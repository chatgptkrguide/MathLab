// Home review badge — shows pending wrong-answer review count when > 0.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers/infrastructure/navigation_provider.dart';
import '../../../data/providers/wrong_answer/wrong_answer_provider.dart';

class HomeReviewBadge extends ConsumerWidget {
  final String userId;

  const HomeReviewBadge({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wrongState = ref.watch(wrongAnswerProvider(userId));
    final reviewCount =
        wrongState.wrongAnswers.where((w) => w.shouldReview()).length;

    if (reviewCount == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: GestureDetector(
        onTap: () => ref.read(navigationProvider.notifier).goToWrongAnswer(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.refresh_rounded, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                '복습할 문제 $reviewCount개',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
