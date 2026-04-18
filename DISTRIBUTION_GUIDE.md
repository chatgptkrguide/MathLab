# MathLab 테스트 배포 가이드

## 아키텍처

```
코드 수정 → Shorebird Patch → 테스터 앱 자동 업데이트 (OTA)
                 또는
코드 수정 → Flutter Build → Firebase App Distribution → 테스터 수동 설치
```

- **Dart 코드만 변경**: Shorebird OTA 패치 (자동 업데이트)
- **네이티브 변경** (플러그인 추가, 권한 변경 등): Firebase App Distribution으로 재배포

---

## 초기 설정 (한 번만)

### 1. Shorebird 로그인 및 초기화
```bash
shorebird login          # 브라우저에서 Google 로그인
shorebird init           # 프로젝트 연결 (shorebird.yaml 생성)
```

### 2. Firebase 테스터 그룹 설정
1. Firebase Console → MathLab 프로젝트 → App Distribution
2. "testers" 그룹 생성
3. 클라이언트 이메일 추가

### 3. Firebase CLI 로그인
```bash
firebase login
```

### 4. Fastlane 설치 (선택사항)
```bash
gem install fastlane
cd android && fastlane add_plugin firebase_app_distribution
cd ../ios && fastlane add_plugin firebase_app_distribution
```

### 5. iOS 추가 설정
- Apple Developer에서 Ad Hoc 프로비저닝 프로필 생성
- `ios/exportOptions-adhoc.plist`에서 `YOUR_TEAM_ID`를 실제 Team ID로 교체
- `ios/fastlane/Appfile`에 apple_id와 team_id 입력

### 6. App Store Connect 앱 생성 (최초 1회)
App Store 배포 전 App Store Connect에 앱 레코드가 존재해야 합니다.
```bash
cd ios && fastlane create_app
```
사전 조건:
- Apple Developer Program 멤버십 활성 상태
- Apple Developer Portal에 Bundle ID `com.gomath.mathlab` 등록
- Apple Developer 계정 역할: Admin 또는 Account Holder

### 7. Google Play 배포 키 설정
Play Store 자동 업로드를 위해 서비스 계정 JSON이 필요합니다.
1. Google Play Console → 설정 → API 액세스 → 서비스 계정 생성
2. Google Cloud Console에서 해당 계정의 JSON 키 다운로드
3. `.secrets/play-store-deploy.json`으로 저장 (프로젝트 루트)
4. `.gitignore`에 `.secrets/` 포함 확인 (이미 포함됨)

**주의**: Google Play Store는 최초 앱 등록을 웹 콘솔에서만 할 수 있습니다. CLI 자동화는 등록 이후 업데이트 업로드에만 가능합니다.

---

## 첫 릴리스 (Shorebird 기반)

```bash
# Android 첫 릴리스
shorebird release android

# iOS 첫 릴리스
shorebird release ios

# 테스터에게 배포
./scripts/distribute.sh android   # 또는 ios / both
```

---

## 일상 업데이트 워크플로우

### Dart 코드만 변경한 경우 (90% 이상의 경우)
```bash
# 코드 수정 후 OTA 패치 (테스터 자동 업데이트)
./scripts/patch.sh android        # 또는 ios / both

# 또는 Fastlane 사용
cd android && fastlane patch
cd ios && fastlane patch
```

### 네이티브 변경이 있는 경우
```bash
# 새 릴리스 빌드 + 배포 (테스터 재설치 필요)
shorebird release android
./scripts/distribute.sh android

# 또는 Fastlane 사용
cd android && fastlane shorebird_release
```

---

## GitHub Actions (CI/CD)

GitHub 웹에서 수동으로 배포 트리거:
1. Repository → Actions → "Distribute to Testers"
2. "Run workflow" 클릭
3. 플랫폼 선택 → 실행

### 필요한 GitHub Secrets
| Secret | 설명 |
|--------|------|
| `FIREBASE_ANDROID_APP_ID` | `1:421762663548:android:8819363bb6b0f241ff35f9` |
| `FIREBASE_IOS_APP_ID` | `1:421762663548:ios:20d3e33da071d49bff35f9` |
| `FIREBASE_SERVICE_ACCOUNT` | Firebase 서비스 계정 JSON |
| `GOOGLE_SERVICES_JSON` | google-services.json을 base64 인코딩한 값 |
| `GOOGLE_SERVICE_INFO_PLIST` | GoogleService-Info.plist을 base64 인코딩한 값 |
| `ANDROID_KEYSTORE_BASE64` | keystore 파일을 base64 인코딩한 값 |
| `ANDROID_STORE_PASSWORD` | keystore 비밀번호 |
| `ANDROID_KEY_PASSWORD` | key 비밀번호 |
| `ANDROID_KEY_ALIAS` | key alias |
| `IOS_CERTIFICATE_BASE64` | iOS 배포 인증서 (.p12) base64 |
| `IOS_CERTIFICATE_PASSWORD` | 인증서 비밀번호 |
| `IOS_PROVISION_PROFILE_BASE64` | Ad Hoc 프로비저닝 프로필 base64 |
| `KEYCHAIN_PASSWORD` | 임시 키체인 비밀번호 (아무 값) |

---

## 파일 구조

```
scripts/
├── distribute.sh       # Firebase App Distribution 배포
├── patch.sh            # Shorebird OTA 패치
└── build_release.sh    # 릴리스 빌드 (기존)

android/fastlane/
├── Fastfile            # Android Fastlane 설정
└── Appfile             # Android 앱 정보

ios/fastlane/
├── Fastfile            # iOS Fastlane 설정
└── Appfile             # iOS 앱 정보

ios/
└── exportOptions-adhoc.plist  # iOS Ad Hoc 배포 설정

.github/workflows/
├── flutter_ci.yml      # CI (코드 분석)
└── distribute.yml      # 테스트 배포 워크플로우
```
