#!/bin/zsh
set -e
print '갤럭시 USB 테더링 자동 연결 서비스를 제거합니다.'
sudo /bin/sh -c '
/bin/launchctl bootout system/local.galaxy-usb-tether 2>/dev/null || true
/bin/rm -f /Library/LaunchDaemons/local.galaxy-usb-tether.plist
/bin/rm -f /Library/PrivilegedHelperTools/galaxy-usb-tether
/bin/rm -rf "/Library/Application Support/GalaxyUSBTether"
/usr/sbin/pkgutil --forget local.galaxy-usb-tether >/dev/null 2>&1 || true
'
print '제거 완료. 갤럭시의 기본 USB 구성은 휴대폰에서 변경할 수 있습니다.'
