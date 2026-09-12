cask "galaxytethermac" do
  version "1.0.1"
  sha256 "eef0ec717181612614fa475af3b08c70c9e5fae3db0e6ecac138d517c846c027"

  url "https://github.com/ddotz/galaxytethermac/releases/download/v#{version}/GalaxyTetherMac-#{version}-arm64.pkg"
  name "Galaxy Tether for Mac"
  desc "Share Galaxy phone internet over USB"
  homepage "https://github.com/ddotz/galaxytethermac"

  depends_on arch: :arm64
  depends_on macos: :tahoe

  pkg "GalaxyTetherMac-#{version}-arm64.pkg"

  uninstall launchctl: "local.galaxy-usb-tether",
            pkgutil:   "local.galaxy-usb-tether"

  caveats <<~EOS
    Your Galaxy provides internet access; your Mac receives it over USB.
    Enable USB tethering in your Galaxy's default USB configuration.
    A background service starts automatically; no Network Settings entry is shown.
    This package is not Developer ID signed or notarized.
  EOS
end
