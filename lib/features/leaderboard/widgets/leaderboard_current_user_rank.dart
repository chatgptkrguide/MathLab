import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_dimensions.dart';
import '../../../shared/widgets/animations/fade_in_widget.dart';
import '../../../shared/utils/level_badge_mapper.dart';
import '../../../data/models/models.dart';

/// 현재 사용자 순위 표시 위젯 (Duolingo flat style with 3D shadow + animation)
class LeaderboardCurrentUserRank extends StatelessWidget {
  final LeaderboardEntry entry;

  const LeaderboardCurrentUserRank({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInWidget(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutBack,
          tween: Tween(begin: 0.9, end: 1.0),
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // GoMath 3D solid shadow
                  Positioned(
                    top: 6,
                    left: 0,
                    right: 0,
                    bottom: -6,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors
                            .mathGreenDark, // Darker green (successGreen 20% darker)
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  // Main container
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.successGreen, // GoMath green
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.mathGreenDark, // Darker green
                        width: 3,
                      ),
                    ),
                    child: Row(
                      children: [
                        // 순위
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusXL),
                            border: Border.all(
                              color: AppColors.mathGreenDark, // Darker green
                              width: 3,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${entry.rank}',
                              style: const TextStyle(
                                color: AppColors.successGreen, // GoMath green
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        // 사용자 정보
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '나의 순위',
                                style: TextStyle(
                                  color: AppColors.surface,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                entry.userName,
                                style: const TextStyle(
                                  color: AppColors.surface,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                        // XP
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${entry.xp} XP',
                              style: const TextStyle(
                                color: AppColors.surface,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // 레벨 배지
                            Image.asset(
                              LevelBadgeMapper.getBadgeImagePath(entry.level),
                              width: 24,
                              height: 24,
                              errorBuilder: (context, error, stackTrace) {
                                return Text(
                                  'Lv.${entry.level}',
                                  style: const TextStyle(
                                    color: AppColors.surface,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
