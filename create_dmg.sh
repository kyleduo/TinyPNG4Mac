#!/bin/bash

# 设置变量
DMG_NAME="Tiny-Image-Installer.dmg"
VOLUME_NAME="Tiny Image Installer"
BACKGROUND_IMAGE="images/dmg_background.png"
APP_PATH="dmg_source/"
ICON_NAME="Tiny Image.app"

# 检查是否安装了 create-dmg
if ! command -v create-dmg &> /dev/null; then
  echo "Error: create-dmg is not installed. Please install it first."
  exit 1
fi

# 创建 DMG
create-dmg \
  --volname "$VOLUME_NAME" \
  --background "$BACKGROUND_IMAGE" \
  --window-size 640 420 \
  --icon "$ICON_NAME" 180 220 \
  --icon-size 100 \
  --hide-extension "$ICON_NAME" \
  --app-drop-link 440 220 \
  "$DMG_NAME" \
  "$APP_PATH"

# 检查命令是否成功
if [ $? -eq 0 ]; then
  echo "DMG created successfully: $DMG_NAME"
else
  echo "Failed to create DMG."
  exit 1
fi
