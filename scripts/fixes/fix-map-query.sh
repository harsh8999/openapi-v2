#!/bin/bash
# ------------------------------------------------------------------
# Fix Map Query Parameters for Flat Query Params
# ------------------------------------------------------------------
# This script modifies generated API classes to ensure that
# Map query parameters are serialized as flat query parameters
# instead of nested ones.
#
# Usage: fix-map-query.sh <output_directory>
# ------------------------------------------------------------------

set -e

# The output directory where the generated API files are located
OUTPUT_DIR="$1"

# Path to the API package
API_DIR="$OUTPUT_DIR/src/main/java/com/example/api" # Adjust path as needed

# Iterate over all API Java files
find "$API_DIR" -name "*.java" | while read -r api_file; do
  # Apply the fix for Map query parameters (example using sed)
  sed -i 's/parameterToPairs/parameterToFlatPairs/' "$api_file" # Example logic
done

echo "✅ Fixed Map query parameters in API classes"
