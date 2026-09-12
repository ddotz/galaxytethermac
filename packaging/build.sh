#!/bin/bash
# Build the Galaxy Tether for Mac component and product packages.
# Builds a self-contained arm64 installer from this repository.
set -euo pipefail

PACKAGE_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$PACKAGE_DIR/.." && pwd)"
SOURCE_DIR="$ROOT_DIR"
RELEASE_DIR="$ROOT_DIR/build/release"
BUILD_DIR="$ROOT_DIR/build/package"
STAGE_DIR="$BUILD_DIR/payload-root"
COMPONENT_NAME="GalaxyTetherMac-component.pkg"
COMPONENT_PKG="$BUILD_DIR/$COMPONENT_NAME"
DIST="$PACKAGE_DIR/Distribution.xml"
OUTPUT_DIR="$ROOT_DIR/dist"
OUTPUT_PKG="$OUTPUT_DIR/GalaxyTetherMac-1.0.2-arm64.pkg"
# Keep the installation ID stable so existing users upgrade in place.
IDENTIFIER="local.galaxy-usb-tether"
VERSION="$(cat "$ROOT_DIR/VERSION")"

HELPER_SRC="$RELEASE_DIR/android-tether"
DYLIB_SRC="$RELEASE_DIR/libusb-1.0.0.dylib"
PLIST_SRC="$PACKAGE_DIR/local.galaxy-usb-tether.plist"
CONFIG_SRC="$PACKAGE_DIR/config"
MIT_SRC="$SOURCE_DIR/LICENSE"
LIBUSB_PREFIX="$(brew --prefix libusb)"
LIBUSB_SRC="$LIBUSB_PREFIX/COPYING"

HELPER_DST="$STAGE_DIR/Library/PrivilegedHelperTools/galaxy-usb-tether"
DYLIB_DST="$STAGE_DIR/Library/Application Support/GalaxyUSBTether/lib/libusb-1.0.0.dylib"
CONFIG_DST="$STAGE_DIR/Library/Application Support/GalaxyUSBTether/config"
PLIST_DST="$STAGE_DIR/Library/LaunchDaemons/$IDENTIFIER.plist"
LICENSE_DIR="$STAGE_DIR/Library/Application Support/GalaxyUSBTether/licenses"

die() { echo "Galaxy Tether for Mac package: $*" >&2; exit 1; }
require_file() { [ -f "$1" ] || die "missing required file: $1"; }

[ "$(uname -m)" = arm64 ] || die "Apple Silicon build host required"
[ "$(brew list --versions libusb | awk '{print $2}')" = "1.0.30" ] || die "libusb 1.0.30 required"
make -C "$ROOT_DIR" all
mkdir -p "$RELEASE_DIR"
cp "$ROOT_DIR/build/android-tether" "$HELPER_SRC"
rm -f "$DYLIB_SRC"
cp "$LIBUSB_PREFIX/lib/libusb-1.0.0.dylib" "$DYLIB_SRC"
chmod 0644 "$DYLIB_SRC"
install_name_tool -change "$LIBUSB_PREFIX/lib/libusb-1.0.0.dylib" '@executable_path/../Application Support/GalaxyUSBTether/lib/libusb-1.0.0.dylib' "$HELPER_SRC"
codesign --force --sign - "$HELPER_SRC"
codesign --verify "$HELPER_SRC"

require_file "$HELPER_SRC"
require_file "$DYLIB_SRC"
require_file "$PLIST_SRC"
require_file "$CONFIG_SRC"
require_file "$MIT_SRC"
require_file "$LIBUSB_SRC"

for file in "$HELPER_SRC" "$DYLIB_SRC"; do
    [ "$(/usr/bin/file -b "$file" | /usr/bin/grep -c 'arm64')" -eq 1 ] \
        || die "payload is not arm64: $file"
    [ "$(/usr/bin/lipo -archs "$file")" = "arm64" ] \
        || die "payload has an unexpected architecture: $file"
done

rm -rf "$STAGE_DIR" "$COMPONENT_PKG" "$OUTPUT_PKG"
mkdir -p \
    "$STAGE_DIR/Library/PrivilegedHelperTools" \
    "$STAGE_DIR/Library/LaunchDaemons" \
    "$STAGE_DIR/Library/Application Support/GalaxyUSBTether/lib" \
    "$LICENSE_DIR" \
    "$OUTPUT_DIR"

install -m 0755 "$HELPER_SRC" "$HELPER_DST"
install -m 0644 "$DYLIB_SRC" "$DYLIB_DST"
install -m 0644 "$CONFIG_SRC" "$CONFIG_DST"
install -m 0644 "$PLIST_SRC" "$PLIST_DST"
install -m 0644 "$MIT_SRC" "$LICENSE_DIR/galaxy-usb-tether-MIT.txt"
install -m 0644 "$LIBUSB_SRC" "$LICENSE_DIR/libusb-COPYING.txt"

/bin/chmod 0755 \
    "$STAGE_DIR/Library/Application Support/GalaxyUSBTether" \
    "$STAGE_DIR/Library/Application Support/GalaxyUSBTether/lib" \
    "$LICENSE_DIR"

# Finder provenance xattrs are workstation metadata, not package payload.
# Remove them from the private staging tree so pkgbuild cannot emit AppleDouble
# (._*) entries alongside the actual files.
/usr/bin/xattr -rc "$STAGE_DIR" 2>/dev/null || true

xattr -cr "$STAGE_DIR"

pkgbuild \
    --root "$STAGE_DIR" \
    --scripts "$PACKAGE_DIR/scripts" \
    --identifier "$IDENTIFIER" \
    --version "$VERSION" \
    --install-location / \
    --ownership recommended \
    --min-os-version 26.0 \
    "$COMPONENT_PKG"

productbuild \
    --distribution "$DIST" \
    --package-path "$BUILD_DIR" \
    --resources "$PACKAGE_DIR/resources" \
    --identifier "$IDENTIFIER" \
    --version "$VERSION" \
    "$OUTPUT_PKG"

# Verify the component payload and the product's embedded Distribution before
# reporting success.  Keep the component and Distribution as review evidence.
PAYLOAD_FILES="$(pkgutil --payload-files "$COMPONENT_PKG")"
NORMALIZED_PAYLOAD_FILES="$(printf '%s\n' "$PAYLOAD_FILES" | /usr/bin/sed 's#^\./##')"
for expected in \
    "Library/PrivilegedHelperTools/galaxy-usb-tether" \
    "Library/LaunchDaemons/$IDENTIFIER.plist" \
    "Library/Application Support/GalaxyUSBTether/config" \
    "Library/Application Support/GalaxyUSBTether/lib/libusb-1.0.0.dylib" \
    "Library/Application Support/GalaxyUSBTether/licenses/galaxy-usb-tether-MIT.txt" \
    "Library/Application Support/GalaxyUSBTether/licenses/libusb-COPYING.txt"; do
    printf '%s\n' "$NORMALIZED_PAYLOAD_FILES" | /usr/bin/grep -Fxq "$expected" \
        || die "component payload missing: $expected"
done

EXPANDED_DIR="$BUILD_DIR/product-expanded"
rm -rf "$EXPANDED_DIR"
pkgutil --expand "$OUTPUT_PKG" "$EXPANDED_DIR"
/usr/bin/grep -Fq 'hostArchitectures="arm64"' "$EXPANDED_DIR/Distribution" \
    || die "product Distribution does not restrict host architecture to arm64"
/usr/bin/grep -Fq '<os-version min="26.0"/>' "$EXPANDED_DIR/Distribution" \
    || die "product Distribution does not require macOS 26.0"
/usr/bin/grep -Fq 'rootVolumeOnly="true"' "$EXPANDED_DIR/Distribution" \
    || die "product Distribution does not restrict installation to the boot volume"

echo "Package: $OUTPUT_PKG"
echo "Component: $COMPONENT_PKG"
echo "Identifier: $IDENTIFIER"
echo "Version: $VERSION"
echo "Architectures: helper=$(lipo -archs "$HELPER_SRC"), dylib=$(lipo -archs "$DYLIB_SRC")"
echo "Payload files:"
printf '%s\n' "$PAYLOAD_FILES"
