#!/usr/bin/env bash
set -e

BUILD_DIR="builds"

echo "Cleaning build artifacts..."
rm -rf "$BUILD_DIR"/*.pdx
echo "Done."
