# MathLab 백엔드 시스템 완벽 가이드

## 🎯 개요

MathLab은 Google Cloud Platform (GCP)의 Firebase를 기반으로 한 완전한 서버리스 백엔드 시스템을 사용합니다.

## ✅ 프로젝트 생성 완료

### GCP 프로젝트 정보
- **프로젝트 ID**: `mathlab-gomath`
- **프로젝트 번호**: `421762663548`
- **프로젝트 이름**: MathLab
- **생성일**: 2025-11-22 10:10:45 UTC

### Firestore 데이터베이스
- **위치**: asia-northeast3 (서울)
- **모드**: FIRESTORE_NATIVE
- **에디션**: 표준 (무료 tier)
- **상태**: ✅ 활성화됨
- **Database ID**: (default)

### 활성화된 Firebase API
- ✅ Firebase API (firebase.googleapis.com)
- ✅ Firestore API (firestore.googleapis.com)
- ✅ Identity Toolkit API (identitytoolkit.googleapis.com)
- ✅ Firebase Hosting API (firebasehosting.googleapis.com)
- ✅ Cloud Functions API (cloudfunctions.googleapis.com)

## 📋 구현된 기능

### 1. Firebase 서비스
- ✅ **Firebase Authentication**: 이메일/비밀번호, Google 로그인
- ✅ **Cloud Firestore**: NoSQL 데이터베이스
- ✅ **Firebase Storage**: 이미지 및 파일 저장
- ✅ **Firebase Analytics**: 사용자 행동 분석

### 2. 데이터 모델

#### UserModel (`lib/data/models/user_model.dart`)
```dart
class UserModel {
  final String uid;              // 사용자 고유 ID
  final String email;            // 이메일
  final String displayName;      // 표시 이름
  final String currentGrade;     // 현재 학년 (중1, 중2, 중3)
  final int totalXP;             // 총 경험치
  final int level;               // 레벨
  final int streak;              // 연속 학습 일수
  final DateTime lastStudyDate;  // 마지막 학습 날짜
  final Map<String, int> categoryXP;  // 카테고리별 XP
  final List<String> achievements;     // 획득 업적
  final String league;           // 리그 (Bronze, Silver, Gold, Diamond)
}
```

#### ProgressModel (`lib/data/models/progress_model.dart`)
```dart
class ProgressModel {
  final String userId;           // 사용자 ID
  final String grade;            // 학년
  final String chapter;          // 단원
  final String lessonId;         // 레슨 ID
  final int problemsCompleted;   // 완료한 문제 수
  final int correctAnswers;      // 정답 수
  final int xpEarned;            // 획득 XP
  final bool isCompleted;        // 완료 여부
}
```

#### DailyStudyModel
```dart
class DailyStudyModel {
  final String userId;           // 사용자 ID
  final DateTime date;           // 학습 날짜
  final int problemsCompleted;   // 완료한 문제 수
  final int xpEarned;            // 획득 XP
  final int studyTimeMinutes;    // 학습 시간 (분)
  final Map<String, int> categoryProgress;  // 카테고리별 진행도
}
```

### 3. 서비스 계층

#### AuthService (`lib/data/services/auth_service.dart`)
인증 관련 모든 기능을 담당합니다.

**주요 메서드:**
- `signUpWithEmail()`: 이메일/비밀번호 회원가입
- `signInWithEmail()`: 이메일/비밀번호 로그인
- `signInWithGoogle()`: Google 로그인
- `signOut()`: 로그아웃
- `sendPasswordResetEmail()`: 비밀번호 재설정
- `getUserProfile()`: 사용자 프로필 조회
- `deleteAccount()`: 계정 삭제

#### FirestoreService (`lib/data/services/firestore_service.dart`)
Firestore 데이터베이스 작업을 담당합니다.

**주요 메서드:**

**사용자 프로필 관리:**
- `updateUserProfile()`: 프로필 업데이트
- `addXP()`: XP 추가 및 레벨 계산
- `updateStreak()`: 연속 학습 일수 업데이트
- `addAchievement()`: 업적 추가

**학습 진행상황:**
- `saveProgress()`: 진행상황 저장
- `getUserProgress()`: 사용자 진행상황 조회
- `recordProblemCompletion()`: 문제 완료 기록

**리더보드:**
- `getWeeklyLeaderboard()`: 주간 리더보드 조회
- `getUserRank()`: 사용자 순위 조회

### 4. Riverpod Providers (`lib/data/providers/firebase_providers.dart`)

```dart
// 서비스 제공자
final authServiceProvider
final firestoreServiceProvider

// 인증 상태
final authStateProvider        // Firebase User 스트림
final currentUserProvider      // 현재 사용자
final userProfileProvider      // Firestore UserModel 스트림
final isAuthenticatedProvider  // 로그인 여부
```

## 🔧 Firebase 설정 가이드

### 1. Firebase Console에서 프로젝트 확인 및 설정

**중요**: GCP에서 이미 프로젝트를 생성했으므로, Firebase Console에서 프로젝트를 확인하고 설정만 하면 됩니다.

1. [Firebase Console](https://console.firebase.google.com/) 접속
2. **기존 프로젝트 선택**: `mathlab-gomath` (MathLab) 선택
   - 프로젝트가 목록에 보이지 않으면 페이지 새로고침
3. Google Analytics 활성화 (선택사항)

### 2. Firebase 앱 등록

#### Android 앱 등록
1. Firebase Console > 프로젝트 설정
2. "Android 앱 추가" 클릭
3. Android 패키지 이름: `com.mathlab.app` 입력
4. `google-services.json` 다운로드
5. `android/app/` 폴더에 파일 배치

#### iOS 앱 등록
1. Firebase Console > 프로젝트 설정
2. "iOS 앱 추가" 클릭
3. iOS 번들 ID: `com.mathlab.app` 입력
4. `GoogleService-Info.plist` 다운로드
5. Xcode에서 `Runner/Runner` 폴더에 파일 추가

#### Web 앱 등록
1. Firebase Console > 프로젝트 설정
2. "웹 앱 추가" 클릭
3. 앱 닉네임: `MathLab Web` 입력
4. Firebase Hosting 설정 (선택사항)
5. 설정 정보를 `lib/firebase_options.dart`에 업데이트

### 3. Firebase Authentication 활성화

1. Firebase Console > Authentication
2. "시작하기" 클릭
3. "Sign-in method" 탭에서 다음 활성화:
   - **이메일/비밀번호**: 활성화
   - **Google**: 활성화 (프로젝트 지원 이메일 설정)
   - **Apple** (iOS용, 선택사항)

### 4. Cloud Firestore 설정

1. Firebase Console > Firestore Database
2. "데이터베이스 만들기" 클릭
3. **위치**: `asia-northeast3 (Seoul)` 선택
4. **모드**: "프로덕션 모드" 선택
5. "만들기" 클릭

#### Firestore 보안 규칙 설정

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 사용자 프로필
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    // 학습 진행상황
    match /progress/{progressId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null &&
        progressId.matches('^' + request.auth.uid + '_.*$');
    }

    // 일일 학습 기록
    match /daily_studies/{dailyId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null &&
        dailyId.matches('^' + request.auth.uid + '_.*$');
    }

    // 리더보드 (읽기 전용)
    match /leaderboard/{document=**} {
      allow read: if request.auth != null;
      allow write: if false;
    }
  }
}
```

### 5. Firebase Storage 설정 (선택사항)

1. Firebase Console > Storage
2. "시작하기" 클릭
3. 보안 규칙 설정:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 6. FlutterFire CLI로 설정 자동화

```bash
# FlutterFire CLI 설치
dart pub global activate flutterfire_cli

# Firebase 프로젝트 구성
flutterfire configure

# 선택사항:
# - 프로젝트: MathLab
# - 플랫폼: Android, iOS, Web
```

이 명령어는 자동으로:
- `lib/firebase_options.dart` 생성
- 각 플랫폼별 Firebase 설정 파일 구성

## 📁 Firestore 데이터베이스 구조

```
/users/{userId}
  - uid: string
  - email: string
  - displayName: string
  - currentGrade: string
  - totalXP: number
  - level: number
  - streak: number
  - lastStudyDate: timestamp
  - categoryXP: map
  - achievements: array
  - league: string
  - createdAt: timestamp
  - updatedAt: timestamp

/progress/{userId}_{lessonId}
  - userId: string
  - grade: string
  - chapter: string
  - lessonId: string
  - problemsCompleted: number
  - totalProblems: number
  - correctAnswers: number
  - xpEarned: number
  - isCompleted: boolean
  - completedAt: timestamp
  - createdAt: timestamp
  - updatedAt: timestamp

/daily_studies/{userId}_{YYYY-MM-DD}
  - userId: string
  - date: timestamp
  - problemsCompleted: number
  - xpEarned: number
  - studyTimeMinutes: number
  - categoryProgress: map
  - createdAt: timestamp
```

## 🔐 보안 고려사항

### 환경 변수 관리
- API 키는 절대 Git에 커밋하지 않기
- `.gitignore`에 다음 추가:
  ```
  # Firebase
  google-services.json
  GoogleService-Info.plist
  firebase_options.dart
  .env
  ```

### Firestore 보안 규칙
- 모든 읽기/쓰기 작업은 인증 필요
- 사용자는 자신의 데이터만 수정 가능
- 리더보드 등 공개 데이터는 읽기 전용

### API 키 제한
Firebase Console > 프로젝트 설정 > API 키에서:
- HTTP 리퍼러 제한 설정 (웹)
- Android 앱 서명 제한 (Android)
- iOS 번들 ID 제한 (iOS)

## 📊 사용 예시

### 회원가입

```dart
final authService = ref.read(authServiceProvider);

try {
  await authService.signUpWithEmail(
    email: 'user@example.com',
    password: 'password123',
    displayName: '홍길동',
  );
  // 회원가입 성공
} catch (e) {
  // 오류 처리
  print('회원가입 실패: $e');
}
```

### 로그인

```dart
final authService = ref.read(authServiceProvider);

try {
  await authService.signInWithEmail(
    email: 'user@example.com',
    password: 'password123',
  );
  // 로그인 성공
} catch (e) {
  // 오류 처리
  print('로그인 실패: $e');
}
```

### 문제 완료 기록

```dart
final firestoreService = ref.read(firestoreServiceProvider);
final user = ref.read(currentUserProvider);

if (user != null) {
  await firestoreService.recordProblemCompletion(
    userId: user.uid,
    grade: '중3',
    chapter: '다항식',
    lessonId: 'lesson_poly_001',
    isCorrect: true,
    xpEarned: 10,
  );
}
```

### 사용자 프로필 조회

```dart
final userProfile = ref.watch(userProfileProvider);

userProfile.when(
  data: (profile) {
    if (profile != null) {
      print('레벨: ${profile.level}');
      print('총 XP: ${profile.totalXP}');
      print('스트릭: ${profile.streak}일');
    }
  },
  loading: () => print('로딩 중...'),
  error: (error, stack) => print('오류: $error'),
);
```

## 🚀 배포 체크리스트

### 프로덕션 배포 전

- [ ] Firebase 프로젝트 생성 완료
- [ ] 모든 플랫폼 앱 등록 완료
- [ ] Authentication 설정 완료
- [ ] Firestore 데이터베이스 생성 및 보안 규칙 설정
- [ ] API 키 제한 설정
- [ ] 환경 변수 설정 완료
- [ ] `.gitignore` 설정 확인
- [ ] 테스트 계정으로 모든 기능 테스트
- [ ] 에러 핸들링 확인
- [ ] 성능 모니터링 설정 (Firebase Analytics)

## 📞 문제 해결

### Firebase 초기화 오류
```dart
[core/no-app] No Firebase App '[DEFAULT]' has been created
```
**해결**: `main.dart`에서 `Firebase.initializeApp()` 호출 확인

### Google 로그인 실패
**Android**: `google-services.json` 파일 확인
**iOS**: `GoogleService-Info.plist` 파일 및 URL Schemes 확인

### Firestore 권한 오류
```
PERMISSION_DENIED: Missing or insufficient permissions
```
**해결**: Firestore 보안 규칙 확인 및 사용자 인증 상태 확인

## 📚 추가 리소스

- [Firebase 공식 문서](https://firebase.google.com/docs)
- [FlutterFire 공식 문서](https://firebase.flutter.dev/)
- [Firestore 데이터 모델링 가이드](https://firebase.google.com/docs/firestore/data-model)
- [Firebase 보안 규칙 가이드](https://firebase.google.com/docs/rules)

---

## 🎉 완료!

이제 MathLab은 완전한 백엔드 시스템을 갖추었습니다!
- ✅ 사용자 인증 시스템
- ✅ 데이터베이스 및 데이터 모델
- ✅ 학습 진행상황 추적
- ✅ 리더보드 및 랭킹 시스템
- ✅ 게이미피케이션 요소 (XP, 레벨, 스트릭, 업적)

다음 단계: Firebase Console에서 실제 프로젝트를 생성하고 설정 파일을 업데이트하세요!
