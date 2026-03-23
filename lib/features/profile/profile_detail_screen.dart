// Profile Detail Screen — Figma "05" 디자인
// 프로필 카드 + 통계 + 스트릭 + 과목 + 뱃지 + 통계 그리드 + 프리미엄 배너

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/user/user_provider.dart';
import '../../data/models/user/user_model.dart';
import '../../shared/constants/app_colors.dart';
import 'edit_profile_screen.dart';
import '../settings/settings_screen.dart';
import '../shop/shop_screen.dart';

class ProfileDetailScreen extends ConsumerStatefulWidget {
  /// 코치마크용 GlobalKey
  static final profileCardKey = GlobalKey(debugLabel: 'profileCard');

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
        color: AppColors.skyBlue,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
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
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
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
                key: ProfileDetailScreen.profileCardKey,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.profileBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.nodeActive,
                      width: 1),
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
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: user.photoUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
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
                                  color: Color(0xFF18181B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Opacity(
                                opacity: 0.7,
                                child: Text(
                                  user.email != null
                                      ? '@${user.email!.split('@').first}'
                                      : '@guest',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF18181B),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Edit Profile + Share buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
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
                                          border: Border.all(
                                            color: const Color(0xFF18181B)
                                                .withValues(alpha: 0.12),
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: AppColors.borderDark,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: const Center(
                                          child: Text(
                                            '프로필 편집',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF18181B),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('공유 기능 준비 중'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        border: Border.all(
                                          color: const Color(0xFF18181B)
                                              .withValues(alpha: 0.12),
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: AppColors.borderDark,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.send_outlined,
                                        size: 16,
                                        color: AppColors.textSecondary,
                                      ),
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

                    // Level badge + progress bar (Figma style)
                    Row(
                      children: [
                        // Shield icon
                        Image.asset(
                          'assets/icons/level_icon.png',
                          width: 39,
                          height: 45,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.shield_rounded,
                            color: AppColors.skyBlue,
                            size: 36,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '$leagueInitial Lv${user.level}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF18181B),
                                    ),
                                  ),
                                  Text(
                                    '$percent%',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF18181B),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Container(
                                height: 14,
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: AppColors.cardBg,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withValues(alpha: 0.04),
                                      blurRadius: 24,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: progress,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFFF48EE),
                                          Color(0xFFFDB232),
                                        ],
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
        color: AppColors.chipBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildStatItem('최장 스트릭', '${user.longestStreak}일'),
          Container(width: 1, height: 31, color: AppColors.borderDark),
          _buildStatItem('총 XP', _formatNumber(user.totalXp)),
          Container(width: 1, height: 31, color: AppColors.borderDark),
          _buildStatItem('보유 젬', _formatNumber(user.gems)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
              letterSpacing: 1,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.profileBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Fire icon (streak flame)
          Image.asset(
            'assets/icons/streak_icon.png',
            width: 28,
            height: 28,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.local_fire_department_rounded,
              color: AppColors.mathOrange,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '연속 학습 이력',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF18181B),
                  ),
                ),
                const SizedBox(height: 4),
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
          // Streak number in circular progress ring (60x60)
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 3,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFFE0E0E0).withValues(alpha: 0.5),
                    ),
                  ),
                ),
                // Progress arc
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    value: (user.streak / 30).clamp(0.0, 1.0),
                    strokeWidth: 3,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.premiumBlue,
                    ),
                  ),
                ),
                // Number
                Text(
                  user.streak.toString().padLeft(2, '0'),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF18181B),
                  ),
                ),
              ],
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
      {'name': '대수', 'tasks': 12, 'hasIcon': false},
      {'name': '공통수학 1', 'tasks': 8, 'hasIcon': true},
      {'name': '공통수학 2', 'tasks': 6, 'hasIcon': true},
    ];

    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: subjects.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final subject = subjects[index];
          final hasIcon = subject['hasIcon'] as bool;
          return GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${subject['name']} 과목 보기 준비 중'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Container(
            width: 120,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  subject['name'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF18181B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: index == 0 ? TextAlign.center : TextAlign.left,
                ),
                if (!hasIcon)
                  Text(
                    '${subject['tasks']}개 과제',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.badgeOrange,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                else
                  Image.asset(
                    'assets/icons/subject_icon.png',
                    width: 38,
                    height: 38,
                    errorBuilder: (_, __, ___) => Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.skyBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        size: 20,
                        color: AppColors.skyBlue,
                      ),
                    ),
                  ),
              ],
            ),
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
        'color': AppColors.streakGold,
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
          '보유 뱃지',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF18181B),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: badges.map((badge) {
            final achieved = user.achievements.isNotEmpty;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                    right: badge != badges.last ? 10.0 : 0.0),
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${badge['name']}'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: achieved
                              ? (badge['color'] as Color)
                                  .withValues(alpha: 0.15)
                              : AppColors.cardBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          badge['icon'] as IconData,
                          size: 28,
                          color: achieved
                              ? badge['color'] as Color
                              : AppColors.borderDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        badge['name'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: achieved
                              ? const Color(0xFF18181B)
                              : AppColors.textLight,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
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
        'label': '챌린지 완료',
        'value': user.achievements.length.toString(),
        'icon': Icons.flag_rounded,
        'color': const Color(0xFFFF6B35),
      },
      {
        'label': '완료한 레슨',
        'value': (user.totalXp ~/ 50).toString(),
        'icon': Icons.check_circle_rounded,
        'color': AppColors.mathGreen,
      },
      {
        'label': '보유 다이아',
        'value': _formatNumber(user.gems),
        'icon': Icons.diamond_rounded,
        'color': const Color(0xFF42A5F5),
      },
      {
        'label': '누적 XP',
        'value': _formatNumber(user.totalXp),
        'icon': Icons.bolt_rounded,
        'color': AppColors.mathYellow,
      },
      {
        'label': '정답 수',
        'value': '${user.totalXp > 0 ? _formatNumber(user.totalXp ~/ 10) : 0}',
        'icon': Icons.task_alt_rounded,
        'color': const Color(0xFF26A69A),
      },
      {
        'label': '3위 이내',
        'value': '${user.achievements.where((a) => a == 'top3').length}',
        'icon': Icons.leaderboard_rounded,
        'color': AppColors.mathPurple,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '나의 기록',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 48,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    stat['label'] as String,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stat['value'] as String,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.premiumBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '프리미엄으로 업그레이드',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF18181B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '광고 없이 무제한 학습하세요',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ShopScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.premiumBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '업그레이드',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
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
