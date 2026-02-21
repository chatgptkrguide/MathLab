import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_dimensions.dart';
import '../../shared/constants/app_text_styles.dart';
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
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    // 일일 보상 다이얼로그 체크
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

    // 보상 상태 변경 감지 → 로딩 완료 시 다이얼로그 표시
    ref.listen<DailyRewardState>(dailyRewardProvider, (prev, next) {
      if (prev != null && prev.isLoading && !next.isLoading) {
        _checkAndShowRewardDialog();
      }
    });

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.homeGradient,
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

              const SizedBox(height: 24),

              // 3. 오늘의 목표 카드
              _buildTodayGoalCard(context, user),

              const SizedBox(height: 16),

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

  /// 레벨 기반 현재 학습 단계명
  String _getLevelTopicName(int level) {
    if (level <= 3) return '기초 연산';
    if (level <= 6) return '분수와 소수';
    if (level <= 10) return '방정식';
    if (level <= 15) return '함수';
    if (level <= 20) return '기하';
    if (level <= 30) return '통계와 확률';
    return '심화 학습';
  }

  /// 상태 바: 현재 레슨명 + 스트릭 + XP + 레벨
  Widget _buildStatusBar(user) {
    final streak = user?.streak ?? 0;
    final xp = user?.xp ?? 0;
    final level = user?.level ?? 1;
    final topicName = _getLevelTopicName(level);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing20),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing16,
          vertical: AppDimensions.spacing8,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(AppDimensions.radius16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 현재 레슨명
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacing8,
                  vertical: AppDimensions.spacing4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppDimensions.radius8),
                ),
                child: Text(
                  topicName,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.spacing8),
            // 스트릭
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 14)),
                const SizedBox(width: AppDimensions.spacing2),
                Text(
                  '$streak',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppDimensions.spacing8),
            // XP
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt_rounded, color: Colors.amber, size: AppDimensions.iconSmall),
                const SizedBox(width: AppDimensions.spacing2),
                Text(
                  '$xp',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppDimensions.spacing8),
            // 레벨
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing8,
                vertical: AppDimensions.spacing2,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppDimensions.radius8),
              ),
              child: Text(
                'HLv$level',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white,
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
