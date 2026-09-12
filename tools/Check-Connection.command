#!/bin/zsh
print 'Galaxy Tether for Mac — connection status'
if ! /bin/launchctl print system/local.galaxy-usb-tether >/dev/null 2>&1; then
  print 'The automatic connection service is not installed or is stopped.'
  exit 1
fi
print 'Automatic connection service: registered'
network_state=$(/Library/PrivilegedHelperTools/galaxy-usb-tether --network-status)
if [[ "$network_state" == connected-other-network* ]]; then
  print 'Wi-Fi/Ethernet is connected. USB tethering is on standby.'
  exit 0
elif [[ "$network_state" == network-status-unavailable ]]; then
  print 'Cannot determine other-network status. USB remains on standby.'
  exit 1
fi
tether_if=$(/usr/sbin/scutil <<'EOF' | /usr/bin/awk '/InterfaceName/ {print $3}'
show State:/Network/Service/android-tether/IPv4
quit
EOF
)
if [[ "$tether_if" != utun<-> ]]; then
  print 'No USB connection. Check USB tethering on your Galaxy and the cable.'
  exit 1
fi
print "USB interface: $tether_if"
http_status=$(/usr/bin/curl -4 --interface "$tether_if" --connect-timeout 5 --max-time 10 -s -o /dev/null -w '%{http_code}' https://www.apple.com)
if [[ "$http_status" == 200 ]]; then
  print 'Galaxy → USB → Mac internet: connected'
else
  print "USB internet check failed: $http_status"
fi
