import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../shared/constants/app_dimensions.dart';
import '../../shared/widgets/cards/achievement_card.dart';
import '../../shared/widgets/animations/animations.dart';
import '../../shared/utils/haptic_feedback.dart';
import '../../data/models/models.dart';
import '../../data/providers/user_provider.dart';
import '../../data/providers/achievement_provider.dart';
import 'settings_screen.dart';
import 'widgets/profile_header_content.dart';
import 'widgets/profile_stat_card.dart';
import 'widgets/guest_login_prompt.dart';

/// 프로필/계정 화면 (업적 시스템 통합 + 간소화)
/// CustomScrollView + SliverAppBar로 스크롤 동작 개선
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _showUnlockedAchievements = true;
  bool _showLockedAchievements = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final achievementsState = ref.watch(achievementProvider);
    final achievements = achievementsState.achievements;

    // 업적 분류
    final unlockedAchievements =
        achievements.where((a) => a.isUnlocked).toList();
    final lockedAchievements =
        achievements.where((a) => !a.isUnlocked).toList();

    final isGuest = user?.name == '게스트';

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          // SliverAppBar - 스크롤 시 축소되는 헤더
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.surface,
            leading: const SizedBox.shrink(), // 뒤로가기 버튼 제거
            actions: [
              // 설정 버튼
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      await AppHapticFeedback.selectionClick();
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      ),
                      child: const Icon(
                        Icons.settings,
                        color: AppColors.surface,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: ProfileHeaderContent(user: user),
            ),
          ),

          // 흰색 배경 시작 영역 - 곡선 전환
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: const SizedBox(height: AppDimensions.paddingXL),
            ),
          ),

          // 게스트 로그인 안내 (게스트인 경우에만)
          if (isGuest)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.paddingXL,
                  0,
                  AppDimensions.paddingXL,
                  AppDimensions.spacingXL,
                ),
                child: const GuestLoginPrompt(),
              ),
            ),

          // 업적 섹션
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingXL,
              ),
              child: Row(
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
                      '${unlockedAchievements.length}/${achievements.length}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.mathTeal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: AppDimensions.spacingL),
          ),

          // 달성한 업적 (접기/펴기)
          if (unlockedAchievements.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingXL,
                ),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _showUnlockedAchievements = !_showUnlockedAchievements;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '달성 완료',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(
                        _showUnlockedAchievements
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppDimensions.spacingM),
            ),
            if (_showUnlockedAchievements)
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingXL,
                ),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: AppDimensions.spacingM,
                    crossAxisSpacing: AppDimensions.spacingM,
                    childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return AchievementCard(
                        achievement: unlockedAchievements[index],
                        onTap: () => _showAchievementDetail(unlockedAchievements[index]),
                      );
                    },
                    childCount: unlockedAchievements.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppDimensions.spacingL),
            ),
          ],

          // 진행 중인 업적 (접기/펴기)
          if (lockedAchievements.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingXL,
                ),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _showLockedAchievements = !_showLockedAchievements;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '진행 중',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(
                        _showLockedAchievements
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppDimensions.spacingM),
            ),
            if (_showLockedAchievements)
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingXL,
                ),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: AppDimensions.spacingM,
                    crossAxisSpacing: AppDimensions.spacingM,
                    childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return AchievementCard(
                        achievement: lockedAchievements[index],
                        onTap: () => _showAchievementDetail(lockedAchievements[index]),
                      );
                    },
                    childCount: lockedAchievements.length,
                  ),
                ),
              ),
          ],

          // 하단 여백
          const SliverToBoxAdapter(
            child: SizedBox(height: AppDimensions.spacingXXL),
          ),
        ],
      ),
    );
  }

  /// 업적 상세 정보 다이얼로그
  void _showAchievementDetail(Achievement achievement) async {
    await AppHapticFeedback.lightImpact();

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        ),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingXL),
          decoration: BoxDecoration(
            gradient: achievement.isUnlocked
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _getAchievementGradient(achievement),
                  )
                : null,
            color: achievement.isUnlocked ? null : AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 아이콘
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: achievement.isUnlocked
                      ? AppColors.surface.withValues(alpha: 0.3)
                      : AppColors.disabled.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    achievement.icon,
                    style: TextStyle(
                      fontSize: 40,
                      color: achievement.isUnlocked ? null : AppColors.disabled,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.spacingL),

              // 제목
              Text(
                achievement.title,
                style: AppTextStyles.headlineMedium.copyWith(
                  color: achievement.isUnlocked ? AppColors.surface : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.spacingM),

              // 설명
              Text(
                achievement.description,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: achievement.isUnlocked
                      ? AppColors.surface.withValues(alpha: 0.9)
                      : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.spacingL),

              // 진행률 (미달성인 경우에만)
              if (!achievement.isUnlocked) ...[
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '진행률',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            achievement.progressText,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: _getAchievementColor(achievement),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.spacingM),
                      Stack(
                        children: [
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.progressBackground,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: achievement.progress.clamp(0.0, 1.0),
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: _getAchievementColor(achievement),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingL),
              ],

              // 보상
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                decoration: BoxDecoration(
                  color: achievement.isUnlocked
                      ? AppColors.surface.withValues(alpha: 0.2)
                      : AppColors.mathYellow.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.diamond,
                      color: achievement.isUnlocked
                          ? AppColors.surface
                          : AppColors.mathYellow,
                      size: 24,
                    ),
                    const SizedBox(width: AppDimensions.spacingS),
                    Text(
                      '+${achievement.xpReward} XP',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: achievement.isUnlocked
                            ? AppColors.surface
                            : AppColors.mathYellow,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spacingL),

              // 달성 상태
              if (achievement.isUnlocked) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.surface,
                      size: 20,
                    ),
                    const SizedBox(width: AppDimensions.spacingS),
                    Text(
                      '달성 완료!',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.surface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingL),
              ],

              // 닫기 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: achievement.isUnlocked
                        ? AppColors.surface
                        : AppColors.mathBlue,
                    foregroundColor: achievement.isUnlocked
                        ? _getAchievementColor(achievement)
                        : AppColors.surface,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.paddingM,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                    ),
                  ),
                  child: const Text(
                    '닫기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 희귀도별 그라디언트 색상
  List<Color> _getAchievementGradient(Achievement achievement) {
    switch (achievement.rarity) {
      case AchievementRarity.common:
        return [AppColors.textSecondary, AppColors.textSecondary.withValues(alpha: 0.8)];
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
  Color _getAchievementColor(Achievement achievement) {
    switch (achievement.rarity) {
      case AchievementRarity.common:
        return AppColors.textSecondary;
      case AchievementRarity.uncommon:
        return AppColors.successGreen;
      case AchievementRarity.rare:
        return AppColors.mathBlue;
      case AchievementRarity.epic:
        return AppColors.mathPurple;
      case AchievementRarity.legendary:
        return AppColors.mathOrange;
    }
  }
}
