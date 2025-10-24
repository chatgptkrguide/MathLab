import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/models.dart';
import '../../data/providers/practice_provider.dart';
import '../../shared/constants/constants.dart';
import '../../shared/utils/haptic_feedback.dart';
import '../../shared/widgets/buttons/duolingo_button.dart';

/// 연습 모드 카테고리 선택 화면
class PracticeCategoryScreen extends ConsumerWidget {
  const PracticeCategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          '연습 모드',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () {
            AppHapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 설명
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: AppDimensions.spacingM),
                    Expanded(
                      child: Text(
                        '연습 모드에서도 경험치를 획득할 수 있어요!\n하트는 소모되지 않으니 자유롭게 연습하세요.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.paddingXL),

              // 카테고리 버튼들
              ...PracticeCategory.values.map((category) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
                child: _CategoryCard(category: category),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

/// 카테고리 카드
class _CategoryCard extends ConsumerWidget {
  final PracticeCategory category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(practiceProvider);
    final count = stats.categoryStats[category.displayName] ?? 0;

    return GestureDetector(
      onTap: () async {
        await AppHapticFeedback.lightImpact();

        // 카테고리별 연습 시작
        if (category == PracticeCategory.errorNote) {
          await ref.read(practiceProvider.notifier).startErrorNotePractice();
        } else {
          await ref.read(practiceProvider.notifier).startCategoryPractice(category);
        }

        if (context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const PracticeScreen(),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: AppColors.borderLight.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // 아이콘
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _getCategoryColor(category).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              child: Center(
                child: Icon(
                  _getCategoryIcon(category),
                  size: 32,
                  color: _getCategoryColor(category),
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.spacingL),

            // 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.displayName,
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (count > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      '$count번 연습함',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // 화살표
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(PracticeCategory category) {
    switch (category) {
      case PracticeCategory.basicArithmetic:
        return AppColors.successGreen;
      case PracticeCategory.algebra:
        return AppColors.primary;
      case PracticeCategory.geometry:
        return AppColors.warning;
      case PracticeCategory.statistics:
        return Colors.purple;
      case PracticeCategory.errorNote:
        return AppColors.error;
    }
  }

  IconData _getCategoryIcon(PracticeCategory category) {
    switch (category) {
      case PracticeCategory.basicArithmetic:
        return Icons.calculate;
      case PracticeCategory.algebra:
        return Icons.functions;
      case PracticeCategory.geometry:
        return Icons.hexagon_outlined;
      case PracticeCategory.statistics:
        return Icons.bar_chart;
      case PracticeCategory.errorNote:
        return Icons.error_outline;
    }
  }
}

/// 연습 모드 문제 풀이 화면
class PracticeScreen extends ConsumerStatefulWidget {
  const PracticeScreen({super.key});

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  String _userAnswer = '';

  Future<void> _submitAnswer() async {
    if (_userAnswer.trim().isEmpty) return;

    await AppHapticFeedback.lightImpact();
    await ref.read(practiceProvider.notifier).submitAnswer(_userAnswer);

    setState(() {
      _userAnswer = '';
    });

    // 세션 완료 체크
    final state = ref.read(practiceProvider);
    if (!state.isSessionActive && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PracticeResultScreen(
            session: state.currentSession!,
          ),
        ),
      );
    }
  }

  Future<void> _skipProblem() async {
    await AppHapticFeedback.lightImpact();
    await ref.read(practiceProvider.notifier).skipProblem();

    setState(() {
      _userAnswer = '';
    });

    // 세션 완료 체크
    final state = ref.read(practiceProvider);
    if (!state.isSessionActive && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PracticeResultScreen(
            session: state.currentSession!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(practiceProvider);
    final problem = state.currentProblem;

    if (problem == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          state.currentSession?.category ?? '연습 모드',
          style: const TextStyle(
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
                title: const Text('연습을 종료하시겠습니까?'),
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
              value: state.progress,
              minHeight: 8,
              backgroundColor: AppColors.disabled.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.successGreen),
            ),
            const SizedBox(height: AppDimensions.paddingL),

            // 문제 번호
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '문제 ${state.currentSession!.currentProblemIndex + 1}/${state.currentSession!.totalProblems}',
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
                      color: AppColors.successGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      border: Border.all(color: AppColors.successGreen),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.psychology,
                          size: 16,
                          color: AppColors.successGreen,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '연습 모드',
                          style: TextStyle(
                            color: AppColors.successGreen,
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
                        problem.question,
                        style: AppTextStyles.displaySmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingXL),

                    // 객관식 선택지
                    if (problem.type == ProblemType.multipleChoice) ...[
                      ...List.generate(
                        problem.options.length,
                        (index) => Padding(
                          padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
                          child: _OptionButton(
                            option: problem.options[index],
                            index: index,
                            isSelected: _userAnswer == problem.options[index],
                            onTap: () {
                              setState(() {
                                _userAnswer = problem.options[index];
                              });
                              AppHapticFeedback.selection();
                            },
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // 하단 버튼들
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Row(
                children: [
                  // 건너뛰기 버튼
                  Expanded(
                    flex: 2,
                    child: OutlinedButton(
                      onPressed: _skipProblem,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppColors.textSecondary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                        ),
                      ),
                      child: Text(
                        '건너뛰기',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingM),

                  // 제출 버튼
                  Expanded(
                    flex: 3,
                    child: DuolingoButton(
                      text: '확인',
                      onPressed: _userAnswer.trim().isNotEmpty ? _submitAnswer : null,
                      isEnabled: _userAnswer.trim().isNotEmpty,
                      backgroundColor: AppColors.successGreen,
                      icon: Icons.check,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 선택지 버튼 (레벨 테스트와 동일)
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
          color: isSelected ? AppColors.successGreen : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          border: Border.all(
            color: isSelected ? AppColors.successGreen : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.successGreen.withValues(alpha: 0.3),
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
                color: isSelected ? AppColors.surface : AppColors.successGreen.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.surface : AppColors.successGreen,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index), // A, B, C, D
                  style: TextStyle(
                    color: isSelected ? AppColors.successGreen : AppColors.textPrimary,
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

/// 연습 모드 결과 화면
class PracticeResultScreen extends ConsumerWidget {
  final PracticeSession session;

  const PracticeResultScreen({
    super.key,
    required this.session,
  });

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
                        color: AppColors.successGreen.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.successGreen,
                          width: 4,
                        ),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        size: 64,
                        color: AppColors.successGreen,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingXL),

                    // 제목
                    Text(
                      '연습 완료!',
                      style: AppTextStyles.displaySmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingS),
                    Text(
                      '${session.category} 연습을 마쳤어요!',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.paddingXL),

                    // 통계 카드들
                    _StatCard(
                      icon: Icons.check_circle,
                      label: '정답',
                      value: '${session.correctCount}/${session.totalProblems}',
                      color: AppColors.success,
                    ),
                    const SizedBox(height: AppDimensions.paddingM),
                    _StatCard(
                      icon: Icons.percent,
                      label: '정답률',
                      value: '${(session.accuracy * 100).toStringAsFixed(1)}%',
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: AppDimensions.paddingM),
                    _StatCard(
                      icon: Icons.skip_next,
                      label: '건너뛴 문제',
                      value: '${session.skippedCount}개',
                      color: AppColors.warning,
                    ),
                  ],
                ),
              ),
            ),

            // 버튼들
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DuolingoButton(
                    text: '다시 풀기',
                    onPressed: () async {
                      await AppHapticFeedback.lightImpact();
                      await ref.read(practiceProvider.notifier).resetSession();
                      if (context.mounted) {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      }
                    },
                    backgroundColor: AppColors.successGreen,
                    icon: Icons.refresh,
                  ),
                  const SizedBox(height: AppDimensions.spacingM),
                  OutlinedButton(
                    onPressed: () {
                      AppHapticFeedback.lightImpact();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                      ),
                    ),
                    child: Text(
                      '홈으로',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 통계 카드 (레벨 테스트와 동일)
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: color.withOpacity(0.3)),
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
