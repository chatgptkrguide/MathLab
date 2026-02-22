import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/problem/problem_model.dart';
import '../../data/models/problem/problem_session_model.dart';
import '../../data/models/problem/sample_problems.dart';
import '../../data/providers/user/user_provider.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_dimensions.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../shared/widgets/math/math_renderer.dart';
import '../../shared/utils/answer_validator.dart';

/// 레벨 테스트 화면 (피그마 08 프레임)
/// 문제 풀이 화면과 유사하지만 헤더가 "레벨테스트"이고
/// 결과에 따라 랭크가 결정됨
class LevelTestScreen extends ConsumerStatefulWidget {
  const LevelTestScreen({super.key});

  @override
  ConsumerState<LevelTestScreen> createState() => _LevelTestScreenState();
}

class _LevelTestScreenState extends ConsumerState<LevelTestScreen> {
  late ProblemSessionModel session;
  String? selectedAnswer;
  bool isAnswerChecked = false;
  bool isCorrect = false;
  bool isComplete = false;

  @override
  void initState() {
    super.initState();
    final problems = SampleProblems.getProblemsForLesson('lesson_1_1');
    final user = ref.read(userProvider);
    session = ProblemSessionModel(
      sessionId: 'level_test_${DateTime.now().millisecondsSinceEpoch}',
      lessonId: 'level_test',
      userId: user?.uid ?? 'anonymous',
      problems: problems,
      startedAt: DateTime.now(),
    );
  }

  ProblemModel? get currentProblem => session.currentProblem;

  @override
  Widget build(BuildContext context) {
    if (isComplete) {
      return _buildResultScreen();
    }

    return Scaffold(
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildProgressBar(),
              Expanded(child: _buildQuestionArea()),
              _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppDimensions.spacing16, AppDimensions.spacing12, AppDimensions.spacing16, AppDimensions.spacing12),
      decoration: const BoxDecoration(
        gradient: AppColors.skyBlueGradient,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showExitDialog(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppDimensions.radius10),
              ),
              child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: AppDimensions.spacing12),
          Expanded(
            child: Text(
              '레벨테스트',
              style: AppTextStyles.headlineSmall.copyWith(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
          // 하트
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppDimensions.radius16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.favorite_rounded, color: Colors.red, size: 18),
                const SizedBox(width: AppDimensions.spacing4),
                Text(
                  '${session.hearts}',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = session.progress;

    return Container(
      padding: const EdgeInsets.fromLTRB(AppDimensions.spacing20, AppDimensions.spacing12, AppDimensions.spacing20, AppDimensions.spacing8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${session.currentProblemIndex + 1} / ${session.totalProblems}',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.skyBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing8),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radius6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.nodeLockedBg,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.skyBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionArea() {
    final problem = currentProblem;
    if (problem == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 문제 카드
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.spacing20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(AppDimensions.radius16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '문제 ${session.currentProblemIndex + 1}',
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing12),
                MathRenderer(
                  latex: problem.question,
                  fontSize: 20,
                  color: AppColors.textDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacing24),

          // 선택지 (chip 스타일)
          if (problem.type == ProblemType.multipleChoice)
            ...problem.options.map((option) {
              final isSelected = selectedAnswer == option;
              Color bgColor = AppColors.chipBg;
              Color textColor = AppColors.textDark;
              Color borderColor = Colors.transparent;

              if (isAnswerChecked && isSelected) {
                if (isCorrect) {
                  bgColor = AppColors.mathGreen.withValues(alpha: 0.15);
                  textColor = AppColors.mathGreen;
                  borderColor = AppColors.mathGreen;
                } else {
                  bgColor = Colors.red.withValues(alpha: 0.1);
                  textColor = Colors.red;
                  borderColor = Colors.red;
                }
              } else if (isSelected) {
                bgColor = AppColors.skyBlue.withValues(alpha: 0.12);
                textColor = AppColors.skyBlue;
                borderColor = AppColors.skyBlue;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: isAnswerChecked
                      ? null
                      : () => setState(() => selectedAnswer = option),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing20, vertical: AppDimensions.spacing16),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(AppDimensions.radius24),
                      border: Border.all(
                        color: borderColor,
                        width: isSelected ? 2 : 0,
                      ),
                    ),
                    child: MathRenderer(
                      latex: option,
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    if (isAnswerChecked) {
      return _buildFeedbackBar();
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(AppDimensions.spacing24, AppDimensions.spacing12, AppDimensions.spacing24, AppDimensions.spacing24),
      child: SizedBox(
        width: double.infinity,
        height: AppDimensions.buttonHeightLarge,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: selectedAnswer != null
                ? AppColors.deepBlueCTA
                : null,
            color: selectedAnswer != null ? null : AppColors.nodeLockedBg,
            borderRadius: BorderRadius.circular(AppDimensions.radius16),
          ),
          child: ElevatedButton(
            onPressed: selectedAnswer != null ? _checkAnswer : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radius16),
              ),
            ),
            child: Text(
              '정답 확인',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: selectedAnswer != null ? Colors.white : AppColors.textLight,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppDimensions.spacing24, AppDimensions.spacing16, AppDimensions.spacing24, AppDimensions.spacing24),
      decoration: BoxDecoration(
        color: isCorrect
            ? AppColors.mathGreen.withValues(alpha: 0.1)
            : Colors.red.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimensions.radius20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: isCorrect ? AppColors.mathGreen : Colors.red,
                size: 28,
              ),
              const SizedBox(width: AppDimensions.spacing12),
              Expanded(
                child: Text(
                  isCorrect ? '정답입니다!' : '틀렸습니다',
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontSize: 18,
                    color: isCorrect ? AppColors.mathGreen : Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing16),
          SizedBox(
            width: double.infinity,
            height: AppDimensions.buttonHeightMedium,
            child: ElevatedButton(
              onPressed: _nextProblem,
              style: ElevatedButton.styleFrom(
                backgroundColor: isCorrect ? AppColors.mathGreen : Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radius16),
                ),
              ),
              child: Text(
                '계속하기',
                style: AppTextStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    final correctCount = session.correctCount;
    final total = session.totalProblems;
    final percentage = total > 0 ? (correctCount / total * 100).toInt() : 0;

    String rankResult;
    Color rankColor;
    if (percentage >= 90) {
      rankResult = 'GT Lv1';
      rankColor = AppColors.adminPurple;
    } else if (percentage >= 70) {
      rankResult = 'H Lv1';
      rankColor = const Color(0xFF2196F3);
    } else {
      rankResult = 'A Lv1';
      rankColor = const Color(0xFF4CAF50);
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.skyBlueGradient,
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emoji_events_rounded, size: 80, color: Colors.white),
                const SizedBox(height: AppDimensions.spacing24),
                Text(
                  '레벨테스트 완료!',
                  style: AppTextStyles.displaySmall.copyWith(
                    color: Colors.white,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing16),
                Text(
                  '$correctCount / $total 정답 ($percentage%)',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing32),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing32, vertical: AppDimensions.spacing16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppDimensions.radius20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '당신의 랭크',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacing8),
                      Text(
                        rankResult,
                        style: AppTextStyles.headlineLarge.copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: rankColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing40),
                  child: SizedBox(
                    width: double.infinity,
                    height: AppDimensions.buttonHeightLarge,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.skyBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radius16),
                        ),
                      ),
                      child: Text(
                        '홈으로 돌아가기',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  void _checkAnswer() {
    final problem = currentProblem;
    if (problem == null || selectedAnswer == null) return;

    final result = AnswerValidator.validateMultipleChoice(
      selectedAnswer!,
      problem.correctAnswer,
    );

    setState(() {
      isAnswerChecked = true;
      isCorrect = result.isCorrect;

      final updatedAnswers = Map<String, String>.from(session.userAnswers);
      updatedAnswers[problem.id] = selectedAnswer!;

      final updatedCorrectness = Map<String, bool>.from(session.correctness);
      updatedCorrectness[problem.id] = result.isCorrect;

      session = session.copyWith(
        userAnswers: updatedAnswers,
        correctness: updatedCorrectness,
        hearts: result.isCorrect ? session.hearts : session.hearts - 1,
        score: session.score + (result.isCorrect ? problem.points : 0),
      );
    });
  }

  void _nextProblem() {
    if (session.hearts <= 0 ||
        session.currentProblemIndex + 1 >= session.totalProblems) {
      setState(() {
        isComplete = true;
      });
      return;
    }

    setState(() {
      session = session.copyWith(
        currentProblemIndex: session.currentProblemIndex + 1,
      );
      selectedAnswer = null;
      isAnswerChecked = false;
      isCorrect = false;
    });
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('레벨테스트 종료'),
        content: const Text('테스트를 종료하시겠습니까?\n진행 상황이 저장되지 않습니다.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radius16)),
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
            child: const Text('종료', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
