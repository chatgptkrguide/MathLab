# problem_screen.dart 리팩토링 계획

**날짜**: 2024-12-13
**현재 상태**: 1,402 lines
**목표**: 400 lines 이하 (메인 파일) + 8-10개 별도 파일

---

## 📊 현재 구조 분석

### Widget Build 메서드 (7개)

| 메서드 | 시작 줄 | 추정 크기 | 설명 |
|--------|---------|-----------|------|
| `_buildHeader()` | 180 | ~165L | 상단 헤더 (뒤로가기, 진행률, XP) |
| `_buildContent()` | 345 | ~44L | 메인 콘텐츠 컨테이너 |
| `_buildCategoryBadge()` | 389 | ~77L | 카테고리 뱃지 |
| `_buildQuestionText()` | 466 | ~14L | 문제 텍스트 |
| `_buildOptions()` | 480 | ~58L | 객관식 선택지 |
| `_buildAnswerInput()` | 538 | ~80L | 주관식 입력 |
| `_buildExplanation()` | 618 | ~181L | 정답 해설 |

### Logic 메서드 (12개)

| 메서드 | 시작 줄 | 추정 크기 | 설명 |
|--------|---------|-----------|------|
| `_setupAnimations()` | 93 | ~24L | 애니메이션 초기화 |
| `_selectAnswer()` | 799 | ~37L | 답 선택 처리 |
| `_submitAnswer()` | 836 | ~121L | 객관식 답안 제출 |
| `_submitShortAnswer()` | 957 | ~145L | 주관식 답안 제출 |
| `_showXPGainAnimation()` | 1102 | ~5L | XP 획득 애니메이션 |
| `_checkAchievements()` | 1107 | ~18L | 업적 확인 |
| `_showAchievementUnlocked()` | 1125 | ~82L | 업적 다이얼로그 |
| `_nextProblem()` | 1207 | ~28L | 다음 문제로 이동 |
| `_showResults()` | 1235 | ~21L | 결과 화면 표시 |
| `_showExitDialog()` | 1256 | ~55L | 종료 다이얼로그 |
| `_scrollToHint()` | 1311 | ~63L | 힌트로 스크롤 |
| `_resetProblemSet()` | 1374 | ~29L | 문제 세트 초기화 |

### State 변수 (44-78줄, ~35줄)

```dart
// 현재 상태
int _currentProblemIndex
int? _selectedAnswerIndex
bool _isAnswerSubmitted
bool _isCorrect

// 세션 통계
int _totalCorrect
int _totalXPEarned
List<ProblemResult> _results

// 연속 정답 스트릭
int _currentStreak
int _maxStreak
bool _showStreakAnimation

// 시간 측정
Stopwatch _stopwatch

// 애니메이션
AnimationController _transitionController
Animation<double> _fadeAnimation
Animation<Offset> _slideAnimation

// 스크롤
ScrollController _scrollController
GlobalKey _hintSectionKey

// 더블 클릭
int? _lastSelectedIndex
DateTime? _lastSelectTime
int? _pulsingIndex

// 주관식
TextEditingController _answerController
FocusNode _answerFocusNode
```

---

## 🎯 분리 전략

### Phase 1: Widget 분리 (6개 파일)

#### 1. `lib/features/problem/widgets/problem_header.dart` (~180줄)
```dart
class ProblemHeader extends ConsumerWidget {
  final double progress;
  final int currentStreak;
  final int totalXPEarned;
  final VoidCallback onClose;

  // _buildHeader() 로직 이동
}
```
**포함 내용**:
- Duolingo-style close button
- 진행률 바
- 스트릭 표시
- XP 표시

---

#### 2. `lib/features/problem/widgets/problem_question.dart` (~150줄)
```dart
class ProblemQuestion extends StatelessWidget {
  final Problem problem;
  final bool showCategoryBadge;

  // _buildQuestionText() + _buildCategoryBadge() 통합
}
```
**포함 내용**:
- 카테고리 뱃지
- 문제 텍스트 (MathText 사용)
- 이미지 (있는 경우)

---

#### 3. `lib/features/problem/widgets/problem_options.dart` (~150줄)
```dart
class ProblemOptions extends ConsumerWidget {
  final Problem problem;
  final int? selectedIndex;
  final bool isSubmitted;
  final bool isCorrect;
  final Function(int) onSelect;
  final int? pulsingIndex;

  // _buildOptions() 로직 이동
}
```
**포함 내용**:
- 객관식 선택지 리스트
- 선택 상태 표시
- 정답/오답 표시

---

#### 4. `lib/features/problem/widgets/problem_answer_input.dart` (~120줄)
```dart
class ProblemAnswerInput extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSubmitted;
  final bool isCorrect;

  // _buildAnswerInput() 로직 이동
}
```
**포함 내용**:
- 주관식 입력 필드
- 키보드 타입 설정
- 포커스 관리

---

#### 5. `lib/features/problem/widgets/problem_explanation.dart` (~200줄)
```dart
class ProblemExplanation extends StatelessWidget {
  final Problem problem;
  final bool isCorrect;
  final int? selectedIndex;
  final String? userAnswer; // 주관식

  // _buildExplanation() 로직 이동
}
```
**포함 내용**:
- 정답/오답 표시
- 정답 해설
- 다음 버튼

---

#### 6. `lib/features/problem/widgets/problem_controls.dart` (~100줄)
```dart
class ProblemControls extends StatelessWidget {
  final bool isAnswerSelected;
  final bool isSubmitted;
  final VoidCallback onSubmit;
  final VoidCallback? onNext;

  // 확인/다음 버튼 로직
}
```
**포함 내용**:
- "확인" 버튼 (답 제출 전)
- "다음" 버튼 (답 제출 후)
- 버튼 상태 관리

---

### Phase 2: State 관리 분리 (1개 파일)

#### `lib/features/problem/state/problem_session_state.dart` (~150줄)
```dart
class ProblemSessionState {
  // 현재 상태
  final int currentProblemIndex;
  final int? selectedAnswerIndex;
  final bool isAnswerSubmitted;
  final bool isCorrect;

  // 세션 통계
  final int totalCorrect;
  final int totalXPEarned;
  final List<ProblemResult> results;

  // 스트릭
  final int currentStreak;
  final int maxStreak;

  // 시간
  final Duration elapsedTime;

  // Copyable state
  ProblemSessionState copyWith({...});

  // Helper getters
  double get progress;
  bool get isLastProblem;
  double get accuracy;
}
```

---

### Phase 3: Logic 분리 (3개 파일)

#### 1. `lib/features/problem/logic/answer_validator.dart` (~100줄)
```dart
class AnswerValidator {
  static bool validateMultipleChoice(Problem problem, int selectedIndex);
  static bool validateShortAnswer(Problem problem, String answer);
  static bool validateNumeric(Problem problem, String answer);

  // 답안 검증 로직만
}
```

---

#### 2. `lib/features/problem/logic/problem_session_manager.dart` (~250줄)
```dart
class ProblemSessionManager {
  // _selectAnswer() 로직
  Future<void> selectAnswer(int index);

  // _submitAnswer() 로직
  Future<void> submitMultipleChoice();

  // _submitShortAnswer() 로직
  Future<void> submitShortAnswer();

  // _nextProblem() 로직
  Future<void> nextProblem();

  // XP, 업적, 스트릭 계산
  int calculateXP(bool isCorrect, int streak);
  void updateStreak(bool isCorrect);
}
```

---

#### 3. `lib/features/problem/dialogs/problem_dialogs.dart` (~150줄)
```dart
// _showExitDialog() 이동
Future<void> showProblemExitDialog(BuildContext context);

// _showAchievementUnlocked() 이동
Future<void> showAchievementUnlockedDialog(
  BuildContext context,
  Achievement achievement
);

// _showResults() - problem_result_dialog.dart 사용 (이미 존재)
```

---

### Phase 4: 메인 파일 재구성 (~350줄)

#### `lib/features/problem/problem_screen.dart` (목표: 350줄)
```dart
// Imports (~30줄)

// ProblemScreen class (~20줄)

// _ProblemScreenState class
class _ProblemScreenState extends ConsumerState<ProblemScreen> {
  // State 변수 (필수만) (~50줄)
  late ProblemSessionState _sessionState;
  late ProblemSessionManager _sessionManager;

  // Controllers
  late AnimationController _transitionController;
  late TextEditingController _answerController;
  late FocusNode _answerFocusNode;
  late ScrollController _scrollController;

  // Lifecycle (~50줄)
  @override
  void initState() { ... }

  @override
  void dispose() { ... }

  // Build (~150줄)
  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // ProblemHeader 사용
              ProblemHeader(
                progress: _sessionState.progress,
                currentStreak: _sessionState.currentStreak,
                totalXPEarned: _sessionState.totalXPEarned,
                onClose: () => showProblemExitDialog(context),
              ),

              // ProblemQuestion 사용
              ProblemQuestion(
                problem: _currentProblem,
              ),

              // ProblemOptions 또는 ProblemAnswerInput
              if (_currentProblem.type == ProblemType.multipleChoice)
                ProblemOptions(
                  problem: _currentProblem,
                  selectedIndex: _sessionState.selectedAnswerIndex,
                  onSelect: _sessionManager.selectAnswer,
                )
              else
                ProblemAnswerInput(
                  controller: _answerController,
                  focusNode: _answerFocusNode,
                ),

              // ProblemExplanation (제출 후)
              if (_sessionState.isAnswerSubmitted)
                ProblemExplanation(
                  problem: _currentProblem,
                  isCorrect: _sessionState.isCorrect,
                ),

              // ProblemControls
              ProblemControls(
                isAnswerSelected: _sessionState.selectedAnswerIndex != null,
                isSubmitted: _sessionState.isAnswerSubmitted,
                onSubmit: _sessionManager.submitMultipleChoice,
                onNext: _sessionManager.nextProblem,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods (~50줄)
  void _handleAnswerSubmitted(bool isCorrect) { ... }
  void _showXPAnimation(int xp) { ... }
}
```

---

## 📋 작업 순서

### Step 1: Widget 분리 (2일)
1. ✅ ProblemHeader 생성 및 테스트
2. ✅ ProblemQuestion 생성 및 테스트
3. ✅ ProblemOptions 생성 및 테스트
4. ✅ ProblemAnswerInput 생성 및 테스트
5. ✅ ProblemExplanation 생성 및 테스트
6. ✅ ProblemControls 생성 및 테스트

### Step 2: Logic 분리 (1일)
1. ✅ AnswerValidator 생성
2. ✅ ProblemSessionState 생성
3. ✅ ProblemSessionManager 생성
4. ✅ ProblemDialogs 생성

### Step 3: 메인 파일 재구성 (1일)
1. ✅ 메인 파일에서 분리된 위젯 import
2. ✅ build 메서드 재작성 (조합만)
3. ✅ 불필요한 코드 제거
4. ✅ Provider 연결 확인

### Step 4: 테스트 및 검증 (1일)
1. ✅ 문제 풀이 전체 플로우 테스트
2. ✅ 애니메이션 작동 확인
3. ✅ XP 획득 확인
4. ✅ 업적 시스템 확인
5. ✅ Flutter analyze 0 errors

---

## 📊 예상 결과

### Before
```
problem_screen.dart: 1,402 lines
```

### After
```
lib/features/problem/
├── problem_screen.dart             (350L) ⬇️ -1,052L
├── widgets/
│   ├── problem_header.dart         (180L) ✨ NEW
│   ├── problem_question.dart       (150L) ✨ NEW
│   ├── problem_options.dart        (150L) ✨ NEW
│   ├── problem_answer_input.dart   (120L) ✨ NEW
│   ├── problem_explanation.dart    (200L) ✨ NEW
│   ├── problem_controls.dart       (100L) ✨ NEW
│   ├── problem_option_button.dart  (existing)
│   ├── problem_result_dialog.dart  (existing)
│   ├── xp_gain_animation.dart      (existing)
│   └── hint_section.dart           (existing)
├── state/
│   └── problem_session_state.dart  (150L) ✨ NEW
├── logic/
│   ├── answer_validator.dart       (100L) ✨ NEW
│   └── problem_session_manager.dart (250L) ✨ NEW
└── dialogs/
    └── problem_dialogs.dart         (150L) ✨ NEW

Total NEW files: 10
Total NEW lines: ~1,500L (organized)
Main file reduction: 1,402L → 350L (75% 감소)
```

---

## ✅ 검증 기준

### 코드 품질
- [ ] 메인 파일 <400 lines
- [ ] 각 위젯 파일 <250 lines
- [ ] Flutter analyze 0 errors
- [ ] No code duplication

### 기능 정상 작동
- [ ] 문제 풀이 정상
- [ ] 객관식/주관식 모두 작동
- [ ] XP 획득 애니메이션
- [ ] 스트릭 계산 정확
- [ ] 업적 시스템 작동
- [ ] 힌트 시스템 작동
- [ ] 결과 화면 표시
- [ ] 뒤로가기 다이얼로그

### 성능
- [ ] 애니메이션 부드럽게
- [ ] 메모리 누수 없음
- [ ] 빌드 시간 개선

---

## 🚧 주의사항

1. **Provider 연결 유지**
   - ref.watch(), ref.read() 사용처 확인
   - ConsumerWidget vs StatelessWidget 선택

2. **State 전달**
   - 분리된 위젯에 필요한 state만 전달
   - Callback 함수 명확히 정의

3. **애니메이션**
   - AnimationController는 메인 파일에 유지
   - Animation 객체만 위젯에 전달

4. **테스트**
   - 각 위젯 분리 후 즉시 테스트
   - 전체 통합 테스트 필수

---

**작성일**: 2024-12-13
**예상 완료**: 2024-12-18 (5일)
