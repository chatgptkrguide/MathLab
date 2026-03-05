import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/game_constants.dart';
import '../../data/providers/user/user_provider.dart';
import '../../data/providers/daily_reward_provider.dart';
import '../../shared/widgets/daily_reward_dialog.dart';
import '../../shared/widgets/effects/noise_texture.dart';
import '../../shared/widgets/indicators/circular_progress_ring.dart';
import '../settings/settings_screen.dart';
import '../lessons/figma/lessons_screen_figma.dart';
import '../../data/providers/wrong_answer/wrong_answer_provider.dart';
import '../../data/providers/infrastructure/navigation_provider.dart';
import '../../data/providers/gamification/heart_regen_provider.dart';

/// 피그마 "00 home" 디자인 — 한 화면, 로봇 중심
class HomeScreenFigma extends ConsumerStatefulWidget {
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
    final hearts = user?.hearts ?? GameConstants.maxHearts;
    final maxHearts = user?.maxHearts ?? GameConstants.maxHearts;
    final heartRegen = ref.watch(heartRegenProvider);
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
            child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 12),

                // ── 상단: 인사 + 스트릭 ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '안녕하세요!',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${user?.displayName ?? '학습자'}의 수학 학습',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.favorite, color: Color(0xFFFF4B6E), size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '$hearts',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (hearts < maxHearts && heartRegen.nextRegenSeconds > 0) ...[
                            const SizedBox(width: 4),
                            Text(
                              '(${_formatRegenTime(heartRegen.nextRegenSeconds)})',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🔥', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 4),
                            Text(
                              '$streak',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // ── 로봇 + 진행률 링 (화면 중앙, 크게) ──
                Expanded(
                  child: Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final maxSize = constraints.maxHeight * 0.85;
                        final size = maxSize.clamp(160.0, 280.0);
                        return SizedBox(
                          width: size,
                          height: size + 30,
                          child: Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              CircularProgressRing(
                                progress: progress,
                                size: size,
                                strokeWidth: 14,
                                child: const SizedBox.shrink(),
                              ),
                              Container(
                                width: size * 0.68,
                                height: size * 0.68,
                                margin: EdgeInsets.only(top: size * 0.16),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.15),
                                ),
                                child: Center(
                                  child: Image.asset(
                                    'assets/icons/robot_character.png',
                                    width: size * 0.55,
                                    height: size * 0.55,
                                    errorBuilder: (_, __, ___) => Image.asset(
                                      'assets/icons/character_design.png',
                                      width: size * 0.55,
                                      height: size * 0.55,
                                      errorBuilder: (_, __, ___) => Text(
                                        '🤖',
                                        style: TextStyle(fontSize: size * 0.3),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // 하단 목표 뱃지
                              Positioned(
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.emoji_events_rounded, size: 16, color: Color(0xFFFFB800)),
                                      const SizedBox(width: 6),
                                      Text(
                                        '오늘의 목표  $dailyXP / $dailyGoal XP',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF333333),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // ── 학습 시작하기 버튼 ──
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LessonsScreenFigma()),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: AppColors.deepBlueCTA,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.deepBlue.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                        SizedBox(width: 8),
                        Text(
                          '학습 시작하기',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Review reminder badge ──
                if (user != null) _buildReviewBadge(ref, user.uid),

                // ── 데일리 챌린지 (간결) ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: AppColors.goldGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          '데일리 챌린지',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          '도전',
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

                const SizedBox(height: 14),
              ],
            ),
          ),
        ),
        ],
      ),
    );
  }

  String _formatRegenTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildReviewBadge(WidgetRef ref, String userId) {
    final wrongState = ref.watch(wrongAnswerProvider(userId));
    final reviewCount =
        wrongState.wrongAnswers.where((w) => w.shouldReview()).length;

    if (reviewCount == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () {
          // Navigate to wrong answer tab (index 1)
          ref.read(navigationProvider.notifier).goToWrongAnswer();
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF5B6ABF).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFF5B6ABF).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF5B6ABF).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(
                    Icons.assignment_rounded,
                    size: 18,
                    color: Color(0xFF5B6ABF),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '복습할 문제 ${reviewCount}개',
                  style: const TextStyle(
                    color: Color(0xFF5B6ABF),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF5B6ABF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '복습하기',
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
      ),
    );
  }
}
