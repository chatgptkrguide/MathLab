# 🏗️ MathLab 백엔드 강화 마스터 플랜

> **작성일**: 2024-12-18
> **목표**: MathLab 앱의 완전한 백엔드 시스템 구축

## 📊 현재 상태 분석

### ✅ 완성된 것
- Flutter 프론트엔드 UI/UX (거의 100%)
- 로컬 데이터 관리 시스템
- 문제 풀이 로직
- 게이미피케이션 시스템 (로컬)

### ❌ 미구현된 것
- Firebase Authentication 연동
- Firestore 데이터베이스 동기화
- Cloud Functions (서버 로직)
- Firebase Storage (파일 업로드)
- FCM Push Notifications
- 실시간 데이터 업데이트
- 보안 규칙 및 최적화

---

## 🎯 백엔드 아키텍처

```
Flutter App (Frontend)
        ↓
Firebase SDK
        ↓
┌───────────────────────────────┐
│   Firebase Backend            │
├───────────────────────────────┤
│ • Authentication              │
│ • Cloud Firestore             │
│ • Cloud Functions             │
│ • Cloud Storage               │
│ • Cloud Messaging (FCM)       │
│ • Performance Monitoring      │
│ • Crashlytics                 │
└───────────────────────────────┘
```

---

## 📋 Phase 별 구현 계획

### **Phase 1: Firebase 인프라 구축** (Week 1)

#### 1.1 Firebase 프로젝트 초기 설정
- [ ] Firebase Console에서 프로젝트 생성
- [ ] Flutter 앱에 Firebase 추가 (iOS, Android, Web)
- [ ] FlutterFire CLI 설치 및 구성
- [ ] 환경별 설정 (Dev, Staging, Production)

**예상 시간**: 2-3시간

#### 1.2 Firestore 데이터베이스 스키마 설계
```
users/
  {userId}/
    - profile (UserProfile)
    - stats (UserStats)
    - settings (UserSettings)
    - progress/{lessonId} (LessonProgress)
    - wrongAnswers/{problemId} (WrongAnswer)

lessons/
  {lessonId}/
    - metadata (LessonMetadata)
    - problems/{problemId} (Problem)

leagues/
  {leagueId}/
    - info (LeagueInfo)
    - participants/{userId} (Participant)

messages/
  {conversationId}/
    - info (ConversationInfo)
    - messages/{messageId} (Message)
```

**예상 시간**: 4-6시간

---

### **Phase 2: Authentication 시스템** (Week 1-2)

#### 2.1 Firebase Authentication 구현
- [ ] 이메일/비밀번호 회원가입
- [ ] 이메일/비밀번호 로그인
- [ ] Google Sign-In
- [ ] Apple Sign-In
- [ ] Anonymous Login (게스트)
- [ ] 비밀번호 재설정
- [ ] 이메일 인증

**파일**:
- `lib/data/services/firebase_auth_service.dart` (강화)
- `lib/data/repositories/auth_repository.dart` (신규)

**예상 시간**: 6-8시간

#### 2.2 사용자 프로필 관리
- [ ] 회원가입 시 Firestore 문서 자동 생성
- [ ] 프로필 실시간 동기화
- [ ] 프로필 사진 업로드

**Cloud Function**:
```javascript
exports.onUserCreate = functions.firestore
  .document('users/{userId}')
  .onCreate(async (snap, context) => {
    // 초기 데이터 생성
    // 환영 알림 전송
  });
```

**예상 시간**: 4-5시간

---

### **Phase 3: Cloud Functions 개발** (Week 2-3)

#### 3.1 핵심 Functions 목록

**사용자 관리**:
- `onUserCreate`: 사용자 생성 시 초기 데이터 설정
- `onUserUpdate`: 프로필 업데이트 처리
- `deleteUserAccount`: 계정 삭제 및 데이터 정리

**학습 진행**:
- `updateUserXP`: XP 추가 및 레벨업 체크
- `completeLessonProgress`: 레슨 완료 처리
- `updateDailyGoal`: 일일 목표 진행도 업데이트

**리그 시스템**:
- `calculateWeeklyLeague`: 주간 리그 순위 계산
- `updateLeagueRanking`: 실시간 순위 업데이트
- `handlePromotion`: 승급/강등 처리

**소셜 기능**:
- `sendFriendRequest`: 친구 요청 전송
- `acceptFriendRequest`: 친구 요청 수락
- `sendMessage`: 메시지 전송 및 알림

**보상 시스템**:
- `claimDailyReward`: 일일 보상 수령
- `unlockBadge`: 뱃지 언락 체크
- `calculateStreakBonus`: 스트릭 보너스 계산

**알림**:
- `scheduleStudyReminder`: 학습 리마인더 스케줄링
- `sendLeagueUpdate`: 리그 업데이트 알림
- `sendFriendActivity`: 친구 활동 알림

**예상 시간**: 15-20시간

---

### **Phase 4: Storage & 파일 업로드** (Week 3)

#### 4.1 Firebase Storage 구조
```
/users/{userId}/
  /profile/
    - avatar.jpg
  /assignments/{assignmentId}/
    - photo_001.jpg
  /weekly_tests/{testId}/
    - omr.jpg
```

#### 4.2 파일 업로드 서비스 구현
- [ ] 이미지 압축 (`flutter_image_compress`)
- [ ] 업로드 진행률 추적
- [ ] 에러 핸들링 및 재시도
- [ ] 파일 삭제 기능

**파일**:
- `lib/data/services/file_upload_service.dart` (강화)
- `lib/data/services/image_compression_service.dart` (신규)

**예상 시간**: 6-8시간

---

### **Phase 5: 실시간 동기화** (Week 4)

#### 5.1 SyncManager 강화
- [ ] 온라인/오프라인 상태 감지
- [ ] 로컬 ↔ 서버 양방향 동기화
- [ ] 충돌 해결 (Conflict Resolution)
- [ ] 백그라운드 동기화

**파일**:
- `lib/data/services/sync_manager.dart` (강화)
- `lib/data/repositories/study_history_repository.dart` (신규)

**예상 시간**: 8-10시간

#### 5.2 Firestore 실시간 리스너
- [ ] 리그 순위 실시간 업데이트
- [ ] 친구 활동 상태 스트림
- [ ] 새 메시지 실시간 수신
- [ ] StreamProvider 구현

**파일**:
- `lib/data/providers/league_provider.dart` (강화)
- `lib/data/providers/friends_provider.dart` (신규)

**예상 시간**: 6-8시간

---

### **Phase 6: Push Notifications (FCM)** (Week 4-5)

#### 6.1 FCM 설정 및 구현
- [ ] FCM 토큰 발급 및 저장
- [ ] 포그라운드/백그라운드 알림 처리
- [ ] 알림 클릭 시 라우팅
- [ ] 알림 스케줄링

**알림 유형**:
- 학습 리마인더 (일일 목표)
- 스트릭 경고
- 친구 활동
- 리그 업데이트
- 메시지 수신
- 일일 보상 알림

**파일**:
- `lib/data/services/notification_service.dart` (강화)
- `functions/src/notifications.ts` (신규)

**예상 시간**: 8-10시간

---

### **Phase 7: 보안 및 최적화** (Week 5)

#### 7.1 Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }

    match /lessons/{lessonId} {
      allow read: if request.auth != null;
      allow write: if request.auth.token.admin == true;
    }
  }
}
```

#### 7.2 Storage Security Rules
```javascript
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth.uid == userId
                         && request.resource.size < 10 * 1024 * 1024;
    }
  }
}
```

#### 7.3 인덱스 최적화
- [ ] 리그 순위 쿼리 인덱스
- [ ] 메시지 시간순 정렬 인덱스
- [ ] 진행도 날짜별 인덱스

**예상 시간**: 4-6시간

---

### **Phase 8: 통합 테스트 및 배포** (Week 6)

#### 8.1 통합 테스트
- [ ] Authentication 플로우 테스트
- [ ] 데이터 동기화 테스트
- [ ] 실시간 기능 테스트
- [ ] Cloud Functions 테스트

#### 8.2 성능 최적화
- [ ] Firestore 쿼리 최적화
- [ ] 이미지 압축 및 캐싱
- [ ] 오프라인 지속성 설정
- [ ] 페이지네이션 구현

#### 8.3 모니터링 설정
- [ ] Firebase Performance Monitoring
- [ ] Crashlytics
- [ ] Analytics 이벤트 설정

**예상 시간**: 10-15시간

---

## 🛠️ 기술 스택

### Backend Infrastructure
- Firebase Authentication
- Cloud Firestore
- Cloud Functions (Node.js 18, TypeScript)
- Firebase Storage
- Firebase Cloud Messaging
- Firebase Performance Monitoring
- Firebase Crashlytics
- Firebase Analytics

### Development Tools
- Firebase CLI
- FlutterFire CLI
- Firebase Emulator Suite
- Postman (API 테스트)

### Flutter Dependencies
```yaml
dependencies:
  firebase_core: ^2.24.0
  firebase_auth: ^4.15.0
  cloud_firestore: ^4.13.0
  firebase_storage: ^11.5.0
  firebase_messaging: ^14.7.0
  firebase_analytics: ^10.7.0
  firebase_crashlytics: ^3.4.0
  firebase_performance: ^0.9.3+0
  flutter_image_compress: ^2.1.0
```

---

## 📅 전체 타임라인

| 주차 | Phase | 작업 내용 | 예상 시간 |
|------|-------|-----------|-----------|
| Week 1 | Phase 1-2 | Firebase 설정 + Auth | 14-17시간 |
| Week 2 | Phase 3 | Cloud Functions (1차) | 15-20시간 |
| Week 3 | Phase 3-4 | Cloud Functions (2차) + Storage | 12-15시간 |
| Week 4 | Phase 5-6 | 실시간 동기화 + FCM | 14-18시간 |
| Week 5 | Phase 7 | 보안 + 최적화 | 8-12시간 |
| Week 6 | Phase 8 | 테스트 + 배포 | 10-15시간 |

**총 예상 시간: 73-97시간 (약 2개월)**

---

## 🚀 시작 준비

### 사전 준비물
- [ ] Firebase 계정
- [ ] Google Cloud Platform 계정
- [ ] 결제 카드 등록 (Cloud Functions 사용)
- [ ] Apple Developer 계정 (iOS Push 알림)
- [ ] Google Cloud Console 프로젝트

### 개발 환경
- [ ] Node.js 18 설치
- [ ] Firebase CLI 설치
- [ ] FlutterFire CLI 설치
- [ ] VS Code Firebase Extension

---

## 📞 다음 단계

이제 **Phase 1: Firebase 인프라 구축**부터 시작하겠습니다!

1. Firebase 프로젝트 생성
2. Flutter 앱 연동
3. Firestore 스키마 설계

준비되면 시작하겠습니다! 🚀
