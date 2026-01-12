import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../shared/constants/app_dimensions.dart';
import '../../shared/constants/game_constants.dart';
import '../../shared/widgets/layout/responsive_wrapper.dart';
import '../../shared/utils/haptic_feedback.dart';
import '../../data/models/models.dart';
import '../../data/providers/user/user_provider.dart';
import '../../data/providers/learning/problem_provider.dart';
import '../../data/providers/learning/lesson_provider.dart';
import '../../data/providers/learning/error_note_provider.dart';
import '../../data/providers/learning/wrong_answer_provider.dart';
import '../../data/providers/gamification/achievement_provider.dart';
import '../../data/providers/learning/hint_provider_optimized.dart';
import '../../data/providers/learning/study_history_provider.dart';
import '../../data/services/sound_service.dart';
import '../../data/services/analytics_service.dart';
import 'widgets/problem_result_dialog.dart';
import 'widgets/xp_gain_animation.dart';
import 'widgets/hint_section.dart';
import 'widgets/problem_header.dart';
import 'widgets/problem_question.dart';
import 'widgets/problem_options.dart';
import 'widgets/problem_answer_input.dart';
import 'widgets/problem_explanation.dart';
import 'widgets/problem_controls.dart';
import 'widgets/exit_confirmation_dialog.dart';
import 'widgets/heart_depleted_dialog.dart';

/// 문제 풀이 화면
/// 실제 Problem 데이터 기반, 경험치/뱃지 시스템 통합
class ProblemScreen extends ConsumerStatefulWidget {
  final String lessonId;
  final List<Problem> problems;

  const ProblemScreen({
    super.key,
    required this.lessonId,
    required this.problems,
  });

  @override
  ConsumerState<ProblemScreen> createState() => _ProblemScreenState();
}

class _ProblemScreenState extends ConsumerState<ProblemScreen>
    with SingleTickerProviderStateMixin {
  // 현재 상태
  int _currentProblemIndex = 0;
  int? _selectedAnswerIndex;
  bool _isAnswerSubmitted = false;
  bool _isCorrect = false;

  // 세션 통계
  int _totalCorrect = 0;
  int _totalXPEarned = 0;
  final List<ProblemResult> _results = [];

  // 연속 정답 스트릭
  int _currentStreak = 0;
  int _maxStreak = 0;
  bool _showStreakAnimation = false;

  // 시간 측정
  final Stopwatch _stopwatch = Stopwatch();

  // 애니메이션
  late AnimationController _transitionController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // 스크롤 컨트롤러 (힌트로 스크롤하기 위해)
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _hintSectionKey = GlobalKey();

  // 더블 클릭 관련 (객관식 답 선택용)
  int? _lastSelectedIndex;
  DateTime? _lastSelectTime;
  int? _pulsingIndex;

  // 주관식 답안 입력
  final TextEditingController _answerController = TextEditingController();
  final FocusNode _answerFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // 문제 리스트가 비어있으면 초기화 중단
    if (widget.problems.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('문제 데이터를 불러올 수 없습니다.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      });
      return;
    }

    _setupAnimations();
    _stopwatch.start(); // 타이머 시작

    // 첫 문제의 힌트 시스템 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.problems.isNotEmpty) {
        ref.read(hintProviderOptimized.notifier).startProblem(_currentProblem.id);
      }
    });
  }

  void _setupAnimations() {
    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _transitionController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0), // 오른쪽에서 시작
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _transitionController,
        curve: Curves.easeOutCubic,
      ),
    );

    _transitionController.forward();
  }

  @override
  void deactivate() {
    // 힌트 시스템 종료 (dispose 전에 호출됨)
    // Future로 래핑하여 위젯 트리 빌드 완료 후에 실행
    if (mounted) {
      Future(() {
        ref.read(hintProviderOptimized.notifier).endProblem();
      });
    }
    super.deactivate();
  }

  @override
  void dispose() {
    _transitionController.dispose();
    _scrollController.dispose();
    _answerController.dispose();
    _answerFocusNode.dispose();
    super.dispose();
  }

  Problem get _currentProblem {
    if (widget.problems.isEmpty || _currentProblemIndex >= widget.problems.length) {
      throw StateError('No problems available or index out of range');
    }
    return widget.problems[_currentProblemIndex];
  }

  double get _progress {
    if (widget.problems.isEmpty) return 0.0;
    return (_currentProblemIndex + 1) / widget.problems.length;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // 뒤로가기 막기
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _showExitDialog(); // 뒤로가기 시 다이얼로그 표시
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.mathBlue, // GoMath 파란색
        body: SafeArea(
          child: ResponsiveWrapper(
            child: Column(
              children: [
                ProblemHeader(
                  progress: _progress,
                  currentStreak: _currentStreak,
                  showStreakAnimation: _showStreakAnimation,
                  onClose: _showExitDialog,
                ),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildContent(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Floating hint button (답 제출 전에만 표시)
        floatingActionButton: _buildFloatingHintButton(),
      ),
    );
  }

  /// 메인 콘텐츠
  Widget _buildContent() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController, // 스크롤 컨트롤러 추가
              padding: const EdgeInsets.all(AppDimensions.paddingXL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProblemQuestion(
                    problem: _currentProblem,
                    showCategoryBadge: true,
                  ),
                  // 힌트 섹션 (답 제출 전에만 표시)
                  if (!_isAnswerSubmitted)
                    Container(
                      key: _hintSectionKey, // GlobalKey 추가
                      child: HintSection(problem: _currentProblem),
                    ),
                  const SizedBox(height: AppDimensions.spacingXXL),
                  _buildAnswerArea(),
                  if (_isAnswerSubmitted) ...[
                    const SizedBox(height: AppDimensions.spacingXL),
                    ProblemExplanation(
                      problem: _currentProblem,
                      isCorrect: _isCorrect,
                    ),
                  ],
                ],
              ),
            ),
          ),
          ProblemControls(
            problem: _currentProblem,
            currentProblemIndex: _currentProblemIndex,
            totalProblems: widget.problems.length,
            isAnswerSelected: _selectedAnswerIndex != null,
            isAnswerSubmitted: _isAnswerSubmitted,
            isCorrect: _isCorrect,
            userInput: _answerController.text,
            onSubmit: _submitShortAnswer,
            onNext: _nextProblem,
            onShowResults: _showResults,
          ),
        ],
      ),
    );
  }

  /// 답안 영역 (객관식/주관식 분기)
  Widget _buildAnswerArea() {
    // 주관식/계산 문제인 경우
    if (_currentProblem.type == ProblemType.shortAnswer ||
        _currentProblem.type == ProblemType.calculation) {
      return ProblemAnswerInput(
        problem: _currentProblem,
        controller: _answerController,
        focusNode: _answerFocusNode,
        isAnswerSubmitted: _isAnswerSubmitted,
        isCorrect: _isCorrect,
        correctAnswerText: _getCorrectAnswerText(),
        onChanged: () {
          setState(() {
            // 입력이 있으면 버튼 활성화
          });
        },
        onSubmitted: _submitShortAnswer,
      );
    }

    // 객관식 문제
    return ProblemOptions(
      problem: _currentProblem,
      selectedIndex: _selectedAnswerIndex,
      isAnswerSubmitted: _isAnswerSubmitted,
      onSelect: _selectAnswer,
      pulsingIndex: _pulsingIndex,
    );
  }

  /// 정답 텍스트 가져오기
  String _getCorrectAnswerText() {
    // 주관식 문제의 경우 (answer가 String인 경우)
    final stringAnswer = _currentProblem.getAnswerAsString();
    if (stringAnswer != null) {
      return stringAnswer;
    }

    // 객관식 문제의 경우 (answer가 int인 경우)
    final intAnswer = _currentProblem.getAnswerAsInt();
    if (intAnswer != null && _currentProblem.choices.isNotEmpty) {
      if (intAnswer >= 0 && intAnswer < _currentProblem.choices.length) {
        return _currentProblem.choices[intAnswer];
      }
    }

    return '알 수 없음';
  }

  /// 답 선택 (객관식 더블 클릭 자동 제출)
  void _selectAnswer(int index) async {
    final now = DateTime.now();

    // 같은 답을 500ms 이내에 다시 선택하면 자동 제출
    if (_lastSelectedIndex == index &&
        _lastSelectTime != null &&
        now.difference(_lastSelectTime!).inMilliseconds <=
            GameConstants.doubleClickSubmitTimeMs) {
      // 두 번째 클릭 -> 자동 제출
      await AppHapticFeedback.success();
      setState(() {
        _pulsingIndex = null;
        _lastSelectedIndex = null;
        _lastSelectTime = null;
      });
      _submitAnswer();
    } else {
      // 첫 클릭 또는 다른 답 선택
      await AppHapticFeedback.selectionClick();
      setState(() {
        _selectedAnswerIndex = index;
        _lastSelectedIndex = index;
        _lastSelectTime = now;
        _pulsingIndex = index;
      });

      // 500ms 후에 깜빡임 중지
      Future.delayed(
          const Duration(milliseconds: GameConstants.doubleClickSubmitTimeMs),
          () {
        if (mounted && _pulsingIndex == index) {
          setState(() {
            _pulsingIndex = null;
          });
        }
      });
    }
  }

  /// 답 제출 (객관식)
  void _submitAnswer() async {
    if (_selectedAnswerIndex == null) return;

    _isCorrect = _currentProblem.isCorrectAnswer(_selectedAnswerIndex!);

    // 사용자 답안 텍스트
    final userAnswerText = _currentProblem.choices.isNotEmpty &&
            _selectedAnswerIndex! < _currentProblem.choices.length
        ? _currentProblem.choices[_selectedAnswerIndex!]
        : '선택 없음';

    await _processAnswerSubmission(
      selectedAnswerIndex: _selectedAnswerIndex,
      userAnswerText: userAnswerText,
    );
  }

  /// 주관식 답안 제출
  void _submitShortAnswer() async {
    if (_answerController.text.isEmpty) return;

    // 답안 정규화 (공백 제거)
    final userAnswer = _answerController.text.trim();

    // 정답 가져오기 (타입 안전하게)
    final correctAnswerString = _currentProblem.getAnswerAsString();
    if (correctAnswerString == null) {
      // 답변이 String이 아닌 경우 오류 처리
      _isCorrect = false;
      return;
    }
    final correctAnswer = correctAnswerString.trim();

    // 정답 체크
    if (_currentProblem.type == ProblemType.calculation) {
      _isCorrect = _compareNumbers(userAnswer, correctAnswer);
    } else {
      _isCorrect = userAnswer.toLowerCase() == correctAnswer.toLowerCase();
    }

    await _processAnswerSubmission(
      selectedAnswerIndex: null,
      userAnswerText: userAnswer,
    );
  }

  /// 답안 제출 공통 처리 로직
  Future<void> _processAnswerSubmission({
    required int? selectedAnswerIndex,
    required String userAnswerText,
  }) async {
    final user = ref.read(userProvider);
    if (user == null) {
      // 사용자가 로그인하지 않은 경우 경고
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인이 필요합니다.')),
        );
      }
      return;
    }

    setState(() {
      _isAnswerSubmitted = true;
    });

    // 시간 측정
    _stopwatch.stop();
    final timeSpent = _stopwatch.elapsed.inSeconds;

    // 결과 저장
    final result = ProblemResult(
      problemId: _currentProblem.id,
      userId: user.id,
      selectedAnswerIndex: selectedAnswerIndex,
      textAnswer: selectedAnswerIndex == null ? userAnswerText : null,
      isCorrect: _isCorrect,
      solvedAt: DateTime.now(),
      timeSpentSeconds: timeSpent,
      xpEarned: _isCorrect ? _currentProblem.xpReward : 0,
    );

    _results.add(result);
    await ref.read(problemResultsProvider.notifier).addResult(result);

    if (_isCorrect) {
      await _handleCorrectAnswer();
    } else {
      await _handleWrongAnswer(user.id, userAnswerText, selectedAnswerIndex);
    }

    // 레슨 진행률 업데이트
    await ref.read(lessonProvider.notifier).onProblemSolved(
          _currentProblem.id,
          _isCorrect,
        );
  }

  /// 정답 처리
  Future<void> _handleCorrectAnswer() async {
    // 스트릭 증가
    _currentStreak++;
    if (_currentStreak > _maxStreak) {
      _maxStreak = _currentStreak;
    }

    // 스트릭 보너스 XP 계산
    final bonusXP = _calculateStreakBonus();

    _totalCorrect++;
    _totalXPEarned += _currentProblem.xpReward + bonusXP;

    // Analytics: 문제 정답 기록
    await AnalyticsService().logProblemCorrect(
      problemId: _currentProblem.id,
      problemType: _currentProblem.type.toString(),
      attemptCount: _currentStreak,
    );

    // 햅틱 및 사운드 피드백
    await AppHapticFeedback.success();
    await SoundEffects.playCorrect();

    // XP 업데이트
    await ref
        .read(userProvider.notifier)
        .addXP(_currentProblem.xpReward + bonusXP);
    await SoundEffects.playXPGain();

    // 최초 정답 시 스트릭 업데이트
    if (_totalCorrect == 1) {
      await ref.read(userProvider.notifier).incrementStreakOnStudy();
      await ref.read(studyHistoryProvider.notifier).markTodayAsCompleted();
    }

    // 애니메이션 표시
    if (mounted) {
      _showXPGainAnimation(_currentProblem.xpReward + bonusXP);
    }

    if (bonusXP > 0) {
      _showStreakAnimationWithDelay();
    }

    // 뱃지 언락 체크
    _checkAchievements();
  }

  /// 오답 처리
  Future<void> _handleWrongAnswer(
    String userId,
    String userAnswerText,
    int? selectedAnswerIndex,
  ) async {
    // 스트릭 초기화
    _currentStreak = 0;

    // Analytics: 문제 오답 기록
    await AnalyticsService().logProblemIncorrect(
      problemId: _currentProblem.id,
      problemType: _currentProblem.type.toString(),
      attemptCount: 1, // 오답이므로 시도 횟수는 1
    );

    // 하트 감소
    await ref.read(userProvider.notifier).decreaseHeart();

    // 하트가 0이 되면 게임 오버 처리
    final user = ref.read(userProvider);
    if (user != null && user.hearts <= 0) {
      if (mounted) {
        await _showHeartDepletedDialog();
      }
      return; // 더 이상 진행하지 않음
    }

    // 햅틱 및 사운드 피드백
    await AppHapticFeedback.error();
    await SoundEffects.playWrong();

    // 오답 노트에 저장
    await ref.read(errorNoteProvider.notifier).addErrorNote(
          userId: userId,
          problem: _currentProblem,
          userAnswer: userAnswerText,
        );

    if (selectedAnswerIndex != null) {
      await ref.read(wrongAnswerProvider.notifier).addWrongAnswer(
            problem: _currentProblem,
            selectedAnswerIndex: selectedAnswerIndex,
          );
    }
  }

  /// 스트릭 보너스 XP 계산
  int _calculateStreakBonus() {
    if (_currentStreak >= 10) return 20;
    if (_currentStreak >= 5) return 10;
    if (_currentStreak >= 3) return 5;
    return 0;
  }

  /// 스트릭 애니메이션 표시
  void _showStreakAnimationWithDelay() {
    setState(() {
      _showStreakAnimation = true;
    });

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _showStreakAnimation = false;
        });
      }
    });
  }

  /// 숫자 비교 (오차 범위 허용)
  bool _compareNumbers(String userAnswer, String correctAnswer) {
    try {
      final userNum = double.parse(userAnswer);
      final correctNum = double.parse(correctAnswer);
      return (userNum - correctNum).abs() < 0.01;
    } catch (e) {
      return false;
    }
  }

  /// XP 획득 애니메이션
  void _showXPGainAnimation(int xp) {
    showXPGainAnimation(context, xp);
  }

  /// 뱃지 언락 체크
  void _checkAchievements() {
    // TODO: 뱃지 언락 체크 및 알림
    final achievements = ref.read(achievementProvider);

    // 예시: 첫 문제 풀기 뱃지
    if (_totalCorrect == 1) {
      final firstProblemAchievement = achievements.firstWhere(
        (a) => a.id == 'achievement001',
        orElse: () => achievements.first,
      );

      if (!firstProblemAchievement.isUnlocked) {
        _showAchievementUnlocked(firstProblemAchievement);
      }
    }
  }

  /// 뱃지 언락 알림
  void _showAchievementUnlocked(Achievement achievement) {
    // 뱃지 언락
    ref.read(achievementProvider.notifier).unlockAchievement(achievement.id);

    // 햅틱 피드백
    AppHapticFeedback.success();

    // 스낵바로 알림 표시 (화면 위쪽에 표시)
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.mathPurple,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  achievement.icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '🎉 뱃지 획득!',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievement.title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+${achievement.xpReward} XP',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 4),
          // 위쪽에 표시하도록 margin 수정
          margin: const EdgeInsets.only(
            top: 16,
            left: 16,
            right: 16,
            bottom: 0,
          ),
        ),
      );
    }
  }

  /// 다음 문제
  void _nextProblem() async {
    // 페이드 아웃 애니메이션
    await _transitionController.reverse(from: 1.0);

    // 상태 업데이트
    setState(() {
      _currentProblemIndex++;
      _selectedAnswerIndex = null;
      _isAnswerSubmitted = false;
      _isCorrect = false;
      _lastSelectedIndex = null;
      _lastSelectTime = null;
      _pulsingIndex = null;
      _answerController.clear(); // 주관식 답안 초기화
    });

    // 타이머 리셋 및 재시작
    _stopwatch.reset();
    _stopwatch.start();

    // 다음 문제의 힌트 시스템 초기화
    ref.read(hintProviderOptimized.notifier).startProblem(_currentProblem.id);

    // 페이드 인 애니메이션
    await _transitionController.forward(from: 0.0);
  }

  /// 결과 확인
  void _showResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProblemResultDialog(
        lessonTitle: '기초 산술',
        results: _results,
        totalXPEarned: _totalXPEarned,
        onComplete: () {
          Navigator.of(context).pop(); // 다이얼로그 닫기
          Navigator.of(context).pop(); // ProblemScreen 닫기
        },
        onRetry: () {
          Navigator.of(context).pop(); // 다이얼로그 닫기
          _resetProblemSet(); // 문제 세트 리셋
        },
      ),
    );
  }

  /// 나가기 다이얼로그
  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => const ExitConfirmationDialog(),
    );
  }

  /// 힌트 섹션으로 스크롤
  void _scrollToHint() {
    final context = _hintSectionKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        alignment: 0.2, // 화면 상단에서 20% 위치에 표시
      );
      AppHapticFeedback.lightImpact(); // 가벼운 햅틱 피드백
    }
  }

  /// Floating hint button - GoMath 스타일
  Widget? _buildFloatingHintButton() {
    // 답 제출 후에는 힌트 버튼 숨김
    if (_isAnswerSubmitted) {
      return null;
    }

    // 힌트가 없는 문제는 버튼 표시 안 함
    final hints = _currentProblem.hints;
    if (hints.isEmpty) {
      return null;
    }

    final hintState = ref.watch(hintProviderOptimized);

    // 잠금 해제된 힌트 개수 계산
    int unlockedCount = 0;
    for (int i = 0; i < hints.length; i++) {
      final hintKey = '${_currentProblem.id}_$i';
      if (hintState.unlockedHints.contains(hintKey)) {
        unlockedCount++;
      }
    }

    return FloatingActionButton(
      onPressed: _scrollToHint,
      backgroundColor: AppColors.mathYellow,
      foregroundColor: AppColors.textPrimary,
      elevation: 4,
      child: Badge(
        isLabelVisible: true,
        label: Text(
          '$unlockedCount/${hints.length}',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor:
            unlockedCount > 0 ? AppColors.successGreen : AppColors.mathOrange,
        child: const Icon(
          Icons.lightbulb,
          size: 28,
        ),
      ),
    );
  }

  /// 하트 소진 다이얼로그 표시
  Future<void> _showHeartDepletedDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const HeartDepletedDialog(),
    );
  }

  /// 문제 세트 리셋 (다시 풀기용)
  void _resetProblemSet() {
    setState(() {
      _currentProblemIndex = 0;
      _selectedAnswerIndex = null;
      _isAnswerSubmitted = false;
      _isCorrect = false;
      _totalCorrect = 0;
      _totalXPEarned = 0;
      _results.clear();
      _lastSelectedIndex = null;
      _lastSelectTime = null;
      _pulsingIndex = null;
      // 스트릭 초기화
      _currentStreak = 0;
      _maxStreak = 0;
      _showStreakAnimation = false;
    });

    // 타이머 리셋 및 재시작
    _stopwatch.reset();
    _stopwatch.start();

    // 첫 문제의 힌트 시스템 초기화
    ref.read(hintProviderOptimized.notifier).startProblem(_currentProblem.id);

    _transitionController.reset();
    _transitionController.forward();
  }
}
