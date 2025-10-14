import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../shared/constants/app_dimensions.dart';
import '../../shared/widgets/widgets.dart';
import '../../data/models/models.dart';
import '../../data/providers/problem_provider.dart';
import '../../data/providers/user_provider.dart';
import '../../shared/utils/haptic_feedback.dart';

/// 문제 풀이 화면
/// 실제 수학 문제를 풀고 XP를 획득하는 핵심 화면
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
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressController;
  late AnimationController _feedbackController;

  int _currentProblemIndex = 0;
  int? _selectedAnswerIndex;
  String? _selectedTextAnswer;
  bool _isAnswerChecked = false;
  bool _showExplanation = false;
  DateTime? _problemStartTime;
  List<ProblemResult> _sessionResults = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _problemStartTime = DateTime.now();

    // Provider 수정을 다음 프레임으로 연기
    Future.delayed(Duration.zero, () {
      _startLearningSession();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  void _startLearningSession() {
    // 학습 세션 시작
    ref.read(learningSessionProvider.notifier).startSession(
          lessonId: widget.lessonId,
          problems: widget.problems,
        );
  }

  Problem get _currentProblem => widget.problems[_currentProblemIndex];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: _showExitDialog,
          icon: const Icon(Icons.close),
        ),
        title: _buildProgressIndicator(),
        actions: [
          _buildHeartsIndicator(),
        ],
      ),
      body: ResponsiveWrapper(
        child: PageView.builder(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.problems.length,
          itemBuilder: (context, index) {
            return _buildProblemPage(widget.problems[index]);
          },
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  /// 진행률 표시
  Widget _buildProgressIndicator() {
    final progress = (_currentProblemIndex + 1) / widget.problems.length;

    return Column(
      children: [
        Text(
          '${_currentProblemIndex + 1} / ${widget.problems.length}',
          style: AppTextStyles.labelMedium,
        ),
        const SizedBox(height: AppDimensions.spacingXS),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppColors.progressBackground,
          valueColor: const AlwaysStoppedAnimation(AppColors.progressActive),
        ),
      ],
    );
  }

  /// 하트 표시 (생명)
  Widget _buildHeartsIndicator() {
    return Consumer(
      builder: (context, ref, child) {
        final user = ref.watch(userProvider);
        const maxHearts = 5;
        final currentHearts = user?.hearts ?? 5;

    return Padding(
      padding: const EdgeInsets.only(right: AppDimensions.paddingL),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(maxHearts, (index) {
          return Text(
            index < currentHearts ? '❤️' : '🤍',
            style: const TextStyle(fontSize: 16),
          );
        }),
      ),
    );
      },
    );
  }

  /// 문제 페이지
  Widget _buildProblemPage(Problem problem) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProblemCard(problem),
          const SizedBox(height: AppDimensions.spacingXL),
          _buildAnswerOptions(problem),
          if (_showExplanation) ...[
            const SizedBox(height: AppDimensions.spacingXL),
            _buildExplanation(problem),
          ],
        ],
      ),
    );
  }

  /// 문제 카드
  Widget _buildProblemCard(Problem problem) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingXL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: AppDimensions.cardElevation * 2,
            offset: const Offset(0, AppDimensions.cardElevation),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingS,
                  vertical: AppDimensions.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: Text(
                  problem.category,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingS,
                  vertical: AppDimensions.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(problem.difficulty).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: Text(
                  problem.difficultyText,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: _getDifficultyColor(problem.difficulty),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingL),
          Text(
            problem.question,
            style: AppTextStyles.headlineMedium.copyWith(
              height: 1.6, // 1.4 → 1.6 (줄간격 향상)
              fontSize: 24, // 문제 텍스트 크게
              fontWeight: FontWeight.w600,
            ),
          ),
          // TODO: 이미지 지원 (향후 추가)
        ],
      ),
    );
  }

  /// 답안 선택 옵션들
  Widget _buildAnswerOptions(Problem problem) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '정답을 선택하세요:',
          style: AppTextStyles.titleMedium,
        ),
        const SizedBox(height: AppDimensions.spacingM),
        if (problem.type == ProblemType.multipleChoice && problem.options != null)
          ...List.generate(problem.options!.length, (index) {
            return _buildAnswerOption(
              index: index,
              text: problem.options![index],
              isSelected: _selectedAnswerIndex == index,
              isCorrect: index == problem.correctAnswerIndex,
              showResult: _isAnswerChecked,
            );
          })
        else if (problem.type == ProblemType.shortAnswer || problem.type == ProblemType.calculation)
          _buildShortAnswerInput(problem),
      ],
    );
  }

  /// 개별 답안 옵션
  Widget _buildAnswerOption({
    required int index,
    required String text,
    required bool isSelected,
    required bool isCorrect,
    required bool showResult,
  }) {
    Color borderColor = AppColors.borderLight;
    Color backgroundColor = AppColors.surface;

    if (showResult) {
      if (isSelected && isCorrect) {
        // 선택한 답이 정답
        borderColor = AppColors.successGreen;
        backgroundColor = AppColors.successGreen.withValues(alpha: 0.1);
      } else if (isSelected && !isCorrect) {
        // 선택한 답이 오답
        borderColor = AppColors.errorRed;
        backgroundColor = AppColors.errorRed.withValues(alpha: 0.1);
      } else if (!isSelected && isCorrect) {
        // 선택하지 않았지만 정답인 경우
        borderColor = AppColors.successGreen;
        backgroundColor = AppColors.successGreen.withValues(alpha: 0.05);
      }
    } else if (isSelected) {
      // 선택된 상태 (아직 체크 전)
      borderColor = AppColors.primaryBlue;
      backgroundColor = AppColors.primaryBlue.withValues(alpha: 0.1);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      child: InkWell(
        onTap: _isAnswerChecked ? null : () => _selectAnswer(index),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: borderColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index), // A, B, C, D
                    style: AppTextStyles.titleMedium.copyWith(
                      color: borderColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(
                child: Text(
                  text,
                  style: AppTextStyles.titleMedium,
                ),
              ),
              if (showResult && isCorrect)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.successGreen,
                  size: AppDimensions.iconL,
                ),
              if (showResult && isSelected && !isCorrect)
                const Icon(
                  Icons.cancel,
                  color: AppColors.errorRed,
                  size: AppDimensions.iconL,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 해설 카드
  Widget _buildExplanation(Problem problem) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: AppColors.primaryBlue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppColors.primaryBlue,
                size: AppDimensions.iconM,
              ),
              const SizedBox(width: AppDimensions.spacingS),
              Text(
                '해설',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            problem.explanation,
            style: AppTextStyles.bodyLarge.copyWith(
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// 주관식 답안 입력
  Widget _buildShortAnswerInput(Problem problem) {
    return ShortAnswerInput(
      hint: problem.inputHint ?? '답을 입력하세요',
      onChanged: (value) {
        setState(() {
          _selectedTextAnswer = value;
        });
      },
      showResult: _isAnswerChecked,
      isCorrect: _isAnswerChecked && problem.isCorrectTextAnswer(_selectedTextAnswer ?? ''),
      correctAnswer: problem.correctAnswer,
      keyboardType: problem.type == ProblemType.calculation
          ? TextInputType.number
          : TextInputType.text,
    );
  }

  /// 하단 액션 바
  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.only(
        left: AppDimensions.paddingL,
        right: AppDimensions.paddingL,
        top: AppDimensions.paddingM,
        bottom: MediaQuery.of(context).padding.bottom + AppDimensions.paddingM,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: _isAnswerChecked
          ? _buildNextButton()
          : _buildCheckButton(),
    );
  }

  /// 정답 확인 버튼
  Widget _buildCheckButton() {
    final problem = _currentProblem;
    bool isEnabled = false;

    if (problem.type == ProblemType.multipleChoice) {
      isEnabled = _selectedAnswerIndex != null;
    } else {
      isEnabled = _selectedTextAnswer != null && _selectedTextAnswer!.trim().isNotEmpty;
    }

    return PrimaryButton(
      text: '정답 확인',
      onPressed: isEnabled ? _checkAnswer : null,
      isEnabled: isEnabled,
      backgroundColor: AppColors.primaryBlue,
    );
  }

  /// 다음 문제 버튼
  Widget _buildNextButton() {
    final isLastProblem = _currentProblemIndex >= widget.problems.length - 1;

    return PrimaryButton(
      text: isLastProblem ? '완료' : '다음 문제',
      onPressed: _goToNextProblem,
      backgroundColor: AppColors.successGreen,
      icon: isLastProblem ? Icons.check : Icons.arrow_forward,
    );
  }

  // 이벤트 핸들러들

  void _selectAnswer(int index) {
    if (_isAnswerChecked) return;

    setState(() {
      _selectedAnswerIndex = index;
    });
  }

  void _checkAnswer() async {
    final problem = _currentProblem;
    final timeSpent = DateTime.now().difference(_problemStartTime!).inSeconds;

    bool isCorrect = false;
    int? answerIndex;
    String? textAnswer;

    if (problem.type == ProblemType.multipleChoice) {
      if (_selectedAnswerIndex == null) return;
      isCorrect = problem.isCorrectAnswer(_selectedAnswerIndex!);
      answerIndex = _selectedAnswerIndex;
    } else {
      if (_selectedTextAnswer == null || _selectedTextAnswer!.trim().isEmpty) return;
      isCorrect = problem.isCorrectTextAnswer(_selectedTextAnswer!);
      textAnswer = _selectedTextAnswer;
    }

    // 결과 생성
    final result = ProblemResult(
      problemId: problem.id,
      userId: ref.read(userProvider)?.id ?? 'user001',
      selectedAnswerIndex: answerIndex,
      textAnswer: textAnswer,
      isCorrect: isCorrect,
      solvedAt: DateTime.now(),
      timeSpentSeconds: timeSpent,
      xpEarned: isCorrect ? problem.xpReward : 0,
    );

    // 결과 저장
    await ref.read(problemResultsProvider.notifier).addResult(result);
    _sessionResults.add(result);

    // XP 획득 (정답인 경우)
    if (isCorrect) {
      await ref.read(userProvider.notifier).addXP(problem.xpReward);
    }

    // 스트릭 업데이트
    await ref.read(userProvider.notifier).updateStreak();

    // 피드백 애니메이션
    await _feedbackController.forward();

    setState(() {
      _isAnswerChecked = true;
      _showExplanation = true;
    });

    // 정답/오답에 따른 햅틱 피드백
    if (isCorrect) {
      await AppHapticFeedback.success();
      // TODO: XP 애니메이션 표시
    } else {
      await AppHapticFeedback.error();
    }
  }

  void _goToNextProblem() async {
    if (_currentProblemIndex >= widget.problems.length - 1) {
      // 학습 완료
      await _completeSession();
      return;
    }

    // 다음 문제로 이동
    setState(() {
      _currentProblemIndex++;
      _selectedAnswerIndex = null;
      _selectedTextAnswer = null;
      _isAnswerChecked = false;
      _showExplanation = false;
      _problemStartTime = DateTime.now();
    });

    // 페이지 이동
    await _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    // 진행률 애니메이션 업데이트
    final progress = (_currentProblemIndex + 1) / widget.problems.length;
    _progressController.animateTo(progress);

    _feedbackController.reset();
  }

  Future<void> _completeSession() async {
    // 학습 세션 완료
    final summary = ref.read(learningSessionProvider.notifier).completeSession();

    if (summary != null) {
      await _showSessionSummary(summary);
    }

    // 홈 화면으로 이동
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _showSessionSummary(LearningSessionSummary summary) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text('🎉', style: AppTextStyles.emojiLarge),
            const SizedBox(width: AppDimensions.spacingS),
            const Expanded(child: Text('학습 완료!')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryRow('풀이한 문제', '${summary.totalProblems}개'),
            _buildSummaryRow('정답 수', '${summary.correctAnswers}개'),
            _buildSummaryRow('정답률', '${(summary.accuracy * 100).round()}%'),
            _buildSummaryRow('획득 XP', '+${summary.totalXPEarned} XP'),
            _buildSummaryRow('소요 시간', _formatDuration(summary.totalTimeSpent)),
            _buildSummaryRow('성과 등급', summary.performanceGrade),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingXS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('학습 종료'),
        content: const Text('정말로 학습을 종료하시겠습니까?\n진행 상황이 저장되지 않을 수 있습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('계속하기'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.errorRed,
            ),
            child: const Text('종료'),
          ),
        ],
      ),
    );
  }

  // 유틸리티 메서드들

  Color _getDifficultyColor(int difficulty) {
    switch (difficulty) {
      case 1:
        return AppColors.successGreen;
      case 2:
        return AppColors.primaryBlue;
      case 3:
        return AppColors.warningOrange;
      case 4:
      case 5:
        return AppColors.errorRed;
      default:
        return AppColors.primaryBlue;
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    if (minutes == 0) {
      return '${seconds}초';
    } else {
      return '${minutes}분 ${seconds}초';
    }
  }
}