# 🚀 MathLab 프로덕션 준비 가이드

## ✅ 완료된 작업 (2026-01-25)

### 1. 보안 시스템 ✅
**구현된 기능:**
- ✅ 환경변수 관리 시스템 (`lib/core/config/env_config.dart`)
  - flutter_dotenv를 사용한 타입 안전 환경변수 접근
  - 개발/프로덕션 환경 분리
  - API 키 검증 및 fallback 메커니즘

- ✅ 보안 저장소 (`lib/core/security/secure_storage_service.dart`)
  - AES 암호화를 사용한 안전한 토큰 저장
  - iOS Keychain / Android EncryptedSharedPreferences
  - 세션 관리 및 자동 만료 감지

- ✅ 입력값 검증 (`lib/core/security/input_validator.dart`)
  - XSS/SQL Injection 방지
  - 이메일, 전화번호, URL 검증
  - 한국어 특화 검증 (이름, 전화번호)

**보안 문서:**
- 📄 `SECURITY_AUDIT_REPORT.md` - 보안 감사 보고서
- 📄 `SECURITY_IMPLEMENTATION_GUIDE.md` - 구현 가이드
- 📄 `SECURITY_CHECKLIST.md` - 보안 체크리스트

### 2. 에러 핸들링 시스템 ✅
**구현된 기능:**
- ✅ 통합 에러 처리 (`lib/core/error/app_error.dart`)
  - 네트워크 에러 (NetworkException)
  - 인증 에러 (AuthException)
  - 데이터 에러 (DataException)
  - 저장소 에러 (StorageException)
  - 검증 에러 (ValidationException)
  - 비즈니스 로직 에러 (BusinessException)

- ✅ 사용자 친화적 에러 메시지
  - 한국어 에러 메시지 자동 변환
  - HTTP 상태 코드별 맞춤 메시지
  - 개발자/사용자 메시지 분리

### 3. 로깅 시스템 ✅
**구현된 기능:**
- ✅ 다단계 로깅 (`lib/core/utils/app_logger.dart`)
  - Debug, Info, Warning, Error, Fatal 레벨
  - 환경별 로그 레벨 자동 조정 (개발: 전체, 프로덕션: 에러만)
  - 태그 기반 로그 분류
  - 네트워크 요청/응답 전용 로깅
  - 성능 측정 로깅
  - 사용자 액션 로깅 (Analytics 연동 준비)

- ✅ Crashlytics 연동 준비
  - Firebase Crashlytics 보고 구조 준비
  - 에러 컨텍스트 자동 수집

### 4. API 클라이언트 ✅
**구현된 기능:**
- ✅ HTTP 클라이언트 (`lib/core/network/api_client.dart`)
  - Dio 기반 REST API 클라이언트
  - GET, POST, PUT, PATCH, DELETE 메서드
  - 자동 에러 처리 및 변환
  - 네트워크 연결 상태 체크

- ✅ 인증 인터셉터 (`interceptors/auth_interceptor.dart`)
  - 자동 Bearer 토큰 주입
  - 토큰 만료 시 자동 갱신
  - 401 에러 처리

- ✅ 로깅 인터셉터 (`interceptors/logging_interceptor.dart`)
  - 모든 HTTP 요청/응답 로깅
  - 개발 환경에서만 활성화

- ✅ 재시도 인터셉터 (`interceptors/retry_interceptor.dart`)
  - 네트워크 에러 시 자동 재시도
  - Exponential backoff (지수 백오프)
  - 최대 3회 재시도

### 5. 프로젝트 설정 ✅
- ✅ `pubspec.yaml` 생성 및 필수 패키지 설치
  - Firebase (Auth, Firestore, Storage, Analytics, Crashlytics)
  - Riverpod (상태관리)
  - Dio + HTTP (네트워킹)
  - flutter_dotenv (환경변수)
  - flutter_secure_storage (보안 저장소)
  - Kakao/Google 소셜 로그인
  - Hive + SharedPreferences (로컬 저장소)

- ✅ `.gitignore` 업데이트
  - `.env` 파일 제외
  - Firebase 설정 파일 제외
  - API 키 및 인증서 제외

- ✅ 환경변수 템플릿 (`.env.template`)
  - 실제 키 대신 플레이스홀더 제공
  - 각 키의 용도 및 발급처 명시

---

## ⚠️ 프로덕션 배포 전 필수 작업

### 1. API 키 교체 (최우선)
```bash
# ❌ 현재 .env 파일의 모든 키들은 즉시 교체 필요
# ✅ 새로운 키 발급처:

# 1. Kakao Developers
https://developers.kakao.com
→ 새 앱 생성 → 네이티브 앱 키 발급

# 2. Google Cloud Console
https://console.cloud.google.com
→ OAuth 2.0 클라이언트 ID 생성

# 3. Firebase Console
https://console.firebase.google.com
→ 프로젝트 설정 → Cloud Messaging

# 4. OpenAI (⚠️ 프로덕션에서는 서버에서만 사용!)
https://platform.openai.com/api-keys
→ 새 개발용 키 생성 + Usage Limits 설정
```

### 2. Firebase 설정
```bash
# Android
android/app/google-services.json 파일 추가

# iOS
ios/Runner/GoogleService-Info.plist 파일 추가

# ⚠️ 주의: 이 파일들은 절대 Git에 커밋하지 마세요!
```

### 3. 환경 변수 설정
```bash
# 1. .env.template을 복사하여 .env 생성
cp .env.template .env

# 2. .env 파일에 실제 API 키 입력
nano .env

# 3. 프로덕션 환경 변수 생성
cp .env.template .env.production
nano .env.production

# 4. APP_ENV를 production으로 변경
APP_ENV=production
```

### 4. 코드 초기화 작업
```dart
// lib/main.dart에 다음 코드 추가

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'core/config/env_config.dart';
import 'core/utils/app_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. 환경변수 초기화
  await EnvConfig.initialize(
    fileName: EnvConfig.isProduction ? '.env.production' : '.env',
  );

  // 2. 환경변수 검증
  EnvConfig.validateEnvironment();

  // 3. Firebase 초기화
  await Firebase.initializeApp();

  // 4. Crashlytics 설정 (프로덕션에서만)
  if (EnvConfig.isProduction) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  }

  // 5. 앱 시작
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MathLab',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}
```

### 5. 빌드 설정

#### Android (`android/app/build.gradle`)
```gradle
android {
    defaultConfig {
        // 앱 ID 변경
        applicationId "com.gomath.mathlab"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }

    buildTypes {
        release {
            // ProGuard 활성화 (코드 난독화)
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'

            // 서명 설정
            signingConfig signingConfigs.release
        }
    }
}
```

#### iOS (`ios/Runner.xcodeproj/project.pbxproj`)
```
- Display Name: MathLab
- Bundle Identifier: com.gomath.mathlab
- Version: 1.0.0
- Build: 1
```

### 6. 앱 서명 설정

#### Android
```bash
# 1. 키스토어 생성
keytool -genkey -v -keystore ~/mathlab-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias mathlab

# 2. android/key.properties 생성
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=mathlab
storeFile=/path/to/mathlab-release-key.jks

# ⚠️ key.properties는 절대 Git에 커밋하지 마세요!
```

#### iOS
```bash
# Xcode에서 Signing & Capabilities 설정
- Team 선택
- Bundle Identifier 입력
- Automatically manage signing 체크
```

---

## 🚀 빌드 및 배포

### 개발 빌드
```bash
# Android
flutter build apk --debug

# iOS
flutter build ios --debug
```

### 프로덕션 빌드
```bash
# Android (APK)
flutter build apk --release

# Android (App Bundle - Google Play 권장)
flutter build appbundle --release

# iOS
flutter build ios --release
```

### 배포
```bash
# Android - Google Play Console
https://play.google.com/console

# iOS - App Store Connect
https://appstoreconnect.apple.com
```

---

## 🧪 테스트

### 프로덕션 배포 전 체크리스트
- [ ] 모든 API 키가 프로덕션 키로 교체되었는가?
- [ ] `.env.production` 파일이 설정되었는가?
- [ ] Firebase 프로덕션 프로젝트가 설정되었는가?
- [ ] 앱 서명이 완료되었는가?
- [ ] 테스트가 통과되었는가?
- [ ] Crashlytics가 작동하는가?
- [ ] 프로덕션 API 엔드포인트가 올바른가?
- [ ] 앱 아이콘과 스플래시 화면이 설정되었는가?
- [ ] 개인정보 처리방침과 이용약관이 준비되었는가?

### 테스트 실행
```bash
# 단위 테스트
flutter test

# 위젯 테스트
flutter test test/widget_test.dart

# 통합 테스트
flutter test integration_test/
```

---

## 📊 모니터링

### Firebase Crashlytics
```dart
// 에러 보고 (자동)
try {
  // 코드
} catch (error, stackTrace) {
  AppLogger.error('Error occurred', error: error, stackTrace: stackTrace);
  // ↑ 자동으로 Crashlytics에 보고됨
}
```

### Firebase Analytics
```dart
AppLogger.logUserAction(
  'button_clicked',
  parameters: {
    'button_name': 'login',
    'screen': 'auth',
  },
);
```

---

## 🔧 문제 해결

### 자주 발생하는 문제

1. **환경변수 로드 실패**
   ```
   Error: Failed to load environment file: .env
   ```
   - `.env` 파일이 존재하는지 확인
   - `pubspec.yaml`의 `assets`에 `.env`가 포함되어 있는지 확인

2. **Firebase 초기화 실패**
   ```
   Error: [core/no-app] No Firebase App
   ```
   - `google-services.json` (Android) 또는 `GoogleService-Info.plist` (iOS) 파일 확인
   - `Firebase.initializeApp()`이 `main()`에서 호출되는지 확인

3. **API 호출 실패**
   ```
   NetworkException: 인터넷 연결을 확인해주세요
   ```
   - 디바이스의 인터넷 연결 확인
   - API Base URL이 올바른지 확인
   - CORS 설정 확인 (웹인 경우)

---

## 📚 추가 문서

- [SECURITY_AUDIT_REPORT.md](./SECURITY_AUDIT_REPORT.md) - 보안 감사 보고서
- [SECURITY_IMPLEMENTATION_GUIDE.md](./SECURITY_IMPLEMENTATION_GUIDE.md) - 보안 구현 가이드
- [SECURITY_CHECKLIST.md](./SECURITY_CHECKLIST.md) - 보안 체크리스트
- [CLAUDE.md](./CLAUDE.md) - 프로젝트 개요 및 기술 스택

---

## 🤝 지원

문제가 발생하면:
1. [Issues](https://github.com/your-repo/issues)에 버그 리포트 작성
2. [Security 문서](./SECURITY_IMPLEMENTATION_GUIDE.md) 참조
3. Claude Code에게 질문

---

**🤖 Generated with Claude Code**
**Last Updated**: 2026-01-25
**Version**: 1.0.0
