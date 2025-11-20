import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/figma_colors.dart';
import '../lessons/figma/lessons_screen_figma.dart';
import '../daily_reward/daily_reward_screen.dart';
import '../profile/figma/profile_detail_screen_v3_new.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../../data/providers/user_provider.dart';
import '../../shared/widgets/cards/daily_goal_card.dart';
import '../../shared/widgets/indicators/circular_progress_ring.dart';

/// Figma 디자인 "00 home" 화면 100% 재현
/// 레퍼런스: assets/images/figma_home_reference.png
class HomeScreenFigma extends ConsumerWidget {
  const HomeScreenFigma({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: FigmaColors.homeGradient,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),

              // 상단: "안녕하세요!" + 스트릭
              _buildTopSection(context, user),

              const SizedBox(height: 24),

              // 중앙: 로봇 캐릭터 + 진행률 링
              _buildRobotSection(context),

              const SizedBox(height: 32),

              // 오늘의 목표 카드
              _buildTodayGoalCard(context),

              const SizedBox(height: 20),

              // 학습 시작하기 버튼
              _buildStartButton(context),

              const SizedBox(height: 24),

              // 하단 스탯 카드들 (XP, 레벨, 연속)
              _buildStatsCards(context, user),

              const SizedBox(height: 20),

              // 언어 선택 카드
              _buildLanguageCards(),

              const SizedBox(height: 20),

              // 데일리 챌린지 배너
              _buildDailyChallengeB(context),

              const SizedBox(height: 100), // 네비게이션 바 공간
            ],
          ),
        ),
      ),
    );
  }

  /// 상단: "안녕하세요!" + 스트릭
  Widget _buildTopSection(BuildContext context, user) {
    // 사용자 이름 표시 (게스트인 경우 기본값)
    final userName = user?.name ?? 'Guest';
    final isGuest = user?.email == 'guest@gomath.com';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 안녕하세요!
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isGuest ? '안녕하세요!' : '안녕하세요, $userName님!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isGuest ? '게스트로 학습 중' : '$userName의 수학 학습',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),

          // 스트릭 배지 (클릭하면 프로필 상세 화면으로)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileDetailScreenV3New(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Image.asset('assets/icons/streak_fire.png', width: 20, height: 20),
                    const SizedBox(width: 6),
                    Text(
                      '${user?.streakDays ?? 6}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 중앙: 로봇 캐릭터 + 진행률 링 (Figma 디자인)
  Widget _buildRobotSection(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Image.asset(
                  'assets/icons/robot_character.png',
                  width: 32,
                  height: 32,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text('🤖', style: TextStyle(fontSize: 24));
                  },
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    '안녕! 나는 GoMath 로봇이야. 오늘도 열심히 공부하자! 💪',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF4A90E2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      },
      child: SizedBox(
        width: 300,
        height: 300,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Figma 원형 진행률 링
            const CircularProgressRing(
              progress: 0.8,
              centerText: '80%',
              subtitle: '완료',
              size: 280,
              strokeWidth: 16,
            ),

            // 로봇 캐릭터 (중앙에 오버레이)
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
              ),
              child: Center(
                child: Image.asset(
                  'assets/icons/robot_character.png',
                  width: 180,
                  height: 180,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/icons/character_design.png',
                      width: 180,
                      height: 180,
                      errorBuilder: (context, error, stackTrace) {
                        return const Text(
                          '🤖',
                          style: TextStyle(fontSize: 100),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 오늘의 목표 카드 (Figma 디자인)
  Widget _buildTodayGoalCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LessonsScreenFigma(),
          ),
        );
      },
      child: const DailyGoalCard(
        icon: '📚',
        title: '오늘의 목표',
        progress: 0.8,
        current: 80,
        total: 100,
      ),
    );
  }

  /// 학습 시작하기 버튼
  Widget _buildStartButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0000FF), Color(0xFF0000CC)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0000FF).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LessonsScreenFigma(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(28),
          child: const Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.play_arrow, color: Colors.white, size: 28),
                SizedBox(width: 8),
                Text(
                  '학습 시작하기',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 하단 스탯 카드들 (XP, 레벨, 연속)
  Widget _buildStatsCards(BuildContext context, user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // XP 카드 - 프로필 상세 화면으로 이동
          _buildStatCard(
            'assets/icons/xp_icon.png',
            'XP',
            '${user?.xp ?? 549}',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileDetailScreenV3New(),
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          // 레벨 카드 - 리더보드 화면으로 이동
          _buildStatCard(
            null,
            '레벨',
            'H Lv${user?.level ?? 1}',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LeaderboardScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          // 연속 카드 - 프로필 상세 화면으로 이동
          _buildStatCard(
            'assets/icons/streak_fire.png',
            '연속',
            '${user?.streakDays ?? 6}일',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileDetailScreenV3New(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String? iconPath, String label, String value, {VoidCallback? onTap}) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                iconPath != null
                    ? Image.asset(
                        iconPath,
                        width: 36,
                        height: 36,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/icons/gomath_logo_small.png',
                            width: 36,
                            height: 36,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.emoji_events, size: 36, color: Color(0xFFFFB74D));
                            },
                          );
                        },
                      )
                    : Image.asset(
                        'assets/icons/gomath_logo_small.png',
                        width: 36,
                        height: 36,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.emoji_events, size: 36, color: Color(0xFFFFB74D));
                        },
                      ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 언어 선택 카드
  Widget _buildLanguageCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // English 카드
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🇬🇧', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  const Text(
                    'English',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text('→', style: TextStyle(fontSize: 24, color: Colors.white)),
          ),

          // Spanish 카드
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🇪🇸', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  const Text(
                    'Spanish',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
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

  /// 데일리 챌린지 배너
  Widget _buildDailyChallengeB(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DailyRewardScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFA726), Color(0xFFFF9800)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '데일리 챌린지',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '오늘의 챌린지 미션을 완료해 보세요',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '데일리 챌린지 미션',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 챌린지 이미지
              const Text('🎬', style: TextStyle(fontSize: 60)),
            ],
          ),
        ),
      ),
    );
  }
}
