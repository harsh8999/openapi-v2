#!/bin/bash
# ------------------------------------------------------------------
# Fix Java 8 Time / Jackson Incompatibilities
# ------------------------------------------------------------------
# OpenAPI Generator sometimes generates Java 8 SDKs that depend on
# Java Time APIs and Jackson modules that are NOT compatible with
# Jackson 2.13.x (used by Spring Boot 2).
#
# This script:
#  - Removes RFC3339* Java time classes
#  - Converts JavaTimeFormatter into a stub
#  - Removes OffsetDateTime handling from ApiClient
#  - Removes RFC3339JavaTimeModule from JSON.java
#
# Usage:
#   fix-java8-time.sh <output_directory> <base_package>
#
# Example:
#   fix-java8-time.sh generated/product/java-8 com.jumbotail.openapi.productsdk
# ------------------------------------------------------------------

set -e

OUTPUT_DIR="$1"
PACKAGE_BASE="$2"

if [ -z "$OUTPUT_DIR" ] || [ -z "$PACKAGE_BASE" ]; then
  echo "Usage: fix-java8-time.sh <output_directory> <base_package>"
  exit 1
fi

PACKAGE_PATH=$(echo "$PACKAGE_BASE" | tr '.' '/')
BASE_PATH="$OUTPUT_DIR/src/main/java/$PACKAGE_PATH"

echo "🧹 Fixing Java 8 time incompatibilities in $OUTPUT_DIR"

# ------------------------------------------------------------------
# Remove incompatible Java Time classes
# ------------------------------------------------------------------
rm -f \
  "$BASE_PATH/RFC3339InstantDeserializer.java" \
  "$BASE_PATH/RFC3339JavaTimeModule.java" || true

# ------------------------------------------------------------------
# Replace JavaTimeFormatter with stub
# ------------------------------------------------------------------
JAVA_TIME_FILE="$BASE_PATH/JavaTimeFormatter.java"

if [ -f "$JAVA_TIME_FILE" ]; then
  cat > "$JAVA_TIME_FILE" <<EOF
package $PACKAGE_BASE;

/**
 * Stub JavaTimeFormatter for Java 8 SDKs.
 * Not used when dateLibrary=java8.
 */
public class JavaTimeFormatter {
  // Intentionally empty
}
EOF
fi

# ------------------------------------------------------------------
# Remove OffsetDateTime handling from ApiClient
# ------------------------------------------------------------------
API_CLIENT="$BASE_PATH/ApiClient.java"

if [ -f "$API_CLIENT" ] && grep -q "OffsetDateTime" "$API_CLIENT"; then
  awk '
    /^import java\.time\.OffsetDateTime;/ { next }
    /instanceof OffsetDateTime/ { skip=1; next }
    skip && /^\s*}/ { skip=0; next }
    !skip { print }
  ' "$API_CLIENT" > "${API_CLIENT}.tmp" && mv "${API_CLIENT}.tmp" "$API_CLIENT"
fi

# ------------------------------------------------------------------
# Remove RFC3339JavaTimeModule from JSON.java
# ------------------------------------------------------------------
JSON_FILE="$BASE_PATH/JSON.java"

if [ -f "$JSON_FILE" ]; then
  sed -i '/RFC3339JavaTimeModule/d' "$JSON_FILE"
fi

echo "✅ Java 8 time fixes applied"
