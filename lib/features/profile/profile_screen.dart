import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../shared/constants/app_dimensions.dart';
import '../../shared/widgets/widgets.dart';
import '../../data/models/models.dart';
import '../../data/providers/user_provider.dart';
import '../../data/providers/achievement_provider.dart';
import '../../data/providers/learning_stats_provider.dart';

/// 프로필 화면 - Riverpod 버전
/// 실제 스크린샷과 동일한 레이아웃으로 구현
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final achievements = ref.watch(achievementProvider);
    final stats = ref.watch(learningStatsProvider);

    if (user == null || stats == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildUserProfileCard(context, ref, user),
              const SizedBox(height: AppDimensions.spacingL),
              _buildLearningStatsCard(stats),
              const SizedBox(height: AppDimensions.spacingL),
              _buildAchievementsCard(context, achievements),
              const SizedBox(height: AppDimensions.spacingXXL),
            ],
          ),
        ),
      ),
    );
  }

  /// 사용자 프로필 카드
  Widget _buildUserProfileCard(BuildContext context, WidgetRef ref, User user) {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingL),
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: AppDimensions.cardElevation * 2,
            offset: const Offset(0, AppDimensions.cardElevation),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 4,
                child: Row(
                  children: [
                    _buildAvatar(user),
                    const SizedBox(width: AppDimensions.spacingM),
                    Flexible(child: _buildUserInfo(user)),
                  ],
                ),
              ),
              Flexible(
                flex: 1,
                child: IconButton(
                  onPressed: () => _showSettings(context, ref),
                  icon: const Icon(
                    Icons.settings,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingL),
          _buildQuickStats(user),
        ],
      ),
    );
  }

  /// 사용자 아바타
  Widget _buildAvatar(User user) {
    return CircleAvatar(
      radius: AppDimensions.avatarL / 2,
      backgroundColor: AppColors.primaryBlue,
      child: Text(
        user.name.isNotEmpty ? user.name[0] : '학',
        style: AppTextStyles.headlineMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 사용자 정보
  Widget _buildUserInfo(User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          user.name,
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppDimensions.spacingXS),
        Text(
          '${user.joinDate.year}. ${user.joinDate.month}. ${user.joinDate.day}.부터 학습 중',
          style: AppTextStyles.bodySmall,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// 빠른 통계
  Widget _buildQuickStats(User user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildQuickStat('🏆', '레벨 ${user.level}'),
        _buildQuickStat('🔥', '${user.streakDays}일 연속'),
        _buildQuickStat('⭐', '${user.xp} XP'),
      ],
    );
  }

  /// 빠른 통계 위젯
  Widget _buildQuickStat(String icon, String text) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: AppTextStyles.emojiSmall),
          const SizedBox(width: AppDimensions.spacingXS),
          Flexible(
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// 학습 통계 카드
  Widget _buildLearningStatsCard(LearningStats stats) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: AppDimensions.cardElevation * 2,
            offset: const Offset(0, AppDimensions.cardElevation),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '학습 통계',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingL),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                child: _buildMainStat(
                  value: stats.totalXP.toString(),
                  label: '총 XP',
                ),
              ),
              Flexible(
                child: _buildMainStat(
                  value: stats.completedEpisodes.toString(),
                  label: '완료한 에피소드',
                ),
              ),
              Flexible(
                child: _buildMainStat(
                  value: stats.maxStreak.toString(),
                  label: '최고 연속',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 주요 통계 위젯
  Widget _buildMainStat({
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.statValue,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppDimensions.spacingXS),
        Text(
          label,
          style: AppTextStyles.statLabel,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// 업적 카드
  Widget _buildAchievementsCard(BuildContext context, List<Achievement> achievements) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: AppDimensions.cardElevation * 2,
            offset: const Offset(0, AppDimensions.cardElevation),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '업적',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingL),
          _buildAchievementGrid(context, achievements),
        ],
      ),
    );
  }

  /// 업적 그리드
  Widget _buildAchievementGrid(BuildContext context, List<Achievement> achievements) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppDimensions.spacingS,
        mainAxisSpacing: AppDimensions.spacingS,
        childAspectRatio: 1,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return AchievementCard(
          icon: achievement.icon,
          title: achievement.title,
          isUnlocked: achievement.isUnlocked,
          onTap: () => _showAchievementDetails(context, achievement),
        );
      },
    );
  }

  // 이벤트 핸들러들

  void _showSettings(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusL),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppDimensions.spacingL),
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              '설정',
              style: AppTextStyles.titleLarge,
            ),
            const SizedBox(height: AppDimensions.spacingL),
            _buildSettingsItem(
              context: context,
              icon: Icons.person_outline,
              title: '프로필 편집',
              onTap: () => _editProfile(context, ref),
            ),
            _buildSettingsItem(
              context: context,
              icon: Icons.refresh,
              title: '데이터 초기화',
              onTap: () => _resetData(context, ref),
            ),
            _buildSettingsItem(
              context: context,
              icon: Icons.info_outline,
              title: '앱 정보',
              onTap: () => _showAppInfo(context),
            ),
            const SizedBox(height: AppDimensions.spacingL),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _showAchievementDetails(BuildContext context, Achievement achievement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(
              achievement.icon,
              style: AppTextStyles.emojiLarge,
            ),
            const SizedBox(width: AppDimensions.spacingS),
            Expanded(
              child: Text(
                achievement.title,
                style: AppTextStyles.titleLarge,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(achievement.description),
            const SizedBox(height: AppDimensions.spacingM),
            if (achievement.isUnlocked) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingM,
                  vertical: AppDimensions.paddingS,
                ),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: Text(
                  '✅ 달성 완료!',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.successGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ] else ...[
              Text(
                '진행률: ${achievement.progressText}',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: AppDimensions.spacingS),
              LinearProgressIndicator(
                value: achievement.progress,
                backgroundColor: AppColors.progressBackground,
                valueColor: const AlwaysStoppedAnimation(AppColors.progressActive),
              ),
            ],
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              '보상: ${achievement.xpReward} XP',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _editProfile(BuildContext context, WidgetRef ref) {
    final user = ref.read(userProvider);
    if (user == null) return;

    final nameController = TextEditingController(text: user.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('프로필 편집'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '이름',
                hintText: '학습자 이름을 입력하세요',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                ref.read(userProvider.notifier).updateUserName(newName);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('프로필이 업데이트되었습니다!')),
                );
              }
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  void _resetData(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('데이터 초기화'),
        content: const Text(
          '모든 학습 데이터를 초기화하시겠습니까?\n'
          '이 작업은 되돌릴 수 없습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              // 모든 데이터 초기화
              await ref.read(userProvider.notifier).resetUser();
              await ref.read(achievementProvider.notifier).resetAchievements();
              await ref.read(learningStatsProvider.notifier).resetStats();

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('모든 데이터가 초기화되었습니다.')),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.errorRed,
            ),
            child: const Text('초기화'),
          ),
        ],
      ),
    );
  }

  void _showAppInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('앱 정보'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('MathLab', style: AppTextStyles.titleLarge),
            const SizedBox(height: AppDimensions.spacingS),
            Text('버전: 1.0.0', style: AppTextStyles.bodyMedium),
            Text('© 2025 Gomath', style: AppTextStyles.bodySmall),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              '게이미피케이션을 통한 수학 학습 앱',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              '✨ 완전한 기능을 갖춘 Flutter 앱',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}