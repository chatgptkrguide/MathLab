# MathLab 공동 개발자 온보딩

레포 push 권한을 받으셨다면 아래 순서대로 셋업하세요. 끝까지 따라가면 **시뮬레이터에서 첫 빌드를 단독으로** 실행할 수 있습니다.

> **이 가이드의 범위**: macOS 시뮬레이터(또는 본인 iPhone) 에서 단독으로 개발/테스트.
> TestFlight·App Store·Play Store 배포는 메인테이너(@chatgptkrguide) 가 담당합니다.

## 1. 사전 준비

- **OS**: macOS (iOS 시뮬레이터는 macOS 필수)
- **Flutter SDK**: 3.24.0 이상 — [설치 가이드](https://docs.flutter.dev/get-started/install/macos)
- **Xcode**: 15 이상 (App Store 다운로드)
- **Android Studio** 또는 **VS Code** (Flutter 플러그인 포함)
- **CocoaPods**: `sudo gem install cocoapods`

> Shorebird CLI / Apple Developer Program / Play Console — **불필요**. 시뮬레이터 단독 작업에는 안 씁니다.

확인:
```bash
flutter doctor          # 모든 항목 ✓ 권장 (Xcode signing 경고는 무시 OK)
```

## 2. 코드 가져오기

```bash
git clone https://github.com/chatgptkrguide/MathLab.git
cd MathLab
flutter pub get
cd ios && pod install && cd ..
```

## 3. 시크릿 파일 받기 (메인테이너가 별도 채널로 전달)

3개 파일을 받아 다음 위치에 정확히 배치하세요. **절대 git에 커밋하지 마세요** (.gitignore 처리됨):

| 파일 | 배치 위치 |
|---|---|
| `.env` | 프로젝트 루트 (`/MathLab/.env`) |
| `google-services.json` | `android/app/google-services.json` |
| `GoogleService-Info.plist` | `ios/Runner/GoogleService-Info.plist` |

전달 채널 권장: 1Password 공유 / 암호 zip / Signal. **Slack/이메일/카톡 일반 메시지 X**.

## 4. 첫 빌드 (시뮬레이터)

```bash
flutter analyze                 # 정적 분석 (경고 0 권장)
open -a Simulator               # iOS 시뮬레이터 시작
flutter run -d "iPhone"         # 또는 flutter devices 로 device id 확인 후
```

빌드 약 2-3분 후 시뮬레이터에 앱이 띄워지면 셋업 완료입니다.

**Android 시뮬레이터**:
```bash
flutter emulators --launch Pixel_API_34
flutter run -d emulator
```

## 5. 시뮬레이터에서 동작하는 것 / 안 되는 것

| 기능 | 시뮬레이터 |
|---|---|
| 모든 UI / 화면 전환 | ✅ |
| 게스트(익명) 로그인 | ✅ |
| Google 로그인 (iOS) | ✅ |
| Apple Sign In | ✅ (본인 Apple ID로) |
| Firestore 읽기/쓰기 | ✅ (시드된 단원 12개, 문제, 더미 사용자 8명 보임) |
| 푸시 알림 (FCM) | ⚠️ iOS 시뮬레이터 미지원 (실기기 필요) |
| 인앱결제(IAP) | ❌ 실기기 + Sandbox 필요 |
| 카메라 / 생체인증 | ❌ 시뮬레이터 제약 |

## 6. 자기 작업분을 본인 iPhone에 올리기 (선택)

본인 Apple ID 만으로도 가능:

1. Xcode 에서 `ios/Runner.xcworkspace` 열기
2. Runner 타겟 → **Signing & Capabilities** → Team 을 **본인 Apple ID 의 Personal Team** 으로 변경
3. Bundle ID 를 `com.gomath.mathlab` 이 아닌 본인 것 (예: `com.junyun.mathlab`) 으로 변경
   ⚠️ Bundle ID 변경 시 Firebase 콘솔에서도 본인 Bundle ID 의 iOS 앱을 추가해야 GoogleService-Info.plist 가 매칭됨 → 이건 본인 Firebase 권한 필요. 메인테이너에게 요청.
4. iPhone USB 연결 → `flutter run -d "JIYUN-KO iPhone"`

> 7일마다 재서명 필요 (개인 Apple ID 제한). 동시 3개 앱까지.

대안: **TestFlight 배포는 메인테이너에게 요청** — 본인 iPhone TestFlight 앱에서 받는 게 간단.

## 7. 코드 작업 흐름

```bash
git checkout -b feature/내-작업
# 코드 변경
git add . && git commit -m "feat: ..."
git push origin feature/내-작업
gh pr create                      # PR 생성
```

- `main` 브랜치는 **보호되어 있어 직접 push 불가**합니다. 반드시 PR 통해 머지하세요.
- 일부 경로 (`.github/`, Firebase 설정, `pubspec.yaml` 등) 변경 시 메인테이너 승인 필요 ([CODEOWNERS](./.github/CODEOWNERS) 참조).
- 일반 코드/UI 변경 PR 은 빠르게 머지됩니다.

## 8. App Check Debug Token (선택)

현재 App Check 는 **모니터링 모드** 로 차단하지 않으므로 등록 안 해도 동작합니다.
만약 콘솔 로그에 `App Check debug token: XXXX-XXXX-...` 가 보이면, 메인테이너에게 전달해 Firebase 콘솔에 등록 요청하세요. (ENFORCED 전환 후엔 필수)

## 문제 발생 시

| 증상 | 해결 |
|---|---|
| `pod install` 실패 | `cd ios && pod repo update && pod install` |
| Firebase 초기화 에러 | `google-services.json` / `GoogleService-Info.plist` 위치 재확인 |
| iOS 코드 서명 에러 (시뮬레이터인데) | Build Configuration 이 `Debug` 인지 확인 (Release 가 아니어야 함) |
| `flutter run` 후 빈 화면 | Firestore 데이터가 안 가져와짐 — 메인테이너에 시드 재확인 요청 |
| Google 로그인 실패 (Android 만) | 본인 debug SHA-1 등록이 필요. 메인테이너에 요청 |

## 다음 단계

| 목적 | 문서 |
|---|---|
| 프로젝트 개요, 기술 스택, 폴더 구조 | [`CLAUDE.md`](./CLAUDE.md) |
| 디자인 시스템 | [`DESIGN_GUIDE.md`](./DESIGN_GUIDE.md) |
| 코드 스타일, 커밋 규칙, PR 프로세스 | [`CONTRIBUTING.md`](./CONTRIBUTING.md) |
