#!/bin/bash
# ============================================================================
# generate.sh
#
# - Generates Java SDKs (8 / 17 / 21) for ONE OpenAPI spec
# - Version is passed explicitly from CI
# - Applies all post-generation fixes
# - CI-safe (NO mvn install / deploy here)
#
# Called by GitHub Actions:
#   ./scripts/generate.sh services/foo/foo-openapi.yaml 1.2.0
# ============================================================================

set -euo pipefail

SPEC_FILE="$1"
VERSION="$2"

if [[ -z "${SPEC_FILE:-}" || ! -f "$SPEC_FILE" ]]; then
  echo "❌ OpenAPI spec not found: $SPEC_FILE"
  exit 1
fi

if [[ -z "${VERSION:-}" ]]; then
  echo "❌ Version not provided"
  exit 1
fi

SERVICE_NAME=$(basename "$SPEC_FILE" | sed 's/-openapi\.ya\?ml$//')

GROUP_ID="com.harsh.openapi"
BASE_OUT="generated/${SERVICE_NAME}"

mkdir -p "$BASE_OUT"

generate() {
  local JAVA_VER="$1"
  local DATE_LIB="$2"
  local LIBRARY="$3"
  local OUT_DIR="${BASE_OUT}/java-${JAVA_VER}"

  echo "🚀 Generating Java ${JAVA_VER} SDK (v${VERSION})"

  ADDITIONAL_PROPS="groupId=${GROUP_ID},artifactId=${SERVICE_NAME}-sdk-java${JAVA_VER},artifactVersion=${VERSION},dateLibrary=${DATE_LIB},library=${LIBRARY},hideGenerationTimestamp=true"

  if [[ "$JAVA_VER" == "8" ]]; then
    ADDITIONAL_PROPS="${ADDITIONAL_PROPS},java8=true"
  else
    ADDITIONAL_PROPS="${ADDITIONAL_PROPS},java8=false"
  fi

  openapi-generator-cli generate \
    -i "$SPEC_FILE" \
    -g java \
    -o "$OUT_DIR" \
    --additional-properties "$ADDITIONAL_PROPS"

  # -------------------------------------------------------------------------
  # Post-generation fixes (order matters)
  # -------------------------------------------------------------------------
  ./scripts/fixes/fix-remove-example.sh "$OUT_DIR"
  ./scripts/fixes/fix-duplicate-setter.sh "$OUT_DIR"
  ./scripts/fixes/fix-map-query.sh "$OUT_DIR"

  if [[ "$JAVA_VER" == "8" ]]; then
    ./scripts/fixes/fix-jackson-java8.sh "$OUT_DIR"
    ./scripts/fixes/fix-java8-time.sh "$OUT_DIR"
  else
    ./scripts/fixes/fix-java-version.sh "$OUT_DIR" "$JAVA_VER"
  fi
}

# ---------------------------------------------------------------------------
# Generate all SDK variants
# ---------------------------------------------------------------------------
generate 8  java8               jersey2
generate 17 java8-localdatetime native
generate 21 java11              native

echo "✅ SDKs generated successfully for ${SERVICE_NAME} (v${VERSION})"
