cask "galaxytethermac" do
  version "1.0.2"
  sha256 "c75671a5a56a36afe3bf3898c60278b11095a464731dfd24f23799bd6a74e887"

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
    Wi-Fi and Ethernet take priority; USB is used only without another connection.
    Your Galaxy provides internet access; your Mac receives it over USB.
    Enable USB tethering in your Galaxy's default USB configuration.
    A background service starts automatically; no Network Settings entry is shown.
    This package is not Developer ID signed or notarized.
  EOS
end
