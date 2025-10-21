import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../shared/constants/app_dimensions.dart';
import '../../shared/widgets/responsive_wrapper.dart';
import '../../shared/widgets/fade_in_widget.dart';
import '../../data/models/models.dart';
import '../../data/providers/user_provider.dart';
import '../../data/providers/problem_provider.dart';
import '../../data/providers/error_note_provider.dart';
import '../../data/providers/achievement_provider.dart';
import 'widgets/problem_option_button.dart';
import 'widgets/problem_result_dialog.dart';
import 'widgets/xp_gain_animation.dart';

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

  // 시간 측정
  final Stopwatch _stopwatch = Stopwatch();

  // 애니메이션
  late AnimationController _transitionController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _stopwatch.start(); // 타이머 시작
  }

  void _setupAnimations() {
    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _transitionController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
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
  void dispose() {
    _transitionController.dispose();
    super.dispose();
  }

  Problem get _currentProblem => widget.problems[_currentProblemIndex];
  double get _progress => (_currentProblemIndex + 1) / widget.problems.length;
  bool get _isLastProblem => _currentProblemIndex == widget.problems.length - 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mathBlue,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.mathBlueGradient,
          ),
        ),
        child: SafeArea(
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
      ),
    );
  }

  /// 헤더 (뒤로가기 + 진행률 + XP)
  Widget _buildHeader() {
    final user = ref.watch(userProvider);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        children: [
          // 뒤로가기 + XP
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => _showExitDialog(),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingM,
                  vertical: AppDimensions.paddingS,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                ),
                child: Row(
                  children: [
                    Text(
                      '🔶',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: AppDimensions.spacingS),
                    Text(
                      '${user?.xp ?? 0} XP',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          // 진행률 바
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '문제 ${_currentProblemIndex + 1}/${widget.problems.length}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${(_progress * 100).round()}%',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingS),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  tween: Tween(begin: 0.0, end: _progress),
                  builder: (context, value, child) {
                    return LinearProgressIndicator(
                      value: value,
                      backgroundColor: Colors.white.withValues(alpha: 0.3),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                      minHeight: 8,
                    );
                  },
                ),
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
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingXL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoryBadge(),
                  const SizedBox(height: AppDimensions.spacingL),
                  _buildQuestionText(),
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
          _buildBottomButton(),
        ],
      ),
    );
  }

  /// 카테고리 뱃지
  Widget _buildCategoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.mathButtonGradient,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _currentProblem.typeIcon,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: AppDimensions.spacingS),
          Text(
            _currentProblem.category,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingS),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '+${_currentProblem.xpReward} XP',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
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
      child: Text(
        _currentProblem.question,
        style: AppTextStyles.headlineMedium.copyWith(
          fontWeight: FontWeight.bold,
          height: 1.4,
        ),
      ),
    );
  }

  /// 선택지
  Widget _buildOptions() {
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
              ),
            ),
          );
        },
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
                Text(
                  _isCorrect ? '✅' : '💡',
                  style: const TextStyle(fontSize: 24),
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
              _currentProblem.explanation,
              style: AppTextStyles.bodyMedium.copyWith(
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 하단 버튼
  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _getButtonAction(),
            style: ElevatedButton.styleFrom(
              backgroundColor: _getButtonColor(),
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingL),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              ),
              elevation: 0,
            ),
            child: Text(
              _getButtonText(),
              style: AppTextStyles.titleLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  VoidCallback? _getButtonAction() {
    if (!_isAnswerSubmitted && _selectedAnswerIndex == null) {
      return null; // 답을 선택하지 않으면 비활성화
    }
    if (!_isAnswerSubmitted) {
      return _submitAnswer;
    }
    if (_isLastProblem) {
      return _showResults;
    }
    return _nextProblem;
  }

  Color _getButtonColor() {
    if (_isAnswerSubmitted) {
      return _isCorrect ? AppColors.successGreen : AppColors.mathButtonBlue;
    }
    if (_selectedAnswerIndex == null) {
      return AppColors.disabled;
    }
    return AppColors.mathButtonBlue;
  }

  String _getButtonText() {
    if (!_isAnswerSubmitted) {
      return '제출';
    }
    if (_isLastProblem) {
      return '결과 확인';
    }
    return '다음 문제';
  }

  /// 답 선택
  void _selectAnswer(int index) {
    setState(() {
      _selectedAnswerIndex = index;
    });
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
      // 정답: XP 획득
      _totalCorrect++;
      _totalXPEarned += _currentProblem.xpReward;

      // 사용자 XP 업데이트
      await ref.read(userProvider.notifier).addXP(_currentProblem.xpReward);

      // XP 획득 애니메이션 표시
      if (mounted) {
        _showXPGainAnimation(_currentProblem.xpReward);
      }

      // 뱃지 언락 체크
      _checkAchievements();
    } else {
      // 오답: 오답 노트에 저장
      await ref.read(errorNoteProvider.notifier).addErrorNote(
            userId: userId,
            problem: _currentProblem,
            userAnswer: _currentProblem.options![_selectedAnswerIndex!],
          );
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
    // TODO: 뱃지 언락 애니메이션 구현
  }

  /// 다음 문제
  void _nextProblem() async {
    setState(() {
      _currentProblemIndex++;
      _selectedAnswerIndex = null;
      _isAnswerSubmitted = false;
      _isCorrect = false;
    });

    // 타이머 리셋 및 재시작
    _stopwatch.reset();
    _stopwatch.start();

    // 전환 애니메이션
    await _transitionController.reverse();
    await _transitionController.forward();
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
            Text('⚠️', style: const TextStyle(fontSize: 24)),
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
    });

    // 타이머 리셋 및 재시작
    _stopwatch.reset();
    _stopwatch.start();

    _transitionController.reset();
    _transitionController.forward();
  }
}
