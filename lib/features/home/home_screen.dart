import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/constants.dart';
import '../../shared/utils/utils.dart';
import '../../shared/widgets/duolingo_card.dart';
import '../../shared/widgets/duolingo_circular_progress.dart';
import '../../shared/widgets/responsive_wrapper.dart';
import '../../shared/widgets/animated_button.dart';
import '../../shared/widgets/loading_widgets.dart';
import '../../shared/utils/haptic_feedback.dart';
import '../../data/models/models.dart';
import '../../data/providers/user_provider.dart';
import '../../data/providers/problem_provider.dart';
import '../problem/problem_screen.dart';

/// 듀오링고 스타일 홈 화면
/// 완전한 듀오링고 UI/UX 적용
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final problems = ref.watch(problemProvider);

    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.mathBlue,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: AppColors.mathBlueGradient,
            ),
          ),
          child: const Center(
            child: DuolingoLoadingIndicator(
              message: '수학 학습을 준비하고 있어요...',
              size: 80,
              color: AppColors.mathYellow,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.mathBlue, // GoMath 파란 배경
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.mathBlueGradient, // Figma 디자인 그라디언트
          ),
        ),
        child: SafeArea(
          child: ResponsiveWrapper(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildHeader(user),
                  const SizedBox(height: AppDimensions.spacingXXL),
                  _buildLevelProgress(user),
                  const SizedBox(height: AppDimensions.spacingXXL),
                  _buildDailyGoal(user),
                  const SizedBox(height: AppDimensions.spacingXL),
                  _buildStartButton(context, ref, problems),
                  const SizedBox(height: AppDimensions.spacingXL),
                  _buildQuickStats(user),
                  const SizedBox(height: AppDimensions.spacingXXL),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 듀오링고 스타일 헤더
  Widget _buildHeader(User user) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 사용자 정보
          Flexible(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '안녕하세요! 👋',
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXS),
                Text(
                  '${user.name}님의 수학 학습',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          // 스트릭 표시
          Flexible(
            child: _buildStreakDisplay(user.streakDays),
          ),
        ],
      ),
    );
  }

  /// 스트릭 표시 (GoMath 스타일)
  Widget _buildStreakDisplay(int streakDays) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.orangeGradient,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.mathOrange.withValues(alpha: 0.3),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '🔥',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: AppDimensions.spacingXS),
          Text(
            '$streakDays',
            style: AppTextStyles.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// GoMath 스타일 레벨 진행률
  Widget _buildLevelProgress(User user) {
    final levelProgress = user.levelProgress;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingXL),
      child: Column(
        children: [
          // 큰 원형 진행률
          DuolingoCircularProgress(
            progress: levelProgress,
            level: user.level,
            emoji: '🧮', // 수학 이모지
            size: 120,
            progressColor: AppColors.mathYellow,
          ),
          const SizedBox(height: AppDimensions.spacingL),
          // 레벨 정보
          Text(
            '레벨 ${user.level}',
            style: AppTextStyles.headlineLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            '다음 레벨까지 ${user.xpToNextLevel} XP',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  /// 일일 목표 (듀오링고 스타일)
  Widget _buildDailyGoal(User user) {
    const targetXP = 100;
    final currentXP = user.xp.remainder(targetXP);

    return DuolingoCard(
      gradientColors: const [Colors.white, Color(0xFFF8F9FA)],
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.greenGradient,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Center(
                  child: Text('🎯', style: TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '오늘의 목표',
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingXS),
                    Text(
                      '$currentXP / $targetXP XP',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingL),
          // GoMath 스타일 진행률 바 (틸색)
          Container(
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.progressBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (currentXP / targetXP).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.mathTealGradient,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.mathTeal.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
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

  /// 메인 학습 시작 버튼 (GoMath 스타일 - 진한 파란색)
  Widget _buildStartButton(BuildContext context, WidgetRef ref, List<Problem> problems) {
    return AnimatedButton(
      text: '학습 시작하기',
      onPressed: () async {
        await AppHapticFeedback.mediumImpact();
        _startLearning(context, ref, problems);
      },
      gradientColors: AppColors.mathButtonGradient,
      icon: Icons.play_arrow,
      height: 64,
      animationDuration: const Duration(milliseconds: 150),
    );
  }

  /// 빠른 통계 (GoMath 스타일 - 반응형)
  Widget _buildQuickStats(User user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 작은 화면에서는 세로 방향으로 배치
          final isSmallScreen = constraints.maxWidth < 400;
          final spacing = isSmallScreen
              ? AppDimensions.spacingS
              : AppDimensions.spacingM;

          if (isSmallScreen) {
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DuolingoStatCard(
                        emoji: '🔶',
                        title: 'XP',
                        value: user.xp.toString(),
                        iconColor: AppColors.mathOrange,
                      ),
                    ),
                    SizedBox(width: spacing),
                    Expanded(
                      child: DuolingoStatCard(
                        emoji: '⭐',
                        title: '레벨',
                        value: user.level.toString(),
                        iconColor: AppColors.mathYellow,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: spacing),
                SizedBox(
                  width: double.infinity,
                  child: DuolingoStatCard(
                    emoji: '🔥',
                    title: '연속',
                    value: '${user.streakDays}일',
                    iconColor: AppColors.mathOrange,
                  ),
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: DuolingoStatCard(
                  emoji: '🔶',
                  title: 'XP',
                  value: user.xp.toString(),
                  iconColor: AppColors.mathOrange,
                ),
              ),
              SizedBox(width: spacing),
              Expanded(
                child: DuolingoStatCard(
                  emoji: '⭐',
                  title: '레벨',
                  value: user.level.toString(),
                  iconColor: AppColors.mathYellow,
                ),
              ),
              SizedBox(width: spacing),
              Expanded(
                child: DuolingoStatCard(
                  emoji: '🔥',
                  title: '연속',
                  value: '${user.streakDays}일',
                  iconColor: AppColors.mathOrange,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // 이벤트 핸들러

  void _startLearning(BuildContext context, WidgetRef ref, List<Problem> problems) async {
    Logger.ui('학습하기 버튼 클릭', screen: 'HomeScreen', action: 'StartLearning');

    if (problems.isEmpty) {
      Logger.warning('문제 데이터 없음', tag: 'HomeScreen');
      _showCustomSnackBar(context, '문제 데이터를 로드하는 중입니다...', AppColors.duolingoOrange);
      return;
    }

    final user = ref.read(userProvider);
    if (user == null) {
      Logger.error('사용자 데이터 없음', tag: 'HomeScreen');
      return;
    }

    Logger.info(
      '사용자: ${user.name} (레벨: ${user.level})',
      tag: 'HomeScreen',
    );

    final recommendedProblems = ref
        .read(problemProvider.notifier)
        .getRecommendedProblems(user.level, count: GameConstants.recommendedProblemCount);

    List<Problem> selectedProblems;
    String lessonId;

    if (recommendedProblems.isEmpty) {
      Logger.debug('기본 레슨 사용', tag: 'HomeScreen');
      final lesson1Problems = ref
          .read(problemProvider.notifier)
          .getProblemsByLesson(GameConstants.defaultLessonId);
      selectedProblems = lesson1Problems.take(GameConstants.recommendedProblemCount).toList();
      lessonId = GameConstants.defaultLessonId;
    } else {
      selectedProblems = recommendedProblems;
      lessonId = 'recommended';
    }

    if (selectedProblems.isEmpty) {
      Logger.error('선택된 문제 없음', tag: 'HomeScreen');
      _showCustomSnackBar(context, '문제를 찾을 수 없습니다.', AppColors.duolingoRed);
      return;
    }

    Logger.info('문제 ${selectedProblems.length}개 선택 완료', tag: 'HomeScreen');

    try {
      // 햅틱 피드백
      await AppHapticFeedback.success();

      // 학습 화면으로 이동
      final route = MaterialPageRoute(
        builder: (context) => ProblemScreen(
          lessonId: lessonId,
          problems: selectedProblems,
        ),
      );

      if (context.mounted) {
        await Navigator.of(context).push(route);
        Logger.ui('학습 화면 이동 성공', screen: 'HomeScreen');
      }
    } catch (e, stackTrace) {
      Logger.error(
        '네비게이션 에러',
        error: e,
        stackTrace: stackTrace,
        tag: 'HomeScreen',
      );
      if (context.mounted) {
        _showCustomSnackBar(context, '페이지 이동 중 오류가 발생했습니다.', AppColors.duolingoRed);
      }
    }
  }

  void _showCustomSnackBar(BuildContext context, String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}