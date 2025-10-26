import 'package:flutter/material.dart';
import '../../../shared/constants/constants.dart';
import '../../../data/models/models.dart';
import 'profile_stat_badge.dart';

/// 프로필 헤더 컨텐츠 (SliverAppBar 내부)
class ProfileHeaderContent extends StatelessWidget {
  final User? user;

  const ProfileHeaderContent({
    super.key,
    this.user,
  });

  @override
  Widget build(BuildContext context) {
    final isGuest = user?.name == '게스트';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.mathBlueGradient,
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 24), // 30 → 24
            // 프로필 사진
            Container(
              width: 64, // 70 → 64
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.mathButtonGradient,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.mathButtonBlue.withValues(alpha: 0.3),
                    blurRadius: 10, // 12 → 10
                    offset: const Offset(0, 4), // 6 → 4
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  (user!.name.isNotEmpty)
                      ? user.name[0]
                      : '학',
                  style: const TextStyle(
                    fontSize: 28, // 32 → 28
                    fontWeight: FontWeight.bold,
                    color: AppColors.surface,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10), // 12 → 10
            // 이름
            Text(
              user?.name ?? '학습자',
              style: AppTextStyles.headlineLarge.copyWith(
                color: AppColors.surface,
                fontWeight: FontWeight.bold,
                fontSize: 20, // 22 → 20
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 4), // 6 → 4
            // 학년 또는 게스트 표시
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingM,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              ),
              child: Text(
                isGuest ? '게스트 모드' : (user?.currentGrade ?? '중1'),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.surface,
                  fontWeight: FontWeight.w600,
                  fontSize: 12, // 13 → 12
                ),
              ),
            ),
            const SizedBox(height: 10), // 14 → 10
            // 통계 (Level, XP, Streak)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ProfileStatBadge(
                    value: '${user?.level ?? 1}',
                    label: '레벨',
                    icon: Icons.star,
                  ),
                  Container(
                    width: 1,
                    height: 28, // 32 → 28
                    color: AppColors.surface.withValues(alpha: 0.25),
                  ),
                  ProfileStatBadge(
                    value: '${user?.xp ?? 0}',
                    label: 'XP',
                    icon: Icons.diamond_outlined,
                  ),
                  Container(
                    width: 1,
                    height: 28,
                    color: AppColors.surface.withValues(alpha: 0.25),
                  ),
                  ProfileStatBadge(
                    value: '${user?.streakDays ?? 0}',
                    label: '연속',
                    icon: Icons.local_fire_department,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10), // 14 → 10
          ],
        ),
      ),
    );
  }
}
