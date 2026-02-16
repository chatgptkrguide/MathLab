// Profile Detail Screen (Figma "05" Design)
//
// Profile header with follower/following + 6 stat grid (2x3)
// + Premium card + Subject cards + Badge collection + Weekly streak + Logout

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers/auth/auth_provider.dart';
import '../../../data/providers/user/user_provider.dart';
import '../../../data/models/user/user_model.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_dimensions.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../edit_profile_screen.dart';

class ProfileDetailScreen extends ConsumerWidget {
  const ProfileDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // Profile header with avatar, name, level, follower/following
                SliverToBoxAdapter(child: _buildProfileHeader(context, user)),

                // 6 stat boxes in 2 rows of 3
                SliverToBoxAdapter(child: _buildStatsGrid(user)),

                // Premium card
                SliverToBoxAdapter(child: _buildPremiumCard()),

                // Subject cards
                SliverToBoxAdapter(child: _buildSubjectCards()),

                // Weekly streak history
                SliverToBoxAdapter(child: _buildStreakHistory()),

                // Badge collection
                SliverToBoxAdapter(child: _buildBadgeCollection()),

                // Logout
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacing24,
                      vertical: AppDimensions.spacing16,
                    ),
                    child: OutlinedButton.icon(
                      onPressed: () => _handleLogout(context, ref),
                      icon: const Icon(Icons.logout),
                      label: const Text('로그아웃'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.spacing12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radius12),
                        ),
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
    );
  }

  // ──────────────────────────────────────────────
  // Section Header
  // ──────────────────────────────────────────────

  Widget _buildSectionHeader(String title, {String? actionText, VoidCallback? onAction}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.titleLarge.copyWith(
            fontSize: 18,
            color: AppColors.textDark,
          ),
        ),
        if (actionText != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionText,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.royalBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  // ──────────────────────────────────────────────
  // Profile Header
  // ──────────────────────────────────────────────

  Widget _buildProfileHeader(BuildContext context, UserModel user) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppDimensions.spacing20,
        bottom: AppDimensions.spacing24,
        left: AppDimensions.spacing24,
        right: AppDimensions.spacing24,
      ),
      decoration: const BoxDecoration(
        gradient: AppColors.skyBlueGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: user.photoUrl != null
                ? ClipOval(
                    child: Image.network(
                      user.photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.person_rounded,
                        size: AppDimensions.iconXLarge,
                        color: Colors.white,
                      ),
                    ),
                  )
                : const Icon(Icons.person_rounded, size: AppDimensions.iconXLarge, color: Colors.white),
          ),
          const SizedBox(height: AppDimensions.spacing12),

          // Name
          Text(
            user.displayName ?? '사용자',
            style: AppTextStyles.titleLarge.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing4),

          // Level badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: AppDimensions.spacing4,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppDimensions.radius12),
            ),
            child: Text(
              'Level ${user.level}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacing12),

          // Edit Profile button
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing20,
                vertical: AppDimensions.spacing8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radius20),
              ),
              child: Text(
                'Edit Profile',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.royalBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacing16),

          // Follower / Following counts
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFollowStat('팔로워', '0'),
              Container(
                width: 1,
                height: 20,
                margin: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacing24,
                ),
                color: Colors.white.withValues(alpha: 0.4),
              ),
              _buildFollowStat('팔로잉', '0'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFollowStat(String label, String count) {
    return Column(
      children: [
        Text(
          count,
          style: AppTextStyles.titleLarge.copyWith(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: AppDimensions.spacing2),
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────
  // 6 Stats Grid (2 rows x 3 columns)
  // ──────────────────────────────────────────────

  Widget _buildStatsGrid(UserModel user) {
    // Calculate study days from createdAt
    final studyDays = DateTime.now().difference(user.createdAt).inDays + 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacing24,
        AppDimensions.spacing20,
        AppDimensions.spacing24,
        0,
      ),
      child: Column(
        children: [
          // Row 1
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  icon: Icons.calendar_today_rounded,
                  iconColor: AppColors.royalBlue,
                  label: '학습일',
                  value: '$studyDays일',
                ),
              ),
              const SizedBox(width: AppDimensions.spacing12),
              Expanded(
                child: _StatBox(
                  icon: Icons.bolt_rounded,
                  iconColor: AppColors.streakGold,
                  label: 'XP',
                  value: '${user.xp}',
                ),
              ),
              const SizedBox(width: AppDimensions.spacing12),
              Expanded(
                child: _StatBox(
                  icon: Icons.local_fire_department_rounded,
                  iconColor: AppColors.badgeOrange,
                  label: '연속학습',
                  value: '${user.streak}일',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing12),
          // Row 2
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  icon: Icons.emoji_events_rounded,
                  iconColor: AppColors.tealGreen,
                  label: '랭크',
                  value: 'H Lv${user.level}',
                ),
              ),
              const SizedBox(width: AppDimensions.spacing12),
              Expanded(
                child: _StatBox(
                  icon: Icons.check_circle_rounded,
                  iconColor: AppColors.nodeGreen,
                  label: '문제 수',
                  value: '${user.totalXp ~/ 10}',
                ),
              ),
              const SizedBox(width: AppDimensions.spacing12),
              Expanded(
                child: _StatBox(
                  icon: Icons.diamond_rounded,
                  iconColor: AppColors.royalBlue,
                  label: '포인트',
                  value: '${user.gems}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Premium Card
  // ──────────────────────────────────────────────

  Widget _buildPremiumCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacing24,
        AppDimensions.spacing24,
        AppDimensions.spacing24,
        0,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spacing20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4A7CF7), Color(0xFF9B59B6)],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radius16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4A7CF7).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Crown icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppDimensions.radius16),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: AppDimensions.spacing16),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(AppDimensions.radius8),
                    ),
                    child: Text(
                      'Premium',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing8),
                  Text(
                    '광고 없이 무제한 학습을 시작하세요',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacing16,
                      vertical: AppDimensions.spacing8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppDimensions.radius20),
                    ),
                    child: Text(
                      '자세히 보기',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: const Color(0xFF4A7CF7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Subject Cards
  // ──────────────────────────────────────────────

  Widget _buildSubjectCards() {
    final subjects = [
      _SubjectCardData(
        name: '공통수학 1',
        subtitle: '기초 산술 / 대수',
        progress: 0.65,
        completedLessons: 13,
        totalLessons: 20,
        color: AppColors.royalBlue,
        icon: Icons.functions_rounded,
      ),
      _SubjectCardData(
        name: '공통수학 2',
        subtitle: '기하학 / 통계',
        progress: 0.25,
        completedLessons: 5,
        totalLessons: 20,
        color: AppColors.tealGreen,
        icon: Icons.auto_graph_rounded,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacing24,
        AppDimensions.spacing24,
        AppDimensions.spacing24,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('학습 과목', actionText: '더보기 >'),
          const SizedBox(height: AppDimensions.spacing16),
          ...subjects.map((subject) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.spacing12),
                child: _buildSubjectCard(subject),
              )),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(_SubjectCardData subject) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Subject icon
          Container(
            width: AppDimensions.iconXLarge,
            height: AppDimensions.iconXLarge,
            decoration: BoxDecoration(
              color: subject.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radius12),
            ),
            child: Icon(
              subject.icon,
              color: subject.color,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.name,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing2),
                Text(
                  subject.subtitle,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing8),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radius4),
                  child: LinearProgressIndicator(
                    value: subject.progress,
                    minHeight: 6,
                    backgroundColor: AppColors.cardBg,
                    valueColor: AlwaysStoppedAnimation<Color>(subject.color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.spacing12),
          // Progress text
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(subject.progress * 100).toInt()}%',
                style: AppTextStyles.titleMedium.copyWith(
                  color: subject.color,
                ),
              ),
              const SizedBox(height: AppDimensions.spacing2),
              Text(
                '${subject.completedLessons}/${subject.totalLessons}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Weekly Streak History
  // ──────────────────────────────────────────────

  Widget _buildStreakHistory() {
    final days = ['월', '화', '수', '목', '금', '토', '일'];
    final studied = [true, true, true, false, true, true, false];
    // Assume today is the 6th day (Saturday, index 5) for demo
    const todayIndex = 5;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacing24,
        AppDimensions.spacing24,
        AppDimensions.spacing24,
        0,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spacing20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radius16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('이번 주 학습'),
            const SizedBox(height: AppDimensions.spacing16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                final isCompleted = studied[i];
                final isToday = i == todayIndex;
                final isFuture = i > todayIndex;

                return Column(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: isCompleted
                            ? const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [AppColors.nodeGreen, AppColors.mathGreenDark],
                              )
                            : null,
                        color: isCompleted
                            ? null
                            : isFuture
                                ? AppColors.cardBg
                                : AppColors.cardBg,
                        shape: BoxShape.circle,
                        border: isToday && !isCompleted
                            ? Border.all(color: AppColors.nodeGreen, width: 2.5)
                            : null,
                      ),
                      child: Icon(
                        isCompleted
                            ? Icons.check_rounded
                            : isFuture
                                ? Icons.remove_rounded
                                : Icons.close_rounded,
                        color: isCompleted
                            ? Colors.white
                            : isFuture
                                ? AppColors.textLight
                                : AppColors.textLight,
                        size: 18,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacing8),
                    Text(
                      days[i],
                      style: AppTextStyles.labelSmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isCompleted
                            ? AppColors.textDark
                            : isToday
                                ? AppColors.nodeGreen
                                : AppColors.textLight,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Badge Collection
  // ──────────────────────────────────────────────

  Widget _buildBadgeCollection() {
    final badges = [
      _BadgeData('첫 레슨', Icons.star_rounded, AppColors.gold, true),
      _BadgeData('3일 연속', Icons.local_fire_department_rounded, AppColors.badgeOrange, true),
      _BadgeData('100 XP', Icons.bolt_rounded, AppColors.streakGold, true),
      _BadgeData('완벽한 점수', Icons.emoji_events_rounded, AppColors.nodeGreen, false),
      _BadgeData('7일 연속', Icons.calendar_month_rounded, AppColors.royalBlue, false),
      _BadgeData('산술 마스터', Icons.calculate_rounded, AppColors.nodePurple, false),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacing24,
        AppDimensions.spacing24,
        AppDimensions.spacing24,
        0,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spacing20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radius16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('뱃지 컬렉션', actionText: '더보기 >'),
            const SizedBox(height: AppDimensions.spacing16),
            GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: AppDimensions.spacing12,
              mainAxisSpacing: AppDimensions.spacing12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: badges.map((badge) {
                return badge.unlocked
                    ? _buildUnlockedBadge(badge)
                    : _buildLockedBadge(badge);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnlockedBadge(_BadgeData badge) {
    return Container(
      decoration: BoxDecoration(
        color: badge.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
        border: Border.all(
          color: badge.color.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: badge.color.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            badge.icon,
            color: badge.color,
            size: AppDimensions.iconLarge,
          ),
          const SizedBox(height: AppDimensions.spacing4),
          Text(
            badge.name,
            style: AppTextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLockedBadge(_BadgeData badge) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                badge.icon,
                color: AppColors.textLight,
                size: AppDimensions.iconLarge,
              ),
              const SizedBox(height: AppDimensions.spacing4),
              Text(
                badge.name,
                style: AppTextStyles.labelSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          // Lock overlay
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.nodeLocked,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_rounded,
                color: Colors.white,
                size: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Logout
  // ──────────────────────────────────────────────

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃하시겠습니까?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(authProvider.notifier).signOut();
    }
  }
}

// ──────────────────────────────────────────────
// Private Widget: Stat Box
// ──────────────────────────────────────────────

class _StatBox extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatBox({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.spacing16,
        horizontal: AppDimensions.spacing8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radius12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radius12),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: AppDimensions.spacing8),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing2),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Data Classes
// ──────────────────────────────────────────────

class _SubjectCardData {
  final String name;
  final String subtitle;
  final double progress;
  final int completedLessons;
  final int totalLessons;
  final Color color;
  final IconData icon;

  _SubjectCardData({
    required this.name,
    required this.subtitle,
    required this.progress,
    required this.completedLessons,
    required this.totalLessons,
    required this.color,
    required this.icon,
  });
}

class _BadgeData {
  final String name;
  final IconData icon;
  final Color color;
  final bool unlocked;
  _BadgeData(this.name, this.icon, this.color, this.unlocked);
}
