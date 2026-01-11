#!/bin/bash
# ------------------------------------------------------------------
# Fix Duplicate Setter Method in ProductDTO
# ------------------------------------------------------------------
# This script addresses the issue where the generated
# ProductDTO class contains a duplicate 'setDescription'
# method due to a naming conflict.
#
# Usage: fix-duplicate-setter.sh <output_directory>
# ------------------------------------------------------------------

set -e

# The output directory where the generated Java files are located
OUTPUT_DIR="$1"

# Find all Java files in the output directory
find "$OUTPUT_DIR" -name "*.java" | while read -r file; do
  # Replace the conflicting method name
  sed -i 's/public ProductDTO setDescription(/public ProductDTO setSetDescription(/' "$file" || true
done

echo "✅ Fixed duplicate setter method in ProductDTO"
