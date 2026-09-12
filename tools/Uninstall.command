#!/bin/zsh
set -e
print 'Removing Galaxy Tether for Mac.'
sudo /bin/sh -c '
/bin/launchctl bootout system/local.galaxy-usb-tether 2>/dev/null || true
/bin/rm -f /Library/LaunchDaemons/local.galaxy-usb-tether.plist
/bin/rm -f /Library/PrivilegedHelperTools/galaxy-usb-tether
/bin/rm -rf "/Library/Application Support/GalaxyUSBTether"
/usr/sbin/pkgutil --forget local.galaxy-usb-tether >/dev/null 2>&1 || true
'
print 'Removed. You can change the default USB configuration on your Galaxy.'
