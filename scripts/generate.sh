#!/bin/bash
# ============================================================================
# generate.sh
# - Generates Java SDKs (8 / 17 / 21) for ONE OpenAPI spec
# - Applies all post-generation fixes
# - CI-safe (no mvn install/deploy)
# ============================================================================

set -euo pipefail

SPEC_FILE="$1"

if [ -z "$SPEC_FILE" ] || [ ! -f "$SPEC_FILE" ]; then
  echo "❌ OpenAPI spec not found: $SPEC_FILE"
  exit 1
fi

SERVICE_NAME=$(basename "$SPEC_FILE" | sed 's/-openapi\.ya\?ml//')
VERSION=$(grep -E '^[[:space:]]*version:' "$SPEC_FILE" | head -1 | sed 's/.*: *//')

if [ -z "$VERSION" ]; then
  echo "❌ info.version missing in $SPEC_FILE"
  exit 1
fi

GROUP_ID="com.harsh.openapi.${SERVICE_NAME}"
BASE_OUT="generated/${SERVICE_NAME}"

mkdir -p "$BASE_OUT"

generate() {
  local JAVA_VER="$1"
  local DATE_LIB="$2"
  local OUT_DIR="${BASE_OUT}/java-${JAVA_VER}"

  echo "🚀 Generating Java ${JAVA_VER} SDK"

  openapi-generator-cli generate \
    -i "$SPEC_FILE" \
    -g java \
    -o "$OUT_DIR" \
    --additional-properties \
      groupId="${GROUP_ID}" \
      ,artifactId="${SERVICE_NAME}-sdk-java${JAVA_VER}" \
      ,artifactVersion="${VERSION}" \
      ,dateLibrary="${DATE_LIB}" \
      ,library=jersey2 \
      ,hideGenerationTimestamp=true

  # Apply fixes
  ./scripts/fixes/fix-remove-example.sh "$OUT_DIR"
  ./scripts/fixes/fix-duplicate-setter.sh "$OUT_DIR"
  ./scripts/fixes/fix-map-query.sh "$OUT_DIR"

  if [ "$JAVA_VER" = "8" ]; then
    ./scripts/fixes/fix-jackson-java8.sh "$OUT_DIR"
    ./scripts/fixes/fix-java8-time.sh "$OUT_DIR"
  else
    ./scripts/fixes/fix-java-version.sh "$OUT_DIR" "$JAVA_VER"
  fi
}

generate 8  java8
generate 17 java8-localdatetime
generate 21 java11

echo "✅ SDKs generated for $SERVICE_NAME"
