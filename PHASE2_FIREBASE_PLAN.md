# Phase 2: Firebase/Backend 연동 설계 문서

## 📋 목표

Phase 1에서 구현한 로컬 스토리지 기반 멀티테넌트 시스템을 Firebase와 연동하여 클라우드 동기화 및 멀티 디바이스 지원을 구현합니다.

## 🎯 핵심 기능

### 1. Firebase Authentication
- **이메일/비밀번호 로그인**: 기존 이메일 기반에 비밀번호 추가
- **소셜 로그인**: Google, Kakao, Apple 실제 연동
- **계정 연결**: 게스트 → 정식 계정 전환 시 Firebase UID 연결
- **세션 관리**: Firebase Auth State 기반 자동 로그인

### 2. Firestore 데이터 동기화
- **사용자 프로필**: UserModel → Firestore `users/{uid}` 컬렉션
- **학습 데이터**: 오답 노트, 학습 기록, 업적 등
- **리그/친구 데이터**: 실시간 동기화
- **메시지 시스템**: Cloud Messaging 연동

### 3. 하이브리드 저장 시스템
- **로컬 우선**: 빠른 응답을 위해 로컬 스토리지 먼저 사용
- **백그라운드 동기화**: 네트워크 상태에 따라 자동 동기화
- **충돌 해결**: Timestamp 기반 최신 데이터 우선
- **오프라인 모드**: 네트워크 없이도 정상 동작

### 4. 멀티 디바이스 지원
- **디바이스 간 동기화**: 같은 계정을 여러 디바이스에서 사용
- **실시간 업데이트**: Firestore 스냅샷 리스너
- **충돌 방지**: 낙관적 동시성 제어

---

## 🏗️ 아키텍처 설계

### 데이터 흐름

```
사용자 액션
    ↓
Provider (State Management)
    ↓
Repository Layer (데이터 추상화)
    ├─→ LocalStorageService (로컬 우선)
    │       ↓ 동기화 필요 시
    └─→ FirebaseService (클라우드 백업)
            ↓
        Firestore / Firebase Auth
```

### Repository 패턴 도입

**현재 (Phase 1)**:
```dart
Provider → LocalStorageService
```

**Phase 2**:
```dart
Provider → Repository → {
  LocalStorageService (빠른 응답)
  FirebaseService (클라우드 동기화)
}
```

---

## 📐 Firestore 데이터 구조

### Users 컬렉션

```
users/{uid}
  ├─ email: string
  ├─ displayName: string
  ├─ grade: string
  ├─ accountType: string
  ├─ photoUrl: string?
  ├─ createdAt: timestamp
  ├─ updatedAt: timestamp
  ├─ deviceIds: array<string>  // 등록된 디바이스 목록
  └─ syncStatus: {
       lastSyncAt: timestamp
       isPending: boolean
     }
```

### WrongAnswers 서브컬렉션

```
users/{uid}/wrongAnswers/{wrongAnswerId}
  ├─ problemId: string
  ├─ selectedAnswerIndex: number?
  ├─ timestamp: timestamp
  ├─ reviewCount: number
  ├─ lastReviewDate: timestamp?
  ├─ isMastered: boolean
  └─ syncedAt: timestamp
```

### StudyHistory 서브컬렉션

```
users/{uid}/studyHistory/{historyId}
  ├─ date: timestamp
  ├─ problemsSolved: number
  ├─ correctAnswers: number
  ├─ xpEarned: number
  ├─ category: string
  └─ syncedAt: timestamp
```

### League 데이터

```
leagues/{leagueId}
  ├─ tier: string
  ├─ weekStartDate: timestamp
  ├─ weekEndDate: timestamp
  ├─ participants: array<{
       userId: string
       userName: string
       weeklyXp: number
       rank: number
       badges: array<string>
     }>
  └─ updatedAt: timestamp

users/{uid}/leagueStatus
  ├─ currentLeagueId: string
  ├─ currentTier: string
  ├─ weeklyXp: number
  └─ lastUpdatedAt: timestamp
```

---

## 🔄 동기화 전략

### 1. 동기화 시점

**자동 동기화**:
- 앱 시작 시
- 네트워크 상태 변경 시 (오프라인 → 온라인)
- 중요한 데이터 변경 시 (사용자 프로필, 학습 완료 등)

**수동 동기화**:
- 사용자가 pull-to-refresh 제스처 사용
- 설정에서 "지금 동기화" 버튼

### 2. 충돌 해결 정책

**Last-Write-Wins (LWW)**:
- `updatedAt` 타임스탬프가 더 최신인 데이터 사용
- 대부분의 단순 데이터에 적용

**Merge Strategy**:
- 오답 노트: 양쪽 데이터 병합 (중복 제거)
- 학습 기록: 누적 합산

**Server-Wins**:
- 리그 순위: 서버 데이터 우선
- 친구 목록: 서버 데이터 우선

### 3. 오프라인 큐

```dart
class SyncQueue {
  List<SyncTask> pendingTasks = [];

  Future<void> addTask(SyncTask task) async {
    pendingTasks.add(task);
    await _saveToDisk();

    // 네트워크 있으면 즉시 실행
    if (await _isOnline()) {
      await _processTasks();
    }
  }

  Future<void> _processTasks() async {
    for (final task in pendingTasks) {
      try {
        await task.execute();
        pendingTasks.remove(task);
      } catch (e) {
        Logger.error('Sync failed: $e');
        // 재시도 로직
      }
    }
    await _saveToDisk();
  }
}
```

---

## 🔐 보안 규칙

### Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // 사용자는 자신의 데이터만 읽기/쓰기 가능
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      // 서브컬렉션도 동일한 규칙
      match /wrongAnswers/{wrongAnswerId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }

      match /studyHistory/{historyId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }

    // 리그는 모든 인증된 사용자가 읽기 가능
    match /leagues/{leagueId} {
      allow read: if request.auth != null;
      allow write: if false;  // 서버 함수만 쓰기 가능
    }
  }
}
```

---

## 🛠️ 구현 단계

### Step 1: Firebase 프로젝트 설정
- [ ] Firebase Console에서 프로젝트 생성
- [ ] FlutterFire CLI로 프로젝트 구성
- [ ] `google-services.json` 및 `GoogleService-Info.plist` 추가
- [ ] Firebase 초기화 코드 작성

### Step 2: Firebase Authentication 구현
- [ ] FirebaseAuthService 클래스 작성
- [ ] 이메일/비밀번호 로그인 구현
- [ ] Google 로그인 실제 연동
- [ ] Kakao 로그인 실제 연동 (Android)
- [ ] Apple 로그인 실제 연동 (iOS)
- [ ] AuthProvider와 통합

### Step 3: Repository 레이어 구현
- [ ] BaseRepository 추상 클래스
- [ ] UserRepository 구현
- [ ] WrongAnswerRepository 구현
- [ ] StudyHistoryRepository 구현
- [ ] LeagueRepository 구현

### Step 4: Firestore 동기화 구현
- [ ] FirebaseService 클래스
- [ ] 사용자 프로필 동기화
- [ ] 오답 노트 동기화
- [ ] 학습 기록 동기화
- [ ] 리그 데이터 실시간 업데이트

### Step 5: 하이브리드 저장 시스템
- [ ] SyncManager 구현
- [ ] 네트워크 상태 모니터링
- [ ] 오프라인 큐 시스템
- [ ] 충돌 해결 로직

### Step 6: UI 업데이트
- [ ] 동기화 상태 표시 위젯
- [ ] 오프라인 모드 인디케이터
- [ ] 수동 동기화 버튼
- [ ] 계정 연결 UI

### Step 7: 테스트
- [ ] Firebase Auth 테스트
- [ ] Firestore CRUD 테스트
- [ ] 동기화 로직 테스트
- [ ] 오프라인 모드 테스트
- [ ] 멀티 디바이스 테스트

---

## 📱 사용자 시나리오

### 시나리오 A: 게스트에서 정식 회원으로 전환

**Phase 1 (로컬 전용)**:
1. 게스트로 시작 → 로컬 데이터 생성
2. 회원가입 → 로컬 데이터 이전

**Phase 2 (Firebase 연동)**:
1. 게스트로 시작 → 로컬 데이터 생성
2. 회원가입 → Firebase Auth 계정 생성
3. 로컬 데이터를 Firestore로 업로드
4. Firebase UID와 로컬 accountId 매핑

### 시나리오 B: 멀티 디바이스 사용

1. **디바이스 A**: 로그인 → 학습 진행 → Firestore 동기화
2. **디바이스 B**: 같은 계정으로 로그인 → Firestore에서 데이터 다운로드
3. **디바이스 B**: 학습 진행 → Firestore 동기화
4. **디바이스 A**: 앱 재실행 → 최신 데이터 자동 동기화

### 시나리오 C: 오프라인 모드

1. 비행기 모드 ON → 앱 사용
2. 모든 변경사항 로컬 저장 + 동기화 큐에 추가
3. 네트워크 복구 → 자동으로 큐 처리 및 Firestore 동기화

---

## 🔧 주요 클래스 설계

### FirebaseAuthService

```dart
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 현재 사용자 UID
  String? get currentUserUid => _auth.currentUser?.uid;

  // Auth State Stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 이메일/비밀번호 로그인
  Future<UserCredential> signInWithEmailPassword(String email, String password);

  // 이메일/비밀번호 회원가입
  Future<UserCredential> signUpWithEmailPassword(String email, String password);

  // Google 로그인
  Future<UserCredential> signInWithGoogle();

  // Kakao 로그인 (Custom Token)
  Future<UserCredential> signInWithKakao();

  // Apple 로그인
  Future<UserCredential> signInWithApple();

  // 로그아웃
  Future<void> signOut();

  // 계정 삭제
  Future<void> deleteAccount();
}
```

### FirebaseService

```dart
class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 사용자 프로필
  Future<void> saveUserProfile(String uid, UserModel user);
  Future<UserModel?> getUserProfile(String uid);
  Stream<UserModel?> watchUserProfile(String uid);

  // 오답 노트
  Future<void> saveWrongAnswer(String uid, WrongAnswer wrongAnswer);
  Future<List<WrongAnswer>> getWrongAnswers(String uid);
  Stream<List<WrongAnswer>> watchWrongAnswers(String uid);

  // 학습 기록
  Future<void> saveStudyHistory(String uid, StudyHistory history);
  Future<List<StudyHistory>> getStudyHistory(String uid, {DateTime? from, DateTime? to});

  // 리그
  Future<League?> getCurrentLeague(String leagueId);
  Stream<League?> watchLeague(String leagueId);
  Future<void> updateLeagueParticipant(String leagueId, LeagueParticipant participant);
}
```

### SyncManager

```dart
class SyncManager {
  final LocalStorageService _local;
  final FirebaseService _firebase;
  final Connectivity _connectivity;

  // 동기화 상태
  final _syncStatus = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get syncStatus => _syncStatus.stream;

  // 초기 동기화 (앱 시작 시)
  Future<void> initialSync(String uid);

  // 양방향 동기화
  Future<void> bidirectionalSync(String uid);

  // 단방향 업로드
  Future<void> uploadChanges(String uid);

  // 단방향 다운로드
  Future<void> downloadChanges(String uid);

  // 충돌 해결
  Future<T> resolveConflict<T>(T local, T remote, ConflictResolutionStrategy strategy);
}
```

---

## ✅ 체크리스트

### Firebase 설정
- [ ] Firebase 프로젝트 생성
- [ ] FlutterFire CLI 설정
- [ ] Android 앱 등록 (`com.gomath.mathlab`)
- [ ] iOS 앱 등록
- [ ] google-services.json 추가
- [ ] GoogleService-Info.plist 추가
- [ ] Firebase 초기화 코드

### Authentication
- [ ] FirebaseAuthService 구현
- [ ] 이메일/비밀번호 로그인
- [ ] Google 로그인
- [ ] Kakao 로그인
- [ ] Apple 로그인
- [ ] AuthProvider 통합
- [ ] 게스트→정식 계정 전환

### Firestore
- [ ] FirebaseService 구현
- [ ] 사용자 프로필 CRUD
- [ ] 오답 노트 CRUD
- [ ] 학습 기록 CRUD
- [ ] 리그 데이터 실시간 조회
- [ ] Security Rules 설정

### Repository 레이어
- [ ] BaseRepository
- [ ] UserRepository
- [ ] WrongAnswerRepository
- [ ] StudyHistoryRepository
- [ ] LeagueRepository

### 동기화 시스템
- [ ] SyncManager 구현
- [ ] 네트워크 상태 모니터링
- [ ] 오프라인 큐
- [ ] 충돌 해결 로직
- [ ] 자동 동기화
- [ ] 수동 동기화

### UI/UX
- [ ] 동기화 상태 위젯
- [ ] 오프라인 인디케이터
- [ ] 수동 동기화 버튼
- [ ] 계정 연결 UI
- [ ] 로딩 스피너

### 테스트
- [ ] Firebase Auth 테스트
- [ ] Firestore CRUD 테스트
- [ ] 동기화 테스트
- [ ] 오프라인 모드 테스트
- [ ] 멀티 디바이스 테스트
- [ ] 충돌 해결 테스트

---

## 📝 참고사항

### Phase 1 호환성
- 기존 로컬 스토리지 데이터 구조 유지
- Firebase는 추가 레이어로 동작
- Phase 1 기능은 오프라인에서도 완전 동작

### 성능 고려사항
- Firestore 읽기/쓰기 비용 최소화
- 캐시 전략으로 불필요한 네트워크 요청 방지
- 배치 쓰기로 여러 작업 묶기
- 인덱스 최적화

### 보안 고려사항
- Firestore Security Rules 엄격히 설정
- 클라이언트에서 민감한 로직 제외
- Firebase Admin SDK로 서버 측 검증
- API 키 환경변수 관리

---

## 🚀 마일스톤

### M1: Firebase 기본 설정 (1일)
- Firebase 프로젝트 생성 및 앱 등록
- 설정 파일 추가 및 초기화 코드

### M2: Authentication (2-3일)
- Firebase Auth 서비스 구현
- 소셜 로그인 연동
- AuthProvider 통합

### M3: Repository 레이어 (2일)
- BaseRepository 및 각 Repository 구현
- 로컬 + Firebase 추상화

### M4: Firestore 동기화 (3-4일)
- FirebaseService 구현
- 데이터 CRUD 및 실시간 업데이트
- Security Rules 설정

### M5: 동기화 시스템 (3-4일)
- SyncManager 구현
- 충돌 해결 로직
- 오프라인 큐

### M6: UI 통합 및 테스트 (2-3일)
- UI 업데이트
- 통합 테스트
- 버그 수정

**총 예상 기간**: 2-3주
