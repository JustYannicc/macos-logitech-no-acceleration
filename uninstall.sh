#!/bin/zsh
# Built by @justyannicc
set -eu

LABEL="com.$USER.logitech-no-accel"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"

launchctl bootout "gui/$(id -u)" "$PLIST" 2>/dev/null || true
rm -f "$PLIST"

echo "Uninstalled $LABEL"
