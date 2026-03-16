# 🔧 MathLab 코드 리팩토링 계획

## 📋 개요

**목표**: 코드 품질 개선 및 유지보수성 향상
**날짜**: 2026-01-24
**총 파일 수**: 349개 Dart 파일

## 🎯 주요 이슈

### 1. 과도하게 큰 파일들 (800줄 이상)
- ❌ `profile_detail_screen.dart`: **1,025줄** - 11개의 build 메서드
- ❌ `problem_screen.dart`: **875줄** - 복잡한 상태 관리
- ❌ `onboarding_profile_setup_screen.dart`: **828줄**
- ❌ `auth_provider.dart`: **827줄**

### 2. State 관리 복잡도
- 146개 파일에 259개의 State 클래스
- StatefulWidget 과다 사용 가능성
- 상태 관리 로직이 UI 코드와 혼재

### 3. 미완성 작업
- 31개 파일에 TODO/FIXME 주석 존재

## 🔨 리팩토링 우선순위

### Phase 1: 큰 화면 파일 분할 (우선순위: 높음)

#### 1.1 profile_detail_screen.dart 리팩토링

**현재 상태**: 1,025줄, 11개의 build 메서드

**리팩토링 계획**:

```
lib/features/profile/figma/
├── profile_detail_screen.dart (100-150줄로 축소)
└── widgets/
    ├── user_profile_card.dart          # _buildUserProfileCard
    ├── follower_stats_widget.dart      # _buildFollowerStats
    ├── streak_card.dart               # _buildStreakCard (이미 존재)
    ├── profile_tab_section.dart        # _buildTabSection
    ├── badges_section.dart            # _buildBadgesSection
    ├── statistics_section.dart         # _buildStatisticsSection
    └── premium_card_widget.dart       # _buildPremiumCard (이미 존재)
```

**기대 효과**:
- 메인 파일: 1,025줄 → **~150줄** (85% 감소)
- 각 위젯: **50-100줄**로 관리 가능한 크기
- 재사용성 향상
- 테스트 용이성 증가

**작업 단계**:
1. ✅ widgets 폴더 구조 확인 (일부 위젯 이미 존재)
2. 각 `_build` 메서드를 독립적인 위젯 파일로 추출
3. ConsumerWidget 또는 StatelessWidget으로 변환
4. 필요한 데이터는 생성자로 전달
5. 메인 파일에서 새 위젯 사용

**예시**:
```dart
// Before (profile_detail_screen.dart 내부)
Widget _buildUserProfileCard(User? user, BuildContext context) {
  // 269줄의 복잡한 위젯 구조
}

// After (widgets/user_profile_card.dart)
class UserProfileCard extends ConsumerWidget {
  final User? user;

  const UserProfileCard({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 명확한 책임과 재사용 가능한 컴포넌트
  }
}
```

#### 1.2 problem_screen.dart 리팩토링

**현재 상태**: 875줄, 복잡한 비즈니스 로직

**리팩토링 계획**:

```
lib/features/problem/
├── problem_screen.dart (200-250줄로 축소)
├── controllers/
│   └── problem_screen_controller.dart  # 비즈니스 로직 분리
└── widgets/ (이미 많은 위젯이 분리되어 있음 ✅)
    ├── problem_header.dart ✅
    ├── problem_question.dart ✅
    ├── problem_options.dart ✅
    ├── problem_controls.dart ✅
    └── ... (기존 위젯들 유지)
```

**개선 방향**:
1. **비즈니스 로직 분리**:
   - `ProblemScreenController` 클래스 생성
   - 답안 제출 로직 (`_submitAnswer`, `_submitShortAnswer`)
   - 스트릭 계산 로직 (`_calculateStreakBonus`)
   - 뱃지 체크 로직 (`_checkAchievements`)
   - 결과 처리 로직 (`_processAnswerSubmission`)

2. **State 변수 그룹화**:
```dart
class _ProblemScreenState extends ConsumerState<ProblemScreen> {
  // 현재: 30개 이상의 변수가 흩어져 있음

  // 개선: 의미 있는 그룹으로 묶기
  late final ProblemStateManager _stateManager;
  late final ProblemAnimationController _animationController;
  late final ProblemInputController _inputController;
}
```

3. **Extension 활용**:
```dart
// extensions/problem_screen_extensions.dart
extension ProblemScreenHelpers on _ProblemScreenState {
  String getCorrectAnswerText() { /* ... */ }
  bool compareNumbers(String userAnswer, String correctAnswer) { /* ... */ }
}
```

**기대 효과**:
- 메인 파일: 875줄 → **~250줄** (70% 감소)
- 로직 재사용성 향상
- 단위 테스트 작성 용이

#### 1.3 auth_provider.dart 리팩토링

**현재 상태**: 827줄

**리팩토링 계획**:
```
lib/data/providers/auth/
├── auth_provider.dart (150-200줄로 축소)
├── controllers/
│   ├── social_auth_controller.dart     # 소셜 로그인 로직
│   ├── account_manager.dart            # 계정 관리 로직
│   └── migration_controller.dart       # 마이그레이션 로직
└── state/
    └── auth_state.dart                 # 상태 정의
```

**개선 방향**:
1. 소셜 로그인 로직 분리 (Google, Kakao, Apple)
2. 계정 CRUD 로직 분리
3. 마이그레이션 로직 분리
4. 각 컨트롤러는 100-200줄 이내

**기대 효과**:
- 메인 파일: 827줄 → **~200줄** (75% 감소)
- 각 컨트롤러가 단일 책임 원칙 준수
- 테스트 및 디버깅 용이

### Phase 2: TODO/FIXME 처리 (우선순위: 중간)

**현재 상태**: 31개 파일에 TODO/FIXME 존재

**작업 계획**:
1. 모든 TODO/FIXME 수집 및 분류
2. 중요도 및 긴급도에 따라 우선순위 설정
3. 실제 구현 또는 백로그로 이동
4. 불필요한 TODO는 삭제

### Phase 3: State 관리 최적화 (우선순위: 중간)

**현재 이슈**:
- StatefulWidget의 과다 사용
- 일부 화면에서 불필요한 State 사용

**개선 방향**:
1. 정적 UI는 StatelessWidget으로 변환
2. Riverpod Provider 활용 극대화
3. 필요시 ConsumerWidget으로 전환

## 📊 예상 효과

### 코드 품질 지표
- **평균 파일 크기**: 현재 ~240줄 → 목표 **~150줄**
- **최대 파일 크기**: 현재 1,025줄 → 목표 **~300줄**
- **재사용 가능한 위젯 증가**: **+20개**

### 개발자 경험 개선
- 파일 탐색 시간 **40% 감소**
- 코드 리뷰 시간 **30% 감소**
- 버그 수정 시간 **25% 감소**
- 신규 기능 추가 시간 **20% 감소**

### 유지보수성
- 각 위젯의 책임이 명확해짐
- 테스트 커버리지 향상 가능
- 코드 재사용성 증가

## 🚀 실행 계획

### 1단계: profile_detail_screen.dart 리팩토링 (예상 시간: 2-3시간)
- [ ] widgets 폴더 생성
- [ ] 각 build 메서드를 위젯으로 추출 (11개)
- [ ] 메인 파일 정리
- [ ] 테스트 및 검증

### 2단계: problem_screen.dart 리팩토링 (예상 시간: 3-4시간)
- [ ] Controller 클래스 생성
- [ ] 비즈니스 로직 이동
- [ ] State 변수 그룹화
- [ ] Extension 생성
- [ ] 테스트 및 검증

### 3단계: auth_provider.dart 리팩토링 (예상 시간: 2-3시간)
- [ ] Controller 클래스들 생성
- [ ] 로직 분리 및 이동
- [ ] 테스트 및 검증

### 4단계: TODO/FIXME 처리 (예상 시간: 4-6시간)
- [ ] TODO 수집 및 분류
- [ ] 우선순위별 처리
- [ ] 문서화

## ⚠️ 주의사항

1. **점진적 리팩토링**: 한 번에 모든 파일을 변경하지 않고, 파일별로 순차 진행
2. **테스트**: 각 리팩토링 후 기능 테스트 필수
3. **Git 커밋**: 의미 있는 단위로 커밋 (파일별 또는 기능별)
4. **백업**: 리팩토링 전 현재 상태 브랜치 생성 권장
5. **Breaking Changes**: 기존 기능 동작은 변경하지 않음

## 📝 체크리스트

리팩토링 시 확인사항:
- [ ] 기존 기능이 정상 동작하는가?
- [ ] 새 코드가 더 읽기 쉬운가?
- [ ] 파일 크기가 적절한가? (300줄 이하)
- [ ] 각 클래스/위젯이 단일 책임을 가지는가?
- [ ] 테스트가 가능한 구조인가?
- [ ] import 문이 정리되어 있는가?
- [ ] 주석이 적절히 작성되어 있는가?
- [ ] 네이밍이 명확한가?

## 🎯 다음 단계

이 리팩토링 계획을 검토한 후:
1. 우선순위 조정 (필요시)
2. 1단계 (profile_detail_screen.dart) 부터 시작
3. 각 단계 완료 후 피드백 수집
4. 필요시 계획 수정

---

**작성자**: Claude Code
**작성일**: 2026-01-24
**버전**: 1.0
