# 🔐 환경 변수 설정 가이드

## 📋 목차
1. [환경 변수란?](#환경-변수란)
2. [.env 파일 생성](#env-파일-생성)
3. [Firebase 설정값 가져오기](#firebase-설정값-가져오기)
4. [Google Sign-In 설정](#google-sign-in-설정)
5. [Kakao SDK 설정](#kakao-sdk-설정)
6. [OpenAI API 설정](#openai-api-설정)
7. [환경 변수 검증](#환경-변수-검증)
8. [보안 주의사항](#보안-주의사항)

---

## 🤔 환경 변수란?

### 개요
환경 변수는 앱이 실행되는 환경에 따라 달라지는 설정값(API 키, 데이터베이스 URL 등)을 코드 외부에서 관리하는 방법입니다.

### 왜 필요한가?
- ✅ **보안**: API 키를 코드에 직접 노출하지 않음
- ✅ **유연성**: 개발/프로덕션 환경별 다른 설정 사용
- ✅ **팀 협업**: 각 개발자가 자신의 키 사용
- ✅ **버전 관리**: Git에 민감한 정보 커밋 방지

---

## 📝 .env 파일 생성

### 1단계: 예제 파일 복사

```bash
cd /Users/yeojoonsoo02/Desktop/Work_Project/Gomath/MathLab

# .env.example 파일을 .env로 복사
cp .env.example .env

# 파일 확인
ls -la .env
```

### 2단계: .env 파일 구조 이해

`.env` 파일은 다음과 같은 구조를 가집니다:

```bash
# 주석은 # 기호로 시작
VARIABLE_NAME=value

# 예시
FIREBASE_API_KEY=AIzaSyABC123...
APP_ENV=development
DEBUG_MODE=true
```

---

## 🔥 Firebase 설정값 가져오기

### Android (google-services.json)

#### 1. google-services.json 파일 열기
```bash
# 파일 위치
cat android/app/google-services.json
```

#### 2. 필요한 값 추출
```json
{
  "project_info": {
    "project_id": "mathlab-12345",              // FIREBASE_PROJECT_ID
    "firebase_url": "https://mathlab-12345.firebaseio.com",
    "project_number": "123456789012",            // FIREBASE_MESSAGING_SENDER_ID
    "storage_bucket": "mathlab-12345.appspot.com" // FIREBASE_STORAGE_BUCKET
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:123456789012:android:abc123", // FIREBASE_APP_ID
        "android_client_info": {
          "package_name": "com.mathlab.app"
        }
      },
      "api_key": [
        {
          "current_key": "AIzaSyABC123DEF456..."    // FIREBASE_API_KEY
        }
      ]
    }
  ]
}
```

#### 3. .env 파일에 입력
```bash
# .env 파일 편집
nano .env

# 또는 VSCode로 열기
code .env
```

```bash
# Firebase 설정 (google-services.json에서 가져온 값)
FIREBASE_API_KEY=AIzaSyABC123DEF456...
FIREBASE_APP_ID=1:123456789012:android:abc123
FIREBASE_MESSAGING_SENDER_ID=123456789012
FIREBASE_PROJECT_ID=mathlab-12345
FIREBASE_STORAGE_BUCKET=mathlab-12345.appspot.com
```

### iOS (GoogleService-Info.plist)

#### 1. GoogleService-Info.plist 파일 열기
```bash
# 파일 위치
cat ios/Runner/GoogleService-Info.plist
```

#### 2. 필요한 값 추출
```xml
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
  <key>API_KEY</key>
  <string>AIzaSyABC123DEF456...</string>           <!-- FIREBASE_API_KEY -->

  <key>GCM_SENDER_ID</key>
  <string>123456789012</string>                    <!-- FIREBASE_MESSAGING_SENDER_ID -->

  <key>GOOGLE_APP_ID</key>
  <string>1:123456789012:ios:xyz789</string>       <!-- FIREBASE_APP_ID (iOS용) -->

  <key>PROJECT_ID</key>
  <string>mathlab-12345</string>                   <!-- FIREBASE_PROJECT_ID -->

  <key>STORAGE_BUCKET</key>
  <string>mathlab-12345.appspot.com</string>       <!-- FIREBASE_STORAGE_BUCKET -->
</dict>
</plist>
```

#### 3. iOS용 값 추가 (선택사항)
iOS와 Android의 APP_ID가 다르므로 필요시 별도 변수 추가:
```bash
FIREBASE_APP_ID_IOS=1:123456789012:ios:xyz789
FIREBASE_APP_ID_ANDROID=1:123456789012:android:abc123
```

---

## 🔑 Google Sign-In 설정

### 1. Firebase Console에서 OAuth 클라이언트 ID 가져오기

#### Android
```
1. Firebase Console > 프로젝트 설정
2. 일반 탭
3. Android 앱 섹션에서 google-services.json 다운로드 링크 아래
4. "OAuth 2.0 Client ID" 복사

또는

1. Google Cloud Console: https://console.cloud.google.com
2. APIs & Services > Credentials
3. OAuth 2.0 Client IDs에서 Android 클라이언트 ID 찾기
4. 형식: xxx.apps.googleusercontent.com
```

#### iOS
```
1. GoogleService-Info.plist 파일 열기
2. CLIENT_ID 키의 값 복사
3. 형식: xxx.apps.googleusercontent.com
```

### 2. .env 파일에 추가
```bash
# Google Sign-In
GOOGLE_CLIENT_ID_IOS=123456789-abc.apps.googleusercontent.com
GOOGLE_CLIENT_ID_ANDROID=123456789-xyz.apps.googleusercontent.com
```

### 3. Reversed Client ID (iOS 전용)
```bash
# GoogleService-Info.plist에서 REVERSED_CLIENT_ID 찾기
GOOGLE_REVERSED_CLIENT_ID_IOS=com.googleusercontent.apps.123456789-abc
```

---

## 📱 Kakao SDK 설정

### 1. Kakao Developers Console
```
https://developers.kakao.com
```

### 2. 앱 생성 및 키 발급
```
1. "내 애플리케이션" > "애플리케이션 추가하기"
2. 앱 이름: MathLab
3. 회사명: (본인 이름 또는 회사명)
4. 앱 생성 완료
```

### 3. 네이티브 앱 키 확인
```
1. 생성된 앱 선택
2. 요약 정보 > 앱 키
3. "네이티브 앱 키" 복사
```

### 4. .env 파일에 추가
```bash
# Kakao SDK
KAKAO_NATIVE_APP_KEY=abc123def456ghi789jkl
```

### 5. 플랫폼 설정 (중요!)

#### Android
```
1. 앱 선택 > 플랫폼 > Android 플랫폼 등록
2. 패키지명: com.mathlab.app
3. 마켓 URL: (Play Store 링크 - 배포 후)
4. 키 해시 등록:
```

키 해시 생성:
```bash
keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore | openssl sha1 -binary | openssl base64

# 출력된 해시값을 Kakao Developers에 등록
```

#### iOS
```
1. 앱 선택 > 플랫폼 > iOS 플랫폼 등록
2. 번들 ID: com.mathlab.app
3. 마켓 URL: (App Store 링크 - 배포 후)
```

---

## 🤖 OpenAI API 설정 (선택사항)

MathLab은 AI 튜터 기능을 위해 OpenAI API를 사용할 수 있습니다.

### 1. OpenAI API 키 발급
```
1. https://platform.openai.com 접속
2. API Keys 메뉴
3. "Create new secret key" 클릭
4. 키 이름: MathLab
5. 생성된 키 복사 (한 번만 표시됨!)
```

### 2. .env 파일에 추가
```bash
# OpenAI API
OPENAI_API_KEY=sk-proj-abcdef123456...
OPENAI_ORGANIZATION_ID=org-xyz789...  # 선택사항
```

### 3. 사용량 제한 설정 (권장)
```
1. OpenAI Platform > Usage limits
2. Hard limit 설정: $10/month (예시)
3. Email notification 활성화
```

---

## 🔍 환경 변수 검증

### 자동 검증 스크립트

`scripts/verify_env.sh` 파일 생성:
```bash
#!/bin/bash

echo "🔍 환경 변수 검증 중..."

# .env 파일 존재 확인
if [ ! -f ".env" ]; then
  echo "❌ .env 파일이 없습니다!"
  echo "✅ cp .env.example .env 명령어로 생성하세요."
  exit 1
fi

# 필수 변수 확인
required_vars=(
  "FIREBASE_API_KEY"
  "FIREBASE_PROJECT_ID"
  "KAKAO_NATIVE_APP_KEY"
)

missing_vars=()

for var in "${required_vars[@]}"; do
  if ! grep -q "^${var}=" .env || grep -q "^${var}=your_" .env; then
    missing_vars+=("$var")
  fi
done

if [ ${#missing_vars[@]} -eq 0 ]; then
  echo "✅ 모든 필수 환경 변수가 설정되었습니다!"
else
  echo "❌ 다음 환경 변수가 설정되지 않았습니다:"
  for var in "${missing_vars[@]}"; do
    echo "   - $var"
  done
  exit 1
fi
```

실행:
```bash
chmod +x scripts/verify_env.sh
./scripts/verify_env.sh
```

### Flutter 앱에서 확인

`lib/shared/config/app_config.dart` 파일 확인:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // Firebase
  static String get firebaseApiKey =>
    dotenv.env['FIREBASE_API_KEY'] ?? '';

  static String get firebaseProjectId =>
    dotenv.env['FIREBASE_PROJECT_ID'] ?? '';

  // Kakao
  static String get kakaoNativeAppKey =>
    dotenv.env['KAKAO_NATIVE_APP_KEY'] ?? '';

  // 검증
  static bool get isConfigured {
    return firebaseApiKey.isNotEmpty &&
           firebaseProjectId.isNotEmpty &&
           kakaoNativeAppKey.isNotEmpty;
  }
}
```

앱 시작 시 검증:
```dart
void main() async {
  await dotenv.load(fileName: ".env");

  if (!AppConfig.isConfigured) {
    print('⚠️ 환경 변수가 올바르게 설정되지 않았습니다!');
  }

  runApp(MyApp());
}
```

---

## 🔒 보안 주의사항

### ✅ 해야 할 것

1. **절대 Git에 커밋하지 않기**
```bash
# .gitignore 파일에 이미 추가되어 있음
.env
.env.local
.env.*.local
```

2. **팀원과 안전하게 공유**
```
- 1Password, Bitwarden 등 비밀번호 관리 도구 사용
- 이메일/메신저로 직접 전송 금지
- GitHub Secrets 사용 (CI/CD)
```

3. **정기적인 키 교체**
```
3-6개월마다 API 키 재발급 권장
```

4. **프로덕션과 개발 환경 분리**
```bash
.env.development
.env.production
```

### ❌ 하지 말아야 할 것

1. **❌ 코드에 하드코딩**
```dart
// 절대 하지 마세요!
final apiKey = "AIzaSyABC123...";
```

2. **❌ 공개 저장소에 업로드**
```
GitHub Public Repository에 .env 파일 포함 금지
```

3. **❌ 스크린샷에 노출**
```
환경 변수가 포함된 화면 캡처 시 주의
```

4. **❌ 불필요한 권한 부여**
```
테스트용 Firebase 프로젝트는 제한된 권한만 사용
```

---

## 📂 환경별 설정 파일 관리 (고급)

### 파일 구조
```
.env                 # 로컬 개발용 (Git에 미포함)
.env.example         # 템플릿 (Git에 포함)
.env.development     # 개발 환경 (선택)
.env.production      # 프로덕션 환경 (선택)
```

### Flutter에서 사용
```dart
// 환경에 따라 다른 파일 로드
final envFile = kReleaseMode ? '.env.production' : '.env.development';
await dotenv.load(fileName: envFile);
```

---

## ✅ 최종 체크리스트

### 필수 환경 변수
- [ ] `FIREBASE_API_KEY` 설정
- [ ] `FIREBASE_PROJECT_ID` 설정
- [ ] `FIREBASE_APP_ID` 설정
- [ ] `FIREBASE_MESSAGING_SENDER_ID` 설정
- [ ] `FIREBASE_STORAGE_BUCKET` 설정
- [ ] `KAKAO_NATIVE_APP_KEY` 설정

### 선택 환경 변수
- [ ] `GOOGLE_CLIENT_ID_IOS` 설정 (Google 로그인 사용 시)
- [ ] `GOOGLE_CLIENT_ID_ANDROID` 설정 (Google 로그인 사용 시)
- [ ] `OPENAI_API_KEY` 설정 (AI 기능 사용 시)

### 보안
- [ ] .env 파일이 .gitignore에 포함되어 있음
- [ ] Git 히스토리에 .env 파일이 없음 확인
- [ ] 팀원과 안전한 방법으로 공유 계획 수립

### 테스트
- [ ] `flutter pub get` 실행
- [ ] `./scripts/verify_env.sh` 실행 (검증 스크립트)
- [ ] `flutter run` 실행하여 앱이 정상 작동하는지 확인

---

## 🆘 문제 해결

### 문제: "Failed to load .env file"

**원인**: .env 파일이 존재하지 않거나 잘못된 위치
```bash
# 해결 방법
ls -la .env  # 파일 존재 확인
cp .env.example .env  # 없으면 생성
```

### 문제: "Environment variable not found"

**원인**: 변수 이름 오타 또는 값 미설정
```bash
# 해결 방법
cat .env | grep VARIABLE_NAME  # 변수 확인
nano .env  # 수정
```

### 문제: Firebase 연결 실패

**원인**: Firebase 설정값 오류
```bash
# google-services.json과 .env 값 비교
cat android/app/google-services.json
cat .env
```

### 문제: Kakao 로그인 실패

**원인**: Kakao Native App Key 오류 또는 플랫폼 미등록
```
1. Kakao Developers에서 키 재확인
2. Android/iOS 플랫폼 등록 확인
3. 키 해시 등록 확인 (Android)
```

---

## 📚 추가 리소스

### 공식 문서
- Flutter dotenv: https://pub.dev/packages/flutter_dotenv
- Firebase Environment: https://firebase.google.com/docs/projects/dev-workflow
- Kakao Developers: https://developers.kakao.com

### 보안 가이드
- OWASP API Security: https://owasp.org/www-project-api-security/
- 12 Factor App: https://12factor.net/config

---

**최종 업데이트**: 2025년 1월 18일
**문서 버전**: 1.0
