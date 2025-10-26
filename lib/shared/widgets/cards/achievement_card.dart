import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
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
      child: Opacity(
        opacity: isUnlocked ? 1.0 : 0.5,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          decoration: BoxDecoration(
          gradient: isUnlocked
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _getRarityGradient(),
                )
              : null,
          color: isUnlocked ? null : AppColors.background,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(
            color: isUnlocked
                ? Colors.transparent
                : AppColors.borderColor,
            width: 1,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: _getRarityColor().withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 아이콘
            _buildIcon(isUnlocked),
            const SizedBox(height: 6),
            // 제목
            Flexible(
              child: Text(
                achievement.title,
                style: TextStyle(
                  fontSize: 11,
                  color: isUnlocked ? AppColors.surface : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            // 진행률 또는 달성 표시
            if (!isUnlocked) ...[
              Container(
                height: 3,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: AppColors.progressBackground,
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: _getRarityColor(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                achievement.progressText,
                style: const TextStyle(
                  fontSize: 9,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ] else ...[
              const Icon(
                Icons.check_circle,
                color: AppColors.surface,
                size: 16,
              ),
            ],
          ],
        ),
      ),
      ),
    );
  }

  /// 아이콘 빌드
  Widget _buildIcon(bool isUnlocked) {
    return Container(
      width: 40,
      height: 40,
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
            fontSize: 20,
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
  // ignore: unused_element
  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}
