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

# Find Playdate device (usually /dev/sda1 with PLAYDATE label)
DEVICE=$(lsblk -no NAME,LABEL | grep PLAYDATE | awk '{print "/dev/"$1}')
if [ -z "$DEVICE" ]; then
    echo "No Playdate found. Make sure it's connected via USB and in data disk mode."
    echo ""
    echo "On your Playdate:"
    echo "  Settings > System > Reboot to Data Disk"
    echo ""
    echo "To sideload via web instead:"
    echo "  1. zip -r $GAME_NAME.pdx.zip $OUTPUT"
    echo "  2. Upload at https://play.date/account/sideload/"
    exit 1
fi

echo "Found Playdate at $DEVICE"

# Create mount point and mount
MOUNT_POINT="/mnt/playdate"
echo "Mounting Playdate..."
sudo mkdir -p "$MOUNT_POINT"
sudo mount "$DEVICE" "$MOUNT_POINT"

if [ ! -d "$MOUNT_POINT/Games" ]; then
    echo "Error: Mounted device doesn't have a Games directory. Wrong device?"
    sudo umount "$MOUNT_POINT"
    exit 1
fi

echo "Copying $OUTPUT to device..."
sudo rm -rf "$MOUNT_POINT/Games/$GAME_NAME.pdx"
sudo cp -r "$OUTPUT" "$MOUNT_POINT/Games/"
sudo sync

echo "Ejecting..."
sudo umount "$MOUNT_POINT"
echo ""
echo "Deploy OK! Game copied to Playdate."
echo "Your Playdate will reboot and $GAME_NAME should appear in Games."
