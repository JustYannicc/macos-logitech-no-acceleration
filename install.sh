#!/bin/zsh
# Built by @justyannicc
set -eu

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPT_PATH="$PROJECT_DIR/logitech-no-accel"
LABEL="com.$USER.logitech-no-accel"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
VENDOR_ID="${VENDOR_ID:-1133}"
PRODUCT_ID="${PRODUCT_ID:-}"

MATCHING="{\"VendorID\":$VENDOR_ID}"
if [[ -n "$PRODUCT_ID" ]]; then
  MATCHING="{\"VendorID\":$VENDOR_ID,\"ProductID\":$PRODUCT_ID}"
fi

chmod +x "$SCRIPT_PATH"
mkdir -p "$HOME/Library/LaunchAgents"

cat > "$PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$LABEL</string>
  <key>ProgramArguments</key>
  <array>
    <string>/usr/bin/hidutil</string>
    <string>property</string>
    <string>--matching</string>
    <string>$MATCHING</string>
    <string>--set</string>
    <string>{"HIDMouseAcceleration":-1}</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>StartInterval</key>
  <integer>30</integer>
  <key>StandardOutPath</key>
  <string>/tmp/$LABEL.out</string>
  <key>StandardErrorPath</key>
  <string>/tmp/$LABEL.err</string>
</dict>
</plist>
PLIST

plutil -lint "$PLIST" >/dev/null
launchctl bootout "gui/$(id -u)" "$PLIST" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$PLIST"
launchctl kickstart -k "gui/$(id -u)/$LABEL"

echo "Installed $LABEL"
echo "The acceleration fix is applied at login and every 30 seconds."
