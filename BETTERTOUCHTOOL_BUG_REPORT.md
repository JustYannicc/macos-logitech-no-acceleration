# BetterTouchTool Bug Report Draft

## Describe the bug

Logitech mouse pointer movement can still feel sluggish/floaty on macOS even after disabling mouse acceleration in macOS and configuring mouse behavior through BetterTouchTool.

In this setup, BetterTouchTool was being used instead of Logitech G HUB / Logi Options because Logitech's driver software is heavy and performs poorly. BetterTouchTool is much better suited for mouse buttons, gestures, scrolling behavior, window actions, and app-specific workflows.

However, even with Logitech driver software not installed and mouse behavior handled through BetterTouchTool, the pointer did not feel like the same mouse on Windows/Linux, or like the same mouse on a Mac with Logitech's driver software installed.

The concrete low-level issue found:

```text
HIDMouseAcceleration=45056
```

was being applied to the Logitech receiver, even though mouse acceleration was supposed to be disabled. Applying:

```sh
hidutil property --matching '{"VendorID":1133}' --set '{"HIDMouseAcceleration":-1}'
```

changed the receiver to:

```text
HIDMouseAcceleration=18446744073709551615
```

and immediately fixed the sluggish/floaty pointer feel.

This may be a BetterTouchTool Logitech mouse integration issue, or it may be a macOS HID/device-state issue that BetterTouchTool could detect/fix when it manages Logitech mice.

Current workaround / reproduction details:

https://github.com/justyannicc/macos-logitech-no-acceleration

## Affected input device

Logitech G502 X via Logitech Powerplay mat / USB receiver.

macOS sees it as:

```text
Manufacturer: Logitech
Product: USB Receiver
VendorID: 1133
ProductID: 50490
ReportInterval: 1000
```

## Screenshots

None yet. The relevant evidence is the `ioreg` / `hidutil` output above.

## Device information

Type of Mac: MacBook Pro, Mac17,8, Apple M5 Pro, 48 GB memory

macOS version: macOS 26.4.1, build 25E253

BetterTouchTool version: 6.512, build 2026051202

## Additional information

No crash logs. This is not a crash.

Important context:

- Logitech G HUB / Logi Options are intentionally not installed.
- BetterTouchTool is used for mouse button/gesture behavior.
- Karabiner-Elements is used for keyboard remapping, not mouse behavior.
- Karabiner's Logitech pointing-device handling was disabled/removed while testing.
- The Logitech receiver reports 1000 Hz, so the issue does not appear to be polling rate.
- macOS global `com.apple.mouse.scaling` was already set to `-1`, but the receiver still had `HIDMouseAcceleration=45056` until fixed with `hidutil`.
