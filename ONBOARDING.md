# MathLab 공동 개발자 온보딩

레포 push 권한을 받으셨다면 아래 순서대로 셋업하세요. 끝까지 따라가면 첫 빌드를 실행할 수 있습니다.

## 1. 사전 준비

- **OS**: macOS (iOS 빌드는 macOS 필수)
- **Flutter SDK**: 3.24.0 이상 — [설치 가이드](https://docs.flutter.dev/get-started/install/macos)
- **Xcode**: 15 이상 (App Store 다운로드)
- **Android Studio** 또는 **VS Code** (Flutter 플러그인 포함)
- **CocoaPods**: `sudo gem install cocoapods`
- **Shorebird CLI**: 아래 한 줄로 설치
  ```bash
  curl --proto '=https' --tlsv1.2 https://raw.githubusercontent.com/shorebirdtech/install/main/install.sh -sSf | bash
  export PATH="$HOME/.shorebird/bin:$PATH"   # ~/.zshrc 에도 추가
  ```

확인:
```bash
flutter doctor          # 모든 항목 ✓ 권장
shorebird --version
```

## 2. 코드 가져오기

```bash
git clone https://github.com/chatgptkrguide/MathLab.git
cd MathLab
flutter pub get
cd ios && pod install && cd ..
```

## 3. 시크릿 파일 받기

[`SECRETS_HANDOVER.md`](./SECRETS_HANDOVER.md) 의 체크리스트대로 1Password 공유 폴더에서 받아 정확한 위치에 배치하세요. 절대 평문 채널(Slack, 이메일, GitHub)로 전달받지 마세요.

## 4. 첫 빌드 검증

```bash
flutter analyze                 # 정적 분석 (경고 0 권장)
flutter run -d <시뮬레이터>     # iOS / Android 시뮬레이터 실행
```

앱이 정상 실행되면 셋업 완료입니다.

## 5. 배포 권한 (각 콘솔 초대 수락 후)

- **App Store Connect**: Apple ID로 초대 메일 수락 → Xcode가 Team `UHL26F5Y87` 자동 인식
- **Google Play Console**: Google 계정으로 초대 수락
- **Firebase Console**: 동일 Google 계정으로 초대 수락

배포 명령:
```bash
./scripts/deploy.sh patch android    # OTA 패치 (Dart 코드만, 90% 사용)
./scripts/deploy.sh test android     # 테스터 배포 (네이티브 변경 시)
./scripts/deploy.sh store android    # Play Store 업로드
./scripts/deploy.sh store ios        # App Store 업로드
```

⚠️ **Shorebird OTA 패치 권한**은 현재 사용자 계정에만 부여되어 있습니다. `patch` 명령은 메인테이너에게 요청하세요. 테스터/스토어 배포만 직접 수행 가능합니다.

## 다음 단계

| 목적 | 문서 |
|---|---|
| 코드 스타일, 커밋 규칙, PR 프로세스 | [`CONTRIBUTING.md`](./CONTRIBUTING.md) |
| 배포 아키텍처 상세 (Shorebird / Firebase / Fastlane) | [`DISTRIBUTION_GUIDE.md`](./DISTRIBUTION_GUIDE.md) |
| 프로젝트 개요, 기술 스택, 폴더 구조 | [`CLAUDE.md`](./CLAUDE.md) |
| 디자인 시스템 | [`DESIGN_GUIDE.md`](./DESIGN_GUIDE.md) |

## 문제 발생 시

- `pod install` 실패 → `cd ios && pod repo update && pod install`
- Shorebird 명령 not found → PATH 확인 (`echo $PATH | grep shorebird`)
- Firebase 초기화 에러 → `google-services.json` / `GoogleService-Info.plist` 위치 재확인
- iOS 코드 서명 에러 → Xcode에서 본인 Apple ID 로그인 + Team 선택 (`UHL26F5Y87`)
