import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/achievement_provider.dart';
import '../../data/models/achievement.dart';
import '../../shared/constants/constants.dart';
import '../../shared/utils/haptic_feedback.dart';

/// 업적 화면
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(achievementProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          '업적',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () async {
            await AppHapticFeedback.lightImpact();
            if (context.mounted) Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          // 진행 현황 - GoMath style
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.paddingXL),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                bottom: BorderSide(color: AppColors.borderLight, width: 1),
              ),
            ),
            child: Column(
              children: [
                Text(
                  '${state.unlockedCount} / ${state.totalCount}',
                  style: const TextStyle(
                    color: AppColors.successGreen, // GoMath 초록색
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                  ),
                ),
                const SizedBox(height: 12),
                // GoMath-style progress bar with animation
                Stack(
                  children: [
                    Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.borderLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      tween: Tween(begin: 0.0, end: state.completionRate),
                      builder: (context, value, child) {
                        return FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: value.clamp(0.01, 1.0),
                          child: Container(
                            height: 12,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.successGreen,
                                  AppColors.duolingoGreenDark,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.successGreen.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${(state.completionRate * 100).toStringAsFixed(1)}% 완료',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // 업적 리스트
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              itemCount: state.achievements.length,
              itemBuilder: (context, index) {
                final achievement = state.achievements[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
                  child: _AchievementCard(achievement: achievement),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 업적 카드
class _AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const _AchievementCard({required this.achievement});

  Color _getRarityColor() {
    switch (achievement.rarity) {
      case AchievementRarity.common:
        return Colors.grey;
      case AchievementRarity.uncommon:
        return Colors.green;
      case AchievementRarity.rare:
        return Colors.blue;
      case AchievementRarity.epic:
        return Colors.purple;
      case AchievementRarity.legendary:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = achievement.currentValue / achievement.requiredValue;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: achievement.isUnlocked
            ? AppColors.surface
            : AppColors.background, // GoMath 배경색
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: achievement.isUnlocked
              ? _getRarityColor()
              : AppColors.borderLight,
          width: achievement.isUnlocked ? 3 : 2,
        ),
      ),
      child: Row(
        children: [
          // 아이콘 - GoMath style
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: achievement.isUnlocked
                  ? _getRarityColor()
                  : AppColors.borderLight,
              shape: BoxShape.circle,
              border: Border.all(
                color: achievement.isUnlocked
                    ? _getRarityColor()
                    : AppColors.borderLight,
                width: 3,
              ),
            ),
            child: Center(
              child: Text(
                achievement.icon,
                style: TextStyle(
                  fontSize: 30,
                  color: achievement.isUnlocked ? null : Colors.grey,
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // 정보 - Duolingo typography
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        achievement.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: achievement.isUnlocked
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    if (achievement.isUnlocked)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.successGreen, // GoMath 초록색
                        size: 24,
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  achievement.description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                if (!achievement.isUnlocked) ...[
                  // GoMath progress bar
                  Stack(
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.borderLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress.clamp(0.01, 1.0),
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getRarityColor(),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${achievement.currentValue} / ${achievement.requiredValue}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text(
                      '+${achievement.xpReward} XP',
                      style: const TextStyle(
                        color: AppColors.mathYellow, // GoMath 노란색
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
