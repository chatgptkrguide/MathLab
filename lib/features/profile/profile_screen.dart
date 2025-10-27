import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../shared/constants/app_dimensions.dart';
import '../../shared/widgets/cards/achievement_card.dart';
import '../../shared/utils/haptic_feedback.dart';
import '../../data/models/models.dart';
import '../../data/providers/user_provider.dart';
import '../../data/providers/achievement_provider.dart';
import 'settings_screen.dart';
import 'widgets/profile_header_content.dart';
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
                padding: const EdgeInsets.only(right: 12.0),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
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
                    borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                    splashColor: AppColors.surface.withValues(alpha: 0.3),
                    highlightColor: AppColors.surface.withValues(alpha: 0.2),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                        border: Border.all(
                          color: AppColors.surface.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.settings_rounded,
                        color: AppColors.surface,
                        size: 22,
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

          // 흰색 배경 시작 영역 - 부드러운 곡선 전환
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: AppDimensions.paddingXL),

                  // 게스트 로그인 안내 (게스트인 경우에만)
                  if (isGuest) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingXL,
                      ),
                      child: const GuestLoginPrompt(),
                    ),
                    const SizedBox(height: AppDimensions.spacingXL),
                  ],

                  // 업적 헤더 섹션
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingXL,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.mathTeal.withValues(alpha: 0.08),
                            AppColors.mathBlue.withValues(alpha: 0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                        border: Border.all(
                          color: AppColors.mathTeal.withValues(alpha: 0.15),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          // 트로피 아이콘
                          Container(
                            padding: const EdgeInsets.all(AppDimensions.paddingM),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.mathYellow,
                                  AppColors.mathOrange,
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.mathYellow.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.emoji_events,
                              color: AppColors.surface,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spacingM),
                          // 텍스트 정보
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '나의 업적',
                                  style: AppTextStyles.titleLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      '${unlockedAchievements.length}개 달성',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.mathTeal,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      ' / 총 ${achievements.length}개',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // 진행률 원형 인디케이터
                          SizedBox(
                            width: 56,
                            height: 56,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: unlockedAchievements.length / achievements.length,
                                  backgroundColor: AppColors.progressBackground,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.mathTeal,
                                  ),
                                  strokeWidth: 5,
                                ),
                                Text(
                                  '${((unlockedAchievements.length / achievements.length) * 100).toInt()}%',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.mathTeal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXL),
                ],
              ),
            ),
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
                    childAspectRatio: 0.75,
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
                    childAspectRatio: 0.75,
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
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        ),
        clipBehavior: Clip.antiAlias,
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 400,
            minHeight: 500,
          ),
          decoration: BoxDecoration(
            gradient: achievement.isUnlocked
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _getAchievementGradient(achievement),
                  )
                : null,
            color: achievement.isUnlocked ? null : AppColors.surface,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 상단 곡선 영역
              Container(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                decoration: BoxDecoration(
                  gradient: achievement.isUnlocked
                      ? null
                      : LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            _getAchievementColor(achievement).withValues(alpha: 0.1),
                            AppColors.surface,
                          ],
                        ),
                ),
                child: Column(
                  children: [
                    // 아이콘 + 애니메이션
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 600),
                      tween: Tween(begin: 0.0, end: 1.0),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: achievement.isUnlocked
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
                                        _getAchievementColor(achievement).withValues(alpha: 0.2),
                                        _getAchievementColor(achievement).withValues(alpha: 0.1),
                                      ],
                                    ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: achievement.isUnlocked
                                      ? AppColors.surface.withValues(alpha: 0.3)
                                      : _getAchievementColor(achievement).withValues(alpha: 0.2),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                achievement.icon,
                                style: TextStyle(
                                  fontSize: 48,
                                  color: achievement.isUnlocked ? null : AppColors.disabled,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // 제목
                    Text(
                      achievement.title,
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: achievement.isUnlocked ? AppColors.surface : AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    // 희귀도 표시
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: achievement.isUnlocked
                            ? AppColors.surface.withValues(alpha: 0.25)
                            : _getAchievementColor(achievement).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: achievement.isUnlocked
                              ? AppColors.surface.withValues(alpha: 0.4)
                              : _getAchievementColor(achievement).withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _getRarityText(achievement.rarity),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: achievement.isUnlocked
                              ? AppColors.surface
                              : _getAchievementColor(achievement),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 하단 정보 영역
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // 설명
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: achievement.isUnlocked
                            ? AppColors.surface.withValues(alpha: 0.15)
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        achievement.description,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: achievement.isUnlocked
                              ? AppColors.surface.withValues(alpha: 0.95)
                              : AppColors.textSecondary,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 진행률 (미달성인 경우에만)
                    if (!achievement.isUnlocked) ...[
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.borderLight,
                            width: 1,
                          ),
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
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Stack(
                                children: [
                                  Container(
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: AppColors.progressBackground,
                                    ),
                                  ),
                                  FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: achievement.progress.clamp(0.0, 1.0),
                                    child: Container(
                                      height: 10,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            _getAchievementColor(achievement),
                                            _getAchievementColor(achievement).withValues(alpha: 0.7),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 보상
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: achievement.isUnlocked
                            ? LinearGradient(
                                colors: [
                                  AppColors.surface.withValues(alpha: 0.25),
                                  AppColors.surface.withValues(alpha: 0.15),
                                ],
                              )
                            : LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.mathYellow.withValues(alpha: 0.15),
                                  AppColors.mathOrange.withValues(alpha: 0.1),
                                ],
                              ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: achievement.isUnlocked
                              ? AppColors.surface.withValues(alpha: 0.3)
                              : AppColors.mathYellow.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.diamond,
                            color: achievement.isUnlocked
                                ? AppColors.surface
                                : AppColors.mathYellow,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '+${achievement.xpReward} XP',
                            style: AppTextStyles.titleLarge.copyWith(
                              color: achievement.isUnlocked
                                  ? AppColors.surface
                                  : AppColors.mathYellow,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 달성 상태
                    if (achievement.isUnlocked) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.surface,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '달성 완료!',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.surface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
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
                            vertical: 16,
                          ),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '닫기',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 희귀도 텍스트 변환
  String _getRarityText(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common:
        return '일반';
      case AchievementRarity.uncommon:
        return '고급';
      case AchievementRarity.rare:
        return '희귀';
      case AchievementRarity.epic:
        return '영웅';
      case AchievementRarity.legendary:
        return '전설';
    }
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
