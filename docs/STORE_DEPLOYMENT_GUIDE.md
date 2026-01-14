# 📱 앱스토어 & 플레이스토어 배포 가이드

## 목차
1. [공통 준비사항](#공통-준비사항)
2. [iOS 앱스토어 배포](#ios-앱스토어-배포)
3. [Android 플레이스토어 배포](#android-플레이스토어-배포)
4. [스토어 리스팅 자료](#스토어-리스팅-자료)

---

## 공통 준비사항

### 1. 앱 정보
- **앱 이름**: MathLab (고매스)
- **현재 버전**: 1.0.0 (Build 1)
- **카테고리**: 교육 (Education)
- **대상 연령**: 4+
- **가격**: 무료 (인앱 결제 포함)

### 2. 필수 문서
- [x] 개인정보 처리방침 (Privacy Policy)
- [x] 서비스 이용약관 (Terms of Service)
- [ ] 앱 설명 (한국어/영어)
- [ ] 스크린샷 (다양한 기기 크기)
- [ ] 앱 아이콘 (다양한 크기)

### 3. 개발자 계정
- [ ] Apple Developer Account ($99/year)
- [ ] Google Play Console Account ($25 one-time)

---

## iOS 앱스토어 배포

### Step 1: Xcode 프로젝트 설정

#### 1.1 Bundle Identifier 설정
```bash
# ios/Runner.xcodeproj를 Xcode에서 열기
open ios/Runner.xcworkspace
```

**Xcode에서 설정:**
1. Runner → General → Identity
2. Bundle Identifier: `com.yourcompany.mathlab`
3. Version: `1.0.0`
4. Build: `1`

#### 1.2 Signing & Capabilities
1. Signing → Automatically manage signing 체크
2. Team 선택 (Apple Developer Account 필요)
3. Provisioning Profile 자동 생성 확인

#### 1.3 App Icon 설정
```bash
# 아이콘 파일 위치
ios/Runner/Assets.xcassets/AppIcon.appiconset/
```

**필요한 아이콘 크기:**
- 20x20 (@2x, @3x)
- 29x29 (@2x, @3x)
- 40x40 (@2x, @3x)
- 60x60 (@2x, @3x)
- 76x76 (@1x, @2x)
- 83.5x83.5 (@2x)
- 1024x1024 (App Store)

### Step 2: 빌드 설정 확인

#### 2.1 Info.plist 필수 권한 설정
```xml
<!-- ios/Runner/Info.plist -->
<key>NSCameraUsageDescription</key>
<string>문제 사진을 찍기 위해 카메라 접근이 필요합니다.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>프로필 사진을 설정하기 위해 사진 라이브러리 접근이 필요합니다.</string>

<key>NSUserTrackingUsageDescription</key>
<string>맞춤형 학습 경험 제공을 위해 사용됩니다.</string>
```

#### 2.2 최소 iOS 버전 확인
```ruby
# ios/Podfile
platform :ios, '12.0'
```

### Step 3: 빌드 및 업로드

#### 3.1 Release 빌드
```bash
# 프로젝트 루트에서
flutter build ios --release

# 또는 Xcode에서 직접 빌드
# Product → Archive
```

#### 3.2 App Store Connect에 업로드
```bash
# Xcode에서 Archive 후
# Window → Organizer → Distribute App → App Store Connect
```

### Step 4: App Store Connect 설정

#### 4.1 앱 정보 입력
- **앱 이름**: MathLab
- **부제**: 재미있는 수학 학습 앱
- **카테고리**: 교육
- **가격**: 무료
- **인앱 구매**: 설정 (프리미엄 구독)

#### 4.2 앱 설명 (한국어)
```
🎓 MathLab - 게임처럼 재미있는 수학 학습!

듀오링고 스타일의 게이미피케이션으로 매일 수학을 배우세요!

주요 기능:
✨ 게임처럼 재미있는 학습 경험
📊 레벨 시스템과 XP 획득
🔥 연속 학습 스트릭 (Streak)
🏆 리그 시스템과 주간 경쟁
👥 친구와 함께 학습
💎 업적 시스템
🎯 일일 챌린지

학습 내용:
• 기초 산술 (사칙연산, 분수, 소수)
• 대수 (방정식, 부등식, 함수)
• 기하 (도형, 각도, 면적, 부피)
• 통계 (평균, 확률, 그래프)

특징:
• 매일 10분, 꾸준한 학습
• AI 기반 난이도 조절
• 오답 노트 자동 생성
• 단계별 힌트 시스템
• 개념 설명 카드

지금 시작하세요! 🚀
```

#### 4.3 앱 설명 (영어)
```
🎓 MathLab - Fun Math Learning!

Learn math daily with Duolingo-style gamification!

Key Features:
✨ Game-like learning experience
📊 Level system and XP rewards
🔥 Daily streak tracking
🏆 Weekly league competitions
👥 Learn with friends
💎 Achievement system
🎯 Daily challenges

Curriculum:
• Basic Arithmetic (Addition, Fractions, Decimals)
• Algebra (Equations, Inequalities, Functions)
• Geometry (Shapes, Angles, Area, Volume)
• Statistics (Averages, Probability, Graphs)

Features:
• 10 minutes daily
• AI-powered difficulty adjustment
• Automatic error tracking
• Step-by-step hints
• Concept explanation cards

Start now! 🚀
```

#### 4.4 스크린샷 요구사항

**iPhone (필수):**
- 6.7" (iPhone 15 Pro Max): 1290 x 2796 px
- 6.5" (iPhone 14 Plus): 1242 x 2688 px
- 5.5" (iPhone 8 Plus): 1242 x 2208 px

**iPad (선택):**
- 12.9" (iPad Pro): 2048 x 2732 px

**개수**: 각 크기당 최소 3개, 최대 10개

#### 4.5 앱 미리보기 비디오 (선택)
- 길이: 15-30초
- 형식: .mov, .m4v, .mp4
- 해상도: 스크린샷과 동일

### Step 5: 심사 제출

#### 5.1 심사 정보
```
연령 등급: 4+
콘텐츠 권한: 없음
광고 ID: 사용 안 함 (또는 Firebase Analytics 사용 시 명시)
```

#### 5.2 심사 노트
```
테스트 계정:
- Email: test@mathlab.com
- Password: TestPass123!

주요 기능:
1. 회원가입/로그인
2. 레벨 테스트
3. 문제 풀이 (객관식, 드래그앤드롭)
4. 친구 추가
5. 리더보드 확인

Firebase 사용:
- Authentication
- Firestore Database
- Analytics
```

---

## Android 플레이스토어 배포

### Step 1: 키스토어 생성

#### 1.1 키스토어 파일 생성
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# 키스토어 파일을 android/app/ 폴더로 복사
cp ~/upload-keystore.jks android/app/
```

#### 1.2 key.properties 파일 생성
```properties
# android/key.properties
storePassword=<키스토어 비밀번호>
keyPassword=<키 비밀번호>
keyAlias=upload
storeFile=upload-keystore.jks
```

**⚠️ 중요: key.properties 파일은 .gitignore에 추가!**

### Step 2: build.gradle 설정

#### 2.1 android/app/build.gradle 수정
```gradle
// 파일 상단에 추가
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...

    defaultConfig {
        applicationId "com.yourcompany.mathlab"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
        }
    }
}
```

### Step 3: AndroidManifest.xml 설정

#### 3.1 필수 권한 확인
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>

<!-- Firebase Cloud Messaging -->
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE"/>
```

#### 3.2 앱 아이콘 확인
```bash
# 아이콘 파일 위치
android/app/src/main/res/
  mipmap-hdpi/ic_launcher.png (72x72)
  mipmap-mdpi/ic_launcher.png (48x48)
  mipmap-xhdpi/ic_launcher.png (96x96)
  mipmap-xxhdpi/ic_launcher.png (144x144)
  mipmap-xxxhdpi/ic_launcher.png (192x192)
```

### Step 4: 빌드 및 생성

#### 4.1 App Bundle 생성 (권장)
```bash
flutter build appbundle --release

# 출력: build/app/outputs/bundle/release/app-release.aab
```

#### 4.2 APK 생성 (선택)
```bash
flutter build apk --release

# 출력: build/app/outputs/flutter-apk/app-release.apk
```

### Step 5: Google Play Console 설정

#### 5.1 앱 정보
- **앱 이름**: MathLab
- **짧은 설명**: 게임처럼 재미있는 수학 학습
- **전체 설명**: (iOS와 동일)
- **카테고리**: 교육
- **태그**: 수학, 교육, 게임화, 학습

#### 5.2 스크린샷 요구사항

**휴대전화 (필수):**
- 최소 2개, 최대 8개
- JPG 또는 PNG
- 크기: 16:9 또는 9:16 비율
- 최소: 320px
- 최대: 3840px

**태블릿 (선택):**
- 7인치, 10인치용 스크린샷

#### 5.3 그래픽 자산

**아이콘:**
- 512 x 512 px (32비트 PNG)

**기능 그래픽:**
- 1024 x 500 px (JPG 또는 PNG)

### Step 6: 콘텐츠 등급

#### 6.1 IARC 설문 작성
```
앱이 다음을 포함하나요?
- 폭력: 없음
- 성적 콘텐츠: 없음
- 욕설: 없음
- 약물: 없음
- 도박: 없음

결과: 3세 이상 (Everyone)
```

### Step 7: 가격 및 배포

#### 7.1 가격 설정
```
가격: 무료
인앱 구매: 있음
- 프리미엄 월간 구독: ₩9,900
- 프리미엄 연간 구독: ₩79,000
```

#### 7.2 배포 국가
```
주요 배포 국가:
- 대한민국
- 미국
- 일본
- 영어권 국가
```

---

## 스토어 리스팅 자료

### 1. 앱 스크린샷 가이드

#### 촬영할 화면:
1. **온보딩 화면** - 앱 소개
2. **홈 화면** - 학습 시작, XP, 스트릭
3. **문제 풀이 화면** - 실제 문제 예시
4. **리더보드** - 친구와 경쟁
5. **프로필** - 레벨, 업적
6. **일일 챌린지** - 보상 시스템

#### 스크린샷 생성:
```bash
# iOS 시뮬레이터에서
flutter run --release
# 화면 캡처: Cmd + S

# Android 에뮬레이터에서
flutter run --release
# 화면 캡처: 에뮬레이터 툴바의 카메라 아이콘
```

### 2. 프로모션 자료

#### 기능 그래픽 (Feature Graphic)
- 크기: 1024 x 500 px
- 메인 메시지: "게임처럼 재미있는 수학 학습"
- 앱 아이콘 + 주요 기능 아이콘

#### 프로모션 비디오 (선택)
- YouTube 업로드 후 링크 추가
- 30초 이내
- 주요 기능 시연

### 3. 검색 최적화 (ASO)

#### iOS App Store 키워드
```
수학, 학습, 교육, 게임, 문제, 연습, 공부, 초등, 중등, 수학공부,
수학게임, 듀오링고, 게이미피케이션, 매일수학, 수학앱
```

#### Google Play Store 키워드
```
수학 학습 앱, 수학 게임, 교육 게임, 수학 공부, 초등 수학,
중등 수학, 수학 연습, 게이미피케이션, 학습 앱, 교육 앱
```

---

## 체크리스트

### 배포 전 최종 확인

#### 공통
- [ ] 앱 이름, 설명, 키워드 준비
- [ ] 스크린샷 5개 이상 준비
- [ ] 앱 아이콘 모든 크기 준비
- [ ] 개인정보 처리방침 URL 준비
- [ ] 서비스 이용약관 URL 준비
- [ ] 테스트 계정 준비

#### iOS
- [ ] Apple Developer Account 등록
- [ ] Bundle Identifier 설정
- [ ] Provisioning Profile 생성
- [ ] Info.plist 권한 설명 작성
- [ ] Release 빌드 테스트
- [ ] App Store Connect 앱 생성
- [ ] TestFlight 베타 테스트 (선택)

#### Android
- [ ] Google Play Console 등록
- [ ] 키스토어 파일 생성 및 안전 보관
- [ ] key.properties 작성 (.gitignore 확인)
- [ ] applicationId 설정
- [ ] Release 빌드 테스트
- [ ] App Bundle 생성
- [ ] IARC 콘텐츠 등급 완료

---

## 유용한 명령어

### 버전 업데이트
```bash
# pubspec.yaml 버전 수정 후
flutter clean
flutter pub get

# iOS 빌드
flutter build ios --release --no-codesign

# Android 빌드
flutter build appbundle --release
```

### 빌드 크기 분석
```bash
# iOS
flutter build ios --release --analyze-size

# Android
flutter build appbundle --release --target-platform android-arm,android-arm64
```

### 난독화 (Obfuscation)
```bash
flutter build appbundle --obfuscate --split-debug-info=build/app/outputs/symbols
```

---

## 참고 자료

- [Flutter iOS 배포 가이드](https://docs.flutter.dev/deployment/ios)
- [Flutter Android 배포 가이드](https://docs.flutter.dev/deployment/android)
- [App Store 심사 가이드라인](https://developer.apple.com/app-store/review/guidelines/)
- [Google Play 정책 센터](https://play.google.com/about/developer-content-policy/)
- [ASO (App Store Optimization) 가이드](https://developer.apple.com/app-store/product-page/)

---

## 문의

배포 과정에서 문제가 발생하면:
1. Flutter 공식 문서 확인
2. GitHub Issues 검색
3. Stack Overflow 검색
4. 개발자 커뮤니티 질문

**Good Luck! 🚀**
