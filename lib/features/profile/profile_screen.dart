import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../shared/constants/app_dimensions.dart';
import '../../shared/widgets/layout/responsive_wrapper.dart';
import '../../shared/widgets/animations/fade_in_widget.dart';
import '../../shared/widgets/cards/achievement_card.dart';
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

    // 게스트 사용자 여부 확인
    final isGuest = user?.email == null || user!.email!.isEmpty;

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
                  // 게스트 사용자에게 로그인 프롬프트 표시
                  if (isGuest) ...[
                    _buildLoginPromptCard(),
                    const SizedBox(height: AppDimensions.spacingXL),
                  ],
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
                        color: AppColors.surface,
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
                  color: AppColors.surface,
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
                color: AppColors.surface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              ),
              child: Text(
                user?.currentGrade ?? '중1',
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
                  height: 40,
                  color: AppColors.surface.withValues(alpha: 0.3),
                ),
                _buildTopStat('${user?.xp ?? 0}', 'XP', '🔶'),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.surface.withValues(alpha: 0.3),
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
    return FadeInWidget(
      duration: const Duration(milliseconds: 600),
      delay: const Duration(milliseconds: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
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

  /// 로그인 프롬프트 카드 (게스트 사용자용)
  Widget _buildLoginPromptCard() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.mathBlue,
            AppColors.mathTeal,
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.mathBlue.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 아이콘과 제목
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                ),
                child: const Text(
                  '🔐',
                  style: TextStyle(fontSize: 28),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(
                child: Text(
                  '진행상황을 저장하세요!',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.surface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingM),

          // 설명
          Text(
            '계정에 로그인하면 모든 디바이스에서\n학습 진행상황을 동기화할 수 있어요.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.surface.withValues(alpha: 0.9),
              height: 1.5,
            ),
          ),

          const SizedBox(height: AppDimensions.spacingL),

          // 혜택 리스트
          _buildBenefitItem('✅', '진행상황 동기화 & 백업'),
          const SizedBox(height: AppDimensions.spacingS),
          _buildBenefitItem('🏆', '업적과 리그 순위 저장'),
          const SizedBox(height: AppDimensions.spacingS),
          _buildBenefitItem('📱', '여러 기기에서 사용'),

          const SizedBox(height: AppDimensions.spacingL),

          // 로그인 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _showLoginOptions,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.mathBlue,
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.paddingL,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🔵'),
                  const SizedBox(width: AppDimensions.spacingS),
                  Text(
                    '로그인하기',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.mathBlue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 혜택 항목
  Widget _buildBenefitItem(String icon, String text) {
    return Row(
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(width: AppDimensions.spacingS),
        Text(
          text,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.surface.withValues(alpha: 0.95),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// 로그인 옵션 표시
  Future<void> _showLoginOptions() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppDimensions.radiusXXL),
            topRight: Radius.circular(AppDimensions.radiusXXL),
          ),
        ),
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 핸들 바
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spacingXL),

              // 제목
              Text(
                '로그인 방법 선택',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppDimensions.spacingXL),

              // Google 로그인 버튼
              _buildLoginButton(
                icon: '🔵',
                label: 'Google 계정으로 로그인',
                color: AppColors.mathBlue,
                onPressed: () {
                  Navigator.pop(context);
                  _signInWithGoogle();
                },
              ),

              const SizedBox(height: AppDimensions.spacingM),

              // Kakao 로그인 버튼
              _buildLoginButton(
                icon: '💬',
                label: 'Kakao 계정으로 로그인',
                color: AppColors.mathYellow,
                onPressed: () {
                  Navigator.pop(context);
                  _signInWithKakao();
                },
              ),

              const SizedBox(height: AppDimensions.spacingM),

              // 취소 버튼
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  '취소',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 로그인 버튼
  Widget _buildLoginButton({
    required String icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.1),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.paddingL,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          side: BorderSide(
            color: color.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: AppDimensions.spacingM),
          Text(
            label,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Google 로그인
  Future<void> _signInWithGoogle() async {
    try {
      final authNotifier = ref.read(authProvider.notifier);
      final success = await authNotifier.signInWithGoogle();

      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Google 계정으로 로그인했습니다! 🎉',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.surface,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: AppColors.mathBlue,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Google 로그인에 실패했습니다.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.surface,
              ),
            ),
            backgroundColor: AppColors.mathRed,
          ),
        );
      }
    }
  }

  /// Kakao 로그인
  Future<void> _signInWithKakao() async {
    try {
      final authNotifier = ref.read(authProvider.notifier);
      final success = await authNotifier.signInWithKakao();

      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Kakao 계정으로 로그인했습니다! 🎉',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.surface,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: AppColors.mathYellow,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Kakao 로그인에 실패했습니다.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.surface,
              ),
            ),
            backgroundColor: AppColors.mathRed,
          ),
        );
      }
    }
  }
}
