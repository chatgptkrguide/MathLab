# 🔥 Firebase 설정 완전 가이드

## 📋 목차
1. [Firebase 프로젝트 생성](#firebase-프로젝트-생성)
2. [Android 설정](#android-설정)
3. [iOS 설정](#ios-설정)
4. [Firebase 서비스 활성화](#firebase-서비스-활성화)
5. [보안 규칙 설정](#보안-규칙-설정)
6. [테스트 및 검증](#테스트-및-검증)

---

## 🚀 Firebase 프로젝트 생성

### 1단계: Firebase Console 접속
```
https://console.firebase.google.com
```

### 2단계: 프로젝트 생성
```
1. "프로젝트 추가" 클릭
2. 프로젝트 이름: "MathLab" 입력
3. Google Analytics 활성화 (권장)
4. Analytics 계정 선택 또는 새로 만들기
5. "프로젝트 만들기" 클릭
6. 프로젝트 생성 완료 대기 (1-2분)
```

### 3단계: 프로젝트 설정 확인
```
1. 프로젝트 대시보드 접속
2. 좌측 상단 톱니바퀴 > 프로젝트 설정
3. 프로젝트 ID 확인 및 메모
   (예: mathlab-12345)
```

---

## 📱 Android 설정

### 1단계: Android 앱 등록

#### Firebase Console에서
```
1. 프로젝트 대시보드
2. "Android 앱에 Firebase 추가" 클릭
3. 정보 입력:
   - Android 패키지 이름: com.mathlab.app
     (android/app/build.gradle 파일에서 확인)
   - 앱 닉네임: MathLab
   - 디버그 서명 인증서 SHA-1: (선택사항, 나중에 추가 가능)
4. "앱 등록" 클릭
```

#### SHA-1 인증서 생성 (선택사항, Google 로그인 필요 시)
```bash
# macOS/Linux
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Windows
keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android

# 출력에서 SHA-1 복사하여 Firebase Console에 입력
```

### 2단계: google-services.json 다운로드

#### 다운로드
```
1. Firebase Console에서 "google-services.json 다운로드" 클릭
2. 파일 저장
```

#### 프로젝트에 추가
```bash
# google-services.json 파일을 Android 앱 디렉토리에 복사
cp ~/Downloads/google-services.json /Users/yeojoonsoo02/Desktop/Work_Project/Gomath/MathLab/android/app/

# 파일 위치 확인
ls -la /Users/yeojoonsoo02/Desktop/Work_Project/Gomath/MathLab/android/app/google-services.json
```

### 3단계: build.gradle 확인

이미 설정되어 있는지 확인:

#### android/build.gradle
```gradle
buildscript {
    dependencies {
        // Firebase Gradle 플러그인 (이미 추가되어 있어야 함)
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

#### android/app/build.gradle
```gradle
// 파일 하단에 다음 라인 확인
apply plugin: 'com.google.gms.google-services'
```

### 4단계: Firebase SDK 확인

#### android/app/build.gradle dependencies 섹션
```gradle
dependencies {
    // Firebase BOM (이미 추가되어 있어야 함)
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-analytics'
}
```

---

## 🍎 iOS 설정

### 1단계: iOS 앱 등록

#### Firebase Console에서
```
1. 프로젝트 대시보드
2. "iOS 앱에 Firebase 추가" 클릭
3. 정보 입력:
   - iOS 번들 ID: com.mathlab.app
     (ios/Runner.xcodeproj/project.pbxproj에서 확인)
   - 앱 닉네임: MathLab
   - App Store ID: (나중에 추가 가능)
4. "앱 등록" 클릭
```

#### Bundle ID 확인
```bash
# Xcode에서 확인
open /Users/yeojoonsoo02/Desktop/Work_Project/Gomath/MathLab/ios/Runner.xcworkspace

# 또는 Info.plist에서 확인
cat /Users/yeojoonsoo02/Desktop/Work_Project/Gomath/MathLab/ios/Runner/Info.plist | grep CFBundleIdentifier
```

### 2단계: GoogleService-Info.plist 다운로드

#### 다운로드
```
1. Firebase Console에서 "GoogleService-Info.plist 다운로드" 클릭
2. 파일 저장
```

#### 프로젝트에 추가
```bash
# GoogleService-Info.plist 파일을 iOS Runner 디렉토리에 복사
cp ~/Downloads/GoogleService-Info.plist /Users/yeojoonsoo02/Desktop/Work_Project/Gomath/MathLab/ios/Runner/

# 파일 위치 확인
ls -la /Users/yeojoonsoo02/Desktop/Work_Project/Gomath/MathLab/ios/Runner/GoogleService-Info.plist
```

#### Xcode에서 추가 (중요!)
```
1. Xcode 열기
   open /Users/yeojoonsoo02/Desktop/Work_Project/Gomath/MathLab/ios/Runner.xcworkspace

2. Runner 프로젝트 우클릭
3. "Add Files to Runner" 선택
4. GoogleService-Info.plist 파일 선택
5. ✅ "Copy items if needed" 체크
6. ✅ "Add to targets: Runner" 체크
7. "Add" 클릭
```

### 3단계: iOS Podfile 확인

이미 설정되어 있는지 확인:

#### ios/Podfile
```ruby
# Firebase 관련 pods (flutter pub get 실행 시 자동 추가)
# 수동 확인 필요 없음 - Flutter가 자동 관리
```

### 4단계: CocoaPods 설치
```bash
cd /Users/yeojoonsoo02/Desktop/Work_Project/Gomath/MathLab/ios
pod install

# 출력 확인
# Installing Firebase... (여러 Firebase pods 설치됨)
```

---

## 🔧 Firebase 서비스 활성화

### 1. Authentication (인증)

#### Firebase Console
```
1. 좌측 메뉴 > Build > Authentication
2. "시작하기" 클릭
3. Sign-in method 탭
4. 활성화할 로그인 방법:
   ✅ 이메일/비밀번호
   ✅ Google
   ✅ Apple (iOS 전용)
```

#### 이메일/비밀번호
```
1. "이메일/비밀번호" 클릭
2. "사용 설정" 토글 ON
3. "저장" 클릭
```

#### Google 로그인
```
1. "Google" 클릭
2. "사용 설정" 토글 ON
3. 프로젝트 지원 이메일 선택
4. "저장" 클릭
```

#### Apple 로그인 (iOS)
```
1. "Apple" 클릭
2. "사용 설정" 토글 ON
3. "저장" 클릭
```

### 2. Firestore Database (데이터베이스)

#### 데이터베이스 생성
```
1. 좌측 메뉴 > Build > Firestore Database
2. "데이터베이스 만들기" 클릭
3. 위치 선택:
   - asia-northeast3 (서울) 권장
   - 또는 asia-northeast1 (도쿄)
4. 보안 규칙 선택:
   - "테스트 모드에서 시작" (개발 중)
   - 나중에 "프로덕션 모드"로 변경
5. "사용 설정" 클릭
```

#### 보안 규칙 설정 (나중에 적용)
```
프로젝트의 firestore.rules 파일 참조
firebase deploy --only firestore:rules
```

### 3. Storage (파일 저장소)

#### Storage 생성
```
1. 좌측 메뉴 > Build > Storage
2. "시작하기" 클릭
3. 보안 규칙:
   - "테스트 모드에서 시작" 선택
4. 위치: Firestore와 동일 (asia-northeast3)
5. "완료" 클릭
```

#### 보안 규칙 설정 (나중에 적용)
```
프로젝트의 storage.rules 파일 참조
firebase deploy --only storage
```

### 4. Analytics (분석)

#### 자동 활성화
```
프로젝트 생성 시 Google Analytics를 활성화했다면 자동으로 설정됨
```

#### 추가 설정 (선택)
```
1. 좌측 메뉴 > Analytics
2. Events, Conversions 등 확인
3. 커스텀 이벤트 추가 가능
```

### 5. Crashlytics (크래시 리포팅)

#### 활성화
```
1. 좌측 메뉴 > Release & Monitor > Crashlytics
2. "시작하기" 클릭
3. Flutter 앱에 이미 설정되어 있음 (pubspec.yaml 확인)
4. 앱 실행 시 자동으로 초기화됨
```

### 6. Cloud Messaging (푸시 알림)

#### FCM 설정
```
1. 좌측 메뉴 > Engage > Messaging
2. 기본 설정 완료 (추가 작업 불필요)
3. 알림 전송 테스트 가능
```

#### iOS APNs 인증 키 업로드 (iOS 푸시 알림용)
```
1. 프로젝트 설정 > Cloud Messaging 탭
2. "APNs 인증 키 업로드" 클릭
3. Apple Developer에서 생성한 .p8 파일 업로드
4. Key ID 및 Team ID 입력
```

---

## 🔒 보안 규칙 설정

### Firestore 보안 규칙

#### 개발 환경 (테스트 모드)
```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.time < timestamp.date(2025, 2, 1);
    }
  }
}
```

#### 프로덕션 환경 (보안 강화)
프로젝트에 이미 작성된 `firestore.rules` 파일 사용:
```bash
# firestore.rules 파일 확인
cat /Users/yeojoonsoo02/Desktop/Work_Project/Gomath/MathLab/firestore.rules

# Firebase에 배포
firebase deploy --only firestore:rules
```

### Storage 보안 규칙

#### 프로덕션 환경
프로젝트에 이미 작성된 `storage.rules` 파일 사용:
```bash
# storage.rules 파일 확인
cat /Users/yeojoonsoo02/Desktop/Work_Project/Gomath/MathLab/storage.rules

# Firebase에 배포
firebase deploy --only storage
```

---

## ✅ 테스트 및 검증

### 1. Flutter 앱 빌드 테스트

```bash
cd /Users/yeojoonsoo02/Desktop/Work_Project/Gomath/MathLab

# Android 빌드
flutter build apk --debug

# iOS 빌드
flutter build ios --debug

# 에러 없이 완료되면 성공
```

### 2. Firebase 연결 테스트

#### Android
```bash
# Android 에뮬레이터 또는 실제 기기에서 실행
flutter run

# 로그 확인
adb logcat | grep -i firebase

# 출력 예시:
# Firebase initialization successful
# FirebaseAuth initialized
# Firestore initialized
```

#### iOS
```bash
# iOS 시뮬레이터 또는 실제 기기에서 실행
flutter run -d "iPhone 15 Pro"

# Xcode 로그 확인
# Firebase initialization successful 메시지 확인
```

### 3. 기능별 테스트

#### Authentication 테스트
```
1. 앱 실행
2. 회원가입 화면에서 이메일/비밀번호로 가입
3. Firebase Console > Authentication > Users
4. 새 사용자가 추가되었는지 확인
```

#### Firestore 테스트
```
1. 앱에서 문제 풀이 또는 데이터 저장 작업 수행
2. Firebase Console > Firestore Database
3. 컬렉션 및 문서가 생성되었는지 확인
```

#### Storage 테스트
```
1. 앱에서 프로필 사진 업로드
2. Firebase Console > Storage
3. 파일이 업로드되었는지 확인
```

#### Analytics 테스트
```
1. 앱 실행 및 여러 화면 이동
2. Firebase Console > Analytics > Events
3. 이벤트가 기록되는지 확인 (최대 24시간 지연)
```

### 4. 일반적인 문제 해결

#### 문제: "Default FirebaseApp is not initialized"
```bash
# 해결 방법
1. main.dart에서 Firebase.initializeApp() 호출 확인
2. google-services.json (Android) 또는 GoogleService-Info.plist (iOS) 파일 존재 확인
3. 앱 재빌드
```

#### 문제: "google-services.json not found"
```bash
# 파일 위치 확인
ls -la /Users/yeojoonsoo02/Desktop/Work_Project/Gomath/MathLab/android/app/google-services.json

# 없으면 Firebase Console에서 재다운로드
```

#### 문제: iOS 빌드 실패
```bash
# CocoaPods 재설치
cd ios
rm -rf Pods Podfile.lock
pod install

# Xcode에서 Clean Build
Product > Clean Build Folder (Shift + Cmd + K)
```

---

## 📊 Firebase 사용량 모니터링

### 1. Spark Plan (무료) 한도 확인
```
Firestore:
- 읽기: 50,000/day
- 쓰기: 20,000/day
- 삭제: 20,000/day

Storage:
- 저장: 5GB
- 다운로드: 1GB/day

Authentication:
- 무제한 (이메일, Google, Apple)

Functions:
- 125,000/month 호출
```

### 2. 사용량 확인
```
Firebase Console > 좌측 하단 > Upgrade
> 현재 사용량 및 한도 확인
```

### 3. Blaze Plan (종량제) 업그레이드
```
필요 시:
1. Firebase Console > Upgrade to Blaze Plan
2. 신용카드 등록
3. 예산 알림 설정 권장
```

---

## 🔐 환경별 Firebase 프로젝트 분리 (권장)

### 개발 환경과 프로덕션 환경 분리

#### 1. 개발용 프로젝트
```
프로젝트 이름: MathLab-Dev
패키지명: com.mathlab.app.dev
용도: 개발 및 테스트
```

#### 2. 프로덕션용 프로젝트
```
프로젝트 이름: MathLab-Prod
패키지명: com.mathlab.app
용도: 실제 사용자 서비스
```

#### 3. Flavor 설정 (선택사항)
Flutter에서 여러 Firebase 프로젝트 사용하려면 `flavor` 설정 필요 (고급 주제)

---

## ✅ 최종 체크리스트

### Firebase Console
- [ ] Firebase 프로젝트 생성 완료
- [ ] Android 앱 등록 완료
- [ ] iOS 앱 등록 완료
- [ ] Authentication 활성화 (이메일, Google, Apple)
- [ ] Firestore Database 생성 완료
- [ ] Storage 생성 완료
- [ ] Analytics 활성화 확인
- [ ] Crashlytics 활성화 확인
- [ ] Cloud Messaging 설정 확인

### 프로젝트 파일
- [ ] android/app/google-services.json 존재
- [ ] ios/Runner/GoogleService-Info.plist 존재
- [ ] Xcode에서 GoogleService-Info.plist 추가 확인
- [ ] ios/Pods 설치 완료 (pod install)

### 테스트
- [ ] Android 빌드 성공
- [ ] iOS 빌드 성공
- [ ] Firebase 초기화 로그 확인
- [ ] Authentication 테스트 (회원가입/로그인)
- [ ] Firestore 데이터 저장 테스트
- [ ] Storage 파일 업로드 테스트

### 보안
- [ ] Firestore 보안 규칙 배포 (프로덕션)
- [ ] Storage 보안 규칙 배포 (프로덕션)
- [ ] 테스트 모드 만료일 확인

---

## 📞 추가 도움말

### 공식 문서
- Firebase Flutter: https://firebase.google.com/docs/flutter/setup
- FlutterFire: https://firebase.flutter.dev

### 커뮤니티
- Firebase Support: https://firebase.google.com/support
- Stack Overflow: https://stackoverflow.com/questions/tagged/firebase+flutter

---

**최종 업데이트**: 2025년 1월 18일
**문서 버전**: 1.0
