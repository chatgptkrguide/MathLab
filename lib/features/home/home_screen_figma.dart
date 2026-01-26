import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/figma_colors.dart';
import '../../shared/constants/game_constants.dart';
import '../lessons/figma/lessons_screen_figma.dart';
import '../../data/providers/user/user_provider.dart';
import '../../shared/widgets/cards/daily_goal_card.dart';
import 'widgets/home_header.dart';
import 'widgets/home_top_section.dart';
import 'widgets/home_start_button.dart';
import 'widgets/home_robot_section.dart';
import 'widgets/home_stats_cards.dart';
import 'widgets/home_friends_activity.dart';
import 'widgets/home_language_cards.dart';
import 'widgets/home_daily_challenge.dart';

/// Figma 디자인 "00 home" 화면 100% 재현
/// 레퍼런스: assets/images/figma_home_reference.png
/// 업데이트: 2026-01-23 - 색상 및 디자인 개선
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
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 100), // 네비게이션 바 여유 공간
          child: Column(
            children: [
              const SizedBox(height: 24),

              // 1. Figma: 상단 간단한 인사 + 스트릭 (우상단)
              HomeTopSection(user: user),

              const SizedBox(height: 32),

              // 2. Figma: 🤖 로봇 캐릭터 + 진행률 링 (상단 중앙, 크게!)
              const HomeRobotSection(),

              const SizedBox(height: 32),

              // 3. Figma: 오늘의 목표 카드
              _buildTodayGoalCard(context, user),

              const SizedBox(height: 24),

              // 4. Figma: 📘 학습 시작하기 버튼
              const HomeStartButton(),

              const SizedBox(height: 32),

              // 5. Figma: 스탯 카드 3개 (XP, 레벨, 연속)
              HomeStatsCards(user: user),

              const SizedBox(height: 24),

              // 6. Figma: 언어 선택 카드
              const HomeLanguageCards(),

              const SizedBox(height: 24),

              // 7. Figma: 데일리 챌린지 카드
              const HomeDailyChallenge(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// 오늘의 목표 카드 (Figma 디자인)
  Widget _buildTodayGoalCard(BuildContext context, user) {
    final dailyXP = user?.dailyXP ?? 0;
    final dailyGoal = GameConstants.dailyGoalXP;
    final progress = dailyXP / dailyGoal;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () {
          // 레슨 선택 화면으로 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LessonsScreenFigma(),
            ),
          );
        },
        child: DailyGoalCard(
          currentXP: dailyXP,
          goalXP: dailyGoal,
        ),
      ),
    );
  }
}
