#!/usr/bin/env bash
set -e

GAME_NAME="GameJam"
SOURCE_DIR="source"
BUILD_DIR="builds"
OUTPUT="$BUILD_DIR/$GAME_NAME.pdx"

# Use PLAYDATE_SDK_PATH if set, otherwise try common locations
if [ -z "$PLAYDATE_SDK_PATH" ]; then
    if [ -d "$HOME/.local/share/playdate-sdk" ]; then
        export PLAYDATE_SDK_PATH="$HOME/.local/share/playdate-sdk"
    elif [ -d "/opt/playdate-sdk" ]; then
        export PLAYDATE_SDK_PATH="/opt/playdate-sdk"
    elif [ -d "$HOME/Developer/PlaydateSDK" ]; then
        export PLAYDATE_SDK_PATH="$HOME/Developer/PlaydateSDK"
    else
        echo "Error: PLAYDATE_SDK_PATH not set and SDK not found in common locations."
        exit 1
    fi
fi

PDC="$PLAYDATE_SDK_PATH/bin/pdc"
SIM="$PLAYDATE_SDK_PATH/bin/PlaydateSimulator"

echo "SDK: $PLAYDATE_SDK_PATH"
echo "Building $SOURCE_DIR -> $OUTPUT"
"$PDC" "$SOURCE_DIR" "$OUTPUT"
echo "Build OK. Launching simulator..."
"$SIM" "$OUTPUT"
