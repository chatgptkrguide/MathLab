import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/learning/wrong_answer_provider.dart';
import '../../../data/models/learning/wrong_answer.dart';
import '../../../shared/constants/constants.dart';
import 'wrong_answer_card.dart';

/// 최근 오답 탭
class RecentTab extends ConsumerWidget {
  final WrongAnswerProvider provider;
  final Function(WrongAnswer) onTap;

  const RecentTab({
    super.key,
    required this.provider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentList = provider.recentList;

    if (recentList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.mathBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Text(
                '📝',
                style: TextStyle(fontSize: 80),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),
            Text(
              '아직 오답이 없어요',
              style: AppTextStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              '문제를 풀면 여기에 저장돼요',
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
      itemCount: recentList.length,
      itemBuilder: (context, index) {
        final wrongAnswer = recentList[index];
        return WrongAnswerCard(
          wrongAnswer: wrongAnswer,
          showReviewInfo: true,
          onTap: () => onTap(wrongAnswer),
        );
      },
    );
  }
}
