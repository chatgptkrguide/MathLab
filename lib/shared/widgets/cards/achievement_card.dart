import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_dimensions.dart';
import '../../../data/models/models.dart';

/// 업적 카드 위젯 (데이터 모델 기반)
/// 프로필 화면에서 업적을 표시하는데 사용
class AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback? onTap;

  const AchievementCard({
    super.key,
    required this.achievement,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnlocked = achievement.isUnlocked;
    final progress = achievement.progress;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        decoration: BoxDecoration(
          gradient: isUnlocked
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _getRarityGradient(),
                )
              : null,
          color: isUnlocked ? null : AppColors.background,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          border: Border.all(
            color: isUnlocked
                ? Colors.transparent
                : AppColors.borderColor,
            width: 1,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: _getRarityColor().withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 아이콘
            _buildIcon(isUnlocked),
            const SizedBox(height: AppDimensions.spacingS),
            // 제목
            Text(
              achievement.title,
              style: AppTextStyles.titleSmall.copyWith(
                color: isUnlocked ? AppColors.surface : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppDimensions.spacingXS),
            // 진행률 (잠김 상태일 때만)
            if (!isUnlocked) ...[
              LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.progressBackground,
                valueColor: AlwaysStoppedAnimation(
                  _getRarityColor(),
                ),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                minHeight: 4,
              ),
              const SizedBox(height: AppDimensions.spacingXS),
              Text(
                achievement.progressText,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            // XP 보상 (잠김 상태일 때만)
            if (!isUnlocked) ...[
              const SizedBox(height: AppDimensions.spacingXS),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '🔶',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '+${achievement.xpReward}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.mathOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
            // 달성 날짜 (달성 상태일 때만)
            if (isUnlocked && achievement.unlockedAt != null) ...[
              const SizedBox(height: AppDimensions.spacingXS),
              Text(
                _formatDate(achievement.unlockedAt!),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.surface.withValues(alpha: 0.9),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 아이콘 빌드
  Widget _buildIcon(bool isUnlocked) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: isUnlocked
            ? AppColors.surface.withValues(alpha: 0.3)
            : AppColors.disabled.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          achievement.icon,
          style: TextStyle(
            fontSize: 28,
            color: isUnlocked ? null : AppColors.disabled,
          ),
        ),
      ),
    );
  }

  /// 희귀도별 그라디언트 색상
  List<Color> _getRarityGradient() {
    switch (achievement.rarity) {
      case AchievementRarity.common:
        return [AppColors.textSecondary, AppColors.textSecondary.withValues(alpha: 0.8)]; // GoMath gray
      case AchievementRarity.uncommon:
        return AppColors.greenGradient;
      case AchievementRarity.rare:
        return AppColors.blueGradient;
      case AchievementRarity.epic:
        return AppColors.purpleGradient;
      case AchievementRarity.legendary:
        return AppColors.orangeGradient;
    }
  }

  /// 희귀도별 메인 색상
  Color _getRarityColor() {
    switch (achievement.rarity) {
      case AchievementRarity.common:
        return AppColors.textSecondary; // GoMath gray (consistent)
      case AchievementRarity.uncommon:
        return AppColors.successGreen; // GoMath green
      case AchievementRarity.rare:
        return AppColors.mathBlue; // GoMath blue
      case AchievementRarity.epic:
        return AppColors.mathPurple; // GoMath purple
      case AchievementRarity.legendary:
        return AppColors.mathOrange; // GoMath orange
    }
  }

  /// 날짜 포맷
  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}
