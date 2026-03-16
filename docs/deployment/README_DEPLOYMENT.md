# MathLab 배포 가이드

이 문서는 MathLab 앱을 빠르게 빌드하고 배포하는 방법을 설명합니다.

## 🚀 빠른 시작

### 1. 환경 설정 확인

```bash
# Flutter 버전 확인
flutter --version

# 의존성 설치
flutter pub get

# 코드 분석
flutter analyze
```

### 2. Android 릴리즈 빌드

#### 2.1. 키스토어 생성 (최초 1회만)

```bash
./scripts/create_keystore.sh
```

이 스크립트는 다음을 자동으로 수행합니다:
- Release 키스토어 생성
- `android/key.properties` 파일 생성
- 키 정보 백업 파일 생성
- `.gitignore`에 키스토어 관련 항목 추가

⚠️ **중요**: 생성된 키스토어와 비밀번호는 안전한 곳에 백업하세요!

#### 2.2. App Bundle 빌드 (Play Store 업로드용)

```bash
# 자동화 스크립트 사용
./scripts/build_release.sh

# 또는 직접 빌드
flutter build appbundle --release
```

생성 위치: `build/app/outputs/bundle/release/app-release.aab`

#### 2.3. APK 빌드 (직접 설치용)

```bash
flutter build apk --release
```

생성 위치: `build/app/outputs/flutter-apk/app-release.apk`

### 3. iOS 릴리즈 빌드

#### 3.1. iOS 빌드

```bash
# 자동화 스크립트 사용
./scripts/build_release.sh

# 또는 직접 빌드
flutter build ios --release
```

#### 3.2. Xcode에서 아카이브

```bash
# Xcode 워크스페이스 열기
open ios/Runner.xcworkspace
```

Xcode에서:
1. Product > Archive 선택
2. Organizer에서 생성된 아카이브 선택
3. "Distribute App" 클릭
4. App Store Connect로 업로드

## 📱 배포 전 체크리스트

### 필수 준비사항

- [ ] 앱 아이콘 (1024x1024)
- [ ] 스크린샷
  - iOS: iPhone 6.7" (최소 1장)
  - Android: 1080x1920 (최소 2장)
- [ ] Feature Graphic (Android, 1024x500)
- [ ] 개인정보 처리방침 URL
- [ ] 서비스 이용약관 URL

### 개발자 계정

- [ ] Apple Developer Program ($99/년)
- [ ] Google Play Console ($25 일회성)

### 법률 문서

- [ ] `docs/PRIVACY_POLICY.md` 검토 및 정보 업데이트
- [ ] `docs/TERMS_OF_SERVICE.md` 검토 및 정보 업데이트

## 📚 상세 가이드

더 자세한 내용은 다음 문서를 참조하세요:

- **[배포 가이드](docs/STORE_DEPLOYMENT_GUIDE.md)** - iOS/Android 배포 완전 가이드
- **[에셋 가이드](docs/STORE_ASSETS_GUIDE.md)** - 아이콘, 스크린샷 준비
- **[개인정보 처리방침](docs/PRIVACY_POLICY.md)** - 법률 문서
- **[서비스 이용약관](docs/TERMS_OF_SERVICE.md)** - 법률 문서

## 🛠️ 유틸리티 스크립트

### 키스토어 생성

```bash
./scripts/create_keystore.sh
```

대화형 프롬프트로 키스토어를 생성합니다.

### 릴리즈 빌드 자동화

```bash
./scripts/build_release.sh
```

플랫폼을 선택하여 자동으로 빌드합니다:
1. Android (App Bundle)
2. Android (APK)
3. iOS
4. 모두

### 앱 아이콘 플레이스홀더 생성

```bash
# Python 3 필요
pip3 install Pillow

# 아이콘 생성
./scripts/generate_icon_placeholder.py
```

## 📚 상세 문서

자세한 배포 가이드는 다음 문서를 참조하세요:

- **전체 배포 가이드**: [`docs/STORE_DEPLOYMENT_GUIDE.md`](docs/STORE_DEPLOYMENT_GUIDE.md)
  - iOS App Store 배포 상세 가이드
  - Android Play Store 배포 상세 가이드
  - 앱 설명 (한국어/영어)
  - ASO 키워드

- **스토어 에셋 가이드**: [`docs/STORE_ASSETS_GUIDE.md`](docs/STORE_ASSETS_GUIDE.md)
  - 앱 아이콘 사이즈 가이드
  - 스크린샷 요구사항
  - Feature Graphic 제작 가이드

- **개인정보 처리방침**: `docs/PRIVACY_POLICY.md`
- **서비스 이용약관**: `docs/TERMS_OF_SERVICE.md`

## 🛠️ 유틸리티 스크립트

### 키스토어 생성

```bash
./scripts/create_keystore.sh
```

Android 릴리즈 서명을 위한 키스토어를 대화형으로 생성합니다.

### 릴리즈 빌드 자동화

```bash
./scripts/build_release.sh
```

인터랙티브 메뉴에서 빌드할 플랫폼을 선택할 수 있습니다:
1. Android (App Bundle)
2. Android (APK)
3. iOS
4. 모두 (Android + iOS)

### 앱 아이콘 플레이스홀더 생성

```bash
# Python 3와 Pillow가 필요합니다
pip3 install Pillow

# 아이콘 생성
./scripts/generate_icon_placeholder.py
```

이 스크립트는 1024x1024 플레이스홀더 아이콘을 생성합니다.

## 📚 상세 문서

### 배포 가이드
- [스토어 배포 완전 가이드](docs/STORE_DEPLOYMENT_GUIDE.md)
- [스토어 에셋 준비 가이드](docs/STORE_ASSETS_GUIDE.md)

### 법률 문서
- [개인정보 처리방침](docs/PRIVACY_POLICY.md)
- [서비스 이용약관](docs/TERMS_OF_SERVICE.md)

## 🔧 유용한 스크립트

### 키스토어 생성
```bash
./scripts/create_keystore.sh
```

### 릴리즈 빌드 (대화형)
```bash
./scripts/build_release.sh
```

### 앱 아이콘 플레이스홀더 생성
```bash
python3 scripts/generate_icon_placeholder.py
```

## 📊 빌드 정보

빌드가 완료되면 `build_info/` 디렉토리에 빌드 정보가 저장됩니다:
- 빌드 날짜 및 시간
- 버전 정보
- 파일 크기
- Flutter 버전

## 🆘 문제 해결

### Android 빌드 실패

**문제**: `key.properties` 파일을 찾을 수 없습니다.
**해결**: `./scripts/create_keystore.sh`를 실행하여 키스토어를 생성하세요.

**문제**: 중복 리소스 파일 오류
**해결**: `build.gradle.kts`에 이미 자동 정리 태스크가 포함되어 있습니다.

### iOS 빌드 실패

**문제**: CocoaPods 오류
**해결**:
```bash
cd ios
pod deintegrate
pod install
cd ..
```

**문제**: 서명 오류
**해결**: Xcode에서 Signing & Capabilities 탭에서 팀과 프로비저닝 프로필을 설정하세요.

## 📚 추가 문서

- [완전한 배포 가이드](docs/STORE_DEPLOYMENT_GUIDE.md)
- [스토어 에셋 가이드](docs/STORE_ASSETS_GUIDE.md)
- [개인정보 처리방침](docs/PRIVACY_POLICY.md)
- [서비스 이용약관](docs/TERMS_OF_SERVICE.md)

## 🎯 다음 단계

1. **앱 아이콘 제작**: 전문 디자이너에게 의뢰하거나 온라인 도구 사용
2. **스크린샷 촬영**: 실제 기기에서 주요 화면 캡처
3. **스토어 등록**: Apple Developer와 Google Play Console에 앱 등록
4. **심사 제출**: 빌드 파일과 메타데이터 업로드

## 💡 팁

- 첫 배포 전에 TestFlight(iOS) 또는 내부 테스트(Android)로 베타 테스트 진행
- 버전 번호는 `pubspec.yaml`에서 관리
- 각 릴리즈마다 빌드 번호(+1, +2, ...)를 증가시키세요
- 키스토어는 안전한 곳에 백업 (클라우드 + 로컬)

---

**문의사항이 있으신가요?**
- docs/STORE_DEPLOYMENT_GUIDE.md의 FAQ 섹션을 확인하세요.
- 또는 프로젝트 이슈를 생성하세요.
