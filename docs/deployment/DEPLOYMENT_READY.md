# 🚀 MathLab 배포 준비 완료!

모든 코드 준비가 완료되었습니다. 이제 스토어에 배포할 수 있습니다!

## ✅ 완료된 작업

### 1. 문서화
- ✅ **STORE_DEPLOYMENT_GUIDE.md** - iOS/Android 배포 완전 가이드
- ✅ **STORE_ASSETS_GUIDE.md** - 스토어 에셋 준비 가이드
- ✅ **PRIVACY_POLICY.md** - 개인정보 처리방침 (GDPR/CCPA 준수)
- ✅ **TERMS_OF_SERVICE.md** - 서비스 이용약관
- ✅ **README_DEPLOYMENT.md** - 빠른 배포 가이드

### 2. 자동화 스크립트
- ✅ **create_keystore.sh** - Android 키스토어 자동 생성
- ✅ **build_release.sh** - 릴리즈 빌드 자동화 (iOS/Android)
- ✅ **generate_icon_placeholder.py** - 앱 아이콘 생성 도구

### 3. 빌드 설정
- ✅ **iOS Info.plist** - 권한 및 설정 완료
- ✅ **Android build.gradle.kts** - 서명 및 ProGuard 설정
- ✅ **AndroidManifest.xml** - 권한 설정
- ✅ **pubspec.yaml** - 버전 정보 및 앱 설명

### 4. 앱 아이콘
- ✅ **플레이스홀더 아이콘** 생성 (1024x1024)
- ✅ **iOS/Android 아이콘** 자동 생성 완료

## 🎯 다음 단계 (사용자가 직접 해야 할 작업)

### 1단계: 법률 문서 정보 업데이트 ⚠️

다음 파일들의 플레이스홀더를 실제 정보로 교체하세요:

**docs/PRIVACY_POLICY.md**
```
[책임자 이름]  → 실제 책임자 이름
[전화번호]     → 실제 전화번호
[대표자명]     → 실제 대표자명
```

**docs/TERMS_OF_SERVICE.md**
```
[대표자명]           → 실제 대표자명
[사업자등록번호]     → 실제 사업자등록번호
[주소]               → 실제 사업장 주소
```

### 2단계: 앱 아이콘 제작 (선택사항)

현재 플레이스홀더 아이콘이 적용되어 있습니다. 전문 디자이너에게 아이콘 제작을 의뢰하세요.

**추천 도구:**
- https://icon.kitchen/ (무료)
- https://appicon.co/ (무료)
- Fiverr, 크몽 (유료, 전문 디자이너)

**제작 후:**
```bash
# 아이콘 파일을 assets/images/app_icon.png로 교체
# 그 다음 실행:
flutter pub run flutter_launcher_icons
```

### 3단계: 스크린샷 촬영

**필수 스크린샷:**
- iOS: iPhone 6.7" (최소 1장)
- Android: 1080x1920 (최소 2장)
- Android Feature Graphic: 1024x500

**추천 화면:**
1. 온보딩/환영 화면
2. 메인 홈 화면
3. 문제 풀이 화면
4. 진행률/통계 화면
5. 게이미피케이션 (리그, 업적)

**촬영 방법:**
```bash
# 1. 앱 실행
flutter run

# 2. 실제 기기 또는 시뮬레이터에서 스크린샷 촬영
# iOS: Cmd + S (시뮬레이터)
# Android: 볼륨 다운 + 전원 버튼
```

### 4단계: 개발자 계정 등록

**Apple Developer Program**
- 비용: $99/년
- 등록: https://developer.apple.com/programs/

**Google Play Console**
- 비용: $25 (1회)
- 등록: https://play.google.com/console/signup

### 5단계: Android 릴리즈 빌드

```bash
# 1. 키스토어 생성 (최초 1회만)
./scripts/create_keystore.sh

# 2. App Bundle 빌드
./scripts/build_release.sh
# 또는
flutter build appbundle --release

# 3. 생성된 파일:
# build/app/outputs/bundle/release/app-release.aab
```

### 6단계: iOS 릴리즈 빌드

```bash
# 1. iOS 빌드
./scripts/build_release.sh
# 또는
flutter build ios --release

# 2. Xcode에서 아카이브
open ios/Runner.xcworkspace
# Product > Archive > Distribute App
```

### 7단계: 스토어 등록

**Google Play Console:**
1. 앱 만들기
2. App Bundle 업로드
3. 스토어 등록정보 작성
4. 콘텐츠 등급 설정
5. 가격 및 배포 설정
6. 심사 제출

**App Store Connect:**
1. 새로운 앱 추가
2. Xcode에서 아카이브 업로드
3. 앱 정보 입력
4. 스크린샷 업로드
5. 심사 제출

## 📋 배포 체크리스트

### 필수 사항
- [ ] 법률 문서 정보 업데이트 (개인정보 처리방침, 이용약관)
- [ ] 앱 아이콘 제작 (또는 플레이스홀더 사용)
- [ ] 스크린샷 촬영 (iOS 1장, Android 2장 최소)
- [ ] Feature Graphic 제작 (Android, 1024x500)
- [ ] Apple Developer 계정 등록 ($99)
- [ ] Google Play Console 계정 등록 ($25)

### Android 빌드
- [ ] 키스토어 생성 및 안전하게 백업
- [ ] App Bundle 빌드 완료
- [ ] 빌드 파일 확인 (app-release.aab)

### iOS 빌드
- [ ] Xcode 서명 설정
- [ ] Archive 생성
- [ ] App Store Connect 업로드

### 스토어 리스팅
- [ ] 앱 이름 및 설명 작성
- [ ] 스크린샷 업로드
- [ ] 콘텐츠 등급 설정
- [ ] 개인정보 처리방침 URL 설정
- [ ] 서비스 이용약관 URL 설정

## 🚀 빠른 명령어

### 전체 프로세스 (한 줄)
```bash
# Android
./scripts/create_keystore.sh && ./scripts/build_release.sh

# iOS
./scripts/build_release.sh
```

### 개별 명령어
```bash
# 키스토어 생성
./scripts/create_keystore.sh

# 릴리즈 빌드
./scripts/build_release.sh

# 앱 아이콘 재생성
flutter pub run flutter_launcher_icons

# 코드 분석
flutter analyze
```

## 📚 참고 문서

### 배포 가이드
- [빠른 배포 가이드](README_DEPLOYMENT.md) ⭐ 시작하기 좋음
- [완전한 배포 가이드](docs/STORE_DEPLOYMENT_GUIDE.md)
- [스토어 에셋 가이드](docs/STORE_ASSETS_GUIDE.md)

### 법률 문서
- [개인정보 처리방침](docs/PRIVACY_POLICY.md)
- [서비스 이용약관](docs/TERMS_OF_SERVICE.md)

### 스크립트
- [키스토어 생성](scripts/create_keystore.sh)
- [릴리즈 빌드](scripts/build_release.sh)
- [아이콘 생성](scripts/generate_icon_placeholder.py)

## 💡 유용한 팁

### 테스트 배포
실제 배포 전에 테스트해보세요:
- **iOS**: TestFlight로 베타 테스트
- **Android**: 내부 테스트 트랙 사용

### 버전 관리
```yaml
# pubspec.yaml
version: 1.0.0+1  # 버전명+빌드번호
```
- 버전명: 사용자에게 표시 (1.0.0)
- 빌드번호: 내부 식별용 (1, 2, 3, ...)
- 업데이트마다 빌드번호 증가 필수!

### 키스토어 백업
```bash
# 키스토어 파일 백업 (매우 중요!)
# 위치: ~/mathlab-keystore/mathlab-release.jks
# 비밀번호: ~/mathlab-keystore/KEYSTORE_INFO.txt

# 백업 권장:
# 1. 클라우드 (암호화된 저장소)
# 2. 외장 하드
# 3. 안전한 물리적 위치
```

### ASO (App Store Optimization)
- 키워드를 앱 제목과 설명에 자연스럽게 포함
- 첫 번째 스크린샷이 가장 중요 (전환율 30% 영향)
- 정기적으로 스크린샷과 설명 업데이트

## 🆘 문제 해결

### "key.properties를 찾을 수 없습니다"
```bash
./scripts/create_keystore.sh
```

### "서명 오류"
Xcode: Signing & Capabilities에서 팀과 프로비저닝 프로필 확인

### "CocoaPods 오류"
```bash
cd ios
pod deintegrate
pod install
cd ..
```

### 더 많은 문제 해결
- [배포 가이드 FAQ](docs/STORE_DEPLOYMENT_GUIDE.md#문제-해결)

## 🎉 축하합니다!

모든 코드 준비가 완료되었습니다!

**이제 할 일:**
1. 위의 체크리스트를 따라 진행하세요
2. 막히는 부분이 있다면 문서를 참조하세요
3. 첫 배포는 조금 시간이 걸릴 수 있습니다 (정상입니다!)

**예상 소요 시간:**
- Android: 2-3시간 (첫 배포)
- iOS: 3-4시간 (첫 배포)
- 심사: 1-3일 (Apple), 1-2일 (Google)

화이팅! 🚀

---

**최종 업데이트**: 2025년 1월 15일
