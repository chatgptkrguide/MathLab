# iOS 배포 가이드

MathLab 앱을 App Store에 배포하기 위한 단계별 가이드입니다.

## 📋 목차

1. [사전 준비](#1-사전-준비)
2. [Firebase 설정](#2-firebase-설정)
3. [Apple Developer 계정 설정](#3-apple-developer-계정-설정)
4. [Xcode 프로젝트 설정](#4-xcode-프로젝트-설정)
5. [App Store Connect 설정](#5-app-store-connect-설정)
6. [빌드 및 Archive](#6-빌드-및-archive)
7. [TestFlight 배포](#7-testflight-배포)
8. [App Store 제출](#8-app-store-제출)
9. [문제 해결](#9-문제-해결)

---

## 1. 사전 준비

### 필수 요구사항

- **macOS** (iOS 개발은 macOS에서만 가능)
- **Xcode** 15.0 이상 (App Store에서 무료 다운로드)
- **Apple Developer Program** 멤버십 ($99/년)
- **Flutter** 3.32.1 이상
- **CocoaPods** (의존성 관리)

### 개발 환경 확인

```bash
# Flutter 버전 확인
flutter --version

# Xcode 버전 확인
xcodebuild -version

# CocoaPods 설치 확인
pod --version

# CocoaPods 미설치 시
sudo gem install cocoapods
```

---

## 2. Firebase 설정

### GoogleService-Info.plist 추가

1. **Firebase Console 접속**
   - https://console.firebase.google.com
   - MathLab 프로젝트 선택

2. **iOS 앱 추가/설정**
   - 프로젝트 설정 > 일반 > iOS 앱
   - Bundle ID: `com.gomath.mathlab` (Xcode와 동일해야 함)

3. **GoogleService-Info.plist 다운로드**
   - Firebase Console에서 `GoogleService-Info.plist` 다운로드
   - 파일을 `ios/Runner/` 폴더에 추가

4. **Xcode에서 확인**
   ```bash
   open ios/Runner.xcworkspace
   ```
   - 프로젝트 네비게이터에서 `GoogleService-Info.plist` 파일이 `Runner` 폴더 아래에 있는지 확인
   - ⚠️ **중요**: 파일을 드래그&드롭으로 추가하고 "Copy items if needed" 체크

---

## 3. Apple Developer 계정 설정

### Developer Program 가입

1. **Apple Developer Program 가입**
   - https://developer.apple.com/programs/
   - $99/년 비용 발생

2. **Apple ID로 로그인**
   - Xcode > Preferences > Accounts
   - '+' 버튼 클릭하여 Apple ID 추가

### Certificates, Identifiers & Profiles

1. **App ID 생성**
   - https://developer.apple.com/account/resources/identifiers/list
   - '+' 버튼 클릭
   - Bundle ID: `com.gomath.mathlab` (Explicit App ID)
   - Capabilities:
     - Push Notifications ✅
     - Sign In with Apple ✅
     - Associated Domains ✅

2. **Development Certificate 생성**
   - Certificates > '+' 버튼
   - iOS App Development 선택
   - CSR (Certificate Signing Request) 업로드

3. **Distribution Certificate 생성**
   - Certificates > '+' 버튼
   - iOS Distribution (App Store) 선택
   - CSR 업로드

4. **Provisioning Profile 생성**

   **Development Profile:**
   - Profiles > '+' 버튼
   - iOS App Development 선택
   - App ID 선택: `com.gomath.mathlab`
   - Development Certificate 선택
   - 테스트 기기 선택
   - Profile 이름: `MathLab Development`

   **Distribution Profile:**
   - Profiles > '+' 버튼
   - App Store 선택
   - App ID 선택: `com.gomath.mathlab`
   - Distribution Certificate 선택
   - Profile 이름: `MathLab Distribution`

---

## 4. Xcode 프로젝트 설정

### 프로젝트 열기

```bash
# Runner.xcworkspace 파일을 Xcode로 열기
open ios/Runner.xcworkspace
```

⚠️ **중요**: `.xcodeproj`가 아닌 `.xcworkspace` 파일을 열어야 합니다!

### Signing & Capabilities 설정

1. **프로젝트 네비게이터에서 Runner 선택**

2. **General 탭**
   - Display Name: `MathLab`
   - Bundle Identifier: `com.gomath.mathlab`
   - Version: `1.0.0`
   - Build: `1`
   - Deployment Target: `13.0`

3. **Signing & Capabilities 탭**

   **Debug 설정:**
   - Automatically manage signing ✅
   - Team: (본인의 개발팀 선택)
   - Provisioning Profile: Automatic

   **Release 설정:**
   - Automatically manage signing ✅
   - Team: (본인의 개발팀 선택)
   - Provisioning Profile: Automatic

   ⚠️ 수동 설정이 필요한 경우 위에서 생성한 Provisioning Profile 선택

4. **Capabilities 확인**
   - Push Notifications ✅
   - Sign in with Apple ✅
   - Background Modes ✅
     - Remote notifications ✅

### Info.plist 확인

`ios/Runner/Info.plist`에 다음 항목들이 있는지 확인:

```xml
<!-- 카메라 권한 -->
<key>NSCameraUsageDescription</key>
<string>프로필 사진을 촬영하기 위해 카메라 접근이 필요합니다.</string>

<!-- 사진 라이브러리 권한 -->
<key>NSPhotoLibraryUsageDescription</key>
<string>프로필 사진을 선택하기 위해 사진 라이브러리 접근이 필요합니다.</string>

<!-- Google Sign In -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.$(REVERSED_CLIENT_ID)</string>
        </array>
    </dict>
</array>

<!-- Kakao Sign In -->
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>kakaokompassauth</string>
    <string>kakaolink</string>
    <string>kakaotalk</string>
</array>
```

### 소셜 로그인 설정

**Google Sign In:**
1. Firebase Console > Authentication > Sign-in method > Google
2. iOS 클라이언트 ID 확인
3. `GoogleService-Info.plist`의 `REVERSED_CLIENT_ID` 값 확인
4. Xcode > Runner > Info > URL Types에 추가

**Kakao Sign In:**
1. Kakao Developers Console에서 iOS 앱 등록
2. 네이티브 앱 키 발급
3. 플랫폼 > iOS 설정에 Bundle ID 추가
4. `Info.plist`에 URL Scheme 추가

**Apple Sign In:**
1. Signing & Capabilities > '+' Capability
2. "Sign in with Apple" 추가
3. Apple Developer에서 App ID Capabilities 활성화

---

## 5. App Store Connect 설정

### 앱 등록

1. **App Store Connect 접속**
   - https://appstoreconnect.apple.com
   - Apple ID로 로그인

2. **새 앱 추가**
   - 'My Apps' > '+' 버튼 > 'New App'
   - Platform: iOS
   - Name: `MathLab`
   - Primary Language: Korean
   - Bundle ID: `com.gomath.mathlab`
   - SKU: `mathlab-ios-001` (고유한 값)

### 앱 정보 입력

**1.0 Prepare for Submission 탭:**

1. **앱 정보**
   - 이름: MathLab
   - 부제목: 듀오링고 스타일 수학 학습 앱
   - 카테고리:
     - Primary: Education
     - Secondary: Games (게임 요소가 있는 경우)

2. **스크린샷 준비**

   필수 디바이스 스크린샷:
   - iPhone 6.7" Display (iPhone 15 Pro Max)
   - iPhone 6.5" Display (iPhone 14 Plus)

   권장 스크린샷 수: 3-8장
   - 로그인 화면
   - 홈 화면
   - 학습 화면
   - 문제 풀이 화면
   - 프로필/통계 화면

3. **앱 설명**
   ```
   듀오링고처럼 즐겁게! 매일 꾸준히!
   MathLab과 함께 수학 실력을 키워보세요!

   🎮 게이미피케이션
   - 경험치와 레벨 시스템
   - 연속 학습 스트릭
   - 업적 뱃지 수집
   - 주간 리그 경쟁

   📚 체계적인 커리큘럼
   - 기초 산술부터 미적분까지
   - 단계별 학습 경로
   - 개인 맞춤형 난이도

   ✨ 학습 강화 기능
   - 힌트 시스템
   - 오답 노트
   - 일일 챌린지
   ```

4. **키워드**
   ```
   수학, 학습, 교육, 게임, 듀오링고, 문제풀이,
   산수, 대수, 기하, 통계, 미적분
   ```

5. **지원 URL**
   - 웹사이트: https://mathlab.app (실제 URL로 변경)
   - 지원 이메일: support@mathlab.app

6. **개인정보 처리방침**
   - Privacy Policy URL 필수
   - GDPR, COPPA 준수 사항 명시

### App Privacy

**수집하는 데이터:**
- 이름, 이메일 (계정 생성)
- 사용자 ID (Firebase)
- 학습 진행도, 통계
- 기기 정보 (Analytics)

**데이터 사용 목적:**
- 앱 기능 제공
- Analytics
- 제품 개인화

---

## 6. 빌드 및 Archive

### 빌드 스크립트 사용

```bash
# 프로젝트 루트에서 실행
./scripts/build_ios.sh
```

스크립트가 자동으로:
1. Clean
2. Dependencies 설치
3. CocoaPods 설치
4. 테스트 실행
5. 정적 분석
6. Release 빌드

### Xcode에서 Archive

1. **Xcode 열기**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Scheme 선택**
   - Product > Scheme > Runner
   - Generic iOS Device 선택

3. **Archive 생성**
   - Product > Archive
   - Archive 완료까지 대기 (5-10분)

4. **Organizer 창**
   - Automatically opens after archive
   - 또는 Window > Organizer

### Archive 검증

1. **Validate App**
   - Archive 선택
   - 'Validate App' 버튼
   - App Store Connect API Key 선택 (또는 Apple ID)
   - 검증 완료까지 대기

2. **일반적인 검증 이슈:**
   - Missing compliance: 암호화 사용 여부 선택
   - Invalid Bundle ID: Bundle ID 확인
   - Provisioning Profile: Signing 설정 확인

---

## 7. TestFlight 배포

### Archive 업로드

1. **Distribute App 선택**
   - Archive > Distribute App
   - App Store Connect 선택
   - Upload 선택

2. **Distribution Options**
   - Automatically manage signing ✅
   - Upload symbols for crash reporting ✅
   - Upload 시작 (10-20분 소요)

3. **Processing**
   - App Store Connect에서 'Processing' 상태 확인
   - 보통 5-30분 소요

### TestFlight 설정

1. **App Store Connect > TestFlight 탭**

2. **Internal Testing**
   - Testers 추가 (최대 100명)
   - 이메일 초대
   - 즉시 테스트 가능 (심사 불필요)

3. **External Testing** (선택사항)
   - Beta App Review 필요
   - 최대 10,000명 테스터
   - Review 정보 제공:
     - 로그인 테스트 계정
     - 테스트 방법 설명

---

## 8. App Store 제출

### 제출 준비

1. **최종 확인**
   - [ ] 모든 스크린샷 업로드
   - [ ] 앱 설명 및 키워드 입력
   - [ ] Privacy Policy URL 등록
   - [ ] 지원 URL 등록
   - [ ] 가격 및 배포 지역 선택
   - [ ] 연령 등급 설정

2. **Build 선택**
   - 1.0 Prepare for Submission
   - Build 섹션에서 TestFlight 빌드 선택

3. **Content Rights**
   - 제3자 콘텐츠 사용 여부 체크
   - 광고 ID(IDFA) 사용 여부

### 제출

1. **Submit for Review**
   - 모든 정보 확인
   - 'Submit for Review' 버튼

2. **Review 진행 상태**
   - Waiting for Review (1-3일)
   - In Review (1-2일)
   - Pending Developer Release (승인됨)
   - Ready for Sale (출시됨)

3. **거부 시 대응**
   - 거부 사유 확인
   - 수정 후 재제출
   - 또는 Resolution Center에서 소통

---

## 9. 문제 해결

### 일반적인 문제

**1. CocoaPods 오류**
```bash
# Pods 완전 제거 후 재설치
cd ios
rm -rf Pods Podfile.lock
pod deintegrate
pod install
cd ..
```

**2. Signing 오류**
```bash
# Derived Data 삭제
rm -rf ~/Library/Developer/Xcode/DerivedData
```

**3. Archive 실패**
- Xcode > Preferences > Accounts에서 Apple ID 로그아웃 후 재로그인
- Provisioning Profile 다시 다운로드
- Certificates 재생성

**4. GoogleService-Info.plist 누락**
```bash
# 파일 위치 확인
ls -la ios/Runner/GoogleService-Info.plist

# 없으면 Firebase Console에서 다운로드
```

**5. Upload 오류**
```bash
# Xcode 버전 확인 및 업데이트
xcode-select --install
```

### 유용한 명령어

```bash
# iOS 빌드만 (Archive 없이)
flutter build ios --release

# 특정 기기로 빌드 테스트
flutter run -d <device-id> --release

# Xcode 로그 확인
cat ~/Library/Logs/CoreSimulator/*/system.log

# Firebase Debug 모드
flutter run --dart-define=FIREBASE_DEBUG=true
```

### 도움말 링크

- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Flutter iOS Deployment](https://docs.flutter.dev/deployment/ios)
- [Firebase iOS Setup](https://firebase.google.com/docs/ios/setup)

---

## 체크리스트

### 배포 전 최종 점검

- [ ] GoogleService-Info.plist 추가됨
- [ ] Bundle ID 일치: Xcode, Firebase, App Store Connect
- [ ] Signing & Capabilities 설정 완료
- [ ] Info.plist 권한 설명 모두 추가
- [ ] 소셜 로그인 URL Schemes 설정
- [ ] 모든 테스트 통과
- [ ] Flutter analyze 0 issues
- [ ] 실제 기기에서 테스트 완료
- [ ] 스크린샷 준비 (최소 3장)
- [ ] 앱 설명 작성
- [ ] Privacy Policy 준비
- [ ] 지원 이메일 설정
- [ ] 가격 및 배포 지역 선택
- [ ] 연령 등급 설정

---

**배포 성공을 기원합니다! 🎉**
