import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/figma_colors.dart';
import '../../shared/constants/game_constants.dart';
import '../../data/providers/user/user_provider.dart';
import '../../data/providers/infrastructure/navigation_provider.dart';
import '../../data/providers/daily_reward_provider.dart';
import '../../shared/widgets/cards/daily_goal_card.dart';
import '../../shared/widgets/daily_reward_dialog.dart';
import 'widgets/home_top_section.dart';
import 'widgets/home_start_button.dart';
import 'widgets/home_robot_section.dart';
import 'widgets/home_stats_cards.dart';
import 'widgets/home_daily_challenge.dart';
import 'widgets/home_action_buttons.dart';
import 'widgets/home_subject_cards.dart';

/// Figma 디자인 "00 home" 화면
/// 스카이블루(#61A1D8) 배경 + 과목 카드 + 데일리 챌린지 + CTA 3개
class HomeScreenFigma extends ConsumerStatefulWidget {
  const HomeScreenFigma({super.key});

  @override
  ConsumerState<HomeScreenFigma> createState() => _HomeScreenFigmaState();
}

class _HomeScreenFigmaState extends ConsumerState<HomeScreenFigma> {
  @override
  void initState() {
    super.initState();
    // 일일 보상 다이얼로그 체크
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rewardState = ref.read(dailyRewardProvider);
      if (rewardState.shouldShowDialog) {
        DailyRewardDialog.show(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: FigmaColors.homeGradient,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // 1. 상단 인사 + 스트릭
              HomeTopSection(user: user),

              const SizedBox(height: 16),

              // 1.5. 상태 바 (현재 레슨명 + 스트릭 + XP + 레벨)
              _buildStatusBar(user),

              const SizedBox(height: 24),

              // 2. 로봇 캐릭터 + 진행률 링
              const HomeRobotSection(),

              const SizedBox(height: 32),

              // 3. 오늘의 목표 카드
              _buildTodayGoalCard(context, user),

              const SizedBox(height: 24),

              // 4. 학습 시작하기 버튼
              const HomeStartButton(),

              const SizedBox(height: 32),

              // 5. 스탯 카드 3개 (XP, 레벨, 연속)
              HomeStatsCards(user: user),

              const SizedBox(height: 24),

              // 6. 과목 선택 카드 (피그마: 공통수학 1, 공통수학 2)
              HomeSubjectCards(
                onSubjectTap: (subjectId) {
                  // 학습 탭으로 이동
                  ref.read(navigationProvider.notifier).goToLessons();
                },
              ),

              const SizedBox(height: 24),

              // 7. 데일리 챌린지 카드
              const HomeDailyChallenge(),

              const SizedBox(height: 24),

              // 8. 하단 CTA 3개 (과제 확인, AI 튜터, 멤버 채팅)
              const HomeActionButtons(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// 상태 바: 현재 레슨명 + 스트릭 + XP + 레벨
  Widget _buildStatusBar(user) {
    final streak = user?.streak ?? 0;
    final xp = user?.xp ?? 0;
    final level = user?.level ?? 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 현재 레슨명
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '소인수분해',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // 스트릭
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 3),
                Text(
                  '$streak',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            // XP
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt_rounded, color: Colors.amber, size: 16),
                const SizedBox(width: 2),
                Text(
                  '$xp',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            // 레벨
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'HLv$level',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 오늘의 목표 카드
  Widget _buildTodayGoalCard(BuildContext context, user) {
    final dailyXP = user?.dailyXP ?? 0;
    final dailyGoal = GameConstants.dailyGoalXP;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () {
          ref.read(navigationProvider.notifier).goToLessons();
        },
        child: DailyGoalCard(
          currentXP: dailyXP,
          goalXP: dailyGoal,
        ),
      ),
    );
  }
}
