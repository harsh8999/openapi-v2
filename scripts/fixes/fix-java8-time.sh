#!/bin/bash
# =============================================================================
# fix-java8-time.sh
#
# PURPOSE
# -------
# OpenAPI Generator sometimes generates Java 8 SDKs that depend on:
#   - java.time.* classes (OffsetDateTime, Instant, etc.)
#   - RFC3339 Jackson modules
#
# These classes are NOT compatible with:
#   - Jackson 2.13.x
#   - Spring Boot 2.x (common in legacy Java 8 services)
#
# This script fixes those incompatibilities by:
#   1. Detecting the ACTUAL generated Java package (auto-detected, no hardcoding)
#   2. Removing RFC3339 Java Time helper classes
#   3. Replacing JavaTimeFormatter with a safe stub
#   4. Removing OffsetDateTime handling from ApiClient
#   5. Removing RFC3339JavaTimeModule usage from JSON.java
#
# This script is:
#   - CI-safe
#   - Idempotent (can run multiple times safely)
#   - Compatible with GitHub Actions runners (Linux)
#
# USAGE
# -----
#   fix-java8-time.sh <output_directory>
#
# EXAMPLE
# -------
#   fix-java8-time.sh generated/product-discovery/java-8
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# Input validation
# -----------------------------------------------------------------------------
OUT_DIR="$1"

SRC_DIR="$OUT_DIR/src/main/java"

if [[ ! -d "$SRC_DIR" ]]; then
  echo "⚠️  src/main/java not found in $OUT_DIR — skipping Java 8 time fixes"
  exit 0
fi

# -----------------------------------------------------------------------------
# Detect the real generated package
#
# IMPORTANT:
# We DO NOT assume:
#   - groupId == packageName
#   - com.example
#
# Instead, we locate ApiClient.java and derive the package path from it.
# This makes the script robust across all OpenAPI generator configurations.
# -----------------------------------------------------------------------------
BASE_PATH=$(find "$SRC_DIR" -name ApiClient.java | sed 's|/ApiClient.java||' | head -1)

if [[ -z "$BASE_PATH" ]]; then
  echo "⚠️  ApiClient.java not found — skipping Java 8 time fixes"
  exit 0
fi

# Convert filesystem path → Java package
PACKAGE_NAME=$(echo "$BASE_PATH" | sed "s|$SRC_DIR/||" | tr '/' '.')

echo "🧹 Applying Java 8 time fixes in package: $PACKAGE_NAME"

# -----------------------------------------------------------------------------
# 1️⃣ Remove RFC3339 Java Time helper classes
#
# These classes rely on Jackson features NOT available in 2.13.x
# -----------------------------------------------------------------------------
rm -f "$BASE_PATH/RFC3339InstantDeserializer.java" || true
rm -f "$BASE_PATH/RFC3339JavaTimeModule.java" || true

# -----------------------------------------------------------------------------
# 2️⃣ Replace JavaTimeFormatter with a safe stub
#
# ApiClient depends on JavaTimeFormatter, but:
#   - It is unused when dateLibrary=java8
#   - The generated implementation is unsafe for Jackson 2.13
#
# So we replace it with a minimal stub class.
# -----------------------------------------------------------------------------
if [[ -f "$BASE_PATH/JavaTimeFormatter.java" ]]; then
  cat > "$BASE_PATH/JavaTimeFormatter.java" <<EOF
package $PACKAGE_NAME;

/**
 * Stub class for JavaTimeFormatter.
 *
 * This exists only to satisfy ApiClient dependencies.
 * It is intentionally empty for Java 8 + Jackson 2.13 compatibility.
 */
public class JavaTimeFormatter {
}
EOF
fi

# -----------------------------------------------------------------------------
# 3️⃣ Remove OffsetDateTime handling from ApiClient
#
# OffsetDateTime serialization requires newer Jackson modules.
# Removing this ensures the SDK compiles and runs on Java 8.
# -----------------------------------------------------------------------------
API_CLIENT="$BASE_PATH/ApiClient.java"

if [[ -f "$API_CLIENT" ]]; then
  sed -i '/OffsetDateTime/d' "$API_CLIENT"
fi

# -----------------------------------------------------------------------------
# 4️⃣ Remove RFC3339JavaTimeModule usage from JSON.java
#
# This module is unavailable in Jackson 2.13.x.
# -----------------------------------------------------------------------------
JSON_FILE="$BASE_PATH/JSON.java"

if [[ -f "$JSON_FILE" ]]; then
  sed -i '/RFC3339JavaTimeModule/d' "$JSON_FILE"
fi

echo "✅ Java 8 time compatibility fixes applied successfully"
