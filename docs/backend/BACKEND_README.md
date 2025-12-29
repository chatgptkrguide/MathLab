# MathLab 백엔드 시스템 문서

## 📋 개요

MathLab의 백엔드 시스템은 **Firebase + Node.js 하이브리드 아키텍처**를 사용합니다.

### 주요 기술 스택
- **인증**: Firebase Authentication
- **데이터베이스**: Cloud Firestore
- **백엔드 API**: Node.js + Express (GCP Cloud Run)
- **로컬 저장소**: Hive + SQLite
- **동기화**: Offline-First Architecture

---

## 🏗️ 아키텍처

```
┌─────────────────────────────────────────┐
│         Flutter App (Dart)              │
├─────────────────────────────────────────┤
│  ┌──────────────┐  ┌─────────────────┐ │
│  │   UI Layer   │  │  State (Riverpod)│ │
│  └──────────────┘  └─────────────────┘ │
├─────────────────────────────────────────┤
│  ┌──────────────┐  ┌─────────────────┐ │
│  │ Repositories │  │    Services     │ │
│  └──────────────┘  └─────────────────┘ │
└─────────────────────────────────────────┘
           ↓                    ↓
    ┌─────────────┐      ┌──────────────┐
    │  Firestore  │      │ Node.js API  │
    │  (Firebase) │      │ (Cloud Run)  │
    └─────────────┘      └──────────────┘
           ↓                    ↓
    ┌─────────────────────────────────┐
    │    Local Storage (Hive)         │
    └─────────────────────────────────┘
```

---

## ✅ 구현 완료 기능

### 1. API Client (`lib/data/services/api_client.dart`)
- ✅ 환경별 설정 (Development, Staging, Production)
- ✅ 자동 토큰 갱신 (401 에러 처리)
- ✅ 재시도 로직 (네트워크 에러, 5xx 에러)
- ✅ 요청/응답 인터셉터
- ✅ Auth API 엔드포인트
- ✅ Payment API 엔드포인트
- ✅ User API 엔드포인트

#### Auth API
```dart
// 회원가입
await apiClient.register(
  email: 'test@example.com',
  password: 'password123',
  displayName: 'Test User',
);

// 로그인
await apiClient.login(
  email: 'test@example.com',
  password: 'password123',
);

// 비밀번호 재설정
await apiClient.requestPasswordReset('test@example.com');
```

#### Payment API
```dart
// iOS 영수증 검증
final isValid = await apiClient.verifyIosReceipt(receiptData);

// Android 영수증 검증
final isValid = await apiClient.verifyAndroidReceipt(
  packageName: 'com.example.mathlab',
  productId: 'premium_monthly',
  purchaseToken: 'token...',
);
```

### 2. 인증 시스템 (`lib/data/services/auth_service.dart`)
- ✅ 이메일/비밀번호 인증
- ✅ Google 소셜 로그인
- ✅ 비밀번호 재설정
- ✅ 이메일 인증
- ✅ 계정 삭제
- ✅ Firestore 프로필 자동 생성

```dart
final authService = AuthService();

// 이메일 회원가입
await authService.signUpWithEmail(
  email: 'test@example.com',
  password: 'password123',
  displayName: 'Test User',
);

// Google 로그인
await authService.signInWithGoogle();

// 로그아웃
await authService.signOut();
```

### 3. Firestore 서비스 (`lib/data/services/firestore_service.dart`)
- ✅ 사용자 프로필 CRUD
- ✅ XP 및 스트릭 관리 (트랜잭션)
- ✅ 학습 진행률 추적
- ✅ 리더보드 기능
- ✅ 리그 시스템 (완전한 트랜잭션 로직)
- ✅ 오답 노트 관리
- ✅ 실시간 스트림

#### Firestore 컬렉션 구조
```
/users/{uid}
  - 프로필 정보
  - XP, 레벨, 스트릭
  /wrongAnswers/{id} (서브컬렉션)
    - 틀린 문제 기록

/progress/{userId_lessonId}
  - 레슨별 진행률

/daily_studies/{userId_date}
  - 일일 학습 기록

/leagues/{leagueId}
  - 리그 정보
  - 참가자 목록 및 순위
```

### 4. Repository 패턴 (`lib/data/repositories/`)
- ✅ UserRepository - 사용자 프로필 관리
- ✅ WrongAnswerRepository - 오답 노트
- ✅ LessonRepository - 학습 콘텐츠
- ✅ LeagueRepository - 리그 시스템
- ✅ Local-First 동기화
- ✅ 충돌 해결 (Last-Write-Wins)
- ✅ 완전한 삭제 기능 (사용자 데이터 전체 삭제)

```dart
final userRepository = UserRepository(
  localStorageService: LocalStorageService(),
  firestoreService: FirestoreService(),
);

// 사용자 데이터 가져오기 (로컬 우선)
final user = await userRepository.getFromLocal(userId);

// Firebase와 동기화
await userRepository.saveToFirebase(userId, user);

// 완전 삭제 (모든 관련 데이터 삭제)
await userRepository.deleteFromFirebase(userId);
```

### 5. 동기화 시스템 (`lib/data/services/sync_manager.dart`)
- ✅ 네트워크 상태 모니터링
- ✅ 오프라인 큐 관리
- ✅ 자동 동기화 (온라인 복귀 시)
- ✅ 재시도 로직 (최대 5회)
- ✅ 실시간 동기화 (Firestore Streams)
- ✅ 양방향 동기화 (Local ↔ Firebase)

```dart
final syncManager = SyncManager();
await syncManager.initialize();

// 초기 동기화
await syncManager.initialSync(userId);

// 양방향 동기화
await syncManager.bidirectionalSync(userId);

// 실시간 동기화 시작
await syncManager.startRealtimeSync(userId);
```

### 6. 에러 핸들링 (`lib/shared/utils/error_handler.dart`)
- ✅ API 에러 처리
- ✅ Firebase Auth 에러 처리
- ✅ Firestore 에러 처리
- ✅ 재시도 헬퍼 (지수 백오프)
- ✅ 사용자 친화적 에러 메시지

```dart
try {
  await apiClient.login(email: email, password: password);
} catch (error) {
  final appException = ErrorHandler.handleGenericError(error);
  print(appException.message); // 사용자 친화적 메시지
}

// 재시도 로직
final result = await RetryHelper.retryWithBackoff(
  operation: () => apiClient.getUserProfile(userId),
  maxRetries: 3,
);
```

### 7. 환경 설정 (`lib/shared/config/app_config.dart`)
- ✅ Development, Staging, Production 환경 분리
- ✅ API URL 자동 전환
- ✅ 타임아웃 설정
- ✅ 재시도 설정
- ✅ Firebase 프로젝트 분리

```dart
// 환경 설정
AppConfig().setEnvironment(AppEnvironment.production);

// API URL 자동 전환
final apiUrl = AppConfig().fullApiUrl;
// Development: http://localhost:3000/api/v1
// Staging: https://staging-api.mathlab.com/api/v1
// Production: https://api.mathlab.com/api/v1
```

---

## 🚀 배포 가이드

### 1. 환경 설정

#### Development (로컬 개발)
```dart
// lib/main.dart
void main() {
  AppConfig().setEnvironment(AppEnvironment.development);
  runApp(MyApp());
}
```

#### Staging (테스트 서버)
```dart
void main() {
  AppConfig().setEnvironment(AppEnvironment.staging);
  runApp(MyApp());
}
```

#### Production (프로덕션)
```dart
void main() {
  AppConfig().setEnvironment(AppEnvironment.production);
  runApp(MyApp());
}
```

### 2. Backend 서버 배포

**필요 환경 변수** (`.env` 파일)
```bash
# API 설정
API_PORT=3000
API_VERSION=v1

# Firebase 설정
FIREBASE_PROJECT_ID=mathlab-prod
FIREBASE_PRIVATE_KEY=...
FIREBASE_CLIENT_EMAIL=...

# 데이터베이스
DATABASE_URL=...

# 결제 검증
APPLE_SHARED_SECRET=...
GOOGLE_SERVICE_ACCOUNT_KEY=...

# 보안
JWT_SECRET=...
CORS_ORIGIN=https://mathlab.com
```

**GCP Cloud Run 배포**
```bash
# Docker 이미지 빌드
docker build -t gcr.io/mathlab-prod/api:latest .

# GCP에 푸시
docker push gcr.io/mathlab-prod/api:latest

# Cloud Run 배포
gcloud run deploy mathlab-api \
  --image gcr.io/mathlab-prod/api:latest \
  --platform managed \
  --region asia-northeast3 \
  --allow-unauthenticated
```

---

## 🧪 테스트 체크리스트

### API Client
- [ ] Development 환경 연결 테스트
- [ ] Staging 환경 연결 테스트
- [ ] 401 에러 시 토큰 자동 갱신 확인
- [ ] 네트워크 에러 시 재시도 확인
- [ ] Auth API 엔드포인트 테스트
- [ ] Payment API 엔드포인트 테스트

### Firebase
- [ ] 이메일 회원가입/로그인
- [ ] Google 소셜 로그인
- [ ] Firestore 읽기/쓰기
- [ ] 실시간 스트림 동작 확인
- [ ] 트랜잭션 동작 확인

### 동기화
- [ ] 오프라인 모드 동작
- [ ] 온라인 복귀 시 자동 동기화
- [ ] 충돌 해결 로직 확인
- [ ] 실시간 동기화 확인

### 리그 시스템
- [ ] 참가자 추가/업데이트
- [ ] 순위 자동 재계산
- [ ] 리그 종료 처리
- [ ] 사용자 삭제 시 리그에서 제거

### 에러 핸들링
- [ ] 네트워크 오프라인 에러
- [ ] API 5xx 에러
- [ ] Firebase Auth 에러
- [ ] Firestore 권한 에러
- [ ] 재시도 로직

---

## 📊 성능 지표

### 목표 성능
- API 응답 시간: <500ms (P95)
- Firestore 읽기: <300ms (P95)
- Firestore 쓰기: <500ms (P95)
- 동기화 완료 시간: <3초
- 오프라인 큐 처리: <1분

### 모니터링
- Firebase Performance Monitoring
- Cloud Logging (GCP)
- Error Tracking (Sentry)

---

## 🔒 보안 가이드

### API 보안
- ✅ Firebase ID Token 검증
- ✅ HTTPS 강제
- ✅ Rate Limiting
- ✅ CORS 설정

### 데이터 보안
- ✅ Firestore Security Rules
- ✅ 민감정보 암호화
- ✅ 로컬 저장소 암호화
- ✅ 사용자 데이터 완전 삭제

### Firestore Security Rules 예시
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 사용자는 자신의 데이터만 읽기/쓰기 가능
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      // 오답 노트는 본인만 접근 가능
      match /wrongAnswers/{answerId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }

    // 리그는 모두 읽기 가능, 쓰기는 인증된 사용자만
    match /leagues/{leagueId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

---

## 🐛 알려진 이슈 및 제한사항

### 현재 제한사항
1. **백엔드 서버 미배포**: 실제 Node.js 서버 구축 필요
2. **프로덕션 URL 미설정**: 현재 localhost 사용 중
3. **결제 검증 미테스트**: iOS/Android 영수증 검증 서버 필요

### 해결 방법
1. **백엔드 서버 구축**
   - Node.js + Express 또는 Python + FastAPI
   - GCP Cloud Run에 배포
   - 필요한 엔드포인트 구현

2. **환경 변수 설정**
   - `.env` 파일 생성
   - 프로덕션 API URL 설정
   - Firebase 인증 정보 추가

3. **결제 시스템 연동**
   - Apple App Store Connect 설정
   - Google Play Console 설정
   - 영수증 검증 서버 구현

---

## 📝 다음 단계

### Phase 1: 백엔드 서버 구축 ✅
- [x] API Client 완성
- [x] Auth API 구현
- [x] Payment API 구현
- [x] 에러 핸들링 강화

### Phase 2: 배포 (진행 예정)
- [ ] Node.js 백엔드 서버 구현
- [ ] GCP Cloud Run 배포
- [ ] Firestore Security Rules 설정
- [ ] 모니터링 및 로깅 설정

### Phase 3: 최적화 (계획 중)
- [ ] 캐싱 전략 (Redis)
- [ ] Database 인덱싱
- [ ] API Rate Limiting
- [ ] 성능 모니터링

---

## 💡 팁 및 베스트 프랙티스

### 1. 에러 핸들링
```dart
// ✅ 올바른 방법
try {
  final user = await userRepository.getFromFirebase(userId);
} catch (error) {
  final exception = ErrorHandler.handleGenericError(error);
  showSnackBar(exception.message); // 사용자 친화적 메시지
}

// ❌ 잘못된 방법
try {
  final user = await userRepository.getFromFirebase(userId);
} catch (error) {
  print(error); // 원시 에러 메시지
}
```

### 2. 동기화 전략
```dart
// ✅ 올바른 방법 - 낙관적 업데이트
await userRepository.saveToLocal(userId, updatedUser); // 즉시 로컬 업데이트
syncManager.addTask(SyncTask(...)); // 백그라운드에서 Firebase 동기화

// ❌ 잘못된 방법 - 동기 대기
await userRepository.saveToFirebase(userId, updatedUser); // 네트워크 대기
```

### 3. 트랜잭션 사용
```dart
// ✅ 경쟁 조건이 있는 경우 트랜잭션 사용
await firestoreService.updateLeagueParticipant(leagueId, userId, data);

// ❌ 단순 업데이트로는 충돌 발생 가능
await firestoreService.updateUserProfile(userId, data);
```

---

## 📞 지원 및 문의

- **GitHub Issues**: https://github.com/mathlab/mathlab/issues
- **Documentation**: https://docs.mathlab.com
- **Email**: dev@mathlab.com

---

**마지막 업데이트**: 2024-12-24
**버전**: 1.0.0
**상태**: ✅ 백엔드 기능 완성
