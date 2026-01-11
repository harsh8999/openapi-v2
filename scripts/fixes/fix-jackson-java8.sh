#!/bin/bash
# ------------------------------------------------------------------
# Fix Jackson Version for Java 8 SDKs
# ------------------------------------------------------------------
# This script updates the Jackson version in the generated
# pom.xml file to ensure compatibility with Spring Boot 2.
#
# Usage: fix-jackson-java8.sh <output_directory> [<jackson_version>]
# ------------------------------------------------------------------

set -e

# The output directory where the generated SDK is located
OUTPUT_DIR="$1"

# The desired Jackson version (default is 2.13.5 if not specified)
JACKSON_VERSION="${2:-2.13.5}"

POM_FILE="$OUTPUT_DIR/pom.xml"

# Update the Jackson version in the pom.xml file
sed -i "s/<jackson-version>.*<\/jackson-version>/<jackson-version>${JACKSON_VERSION}<\/jackson-version>/" "$POM_FILE"
sed -i "s/<jackson-databind-version>.*<\/jackson-databind-version>/<jackson-databind-version>${JACKSON_VERSION}<\/jackson-databind-version>/" "$POM_FILE"

echo "✅ Set Jackson version to $JACKSON_VERSION in pom.xml"
