# ✅ MathLab 배포 완료 체크리스트

## 🎉 모든 준비 작업 완료!

배포에 필요한 모든 가이드와 문서가 준비되었습니다. 이제 아래 체크리스트를 따라 실제 배포를 진행하세요.

---

## 📁 생성된 문서 목록

### 법률 문서
- ✅ `docs/PRIVACY_POLICY.md` - 개인정보 처리방침 (실제 정보로 업데이트 완료)
- ✅ `docs/TERMS_OF_SERVICE.md` - 서비스 이용약관 (실제 정보로 업데이트 완료)

### 설정 가이드
- ✅ `docs/APP_ICON_GUIDE.md` - 앱 아이콘 디자인 및 제작 가이드
- ✅ `docs/SCREENSHOT_GUIDE.md` - 스크린샷 촬영 완전 가이드
- ✅ `docs/FIREBASE_SETUP_GUIDE.md` - Firebase 설정 단계별 가이드
- ✅ `docs/ENV_SETUP_GUIDE.md` - 환경 변수 설정 가이드
- ✅ `docs/DEVELOPER_ACCOUNT_GUIDE.md` - 개발자 계정 등록 가이드

---

## 🚀 배포 전 필수 작업

### 1️⃣ 법률 문서 확인
- [x] 개인정보 처리방침 플레이스홀더 업데이트 완료
- [x] 서비스 이용약관 플레이스홀더 업데이트 완료
- [ ] 법률 전문가 검토 (권장)
- [ ] 법률 문서 호스팅 URL 준비

**참고**: `docs/PRIVACY_POLICY.md`, `docs/TERMS_OF_SERVICE.md`

---

### 2️⃣ 앱 아이콘 제작
- [ ] 전문 디자이너에게 아이콘 의뢰
- [ ] 1024x1024 PNG 파일 준비
- [ ] `assets/images/app_icon.png` 교체
- [ ] `flutter pub run flutter_launcher_icons` 실행
- [ ] iOS/Android에서 아이콘 확인

**참고**: `docs/APP_ICON_GUIDE.md`

**추천 플랫폼**:
- Fiverr: https://fiverr.com ($25-$100)
- 99designs: https://99designs.com ($299-$799)
- Upwork: https://upwork.com ($30-$100/시간)

---

### 3️⃣ 스크린샷 촬영
- [ ] iOS 시뮬레이터 설정 (iPhone 15 Pro Max)
- [ ] Android 에뮬레이터 설정 (Pixel 6 Pro)
- [ ] 5개 화면 스크린샷 촬영:
  - [ ] 홈 화면
  - [ ] 문제 풀이 화면
  - [ ] 성과/리워드 화면
  - [ ] 학습 통계 화면
  - [ ] 친구/리더보드 화면
- [ ] iOS: 1290 x 2796 크기 확인
- [ ] Android: 1080 x 1920 이상 확인
- [ ] Feature Graphic 제작 (Android, 1024 x 500)

**참고**: `docs/SCREENSHOT_GUIDE.md`

---

### 4️⃣ Firebase 설정
- [ ] Firebase 프로젝트 생성
- [ ] Android 앱 등록
- [ ] `google-services.json` 다운로드 → `android/app/`
- [ ] iOS 앱 등록
- [ ] `GoogleService-Info.plist` 다운로드 → `ios/Runner/`
- [ ] Xcode에서 plist 파일 추가 확인
- [ ] Authentication 활성화 (이메일, Google, Apple)
- [ ] Firestore Database 생성
- [ ] Storage 생성
- [ ] Analytics 확인
- [ ] Crashlytics 확인
- [ ] Cloud Messaging 설정
- [ ] 보안 규칙 배포: `firebase deploy --only firestore:rules,storage`

**참고**: `docs/FIREBASE_SETUP_GUIDE.md`

---

### 5️⃣ 환경 변수 설정
- [ ] `.env` 파일 확인 (이미 존재함)
- [ ] Firebase 설정값 입력
- [ ] Kakao SDK 키 입력
- [ ] Google Sign-In 클라이언트 ID 입력
- [ ] OpenAI API 키 입력 (선택사항)
- [ ] 환경 변수 검증: `./scripts/verify_env.sh`

**참고**: `docs/ENV_SETUP_GUIDE.md`

---

### 6️⃣ 개발자 계정 등록
- [ ] Apple Developer Program 등록 ($99/년)
  - [ ] Apple ID 생성 및 2단계 인증
  - [ ] 개인/조직 선택
  - [ ] 결제 완료
  - [ ] 심사 통과 대기 (1-3일)
  - [ ] App Store Connect 접속 확인
  - [ ] 계약 동의 (Agreements, Tax, and Banking)

- [ ] Google Play Console 등록 ($25 일회성)
  - [ ] Google 계정 준비
  - [ ] 개인/조직 선택
  - [ ] 결제 완료
  - [ ] 계정 활성화 확인 (즉시)
  - [ ] 결제 프로필 설정

**참고**: `docs/DEVELOPER_ACCOUNT_GUIDE.md`

---

## 🏗️ 빌드 및 배포

### Android (Google Play Store)

#### 7️⃣ 키스토어 생성 (최초 1회)
```bash
./scripts/create_keystore.sh
```

#### 8️⃣ 릴리즈 빌드
```bash
./scripts/build_release.sh

# 또는 직접
flutter build appbundle --release
```

#### 9️⃣ Play Console 업로드
```
1. https://play.google.com/console 로그인
2. "Create app" 클릭
3. 앱 정보 입력
4. Release > Production
5. App bundle 업로드
6. 스크린샷 및 설명 추가
7. 콘텐츠 등급 설정
8. 가격 설정 (무료)
9. "Review release" → "Start rollout to Production"
```

**심사 기간**: 1-3일

---

### iOS (App Store)

#### 🔟 릴리즈 빌드
```bash
./scripts/build_release.sh

# 또는 직접
flutter build ios --release
```

#### 1️⃣1️⃣ Xcode에서 아카이브
```bash
open ios/Runner.xcworkspace

# Xcode에서:
1. Product > Scheme > Runner 선택
2. Product > Destination > Any iOS Device
3. Product > Archive
4. Archives > Distribute App
5. App Store Connect > Upload
```

#### 1️⃣2️⃣ App Store Connect 설정
```
1. https://appstoreconnect.apple.com 로그인
2. My Apps > "+" > New App
3. 앱 정보 입력
4. 스크린샷 업로드
5. 앱 설명 작성
6. 가격 설정 (무료)
7. 빌드 선택
8. "Submit for Review"
```

**심사 기간**: 1-3일

---

## 📊 배포 후 모니터링

### 필수 모니터링
- [ ] Firebase Crashlytics - 크래시 리포트 확인
- [ ] Firebase Analytics - 사용자 행동 분석
- [ ] App Store Connect - 다운로드 및 리뷰 확인
- [ ] Google Play Console - 다운로드 및 리뷰 확인

### 사용자 피드백 수집
- [ ] 인앱 피드백 시스템 활성화
- [ ] 고객 지원 이메일 모니터링
- [ ] 앱 스토어 리뷰 정기 확인

---

## 🎯 예상 타임라인

### 준비 단계 (1-2주)
```
Day 1-2:   법률 문서 검토
Day 3-4:   앱 아이콘 디자인 의뢰
Day 5:     스크린샷 촬영
Day 6:     Firebase 설정
Day 7:     환경 변수 설정
Day 8-10:  개발자 계정 등록 및 승인 대기
```

### 빌드 & 배포 (1주)
```
Day 11:    Android 빌드 및 업로드
Day 12:    iOS 빌드 및 업로드
Day 13-15: 심사 대기
Day 16:    배포 완료! 🎉
```

---

## 💰 예상 비용

### 필수 비용
- Apple Developer: $99/년
- Google Play: $25 (일회성)
- **합계**: $124

### 선택 비용
- 앱 아이콘 디자인: $25-$100
- 스크린샷 전문 제작: $50-$200
- 법률 문서 검토: $100-$500

**총 예상 비용**: $300-$1,000

---

## 📚 참고 문서

### 빠른 시작
- [배포 준비 가이드](DEPLOYMENT_READY.md)
- [빠른 배포 가이드](README_DEPLOYMENT.md)

### 상세 가이드
- [완전한 스토어 배포 가이드](docs/STORE_DEPLOYMENT_GUIDE.md)
- [스토어 에셋 가이드](docs/STORE_ASSETS_GUIDE.md)

### 개발 문서
- [기여 가이드](CONTRIBUTING.md)
- [변경 이력](CHANGELOG.md)

---

## 🆘 도움이 필요하신가요?

### 커뮤니티
- Flutter Community: https://flutter.dev/community
- Reddit r/FlutterDev: https://reddit.com/r/FlutterDev
- Stack Overflow: https://stackoverflow.com/questions/tagged/flutter

### 공식 지원
- Apple Developer: https://developer.apple.com/support/
- Google Play: https://support.google.com/googleplay/android-developer
- Firebase: https://firebase.google.com/support

---

## ✨ 축하합니다!

모든 가이드와 문서가 준비되었습니다. 위 체크리스트를 차근차근 따라가시면 성공적으로 배포하실 수 있습니다!

**화이팅! 🚀**

---

**최종 업데이트**: 2025년 1월 18일
**문서 버전**: 1.0
