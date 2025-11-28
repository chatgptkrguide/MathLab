import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/user_provider.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../shared/widgets/layout/adaptive_app_header.dart';
import '../../practice/practice_screen.dart';
import '../../level_test/level_test_screen.dart';
import '../../achievements/achievements_screen.dart';
import '../../daily_challenge/daily_challenge_screen.dart';
import '../../settings/settings_screen.dart';
import '../../academic_records/academic_records_screen.dart';
import '../../course_enrollment/course_enrollment_screen.dart';
import '../../league_tier/league_tier_screen.dart';
import '../../friends/friends_screen.dart';

/// Figma 디자인 "05" 프로필 상세 페이지 - 완전 재구성 버전
/// Figma Page 05 구조와 100% 일치하도록 구현
class ProfileDetailScreenV3New extends ConsumerWidget {
  const ProfileDetailScreenV3New({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // 통합 헤더 (홈 화면과 동일한 디자인)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: AppColors.headerBlueGradient,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48), // 대칭을 위한 빈 공간
                  Expanded(
                    child: Text(
                      '프로필',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: AppColors.headerText,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: AppColors.headerText, size: 28),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      );
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // User Profile Card
                    _buildUserProfileCard(user),

                    const SizedBox(height: 16),

                    // Level Progress Card
                    _buildLevelProgressCard(),

                    const SizedBox(height: 16),

                    // Daily Goal Card
                    _buildDailyGoalCard(),

                    const SizedBox(height: 24),

                    // Badges Section
                    _buildBadgesSection(),

                    const SizedBox(height: 24),

                    // Statistics Section
                    _buildStatisticsSection(),

                    const SizedBox(height: 24),

                    // Quick Access Menu Section
                    _buildQuickAccessSection(context),

                    const SizedBox(height: 24),

                    // Info Section (Followers/Following/Lifetime XP)
                    _buildInfoSection(),

                    const SizedBox(height: 100), // 하단 네비게이션 공간
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// User Profile Card - 프로필 사진 + 이름 + 스탯
  Widget _buildUserProfileCard(user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // 프로필 사진
              CircleAvatar(
                radius: 46,
                backgroundColor: const Color(0xFFE8F4FD),
                child: CircleAvatar(
                  radius: 42,
                  backgroundColor: Colors.white,
                  backgroundImage: user?.avatarUrl != null && user!.avatarUrl.isNotEmpty
                      ? NetworkImage(user.avatarUrl)
                      : null,
                  child: user?.avatarUrl == null || user!.avatarUrl.isEmpty
                      ? Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.grey.shade400,
                        )
                      : null,
                ),
              ),

              const SizedBox(width: 20),

              // 이름 + 스탯
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? '고 1',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 스탯 행 (XP, 스트릭, 레벨)
                    Row(
                      children: [
                        Expanded(child: _buildMiniStat('💎', '${user?.xp ?? 549}')),
                        const SizedBox(width: 4),
                        Expanded(child: _buildMiniStat('🔥', '${user?.streakDays ?? 6}')),
                        const SizedBox(width: 4),
                        Expanded(child: _buildMiniStat('🏅', 'Lv${user?.level ?? 1}')),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String emoji, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Level Progress Card - 레벨 진행률
  Widget _buildLevelProgressCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // 레벨 아이콘
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.red.shade700,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.military_tech,
              color: Colors.white,
              size: 32,
            ),
          ),

          const SizedBox(width: 16),

          // 진행률
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'H Lv1',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      '50%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: 0.5,
                    minHeight: 14,
                    backgroundColor: const Color(0xFFE0E0E0),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.pink.shade300,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Daily Goal Card - 일일 목표
  Widget _buildDailyGoalCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // 목표 아이콘
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Center(
              child: Text('🎯', style: TextStyle(fontSize: 30)),
            ),
          ),

          const SizedBox(width: 16),

          // 진행률
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '오늘의 목표',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '80 / 100 XP',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: 0.8,
                    minHeight: 12,
                    backgroundColor: const Color(0xFFE0E0E0),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF45A6AD),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Badges Section - 업적 뱃지
  Widget _buildBadgesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '업적',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              Text(
                '3/12',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 뱃지 그리드
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(child: _buildBadge('assets/badges/badge_locked_1.png', '테크닉', isLocked: true)),
              Expanded(child: _buildBadge('assets/badges/badge_locked_2.png', '챌린지', isLocked: true)),
              Expanded(child: _buildBadge('assets/badges/badge_locked_3.png', '연속학습', isLocked: true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String imagePath, String title, {bool isLocked = false}) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              ClipOval(
                child: Image.asset(
                  imagePath,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.emoji_events,
                        size: 40,
                        color: Colors.grey.shade600,
                      ),
                    );
                  },
                ),
              ),
              if (isLocked)
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.lock, color: Colors.white, size: 28),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 100,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: isLocked ? Colors.grey.shade600 : const Color(0xFF1A1A1A),
              height: 1.3,
            ),
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  /// Statistics Section - 통계 정보 (6개 카드)
  Widget _buildStatisticsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Statistics',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),

          // 2x3 그리드
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildStatCard('Challenges', '12', '🎯'),
              _buildStatCard('Lessons Passed', '45', '📚'),
              _buildStatCard('Total Diamonds', '549', '💎'),
              _buildStatCard('Total Lifetime', '2.5h', '⏱️'),
              _buildStatCard('Correct Practices', '89%', '✅'),
              _buildStatCard('Top 3 Position', '1st', '🏆'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String emoji) {
    // MediaQuery를 사용하여 화면 너비 기준으로 카드 너비 계산
    return LayoutBuilder(
      builder: (context, constraints) {
        // 화면 너비에서 마진(24*2) 및 간격(12)을 뺀 후 2로 나누기
        final screenWidth = MediaQuery.of(context).size.width;
        final cardWidth = (screenWidth - 24 * 2 - 12) / 2;

        return Container(
          width: cardWidth,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Quick Access Menu - Practice and Level Test
  Widget _buildQuickAccessSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Access',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickAccessCard(
                  context,
                  '📝',
                  '연습 모드',
                  'Practice Mode',
                  const Color(0xFF4CAF50),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PracticeCategoryScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAccessCard(
                  context,
                  '🎯',
                  '레벨 테스트',
                  'Level Test',
                  const Color(0xFFFF9800),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LevelTestScreen(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickAccessCard(
                  context,
                  '🏆',
                  '업적',
                  'Achievements',
                  const Color(0xFF2196F3),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AchievementsScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAccessCard(
                  context,
                  '⚡',
                  '데일리 챌린지',
                  'Daily Challenge',
                  const Color(0xFFE91E63),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DailyChallengeScreen(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Row 3: Academic Records & Course Enrollment
          Row(
            children: [
              Expanded(
                child: _buildQuickAccessCard(
                  context,
                  '📊',
                  '학업 성적',
                  'Academic Records',
                  const Color(0xFF9C27B0),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AcademicRecordsScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAccessCard(
                  context,
                  '📚',
                  '수강 과정',
                  'My Courses',
                  const Color(0xFF00BCD4),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CourseEnrollmentScreen(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Row 4: League Tier & Friends
          Row(
            children: [
              Expanded(
                child: _buildQuickAccessCard(
                  context,
                  '🏆',
                  '리그 티어',
                  'League Tier',
                  const Color(0xFFFF5722),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TierLevelScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAccessCard(
                  context,
                  '👥',
                  '친구',
                  'Friends',
                  const Color(0xFF673AB7),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FriendsScreen(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessCard(
    BuildContext context,
    String emoji,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 40),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Info Section - Followers/Following/Lifetime XP
  Widget _buildInfoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem('Followers', '245'),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.shade300,
          ),
          _buildInfoItem('Following', '183'),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.shade300,
          ),
          _buildInfoItem('Lifetime XP', '2,450'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
