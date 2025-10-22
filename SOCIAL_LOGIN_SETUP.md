# 소셜 로그인 설정 가이드

MathLab 앱에서 Google, Kakao, Apple 소셜 로그인을 설정하는 방법을 안내합니다.

## 📋 목차

1. [Google 로그인 설정](#google-로그인-설정)
2. [Kakao 로그인 설정](#kakao-로그인-설정)
3. [Apple 로그인 설정](#apple-로그인-설정)
4. [테스트 방법](#테스트-방법)

---

## Google 로그인 설정

### 1. Firebase 프로젝트 생성

1. [Firebase Console](https://console.firebase.google.com/)에 접속
2. "프로젝트 추가" 클릭
3. 프로젝트 이름: `MathLab` 입력
4. Google Analytics 설정 (선택사항)
5. 프로젝트 생성 완료

### 2. Android 앱 등록

1. Firebase 프로젝트 개요 > Android 아이콘 클릭
2. Android 패키지 이름 입력: `com.mathlab.app` (또는 실제 패키지명)
3. 앱 닉네임: `MathLab Android` (선택사항)
4. 디버그 서명 인증서 SHA-1 추가:

```bash
# macOS/Linux
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Windows
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

5. `google-services.json` 다운로드
6. 다운로드한 파일을 `android/app/` 폴더에 복사

### 3. iOS 앱 등록

1. Firebase 프로젝트 개요 > iOS 아이콘 클릭
2. iOS 번들 ID 입력: `com.mathlab.app` (Xcode에서 확인)
3. 앱 닉네임: `MathLab iOS` (선택사항)
4. `GoogleService-Info.plist` 다운로드
5. Xcode에서 `ios/Runner/` 폴더에 파일 추가 (Copy items if needed 체크)

### 4. Android 설정 파일 수정

**`android/build.gradle`**
```gradle
buildscript {
    dependencies {
        // Google Services 플러그인 추가
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

**`android/app/build.gradle`**
```gradle
apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'
apply from: "$flutterRoot/packages/flutter_tools/gradle/flutter.gradle"
// Google Services 플러그인 적용
apply plugin: 'com.google.gms.google-services'

android {
    defaultConfig {
        // ... 기존 설정

        // Google Sign-In을 위한 최소 SDK 버전
        minSdkVersion 21
    }
}

dependencies {
    // Google Play Services
    implementation 'com.google.android.gms:play-services-auth:20.7.0'
}
```

### 5. iOS 설정 (Xcode)

1. Xcode에서 `ios/Runner.xcworkspace` 열기
2. Runner > Signing & Capabilities 탭
3. Bundle Identifier 확인/설정: `com.mathlab.app`
4. Team 선택 (Apple Developer 계정 필요)

**`ios/Runner/Info.plist`에 URL Scheme 추가**

GoogleService-Info.plist에서 `REVERSED_CLIENT_ID` 값을 복사한 후:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- GoogleService-Info.plist의 REVERSED_CLIENT_ID 값 -->
            <string>com.googleusercontent.apps.YOUR_REVERSED_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

### 6. Firebase Authentication 활성화

1. Firebase Console > Authentication > Sign-in method
2. Google 로그인 활성화
3. 프로젝트 지원 이메일 입력
4. 저장

---

## Kakao 로그인 설정

### 1. Kakao Developers 앱 등록

1. [Kakao Developers](https://developers.kakao.com/)에 접속
2. "내 애플리케이션" > "애플리케이션 추가하기"
3. 앱 이름: `MathLab`
4. 회사명: (실제 회사명 입력)
5. 앱 생성 완료

### 2. 앱 키 확인

앱 설정 > 요약 정보에서 다음 키들을 확인:
- **네이티브 앱 키**: Android/iOS에서 사용
- **REST API 키**: 서버에서 사용 (선택)
- **JavaScript 키**: 웹에서 사용 (선택)

### 3. 플랫폼 설정

#### Android 플랫폼 등록

1. 앱 설정 > 플랫폼 > Android 플랫폼 등록
2. 패키지명: `com.mathlab.app`
3. 키 해시 등록:

```bash
# macOS/Linux - Debug
keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore -storepass android -keypass android | openssl sha1 -binary | openssl base64

# macOS/Linux - Release (release.keystore 사용 시)
keytool -exportcert -alias YOUR_ALIAS -keystore /path/to/release.keystore | openssl sha1 -binary | openssl base64
```

4. 마켓 URL: (선택사항)

#### iOS 플랫폼 등록

1. 앱 설정 > 플랫폼 > iOS 플랫폼 등록
2. 번들 ID: `com.mathlab.app`
3. 다운로드 URL: (선택사항)

### 4. Kakao Login 활성화

1. 제품 설정 > Kakao Login > 활성화 설정
2. Kakao Login 활성화: ON
3. OpenID Connect 활성화: ON (선택)

### 5. 동의 항목 설정

1. 제품 설정 > Kakao Login > 동의항목
2. 필수 동의 항목:
   - 닉네임 (필수)
   - 프로필 사진 (선택)
   - 카카오계정(이메일) (필수)

### 6. Android 설정

**`android/app/src/main/AndroidManifest.xml`**

```xml
<manifest>
    <application>
        <!-- 기존 activity -->

        <!-- Kakao Login Activity -->
        <activity
            android:name="com.kakao.sdk.auth.AuthCodeHandlerActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />

                <!-- Redirect URI: kakao{NATIVE_APP_KEY}://oauth -->
                <data
                    android:host="oauth"
                    android:scheme="kakao{YOUR_NATIVE_APP_KEY}" />
            </intent-filter>
        </activity>
    </application>
</manifest>
```

### 7. iOS 설정

**`ios/Runner/Info.plist`**

```xml
<key>CFBundleURLTypes</key>
<array>
    <!-- Google (기존) -->
    <dict>...</dict>

    <!-- Kakao -->
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- kakao{NATIVE_APP_KEY} -->
            <string>kakao{YOUR_NATIVE_APP_KEY}</string>
        </array>
    </dict>
</array>

<key>LSApplicationQueriesSchemes</key>
<array>
    <string>kakaokompassauth</string>
    <string>kakaolink</string>
    <string>kakaoplus</string>
</array>

<!-- Kakao SDK 앱 키 -->
<key>KAKAO_APP_KEY</key>
<string>{YOUR_NATIVE_APP_KEY}</string>
```

### 8. 코드에 Native App Key 추가

**`lib/data/providers/auth_provider.dart`** 파일에서 실제 Kakao Native App Key로 교체:

```dart
await _socialAuth.initializeKakao(
  nativeAppKey: 'YOUR_KAKAO_NATIVE_APP_KEY', // ← 실제 키로 교체
);
```

**⚠️ 보안 주의사항**
- 실제 프로덕션 앱에서는 환경변수나 보안 저장소 사용 권장
- 예: flutter_dotenv, flutter_config 등 사용

---

## Apple 로그인 설정

### 1. Apple Developer 계정 요구사항

- Apple Developer Program 가입 필요 (연간 $99)
- iOS 13.0 이상에서만 사용 가능

### 2. App ID 설정

1. [Apple Developer Console](https://developer.apple.com/account/) 접속
2. Certificates, Identifiers & Profiles > Identifiers
3. App IDs > "+" 버튼 클릭
4. App 선택 > Continue
5. Description: `MathLab`
6. Bundle ID: `com.mathlab.app` (Explicit)
7. Capabilities > Sign in with Apple 체크
8. Continue > Register

### 3. Service ID 생성 (웹/서버용, 선택사항)

1. Identifiers > Services IDs > "+" 버튼
2. Description: `MathLab Sign In`
3. Identifier: `com.mathlab.app.signin`
4. Sign in with Apple 체크
5. Configure 클릭
   - Primary App ID: `com.mathlab.app` 선택
   - Return URLs: 추가 (필요시)
6. Continue > Register

### 4. iOS 프로젝트 설정 (Xcode)

1. Xcode에서 `ios/Runner.xcworkspace` 열기
2. Runner 타겟 선택 > Signing & Capabilities
3. "+ Capability" 버튼 클릭
4. "Sign in with Apple" 추가

### 5. Info.plist 권한 추가는 자동

Xcode에서 Capability를 추가하면 자동으로 Info.plist가 업데이트됩니다.

### 6. Android 지원 (선택사항)

Android에서 Apple 로그인을 지원하려면 추가 설정 필요:
- 웹 기반 OAuth 흐름 사용
- Service ID와 Return URL 설정 필요
- 현재 구현은 iOS만 지원 (Platform.isIOS 체크)

---

## 테스트 방법

### 1. 개발 환경 준비

```bash
# 의존성 설치
flutter pub get

# iOS 의존성 설치 (macOS만)
cd ios
pod install
cd ..
```

### 2. 실행 및 테스트

```bash
# iOS 시뮬레이터 (macOS)
flutter run -d ios

# Android 에뮬레이터
flutter run -d android
```

### 3. 테스트 체크리스트

#### Google 로그인 테스트
- [ ] "Google로 계속하기" 버튼 클릭
- [ ] Google 계정 선택 화면 표시
- [ ] 계정 선택 후 앱으로 복귀
- [ ] 사용자 정보 저장 확인 (이름, 이메일)
- [ ] 로그아웃 후 재로그인 테스트

#### Kakao 로그인 테스트
- [ ] "Kakao로 계속하기" 버튼 클릭
- [ ] 카카오톡 앱 실행 (설치된 경우)
- [ ] 또는 카카오 계정 로그인 웹페이지 표시
- [ ] 동의 항목 확인 후 로그인
- [ ] 사용자 정보 저장 확인
- [ ] 로그아웃 후 재로그인 테스트

#### Apple 로그인 테스트 (iOS만)
- [ ] "Apple로 계속하기" 버튼 클릭
- [ ] Face ID / Touch ID 인증 또는 암호 입력
- [ ] 이메일 공유 옵션 선택
- [ ] 사용자 정보 저장 확인
- [ ] 로그아웃 후 재로그인 테스트

### 4. 디버깅 팁

**로그 확인**
```dart
// Logger를 사용한 로그는 콘솔에서 확인
flutter logs
```

**일반적인 문제**

1. **Google 로그인 실패**
   - SHA-1 인증서가 올바른지 확인
   - google-services.json이 올바른 위치에 있는지 확인
   - Firebase Console에서 Google 로그인이 활성화되어 있는지 확인

2. **Kakao 로그인 실패**
   - Native App Key가 올바른지 확인
   - 패키지명/번들 ID가 일치하는지 확인
   - 키 해시가 올바르게 등록되었는지 확인

3. **Apple 로그인 실패 (iOS)**
   - Capability가 추가되었는지 확인
   - Bundle ID가 Developer Console의 App ID와 일치하는지 확인
   - iOS 시뮬레이터에서는 테스트용 Apple ID 필요

---

## 프로덕션 배포 전 체크리스트

### Google
- [ ] 프로덕션 SHA-1 인증서 Firebase에 등록
- [ ] OAuth 동의 화면 설정 완료
- [ ] 개인정보 처리방침 URL 등록

### Kakao
- [ ] 프로덕션 키 해시 등록
- [ ] 비즈니스 인증 완료 (선택)
- [ ] 개인정보 처리방침 URL 등록

### Apple
- [ ] 프로덕션 프로비저닝 프로파일 생성
- [ ] App Store Connect에서 Sign in with Apple 활성화
- [ ] 개인정보 처리방침 URL 등록

---

## 참고 자료

- [Google Sign-In for Flutter](https://pub.dev/packages/google_sign_in)
- [Kakao Flutter SDK](https://developers.kakao.com/docs/latest/ko/flutter-sdk/getting-started)
- [Sign in with Apple](https://pub.dev/packages/sign_in_with_apple)
- [Firebase Console](https://console.firebase.google.com/)
- [Kakao Developers](https://developers.kakao.com/)
- [Apple Developer](https://developer.apple.com/)

---

## 문의 및 지원

문제가 발생하거나 추가 지원이 필요한 경우:
1. 각 플랫폼의 공식 문서 확인
2. GitHub Issues 검색
3. 개발팀에 문의

