import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../shared/constants/app_dimensions.dart';
import '../../shared/widgets/layout/responsive_wrapper.dart';
import '../../shared/widgets/animations/fade_in_widget.dart';
import '../../shared/widgets/cards/achievement_card.dart';
import '../../shared/widgets/buttons/animated_button.dart';
import '../../data/models/models.dart';
import '../../data/providers/user_provider.dart';
import '../../data/providers/achievement_provider.dart';
import '../auth/auth_screen.dart';

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
                  child: _buildContent(user, achievements.achievements),
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
              color: AppColors.surface,
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
              color: AppColors.surface,
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
    final isGuest = user?.name == '게스트';

    return FadeInWidget(
      duration: const Duration(milliseconds: 600),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingXL),
        child: Column(
          children: [
            // 프로필 사진
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.mathButtonGradient,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.mathButtonBlue.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  (user?.name != null && user!.name.isNotEmpty) ? user.name[0] : '학',
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: AppColors.surface,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),
            // 이름
            Text(
              user?.name ?? '학습자',
              style: AppTextStyles.headlineLarge.copyWith(
                color: AppColors.surface,
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: AppDimensions.spacingS),
            // 학년 또는 게스트 표시
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingM,
                vertical: 6,
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
                  height: 36,
                  color: AppColors.surface.withValues(alpha: 0.25),
                ),
                _buildTopStat('${user?.xp ?? 0}', 'XP', '🔶'),
                Container(
                  width: 1,
                  height: 36,
                  color: AppColors.surface.withValues(alpha: 0.25),
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
              color: AppColors.surface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.surface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  /// 통계 섹션 (흰색 배경 영역 - 반응형)
  Widget _buildStatisticsSection(User? user) {
    final isGuest = user?.name == '게스트';

    return FadeInWidget(
      duration: const Duration(milliseconds: 600),
      delay: const Duration(milliseconds: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 게스트 로그인 안내 (게스트인 경우에만)
          if (isGuest) ...[
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              decoration: BoxDecoration(
                color: AppColors.mathYellow.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                border: Border.all(
                  color: AppColors.mathYellow.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text('🎯', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: AppDimensions.spacingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '로그인하고 학습 기록을 저장하세요',
                              style: AppTextStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '소셜 로그인으로 간편하게 시작할 수 있어요',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingM),
                  Builder(
                    builder: (context) => AnimatedButton(
                      text: '로그인하러 가기',
                      onPressed: () => _navigateToLogin(context),
                      backgroundColor: AppColors.mathYellow,
                      shadowColor: AppColors.mathYellowDark,
                      textColor: AppColors.textPrimary,
                      width: double.infinity,
                      height: 48,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXL),
          ],
          Text(
            '학습 통계',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingL),
          // 통계 카드들 (반응형 2x2 그리드)
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmallScreen = constraints.maxWidth < 400;
              final spacing = isSmallScreen ? AppDimensions.spacingS : AppDimensions.spacingM;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('레벨', '${user?.level ?? 1}', '⭐')),
                      SizedBox(width: spacing),
                      Expanded(child: _buildStatCard('총 XP', '${user?.xp ?? 0}', '🔶')),
                    ],
                  ),
                  SizedBox(height: spacing),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('연속일', '${user?.streakDays ?? 0}일', '🔥')),
                      SizedBox(width: spacing),
                      Expanded(child: _buildStatCard('하트', '${user?.hearts ?? 5}개', '❤️')),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _navigateToLogin(BuildContext context) async {
    final shouldNavigate = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        title: const Text('로그인'),
        content: const Text(
          '로그인 화면으로 이동하시겠습니까?\n현재 게스트 계정의 학습 기록은 유지됩니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              '취소',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              '이동',
              style: TextStyle(color: AppColors.mathYellow),
            ),
          ),
        ],
      ),
    );

    if (shouldNavigate == true && context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    }
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
            LayoutBuilder(
              builder: (context, constraints) {
                // 화면 크기에 따라 열 개수 조정
                final crossAxisCount = constraints.maxWidth < 360 ? 2 : 3;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: AppDimensions.spacingS,
                    crossAxisSpacing: AppDimensions.spacingS,
                    childAspectRatio: 0.9,
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
            LayoutBuilder(
              builder: (context, constraints) {
                // 화면 크기에 따라 열 개수 조정
                final crossAxisCount = constraints.maxWidth < 360 ? 2 : 3;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: AppDimensions.spacingS,
                    crossAxisSpacing: AppDimensions.spacingS,
                    childAspectRatio: 0.9,
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

