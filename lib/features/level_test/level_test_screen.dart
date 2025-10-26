import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/level_test.dart';
import '../../data/providers/level_test_provider.dart';
import '../../shared/constants/constants.dart';
import '../../shared/utils/haptic_feedback.dart';
import '../../shared/widgets/buttons/duolingo_button.dart';

/// 레벨 테스트 화면
class LevelTestScreen extends ConsumerStatefulWidget {
  const LevelTestScreen({super.key});

  @override
  ConsumerState<LevelTestScreen> createState() => _LevelTestScreenState();
}

class _LevelTestScreenState extends ConsumerState<LevelTestScreen> {
  int? _selectedAnswerIndex;

  @override
  void initState() {
    super.initState();
    // 테스트 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(levelTestProvider);
      if (state.currentTest == null) {
        ref.read(levelTestProvider.notifier).startNewTest();
      }
    });
  }

  Future<void> _submitAnswer() async {
    if (_selectedAnswerIndex == null) return;

    await AppHapticFeedback.lightImpact();
    await ref.read(levelTestProvider.notifier).submitAnswer(_selectedAnswerIndex!);

    setState(() {
      _selectedAnswerIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(levelTestProvider);

    if (state.isCompleted && state.result != null) {
      return _LevelTestResultScreen(result: state.result!);
    }

    if (state.currentQuestion == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final question = state.currentQuestion!;
    final progress = state.progress;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          '레벨 테스트',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () async {
            await AppHapticFeedback.lightImpact();
            final shouldExit = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('테스트를 종료하시겠습니까?'),
                content: const Text('진행 상황이 저장됩니다.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('계속하기'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('종료'),
                  ),
                ],
              ),
            );
            if (shouldExit == true && mounted) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 진행률 바
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.disabled.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: AppDimensions.paddingL),

            // 문제 번호 및 난이도
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '문제 ${state.currentQuestionIndex + 1}/${state.currentTest!.questions.length}',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingM,
                      vertical: AppDimensions.paddingS,
                    ),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(question.difficulty).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      border: Border.all(
                        color: _getDifficultyColor(question.difficulty),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: _getDifficultyColor(question.difficulty),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '난이도 ${question.difficulty}',
                          style: TextStyle(
                            color: _getDifficultyColor(question.difficulty),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.paddingXL),

            // 문제
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 문제 텍스트
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.borderLight.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        question.question,
                        style: AppTextStyles.displaySmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingXL),

                    // 선택지
                    ...List.generate(
                      question.options.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
                        child: _OptionButton(
                          option: question.options[index],
                          index: index,
                          isSelected: _selectedAnswerIndex == index,
                          onTap: () {
                            setState(() {
                              _selectedAnswerIndex = index;
                            });
                            AppHapticFeedback.selection();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 제출 버튼
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: DuolingoButton(
                text: '다음',
                onPressed: _selectedAnswerIndex != null ? _submitAnswer : null,
                isEnabled: _selectedAnswerIndex != null,
                backgroundColor: AppColors.primary,
                icon: Icons.arrow_forward,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(int difficulty) {
    switch (difficulty) {
      case 1:
      case 2:
        return AppColors.successGreen;
      case 3:
        return AppColors.primary;
      case 4:
      case 5:
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}

/// 선택지 버튼
class _OptionButton extends StatelessWidget {
  final String option;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionButton({
    required this.option,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            else
              BoxShadow(
                color: AppColors.borderLight.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.surface : AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.surface : AppColors.primary,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index), // A, B, C, D
                  style: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.spacingM),
            Expanded(
              child: Text(
                option,
                style: AppTextStyles.titleMedium.copyWith(
                  color: isSelected ? AppColors.surface : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 레벨 테스트 결과 화면
class _LevelTestResultScreen extends ConsumerWidget {
  final LevelTestResult result;

  const _LevelTestResultScreen({required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Column(
                  children: [
                    const SizedBox(height: AppDimensions.paddingXL),
                    // 아이콘
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: AppColors.goldGradient),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        size: 64,
                        color: AppColors.surface,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingXL),

                    // 제목
                    Text(
                      '테스트 완료!',
                      style: AppTextStyles.displaySmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingS),
                    Text(
                      result.performanceMessage,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.paddingXL),

                    // 레벨
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingXL),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.borderLight.withValues(alpha: 0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            '추천 레벨',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.spacingM),
                          Text(
                            'Level ${result.recommendedLevel}',
                            style: AppTextStyles.displayLarge.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.spacingS),
                          Text(
                            result.levelDescription,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingL),

                    // 통계
                    _StatCard(
                      icon: Icons.check_circle,
                      label: '정답',
                      value: '${result.correctAnswers}/${result.totalQuestions}',
                      color: AppColors.success,
                    ),
                    const SizedBox(height: AppDimensions.paddingM),
                    _StatCard(
                      icon: Icons.percent,
                      label: '정답률',
                      value: '${(result.accuracy * 100).toStringAsFixed(1)}%',
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),

            // 시작하기 버튼
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: DuolingoButton(
                text: '학습 시작하기',
                onPressed: () {
                  Navigator.of(context).pop();
                },
                backgroundColor: AppColors.successGreen,
                icon: Icons.rocket_launch,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 통계 카드
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
