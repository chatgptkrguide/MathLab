# Firebase 설정 가이드

## 1. Firebase 프로젝트 생성

1. [Firebase Console](https://console.firebase.google.com/)에 접속
2. "프로젝트 추가" 클릭
3. 프로젝트 이름: `MathLab` 입력
4. Google Analytics 활성화 (선택사항)

## 2. Flutter 앱에 Firebase 추가

### 2.1 FlutterFire CLI 설치
```bash
dart pub global activate flutterfire_cli
```

### 2.2 Firebase 프로젝트 설정
```bash
flutterfire configure
```

선택사항:
- 프로젝트: MathLab
- 플랫폼: Android, iOS, Web

## 3. Firebase 서비스 활성화

### 3.1 Authentication
1. Firebase Console > Authentication
2. "시작하기" 클릭
3. 로그인 제공업체 활성화:
   - 이메일/비밀번호
   - Google
   - Apple (iOS용, 선택사항)

### 3.2 Firestore Database
1. Firebase Console > Firestore Database
2. "데이터베이스 만들기" 클릭
3. 모드 선택: "프로덕션 모드"
4. 위치: asia-northeast3 (서울)

### 3.3 Storage (선택사항)
1. Firebase Console > Storage
2. "시작하기" 클릭
3. 보안 규칙 설정

## 4. 보안 규칙 설정

### Firestore 보안 규칙
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 사용자 프로필
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    // 진행상황
    match /progress/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    // 리더보드 (읽기 전용)
    match /leaderboard/{document=**} {
      allow read: if request.auth != null;
      allow write: if false;
    }

    // 문제 데이터 (읽기 전용)
    match /problems/{problem} {
      allow read: if request.auth != null;
      allow write: if false;
    }
  }
}
```

## 5. 환경 변수 설정

프로젝트 루트에 `.env` 파일 생성 후 Firebase 설정 추가
