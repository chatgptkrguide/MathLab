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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingS,
          vertical: AppDimensions.paddingM,
        ),
        decoration: BoxDecoration(
          gradient: isUnlocked
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _getRarityGradient(),
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.surface,
                    AppColors.background,
                  ],
                ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          border: Border.all(
            color: isUnlocked
                ? _getRarityColor().withValues(alpha: 0.3)
                : AppColors.borderLight,
            width: isUnlocked ? 2 : 1,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: _getRarityColor().withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: AppColors.textSecondary.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 아이콘
            _buildIcon(isUnlocked),
            const SizedBox(height: 6),
            // 제목
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  achievement.title,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: isUnlocked ? AppColors.surface : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    shadows: isUnlocked
                        ? [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              offset: const Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(height: 4),
            // 진행률 또는 달성 표시
            if (!isUnlocked) ...[
              Container(
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: AppColors.progressBackground,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getRarityColor(),
                            _getRarityColor().withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                achievement.progressText,
                style: TextStyle(
                  fontSize: 9,
                  color: _getRarityColor(),
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.surface,
                      size: 11,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '달성',
                      style: TextStyle(
                        fontSize: 8.5,
                        color: AppColors.surface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        gradient: isUnlocked
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.surface.withValues(alpha: 0.4),
                  AppColors.surface.withValues(alpha: 0.2),
                ],
              )
            : LinearGradient(
                colors: [
                  AppColors.disabled.withValues(alpha: 0.15),
                  AppColors.disabled.withValues(alpha: 0.08),
                ],
              ),
        shape: BoxShape.circle,
        border: Border.all(
          color: isUnlocked
              ? AppColors.surface.withValues(alpha: 0.3)
              : AppColors.disabled.withValues(alpha: 0.2),
          width: 2,
        ),
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: AppColors.surface.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          achievement.icon,
          style: TextStyle(
            fontSize: 22,
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
