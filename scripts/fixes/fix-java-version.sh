#!/bin/bash
# ------------------------------------------------------------------
# Fix Maven Java Compiler Version
# ------------------------------------------------------------------
# Ensures that the generated pom.xml explicitly sets the correct
# Java source & target versions.
#
# Usage:
#   fix-java-version.sh <output_directory> <java_version>
#
# Example:
#   fix-java-version.sh generated/product/java-17 17
# ------------------------------------------------------------------

set -e

OUTPUT_DIR="$1"
JAVA_VERSION="$2"

if [ -z "$OUTPUT_DIR" ] || [ -z "$JAVA_VERSION" ]; then
  echo "Usage: fix-java-version.sh <output_directory> <java_version>"
  exit 1
fi

POM_FILE="$OUTPUT_DIR/pom.xml"

if [ ! -f "$POM_FILE" ]; then
  echo "❌ pom.xml not found in $OUTPUT_DIR"
  exit 1
fi

sed -i \
  -e "s|<maven.compiler.source>.*</maven.compiler.source>|<maven.compiler.source>$JAVA_VERSION</maven.compiler.source>|" \
  -e "s|<maven.compiler.target>.*</maven.compiler.target>|<maven.compiler.target>$JAVA_VERSION</maven.compiler.target>|" \
  "$POM_FILE"

echo "✅ Maven compiler set to Java $JAVA_VERSION"
