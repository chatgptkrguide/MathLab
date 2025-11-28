import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../shared/constants/app_dimensions.dart';
import '../../shared/constants/game_constants.dart';
import '../../shared/widgets/layout/responsive_wrapper.dart';
import '../../shared/widgets/animations/fade_in_widget.dart';
import '../../shared/widgets/math/math_text.dart';
import '../../shared/utils/haptic_feedback.dart';
import '../../data/models/models.dart';
import '../../data/providers/user_provider.dart';
import '../../data/providers/problem_provider.dart';
import '../../data/providers/lesson_provider.dart';
import '../../data/providers/error_note_provider.dart';
import '../../data/providers/achievement_provider.dart';
import '../../data/providers/hint_provider.dart';
import '../../data/providers/study_history_provider.dart';
import '../../data/services/sound_service.dart';
import 'widgets/problem_option_button.dart';
import 'widgets/problem_result_dialog.dart';
import 'widgets/xp_gain_animation.dart';
import 'widgets/hint_section.dart';

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
    _setupAnimations();
    _stopwatch.start(); // 타이머 시작

    // 첫 문제의 힌트 시스템 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(hintProvider.notifier).startProblem(_currentProblem.id);
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
        ref.read(hintProvider.notifier).endProblem();
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

  Problem get _currentProblem => widget.problems[_currentProblemIndex];
  double get _progress => (_currentProblemIndex + 1) / widget.problems.length;
  bool get _isLastProblem => _currentProblemIndex == widget.problems.length - 1;

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
                _buildHeader(),
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

  /// 헤더 (뒤로가기 + 진행률 + XP) - Duolingo style
  Widget _buildHeader() {
    final user = ref.watch(userProvider);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        children: [
          // 뒤로가기 + 스트릭 + XP
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Duolingo-style close button
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: AppColors.surface, size: 20),
                  padding: EdgeInsets.zero,
                  onPressed: () => _showExitDialog(),
                ),
              ),
              // 연속 정답 스트릭 뱃지
              if (_currentStreak > 0)
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.elasticOut,
                  tween: Tween(
                    begin: _showStreakAnimation ? 0.8 : 1.0,
                    end: _showStreakAnimation ? 1.2 : 1.0,
                  ),
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _currentStreak >= 10
                              ? AppColors.mathPurple
                              : _currentStreak >= 5
                                  ? AppColors.mathOrange
                                  : AppColors.mathYellow,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: (_currentStreak >= 10
                                      ? AppColors.mathPurple
                                      : _currentStreak >= 5
                                          ? AppColors.mathOrange
                                          : AppColors.mathYellow)
                                  .withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.local_fire_department,
                              color: AppColors.surface,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$_currentStreak',
                              style: const TextStyle(
                                color: AppColors.surface,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              // Clean XP badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.diamond_outlined,
                      color: AppColors.mathOrange,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${user?.xp ?? 0}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          // Duolingo-style progress bar
          Stack(
            children: [
              // Background bar
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // Progress bar with animation
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                tween: Tween(begin: 0.0, end: _progress),
                builder: (context, value, child) {
                  return FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: value.clamp(0.05, 1.0),
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.mathYellow, AppColors.mathYellowDark],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.mathYellow.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
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
                  _buildCategoryBadge(),
                  const SizedBox(height: AppDimensions.spacingL),
                  _buildQuestionText(),
                  // 힌트 섹션 (답 제출 전에만 표시)
                  if (!_isAnswerSubmitted)
                    Container(
                      key: _hintSectionKey, // GlobalKey 추가
                      child: HintSection(problem: _currentProblem),
                    ),
                  const SizedBox(height: AppDimensions.spacingXXL),
                  _buildOptions(),
                  if (_isAnswerSubmitted) ...[
                    const SizedBox(height: AppDimensions.spacingXL),
                    _buildExplanation(),
                  ],
                ],
              ),
            ),
          ),
          if (_buildBottomButton() != null) _buildBottomButton()!,
        ],
      ),
    );
  }

  /// 카테고리 뱃지 - GoMath flat style
  Widget _buildCategoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.mathBlue, // GoMath 파란색
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.mathBlue.withValues(alpha: 0.7), // 어두운 파란색 테두리
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _currentProblem.typeIcon,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 8),
          Text(
            _currentProblem.category,
            style: const TextStyle(
              color: AppColors.surface,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          // 학년 정보 표시
          if (_currentProblem.grade != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _currentProblem.grade!,
                style: const TextStyle(
                  color: AppColors.surface,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: AppColors.mathYellow, // GoMath 노란색
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '+${_currentProblem.xpReward} XP',
              style: const TextStyle(
                color: AppColors.surface,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 문제 텍스트
  Widget _buildQuestionText() {
    return FadeInWidget(
      child: MathText(
        _currentProblem.question,
        style: AppTextStyles.headlineMedium.copyWith(
          fontWeight: FontWeight.bold,
          height: 1.4,
        ),
        fontSize: 20,
      ),
    );
  }

  /// 선택지
  Widget _buildOptions() {
    // 주관식 문제인 경우 입력 필드 표시
    if (_currentProblem.type == ProblemType.shortAnswer ||
        _currentProblem.type == ProblemType.calculation) {
      return _buildAnswerInput();
    }

    // 객관식 문제
    if (_currentProblem.options == null) return const SizedBox();

    return Column(
      children: List.generate(
        _currentProblem.options!.length,
        (index) {
          final isCorrectAnswer = _currentProblem.correctAnswerIndex == index;

          return FadeInWidget(
            delay: Duration(milliseconds: 100 * index),
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
              child: ProblemOptionButton(
                optionText: _currentProblem.options![index],
                index: index,
                selectedIndex: _selectedAnswerIndex,
                isAnswerSubmitted: _isAnswerSubmitted,
                isCorrectAnswer: isCorrectAnswer,
                onTap: () => _selectAnswer(index),
                isPulsing: _pulsingIndex == index,
              ),
            ),
          );
        },
      ),
    );
  }

  /// 정답 텍스트 가져오기
  String _getCorrectAnswerText() {
    // 주관식 문제의 경우
    if (_currentProblem.correctAnswer != null) {
      return _currentProblem.correctAnswer!;
    }

    // 객관식 문제의 경우
    final options = _currentProblem.options;
    final correctIndex = _currentProblem.correctAnswerIndex;

    if (options != null &&
        correctIndex != null &&
        correctIndex >= 0 &&
        correctIndex < options.length) {
      return options[correctIndex];
    }

    return '알 수 없음';
  }

  /// 주관식 답안 입력 필드
  Widget _buildAnswerInput() {
    return FadeInWidget(
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          border: Border.all(
            color: _isAnswerSubmitted
                ? (_isCorrect ? AppColors.successGreen : AppColors.errorRed)
                : AppColors.borderLight,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '정답을 입력하세요',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            TextField(
              controller: _answerController,
              focusNode: _answerFocusNode,
              enabled: !_isAnswerSubmitted,
              keyboardType: _currentProblem.type == ProblemType.calculation
                  ? const TextInputType.numberWithOptions(decimal: true)
                  : TextInputType.text,
              style: AppTextStyles.titleLarge,
              decoration: InputDecoration(
                hintText: _currentProblem.type == ProblemType.calculation ? '숫자를 입력하세요' : '답을 입력하세요',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  borderSide: BorderSide(color: AppColors.borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  borderSide: BorderSide(color: AppColors.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  borderSide: BorderSide(color: AppColors.mathPurple, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  // 입력이 있으면 버튼 활성화
                });
              },
              onSubmitted: (_) {
                if (_answerController.text.isNotEmpty && !_isAnswerSubmitted) {
                  _submitShortAnswer();
                }
              },
            ),
            if (_isAnswerSubmitted && !_isCorrect) ...[
              const SizedBox(height: AppDimensions.spacingS),
              Text(
                '정답: ${_getCorrectAnswerText()}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.successGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 해설
  Widget _buildExplanation() {
    return FadeInWidget(
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        decoration: BoxDecoration(
          color: _isCorrect
              ? AppColors.successGreen.withValues(alpha: 0.1)
              : AppColors.warningOrange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          border: Border.all(
            color: _isCorrect
                ? AppColors.successGreen.withValues(alpha: 0.3)
                : AppColors.warningOrange.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isCorrect ? Icons.check_circle : Icons.lightbulb,
                  color: _isCorrect ? AppColors.successGreen : AppColors.warningOrange,
                  size: 24,
                ),
                const SizedBox(width: AppDimensions.spacingS),
                Text(
                  _isCorrect ? '정답입니다!' : '다시 한번 확인해보세요',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: _isCorrect ? AppColors.successGreen : AppColors.warningOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              _currentProblem.explanation ?? '풀이 설명이 없습니다',
              style: AppTextStyles.bodyMedium.copyWith(
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 하단 버튼 - Duolingo style with 3D shadow
  Widget? _buildBottomButton() {
    // 객관식 문제이고 답 제출 전이면 버튼 숨김
    if (_currentProblem.type == ProblemType.multipleChoice && !_isAnswerSubmitted) {
      return null;
    }

    final enabled = _getButtonAction() != null;
    final buttonColor = _getButtonColor();
    final darkerColor = _getDarkerButtonColor();

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Stack(
            children: [
              // Duolingo 3D solid shadow
              if (enabled)
                Positioned(
                  top: 6,
                  left: 0,
                  right: 0,
                  bottom: -6,
                  child: Container(
                    decoration: BoxDecoration(
                      color: darkerColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              // Main button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _getButtonAction(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: AppColors.borderLight,
                  ),
                  child: Text(
                    _getButtonText(),
                    style: const TextStyle(
                      color: AppColors.surface,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
        ),
      ),
    );
  }

  VoidCallback? _getButtonAction() {
    // 답 제출 후에는 다음 문제 또는 결과 확인
    if (_isAnswerSubmitted) {
      // 2문제 완료하면 결과 확인
      if (_currentProblemIndex >= 1 || _isLastProblem) {
        return _showResults;
      }
      return _nextProblem;
    }

    // 객관식: 제출 버튼 없음 (더블 클릭으로 자동 제출)
    if (_currentProblem.type == ProblemType.multipleChoice) {
      return null;
    }

    // 주관식/계산: 입력이 있을 때만 제출 버튼 활성화
    if (_currentProblem.type == ProblemType.shortAnswer ||
        _currentProblem.type == ProblemType.calculation) {
      return _answerController.text.isNotEmpty ? _submitShortAnswer : null;
    }

    return null;
  }

  Color _getButtonColor() {
    if (_isAnswerSubmitted) {
      return _isCorrect ? AppColors.successGreen : AppColors.mathButtonBlue; // GoMath 색상
    }

    // 주관식: 입력이 있으면 활성화
    if (_currentProblem.type == ProblemType.shortAnswer ||
        _currentProblem.type == ProblemType.calculation) {
      return _answerController.text.isEmpty
          ? AppColors.borderLight
          : AppColors.successGreen;
    }

    // 객관식: 선택이 있으면 활성화
    if (_selectedAnswerIndex == null) {
      return AppColors.borderLight; // 비활성화 회색
    }
    return AppColors.successGreen; // GoMath 성공 색상
  }

  Color _getDarkerButtonColor() {
    if (_isAnswerSubmitted) {
      return _isCorrect
          ? AppColors.successGreen.withValues(alpha: 0.8)
          : AppColors.mathButtonBlueDark; // Darker mathButtonBlue (GoMath 20% darker)
    }
    return AppColors.successGreen.withValues(alpha: 0.8); // 어두운 초록색
  }

  String _getButtonText() {
    if (!_isAnswerSubmitted) {
      return '제출';
    }
    // 2문제 완료하면 결과 확인
    if (_currentProblemIndex >= 1 || _isLastProblem) {
      return '결과 확인';
    }
    return '다음 문제';
  }

  /// 답 선택 (객관식 더블 클릭 자동 제출)
  void _selectAnswer(int index) async {
    final now = DateTime.now();

    // 같은 답을 500ms 이내에 다시 선택하면 자동 제출
    if (_lastSelectedIndex == index &&
        _lastSelectTime != null &&
        now.difference(_lastSelectTime!).inMilliseconds <= GameConstants.doubleClickSubmitTimeMs) {
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
      Future.delayed(const Duration(milliseconds: GameConstants.doubleClickSubmitTimeMs), () {
        if (mounted && _pulsingIndex == index) {
          setState(() {
            _pulsingIndex = null;
          });
        }
      });
    }
  }

  /// 답 제출
  void _submitAnswer() async {
    if (_selectedAnswerIndex == null) return;

    final user = ref.read(userProvider);
    final userId = user?.id ?? 'user001';

    _isCorrect = _currentProblem.isCorrectAnswer(_selectedAnswerIndex!);

    setState(() {
      _isAnswerSubmitted = true;
    });

    // 실제 시간 측정
    _stopwatch.stop();
    final timeSpent = _stopwatch.elapsed.inSeconds;

    // 결과 저장
    final result = ProblemResult(
      problemId: _currentProblem.id,
      userId: userId,
      selectedAnswerIndex: _selectedAnswerIndex,
      isCorrect: _isCorrect,
      solvedAt: DateTime.now(),
      timeSpentSeconds: timeSpent,
      xpEarned: _isCorrect ? _currentProblem.xpReward : 0,
    );

    _results.add(result);
    await ref.read(problemResultsProvider.notifier).addResult(result);

    if (_isCorrect) {
      // 정답: 연속 스트릭 증가
      _currentStreak++;
      if (_currentStreak > _maxStreak) {
        _maxStreak = _currentStreak;
      }

      // 스트릭 보너스 XP 계산
      int bonusXP = 0;
      if (_currentStreak >= 10) {
        bonusXP = 20; // 10연속 정답
      } else if (_currentStreak >= 5) {
        bonusXP = 10; // 5연속 정답
      } else if (_currentStreak >= 3) {
        bonusXP = 5; // 3연속 정답
      }

      _totalCorrect++;
      _totalXPEarned += _currentProblem.xpReward + bonusXP;

      // 정답 햅틱 피드백 및 사운드
      await AppHapticFeedback.success();
      await SoundEffects.playCorrect();

      // 사용자 XP 업데이트 (보너스 포함)
      await ref.read(userProvider.notifier).addXP(_currentProblem.xpReward + bonusXP);

      // XP 획득 사운드
      await SoundEffects.playXPGain();

      // 매일 학습 스트릭 업데이트 (최초 정답 시에만)
      if (_totalCorrect == 1) {
        await ref.read(userProvider.notifier).incrementStreakOnStudy();

        // 학습 이력에 오늘 날짜 추가
        await ref.read(studyHistoryProvider.notifier).markTodayAsCompleted();
      }

      // XP 획득 애니메이션 표시 (보너스 포함)
      if (mounted) {
        _showXPGainAnimation(_currentProblem.xpReward + bonusXP);
      }

      // 스트릭 애니메이션 표시
      if (bonusXP > 0) {
        setState(() {
          _showStreakAnimation = true;
        });

        // 2초 후 애니메이션 종료
        Future.delayed(const Duration(milliseconds: 2000), () {
          if (mounted) {
            setState(() {
              _showStreakAnimation = false;
            });
          }
        });
      }

      // 뱃지 언락 체크
      _checkAchievements();
    } else {
      // 오답: 스트릭 초기화
      _currentStreak = 0;

      // 오답 햅틱 피드백 및 사운드
      await AppHapticFeedback.error();
      await SoundEffects.playWrong();

      // 오답: 오답 노트에 저장
      await ref.read(errorNoteProvider.notifier).addErrorNote(
            userId: userId,
            problem: _currentProblem,
            userAnswer: _currentProblem.options![_selectedAnswerIndex!],
          );
    }

    // 레슨 진행률 업데이트
    await ref.read(lessonProvider.notifier).onProblemSolved(
      _currentProblem.id,
      _isCorrect,
    );
  }

  /// 주관식 답안 제출
  void _submitShortAnswer() async {
    if (_answerController.text.isEmpty) return;

    final user = ref.read(userProvider);
    final userId = user?.id ?? 'user001';

    // 답안 정규화 (공백 제거, 소문자 변환 등)
    final userAnswer = _answerController.text.trim();
    final correctAnswer = _currentProblem.correctAnswer?.trim() ?? '';

    // 정답 체크 (대소문자 구분 없음, 공백 무시)
    if (_currentProblem.type == ProblemType.calculation) {
      // 계산 문제: 숫자 비교
      _isCorrect = _compareNumbers(userAnswer, correctAnswer);
    } else {
      // 주관식: 문자열 비교 (대소문자 무시)
      _isCorrect = userAnswer.toLowerCase() == correctAnswer.toLowerCase();
    }

    setState(() {
      _isAnswerSubmitted = true;
    });

    // 실제 시간 측정
    _stopwatch.stop();
    final timeSpent = _stopwatch.elapsed.inSeconds;

    // 결과 저장
    final result = ProblemResult(
      problemId: _currentProblem.id,
      userId: userId,
      selectedAnswerIndex: null, // 주관식은 인덱스 없음
      textAnswer: userAnswer, // 사용자가 입력한 답
      isCorrect: _isCorrect,
      solvedAt: DateTime.now(),
      timeSpentSeconds: timeSpent,
      xpEarned: _isCorrect ? _currentProblem.xpReward : 0,
    );

    _results.add(result);
    await ref.read(problemResultsProvider.notifier).addResult(result);

    if (_isCorrect) {
      // 정답: 연속 스트릭 증가
      _currentStreak++;
      if (_currentStreak > _maxStreak) {
        _maxStreak = _currentStreak;
      }

      // 스트릭 보너스 XP 계산
      int bonusXP = 0;
      if (_currentStreak >= 10) {
        bonusXP = 20; // 10연속 정답
      } else if (_currentStreak >= 5) {
        bonusXP = 10; // 5연속 정답
      } else if (_currentStreak >= 3) {
        bonusXP = 5; // 3연속 정답
      }

      _totalCorrect++;
      _totalXPEarned += _currentProblem.xpReward + bonusXP;

      // 정답 햅틱 피드백 및 사운드
      await AppHapticFeedback.success();
      await SoundEffects.playCorrect();

      // 사용자 XP 업데이트 (보너스 포함)
      await ref.read(userProvider.notifier).addXP(_currentProblem.xpReward + bonusXP);

      // XP 획득 사운드
      await SoundEffects.playXPGain();

      // 매일 학습 스트릭 업데이트 (최초 정답 시에만)
      if (_totalCorrect == 1) {
        await ref.read(userProvider.notifier).incrementStreakOnStudy();

        // 학습 이력에 오늘 날짜 추가
        await ref.read(studyHistoryProvider.notifier).markTodayAsCompleted();
      }

      // XP 획득 애니메이션 표시 (보너스 포함)
      if (mounted) {
        _showXPGainAnimation(_currentProblem.xpReward + bonusXP);
      }

      // 스트릭 애니메이션 표시
      if (bonusXP > 0) {
        setState(() {
          _showStreakAnimation = true;
        });

        // 2초 후 애니메이션 종료
        Future.delayed(const Duration(milliseconds: 2000), () {
          if (mounted) {
            setState(() {
              _showStreakAnimation = false;
            });
          }
        });
      }

      // 뱃지 언락 체크
      _checkAchievements();
    } else {
      // 오답: 스트릭 초기화
      _currentStreak = 0;

      // 오답 햅틱 피드백 및 사운드
      await AppHapticFeedback.error();
      await SoundEffects.playWrong();

      // 오답: 오답 노트에 저장
      await ref.read(errorNoteProvider.notifier).addErrorNote(
            userId: userId,
            problem: _currentProblem,
            userAnswer: userAnswer,
          );
    }

    // 레슨 진행률 업데이트
    await ref.read(lessonProvider.notifier).onProblemSolved(
      _currentProblem.id,
      _isCorrect,
    );
  }

  /// 숫자 비교 (오차 범위 허용)
  bool _compareNumbers(String userAnswer, String correctAnswer) {
    try {
      final userNum = double.parse(userAnswer);
      final correctNum = double.parse(correctAnswer);
      // 0.01 오차 범위 허용
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
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
    ref.read(hintProvider.notifier).startProblem(_currentProblem.id);

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
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning, color: AppColors.warningOrange, size: 24),
            const SizedBox(width: AppDimensions.spacingS),
            Text(
              '학습 중단',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          '정말 나가시겠습니까?\n\n현재까지의 진행 상황은 저장되지 않습니다.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '계속하기',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.mathButtonBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 다이얼로그 닫기
              Navigator.of(context).pop(); // ProblemScreen 닫기
            },
            child: Text(
              '나가기',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.errorRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
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

    final hintState = ref.watch(hintProvider);

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
        backgroundColor: unlockedCount > 0
            ? AppColors.successGreen
            : AppColors.mathOrange,
        child: const Icon(
          Icons.lightbulb,
          size: 28,
        ),
      ),
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
    ref.read(hintProvider.notifier).startProblem(_currentProblem.id);

    _transitionController.reset();
    _transitionController.forward();
  }
}
