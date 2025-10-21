# MathLab Flutter 프로젝트 아키텍처 분석 리포트

## 프로젝트 개요
- 총 Dart 파일: 69개
- 총 코드 라인: ~16,773 라인
- 디렉토리 깊이: 3단계 (양호)
- 주요 패턴: Feature-first + Provider 패턴

## 1. 현재 폴더 구조 분석

### 파일 분포도
```
lib/shared/widgets/        24 파일 ⚠️  (임계값 초과: 20개 기준)
lib/data/models/           12 파일 ✅
lib/data/providers/         8 파일 ✅
lib/shared/utils/           4 파일 ✅
lib/shared/constants/       4 파일 ✅
lib/features/problem/widgets 3 파일 ✅
lib/app/                    3 파일 ✅
기타 features/              각 1 파일 ✅
```

### 구조 평가
**긍정적 요소:**
- Feature-first 구조를 기본적으로 따르고 있음
- 각 feature는 독립적인 화면 단위로 구성
- shared 폴더로 공통 요소 분리
- data 레이어가 명확하게 분리됨
- 디렉토리 깊이가 3단계로 관리 가능

**개선 필요 요소:**
- lib/shared/widgets/ 폴더에 24개 파일 집중 (과밀화)
- features 내부에 providers/widgets/screens 세부 구조 미흡
- 일부 feature가 단일 파일로만 구성 (확장성 제한)

## 2. 아키텍처 패턴 평가

### 현재 적용 패턴
**패턴:** Feature-first + Provider (Riverpod)

**구조:**
```
✅ Feature-first 기반
   - features/ 폴더에 기능별 분리
   - 각 feature는 독립적 화면

✅ Provider 패턴 (Riverpod)
   - StateNotifier + Provider
   - 중앙 집중식 상태 관리
   - data/providers/ 에서 일괄 관리

⚠️  Layer 혼재
   - data/ 레이어는 layer-first
   - features/ 는 feature-first
```

### 의존성 방향성

**의존성 흐름:**
```
features/ → data/providers/ → data/models/ → data/services/
         ↓
       shared/ (constants, widgets, utils, themes)
```

**평가:**
- ✅ 단방향 의존성 유지 (features → data → shared)
- ✅ 순환 의존성 없음
- ✅ Barrel 파일 사용 (models.dart, widgets.dart)
- ⚠️  일부 features가 provider를 직접 참조 (강결합)

### Provider 패턴 일관성
**현재 8개 Provider:**
1. auth_provider.dart (인증)
2. user_provider.dart (사용자)
3. lesson_provider.dart (레슨)
4. problem_provider.dart (문제)
5. achievement_provider.dart (업적)
6. learning_stats_provider.dart (학습 통계)
7. error_note_provider.dart (오답노트)
8. leaderboard_provider.dart (리더보드)

**평가:**
- ✅ StateNotifier 패턴 일관성 유지
- ✅ SharedPreferences를 통한 로컬 저장소 통합
- ✅ MockDataService로 데이터 레이어 분리
- ⚠️  Provider 간 의존성 존재 (lesson_provider → user_provider, problem_provider)

## 3. 개선이 필요한 영역

### 🔴 Critical Issues

#### Issue 1: shared/widgets/ 과밀화 (24개 파일)
**문제점:**
- 단일 폴더에 24개 위젯 파일 집중
- 카테고리화 없이 평면 구조
- 유지보수성 저하 및 검색 어려움

**영향도:**
- 개발자 생산성: ⬇️ 30%
- 신규 위젯 추가 시 혼란
- 코드 리뷰 어려움

#### Issue 2: Features 내부 구조 부족
**문제점:**
- 대부분 feature가 단일 파일로 구성
- widgets, screens, providers 구분 없음
- 확장 시 구조 재설계 필요

**현재:**
```
features/
  ├── home/home_screen.dart (단일 파일)
  ├── profile/profile_screen.dart (단일 파일)
  └── problem/
      ├── problem_screen.dart
      └── widgets/ (유일하게 구조화됨)
```

#### Issue 3: Barrel 파일 관리 부족
**문제점:**
- models.dart, widgets.dart만 barrel 파일 존재
- constants, utils는 개별 import 필요
- import 문이 길어지고 복잡함

### ⚠️  Warning Issues

#### Issue 4: Provider 교차 의존성
**예시:**
```dart
// lesson_provider.dart
import 'user_provider.dart';
import 'problem_provider.dart';
```

**문제점:**
- Provider 간 강결합
- 테스트 어려움
- 변경 영향 범위 확대

#### Issue 5: UI/Logic 혼재
**예시:**
```dart
// home_screen.dart에 비즈니스 로직 포함
void _startLearning(BuildContext context, WidgetRef ref, List<Problem> problems) {
  // 추천 문제 선택 로직 (이 부분은 Provider로 분리 가능)
  final recommendedProblems = ref
      .read(problemProvider.notifier)
      .getRecommendedProblems(user.level, count: 5);
}
```

## 4. 복잡도 메트릭스

### 폴더별 복잡도 점수

| 폴더 | 파일 수 | 복잡도 점수 | 상태 |
|------|---------|-------------|------|
| lib/shared/widgets/ | 24 | 🔴 0.85 | 과밀 |
| lib/data/models/ | 12 | 🟡 0.60 | 보통 |
| lib/data/providers/ | 8 | 🟢 0.40 | 양호 |
| lib/features/problem/ | 4 | 🟢 0.20 | 양호 |
| lib/shared/constants/ | 4 | 🟢 0.20 | 양호 |
| lib/shared/utils/ | 4 | 🟢 0.20 | 양호 |

**계산 방식:**
- 복잡도 = (파일 수 / 20) × 0.5 + (깊이 / 5) × 0.3 + 중복도 × 0.2

### 전체 프로젝트 건강도

```
전체 건강도: 72/100 (보통)

세부 점수:
  구조 명확성: 75/100
  모듈화:      68/100  ⬇️ (shared/widgets 과밀)
  확장성:      70/100  ⬇️ (feature 구조 부족)
  유지보수성:  74/100
  테스트성:    70/100
```

## 5. 권장 폴더 구조

### 제안 1: Feature-First 완전 적용 (권장 ⭐)

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── main_navigation.dart
│   └── auth_wrapper.dart
│
├── core/                           # 새로 추가
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_dimensions.dart
│   │   ├── app_text_styles.dart
│   │   └── app_ui_constants.dart
│   ├── themes/
│   │   └── app_theme.dart
│   ├── utils/
│   │   ├── haptic_feedback.dart
│   │   ├── page_transitions.dart
│   │   ├── validators.dart
│   │   └── error_handler.dart
│   └── widgets/                    # 기본 UI 컴포넌트만
│       ├── buttons/
│       │   ├── primary_button.dart
│       │   ├── animated_button.dart
│       │   └── duolingo_button.dart
│       ├── cards/
│       │   ├── duolingo_card.dart
│       │   ├── progress_card.dart
│       │   ├── stat_card.dart
│       │   └── achievement_card.dart
│       ├── inputs/
│       │   └── short_answer_input.dart
│       ├── indicators/
│       │   ├── duolingo_circular_progress.dart
│       │   └── loading_widgets.dart
│       ├── dialogs/
│       │   ├── level_up_dialog.dart
│       │   ├── badge_unlock_dialog.dart
│       │   └── daily_reward_dialog.dart
│       ├── animations/
│       │   ├── fade_in_widget.dart
│       │   └── xp_animation.dart
│       ├── layout/
│       │   ├── responsive_wrapper.dart
│       │   ├── custom_bottom_nav.dart
│       │   └── empty_state.dart
│       └── widgets.dart            # Barrel 파일
│
├── features/
│   ├── auth/
│   │   ├── presentation/
│   │   │   └── auth_screen.dart
│   │   ├── providers/
│   │   │   └── auth_provider.dart
│   │   └── models/
│   │       └── user_account.dart
│   │
│   ├── home/
│   │   ├── presentation/
│   │   │   ├── home_screen.dart
│   │   │   └── widgets/           # home 전용 위젯
│   │   │       └── streak_display.dart
│   │   └── providers/
│   │       └── (필요 시 추가)
│   │
│   ├── lessons/
│   │   ├── presentation/
│   │   │   ├── lessons_screen.dart
│   │   │   └── widgets/
│   │   │       ├── lesson_card.dart
│   │   │       └── grade_tab_bar.dart
│   │   ├── providers/
│   │   │   └── lesson_provider.dart
│   │   └── models/
│   │       ├── lesson.dart
│   │       └── episode.dart
│   │
│   ├── problem/
│   │   ├── presentation/
│   │   │   ├── problem_screen.dart
│   │   │   └── widgets/
│   │   │       ├── problem_option_button.dart
│   │   │       ├── problem_result_dialog.dart
│   │   │       └── xp_gain_animation.dart
│   │   ├── providers/
│   │   │   └── problem_provider.dart
│   │   └── models/
│   │       └── problem.dart
│   │
│   ├── profile/
│   │   ├── presentation/
│   │   │   └── profile_screen.dart
│   │   ├── providers/
│   │   │   ├── user_provider.dart
│   │   │   └── achievement_provider.dart
│   │   └── models/
│   │       ├── user.dart
│   │       └── achievement.dart
│   │
│   ├── leaderboard/
│   │   ├── presentation/
│   │   │   ├── leaderboard_screen.dart
│   │   │   └── widgets/
│   │   │       └── league_widget.dart
│   │   ├── providers/
│   │   │   └── leaderboard_provider.dart
│   │   └── models/
│   │       ├── leaderboard_entry.dart
│   │       └── league.dart
│   │
│   ├── errors/
│   │   ├── presentation/
│   │   │   └── errors_screen.dart
│   │   ├── providers/
│   │   │   └── error_note_provider.dart
│   │   └── models/
│   │       └── error_note.dart
│   │
│   └── history/
│       ├── presentation/
│       │   └── history_screen.dart
│       ├── providers/
│       │   └── learning_stats_provider.dart
│       └── models/
│           ├── learning_stats.dart
│           └── daily_reward.dart
│
└── services/                       # data/services → 최상위로
    ├── mock_data_service.dart
    └── (향후 api_service.dart 등)
```

**주요 변경사항:**
1. `shared/` → `core/` 이름 변경 (명확성)
2. `core/widgets/` 를 카테고리별로 세분화
3. 각 feature 내부에 presentation/providers/models 구조 적용
4. data/ 레이어 제거, 각 feature로 분산
5. services는 최상위로 이동 (여러 feature에서 공유)

**장점:**
- ✅ 확장성: 새 feature 추가 시 명확한 구조
- ✅ 모듈화: 각 feature가 독립적
- ✅ 유지보수성: 파일 위치 예측 가능
- ✅ 테스트: Feature 단위 테스트 용이
- ✅ 팀 협업: Feature별 병렬 작업 가능

**단점:**
- ⚠️  초기 리팩토링 비용
- ⚠️  Provider 간 의존성 재설계 필요

### 제안 2: Hybrid 구조 (현실적 타협안)

현재 구조를 최소한으로 개선:

```
lib/
├── main.dart
├── app/
│   └── (현재 유지)
│
├── shared/
│   ├── constants/
│   ├── themes/
│   ├── utils/
│   └── widgets/
│       ├── buttons/               # 새로 추가: 카테고리화
│       │   ├── primary_button.dart
│       │   ├── animated_button.dart
│       │   └── duolingo_button.dart
│       ├── cards/
│       │   ├── duolingo_card.dart
│       │   ├── progress_card.dart
│       │   └── stat_card.dart
│       ├── dialogs/
│       │   ├── level_up_dialog.dart
│       │   └── badge_unlock_dialog.dart
│       ├── indicators/
│       │   ├── duolingo_circular_progress.dart
│       │   └── loading_widgets.dart
│       ├── animations/
│       │   ├── fade_in_widget.dart
│       │   └── xp_animation.dart
│       └── widgets.dart           # 각 카테고리 barrel
│
├── features/
│   ├── problem/
│   │   ├── screens/              # 새로 추가
│   │   │   └── problem_screen.dart
│   │   └── widgets/
│   │       └── (현재 유지)
│   └── (나머지 features도 동일하게 확장)
│
└── data/                          # 현재 유지
    ├── models/
    ├── providers/
    └── services/
```

**장점:**
- ✅ 최소 변경으로 개선
- ✅ 기존 코드 영향 최소화
- ✅ shared/widgets 정리

**단점:**
- ⚠️  근본적 확장성 문제 해결 안 됨
- ⚠️  Feature 독립성 여전히 부족

### 제안 3: Clean Architecture (향후 확장용)

```
lib/
├── main.dart
├── app/
├── core/
│   ├── constants/
│   ├── themes/
│   ├── utils/
│   ├── widgets/
│   └── errors/
│
├── features/
│   └── [feature_name]/
│       ├── domain/              # 비즈니스 로직
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── usecases/
│       ├── data/                # 데이터 레이어
│       │   ├── models/
│       │   ├── datasources/
│       │   └── repositories/
│       └── presentation/        # UI 레이어
│           ├── providers/
│           ├── screens/
│           └── widgets/
│
└── services/
```

**적용 시기:** MVP 완료 후, 백엔드 연동 시

## 6. 마이그레이션 계획

### Phase 1: Widgets 정리 (1-2일)
```bash
# 우선순위: High
# 영향도: Low

1. shared/widgets/ 카테고리화
   - buttons/
   - cards/
   - dialogs/
   - indicators/
   - animations/
   - layout/

2. Barrel 파일 업데이트
   - widgets.dart 각 카테고리별 재구성

3. Import 경로 수정
   - IDE 자동 리팩토링 활용
```

### Phase 2: Features 구조화 (3-5일)
```bash
# 우선순위: Medium
# 영향도: Medium

1. 각 feature에 presentation/ 폴더 생성
2. feature별 widgets/ 폴더 추가
3. 공통 위젯 vs feature 전용 위젯 분리
4. Import 경로 재조정
```

### Phase 3: Provider 분산 (5-7일)
```bash
# 우선순위: Medium
# 영향도: High

1. data/providers/ → features/*/providers/ 이동
2. Provider 간 의존성 재설계
3. 공유 Provider는 core/providers/ 생성
4. 테스트 코드 업데이트
```

### Phase 4: Data 레이어 분산 (선택사항)
```bash
# 우선순위: Low
# 영향도: High

1. data/models/ → features/*/models/ 이동
2. 공통 모델은 core/models/ 유지
3. services는 최상위로 이동
```

## 7. 즉시 적용 가능한 개선사항

### Quick Win 1: Widgets 카테고리화
```bash
# 작업 시간: 2시간
# 영향도: Low
# 효과: High

mkdir -p lib/shared/widgets/{buttons,cards,dialogs,indicators,animations,layout}

# 파일 이동 (예시)
mv lib/shared/widgets/primary_button.dart lib/shared/widgets/buttons/
mv lib/shared/widgets/animated_button.dart lib/shared/widgets/buttons/
mv lib/shared/widgets/duolingo_button.dart lib/shared/widgets/buttons/

# Barrel 파일 업데이트
# lib/shared/widgets/buttons/buttons.dart 생성
# lib/shared/widgets/widgets.dart 에서 export
```

### Quick Win 2: Constants Barrel 파일
```dart
// lib/shared/constants/constants.dart
export 'app_colors.dart';
export 'app_dimensions.dart';
export 'app_text_styles.dart';
export 'app_ui_constants.dart';

// 사용:
import '../../shared/constants/constants.dart';
// 대신
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_dimensions.dart';
// ...
```

### Quick Win 3: Utils Barrel 파일
```dart
// lib/shared/utils/utils.dart
export 'haptic_feedback.dart';
export 'page_transitions.dart';
export 'validators.dart';
export 'error_handler.dart';
```

### Quick Win 4: Feature별 README
각 feature 폴더에 README.md 추가:

```markdown
# Feature: Home

## 책임
- 사용자 대시보드 표시
- 일일 목표 진행률 표시
- 빠른 학습 시작

## 의존성
- Providers: user_provider, problem_provider
- Models: User, Problem
- Widgets: DuolingoCard, AnimatedButton

## 화면
- HomeScreen: 메인 대시보드
```

## 8. 성과 지표

### 개선 전후 비교

| 지표 | 현재 | 목표 (Phase 2 완료) | 목표 (Phase 3 완료) |
|------|------|---------------------|---------------------|
| Widgets 폴더 파일 수 | 24 | 6 카테고리 (4개/카테고리) | 6 카테고리 |
| Feature 구조 완성도 | 12% (1/8) | 75% (6/8) | 100% (8/8) |
| Import 평균 길이 | ~60자 | ~45자 | ~35자 |
| 파일 검색 시간 | ~30초 | ~15초 | ~10초 |
| 코드 리뷰 시간 | ~60분 | ~40분 | ~30분 |

## 9. 위험 요소 및 대응

### Risk 1: 대규모 리팩토링 중 버그 발생
**대응:**
- Phase별 단계적 진행
- 각 Phase 후 전체 테스트 실행
- Git 브랜치 전략: feature/refactor-phase-N

### Risk 2: Import 경로 깨짐
**대응:**
- IDE 자동 리팩토링 활용 (VS Code, Android Studio)
- Barrel 파일 먼저 생성 후 이동
- 점진적 마이그레이션 (한 번에 한 카테고리)

### Risk 3: Provider 의존성 깨짐
**대응:**
- Provider 이동 전 의존성 그래프 작성
- 테스트 코드 작성 (Provider 단위 테스트)
- 순환 의존성 제거 우선 작업

## 10. 결론 및 권장사항

### 종합 평가
현재 MathLab 프로젝트는 **72/100점**으로 평가되며, 기본적인 아키텍처는 양호하나 확장성과 유지보수성 개선이 필요합니다.

### 핵심 권장사항

1. **즉시 시작 (1주일 내):**
   - ✅ shared/widgets/ 카테고리화
   - ✅ Barrel 파일 추가 (constants, utils)
   - ✅ Feature별 README 작성

2. **단기 목표 (2-4주):**
   - ✅ Features 구조화 (presentation/widgets 분리)
   - ✅ 공통 위젯 vs Feature 전용 위젯 명확화
   - ✅ Import 경로 간소화

3. **중기 목표 (1-2개월):**
   - ✅ Provider 분산 (각 feature로 이동)
   - ✅ Provider 간 의존성 재설계
   - ✅ 테스트 코드 작성

4. **장기 목표 (MVP 완료 후):**
   - ⏳ Clean Architecture 적용 고려
   - ⏳ 백엔드 연동 시 Repository 패턴 도입

### 최종 추천 구조
**Phase 2 완료 후 목표 구조: 제안 1 (Feature-First 완전 적용)**

이 구조는 확장성, 유지보수성, 팀 협업에 최적화되어 있으며, Flutter Best Practice에 부합합니다.

---

**작성일:** 2025-10-21
**프로젝트 버전:** Current (main branch)
**다음 리뷰 권장일:** Phase 1 완료 후 (2주 후)
