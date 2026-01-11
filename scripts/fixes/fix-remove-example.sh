#!/bin/bash
# ------------------------------------------------------------------
# Remove Duplicate com.example Package
# ------------------------------------------------------------------
# OpenAPI Generator sometimes generates example code under
# com.example.* even when a real package is configured.
#
# This script removes com.example if another root package exists.
#
# Usage:
#   fix-remove-example.sh <output_directory>
# ------------------------------------------------------------------

set -e

OUTPUT_DIR="$1"

if [ -z "$OUTPUT_DIR" ]; then
  echo "Usage: fix-remove-example.sh <output_directory>"
  exit 1
fi

JAVA_MAIN="$OUTPUT_DIR/src/main/java"
JAVA_TEST="$OUTPUT_DIR/src/test/java"

if [ -d "$JAVA_MAIN/com/example" ]; then
  echo "🧹 Removing com.example package"
  rm -rf "$JAVA_MAIN/com/example"
  rm -rf "$JAVA_TEST/com/example" 2>/dev/null || true
fi

echo "✅ com.example cleanup done"
