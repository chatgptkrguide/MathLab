# 🚨 사용자 필수 작업 목록

**작성일**: 2026-01-15
**우선순위**: 높음
**예상 소요 시간**: 2-3주

---

## 📋 완료된 작업 (Claude Code)

✅ Friend 모델 photoUrl 속성 추가
✅ 13개 Repository 구현 완료 (총 21개)
✅ 기본 테스트 파일 구조 생성
✅ 코드베이스 종합 분석 보고서 작성

---

## 🔥 긴급 작업 (1주 내 완료 필수)

### 1. Firebase 프로젝트 설정 및 Firestore 데이터베이스 생성

**필요한 이유**: 모든 Repository가 Firebase Firestore를 사용하도록 구현됨

**작업 단계**:

#### 1-1. Firebase 콘솔에서 프로젝트 생성
```
https://console.firebase.google.com/
```

1. "프로젝트 추가" 클릭
2. 프로젝트 이름: `mathlab-production` (또는 원하는 이름)
3. Google Analytics 활성화 (선택사항)
4. 프로젝트 생성 완료

#### 1-2. Android 앱 등록
```
Firebase 콘솔 > 프로젝트 설정 > 앱 추가 > Android
```

- **Android 패키지 이름**: `com.mathlab.app` (android/app/build.gradle.kts 확인)
- **앱 닉네임**: MathLab
- **SHA-1 인증서** (선택사항):
  ```bash
  cd android
  ./gradlew signingReport
  ```
- `google-services.json` 다운로드
- `android/app/` 폴더에 복사

#### 1-3. iOS 앱 등록 (macOS에서만)
```
Firebase 콘솔 > 프로젝트 설정 > 앱 추가 > iOS
```

- **번들 ID**: `com.mathlab.app` (ios/Runner/Info.plist 확인)
- **앱 닉네임**: MathLab
- `GoogleService-Info.plist` 다운로드
- Xcode에서 `ios/Runner/` 폴더에 추가

#### 1-4. Firestore 데이터베이스 생성
```
Firebase 콘솔 > Firestore Database > 데이터베이스 만들기
```

- **모드**: 프로덕션 모드 시작
- **위치**: asia-northeast3 (서울)
- **보안 규칙**: 아래 규칙 적용

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 사용자 인증 체크
    function isAuthenticated() {
      return request.auth != null;
    }

    // 본인 데이터만 접근 가능
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    // Users 컬렉션
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow write: if isOwner(userId);
    }

    // Achievements
    match /achievements/{achievementId} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated();
    }

    // Leaderboard
    match /leaderboard/{userId} {
      allow read: if isAuthenticated();
      allow write: if isOwner(userId);
    }

    // Friends
    match /friends/{friendId} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated();
    }

    // Messages
    match /messages/{messageId} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated();
    }

    // 나머지 컬렉션들도 유사하게 설정
    match /{document=**} {
      allow read, write: if isAuthenticated();
    }
  }
}
```

#### 1-5. Firebase Authentication 활성화
```
Firebase 콘솔 > Authentication > 로그인 방법
```

활성화할 제공업체:
- ✅ 이메일/비밀번호
- ✅ Google (선택사항)
- ✅ Apple (iOS 필수, macOS에서만)

---

### 2. Firestore 컬렉션 및 인덱스 생성

**작업 위치**: Firebase 콘솔 > Firestore Database

#### 2-1. 필수 컬렉션 생성 (총 21개)

각 컬렉션에 테스트 문서 1개씩 수동 추가:

```
✅ users
✅ achievements
✅ leaderboard
✅ friends
✅ messages
✅ chat_rooms
✅ lessons
✅ problems
✅ wrong_answers
✅ daily_challenges
✅ daily_rewards
✅ study_sessions (history)
✅ practice_sessions
✅ level_tests
✅ academic_records
✅ course_enrollments
✅ settings
✅ leagues
✅ subscriptions
✅ weekly_tests
✅ assignments
```

#### 2-2. 복합 인덱스 생성

Firestore 콘솔에서 수동 생성 또는 앱 실행 시 자동 생성:

```javascript
// leaderboard 인덱스
컬렉션: leaderboard
필드: xp (내림차순), userId (오름차순)

// friends 인덱스
컬렉션: friends
필드: userId (오름차순), status (오름차순), acceptedAt (내림차순)

// messages 인덱스
컬렉션: messages
필드: receiverId (오름차순), isRead (오름차순), sentAt (내림차순)

// achievements 인덱스
컬렉션: achievements
필드: userId (오름차순), isUnlocked (오름차순), unlockedAt (내림차순)
```

**자동 생성 방법**:
1. 앱 실행
2. 에러 로그에서 인덱스 생성 링크 클릭
3. Firebase 콘솔에서 자동 생성

---

### 3. 초기 데이터 시딩 (테스트 데이터)

**작업 방법**: Firebase 콘솔에서 수동 입력 또는 스크립트 사용

#### 3-1. 문제 데이터 (problems 컬렉션)

최소 10개 문제 추가 예시:

```json
{
  "id": "prob_001",
  "title": "2 + 3은 무엇인가요?",
  "question": "2 + 3 =",
  "options": ["4", "5", "6", "7"],
  "correctAnswer": 1,
  "difficulty": "easy",
  "subject": "arithmetic",
  "grade": "elementary_4",
  "xpReward": 10,
  "createdAt": "2026-01-15T00:00:00.000Z"
}
```

**필요 개수**: 최소 50-100개 (과목별, 난이도별)

#### 3-2. 레슨 데이터 (lessons 컬렉션)

```json
{
  "id": "lesson_001",
  "title": "덧셈 기초",
  "description": "한 자리 수 덧셈을 배워봅시다",
  "subject": "arithmetic",
  "grade": "elementary_4",
  "order": 1,
  "problemIds": ["prob_001", "prob_002", "prob_003"],
  "isLocked": false,
  "xpReward": 50
}
```

**필요 개수**: 최소 20-30개

#### 3-3. 업적 데이터 (achievements 컬렉션)

```json
{
  "id": "ach_first_problem",
  "title": "첫 문제 해결",
  "description": "첫 번째 문제를 풀어보세요",
  "category": "problem_solving",
  "requiredProgress": 1,
  "xpReward": 10,
  "icon": "🎯"
}
```

**필요 개수**: 최소 10-15개

---

## 📱 중요 작업 (2주 내 완료)

### 4. 인앱 결제 (Premium) 설정

#### 4-1. Google Play Console 설정

```
https://play.google.com/console/
```

1. 앱 등록
2. In-app products 생성:
   - `premium_monthly` - 월간 구독 (₩9,900)
   - `premium_yearly` - 연간 구독 (₩99,000)
3. 테스트 계정 추가

#### 4-2. App Store Connect 설정 (iOS)

```
https://appstoreconnect.apple.com/
```

1. 앱 등록
2. In-App Purchase 생성
3. Subscription Group 생성
4. 테스트 계정 추가 (Sandbox)

#### 4-3. 코드에서 제품 ID 업데이트

**파일**: `lib/data/services/subscription_service.dart`

```dart
// 실제 제품 ID로 변경
static const premiumMonthlyId = 'premium_monthly';
static const premiumYearlyId = 'premium_yearly';
```

---

### 5. 푸시 알림 설정

#### 5-1. Firebase Cloud Messaging (FCM) 설정

Firebase 콘솔에서 이미 활성화되어 있음. 추가 설정 필요:

**Android**:
- `android/app/google-services.json` 확인
- 권한 이미 설정됨 ✅

**iOS**:
- APNs 인증 키 업로드:
  ```
  Firebase 콘솔 > 프로젝트 설정 > 클라우드 메시징 > APNs 인증 키
  ```
- Apple Developer에서 키 생성:
  ```
  https://developer.apple.com/account/resources/authkeys/list
  ```

#### 5-2. 테스트 알림 발송

Firebase 콘솔 > Cloud Messaging > 새 알림

---

### 6. Mock 데이터 제거 및 실제 Firebase 연동

**영향받는 파일** (총 7개):

#### 6-1. Daily Challenge 화면

**파일**: `lib/features/daily_challenge/daily_challenge_screen.dart`

**현재 코드** (Mock 데이터):
```dart
// TODO: Replace with actual data from provider
final challenges = [
  // Mock data
];
```

**수정 방법**:
```dart
// Provider에서 실제 데이터 가져오기
final challenges = ref.watch(dailyChallengeProvider);

// Repository 사용
final repository = DailyChallengeRepository();
final result = await repository.getTodayChallenge(userId);
```

#### 6-2. Messages 화면

**파일**: `lib/features/messages/messages_screen.dart`

**수정 필요**:
```dart
// Mock 데이터 제거
final messages = ref.watch(messageProvider);

// MessageRepository 사용
final repository = MessageRepository();
final inbox = await repository.getInboxMessages(userId);
```

#### 6-3. Premium 화면

**파일**: `lib/features/premium/premium_upgrade_screen.dart`

**수정 필요**:
- 실제 인앱 결제 로직 연동
- 영수증 검증 추가

#### 6-4. Wrong Answer 화면

**파일**: `lib/features/wrong_answer/wrong_answer_screen.dart`

**수정 필요**:
```dart
// WrongAnswerRepository 사용
final repository = WrongAnswerRepository();
final wrongAnswers = await repository.getUserWrongAnswers(userId);
```

#### 6-5. Problem 화면

**파일**: `lib/features/problem/problem_screen.dart`

**수정 필요**:
```dart
// ProblemRepository 사용
final repository = ProblemRepository();
final problem = await repository.getById(problemId);
```

---

## 🎨 선택 작업 (3-4주 내)

### 7. 미구현 화면 개발

#### 7-1. Academic Records (학업 기록) 화면

**새로 생성할 파일**:
```
lib/features/academic_records/
├── academic_records_screen.dart
├── widgets/
│   ├── grade_card.dart
│   └── subject_stats.dart
```

**Repository**: `AcademicRecordRepository` (이미 구현됨 ✅)

#### 7-2. Course Enrollment (과정 등록) 화면

**새로 생성할 파일**:
```
lib/features/course_enrollment/
├── course_enrollment_screen.dart
├── course_list_screen.dart
├── widgets/
│   ├── course_card.dart
│   └── enrollment_status.dart
```

**Repository**: `CourseEnrollmentRepository` (이미 구현됨 ✅)

#### 7-3. League Tier (리그 티어) 화면

**새로 생성할 파일**:
```
lib/features/league_tier/
├── league_tier_screen.dart
├── widgets/
│   ├── tier_badge.dart
│   └── promotion_progress.dart
```

**필요한 작업**: League 관련 UI 구현

#### 7-4. Problem Management (문제 관리) 화면

**새로 생성할 파일**:
```
lib/features/problem_management/
├── problem_management_screen.dart (관리자 전용)
├── widgets/
│   ├── problem_list.dart
│   └── problem_editor.dart
```

**보안**: 관리자 권한 체크 필요

---

### 8. 고급 기능 구현

#### 8-1. 드래그 앤 드롭 문제 유형

**참고 패키지**: `flutter_draggable_gridview`

**구현 위치**: `lib/features/problem/widgets/drag_drop_problem.dart`

#### 8-2. 손글씨 인식 (선택사항)

**참고 패키지**: `google_mlkit_digital_ink_recognition`

**구현 위치**: `lib/features/problem/widgets/handwriting_input.dart`

#### 8-3. 실시간 채팅

**Firebase Realtime Database** 또는 **Firestore 실시간 리스너** 사용

**구현 위치**: `lib/features/chat/chat_detail_screen.dart`

---

## 🧪 테스트 작업

### 9. 단위 테스트 작성

**위치**: `test/` 폴더

**우선순위 높은 테스트**:

1. **Repository 테스트** (Firebase Emulator 사용)
   ```bash
   # Firebase Emulator 설치
   firebase init emulators

   # Firestore, Auth Emulator 선택
   # 테스트 실행
   flutter test
   ```

2. **Model 테스트** (이미 시작됨 ✅)
   - `test/models/friend_test.dart` 확장
   - 다른 모델 테스트 추가

3. **Provider 테스트**
   ```dart
   // test/providers/user_provider_test.dart
   test('UserProvider should update state', () {
     // ...
   });
   ```

**목표**: 80% 코드 커버리지

---

### 10. 통합 테스트

**위치**: `integration_test/` 폴더

**주요 시나리오**:
1. 회원가입 → 로그인 → 문제 풀이
2. 친구 추가 → 메시지 전송
3. 리그 진입 → 순위 확인

---

## 📊 진행상황 체크리스트

### Phase 1: Firebase 설정 (1주)
- [ ] Firebase 프로젝트 생성
- [ ] Android 앱 등록 (`google-services.json`)
- [ ] iOS 앱 등록 (`GoogleService-Info.plist`)
- [ ] Firestore 데이터베이스 생성
- [ ] Authentication 활성화
- [ ] 21개 컬렉션 생성
- [ ] 복합 인덱스 생성
- [ ] 초기 테스트 데이터 시딩

### Phase 2: 핵심 기능 연동 (1주)
- [ ] Mock 데이터 제거 (7개 파일)
- [ ] Repository 연동 테스트
- [ ] 로그인/회원가입 테스트
- [ ] 문제 풀이 테스트
- [ ] 친구 추가 테스트

### Phase 3: 인앱 결제 & 푸시 알림 (1주)
- [ ] Google Play In-App Products 설정
- [ ] App Store In-App Purchase 설정
- [ ] 결제 테스트 (Sandbox)
- [ ] FCM 푸시 알림 테스트
- [ ] APNs 설정 (iOS)

### Phase 4: 미구현 화면 (2주)
- [ ] Academic Records 화면
- [ ] Course Enrollment 화면
- [ ] League Tier 화면
- [ ] Problem Management 화면 (관리자)

### Phase 5: 테스트 (1주)
- [ ] 단위 테스트 (80% 커버리지)
- [ ] 통합 테스트
- [ ] E2E 테스트

---

## 🔗 유용한 링크

### Firebase
- **콘솔**: https://console.firebase.google.com/
- **문서**: https://firebase.google.com/docs/flutter/setup
- **Firestore 규칙**: https://firebase.google.com/docs/firestore/security/get-started

### Google Play
- **콘솔**: https://play.google.com/console/
- **In-App 결제**: https://developer.android.com/google/play/billing

### App Store
- **콘솔**: https://appstoreconnect.apple.com/
- **In-App Purchase**: https://developer.apple.com/in-app-purchase/

### Flutter 패키지
- **firebase_core**: https://pub.dev/packages/firebase_core
- **cloud_firestore**: https://pub.dev/packages/cloud_firestore
- **firebase_auth**: https://pub.dev/packages/firebase_auth
- **in_app_purchase**: https://pub.dev/packages/in_app_purchase

---

## 💡 도움말

### Firebase Emulator 로컬 테스트

```bash
# Firebase CLI 설치
npm install -g firebase-tools

# 로그인
firebase login

# Emulator 초기화
firebase init emulators

# Emulator 실행
firebase emulators:start

# Flutter 테스트 실행
flutter test
```

### 빠른 데이터 시딩 스크립트 (Node.js)

```javascript
// scripts/seed_data.js
const admin = require('firebase-admin');

admin.initializeApp();
const db = admin.firestore();

async function seedProblems() {
  const problems = [
    {
      id: 'prob_001',
      title: '2 + 3은 무엇인가요?',
      // ...
    },
    // 더 많은 문제들
  ];

  for (const problem of problems) {
    await db.collection('problems').doc(problem.id).set(problem);
  }
  console.log('✅ Problems seeded');
}

seedProblems();
```

---

## ⚠️ 주의사항

1. **Firebase 프로젝트 생성 필수**: 앱이 실행되려면 Firebase 설정이 완료되어야 함
2. **google-services.json 누락 시 빌드 에러**: Android 빌드 전에 반드시 추가
3. **Firestore 규칙 설정**: 프로덕션 배포 전에 보안 규칙 반드시 설정
4. **인앱 결제 테스트**: 실제 결제 전에 Sandbox 환경에서 충분히 테스트

---

**예상 총 작업 시간**: 2-3주 (1명 풀타임 기준)
**최종 완성도**: 95% (이 작업 완료 시)

**작성자**: Claude Code
**최종 업데이트**: 2026-01-15
