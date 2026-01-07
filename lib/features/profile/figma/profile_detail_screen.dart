import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/user/user.dart';
import '../../../data/providers/user/user_provider.dart';
import '../../../data/providers/subscription/premium_providers.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../shared/utils/level_badge_mapper.dart';
import '../../../shared/widgets/premium/premium_badge.dart';
import '../../settings/settings_screen.dart';
import '../edit_profile_screen.dart';
import '../../premium/premium_upgrade_screen.dart';
import '../../premium/subscription_management_screen.dart';

/// Figma 디자인 "05" 프로필 상세 페이지 - Figma Page 5 디자인 완벽 구현
class ProfileDetailScreen extends ConsumerStatefulWidget {
  const ProfileDetailScreen({super.key});

  @override
  ConsumerState<ProfileDetailScreen> createState() =>
      _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends ConsumerState<ProfileDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // 헤더 (뒤로가기 + 프로필 타이틀 + 설정)
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
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: AppColors.headerText, size: 28),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Text(
                    '프로필',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.headerText,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings,
                        color: AppColors.headerText, size: 28),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SettingsScreen()),
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

                    // User Profile Card with Edit Button & Level Progress
                    _buildUserProfileCard(user, context),

                    const SizedBox(height: 16),

                    // 팔로워 / XP / 팔로잉 통계
                    _buildFollowerStats(),

                    const SizedBox(height: 16),

                    // 연속 학습 이력 카드
                    _buildStreakCard(user),

                    const SizedBox(height: 24),

                    // 탭 섹션 (대수, 공통수학 1, 공통수학 2)
                    _buildTabSection(),

                    const SizedBox(height: 24),

                    // Badges Section
                    _buildBadgesSection(),

                    const SizedBox(height: 24),

                    // Your Statistics Section
                    _buildStatisticsSection(),

                    const SizedBox(height: 24),

                    // Premium Upgrade Card
                    _buildPremiumCard(),

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

  /// User Profile Card - Figma 디자인과 동일 (Edit Profile 버튼 + 레벨 진행률 통합)
  Widget _buildUserProfileCard(User? user, BuildContext context) {
    final userLevel = user?.level ?? 1;
    final tierColor = Color(LevelBadgeMapper.getTierColor(userLevel));
    final rankName = LevelBadgeMapper.getRankName(userLevel);
    final progress = user?.levelProgress ?? 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            const Color(0xFFE3F2FD).withOpacity(0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // 프로필 사진 + 이름 + Edit 버튼 + 알림 아이콘
          Row(
            children: [
              // 프로필 사진 (파란 그라디언트 배경, 원형, 통일된 디자인)
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.mathButtonGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.mathBlue.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: user?.avatarUrl != null && user!.avatarUrl.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          user.avatarUrl,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Center(
                        child: Text(
                          user?.name[0] ?? '학',
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: AppColors.surface,
                          ),
                        ),
                      ),
              ),

              const SizedBox(width: 16),

              // 이름 + 유저명 + Edit Profile 버튼
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user?.name ?? 'Jojo Selvey',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const PremiumBadge(
                          size: PremiumBadgeSize.small,
                          style: PremiumBadgeStyle.iconOnly,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${user?.email.split('@').first ?? 'jojoselvey04'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Edit Profile 버튼
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1A1A1A),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 알림 아이콘
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.notifications_none,
                  color: Color(0xFF1A1A1A),
                  size: 22,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 레벨 뱃지 + 진행률
          Row(
            children: [
              // 레벨 뱃지 아이콘
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [tierColor, tierColor.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: tierColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(6),
                child: Image.asset(
                  LevelBadgeMapper.getBadgeImagePath(userLevel),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 24,
                    );
                  },
                ),
              ),

              const SizedBox(width: 12),

              // 레벨명 + 진행률
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          rankName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: tierColor,
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // 진행률 바
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                        ),
                        child: Stack(
                          children: [
                            FractionallySizedBox(
                              widthFactor: progress,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.mathRed,
                                      AppColors.mathOrange,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
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
    );
  }

  /// 레벨 / XP / 스트릭 통계 (일관된 디자인)
  Widget _buildFollowerStats() {
    final user = ref.watch(userProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          _buildStatItem('레벨', 'Lv${user?.level ?? 1}'),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.shade300,
          ),
          _buildStatItem('XP', '${user?.xp ?? 549}'),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.shade300,
          ),
          _buildStatItem('스트릭', '${user?.streakDays ?? 0}일'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  /// 연속 학습 이력 카드 (원형 진행 표시)
  Widget _buildStreakCard(user) {
    final streakDays = user?.streakDays ?? 6;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFE3F2FD),
            const Color(0xFFBBDEFB).withOpacity(0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.mathBlue.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 불 아이콘
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Text('🔥', style: TextStyle(fontSize: 32)),
            ),
          ),

          const SizedBox(width: 16),

          // 텍스트
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '연속 학습 이력',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '수학을 꾸준한 학습이 가장 중요해요!',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF616161),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // 원형 진행 표시
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              children: [
                // 배경 원
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                // 진행 원 (오렌지색)
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: CircularProgressIndicator(
                    value: streakDays / 10, // 10일 기준
                    strokeWidth: 6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.mathOrange,
                    ),
                  ),
                ),
                // 숫자
                Center(
                  child: Text(
                    '$streakDays',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.mathOrange,
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

  /// 탭 섹션 (대수, 공통수학 1, 공통수학 2)
  Widget _buildTabSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // 탭 바
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.headerBlueGradient,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey.shade700,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: '대수'),
                Tab(text: '공통수학 1'),
                Tab(text: '공통수학 2'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 탭 컨텐츠
          SizedBox(
            height: 120,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTabContent('12 Task', AppColors.mathOrange),
                _buildTabContent('8 Task', AppColors.mathBlue),
                _buildTabContent('5 Task', AppColors.mathPurple),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(String taskCount, Color color) {
    return Container(
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
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            taskCount,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '완료해야 할 과제',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  /// Badges Section
  Widget _buildBadgesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Badges',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _buildBadge(
                  '👋',
                  '첫번째 챌린지 완성',
                  const Color(0xFF9575CD),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildBadge(
                  '🏅',
                  '연속학습 달성',
                  const Color(0xFFFFB74D),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildBadge(
                  '🏆',
                  '챌린지 마스터',
                  const Color(0xFFFFA726),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String emoji, String title, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF1A1A1A),
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  /// Your Statistics Section
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
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildStatCard('Challenges', '235', AppColors.mathOrange),
              _buildStatCard('Lessons Passed', '138', AppColors.mathBlue),
              _buildStatCard('Total Diamonds', '1,239', AppColors.mathPurple),
              _buildStatCard('Total Lifetime', '18,539', AppColors.mathTeal),
              _buildStatCard('Correct Practices', '1,239', AppColors.mathGreen),
              _buildStatCard('Top 3 Position', '43', AppColors.mathGold),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color accentColor) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 24 * 2 - 12) / 2;

    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            accentColor.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Premium Upgrade Card
  Widget _buildPremiumCard() {
    final isPremiumActive = ref.watch(isPremiumActiveProvider);
    final premiumStatusText = ref.watch(premiumStatusTextProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPremiumActive
              ? AppColors.premiumGradient
                  .map((c) => c.withOpacity(0.2))
                  .toList()
              : [
                  const Color(0xFFE3F2FD),
                  const Color(0xFFBBDEFB).withOpacity(0.5),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isPremiumActive
                ? AppColors.premiumGold.withOpacity(0.2)
                : AppColors.mathBlue.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isPremiumActive ? '프리미엄 회원' : 'Upgrade to Premium',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isPremiumActive
                            ? AppColors.premiumGold
                            : const Color(0xFF1A1A1A),
                      ),
                    ),
                    if (isPremiumActive) ...[
                      const SizedBox(width: 8),
                      const PremiumBadge(
                        size: PremiumBadgeSize.small,
                        style: PremiumBadgeStyle.iconOnly,
                        showTooltip: false,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  isPremiumActive
                      ? premiumStatusText
                      : 'Get benefit from our premium',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: ElevatedButton(
              onPressed: () {
                if (isPremiumActive) {
                  // Premium user: Navigate to subscription management
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          const SubscriptionManagementScreen(),
                    ),
                  );
                } else {
                  // Free user: Navigate to premium upgrade
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PremiumUpgradeScreen(),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isPremiumActive
                    ? AppColors.premiumGold
                    : AppColors.mathBlue,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
              child: Text(
                isPremiumActive ? '관리' : 'Upgrade',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
