/// 👤 Profile Detail Screen (Figma "05" Design)
///
/// 프로필 카드 + 통계 카드 3개 + 연속 학습 이력 + 과목별 진행률 + 뱃지 컬렉션

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
                // 상단 프로필 헤더
                SliverToBoxAdapter(child: _buildProfileHeader(context, user)),

                // 통계 카드 3개
                SliverToBoxAdapter(child: _buildStatsRow(user)),

                // 연속 학습 이력 그래프
                SliverToBoxAdapter(child: _buildStreakHistory()),

                // 과목별 진행률
                SliverToBoxAdapter(child: _buildSubjectProgress()),

                // 뱃지 컬렉션
                SliverToBoxAdapter(child: _buildBadgeCollection()),

                // 로그아웃
                if (!user.isGuest)
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
          // 아바타
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
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
          // 이름
          Text(
            user.displayName ?? '사용자',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          // 레벨
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
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
        ],
      ),
    );
  }

  Widget _buildStatsRow(UserModel user) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        children: [
          Expanded(
            child: _StatBox(
              icon: Icons.bolt_rounded,
              iconColor: const Color(0xFFFFC800),
              label: 'XP',
              value: '${user.xp}',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatBox(
              icon: Icons.check_circle_rounded,
              iconColor: FigmaColors.nodeGreen,
              label: '총 XP',
              value: '${user.totalXp}',
            ),
          ),
          const SizedBox(width: 12),
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
    );
  }

  Widget _buildStreakHistory() {
    // 최근 7일 학습 이력 (샘플 데이터)
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
              color: Colors.black.withOpacity(0.04),
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
                color: Color(0xFF3C3C3C),
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
                        color: studied[i]
                            ? Colors.white
                            : Colors.grey[400],
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
                            ? const Color(0xFF3C3C3C)
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

  Widget _buildSubjectProgress() {
    final subjects = [
      _SubjectData('기초 산술', 0.85, FigmaColors.royalBlue),
      _SubjectData('분수와 소수', 0.40, FigmaColors.tealGreen),
      _SubjectData('방정식', 0.15, FigmaColors.nodeOrange),
      _SubjectData('기하학', 0.0, FigmaColors.nodePurple),
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
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '과목별 진행률',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3C3C3C),
              ),
            ),
            const SizedBox(height: 16),
            ...subjects.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            s.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3C3C3C),
                            ),
                          ),
                          Text(
                            '${(s.progress * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: s.color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: s.progress,
                          minHeight: 8,
                          backgroundColor: const Color(0xFFF0F0F0),
                          valueColor: AlwaysStoppedAnimation<Color>(s.color),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeCollection() {
    final badges = [
      _BadgeData('첫 레슨', Icons.star_rounded, FigmaColors.gold, true),
      _BadgeData('3일 연속', Icons.local_fire_department_rounded, const Color(0xFFFF6B35), true),
      _BadgeData('100 XP', Icons.bolt_rounded, const Color(0xFFFFC800), true),
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
              color: Colors.black.withOpacity(0.04),
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
                color: Color(0xFF3C3C3C),
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
                        ? badge.color.withOpacity(0.1)
                        : const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(16),
                    border: badge.unlocked
                        ? Border.all(color: badge.color.withOpacity(0.3))
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
                              ? const Color(0xFF3C3C3C)
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
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/auth');
      }
    }
  }
}

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
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3C3C3C),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

class _SubjectData {
  final String name;
  final double progress;
  final Color color;
  _SubjectData(this.name, this.progress, this.color);
}

class _BadgeData {
  final String name;
  final IconData icon;
  final Color color;
  final bool unlocked;
  _BadgeData(this.name, this.icon, this.color, this.unlocked);
}
