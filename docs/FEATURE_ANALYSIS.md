# MathLab 기능 분석 보고서

## 개요
MathLab 앱의 전체 기능을 분석하고, 현재 구현된 기능과 부족한 기능을 파악하여 향후 개발 방향을 제시합니다.

## 현재 구현된 기능

### 1. 인증 시스템 ✅
**구현 완료도**: 90%

**기능**:
- 이메일 기반 회원가입/로그인
- 소셜 로그인 (Google, Kakao, Apple)
- 로그아웃 기능
- 계정 전환 시스템

**파일**:
- `lib/data/providers/auth_provider.dart`
- `lib/data/services/social_auth_service.dart`
- `lib/features/auth/auth_screen.dart`

**부족한 부분**:
- 비밀번호 재설정 기능 없음
- 이메일 인증 없음
- 계정 삭제 기능 없음

---

### 2. 사용자 프로필 시스템 ✅
**구현 완료도**: 85%

**기능**:
- 사용자 정보 관리 (이름, 이메일, 학년)
- XP 및 레벨 시스템
- 스트릭 추적
- 하트 시스템
- 프로필 화면

**파일**:
- `lib/data/models/user.dart`
- `lib/data/providers/user_provider.dart`
- `lib/features/profile/profile_screen.dart`

**핵심 로직**:
```dart
// 레벨 계산
int get level => (totalXp / 100).floor() + 1;
int get xpForCurrentLevel => totalXp % 100;
int get xpForNextLevel => 100;

// 스트릭 업데이트
void updateStreak() {
  final now = DateTime.now();
  if (_lastActiveDate == null) {
    _currentStreak = 1;
    _lastActiveDate = now;
  } else {
    final difference = now.difference(_lastActiveDate!).inDays;
    if (difference == 1) {
      _currentStreak++;
    } else if (difference > 1) {
      _currentStreak = 1;
    }
    _lastActiveDate = now;
  }
}
```

**부족한 부분**:
- 프로필 사진 업로드/변경 기능 없음
- 학습 통계 시각화 부족 (주간/월간 그래프)
- 계정 설정 화면 없음
- 하트 재생 시스템 없음 (모델에는 존재하지만 로직 미구현)

---

### 3. 레슨 시스템 ✅
**구현 완료도**: 80%

**기능**:
- 레슨 목록 표시
- 카테고리별 그룹핑
- 잠금/해제 시스템
- 진행률 추적
- 레슨 완료 처리

**파일**:
- `lib/data/models/lesson.dart`
- `lib/data/providers/lesson_provider.dart`
- `lib/features/lessons/lessons_screen.dart`

**핵심 로직**:
```dart
// 레슨 잠금 해제 조건
bool isLessonUnlocked(Lesson lesson) {
  if (lesson.requiredLevel > _userLevel) return false;

  if (lesson.prerequisites.isNotEmpty) {
    return lesson.prerequisites.every((prereqId) {
      final prereq = _lessons.firstWhere((l) => l.id == prereqId);
      return prereq.isCompleted;
    });
  }

  return true;
}
```

**부족한 부분**:
- 레슨 검색 기능 없음
- 레슨 북마크/즐겨찾기 없음
- 레슨 난이도 표시 부족
- 추천 레슨 시스템 없음
- 레슨 미리보기 기능 없음

---

### 4. 문제 풀이 시스템 ✅
**구현 완료도**: 75%

**기능**:
- 객관식 문제 (4지선다)
- 정답/오답 피드백
- XP 보상 시스템
- 하트 차감
- 문제 셔플
- 햅틱 피드백

**파일**:
- `lib/data/models/problem.dart`
- `lib/data/providers/problem_provider.dart`
- `lib/features/problem/problem_screen.dart`

**핵심 로직**:
```dart
// 정답 확인
if (_isCorrect) {
  await AppHapticFeedback.success();
  _userProvider.addXP(10);
  setState(() {
    _showFeedback = true;
    _feedbackMessage = '정답입니다! 🎉';
  });
} else {
  await AppHapticFeedback.error();
  _userProvider.loseHeart();
  setState(() {
    _showFeedback = true;
    _feedbackMessage = '틀렸습니다. 다시 시도해보세요!';
  });
}
```

**부족한 부분**:
- 힌트 시스템 없음
- 문제 유형 다양화 필요 (드래그 앤 드롭, 손글씨 인식 등)
- 단계별 풀이 시스템 없음
- 오답 노트 기능 없음
- 연습 모드 없음
- 시간 제한 모드 없음
- 설명/해설 기능 부족

---

### 5. 업적 시스템 ⚠️
**구현 완료도**: 40%

**기능**:
- 업적 데이터 모델
- 업적 타입 (문제 풀이, 스트릭, 레벨, XP, 완벽, 시간)
- 희귀도 시스템 (Common, Rare, Epic, Legendary)

**파일**:
- `lib/data/models/achievement.dart`

**부족한 부분**:
- ❌ Provider 없음 (추적/언락 로직 없음)
- ❌ UI 화면 없음
- ❌ 업적 알림 없음
- ❌ 업적 보상 시스템 없음
- ❌ 진행률 추적 없음

**제안**:
```dart
// AchievementProvider 구현 필요
class AchievementProvider extends StateNotifier<List<Achievement>> {
  void checkAchievements(User user) {
    // 조건 체크 후 업적 언락
  }

  void unlockAchievement(String achievementId) {
    // 업적 언락 처리
  }
}
```

---

### 6. 데일리 리워드 시스템 ⚠️
**구현 완료도**: 30%

**기능**:
- 데일리 리워드 데이터 모델
- 7일 주기 보상
- 스트릭 보너스

**파일**:
- `lib/data/models/daily_reward.dart`

**부족한 부분**:
- ❌ Provider 없음 (클레임 로직 없음)
- ❌ UI 화면 없음
- ❌ 클레임 알림 없음
- ❌ 스트릭 프리즈 기능 없음

**제안**:
```dart
// DailyRewardProvider 구현 필요
class DailyRewardProvider extends StateNotifier<DailyRewardState> {
  bool canClaimToday() {
    // 오늘 클레임 가능 여부 확인
  }

  void claimDailyReward() {
    // 보상 지급 및 날짜 업데이트
  }
}
```

---

### 7. 리그 시스템 ⚠️
**구현 완료도**: 35%

**기능**:
- 리그 티어 데이터 모델 (Bronze, Silver, Gold, Diamond)
- 티어별 요구 XP

**파일**:
- `lib/data/models/league.dart`

**부족한 부분**:
- ❌ Provider 없음 (승격/강등 로직 없음)
- ❌ 주간 리그 경쟁 시스템 없음
- ❌ 리그 화면 없음
- ❌ 리그 보상 시스템 없음
- ❌ 리그 순위 추적 없음

**제안**:
```dart
// LeagueProvider 구현 필요
class LeagueProvider extends StateNotifier<LeagueState> {
  void updateLeagueTier(int totalXp) {
    // XP 기반 티어 업데이트
  }

  void processWeeklyReset() {
    // 주간 리그 초기화 및 보상
  }
}
```

---

### 8. 리더보드 시스템 ✅
**구현 완료도**: 75%

**기능**:
- 주간/월간/전체 랭킹
- 현재 사용자 하이라이트
- 순위 뱃지 표시

**파일**:
- `lib/data/providers/leaderboard_provider.dart`
- `lib/features/leaderboard/leaderboard_screen.dart`

**부족한 부분**:
- 실시간 데이터 연동 없음 (샘플 데이터 사용)
- 친구 랭킹 없음
- 지역별 랭킹 없음
- 랭킹 필터링 기능 부족

---

### 9. 게이미피케이션 요소 ✅
**구현 완료도**: 70%

**구현된 요소**:
- ✅ XP 시스템
- ✅ 레벨 시스템 (level * 100 XP)
- ✅ 스트릭 시스템
- ✅ 하트 시스템
- ✅ 3D 듀오링고 스타일 버튼
- ✅ 햅틱 피드백
- ✅ 애니메이션 효과

**부족한 요소**:
- ⚠️ 업적 시스템 (모델만 존재)
- ⚠️ 데일리 리워드 (모델만 존재)
- ⚠️ 리그 시스템 (모델만 존재)
- ❌ 친구 시스템 없음
- ❌ 아이템/파워업 없음
- ❌ 커스터마이징 요소 없음

---

### 10. UI/UX 시스템 ✅
**구현 완료도**: 85%

**구현된 기능**:
- ✅ 듀오링고 스타일 3D 버튼
- ✅ 부드러운 애니메이션
- ✅ 햅틱 피드백 패턴
- ✅ 접근성 (Semantics)
- ✅ 커스텀 하단 네비게이션
- ✅ 반응형 레이아웃
- ✅ 다크모드 대응 색상

**부족한 부분**:
- 설정 화면 없음
- 다크모드 토글 없음
- 사운드 효과 없음
- 언어 설정 없음
- 글꼴 크기 조절 없음

---

## 부족한 기능 우선순위

### 🔴 높음 (즉시 구현 필요)

#### 1. 데일리 리워드 시스템
**우선순위**: 최고
**이유**: 사용자 리텐션에 가장 중요한 기능

**구현 사항**:
- `DailyRewardProvider` 생성
- 데일리 리워드 클레임 UI
- 스트릭 보너스 로직
- 클레임 알림

**예상 작업량**: 2-3일

---

#### 2. 업적 시스템
**우선순위**: 높음
**이유**: 사용자 동기부여 및 성취감 제공

**구현 사항**:
- `AchievementProvider` 생성
- 업적 조건 체크 로직
- 업적 화면 UI
- 업적 언락 알림
- 업적 진행률 추적

**예상 작업량**: 3-4일

---

#### 3. 하트 재생 시스템
**우선순위**: 높음
**이유**: 게임 플레이 지속성에 중요

**구현 사항**:
```dart
class UserProvider extends StateNotifier<User> {
  Timer? _heartRegenTimer;

  void startHeartRegeneration() {
    _heartRegenTimer?.cancel();
    _heartRegenTimer = Timer.periodic(
      const Duration(minutes: 30), // 30분마다 하트 1개 재생
      (timer) {
        if (state.hearts < 5) {
          state = state.copyWith(hearts: state.hearts + 1);
          _saveUser();
        } else {
          timer.cancel();
        }
      },
    );
  }

  void purchaseFullHearts() {
    // 하트 전체 구매 (광고 시청 또는 IAP)
    state = state.copyWith(hearts: 5);
    _saveUser();
  }
}
```

**예상 작업량**: 1-2일

---

#### 4. 설정 화면
**우선순위**: 높음
**이유**: 사용자 개인화 필수 기능

**구현 사항**:
- 알림 On/Off
- 사운드 효과 On/Off
- 햅틱 피드백 On/Off
- 다크모드 토글
- 언어 설정
- 계정 관리 (로그아웃, 계정 삭제)

**파일 구조**:
```
lib/features/settings/
├── settings_screen.dart
├── widgets/
│   ├── setting_item.dart
│   └── setting_section.dart
└── providers/
    └── settings_provider.dart
```

**예상 작업량**: 2-3일

---

### 🟡 중간 (단기 구현 필요)

#### 5. 리그 시스템
**우선순위**: 중간
**이유**: 경쟁 요소 추가로 사용자 참여 증대

**구현 사항**:
- `LeagueProvider` 생성
- 주간 XP 경쟁 시스템
- 승격/강등 로직
- 리그 화면 UI
- 주간 리셋 및 보상

**예상 작업량**: 4-5일

---

#### 6. 오답 노트 시스템
**우선순위**: 중간
**이유**: 학습 효과 증대

**구현 사항**:
```dart
class WrongAnswerProvider extends StateNotifier<List<WrongAnswer>> {
  void addWrongAnswer(Problem problem, int selectedIndex) {
    state = [
      ...state,
      WrongAnswer(
        problem: problem,
        selectedAnswer: selectedIndex,
        timestamp: DateTime.now(),
      ),
    ];
  }

  List<WrongAnswer> getReviewList() {
    // 망각 곡선 기반 복습 필요 문제 반환
    return state.where((wa) {
      final daysSince = DateTime.now().difference(wa.timestamp).inDays;
      return daysSince >= 1 && daysSince <= 7;
    }).toList();
  }
}
```

**파일 구조**:
```
lib/features/wrong_answers/
├── wrong_answers_screen.dart
├── models/
│   └── wrong_answer.dart
└── providers/
    └── wrong_answer_provider.dart
```

**예상 작업량**: 2-3일

---

#### 7. 힌트 시스템
**우선순위**: 중간
**이유**: 학습 지원 및 이탈 방지

**구현 사항**:
```dart
class Problem {
  final List<String> hints; // 단계별 힌트
  final String explanation; // 상세 설명

  // 힌트 비용 (XP 또는 광고 시청)
  static const int hintCost = 5;
}

class ProblemProvider extends StateNotifier<ProblemState> {
  void showHint(int hintIndex) {
    if (_userProvider.state.totalXp >= Problem.hintCost) {
      _userProvider.deductXP(Problem.hintCost);
      // 힌트 표시
    }
  }
}
```

**예상 작업량**: 2일

---

#### 8. 튜토리얼/온보딩 개선
**우선순위**: 중간
**이유**: 신규 사용자 경험 개선

**구현 사항**:
- 인터랙티브 튜토리얼
- 주요 기능 소개
- Skip 가능한 온보딩
- 첫 문제 풀이 가이드

**라이브러리 추천**:
```yaml
dependencies:
  tutorial_coach_mark: ^1.2.11
```

**예상 작업량**: 3-4일

---

### 🟢 낮음 (장기 구현 검토)

#### 9. 친구 시스템
**우선순위**: 낮음
**이유**: 소셜 기능으로 사용자 리텐션 증대

**구현 사항**:
- 친구 추가/삭제
- 친구 초대 코드
- 친구 랭킹
- 친구와 경쟁

**Backend 필요**: 실시간 데이터 동기화

**예상 작업량**: 1-2주

---

#### 10. 푸시 알림 시스템
**우선순위**: 낮음
**이유**: 사용자 재방문 유도

**구현 사항**:
- Firebase Cloud Messaging 연동
- 스트릭 알림 (21:00 기본)
- 하트 충전 알림
- 데일리 리워드 알림
- 리그 순위 알림

**라이브러리**:
```yaml
dependencies:
  firebase_messaging: ^14.7.9
  flutter_local_notifications: ^16.3.0
```

**예상 작업량**: 3-5일

---

#### 11. 문제 유형 다양화
**우선순위**: 낮음
**이유**: 학습 경험 향상

**추가 문제 유형**:
- 드래그 앤 드롭 (수식 조립)
- 손글씨 인식
- 그래프 매칭
- 빈칸 채우기

**라이브러리 추천**:
```yaml
dependencies:
  google_mlkit_digital_ink_recognition: ^0.11.0  # 손글씨
  flutter_draggable_gridview: ^0.1.3             # 드래그 앤 드롭
```

**예상 작업량**: 1-2주

---

#### 12. 수익화 시스템
**우선순위**: 낮음
**이유**: 장기적 수익 모델

**구현 사항**:
- 광고 (배너, 전면, 보상형)
- 인앱 구매 (하트, 힌트, 프리미엄)
- 구독 모델

**라이브러리**:
```yaml
dependencies:
  google_mobile_ads: ^4.0.0
  in_app_purchase: ^3.1.13
```

**예상 작업량**: 1주

---

## 기능 로드맵

### Phase 1: 즉시 구현 (1-2주)
1. ✅ 데일리 리워드 시스템
2. ✅ 업적 시스템
3. ✅ 하트 재생 시스템
4. ✅ 설정 화면

### Phase 2: 단기 구현 (2-4주)
5. ✅ 리그 시스템
6. ✅ 오답 노트
7. ✅ 힌트 시스템
8. ✅ 튜토리얼 개선

### Phase 3: 중기 구현 (1-2개월)
9. 친구 시스템 (Backend 필요)
10. 푸시 알림
11. 문제 유형 다양화
12. 통계 화면 (주간/월간 학습 그래프)

### Phase 4: 장기 구현 (3-6개월)
13. AI 기반 적응형 학습
14. 수익화 시스템
15. 부모 모드
16. 오프라인 모드

---

## 데이터베이스 설계 (Backend 연동 시)

### Users 테이블
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  display_name VARCHAR(100),
  grade INTEGER,
  total_xp INTEGER DEFAULT 0,
  current_streak INTEGER DEFAULT 0,
  longest_streak INTEGER DEFAULT 0,
  hearts INTEGER DEFAULT 5,
  last_active_date TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### Achievements 테이블
```sql
CREATE TABLE user_achievements (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  achievement_id VARCHAR(50),
  unlocked_at TIMESTAMP DEFAULT NOW(),
  progress INTEGER DEFAULT 0
);
```

### Daily Rewards 테이블
```sql
CREATE TABLE daily_rewards (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  claim_date DATE,
  day_number INTEGER,
  xp_rewarded INTEGER,
  hearts_rewarded INTEGER,
  created_at TIMESTAMP DEFAULT NOW()
);
```

### Leagues 테이블
```sql
CREATE TABLE league_rankings (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  week_start DATE,
  tier VARCHAR(20),
  weekly_xp INTEGER DEFAULT 0,
  rank INTEGER,
  promoted BOOLEAN DEFAULT FALSE,
  relegated BOOLEAN DEFAULT FALSE
);
```

---

## 성능 최적화 제안

### 1. 로컬 캐싱 강화
```dart
class CachedDataService {
  static final _cache = <String, dynamic>{};
  static const _cacheDuration = Duration(hours: 1);

  Future<T?> getCached<T>(String key) async {
    final cached = _cache[key];
    if (cached != null && cached['expiry'].isAfter(DateTime.now())) {
      return cached['data'] as T;
    }
    return null;
  }

  void setCached<T>(String key, T data) {
    _cache[key] = {
      'data': data,
      'expiry': DateTime.now().add(_cacheDuration),
    };
  }
}
```

### 2. 이미지 최적화
```yaml
dependencies:
  cached_network_image: ^3.3.1
  flutter_cache_manager: ^3.3.1
```

### 3. 애니메이션 성능 개선
- ✅ 이미 완료: AnimatedButton 쉬머 효과 제거
- 추가 제안: 복잡한 애니메이션에 RepaintBoundary 사용

---

## 보안 강화 제안

### 1. 민감 데이터 암호화
```yaml
dependencies:
  flutter_secure_storage: ^9.0.0
```

```dart
class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
}
```

### 2. API 통신 보안
- HTTPS 강제
- JWT 토큰 만료 처리
- 리프레시 토큰 구현

---

## 접근성 개선 제안

### 1. 스크린 리더 지원 강화
- ✅ 이미 완료: 모든 버튼에 Semantics 추가
- 추가 제안: 수학 수식 읽기 지원

### 2. 색상 대비 개선
- WCAG 2.1 AAA 등급 달성
- 색맹 모드 추가

### 3. 글꼴 크기 조절
```dart
class AccessibilitySettings {
  static const textScaleFactors = [0.8, 1.0, 1.2, 1.5, 2.0];

  void setTextScale(double scale) {
    // 전역 텍스트 스케일 설정
  }
}
```

---

## 테스트 전략

### 1. 단위 테스트
```dart
// test/providers/user_provider_test.dart
void main() {
  test('사용자 레벨 계산 테스트', () {
    final user = User(totalXp: 250);
    expect(user.level, 3); // level = (250 / 100).floor() + 1
  });

  test('스트릭 업데이트 테스트', () {
    final provider = UserProvider();
    provider.updateStreak();
    expect(provider.state.currentStreak, 1);
  });
}
```

### 2. 위젯 테스트
```dart
testWidgets('로그인 화면 렌더링 테스트', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(home: AuthScreen()),
    ),
  );

  expect(find.text('이메일'), findsOneWidget);
  expect(find.byType(ElevatedButton), findsWidgets);
});
```

### 3. 통합 테스트
```dart
testWidgets('전체 로그인 플로우 테스트', (tester) async {
  // 1. 로그인 화면 진입
  // 2. 이메일 입력
  // 3. 로그인 버튼 클릭
  // 4. 홈 화면 진입 확인
});
```

---

## 결론

### 현재 상태 요약
- **전체 완성도**: 약 65%
- **핵심 기능**: 대부분 구현 완료
- **게이미피케이션**: 모델은 준비, 로직 구현 필요
- **UI/UX**: 높은 완성도 (85%)

### 즉시 구현이 필요한 기능 (Phase 1)
1. 데일리 리워드 시스템 (사용자 리텐션 핵심)
2. 업적 시스템 (사용자 동기부여)
3. 하트 재생 시스템 (게임 지속성)
4. 설정 화면 (필수 UX)

### 권장 개발 순서
```
Phase 1 (2주) → MVP 출시 가능 수준
→ Phase 2 (4주) → 경쟁력 있는 제품
→ Phase 3 (2개월) → 차별화된 서비스
→ Phase 4 (6개월) → 프리미엄 학습 플랫폼
```

### 성공을 위한 핵심 지표
- DAU/MAU 비율 30% 이상
- 7일 리텐션 40% 이상
- 평균 세션 시간 15분 이상
- 스트릭 유지율 25% 이상

---

**작성일**: 2025-10-22
**작성자**: Claude Code
**버전**: 1.0.0
