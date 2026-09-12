# Galaxy USB Tether for Mac

갤럭시를 USB로 연결하면 Mac이 인터넷을 사용할 수 있게 해 주는 RNDIS 연결 도구입니다. 설치 시 자동 실행 서비스를 등록합니다.

## 설치

Apple Silicon(M1 이상), macOS 26 이상이 필요합니다.

```sh
brew install --cask ddotz/tap/galaxy-usb-tether
```

설치 중 Mac 관리자 인증이 필요합니다. Homebrew가 없다면 [Releases](https://github.com/ddotz/galaxy-usb-tether/releases/latest)의 PKG를 설치하세요. 패키지는 Developer ID 서명 및 Apple 공증을 받지 않았습니다.

갤럭시에서 **개발자 옵션 → 기본 USB 구성 → USB 테더링**을 선택한 뒤 데이터 통신 가능한 USB 케이블로 Mac에 연결합니다. 해당 항목이 없는 기기는 연결할 때마다 **연결 → 모바일 핫스팟 및 테더링 → USB 테더링**을 켜세요. USB 디버깅은 필요하지 않습니다.

## 동작과 제한

- Mac 부팅 시 자동 시작하며, USB 테더링이 켜진 기기를 감지하면 연결합니다.
- 시스템 설정의 네트워크 목록에 별도 갤럭시 항목은 표시되지 않습니다. 가상 인터페이스를 사용합니다.
- [연결 확인 도구](tools/Check-Connection.command)로 실제 USB 인터넷 접속을 확인할 수 있습니다.
- IPv4 연결을 제공합니다. IPv6 및 모든 VPN 조합의 동작을 보장하지 않습니다.
- macOS 26 / One UI 9 조합에서 설치, 자동 서비스 시작, USB HTTPS 접속을 확인했습니다. 다른 하드웨어, 실제 재부팅 및 잠자기 복귀는 아직 검증하지 않았습니다.
- SIP 변경이나 커널 확장 설치는 필요하지 않습니다.

## 제거

```sh
brew uninstall --cask galaxy-usb-tether
```

PKG로 설치했다면 [제거 도구](tools/Uninstall.command)를 사용하세요. 갤럭시의 기본 USB 구성은 휴대폰에서 직접 변경합니다.

## 소스에서 빌드

Xcode 명령줄 도구와 Homebrew가 있는 Apple Silicon Mac에서:

```sh
brew install libusb
make package
```

`dist/`에 PKG가 생성됩니다. 빌드 도구는 libusb 1.0.30을 요구하며, 라이브러리를 패키지에 포함합니다. 배포본 사용자는 Homebrew libusb가 없어도 실행할 수 있습니다.

## 출처와 라이선스

[Hakan Saglam의 android-usb-tether-macos](https://github.com/hknsglm/android-usb-tether-macos) v1.0.0을 기반으로 합니다(MIT). 원저작자 표시는 LICENSE에 유지합니다.

이 배포판은 제어 소켓과 임시 통계 파일을 제거하고, 자동 감시를 활성화하며, 전역 DNS 변경 없이 임시 서비스 DNS를 등록합니다. 종료할 때 자신이 추가한 경로만 정리하도록 수정했습니다. Samsung 또는 Apple의 공식 제품은 아닙니다.

libusb 1.0.30은 LGPL-2.1-or-later이며 동적 링크합니다. [원본 소스](https://github.com/libusb/libusb/releases/download/v1.0.30/libusb-1.0.30.tar.bz2)와 라이선스 사본을 릴리스 배포에 포함합니다. 해당 라이브러리의 수정 및 디버깅을 위한 역공학을 제한하지 않습니다.
