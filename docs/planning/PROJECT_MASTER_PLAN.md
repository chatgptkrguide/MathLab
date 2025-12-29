# MathLab 프로젝트 마스터 플랜

**작성일**: 2024-12-13
**목표**: 듀오링고 스타일 수학 학습 앱 완성
**예상 기간**: 8-10주

---

## 📋 전체 개요

### 현재 상태
- ✅ Firebase 인증 완료 (Google, Kakao, Apple)
- ✅ 기본 게이미피케이션 (XP, 리그, 리더보드)
- ✅ 프리미엄 구독 시스템 (In-App Purchase)
- ✅ 소셜 기능 (친구, 메시지, 채팅)
- ⚠️ 코드 품질 이슈 다수 (대형 파일, 중복 코드, 미사용 코드)
- ❌ MVP 핵심 학습 기능 미완성 (커리큘럼, 적응형 학습)

### 최종 목표
1. 코드 품질: 유지보수 가능하고 확장 가능한 구조
2. MVP 기능: CLAUDE.md 정의 핵심 기능 100% 구현
3. 콘텐츠: 최소 20개 유닛 × 5개 레슨 = 100개 레슨
4. 품질: Flutter analyze 0 errors, 테스트 커버리지 >70%

---

## 🎯 Phase 1: 코드 품질 개선 (2-3주)

### 목표
기술 부채 해결 및 견고한 코드베이스 구축

### Phase 1-1: 미사용 코드 완전 제거 (3-4일)

**삭제 대상**

1. **미사용 Model 파일 (5개)**
   - `lib/data/models/user_account.dart`
   - `lib/data/models/sync_task.dart`
   - `lib/data/models/progress_model.dart`
   - `lib/data/models/wrong_answer.dart`
   - `lib/data/models/sync_status.dart`

2. **미사용 Widget 파일 (3개)**
   - `lib/shared/widgets/feedback/animated_snackbar.dart` (AnimatedSnackbar, AnimatedToast)
   - `lib/shared/utils/error_handler.dart` (SafeAsyncExecutor)
   - `lib/features/profile/widgets/profile_stat_card.dart` (중복)

3. **미사용 Provider (90개 이상)**
   - `lib/data/providers/premium_providers.dart` (27개 중 대부분)
   - `lib/data/providers/lesson_provider.dart` (6개)
   - `lib/data/providers/level_skip_provider.dart` (7개)
   - `lib/data/providers/problem_management_provider.dart` (6개)
   - `lib/data/providers/settings_provider.dart` (7개)
   - 기타 provider 파일들

**작업 순서**
1. 각 파일의 import 사용처 검색 (`grep -r "파일명"`)
2. 사용되지 않는 것 확인
3. 파일 삭제
4. `flutter analyze` 실행하여 에러 확인
5. 에러 발생 시 import 수정

**검증 기준**
- `flutter analyze` 0 errors
- Import 에러 없음
- 앱 실행 정상

---

### Phase 1-2: 중복 위젯 통합 (2-3일)

#### 1. 버튼 위젯 통합 (4개 → 1개)

**현재 상태**
- `lib/shared/widgets/buttons/animated_button.dart`
- `lib/shared/widgets/buttons/duolingo_button.dart`
- `lib/shared/widgets/buttons/primary_button.dart`
- `lib/features/problem/widgets/problem_option_button.dart`

**통합 계획**

**새 파일**: `lib/shared/widgets/buttons/unified_button.dart`

```dart
// 통합 버튼 위젯 - 모든 버튼 스타일 지원
class UnifiedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonStyle style; // primary, secondary, problem, duolingo
  final ButtonSize size; // small, medium, large
  final bool isEnabled;
  final bool isLoading;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final bool enableAnimation;

  // ... 구현
}

enum ButtonStyle { primary, secondary, problem, duolingo, text }
enum ButtonSize { small, medium, large }
```

**작업 순서**
1. `unified_button.dart` 생성
2. 4개 버튼의 공통 기능 추출
3. 스타일별 구현 (named constructor 또는 enum)
4. 기존 버튼 사용처 검색 및 교체
5. 기존 4개 파일 삭제
6. 테스트

**예상 감소**: 400+ lines

#### 2. 카드 위젯 통합 (2개 → 1개)

**현재 상태**
- `lib/shared/widgets/cards/stat_card.dart`
- `lib/features/profile/widgets/profile_stat_card.dart` (거의 동일)

**통합 계획**

**파일**: `lib/shared/widgets/cards/stat_card.dart` (기존 파일 확장)

```dart
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;
  final bool showTrend; // 추가: 트렌드 표시
  final double? trendValue; // 추가

  // ... 구현
}
```

**작업 순서**
1. `stat_card.dart`에 profile_stat_card 기능 병합
2. 사용처 검색 및 교체
3. `profile_stat_card.dart` 삭제
4. 테스트

**예상 감소**: 200+ lines

---

### Phase 1-3: 대형 파일 리팩토링 - problem_screen.dart (3-4일)

**현재**: 1,403 lines (CRITICAL)

**목표**: 400 lines 이하 (메인 파일) + 4-5개 별도 파일

**분리 계획**

```
lib/features/problem/
├── problem_screen.dart (300-400L) - 메인 orchestrator
├── widgets/
│   ├── problem_header.dart (100-150L) - 상단 정보 (XP, 진행률, 하트)
│   ├── problem_content.dart (150-200L) - 문제 본문 표시
│   ├── problem_options.dart (200-250L) - 선택지 UI
│   ├── problem_input_area.dart (150-200L) - 입력 영역
│   ├── problem_controls.dart (100-150L) - 확인/건너뛰기 버튼
│   ├── problem_feedback.dart (150-200L) - 정답/오답 피드백
│   └── problem_hint_panel.dart (100-150L) - 힌트 패널
├── logic/
│   ├── problem_state.dart (150-200L) - 상태 관리
│   └── problem_validator.dart (100-150L) - 답안 검증 로직
└── providers/
    └── problem_provider.dart (기존 유지)
```

**작업 순서**
1. 현재 problem_screen.dart 분석 및 섹션 구분
2. Widget 분리 (Header → Content → Options → Input → Controls → Feedback → Hint)
3. 로직 분리 (State, Validator)
4. 메인 파일에서 분리된 위젯 import 및 조합
5. Provider 연결 확인
6. 기능 테스트 (문제 풀이 전체 플로우)
7. `flutter analyze` 확인

**검증 기준**
- 메인 파일 <400 lines
- 각 위젯 파일 <250 lines
- 앱 실행 시 문제 풀이 정상 작동
- 애니메이션, 사운드, XP 획득 정상

---

### Phase 1-4: 대형 파일 리팩토링 - home_screen_figma.dart (3-4일)

**현재**: 1,249 lines (CRITICAL)

**목표**: 350 lines 이하 (메인 파일) + 3개 별도 파일

**분리 계획**

```
lib/features/home/
├── home_screen_figma.dart (300-350L) - 메인 orchestrator
├── widgets/
│   ├── home_header.dart (150-200L) - 상단 (프로필, 스트릭, XP)
│   ├── home_progress_section.dart (200-250L) - 학습 진행률, 챌린지
│   ├── home_quick_actions.dart (150-200L) - 빠른 액션 버튼들
│   ├── home_curriculum_preview.dart (200-250L) - 커리큘럼 미리보기
│   └── home_stats_summary.dart (150-200L) - 통계 요약
└── providers/
    └── home_provider.dart (기존 유지)
```

**작업 순서**
1. home_screen_figma.dart 분석 및 섹션 구분
2. Widget 분리 (Header → Progress → Actions → Curriculum → Stats)
3. 메인 파일에서 분리된 위젯 조합
4. Provider 연결 확인
5. 네비게이션 링크 확인
6. 기능 테스트
7. `flutter analyze` 확인

**검증 기준**
- 메인 파일 <350 lines
- 각 위젯 파일 <250 lines
- 홈 화면 모든 기능 정상 작동
- 네비게이션 정상

---

### Phase 1-5: Provider 구조 재정리 (2-3일)

**현재 문제**
- 36개 provider 파일이 flat 구조
- 90개 이상의 미사용 provider 정의
- 카테고리화 없음

**목표 구조**

```
lib/data/providers/
├── auth/
│   ├── auth_providers.dart
│   └── user_providers.dart
├── learning/
│   ├── lesson_providers.dart
│   ├── problem_providers.dart
│   └── progress_providers.dart
├── gamification/
│   ├── xp_providers.dart
│   ├── league_providers.dart
│   └── achievement_providers.dart
├── social/
│   ├── friend_providers.dart
│   └── message_providers.dart
├── premium/
│   └── premium_providers.dart
└── settings/
    └── settings_providers.dart
```

**작업 순서**
1. 현재 사용 중인 provider만 식별
2. 카테고리별 폴더 생성
3. Provider 파일 이동 및 재구성
4. 미사용 provider 주석 처리 (삭제 전 확인용)
5. Import 경로 전체 업데이트
6. `flutter analyze` 확인
7. 앱 전체 기능 테스트
8. 문제없으면 미사용 provider 완전 삭제

**검증 기준**
- Provider 카테고리별 정리 완료
- 미사용 provider 제거
- `flutter analyze` 0 errors
- 모든 화면 정상 작동

---

### Phase 1 완료 기준

- [ ] 미사용 파일 8개 삭제 완료
- [ ] 버튼 위젯 4→1 통합 완료
- [ ] 카드 위젯 2→1 통합 완료
- [ ] problem_screen.dart <400 lines
- [ ] home_screen_figma.dart <350 lines
- [ ] Provider 구조 재정리 완료
- [ ] `flutter analyze` 0 errors
- [ ] 앱 전체 기능 정상 작동
- [ ] Git commit 및 push 완료

**예상 코드 감소**: 2,000+ lines
**예상 기간**: 14-18일

---

## 🚀 Phase 2: MVP 핵심 기능 완성 (3-4주)

### 목표
CLAUDE.md에 정의된 핵심 학습 기능 100% 구현

---

### Phase 2-1: 커리큘럼 시스템 설계 및 구현 (5-6일)

#### 데이터 구조 설계

**커리큘럼 계층 구조**
```
Course (코스)
  ├── Unit (유닛) - 예: "기초 산술"
  │     ├── Lesson (레슨) - 예: "덧셈과 뺄셈"
  │     │     ├── Problem (문제) 1
  │     │     ├── Problem (문제) 2
  │     │     └── ...
  │     ├── Lesson 2
  │     └── ...
  ├── Unit 2
  └── ...
```

**새 Model 파일**

1. **`lib/data/models/curriculum/course.dart`**
```dart
class Course {
  final String id;
  final String title;
  final String description;
  final String level; // elementary, middle, high
  final List<Unit> units;
  final int totalXP;
  final String iconUrl;

  // ...
}
```

2. **`lib/data/models/curriculum/unit.dart`**
```dart
class Unit {
  final String id;
  final String courseId;
  final String title;
  final String description;
  final int order; // 순서
  final List<Lesson> lessons;
  final int totalXP;
  final UnitStatus status; // locked, available, completed
  final String iconUrl;

  // ...
}

enum UnitStatus { locked, available, inProgress, completed }
```

3. **`lib/data/models/curriculum/lesson.dart`**
```dart
class Lesson {
  final String id;
  final String unitId;
  final String title;
  final LessonType type; // learning, practice, test, story
  final int order;
  final List<String> problemIds; // Problem 참조
  final int targetXP;
  final int requiredHearts; // 필요한 하트 수
  final LessonStatus status;
  final int? bestScore;
  final DateTime? completedAt;

  // ...
}

enum LessonType { learning, practice, test, story, challenge }
enum LessonStatus { locked, available, inProgress, completed, perfect }
```

4. **`lib/data/models/curriculum/learning_path.dart`**
```dart
class LearningPath {
  final String userId;
  final String courseId;
  final String currentUnitId;
  final String currentLessonId;
  final int totalXP;
  final int completedLessons;
  final Map<String, UnitProgress> unitProgress;
  final List<String> completedLessonIds;
  final DateTime lastStudyDate;

  // ...
}

class UnitProgress {
  final String unitId;
  final int completedLessons;
  final int totalLessons;
  final int earnedXP;
  final int totalXP;
  final double completionRate;

  // ...
}
```

**JSON 데이터 파일**

`assets/data/curriculum/elementary_course.json`
```json
{
  "id": "elementary_math",
  "title": "초등 수학",
  "level": "elementary",
  "units": [
    {
      "id": "unit_01_basic_arithmetic",
      "title": "기초 산술",
      "order": 1,
      "lessons": [
        {
          "id": "lesson_01_addition",
          "title": "덧셈 기초",
          "type": "learning",
          "order": 1,
          "problemIds": ["prob_001", "prob_002", "prob_003"],
          "targetXP": 50
        }
      ]
    }
  ]
}
```

#### 구현 작업

1. **Model 클래스 생성**
   - Course, Unit, Lesson, LearningPath 모델
   - JSON 직렬화/역직렬화 (`fromJson`, `toJson`)

2. **Service 생성**
   - `lib/data/services/curriculum_service.dart`
     - JSON 파일 로드
     - 커리큘럼 데이터 파싱
     - 학습 경로 관리
     - 진행률 계산

3. **Provider 생성**
   - `lib/data/providers/learning/curriculum_providers.dart`
     - 현재 코스, 유닛, 레슨 상태 관리
     - 학습 경로 상태 관리
     - 잠금/해제 로직

4. **UI 구현**
   - `lib/features/curriculum/curriculum_screen.dart`
     - 코스 선택 화면
   - `lib/features/curriculum/unit_list_screen.dart`
     - 유닛 목록 (스크롤 가능한 경로)
   - `lib/features/curriculum/lesson_detail_screen.dart`
     - 레슨 상세 정보

5. **통합**
   - 홈 화면에서 커리큘럼 연결
   - 레슨 → 문제 풀이 화면 연결
   - 진행률 저장 (Firestore)

**검증 기준**
- [ ] 커리큘럼 JSON 파일 로드 성공
- [ ] 유닛/레슨 계층 구조 표시
- [ ] 잠금/해제 로직 정상 작동
- [ ] 레슨 클릭 → 문제 풀이 이동
- [ ] 진행률 계산 정확
- [ ] Firebase 동기화 성공

---

### Phase 2-2: 하트 시스템 구현 (3-4일)

#### 시스템 설계

**하트 규칙**
- 기본 하트: 5개
- 문제 오답 시: -1 하트
- 하트 0 → 학습 중단 (대기 또는 복구 필요)
- 회복 방법:
  1. 시간 경과 (5시간마다 1개, 최대 5개)
  2. 프리미엄 구독자: 무제한
  3. 광고 시청 (선택적)
  4. 친구에게 받기

#### 구현 작업

1. **Model 생성**
   - `lib/data/models/gamification/heart_state.dart`
```dart
class HeartState {
  final int currentHearts;
  final int maxHearts;
  final DateTime? lastLostTime;
  final DateTime? nextRecoveryTime;
  final bool isUnlimited; // 프리미엄 여부

  bool get isFull => currentHearts >= maxHearts;
  bool get isEmpty => currentHearts <= 0;

  Duration? get timeUntilNextHeart {
    if (nextRecoveryTime == null) return null;
    return nextRecoveryTime!.difference(DateTime.now());
  }

  // ...
}
```

2. **Service 생성**
   - `lib/data/services/heart_service.dart`
     - 하트 차감 (`loseHeart()`)
     - 하트 회복 (`recoverHeart()`)
     - 자동 회복 타이머
     - Firebase 동기화

3. **Provider 생성**
   - `lib/data/providers/gamification/heart_providers.dart`
```dart
final heartStateProvider = StateNotifierProvider<HeartNotifier, HeartState>((ref) {
  return HeartNotifier(ref.read);
});

class HeartNotifier extends StateNotifier<HeartState> {
  // 하트 상태 관리
  // 자동 회복 로직
  // ...
}
```

4. **UI 위젯**
   - `lib/shared/widgets/gamification/heart_display.dart`
     - 하트 아이콘 표시 (♥♥♥♡♡)
     - 회복 타이머 표시
   - `lib/features/gamification/heart_empty_dialog.dart`
     - 하트 소진 시 다이얼로그
     - 회복 옵션 제시

5. **통합**
   - 문제 화면에서 하트 표시
   - 오답 시 하트 차감 애니메이션
   - 하트 0 시 문제 풀이 중단
   - 로컬 알림 (하트 회복 시)

**검증 기준**
- [ ] 하트 표시 정확
- [ ] 오답 시 하트 차감 정상
- [ ] 자동 회복 타이머 작동
- [ ] 하트 0 시 학습 중단
- [ ] 프리미엄 사용자 무제한 하트
- [ ] Firebase 동기화 성공

---

### Phase 2-3: 레벨 시스템 세부화 (3-4일)

#### 시스템 설계

**레벨 티어**
- Bronze (브론즈): 0-999 XP
- Silver (실버): 1,000-4,999 XP
- Gold (골드): 5,000-14,999 XP
- Diamond (다이아몬드): 15,000+ XP

**레벨별 혜택**
- Bronze: 기본 기능
- Silver: 특별 뱃지, 프로필 꾸미기 1개
- Gold: 힌트 추가, 프로필 꾸미기 3개
- Diamond: 모든 기능, 특별 애니메이션

#### 구현 작업

1. **Model 확장**
   - `lib/data/models/gamification/level_tier.dart`
```dart
enum LevelTier {
  bronze(
    name: 'Bronze',
    minXP: 0,
    maxXP: 999,
    color: Color(0xFFCD7F32),
    benefits: ['기본 기능'],
  ),
  silver(
    name: 'Silver',
    minXP: 1000,
    maxXP: 4999,
    color: Color(0xFFC0C0C0),
    benefits: ['특별 뱃지', '프로필 꾸미기 1개'],
  ),
  gold(
    name: 'Gold',
    minXP: 5000,
    maxXP: 14999,
    color: Color(0xFFFFD700),
    benefits: ['힌트 추가', '프로필 꾸미기 3개'],
  ),
  diamond(
    name: 'Diamond',
    minXP: 15000,
    maxXP: 999999,
    color: Color(0xFFB9F2FF),
    benefits: ['모든 기능', '특별 애니메이션'],
  );

  const LevelTier({
    required this.name,
    required this.minXP,
    required this.maxXP,
    required this.color,
    required this.benefits,
  });

  final String name;
  final int minXP;
  final int maxXP;
  final Color color;
  final List<String> benefits;

  static LevelTier fromXP(int xp) {
    if (xp < 1000) return bronze;
    if (xp < 5000) return silver;
    if (xp < 15000) return gold;
    return diamond;
  }
}

class LevelInfo {
  final int currentXP;
  final LevelTier tier;
  final int levelInTier; // 티어 내 레벨
  final int xpToNextLevel;
  final double progressToNextLevel;

  // ...
}
```

2. **Service 생성**
   - `lib/data/services/level_service.dart`
     - XP 증가 시 레벨 계산
     - 티어 변경 감지
     - 레벨업 이벤트 발생

3. **Provider 확장**
   - `lib/data/providers/gamification/xp_providers.dart`에 티어 로직 추가
```dart
final levelInfoProvider = Provider<LevelInfo>((ref) {
  final xp = ref.watch(userXPProvider);
  return LevelInfo.fromXP(xp);
});
```

4. **UI 구현**
   - `lib/shared/widgets/gamification/level_badge.dart`
     - 티어 뱃지 표시
   - `lib/shared/widgets/gamification/level_progress_bar.dart`
     - 레벨 진행률 바
   - `lib/features/gamification/level_up_dialog.dart`
     - 레벨업 축하 다이얼로그
     - 티어 업그레이드 애니메이션

5. **통합**
   - 프로필에 티어 표시
   - 홈 화면에 레벨 진행률
   - 문제 정답 시 XP 획득 → 레벨업 체크
   - 티어 변경 시 특별 애니메이션

**검증 기준**
- [ ] XP에 따른 티어 계산 정확
- [ ] 레벨 진행률 표시 정확
- [ ] 레벨업 애니메이션 작동
- [ ] 티어 변경 시 이벤트 발생
- [ ] 티어별 혜택 적용

---

### Phase 2-4: 드래그 앤 드롭 문제 유형 구현 (4-5일)

#### 문제 유형 설계

**드래그 앤 드롭 유형**
1. **수식 조립**: 숫자/기호 드래그하여 수식 완성
2. **순서 맞추기**: 풀이 단계 순서대로 배열
3. **그래프 매칭**: 함수와 그래프 연결

#### 구현 작업

1. **Model 확장**
   - `lib/data/models/problem/problem_type.dart` 확장
```dart
enum ProblemType {
  multipleChoice,
  dragAndDrop, // 추가
  stepByStep, // Phase 2-5
  // ...
}

class DragDropProblem extends Problem {
  final List<DraggableItem> draggables;
  final List<DropZone> dropZones;
  final List<String> correctOrder; // 정답 순서

  // ...
}

class DraggableItem {
  final String id;
  final String content; // 텍스트 또는 이미지 URL
  final DraggableType type; // number, operator, expression

  // ...
}

class DropZone {
  final String id;
  final String? acceptedItemId; // null이면 모든 아이템 가능
  final String? currentItemId; // 현재 놓인 아이템

  // ...
}
```

2. **Widget 생성**
   - `lib/features/problem/widgets/drag_drop/draggable_item_widget.dart`
     - Draggable 위젯 래퍼
   - `lib/features/problem/widgets/drag_drop/drop_zone_widget.dart`
     - DragTarget 위젯 래퍼
   - `lib/features/problem/widgets/drag_drop/drag_drop_problem_widget.dart`
     - 전체 드래그 앤 드롭 UI

3. **로직 구현**
   - `lib/features/problem/logic/drag_drop_validator.dart`
     - 답안 검증
     - 부분 정답 계산

4. **문제 데이터**
   - `assets/problems/drag_drop/` 폴더 생성
   - 샘플 문제 JSON 작성

**예시 문제 JSON**
```json
{
  "id": "dd_001",
  "type": "dragAndDrop",
  "question": "다음 수식을 완성하세요: ___ + ___ = 10",
  "draggables": [
    {"id": "d1", "content": "3", "type": "number"},
    {"id": "d2", "content": "5", "type": "number"},
    {"id": "d3", "content": "7", "type": "number"},
    {"id": "d4", "content": "2", "type": "number"}
  ],
  "dropZones": [
    {"id": "z1", "acceptedItemId": null},
    {"id": "z2", "acceptedItemId": null}
  ],
  "correctAnswer": {
    "z1": "d2",
    "z2": "d2"
  }
}
```

5. **통합**
   - problem_screen.dart에서 문제 유형 분기
   - 드래그 앤 드롭 UI 렌더링
   - 답안 검증 및 피드백

**검증 기준**
- [ ] 드래그 앤 드롭 동작 부드럽게
- [ ] 답안 검증 정확
- [ ] 피드백 표시 정상
- [ ] 다양한 문제 유형 테스트
- [ ] 모바일 터치 최적화

---

### Phase 2-5: 단계별 풀이 시스템 구현 (4-5일)

#### 시스템 설계

**단계별 풀이란?**
- 복잡한 문제를 여러 단계로 나누어 풀이
- 각 단계마다 힌트와 피드백 제공
- 단계 건너뛰기 불가 (순차 진행)
- 부분 점수 지급

**예시: 방정식 풀이**
```
문제: 2x + 5 = 13을 푸시오

Step 1: 양변에서 5를 빼세요
  입력: 2x = ___
  정답: 2x = 8

Step 2: 양변을 2로 나누세요
  입력: x = ___
  정답: x = 4

완료!
```

#### 구현 작업

1. **Model 생성**
   - `lib/data/models/problem/step_problem.dart`
```dart
class StepProblem extends Problem {
  final List<ProblemStep> steps;
  final bool allowSkip; // 단계 건너뛰기 허용 여부

  // ...
}

class ProblemStep {
  final String id;
  final int order;
  final String instruction; // 지시문
  final String question;
  final String answer;
  final String? hint;
  final int xpReward;
  final StepType type; // input, multipleChoice, dragDrop

  // ...
}

enum StepType { input, multipleChoice, dragDrop }

class StepProgress {
  final String problemId;
  final int currentStepIndex;
  final List<bool> completedSteps;
  final int totalSteps;
  final int earnedXP;

  double get progressRate => completedSteps.where((c) => c).length / totalSteps;

  // ...
}
```

2. **Widget 생성**
   - `lib/features/problem/widgets/step_problem/step_problem_widget.dart`
     - 단계별 UI 컨테이너
   - `lib/features/problem/widgets/step_problem/step_indicator.dart`
     - 단계 진행 표시 (1/3, 2/3, 3/3)
   - `lib/features/problem/widgets/step_problem/step_content.dart`
     - 각 단계 내용 표시
   - `lib/features/problem/widgets/step_problem/step_navigation.dart`
     - 이전/다음 단계 버튼

3. **로직 구현**
   - `lib/features/problem/logic/step_validator.dart`
     - 각 단계 답안 검증
     - 부분 점수 계산
     - 진행률 추적

4. **문제 데이터**
   - `assets/problems/step_by_step/` 폴더 생성
   - 샘플 문제 JSON 작성

**예시 문제 JSON**
```json
{
  "id": "step_001",
  "type": "stepByStep",
  "title": "일차방정식 풀이",
  "difficulty": "medium",
  "steps": [
    {
      "order": 1,
      "instruction": "양변에서 5를 빼세요",
      "question": "2x + 5 = 13 → 2x = ___",
      "answer": "8",
      "hint": "13 - 5 = ?",
      "xpReward": 10,
      "type": "input"
    },
    {
      "order": 2,
      "instruction": "양변을 2로 나누세요",
      "question": "2x = 8 → x = ___",
      "answer": "4",
      "hint": "8 ÷ 2 = ?",
      "xpReward": 15,
      "type": "input"
    }
  ],
  "totalXP": 25
}
```

5. **통합**
   - problem_screen.dart에서 단계별 문제 분기
   - 단계 진행 상태 저장 (중간 저장)
   - 단계 완료 시 축하 애니메이션
   - 모든 단계 완료 시 전체 XP 지급

**검증 기준**
- [ ] 단계 순차 진행 정상
- [ ] 각 단계 답안 검증 정확
- [ ] 부분 점수 계산 정확
- [ ] 힌트 표시 정상
- [ ] 진행률 저장/복원 성공
- [ ] 전체 완료 시 XP 지급

---

### Phase 2 완료 기준

- [ ] 커리큘럼 시스템 완성 (20개 유닛 구조)
- [ ] 하트 시스템 완전 작동
- [ ] 레벨 티어 시스템 구현
- [ ] 드래그 앤 드롭 문제 유형 작동
- [ ] 단계별 풀이 시스템 작동
- [ ] 모든 기능 통합 테스트 성공
- [ ] `flutter analyze` 0 errors
- [ ] Firebase 동기화 정상
- [ ] Git commit 및 push 완료

**예상 기간**: 21-28일

---

## 📚 Phase 3: 문제 콘텐츠 확충 (2-3주)

### 목표
최소 20개 유닛 × 5개 레슨 = 100개 레슨 문제 작성

### 커리큘럼 구조

#### Elementary (초등)
1. **기초 산술 (10 units)**
   - Unit 1: 덧셈과 뺄셈
   - Unit 2: 곱셈과 나눗셈
   - Unit 3: 분수 기초
   - Unit 4: 소수 기초
   - Unit 5: 혼합 계산
   - ...

2. **기하 입문 (5 units)**
   - Unit 1: 도형 인식
   - Unit 2: 각도 기초
   - ...

3. **측정 (5 units)**
   - Unit 1: 길이와 무게
   - Unit 2: 시간
   - ...

#### Middle (중등)
1. **대수 (10 units)**
   - Unit 1: 정수와 유리수
   - Unit 2: 일차방정식
   - Unit 3: 부등식
   - ...

2. **기하 (5 units)**
   - Unit 1: 평면도형
   - Unit 2: 입체도형
   - ...

3. **함수 (5 units)**
   - Unit 1: 함수의 개념
   - Unit 2: 일차함수
   - ...

#### High (고등)
1. **고급 대수 (7 units)**
2. **미적분 입문 (7 units)**
3. **확률과 통계 (6 units)**

### 작업 방식

#### 문제 작성 템플릿

**각 레슨당 구성**
- 학습 문제: 5개 (개념 설명 + 쉬운 문제)
- 연습 문제: 10개 (난이도 중간)
- 도전 문제: 5개 (난이도 높음)
- 총 20개 문제/레슨

**문제 JSON 템플릿**
```json
{
  "id": "elem_u01_l01_p001",
  "unitId": "unit_01_addition",
  "lessonId": "lesson_01_single_digit",
  "type": "multipleChoice",
  "difficulty": "easy",
  "question": "3 + 5 = ?",
  "options": ["6", "7", "8", "9"],
  "correctAnswer": "8",
  "explanation": "3에 5를 더하면 8입니다.",
  "hints": ["손가락으로 세어보세요!"],
  "xp": 10,
  "tags": ["덧셈", "한자리수"]
}
```

### 작업 순서

1. **Week 1**: Elementary 20 units (100 lessons, 2000 problems)
2. **Week 2**: Middle 20 units (100 lessons, 2000 problems)
3. **Week 3**: High 20 units (100 lessons, 2000 problems) - 선택적

### 도구 활용

- AI 활용하여 문제 초안 생성
- 수학 교사 검수 (가능하면)
- 난이도 균형 조정
- 중복 제거

### 완료 기준

- [ ] Elementary 100 lessons 완성
- [ ] Middle 100 lessons 완성 (선택적)
- [ ] 각 문제 검증 완료
- [ ] JSON 파일 정리
- [ ] 앱에서 로드 테스트 성공

**예상 기간**: 14-21일

---

## ✅ 최종 검증 및 배포 준비 (1주)

### 검증 항목

1. **코드 품질**
   - [ ] `flutter analyze` 0 errors
   - [ ] 모든 경고 해결
   - [ ] 코드 리뷰 완료

2. **기능 테스트**
   - [ ] 모든 화면 정상 작동
   - [ ] 학습 플로우 완전 테스트
   - [ ] 하트 시스템 테스트
   - [ ] 레벨 시스템 테스트
   - [ ] 커리큘럼 진행 테스트
   - [ ] 프리미엄 구독 테스트

3. **성능**
   - [ ] 앱 시작 시간 <3초
   - [ ] 화면 전환 부드럽게
   - [ ] 메모리 누수 없음

4. **디바이스 테스트**
   - [ ] iOS 실기기 테스트
   - [ ] Android 실기기 테스트
   - [ ] 다양한 화면 크기 테스트

5. **데이터**
   - [ ] Firebase 동기화 완벽
   - [ ] 오프라인 모드 작동
   - [ ] 데이터 손실 없음

6. **문서화**
   - [ ] README.md 업데이트
   - [ ] API 문서 작성
   - [ ] 배포 가이드 작성

### 배포 준비

1. **앱 스토어 준비**
   - 스크린샷 준비
   - 앱 설명 작성
   - 개인정보 처리방침 확인

2. **빌드**
   - iOS Release 빌드
   - Android Release 빌드
   - 서명 및 검증

---

## 📅 전체 타임라인

| Phase | 작업 | 기간 | 상태 |
|-------|------|------|------|
| Phase 1-1 | 미사용 코드 제거 | 3-4일 | ⏳ 대기 |
| Phase 1-2 | 중복 위젯 통합 | 2-3일 | ⏳ 대기 |
| Phase 1-3 | problem_screen 리팩토링 | 3-4일 | ⏳ 대기 |
| Phase 1-4 | home_screen 리팩토링 | 3-4일 | ⏳ 대기 |
| Phase 1-5 | Provider 재정리 | 2-3일 | ⏳ 대기 |
| **Phase 1 완료** | - | **14-18일** | - |
| Phase 2-1 | 커리큘럼 시스템 | 5-6일 | ⏳ 대기 |
| Phase 2-2 | 하트 시스템 | 3-4일 | ⏳ 대기 |
| Phase 2-3 | 레벨 시스템 | 3-4일 | ⏳ 대기 |
| Phase 2-4 | 드래그 앤 드롭 | 4-5일 | ⏳ 대기 |
| Phase 2-5 | 단계별 풀이 | 4-5일 | ⏳ 대기 |
| **Phase 2 완료** | - | **21-28일** | - |
| Phase 3 | 문제 콘텐츠 | 14-21일 | ⏳ 대기 |
| 최종 검증 | 테스트 & 배포 | 5-7일 | ⏳ 대기 |
| **전체 완료** | - | **8-10주** | - |

---

## 🎯 성공 지표

### 코드 품질
- 평균 파일 크기 <300 lines ✅
- 최대 파일 크기 <600 lines ✅
- 미사용 코드 <5% ✅
- 중복 코드 <5% ✅

### 기능 완성도
- CLAUDE.md 핵심 기능 100% ✅
- 최소 100개 레슨 ✅
- 모든 문제 유형 구현 ✅

### 성능
- 앱 시작 <3초 ✅
- 화면 전환 <500ms ✅
- 메모리 사용 <150MB ✅

### 사용자 경험
- 튜토리얼 완료율 >80% 🎯
- 7일 리텐션 >40% 🎯
- 평균 세션 시간 >10분 🎯

---

## 📝 노트

- 각 Phase 완료 시 Git commit 및 push 필수
- 주간 진행 상황 리뷰
- 블로커 발생 시 즉시 조정
- 품질 > 속도 우선

**작성자**: Claude Code
**최종 업데이트**: 2024-12-13
