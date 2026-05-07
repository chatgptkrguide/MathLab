// TODO: 위젯 분리 필요 - ProfileCard, StreakCard, SubjectSection, BadgesSection, StatisticsSection
// Profile Detail Screen — Figma "05" 디자인
// 프로필 카드 + 통계 + 스트릭 + 과목 + 뱃지 + 통계 그리드 + 프리미엄 배너

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/user/user_provider.dart';
import '../../data/providers/lesson/lesson_progress_provider.dart';
import '../../data/models/user/user_model.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/grade_curriculum_map.dart';
import '../../data/providers/infrastructure/navigation_provider.dart';
import 'edit_profile_screen.dart';
import '../settings/settings_screen.dart';
import '../shop/shop_screen.dart';

class ProfileDetailScreen extends ConsumerStatefulWidget {
  /// 코치마크용 GlobalKey
  static final profileCardKey = GlobalKey(debugLabel: 'profileCard');
  static final badgesSectionKey = GlobalKey(debugLabel: 'badgesSection');
  static final statsSectionKey = GlobalKey(debugLabel: 'statsSection');

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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHeader(context, user),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsRow(user),
                  const SizedBox(height: 16),
                  _buildStreakCard(user),
                  const SizedBox(height: 20),
                  _buildSubjectSection(),
                  const SizedBox(height: 24),
                  _buildBadgesSection(user),
                  const SizedBox(height: 24),
                  _buildStatisticsSection(user),
                  const SizedBox(height: 24),
                  _buildPremiumBanner(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================
  Widget _buildHeader(BuildContext context, UserModel user) {
    final league = user.league.toLowerCase();

    // League display info
    final leagueInfo = _getLeagueInfo(league);

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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.skyBlue,
            AppColors.skyBlue.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
          child: Column(
            children: [
              // Top bar
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
                          letterSpacing: 0.5,
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
              const SizedBox(height: 12),

              // Avatar + Name row
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const EditProfileScreen()),
                ),
                child: Row(
                  key: ProfileDetailScreen.profileCardKey,
                  children: [
                    // Avatar with level badge
                    SizedBox(
                      width: 68,
                      height: 68,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.6),
                                width: 2.5,
                              ),
                            ),
                            child: user.photoUrl != null
                                ? ClipOval(
                                    child: Image.network(
                                      user.photoUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          CircleAvatar(
                                        backgroundColor: Colors.white
                                            .withValues(alpha: 0.2),
                                        child: const Icon(
                                          Icons.person_rounded,
                                          size: 32,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                                : CircleAvatar(
                                    backgroundColor:
                                        Colors.white.withValues(alpha: 0.2),
                                    child: const Icon(
                                      Icons.person_rounded,
                                      size: 32,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                          // Level badge
                          Positioned(
                            bottom: -4,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: leagueInfo.color,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: Colors.white, width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: leagueInfo.color
                                          .withValues(alpha: 0.4),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  'Lv.${user.level}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Name + username
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.displayName ?? '사용자',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            user.email != null
                                ? '@${user.email!.split('@').first}'
                                : '@guest',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Edit icon (subtle)
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.edit_rounded,
                        size: 16,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Level progress card
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      left: BorderSide(
                        color: leagueInfo.color,
                        width: 3.5,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // League + Level info row
                      Row(
                        children: [
                          // League icon
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: leagueInfo.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: leagueInfo.color.withValues(alpha: 0.5),
                                width: 1.5,
                              ),
                            ),
                            child: Image.asset(
                              'assets/icons/level_icon.png',
                              width: 32,
                              height: 32,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.shield_rounded,
                                color: leagueInfo.color,
                                size: 26,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  leagueInfo.name,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: leagueInfo.color,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: leagueInfo.color
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Lv.${user.level}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: leagueInfo.color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // XP display
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatNumber(user.totalXp),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const Text(
                                'XP',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // XP progress labels (above bar)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatNumber(xpInTier),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: leagueInfo.color,
                              ),
                            ),
                            Text(
                              '${_formatNumber(xpNeeded)} XP',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Progress bar with percentage
                      SizedBox(
                        height: 26,
                        child: Stack(
                          children: [
                            Container(
                              height: 26,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5E5E5),
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 800),
                                    curve: Curves.easeOutCubic,
                                    width: constraints.maxWidth * progress,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          leagueInfo.color,
                                          leagueInfo.gradientEnd,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(11),
                                      boxShadow: [
                                        BoxShadow(
                                          color: leagueInfo.color
                                              .withValues(alpha: 0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            // Percentage text centered on bar
                            Positioned.fill(
                              child: Center(
                                child: Text(
                                  '${(progress * 100).toInt()}%',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: progress > 0.4 ? Colors.white : AppColors.textSecondary,
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
            ],
          ),
        ),
      ),
    );
  }

  _LeagueDisplayInfo _getLeagueInfo(String league) {
    switch (league) {
      case 'silver':
        return _LeagueDisplayInfo(
          name: '실버',
          color: const Color(0xFF78909C),
          gradientEnd: const Color(0xFFB0BEC5),
        );
      case 'gold':
        return _LeagueDisplayInfo(
          name: '골드',
          color: const Color(0xFFFF9800),
          gradientEnd: const Color(0xFFFFB74D),
        );
      case 'diamond':
        return _LeagueDisplayInfo(
          name: '다이아몬드',
          color: const Color(0xFF42A5F5),
          gradientEnd: const Color(0xFF90CAF9),
        );
      case 'master':
        return _LeagueDisplayInfo(
          name: '마스터',
          color: const Color(0xFF7E57C2),
          gradientEnd: const Color(0xFFB39DDB),
        );
      default: // bronze
        return _LeagueDisplayInfo(
          name: '브론즈',
          color: const Color(0xFFCD7F32),
          gradientEnd: const Color(0xFFDEA05E),
        );
    }
  }

  // ============================================================
  // STATS ROW — game-style with icons
  // ============================================================
  Widget _buildStatsRow(UserModel user) {
    return Row(
      children: [
        _buildStatChip(
          icon: Icons.local_fire_department_rounded,
          iconColor: const Color(0xFFFF6B35),
          bgColor: const Color(0xFFFFF3ED),
          label: '최장 스트릭',
          value: '${user.longestStreak}일',
        ),
        const SizedBox(width: 10),
        _buildStatChip(
          icon: Icons.bolt_rounded,
          iconColor: const Color(0xFFFFB300),
          bgColor: const Color(0xFFFFF8E1),
          label: '총 XP',
          value: _formatNumber(user.totalXp),
        ),
        const SizedBox(width: 10),
        _buildStatChip(
          icon: Icons.diamond_rounded,
          iconColor: const Color(0xFF42A5F5),
          bgColor: const Color(0xFFE3F2FD),
          label: '보유 젬',
          value: _formatNumber(user.gems),
        ),
      ],
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: iconColor.withValues(alpha: 0.2), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: iconColor.withValues(alpha: 0.9),
                letterSpacing: 0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // STREAK CARD — game-style with daily dots
  // ============================================================
  Widget _buildStreakCard(UserModel user) {
    final streakDays = user.streak;
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final today = DateTime.now().weekday; // 1=Mon, 7=Sun

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFF8F0),
            const Color(0xFFFFF3E8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFD9B3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Top: streak count + flame
          Row(
            children: [
              // Big flame + number
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFF8A50), Color(0xFFFF6D00)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6D00).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    streakDays.toString(),
                    style: TextStyle(
                      fontSize: streakDays >= 100 ? 18 : 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          '🔥 연속 학습',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF18181B),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6D00).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$streakDays일째',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFE65100),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      streakDays == 0
                          ? '오늘 학습하고 스트릭을 시작하세요!'
                          : '꾸준히 하고 있어요! 계속 달려보세요 💪',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Week progress dots
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (i) {
              final dayIndex = i + 1; // 1=Mon
              final isToday = dayIndex == today;
              // Show as completed if within streak range
              final isCompleted = dayIndex <= today && (today - dayIndex) < streakDays;
              return Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? const Color(0xFFFF6D00)
                          : isToday
                              ? const Color(0xFFFF6D00).withValues(alpha: 0.15)
                              : const Color(0xFFE0E0E0).withValues(alpha: 0.5),
                      border: isToday && !isCompleted
                          ? Border.all(color: const Color(0xFFFF6D00), width: 2)
                          : null,
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    weekdays[i],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                      color: isToday ? const Color(0xFFE65100) : AppColors.textSecondary,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUBJECT CARDS
  // ============================================================
  Widget _buildSubjectSection() {
    final user = ref.watch(userProvider);
    final grade = user?.currentGrade ?? '중1';
    final gradeSubjects = GradeCurriculumMap.getSubjectsForGrade(grade);
    final displaySubjects = gradeSubjects.isEmpty
        ? ['공통수학1', '공통수학2', '수학I']
        : gradeSubjects;
    final subjects = displaySubjects.map((name) => {'name': name}).toList();

    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: subjects.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final subject = subjects[index];
          final name = subject['name'] ?? '과목';
          return GestureDetector(
            onTap: () => ref.read(navigationProvider.notifier).goToLessons(),
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
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF18181B),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Container(
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
      key: ProfileDetailScreen.badgesSectionKey,
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
                              ? ((badge['color'] as Color?) ?? AppColors.mathBlue)
                                  .withValues(alpha: 0.15)
                              : AppColors.cardBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          (badge['icon'] as IconData?) ?? Icons.star_rounded,
                          size: 28,
                          color: achieved
                              ? (badge['color'] as Color?) ?? AppColors.mathBlue
                              : AppColors.borderDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        (badge['name'] as String?) ?? '',
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
    final progressState = ref.watch(lessonProgressProvider(user.uid));
    final completedLessons = progressState.completedCount;
    final earnedStars = progressState.totalStars;

    final stats = [
      {
        'label': '챌린지 완료',
        'value': user.achievements.length.toString(),
        'icon': Icons.flag_rounded,
        'color': const Color(0xFFFF6B35),
      },
      {
        'label': '완료한 레슨',
        'value': completedLessons.toString(),
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
        'label': '획득 별',
        'value': earnedStars.toString(),
        'icon': Icons.star_rounded,
        'color': const Color(0xFFFFB300),
      },
      {
        'label': '최장 연속',
        'value': '${user.longestStreak}일',
        'icon': Icons.local_fire_department_rounded,
        'color': const Color(0xFFFF7043),
      },
    ];

    return Column(
      key: ProfileDetailScreen.statsSectionKey,
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
            final statColor = (stat['color'] as Color?) ?? AppColors.mathBlue;
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: statColor.withValues(alpha: 0.12),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: statColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      (stat['icon'] as IconData?) ?? Icons.star_rounded,
                      color: statColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          (stat['value'] as String?) ?? '0',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1),
                        Text(
                          (stat['label'] as String?) ?? '',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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

class _LeagueDisplayInfo {
  final String name;
  final Color color;
  final Color gradientEnd;

  const _LeagueDisplayInfo({
    required this.name,
    required this.color,
    required this.gradientEnd,
  });
}
