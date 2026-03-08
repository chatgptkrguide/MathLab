import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/challenge/daily_challenge_provider.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_dimensions.dart';
import '../../../shared/constants/app_text_styles.dart';

/// Firestore-backed daily challenge card with gold gradient background
class HomeDailyChallenge extends ConsumerWidget {
  const HomeDailyChallenge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challenge = ref.watch(dailyChallengeProvider);

    // Show loading skeleton
    if (challenge.isLoading) {
      return _buildSkeleton();
    }

    // Show error fallback (static card)
    if (challenge.error != null) {
      return _buildCard(
        description: '오늘의 챌린지를 불러오는 중...',
        progress: 0.0,
        progressText: '-/- 완료',
        rewardXp: 0,
        completed: false,
      );
    }

    return _buildCard(
      description: challenge.description,
      progress: challenge.progress,
      progressText: challenge.progressText,
      rewardXp: challenge.rewardXp,
      completed: challenge.completed,
    );
  }

  Widget _buildCard({
    required String description,
    required double progress,
    required String progressText,
    required int rewardXp,
    required bool completed,
  }) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: completed ? _completedGradient : AppColors.goldGradient,
            borderRadius: BorderRadius.circular(AppDimensions.radius16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Left: icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  completed
                      ? Icons.check_circle_rounded
                      : Icons.emoji_events_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              // Center: text and progress
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      completed ? '챌린지 완료!' : '오늘의 챌린지',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Progress bar
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radius4),
                      child: LinearProgressIndicator(
                        value: completed ? 1.0 : progress,
                        minHeight: 6,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacing4),
                    Text(
                      completed
                          ? '\u{2705} 완료!'
                          : '\u{2B50} $progressText',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppDimensions.spacing12),

              // Right: reward display
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacing8,
                  vertical: AppDimensions.spacing4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radius12),
                ),
                child: Column(
                  children: [
                    Text(
                      '+$rewardXp',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'XP',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Decorative dot at top-right for asymmetric feel
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  /// Skeleton loader while data is loading
  Widget _buildSkeleton() {
    return Container(
      width: double.infinity,
      height: 100,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
      ),
    );
  }

  /// Green gradient for completed challenges
  LinearGradient get _completedGradient => const LinearGradient(
        colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}
