# Galaxy Tether for Mac

[한국어](README.ko.md)

Galaxy Tether for Mac lets a Mac use a Galaxy phone's mobile internet over USB. It uses USB tethering only when no other physical network is connected. Wi-Fi and Ethernet take priority.

**Version 1.0.2**

```text
Galaxy internet  ->  USB  ->  Mac
```

## Requirements

- Apple Silicon (M1 or later)
- macOS 26 or later
- A Galaxy phone with USB tethering and a data-capable USB cable

## Install

```sh
brew trust --cask ddotz/galaxytethermac/galaxytethermac
brew tap ddotz/galaxytethermac https://github.com/ddotz/galaxytethermac.git
brew install --cask ddotz/galaxytethermac/galaxytethermac
```

On older Homebrew versions without `brew trust`, omit the first command.

The installer requires Mac administrator authentication. If Homebrew is not installed, use the [latest release PKG](https://github.com/ddotz/galaxytethermac/releases/latest). The PKG is not Developer ID signed or notarized.

On the phone, enable **Developer options → Default USB configuration → USB tethering**, then connect it to the Mac with a data-capable USB cable. On phones without that option, enable **Connections → Mobile Hotspot and Tethering → USB tethering** each time you connect. USB debugging is not required.

## Move from the old cask

If an earlier release was installed from the old `ddotz/tap` tap as `galaxy-usb-tether`, remove that cask and tap before installing the current cask:

```sh
brew uninstall --cask galaxy-usb-tether
brew untap ddotz/tap
brew trust --cask ddotz/galaxytethermac/galaxytethermac
brew tap ddotz/galaxytethermac https://github.com/ddotz/galaxytethermac.git
brew install --cask ddotz/galaxytethermac/galaxytethermac
```

On older Homebrew versions without `brew trust`, omit that command. This is a manual move; Homebrew is not assumed to migrate the old remote automatically.

## Behavior and limitations

- The service starts at boot. It keeps USB tethering idle while Wi-Fi or Ethernet has an active, configured connection.
- When that connection disappears, it can use the Galaxy over USB. When Wi-Fi or Ethernet connects again, it releases the USB connection.
- This policy checks the connection state, not internet reachability. A captive portal or an offline router does not trigger a switch to phone data. VPN and virtual-machine interfaces are not treated as an independent physical connection.
- No separate Galaxy entry appears in macOS Network settings; the connection uses a virtual interface.
- Use [Check-Connection.command](tools/Check-Connection.command) to verify actual USB internet access.
- The connection provides IPv4. IPv6 and every VPN combination are not guaranteed.
- Installation, Wi-Fi priority, fallback to USB with HTTPS access, and release of USB when Wi-Fi returns were verified on macOS 26 with One UI 9. Other hardware, a full reboot, and wake from sleep have not been verified.
- SIP changes and kernel extensions are not required.

## Uninstall

```sh
brew uninstall --cask galaxytethermac
```

For a PKG installation, use [Uninstall.command](tools/Uninstall.command). The phone's default USB configuration must be changed on the phone itself.

## Build from source

On an Apple Silicon Mac with the Xcode command-line tools and Homebrew:

```sh
brew install libusb
make package
```

The PKG is written to `dist/`. The build requires libusb 1.0.30 and bundles the library, so users of the packaged release do not need Homebrew's libusb at runtime.

## Attribution and licenses

This project is based on [android-usb-tether-macos](https://github.com/hknsglm/android-usb-tether-macos) v1.0.0 under the MIT license; attribution is retained in [LICENSE](LICENSE).

This distribution removes the control socket and temporary statistics file, enables automatic monitoring, registers temporary service DNS without changing global DNS, and removes only the paths it adds when it exits.

libusb 1.0.30 is licensed under [LGPL-2.1-or-later](https://www.gnu.org/licenses/old-licenses/lgpl-2.1.html) and is dynamically linked. The [original source archive](https://github.com/libusb/libusb/releases/download/v1.0.30/libusb-1.0.30.tar.bz2) and a license copy are included in release distributions. Reverse engineering for modifying and debugging the library is not restricted.
