import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/models.dart';
import '../../../data/providers/learning/practice_provider.dart';
import '../../../shared/constants/constants.dart';
import '../../../shared/utils/haptic_feedback.dart';
import '../practice_screen.dart';

/// 연습 모드 카테고리 카드 위젯
class PracticeCategoryCard extends ConsumerWidget {
  final PracticeCategory category;

  const PracticeCategoryCard({
    super.key,
    required this.category,
  });

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
          await ref
              .read(practiceProvider.notifier)
              .startCategoryPractice(category);
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
              color: AppColors.borderLight.withOpacity(0.15),
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
