# Galaxy Tether for Mac

[English](README.md)

Galaxy Tether for Mac은 Galaxy 휴대전화의 모바일 인터넷을 USB로 Mac에서 사용할 수 있게 합니다. Wi-Fi나 유선 네트워크가 연결돼 있으면 해당 연결을 우선 사용하고, 다른 물리 네트워크 연결이 없을 때만 USB 테더링을 사용합니다.

**버전 1.0.2**

```text
Galaxy internet  ->  USB  ->  Mac
```

## 요구 사항

- Apple Silicon(M1 이상)
- macOS 26 이상
- USB 테더링을 지원하는 Galaxy 휴대전화와 데이터 통신이 가능한 USB 케이블

## 설치

```sh
brew trust --cask ddotz/galaxytethermac/galaxytethermac
brew tap ddotz/galaxytethermac https://github.com/ddotz/galaxytethermac.git
brew install --cask ddotz/galaxytethermac/galaxytethermac
```

`brew trust`를 지원하지 않는 이전 Homebrew 버전에서는 첫 번째 명령을 생략하세요.

설치 프로그램을 실행하려면 Mac 관리자 인증이 필요합니다. Homebrew가 없다면 [최신 릴리스 PKG](https://github.com/ddotz/galaxytethermac/releases/latest)를 사용하세요. PKG에는 Developer ID 서명이나 공증이 적용되지 않았습니다.

휴대전화에서 **개발자 옵션 → 기본 USB 구성 → USB 테더링**을 켠 뒤 데이터 통신이 가능한 USB 케이블로 Mac에 연결하세요. 해당 항목이 없는 휴대전화에서는 연결할 때마다 **연결 → 모바일 핫스팟 및 테더링 → USB 테더링**을 켜세요. USB 디버깅은 필요하지 않습니다.

## 이전 cask에서 이동

이전 릴리스를 이전 `ddotz/tap` tap의 `galaxy-usb-tether` cask로 설치했다면 이전 cask와 tap을 제거한 뒤 현재 cask를 설치하세요.

```sh
brew uninstall --cask galaxy-usb-tether
brew untap ddotz/tap
brew trust --cask ddotz/galaxytethermac/galaxytethermac
brew tap ddotz/galaxytethermac https://github.com/ddotz/galaxytethermac.git
brew install --cask ddotz/galaxytethermac/galaxytethermac
```

`brew trust`를 지원하지 않는 이전 Homebrew 버전에서는 해당 명령을 생략하세요. 이는 수동 이동 절차이며 Homebrew가 이전 원격 tap을 자동으로 이전한다고 가정하지 않습니다.

## 동작과 제한

- 부팅할 때 서비스가 시작됩니다. Wi-Fi나 유선 네트워크가 활성화되고 주소가 설정돼 있으면 USB 테더링을 대기시킵니다.
- 다른 연결이 없어지면 USB를 사용하고, Wi-Fi나 유선 네트워크가 다시 연결되면 USB 연결을 해제합니다.
- 인터넷 접속 가능 여부가 아닌 연결 상태를 기준으로 판단합니다. 로그인 페이지가 필요한 Wi-Fi나 인터넷이 끊긴 공유기에 연결됐다고 휴대폰 데이터로 전환하지 않습니다. VPN·가상머신 인터페이스는 별도 물리 연결로 세지 않습니다.
- macOS 네트워크 설정에 별도의 Galaxy 항목은 표시되지 않으며 가상 인터페이스를 사용합니다.
- [연결 확인 도구](tools/Check-Connection.command)로 실제 USB 인터넷 접속을 확인할 수 있습니다.
- IPv4 연결을 제공합니다. IPv6 및 모든 VPN 조합의 동작은 보장하지 않습니다.
- macOS 26과 One UI 9 조합에서 설치, Wi-Fi 우선 사용, Wi-Fi 해제 시 USB HTTPS 접속, Wi-Fi 복귀 시 USB 연결 해제를 확인했습니다. 다른 하드웨어, 완전한 재부팅, 잠자기 후 복귀는 아직 확인하지 않았습니다.
- SIP 변경이나 커널 확장 설치는 필요하지 않습니다.

## 제거

```sh
brew uninstall --cask galaxytethermac
```

PKG로 설치했다면 [Uninstall.command](tools/Uninstall.command)를 사용하세요. 휴대전화의 기본 USB 구성은 휴대전화에서 직접 변경해야 합니다.

## 소스에서 빌드

Xcode 명령줄 도구와 Homebrew가 설치된 Apple Silicon Mac에서:

```sh
brew install libusb
make package
```

PKG는 `dist/`에 생성됩니다. 빌드에는 libusb 1.0.30이 필요하며 라이브러리를 패키지에 포함하므로 배포 패키지 사용자는 실행할 때 Homebrew libusb를 설치하지 않아도 됩니다.

## 출처와 라이선스

이 프로젝트는 MIT 라이선스의 [android-usb-tether-macos](https://github.com/hknsglm/android-usb-tether-macos) v1.0.0을 기반으로 하며, 원저작자 표시는 [LICENSE](LICENSE)에 유지합니다.

이 배포판은 제어 소켓과 임시 통계 파일을 제거하고, 자동 감시를 활성화하며, 전역 DNS를 변경하지 않고 임시 서비스 DNS를 등록합니다. 종료할 때 자신이 추가한 경로만 정리하도록 수정했습니다.

libusb 1.0.30은 [LGPL-2.1-or-later](https://www.gnu.org/licenses/old-licenses/lgpl-2.1.html) 라이선스이며 동적으로 링크합니다. 릴리스 배포에는 [원본 소스 아카이브](https://github.com/libusb/libusb/releases/download/v1.0.30/libusb-1.0.30.tar.bz2)와 라이선스 사본을 포함합니다. 라이브러리 수정 및 디버깅을 위한 역공학은 제한하지 않습니다.
