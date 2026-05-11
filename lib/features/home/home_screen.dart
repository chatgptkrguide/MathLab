import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/gamification/daily_reward_provider.dart';
import '../../data/providers/infrastructure/navigation_provider.dart';
import '../../data/providers/user/user_provider.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/game_constants.dart';
import '../../shared/widgets/coach_mark/coach_mark_controller.dart';
import '../../shared/widgets/daily_reward_dialog.dart';
import '../../shared/widgets/effects/noise_texture.dart';
import '../lessons/lessons_screen.dart';
import '../settings/settings_screen.dart';
import 'widgets/home_action_buttons.dart';
import 'widgets/home_daily_challenge.dart';
import 'widgets/home_logo.dart';
import 'widgets/home_review_badge.dart';
import 'widgets/home_robot_section.dart';
import 'widgets/home_start_button.dart';
import 'widgets/home_stats_row.dart';
import 'widgets/home_subject_row.dart';
import 'widgets/home_today_goal.dart';
import 'widgets/home_top_bar.dart';

class HomeScreenFigma extends ConsumerStatefulWidget {
  /// 코치마크에서 참조할 GlobalKey들
  static final startButtonKey = GlobalKey(debugLabel: 'startButton');
  static final todayGoalKey = GlobalKey(debugLabel: 'todayGoal');
  static final statsRowKey = GlobalKey(debugLabel: 'statsRow');
  static final dailyChallengeKey = GlobalKey(debugLabel: 'dailyChallenge');
  static final streakBadgeKey = GlobalKey(debugLabel: 'streakBadge');
  static final subjectRowKey = GlobalKey(debugLabel: 'subjectRow');

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

  Future<void> _checkAndShowRewardDialog() async {
    if (_dialogShown) return;

    // 코치마크 온보딩이 완료되지 않았으면 보상 다이얼로그를 표시하지 않음
    final coachMarkDone = await CoachMarkController.isCompleted();
    if (!coachMarkDone || !mounted) return;

    final rewardState = ref.read(dailyRewardProvider);
    if (!rewardState.isLoading && rewardState.shouldShowDialog) {
      _dialogShown = true;
      if (mounted) DailyRewardDialog.show(context);
    }
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  void _openLessons() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LessonsScreenFigma()),
    );
  }

  void _showComingSoon(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.construction_rounded, color: AppColors.mathOrange, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                feature,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
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
                  HomeTopBar(
                    name: user?.displayName,
                    streak: streak,
                    onStreakTap: _openSettings,
                  ),
                  const SizedBox(height: 16),

                  // 2. Robot + circular progress (centered)
                  Center(child: HomeRobotSection(progress: progress)),
                  const SizedBox(height: 16),

                  // 3. Today's goal card
                  HomeTodayGoal(
                    dailyXP: dailyXP,
                    dailyGoal: dailyGoal,
                    progress: progress,
                  ),
                  const SizedBox(height: 12),

                  // 4. Start button
                  HomeStartButton(onPressed: _openLessons),
                  const SizedBox(height: 12),

                  // 5. Stats: XP, Level, Streak (3 squares)
                  HomeStatsRow(
                    xp: user?.xp ?? 0,
                    level: user?.level ?? 1,
                    streak: streak,
                  ),
                  const SizedBox(height: 16),

                  // 6. Subject cards (horizontal row)
                  const HomeSubjectRow(),
                  const SizedBox(height: 12),

                  // 7. Daily challenge card
                  HomeDailyChallenge(
                    onTap: () =>
                        ref.read(navigationProvider.notifier).goToTeam(),
                  ),
                  const SizedBox(height: 6),

                  // 8. Review badge
                  if (user != null) HomeReviewBadge(userId: user.uid),
                  const SizedBox(height: 16),

                  // 9. Action buttons (stacked full-width)
                  HomeActionButtons(
                    onAssignmentsTap: () =>
                        ref.read(navigationProvider.notifier).goToLessons(),
                    onAiTutorTap: () => _showComingSoon('AI 튜터'),
                    onChatTap: () => _showComingSoon('채팅'),
                  ),
                  const SizedBox(height: 24),

                  // 10. Logo
                  const HomeLogo(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
