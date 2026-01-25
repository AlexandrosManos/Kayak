#!/bin/bash
set -e

if [ -z "$1" ]; then
    echo "Error: Missing target directory."
    echo "Usage: ./build_all_ext.sh <folder_name>"
    echo "  For Server: ./build_all_ext.sh db"
    echo "  For Client: ./build_all_ext.sh splinter"
    exit 1
fi

TARGET_DIR="$HOME/Kayak/$1"

if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Directory $TARGET_DIR does not exist."
    exit 1
fi

echo "Starting Bulk Build & Copy to: $TARGET_DIR"
echo "---------------------------------------------"

EXTENSIONS=("get" "put" "ycsbt" "tao" "bad" "scan" "auth" "long" "checksum" "aggregate" "analysis" "err" "pushback")

BASE_DIR="$HOME/Kayak"

for ext in "${EXTENSIONS[@]}"; do
    echo "Building extension: $ext..."

    cd "$BASE_DIR/ext/$ext"

    # Build
    cargo build --release --quiet

    # Copy
    cp "target/release/lib$ext.so" "$TARGET_DIR/"

    echo "$ext copied."
done

echo "---------------------------------------------"
echo "SUCCESS! All extensions are ready in $TARGET_DIR"

