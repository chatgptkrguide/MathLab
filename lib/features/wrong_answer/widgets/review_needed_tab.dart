import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/learning/wrong_answer_provider.dart';
import '../../../data/models/learning/wrong_answer.dart';
import '../../../shared/constants/constants.dart';
import 'wrong_answer_card.dart';

/// 복습 필요 탭
class ReviewNeededTab extends ConsumerWidget {
  final WrongAnswerProvider provider;
  final Function(WrongAnswer) onTap;

  const ReviewNeededTab({
    super.key,
    required this.provider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewList = provider.reviewList;

    if (reviewList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.mathYellow.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.celebration_rounded,
                color: AppColors.mathYellow,
                size: 80,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),
            Text(
              '완벽해요! 🎉',
              style: AppTextStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              '복습할 문제가 없어요',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      itemCount: reviewList.length,
      itemBuilder: (context, index) {
        final wrongAnswer = reviewList[index];
        return WrongAnswerCard(
          wrongAnswer: wrongAnswer,
          showUrgency: true,
          onTap: () => onTap(wrongAnswer),
        );
      },
    );
  }
}
