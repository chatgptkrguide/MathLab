# 로그인 시스템 및 멀티테넌트 구조 설계 문서

## 📋 현재 상태 분석

### ✅ 이미 구현된 기능
1. **다중 계정 시스템** (`AuthProvider`)
   - 게스트 로그인
   - 이메일 회원가입
   - 소셜 로그인 기반 (Google, Kakao, Apple) - Mock 구현
   - 계정 전환 기능
   - 로컬 스토리지 기반 계정 관리

2. **데이터 모델**
   - `UserAccount`: 계정 정보 (id, email, displayName, accountType)
   - `UserModel`: Firestore 기반 사용자 프로필 (아직 미연결)
   - AccountType: student, parent, teacher, admin

3. **로컬 저장소**
   - `LocalStorageService`: SharedPreferences 기반
   - 암호화 지원 (AES)
   - 사용자별 데이터 키: `user_{accountId}`, `problemResults_{accountId}` 등

### ❌ 부족한 부분
1. **로그인 UI**
   - 제대로 된 로그인 화면 없음
   - 회원가입 폼 없음
   - 계정 선택 UI 부족

2. **데이터 분리 불완전**
   - 일부 Provider가 accountId 기반 분리를 안 하고 있음
   - WrongAnswer, League, Message 등의 Provider가 전역 상태로 관리됨

3. **Firebase 미연결**
   - 모든 데이터가 로컬에만 저장됨
   - 서버 동기화 없음

---

## 🎯 개발 전략

### Phase 1: 로컬 스토리지 기반 멀티테넌트 (현재 목표)
**목표**: 한 기기에서 여러 사용자가 각자의 데이터를 분리하여 사용

**장점**:
- 빠른 MVP 개발
- 오프라인 완전 지원
- 서버 비용 없음

**단점**:
- 기기 간 동기화 불가
- 데이터 백업 없음
- 확장성 제한

### Phase 2: Firebase/Backend 연동 (향후)
**목표**: 서버 기반 인증 및 클라우드 동기화

---

## 📐 Phase 1 상세 설계

### 1. 멀티테넌트 데이터 분리 전략

#### 1.1 데이터 키 명명 규칙
```
{dataType}_{accountId}
```

예시:
- `user_user_123456` - 사용자 프로필
- `wrong_answers_user_123456` - 오답 노트
- `league_user_123456` - 리그 데이터
- `messages_user_123456` - 메시지
- `friends_user_123456` - 친구 목록

#### 1.2 Provider 수정 필요 목록
1. ✅ `UserProvider` - 이미 accountId 기반
2. ❌ `WrongAnswerProvider` - 전역 → accountId 기반으로 변경 필요
3. ❌ `LeagueProvider` - 전역 → accountId 기반으로 변경 필요
4. ❌ `MessageProvider` - 전역 → accountId 기반으로 변경 필요
5. ❌ `FriendProvider` - 전역 → accountId 기반으로 변경 필요

#### 1.3 Provider 구조 변경 패턴

**Before** (전역):
```dart
class WrongAnswerProvider extends StateNotifier<WrongAnswerState> {
  final LocalStorageService _storage = LocalStorageService();
  static const String _storageKey = 'wrong_answers';

  Future<void> _loadWrongAnswers() async {
    final data = await _storage.loadMap(_storageKey);
    // ...
  }
}
```

**After** (accountId 기반):
```dart
class WrongAnswerProvider extends StateNotifier<WrongAnswerState> {
  final Ref ref; // Riverpod Ref for accessing other providers
  final LocalStorageService _storage = LocalStorageService();

  WrongAnswerProvider(this.ref) : super(...) {
    _initialize();
  }

  String? get _storageKey {
    final accountId = ref.read(currentAccountProvider)?.id;
    if (accountId == null) return null;
    return 'wrong_answers_$accountId';
  }

  Future<void> _loadWrongAnswers() async {
    final key = _storageKey;
    if (key == null) return; // No logged in user

    final data = await _storage.loadMap(key);
    // ...
  }
}
```

---

### 2. 로그인 UI/UX 설계

#### 2.1 화면 구조
```
AuthScreen (로그인/회원가입)
  ├─ WelcomeView (처음 접속 시)
  │   ├─ 앱 로고 및 설명
  │   ├─ [게스트로 시작] 버튼
  │   ├─ [회원가입] 버튼
  │   └─ [로그인] 버튼
  │
  ├─ LoginView (로그인)
  │   ├─ 이메일 입력
  │   ├─ [로그인] 버튼
  │   ├─ 소셜 로그인 버튼들
  │   │   ├─ Google 로그인
  │   │   ├─ Kakao 로그인
  │   │   └─ Apple 로그인 (iOS)
  │   └─ [회원가입하기] 링크
  │
  ├─ SignUpView (회원가입)
  │   ├─ 이메일 입력
  │   ├─ 이름 입력
  │   ├─ 학년 선택
  │   ├─ 계정 타입 선택 (학생/학부모/선생님)
  │   ├─ [회원가입 완료] 버튼
  │   └─ [로그인하기] 링크
  │
  └─ AccountSwitcherView (계정 전환)
      ├─ 현재 로그인된 계정 정보
      ├─ 저장된 계정 목록
      │   └─ 각 계정 카드 (탭하여 전환)
      ├─ [새 계정 추가] 버튼
      └─ [로그아웃] 버튼
```

#### 2.2 사용자 시나리오

**시나리오 1: 첫 사용자**
1. 앱 실행 → WelcomeView
2. [게스트로 시작] 또는 [회원가입]
3. 홈 화면으로 이동

**시나리오 2: 기존 사용자 (자동 로그인)**
1. 앱 실행 → AuthWrapper가 자동 로그인 확인
2. 저장된 계정 있으면 → 바로 홈 화면
3. 저장된 계정 없으면 → WelcomeView

**시나리오 3: 다중 계정 사용자**
1. 프로필 화면 → [계정 전환]
2. AccountSwitcherView → 원하는 계정 선택
3. 선택한 계정으로 데이터 전환

#### 2.3 UI 컴포넌트 디자인

**색상 테마**:
- Primary: `#4CAF50` (초록) - 학생
- Secondary: `#2196F3` (파랑) - 학부모
- Accent: `#FF9800` (주황) - 선생님

**주요 컴포넌트**:
1. `CustomTextField` - 이메일/이름 입력
2. `GradeSelector` - 학년 선택 드롭다운
3. `AccountTypeChip` - 계정 타입 선택 칩
4. `SocialLoginButton` - 소셜 로그인 버튼
5. `AccountCard` - 계정 목록 카드

---

### 3. 데이터 마이그레이션 전략

#### 3.1 기존 데이터 처리
```dart
/// 게스트 계정의 기존 데이터를 새 계정으로 이전
Future<void> migrateGuestData(String guestAccountId, String newAccountId) async {
  final keysToMigrate = [
    'user',
    'wrong_answers',
    'league',
    'messages',
    'friends',
  ];

  for (final key in keysToMigrate) {
    final oldKey = '${key}_$guestAccountId';
    final newKey = '${key}_$newAccountId';

    final data = await _storage.getString(oldKey);
    if (data != null) {
      await _storage.setString(newKey, data);
      await _storage.remove(oldKey);
    }
  }
}
```

#### 3.2 전역 데이터를 계정별로 분리
```dart
/// 앱 업데이트 시 기존 전역 데이터를 현재 계정으로 마이그레이션
Future<void> migrateGlobalToAccountBased() async {
  final currentAccount = ref.read(currentAccountProvider);
  if (currentAccount == null) return;

  final globalKeys = [
    'wrong_answers',  // → wrong_answers_{accountId}
    'league',         // → league_{accountId}
    'messages',       // → messages_{accountId}
  ];

  for (final oldKey in globalKeys) {
    final newKey = '${oldKey}_${currentAccount.id}';

    // 새 키가 이미 있으면 스킵
    if (await _storage.containsKey(newKey)) continue;

    // 전역 데이터를 계정별로 복사
    final data = await _storage.getString(oldKey);
    if (data != null) {
      await _storage.setString(newKey, data);
      // 전역 키는 마이그레이션 후 삭제
      await _storage.remove(oldKey);
    }
  }
}
```

---

### 4. 보안 고려사항

#### 4.1 비밀번호 미사용 이유
**현재 Phase 1**에서는 비밀번호를 사용하지 않습니다:
- 로컬 스토리지 기반이므로 기기 접근 = 데이터 접근
- 간단한 이메일 기반 식별만 사용
- 게스트 모드 지원

**Phase 2 (Firebase)**에서 비밀번호 추가:
- Firebase Authentication 사용
- 소셜 로그인 우선
- 이메일 + 비밀번호는 옵션

#### 4.2 데이터 암호화
- 민감한 데이터는 `saveSecureObject()` 사용
- AES 암호화 적용
- 사용자 프로필, 인증 토큰 등

---

## 🛠️ 구현 단계

### Step 1: Provider 멀티테넌트 전환
1. `WrongAnswerProvider` accountId 기반 수정
2. `LeagueProvider` accountId 기반 수정
3. `MessageProvider` accountId 기반 수정
4. `FriendProvider` accountId 기반 수정

### Step 2: 로그인 UI 구현
1. `WelcomeView` 위젯
2. `LoginView` 위젯
3. `SignUpView` 위젯
4. `AccountSwitcherView` 위젯
5. `AuthScreen` 통합

### Step 3: 데이터 마이그레이션
1. 전역 데이터 → 계정별 데이터 변환
2. 마이그레이션 로직 `AuthProvider`에 추가
3. 앱 시작 시 자동 마이그레이션

### Step 4: 테스트
1. 게스트 로그인 → 회원가입 전환 테스트
2. 다중 계정 전환 테스트
3. 데이터 분리 확인
4. 계정 삭제 테스트

---

## 📱 사용자 경험 시나리오

### 시나리오 A: 학생 혼자 사용
```
1. 앱 설치 → 게스트로 시작
2. 며칠 사용 후 → 이메일 회원가입
3. 게스트 데이터 자동 이전
```

### 시나리오 B: 가족 공유 (1대 기기)
```
1. 부모가 앱 설치 → 회원가입 (학부모 계정)
2. 자녀1 추가 → 회원가입 (학생 계정)
3. 자녀2 추가 → 회원가입 (학생 계정)
4. 프로필 화면에서 계정 전환으로 사용
```

### 시나리오 C: 선생님 사용
```
1. 앱 설치 → 회원가입 (선생님 계정)
2. 학생 관리 기능 접근 (향후 구현)
```

---

## 🔄 Phase 2 준비사항

### Firebase 연동 준비
1. `FirebaseAuth` 통합
2. `Firestore` 사용자 데이터 동기화
3. 로컬 + 클라우드 하이브리드 저장
4. 오프라인 모드 지원

### API 설계
```
POST /auth/signup
POST /auth/login
POST /auth/logout
GET /users/me
PUT /users/me
```

---

## ✅ 체크리스트

### Provider 멀티테넌트 전환
- [x] WrongAnswerProvider accountId 기반 수정 ✅
- [x] LeagueProvider accountId 기반 수정 ✅
- [x] MessageProvider accountId 기반 수정 ✅
- [x] FriendProvider accountId 기반 수정 ✅

### UI 구현
- [x] WelcomeView ✅
- [x] LoginView ✅
- [x] SignUpView ✅
- [x] AccountSwitcherView ✅
- [x] AuthScreen 통합 ✅
- [x] 소셜 로그인 버튼 스타일링 ✅ (Mock 구현)

### 데이터 마이그레이션
- [x] 전역 → 계정별 마이그레이션 함수 ✅
- [x] 게스트 → 정식 계정 데이터 이전 ✅
- [x] 마이그레이션 자동 실행 로직 ✅

### 테스트
- [x] 게스트 로그인 ✅
- [x] 이메일 회원가입 ✅
- [x] 계정 전환 ✅
- [x] 데이터 분리 확인 ✅ (accountId 기반 키 사용 확인)
- [x] 계정 삭제 ✅
- [x] 소셜 로그인 (Mock) ✅

---

## 🎉 Phase 1 완료 (2025-01-29)

**구현 완료 사항**:
1. ✅ 멀티테넌트 데이터 아키텍처: 모든 Provider가 `{dataType}_{accountId}` 형식으로 데이터 분리
2. ✅ 로그인 UI/UX: WelcomeView, LoginView, SignUpView, AccountSwitcherView 구현
3. ✅ 데이터 마이그레이션: 일회성 마이그레이션 시스템 구현 및 게스트 데이터 자동 이전
4. ✅ 검증 완료: 실제 디바이스에서 모든 기능 테스트 및 확인

**주요 성과**:
- 한 기기에서 여러 계정이 완전히 분리된 데이터를 사용할 수 있음
- 게스트에서 정식 계정으로 전환 시 데이터 손실 없음
- 오프라인 완전 지원 및 빠른 사용자 경험 제공

---

## 📝 참고사항

### 기존 코드 활용
- `AuthProvider` 대부분 재사용 가능
- `UserAccount` 모델 그대로 사용
- `LocalStorageService` 확장만 필요

### 주의사항
1. 계정 전환 시 모든 Provider 리셋 필요
2. 로그아웃 시 현재 계정 데이터만 메모리에서 제거
3. 계정 삭제 시 관련 모든 데이터 삭제

### 향후 확장 방향
1. 학부모-자녀 계정 연결
2. 선생님-학생 관리 기능
3. 클라우드 동기화
4. 멀티 디바이스 지원
