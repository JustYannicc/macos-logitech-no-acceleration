# macOS Logitech No Acceleration

Built by [@justyannicc](https://github.com/justyannicc).

Small fix for Logitech mice on macOS when the pointer feels sluggish or floaty even though mouse acceleration is supposedly disabled.

## Do You Need This?

You probably only need this if all of these are true:

- You use a Logitech mouse on macOS.
- The mouse feels sluggish, floaty, or inconsistent even after disabling pointer acceleration.
- The same mouse feels normal on Windows or Linux.
- The same mouse feels normal on a Mac when Logitech's driver software is installed.
- You do not want to install Logitech G HUB or Logi Options just to fix pointer feel.

This is most likely relevant for Logitech gaming mice that normally rely on G HUB, including mice used through a Lightspeed receiver or Powerplay mat. It was confirmed with a G502 X + Powerplay setup.

It may not be needed for Logitech's productivity mice, Bolt/Unifying devices, or setups managed by Logi Options+. Those devices can expose different IDs and may use different software paths.

If G HUB, Logi Options, LinearMouse, SteerMouse, CursorSense, or another mouse driver is installed, it may override this setting. For the simplest setup, use this without Logitech's own driver software.

## Why Not G HUB, BetterTouchTool, or Karabiner?

Logitech G HUB can make the mouse feel correct, but it is heavy, performs poorly, and is unpleasant to keep running if all you want is normal pointer movement. This tool exists for people who want the mouse to feel right without installing Logitech's driver stack.

BetterTouchTool and Karabiner-Elements are better suited for many input customizations:

- BetterTouchTool is great for mouse buttons, gestures, scrolling behavior, window actions, and app-specific workflows.
- Karabiner-Elements is great for keyboard remapping and low-level key behavior.

However, in this case, even after disabling pointer acceleration in macOS and setting up mouse behavior in BetterTouchTool/Karabiner, the pointer still felt sluggish and floaty. The mouse did not feel like it did on Windows/Linux, or on a Mac with Logitech's own drivers installed. The missing piece was the per-device HID value on the Logitech receiver:

```text
HIDMouseAcceleration
```

This script only fixes that one low-level value. It does not try to replace BetterTouchTool, Karabiner, or your mouse button setup.

## The Problem

This was created after a Logitech G502 X using a Powerplay mat/USB receiver was running at 1000 Hz, but macOS kept reverting the device to:

```text
HIDMouseAcceleration=45056
```

Reapplying this value fixes the feel:

```text
HIDMouseAcceleration=-1
```

In `ioreg`, macOS displays that disabled value as:

```text
HIDMouseAcceleration=18446744073709551615
```

## Compatibility

Known working setup:

- Logitech G502 X
- Logitech Powerplay mat / USB receiver
- macOS
- No Logitech G HUB or Logi Options driver actively managing the mouse

This should work for other Logitech devices that expose the same `HIDMouseAcceleration` property. Logitech's vendor ID is commonly `1133` (`0x046d`), so this tool defaults to matching all Logitech HID devices by vendor ID.

If you want to be more conservative, you can scope it to a specific product ID.

## Install

```sh
git clone https://github.com/justyannicc/macos-logitech-no-acceleration.git
cd macos-logitech-no-acceleration
./install.sh
```

That installs a LaunchAgent which runs at login and every 30 seconds. This matters because macOS can reset the per-device value after reconnecting the receiver or rebooting.

The LaunchAgent runs `/usr/bin/hidutil` directly, so it does not need permission to read the project folder after installation.

## Supported Device

By default this targets Logitech vendor `1133`, which is Logitech's vendor ID as seen by macOS.

Check what macOS sees for your receiver:

```sh
ioreg -r -c IOHIDDevice -l | grep -A20 -B5 'Logitech\|USB Receiver' | grep -E 'VendorID|ProductID|Product|Manufacturer|HIDMouseAcceleration'
```

To scope the one-off command to a specific receiver/product ID:

```sh
VENDOR_ID=1133 PRODUCT_ID=50490 ./logitech-no-accel
```

To install the persistent LaunchAgent scoped to a specific receiver/product ID:

```sh
VENDOR_ID=1133 PRODUCT_ID=50490 ./install.sh
```

## Verify

Run:

```sh
ioreg -r -c IOHIDDevice -l | grep -A40 -B5 'Logitech\\|USB Receiver' | grep HIDMouseAcceleration
```

Good:

```text
HIDMouseAcceleration=18446744073709551615
```

Bad:

```text
HIDMouseAcceleration=45056
```

## Uninstall

```sh
./uninstall.sh
```

## What It Does

The script runs:

```sh
hidutil property --matching '{"VendorID":1133}' --set '{"HIDMouseAcceleration":-1}'
```

If `PRODUCT_ID` is provided, it runs the same command scoped to that specific Logitech product ID.

It does not install Logitech G HUB, change DPI, or remap buttons.
