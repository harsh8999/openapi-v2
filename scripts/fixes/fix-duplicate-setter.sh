#!/bin/bash
# -----------------------------------------------------------------------------
# fix-duplicate-setter.sh
#
# PURPOSE
# -------
# OpenAPI Generator creates TWO setters for properties whose name starts with
# "setXxx" (example: setDescription):
#
#   1. Fluent setter  -> ProductDTO setSetDescription(String)
#   2. Bean setter    -> void setSetDescription(String)
#
# Java does NOT allow both to exist at the same time → compilation failure.
#
# This script SAFELY removes ONLY the fluent setter while keeping
# the standard JavaBean setter required by Jackson.
#
# Works for:
# - Java 8
# - Java 17
# - Java 21
#
# USAGE
# -----
#   fix-duplicate-setter.sh <generated-sdk-dir>
#
# Example:
#   fix-duplicate-setter.sh generated/product-discovery/java-17
# -----------------------------------------------------------------------------

set -euo pipefail

OUT_DIR="$1"
MODEL_DIR="$OUT_DIR/src/main/java"

if [[ ! -d "$MODEL_DIR" ]]; then
  echo "ℹ️  No Java sources found, skipping duplicate-setter fix"
  exit 0
fi

echo "🧹 Fixing duplicate fluent setters (setSetXxx)..."

# Find ALL model files
find "$MODEL_DIR" -name "*.java" | while read -r file; do
  # Only process files that contain a fluent setter returning the same class
  if grep -qE "public\s+[A-Za-z0-9_]+\s+setSet[A-Za-z0-9_]+\(" "$file"; then
    echo "  🔧 Processing $(basename "$file")"

    # Remove ONLY fluent setters like:
    # public ProductDTO setSetDescription(String value) { ... }
    awk '
      BEGIN { skip=0 }
      /public [A-Za-z0-9_]+ setSet[A-Za-z0-9_]+\(/ {
        skip=1
        next
      }
      skip && /^\s*\}/ {
        skip=0
        next
      }
      !skip { print }
    ' "$file" > "${file}.tmp"

    mv "${file}.tmp" "$file"
  fi
done

echo "✅ Duplicate fluent setters removed"
