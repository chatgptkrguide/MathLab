import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/learning/wrong_answer_provider.dart';
import '../../../data/models/learning/wrong_answer.dart';
import '../../../shared/constants/constants.dart';
import 'wrong_answer_card.dart';

/// 완료 탭
class MasteredTab extends ConsumerWidget {
  final WrongAnswerProvider provider;
  final Function(WrongAnswer) onTap;

  const MasteredTab({
    super.key,
    required this.provider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final masteredList = provider.masteredList;

    if (masteredList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.successGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                color: AppColors.mathYellow,
                size: 80,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),
            Text(
              '아직 완료한 문제가 없어요',
              style: AppTextStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              '3번 연속 맞히면 완료돼요',
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
      itemCount: masteredList.length,
      itemBuilder: (context, index) {
        final wrongAnswer = masteredList[index];
        return WrongAnswerCard(
          wrongAnswer: wrongAnswer,
          isMastered: true,
          onTap: () => onTap(wrongAnswer),
        );
      },
    );
  }
}
