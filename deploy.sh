#!/usr/bin/env bash
set -e

GAME_NAME="GameJam"
BUILD_DIR="builds"
OUTPUT="$BUILD_DIR/$GAME_NAME.pdx"

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
PDUTIL="$PLAYDATE_SDK_PATH/bin/pdutil"

# Build first
echo "SDK: $PLAYDATE_SDK_PATH"
echo "Building $SOURCE_DIR -> $OUTPUT"
"$PDC" source "$OUTPUT"
echo "Build OK."

# Deploy to device
echo ""
echo "Looking for connected Playdate..."
if ! "$PDUTIL" list 2>/dev/null | grep -q .; then
    echo "No Playdate found. Connect via USB and unlock the device."
    echo ""
    echo "To sideload via web instead:"
    echo "  1. zip -r $GAME_NAME.pdx.zip $OUTPUT"
    echo "  2. Upload at https://play.date/account/sideload/"
    exit 1
fi

echo "Installing $OUTPUT to device..."
"$PDUTIL" install "$OUTPUT"
echo "Deploy OK. Game should appear on the Playdate."
