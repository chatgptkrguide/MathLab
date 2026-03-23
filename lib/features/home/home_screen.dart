import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/game_constants.dart';
import '../../data/providers/user/user_provider.dart';
import '../../data/providers/gamification/daily_reward_provider.dart';
import '../../shared/widgets/daily_reward_dialog.dart';
import '../../shared/widgets/effects/noise_texture.dart';
import '../../shared/widgets/indicators/circular_progress_ring.dart';
import '../settings/settings_screen.dart';
import '../lessons/lessons_screen.dart';
import '../../data/providers/wrong_answer/wrong_answer_provider.dart';
import '../../data/providers/infrastructure/navigation_provider.dart';

class HomeScreenFigma extends ConsumerStatefulWidget {
  /// 코치마크에서 참조할 GlobalKey들
  static final startButtonKey = GlobalKey(debugLabel: 'startButton');
  static final todayGoalKey = GlobalKey(debugLabel: 'todayGoal');
  static final statsRowKey = GlobalKey(debugLabel: 'statsRow');
  static final dailyChallengeKey = GlobalKey(debugLabel: 'dailyChallenge');
  static final streakBadgeKey = GlobalKey(debugLabel: 'streakBadge');

  const HomeScreenFigma({super.key});

  @override
  ConsumerState<HomeScreenFigma> createState() => _HomeScreenFigmaState();
}

class _HomeScreenFigmaState extends ConsumerState<HomeScreenFigma> {
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowRewardDialog();
    });
  }

  void _checkAndShowRewardDialog() {
    if (_dialogShown) return;
    final rewardState = ref.read(dailyRewardProvider);
    if (!rewardState.isLoading && rewardState.shouldShowDialog) {
      _dialogShown = true;
      DailyRewardDialog.show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    ref.listen<DailyRewardState>(dailyRewardProvider, (prev, next) {
      if (prev != null && prev.isLoading && !next.isLoading) {
        _checkAndShowRewardDialog();
      }
    });

    final streak = user?.streak ?? 0;
    final dailyXP = user?.dailyXP ?? 0;
    final dailyGoal = GameConstants.dailyGoalXP;
    final progress = (dailyXP / dailyGoal).clamp(0.0, 1.0);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(gradient: AppColors.homeGradient),
          ),
          const NoiseTexture(opacity: 0.025, color: Colors.white),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
              child: Column(
                children: [
                  // 1. Top: greeting + streak badge
                  _buildTopBar(user?.displayName, streak),
                  const SizedBox(height: 16),

                  // 2. Robot + circular progress (centered)
                  Center(child: _buildRobotSection(progress)),
                  const SizedBox(height: 16),

                  // 3. Today's goal card
                  _buildTodayGoal(dailyXP, dailyGoal, progress),
                  const SizedBox(height: 12),

                  // 4. Start button
                  _buildStartButton(),
                  const SizedBox(height: 12),

                  // 5. Stats: XP, Level, Streak (3 squares)
                  _buildStatsRow(user?.xp ?? 0, user?.level ?? 1, streak),
                  const SizedBox(height: 16),

                  // 6. Subject cards (horizontal row)
                  _buildSubjectRow(),
                  const SizedBox(height: 12),

                  // 7. Daily challenge card
                  _buildDailyChallenge(),
                  const SizedBox(height: 6),

                  // 8. Review badge
                  if (user != null) _buildReviewBadge(ref, user.uid),
                  const SizedBox(height: 16),

                  // 9. Action buttons (stacked full-width)
                  _buildActionButtons(),
                  const SizedBox(height: 24),

                  // 10. Logo
                  _buildLogo(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // === 1. Top Bar: Greeting + Streak Badge ===
  Widget _buildTopBar(String? name, int streak) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left: greeting
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '안녕하세요!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${name ?? '학습자'}의 수학 학습',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  letterSpacing: 1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // Right: streak badge
        GestureDetector(
          key: HomeScreenFigma.streakBadgeKey,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE8E8E8),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_fire_department_rounded,
                  color: AppColors.mathOrange,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  streak.toString().padLeft(2, '0'),
                  style: const TextStyle(
                    color: Color(0xFF0D061F),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // === 2. Robot + Circular Progress ===
  Widget _buildRobotSection(double progress) {
    return SizedBox(
      width: 190,
      height: 190,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressRing(
            progress: progress,
            size: 190,
            strokeWidth: 8,
            child: const SizedBox.shrink(),
          ),
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.15),
            ),
            child: Center(
              child: Image.asset(
                'assets/icons/robot_character.png',
                width: 100,
                height: 100,
                errorBuilder: (_, __, ___) => Image.asset(
                  'assets/icons/character_design.png',
                  width: 100,
                  height: 100,
                  errorBuilder: (_, __, ___) => const Text(
                    '🤖',
                    style: TextStyle(fontSize: 56),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // === 3. Today's Goal Card ===
  Widget _buildTodayGoal(int dailyXP, int dailyGoal, double progress) {
    return Container(
      key: HomeScreenFigma.todayGoalKey,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Book icon
          Image.asset(
            'assets/icons/book_pencil.png',
            width: 58,
            height: 58,
            errorBuilder: (_, __, ___) => Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.menu_book_rounded, size: 32, color: AppColors.royalBlue),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '오늘의 목표',
                  style: TextStyle(
                    color: Color(0xFF0D061F),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$dailyXP / $dailyGoal XP',
                  style: const TextStyle(
                    color: Color(0xFF18181B),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.5),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 9,
                    backgroundColor: const Color(0xFFE0E0E0),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.tealGreen),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // === 4. Start Button ===
  Widget _buildStartButton() {
    return GestureDetector(
      key: HomeScreenFigma.startButtonKey,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LessonsScreenFigma()),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFF0015F8),
          borderRadius: BorderRadius.circular(26.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0015F8).withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
            SizedBox(width: 6),
            Text(
              '학습 시작하기',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === 5. Stats Row (3 squares: XP, Level, Streak) ===
  Widget _buildStatsRow(int xp, int level, int streak) {
    return Row(
      key: HomeScreenFigma.statsRowKey,
      children: [
        _buildStatSquare(
          icon: 'assets/icons/xp_icon.png',
          fallbackIcon: Icons.bolt_rounded,
          fallbackColor: AppColors.xpGold,
          label: 'XP',
          value: '$xp',
        ),
        const SizedBox(width: 10),
        _buildStatSquare(
          icon: 'assets/icons/level_icon.png',
          fallbackIcon: Icons.shield_rounded,
          fallbackColor: AppColors.royalBlue,
          label: '레벨',
          value: 'Lv.$level',
        ),
        const SizedBox(width: 10),
        _buildStatSquare(
          icon: 'assets/icons/streak_icon.png',
          fallbackIcon: Icons.local_fire_department_rounded,
          fallbackColor: AppColors.streakOrange,
          label: '연속',
          value: '$streak일',
        ),
      ],
    );
  }

  Widget _buildStatSquare({
    required String icon,
    required IconData fallbackIcon,
    required Color fallbackColor,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Image.asset(
              icon,
              width: 42,
              height: 42,
              errorBuilder: (_, __, ___) => Icon(
                fallbackIcon,
                color: fallbackColor,
                size: 42,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // === 6. Subject Cards (horizontal row) ===
  Widget _buildSubjectRow() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Subject 1
          Expanded(
            child: GestureDetector(
              onTap: () => ref.read(navigationProvider.notifier).goToLessons(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F6F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8EEFF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.functions_rounded, size: 18, color: AppColors.royalBlue),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '공통수학 1',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF18181B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Arrow divider (Figma: 24x24)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 24,
              color: Color(0xFF18181B),
            ),
          ),
          // Subject 2
          Expanded(
            child: GestureDetector(
              onTap: () => ref.read(navigationProvider.notifier).goToLessons(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F6F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE0F5F6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.show_chart_rounded, size: 18, color: AppColors.tealGreen),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '공통수학 2',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF18181B),
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

  // === 7. Daily Challenge Card ===
  Widget _buildDailyChallenge() {
    return GestureDetector(
      key: HomeScreenFigma.dailyChallengeKey,
      onTap: () => ref.read(navigationProvider.notifier).goToTeam(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF3C283),
          borderRadius: BorderRadius.circular(12),
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
                      color: Color(0xFF0D061F),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '오늘의 챌린지 미션을 완료해 보세요',
                    style: TextStyle(
                      color: Color(0xFF0D061F),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFB5523),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF921B7A),
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Text(
                      '데일리 챌린지 미션',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Character illustration placeholder
            Image.asset(
              'assets/icons/challenge_character.png',
              width: 94,
              height: 95,
              errorBuilder: (_, __, ___) => const SizedBox(
                width: 94,
                height: 95,
                child: Icon(Icons.emoji_events_rounded, size: 48, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === 8. Review Badge ===
  Widget _buildReviewBadge(WidgetRef ref, String userId) {
    final wrongState = ref.watch(wrongAnswerProvider(userId));
    final reviewCount =
        wrongState.wrongAnswers.where((w) => w.shouldReview()).length;

    if (reviewCount == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: GestureDetector(
        onTap: () => ref.read(navigationProvider.notifier).goToWrongAnswer(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.refresh_rounded, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                '복습할 문제 $reviewCount개',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // === 9. Action Buttons (Figma: stacked full-width) ===
  Widget _buildActionButtons() {
    return Column(
      children: [
        // Blue: Assignments & Weekly Tests
        _buildActionItem(
          color: const Color(0xFF3195FF),
          shadowColor: const Color(0xFF1C7CE2),
          icon: Icons.assignment_rounded,
          iconBgOpacity: 0.5,
          label: '과제  및 주간테스트 확인 & 제출',
          borderRadius: 8,
          onTap: () => ref.read(navigationProvider.notifier).goToLessons(),
        ),
        const SizedBox(height: 16),
        // Light purple: AI Tutor
        _buildActionItem(
          color: const Color(0xFFA2B6FF),
          shadowColor: const Color(0xFF499609),
          icon: Icons.smart_toy_rounded,
          label: 'AI 튜터에게 물어보세요',
          borderRadius: 14,
          onTap: () => _showComingSoon('AI 튜터'),
        ),
        const SizedBox(height: 16),
        // Dark blue: Chat
        _buildActionItem(
          color: const Color(0xFF0F31AC),
          shadowColor: const Color(0xFFD27312),
          icon: Icons.chat_rounded,
          label: '맴버들 채팅하기',
          borderRadius: 14,
          onTap: () => _showComingSoon('채팅'),
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required Color color,
    required Color shadowColor,
    required IconData icon,
    required String label,
    required double borderRadius,
    double iconBgOpacity = 0.12,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: iconBgOpacity),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === 10. Logo ===
  Widget _buildLogo() {
    return Center(
      child: Opacity(
        opacity: 0.7,
        child: Image.asset(
          'assets/icons/gomath_logo.png',
          width: 144,
          height: 56,
          errorBuilder: (_, __, ___) => const Text(
            'GoMath Lab',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // === Coming Soon Dialog ===
  void _showComingSoon(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.construction_rounded, color: AppColors.mathOrange, size: 28),
            const SizedBox(width: 8),
            Text(
              feature,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          '$feature 기능은 현재 준비 중입니다.\n곧 업데이트 될 예정이니 기대해주세요!',
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              '확인',
              style: TextStyle(
                color: AppColors.nodeActive,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
