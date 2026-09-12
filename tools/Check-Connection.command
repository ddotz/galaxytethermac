#!/bin/zsh
print '갤럭시 USB 테더링 연결 확인'
if ! /bin/launchctl print system/local.galaxy-usb-tether >/dev/null 2>&1; then
  print '자동 연결 서비스가 설치되어 있지 않거나 중지되어 있습니다.'
  exit 1
fi
print '자동 연결 서비스: 등록됨'
tether_if=$(/usr/sbin/scutil <<'EOF' | /usr/bin/awk '/InterfaceName/ {print $3}'
show State:/Network/Service/android-tether/IPv4
quit
EOF
)
if [[ "$tether_if" != utun<-> ]]; then
  print '현재 USB 연결이 없습니다. 갤럭시의 USB 테더링과 케이블을 확인하세요.'
  exit 1
fi
print "USB 인터페이스: $tether_if"
http_status=$(/usr/bin/curl -4 --interface "$tether_if" --connect-timeout 5 --max-time 10 -s -o /dev/null -w '%{http_code}' https://www.apple.com)
if [[ "$http_status" == 200 ]]; then
  print 'USB 인터넷 접속: 정상'
else
  print "USB 인터넷 접속 확인 실패: $http_status"
fi
