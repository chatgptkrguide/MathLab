import 'package:flutter/material.dart';
import '../../data/models/models.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_dimensions.dart';

/// 리그 정보 표시 위젯
class LeagueWidget extends StatelessWidget {
  final LeagueInfo leagueInfo;
  final VoidCallback? onTap;

  const LeagueWidget({
    super.key,
    required this.leagueInfo,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: leagueInfo.tier.gradientColors,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          boxShadow: [
            BoxShadow(
              color: leagueInfo.tier.color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 티어 정보
            Row(
              children: [
                Text(
                  leagueInfo.tier.emoji,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: AppDimensions.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${leagueInfo.tier.displayName} 리그',
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '#${leagueInfo.rank} / ${leagueInfo.totalPlayers}명',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                // 상태 배지
                if (leagueInfo.canPromote)
                  _buildStatusBadge('승급권', Colors.green)
                else if (leagueInfo.relegationRisk)
                  _buildStatusBadge('강등권', Colors.red),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingL),
            // 다음 티어 정보
            if (leagueInfo.tier.nextTier != null) ...[
              Row(
                children: [
                  Text(
                    '다음: ${leagueInfo.tier.nextTier!.displayName}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${leagueInfo.xpToNextTier} XP',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingS),
              // 진행률 바
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                child: LinearProgressIndicator(
                  value: leagueInfo.progressInTier,
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ] else
              Text(
                '최고 티어 달성! 🎉',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// 리그 티어 아이콘
class LeagueTierIcon extends StatelessWidget {
  final LeagueTier tier;
  final double size;

  const LeagueTierIcon({
    super.key,
    required this.tier,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: tier.gradientColors,
        ),
        boxShadow: [
          BoxShadow(
            color: tier.color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          tier.emoji,
          style: TextStyle(fontSize: size * 0.6),
        ),
      ),
    );
  }
}
