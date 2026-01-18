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
        child: Column(
          children: [
            // 통합 헤더
            const HomeHeader(),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 100), // 네비게이션 바 여유 공간
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // 1. 상단: "안녕하세요!" + 스트릭 (핵심 정보)
                    HomeTopSection(user: user),

                    const SizedBox(height: 20),

                    // 2. 오늘의 목표 카드 (한눈에 진행 상황 파악)
                    _buildTodayGoalCard(context, user),

                    const SizedBox(height: 24),

                    // 3. 🎯 학습 시작하기 버튼 (핵심 CTA - 더 일찍 배치)
                    const HomeStartButton(),

                    const SizedBox(height: 24),

                    // 4. 중앙: 로봇 캐릭터 + 진행률 링 (시각적 피드백)
                    const HomeRobotSection(),

                    const SizedBox(height: 32),

                    // 5. 하단 스탯 카드들 (XP, 레벨, 연속 - 압축된 정보)
                    HomeStatsCards(user: user),

                    const SizedBox(height: 32),

                    // 선택적 섹션들 (접을 수 있는 형태로 개선 가능)
                    // 친구 활동, 학년 선택, 데일리 챌린지는 필요시 별도 탭으로 이동

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
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
          icon: '📚',
          title: '오늘의 목표',
          progress: progress.clamp(0.0, 1.0),
          current: dailyXP,
          total: dailyGoal,
        ),
      ),
    );
  }
}
