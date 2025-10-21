import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../shared/constants/app_dimensions.dart';
import '../../shared/widgets/responsive_wrapper.dart';
import '../../shared/widgets/fade_in_widget.dart';
import '../../shared/widgets/achievement_card.dart';
import '../../data/models/models.dart';
import '../../data/providers/user_provider.dart';
import '../../data/providers/achievement_provider.dart';

/// 프로필/계정 화면 (업적 시스템 통합)
/// 사용자 정보, 학습 통계, 업적을 표시
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final achievements = ref.watch(achievementProvider);

    return Scaffold(
      backgroundColor: AppColors.mathBlue,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.mathBlueGradient,
          ),
        ),
        child: SafeArea(
          child: ResponsiveWrapper(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _buildContent(user, achievements),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 헤더
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '👤',
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(width: AppDimensions.spacingM),
          Text(
            '프로필',
            style: AppTextStyles.headlineMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 메인 컨텐츠
  Widget _buildContent(User? user, List<Achievement> achievements) {
    // 업적 분류
    final unlockedAchievements =
        achievements.where((a) => a.isUnlocked).toList();
    final lockedAchievements =
        achievements.where((a) => !a.isUnlocked).toList();

    return Column(
      children: [
        // 프로필 섹션 (파란 배경)
        _buildProfileSection(user),
        // 통계 및 업적 섹션 (흰색 배경)
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingXL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatisticsSection(user),
                  const SizedBox(height: AppDimensions.spacingXXL),
                  _buildAchievementsSection(
                    unlockedAchievements,
                    lockedAchievements,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 프로필 섹션 (파란 배경 영역)
  Widget _buildProfileSection(User? user) {
    return FadeInWidget(
      duration: const Duration(milliseconds: 600),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingXL),
        child: Column(
          children: [
            // 프로필 사진
            Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.mathButtonGradient,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.mathButtonBlue.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      (user?.name != null && user!.name.isNotEmpty) ? user.name[0] : '학',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingL),
            // 이름
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
              child: Text(
                user?.name ?? '학습자',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            // 학년
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingM,
                vertical: AppDimensions.paddingS,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              ),
              child: Text(
                user?.currentGrade ?? '중1',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXL),
            // 통계 (Level, XP, Streak)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTopStat('${user?.level ?? 1}', '레벨', '⭐'),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                _buildTopStat('${user?.xp ?? 0}', 'XP', '🔶'),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                _buildTopStat('${user?.streakDays ?? 0}', '연속', '🔥'),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingXXL),
          ],
        ),
      ),
    );
  }

  /// 상단 통계
  Widget _buildTopStat(String value, String label, String emoji) {
    return Expanded(
      child: Column(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: AppDimensions.spacingXS),
          Text(
            value,
            style: AppTextStyles.headlineSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  /// 통계 섹션 (흰색 배경 영역 - 반응형)
  Widget _buildStatisticsSection(User? user) {
    return FadeInWidget(
      duration: const Duration(milliseconds: 600),
      delay: const Duration(milliseconds: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '학습 통계',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingL),
          // 통계 카드들 (반응형 그리드)
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmallScreen = constraints.maxWidth < 400;
              return GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: isSmallScreen
                    ? AppDimensions.spacingS
                    : AppDimensions.spacingM,
                crossAxisSpacing: isSmallScreen
                    ? AppDimensions.spacingS
                    : AppDimensions.spacingM,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: isSmallScreen ? 1.2 : 1.3,
                children: [
                  _buildStatCard('레벨', '${user?.level ?? 1}', '⭐'),
                  _buildStatCard('총 XP', '${user?.xp ?? 0}', '🔶'),
                  _buildStatCard('연속일', '${user?.streakDays ?? 0}일', '🔥'),
                  _buildStatCard('하트', '${user?.hearts ?? 5}개', '❤️'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// 통계 카드
  Widget _buildStatCard(String label, String value, String emoji) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: AppColors.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXS),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 업적 섹션
  Widget _buildAchievementsSection(
    List<Achievement> unlocked,
    List<Achievement> locked,
  ) {
    return FadeInWidget(
      duration: const Duration(milliseconds: 600),
      delay: const Duration(milliseconds: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '업적',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingM,
                  vertical: AppDimensions.paddingS,
                ),
                decoration: BoxDecoration(
                  color: AppColors.mathTeal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                ),
                child: Text(
                  '${unlocked.length}/${unlocked.length + locked.length}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.mathTeal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingL),

          // 달성한 업적
          if (unlocked.isNotEmpty) ...[
            Text(
              '달성 완료',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: AppDimensions.spacingM,
                crossAxisSpacing: AppDimensions.spacingM,
                childAspectRatio: 0.85,
              ),
              itemCount: unlocked.length,
              itemBuilder: (context, index) {
                return FadeInWidget(
                  delay: Duration(milliseconds: 50 * index),
                  child: AchievementCard(
                    achievement: unlocked[index],
                    onTap: () => _showAchievementDetail(unlocked[index]),
                  ),
                );
              },
            ),
            const SizedBox(height: AppDimensions.spacingXL),
          ],

          // 잠긴 업적
          if (locked.isNotEmpty) ...[
            Text(
              '진행 중',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: AppDimensions.spacingM,
                crossAxisSpacing: AppDimensions.spacingM,
                childAspectRatio: 0.85,
              ),
              itemCount: locked.length,
              itemBuilder: (context, index) {
                return FadeInWidget(
                  delay: Duration(milliseconds: 50 * (unlocked.length + index)),
                  child: AchievementCard(
                    achievement: locked[index],
                    onTap: () => _showAchievementDetail(locked[index]),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  /// 업적 상세 정보 다이얼로그
  void _showAchievementDetail(Achievement achievement) {
    // TODO: 업적 상세 정보 다이얼로그 표시
  }
}
