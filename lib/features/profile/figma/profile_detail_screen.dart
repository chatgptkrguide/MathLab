// Profile Detail Screen — Figma "05" 디자인
// 프로필 카드 + 통계 + 스트릭 + 과목 + 뱃지 + 통계 그리드 + 프리미엄 배너

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers/user/user_provider.dart';
import '../../../data/models/user/user_model.dart';
import '../../../shared/constants/app_colors.dart';
import '../edit_profile_screen.dart';
import '../../settings/settings_screen.dart';

class ProfileDetailScreen extends ConsumerStatefulWidget {
  const ProfileDetailScreen({super.key});

  @override
  ConsumerState<ProfileDetailScreen> createState() =>
      _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends ConsumerState<ProfileDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    if (user == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFFAFAFA),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          // -- Blue Header with Profile Card --
          _buildHeader(context, user),

          // -- Scrollable Content --
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Row
                  _buildStatsRow(user),
                  const SizedBox(height: 16),

                  // Streak Card
                  _buildStreakCard(user),
                  const SizedBox(height: 20),

                  // Subject Cards
                  _buildSubjectSection(),
                  const SizedBox(height: 24),

                  // Badges Section
                  _buildBadgesSection(user),
                  const SizedBox(height: 24),

                  // Statistics Section
                  _buildStatisticsSection(user),
                  const SizedBox(height: 24),

                  // Premium Banner
                  _buildPremiumBanner(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================
  Widget _buildHeader(BuildContext context, UserModel user) {
    final league = user.league.toLowerCase();
    final leagueInitial = league[0].toUpperCase();

    // Level progress calculation
    final thresholds = {
      'bronze': [0, 500],
      'silver': [500, 1100],
      'gold': [1100, 2500],
      'diamond': [2500, 5000],
      'master': [5000, 10000],
    };
    final t = thresholds[league] ?? [0, 500];
    final xpInTier = user.totalXp - t[0];
    final xpNeeded = t[1] - t[0];
    final progress =
        xpNeeded > 0 ? (xpInTier / xpNeeded).clamp(0.0, 1.0) : 1.0;
    final percent = (progress * 100).toInt();

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF61A1D8),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            children: [
              // Top bar: back + title + settings
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        '프로필',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const SettingsScreen()),
                    ),
                    child: const Icon(Icons.settings_outlined,
                        color: Colors.white, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Profile Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE4F5FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: const Color(0xFF2B59FF).withValues(alpha: 0.3),
                      width: 1.5),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Avatar
                        Container(
                          width: 92,
                          height: 92,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDEB67),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: user.photoUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Image.network(
                                    user.photoUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.person_rounded,
                                      size: 48,
                                      color: Color(0xFFE0C84A),
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.person_rounded,
                                  size: 48,
                                  color: Color(0xFFE0C84A),
                                ),
                        ),
                        const SizedBox(width: 16),

                        // Name, username, buttons
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.displayName ?? '사용자',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1A1A1A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user.email != null
                                    ? '@${user.email!.split('@').first}'
                                    : '@guest',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF777777),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10),

                              // Edit Profile + Share buttons
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const EditProfileScreen()),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.06),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Text(
                                        'Edit Profile',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF333333),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.06),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.share_outlined,
                                      size: 18,
                                      color: Color(0xFF555555),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Level badge + progress bar
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF61A1D8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$leagueInitial Lv${user.level}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Stack(
                            children: [
                              // Background track
                              Container(
                                height: 14,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(7),
                                ),
                              ),
                              // Gradient progress
                              FractionallySizedBox(
                                widthFactor: progress,
                                child: Container(
                                  height: 14,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFF48EE),
                                        Color(0xFFFDB232),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$percent%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF555555),
                          ),
                        ),
                      ],
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

  // ============================================================
  // STATS ROW
  // ============================================================
  Widget _buildStatsRow(UserModel user) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F2F1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _buildStatItem('팔로워', _formatNumber(user.longestStreak)),
          Container(width: 1, height: 32, color: const Color(0xFFD9D9D9)),
          _buildStatItem('XP', _formatNumber(user.totalXp)),
          Container(width: 1, height: 32, color: const Color(0xFFD9D9D9)),
          _buildStatItem('팔로잉', user.gems.toString()),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF999999),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STREAK CARD
  // ============================================================
  Widget _buildStreakCard(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE4F5FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          // Fire icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFF9600).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: Color(0xFFFF9600),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '연속 학습 이력',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '수학은 꾸준한 학습이 가장 중요해요!',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Big streak number in circle
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                  color: const Color(0xFFFF9600).withValues(alpha: 0.3),
                  width: 2),
            ),
            child: Center(
              child: Text(
                user.streak.toString().padLeft(2, '0'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFFF9600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUBJECT CARDS
  // ============================================================
  Widget _buildSubjectSection() {
    final subjects = [
      {'name': '대수', 'tasks': 12, 'icon': Icons.functions_rounded},
      {'name': '공통수학 1', 'tasks': 8, 'icon': Icons.calculate_rounded},
      {'name': '공통수학 2', 'tasks': 6, 'icon': Icons.auto_graph_rounded},
    ];

    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: subjects.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final subject = subjects[index];
          return Container(
            width: 120,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F6F6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.skyBlue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    subject['icon'] as IconData,
                    size: 20,
                    color: AppColors.skyBlue,
                  ),
                ),
                const Spacer(),
                Text(
                  subject['name'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF333333),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${subject['tasks']} Task',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // BADGES SECTION
  // ============================================================
  Widget _buildBadgesSection(UserModel user) {
    final badges = [
      {
        'name': '첫번째 챌린지 완성',
        'icon': Icons.emoji_events_rounded,
        'color': const Color(0xFFFFB53E),
      },
      {
        'name': '연속학습 달성',
        'icon': Icons.local_fire_department_rounded,
        'color': const Color(0xFFFF6B35),
      },
      {
        'name': '챌린지 마스터',
        'icon': Icons.workspace_premium_rounded,
        'color': const Color(0xFF7E57C2),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Badges',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: badges.map((badge) {
            final achieved = user.achievements.isNotEmpty;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                    right: badge != badges.last ? 10.0 : 0.0),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: achieved
                            ? (badge['color'] as Color)
                                .withValues(alpha: 0.15)
                            : const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        badge['icon'] as IconData,
                        size: 28,
                        color: achieved
                            ? badge['color'] as Color
                            : const Color(0xFFCCCCCC),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      badge['name'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: achieved
                            ? const Color(0xFF555555)
                            : const Color(0xFFAAAAAA),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ============================================================
  // STATISTICS SECTION
  // ============================================================
  Widget _buildStatisticsSection(UserModel user) {
    final stats = [
      {
        'label': 'Challenges',
        'value': (user.achievements.isNotEmpty ? 235 : 0).toString(),
        'icon': Icons.flag_rounded,
        'color': const Color(0xFFFF6B35),
      },
      {
        'label': 'Lessons Passed',
        'value': (user.level > 1 ? 138 : 0).toString(),
        'icon': Icons.check_circle_rounded,
        'color': const Color(0xFF58CC02),
      },
      {
        'label': 'Total Diamonds',
        'value': _formatNumber(user.gems),
        'icon': Icons.diamond_rounded,
        'color': const Color(0xFF42A5F5),
      },
      {
        'label': 'Total Lifetime',
        'value': _formatNumber(user.totalXp),
        'icon': Icons.bolt_rounded,
        'color': const Color(0xFFFFC800),
      },
      {
        'label': 'Correct Practices',
        'value': '${user.totalXp > 0 ? _formatNumber(user.totalXp ~/ 10) : 0}',
        'icon': Icons.task_alt_rounded,
        'color': const Color(0xFF26A69A),
      },
      {
        'label': 'Top 3 Position',
        'value': '${user.league != 'Bronze' ? 43 : 0}',
        'icon': Icons.leaderboard_rounded,
        'color': const Color(0xFFCE82FF),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Statistics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.7,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final stat = stats[index];
            return Container(
              padding: const EdgeInsets.all(14),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        stat['icon'] as IconData,
                        size: 18,
                        color: stat['color'] as Color,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          stat['label'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    stat['value'] as String,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ============================================================
  // PREMIUM BANNER
  // ============================================================
  Widget _buildPremiumBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFD3E9FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          // Premium icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF2E90FA).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: Color(0xFF2E90FA),
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upgrade to Premium',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF333333),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '광고 없이 모든 기능을 이용하세요',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF777777),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF2E90FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Upgrade',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================
  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(number % 1000 == 0 ? 0 : 1)}k'
          .replaceAll('.0k', 'k');
    }
    return number.toString();
  }
}
