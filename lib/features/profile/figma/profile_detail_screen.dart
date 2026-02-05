// Profile Detail Screen (Figma "05" Design)
//
// Profile header with follower/following + 6 stat grid (2x3)
// + Premium card + Subject cards + Badge collection + Weekly streak + Logout

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers/auth/auth_provider.dart';
import '../../../data/providers/user/user_provider.dart';
import '../../../data/models/user/user_model.dart';
import '../../../shared/constants/figma_colors.dart';

class ProfileDetailScreen extends ConsumerWidget {
  const ProfileDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
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
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: OutlinedButton.icon(
                      onPressed: () => _handleLogout(context, ref),
                      icon: const Icon(Icons.logout),
                      label: const Text('로그아웃'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
  // Profile Header
  // ──────────────────────────────────────────────

  Widget _buildProfileHeader(BuildContext context, UserModel user) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        bottom: 24,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        gradient: FigmaColors.skyBlueGradient,
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
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  )
                : const Icon(Icons.person_rounded, size: 48, color: Colors.white),
          ),
          const SizedBox(height: 12),

          // Name
          Text(
            user.displayName ?? '사용자',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),

          // Level badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Level ${user.level}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Follower / Following counts
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFollowStat('팔로워', '0'),
              Container(
                width: 1,
                height: 20,
                margin: const EdgeInsets.symmetric(horizontal: 24),
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
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 13,
            fontWeight: FontWeight.w500,
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
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        children: [
          // Row 1: 학습일, XP, 연속학습
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  icon: Icons.calendar_today_rounded,
                  iconColor: FigmaColors.royalBlue,
                  label: '학습일',
                  value: '$studyDays일',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatBox(
                  icon: Icons.bolt_rounded,
                  iconColor: FigmaColors.streakGold,
                  label: 'XP',
                  value: '${user.xp}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatBox(
                  icon: Icons.local_fire_department_rounded,
                  iconColor: FigmaColors.badgeOrange,
                  label: '연속학습',
                  value: '${user.streak}일',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Row 2: 랭크, 문제 수, 포인트
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  icon: Icons.emoji_events_rounded,
                  iconColor: FigmaColors.tealGreen,
                  label: '랭크',
                  value: 'H Lv${user.level}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatBox(
                  icon: Icons.check_circle_rounded,
                  iconColor: FigmaColors.nodeGreen,
                  label: '문제 수',
                  value: '${user.totalXp ~/ 10}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatBox(
                  icon: Icons.diamond_rounded,
                  iconColor: FigmaColors.royalBlue,
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
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: FigmaColors.premiumBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: FigmaColors.premiumBlue.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: FigmaColors.premiumBlue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.workspace_premium_rounded,
                color: FigmaColors.premiumBlue,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: FigmaColors.premiumBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Premium',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '광고 없이 무제한 학습을 시작하세요',
                    style: TextStyle(
                      color: FigmaColors.textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: FigmaColors.premiumBlue,
              size: 24,
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
        color: FigmaColors.royalBlue,
        icon: Icons.functions_rounded,
      ),
      _SubjectCardData(
        name: '공통수학 2',
        subtitle: '기하학 / 통계',
        progress: 0.25,
        completedLessons: 5,
        totalLessons: 20,
        color: FigmaColors.tealGreen,
        icon: Icons.auto_graph_rounded,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '학습 과목',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: FigmaColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          ...subjects.map((subject) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildSubjectCard(subject),
              )),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(_SubjectCardData subject) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: subject.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: FigmaColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subject.subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: FigmaColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: subject.progress,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFF0F0F0),
                    valueColor: AlwaysStoppedAnimation<Color>(subject.color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Progress text
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(subject.progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: subject.color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${subject.completedLessons}/${subject.totalLessons}',
                style: const TextStyle(
                  fontSize: 12,
                  color: FigmaColors.textSecondary,
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            const Text(
              '이번 주 학습',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: FigmaColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                return Column(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: studied[i]
                            ? FigmaColors.nodeGreen
                            : const Color(0xFFF0F0F0),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        studied[i]
                            ? Icons.check_rounded
                            : Icons.remove_rounded,
                        color: studied[i] ? Colors.white : Colors.grey[400],
                        size: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      days[i],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: studied[i]
                            ? FigmaColors.textDark
                            : Colors.grey[400],
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
      _BadgeData('첫 레슨', Icons.star_rounded, FigmaColors.gold, true),
      _BadgeData('3일 연속', Icons.local_fire_department_rounded, FigmaColors.badgeOrange, true),
      _BadgeData('100 XP', Icons.bolt_rounded, FigmaColors.streakGold, true),
      _BadgeData('완벽한 점수', Icons.emoji_events_rounded, FigmaColors.nodeGreen, false),
      _BadgeData('7일 연속', Icons.calendar_month_rounded, FigmaColors.royalBlue, false),
      _BadgeData('산술 마스터', Icons.calculate_rounded, FigmaColors.nodePurple, false),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            const Text(
              '뱃지 컬렉션',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: FigmaColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: badges.map((badge) {
                return Container(
                  decoration: BoxDecoration(
                    color: badge.unlocked
                        ? badge.color.withValues(alpha: 0.1)
                        : const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(16),
                    border: badge.unlocked
                        ? Border.all(color: badge.color.withValues(alpha: 0.3))
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        badge.icon,
                        color: badge.unlocked ? badge.color : Colors.grey[400],
                        size: 32,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        badge.name,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: badge.unlocked
                              ? FigmaColors.textDark
                              : Colors.grey[400],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(authProvider.notifier).signOut();
      // AuthWrapper will automatically show AuthScreen when auth state changes
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
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: FigmaColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: FigmaColors.textSecondary,
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
