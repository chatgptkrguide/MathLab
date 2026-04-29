// Problem Header Widget
//
// Displays the progress bar, back button, unit/step info, and XP.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/user/user_provider.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_text_styles.dart';

class ProblemHeader extends StatelessWidget {
  final double progress;
  final String problemNumber;
  final String lessonTitle;
  final String? unitTitle;
  final int? stepNumber;
  final int? totalSteps;
  final VoidCallback onBack;

  const ProblemHeader({
    super.key,
    required this.progress,
    required this.problemNumber,
    required this.lessonTitle,
    this.unitTitle,
    this.stepNumber,
    this.totalSteps,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: const BoxDecoration(
        color: Color(0xFF61A1D8),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // Top row: back arrow, unit/step info
          Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 22),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (unitTitle != null)
                        Text(
                          unitTitle!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      Text(
                        stepNumber != null
                            ? '$lessonTitle ($stepNumber/${totalSteps ?? '?'})'
                            : '문제 $problemNumber',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 22),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar + XP display
          Row(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    AnimatedFractionallySizedBox(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      widthFactor: progress.clamp(0.0, 1.0),
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.mathGreen,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.mathGreen.withValues(alpha: 0.45),
                              blurRadius: 6,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        // 살짝 안쪽 하이라이트로 평면감 완화
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            height: 3,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.28),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Consumer(
                builder: (context, ref, _) {
                  final user = ref.watch(userProvider);
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.diamond_rounded,
                          color: Colors.white, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${user?.xp ?? 0}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
