import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/constants.dart';
import '../../shared/constants/game_constants.dart';
import '../../shared/utils/utils.dart';
import '../../shared/widgets/layout/lesson_path_widget.dart';
import '../../shared/widgets/indicators/loading_widgets.dart';
import '../../shared/utils/haptic_feedback.dart';
import '../../data/models/models.dart';
import '../../data/providers/user_provider.dart';
import '../../data/providers/problem_provider.dart';
import '../../data/providers/lesson_provider.dart';
import '../../data/providers/daily_challenge_provider.dart';
import '../problem/problem_screen.dart';
import '../daily_challenge/daily_challenge_screen.dart';

/// 듀오링고 스타일 홈 화면
/// S자 곡선 레슨 경로 적용
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _challengeController;
  late Animation<double> _headerFadeAnimation;
  late Animation<double> _challengeScaleAnimation;

  @override
  void initState() {
    super.initState();

    // 헤더 페이드인 애니메이션
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerController,
        curve: Curves.easeOut,
      ),
    );

    // 챌린지 버튼 스케일 애니메이션
    _challengeController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _challengeScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _challengeController,
        curve: Curves.easeInOut,
      ),
    );

    // 초기 애니메이션 시작
    _headerController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _challengeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final problems = ref.watch(problemProvider);
    final lessons = ref.watch(lessonProvider);

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
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // SliverAppBar - 스크롤 시 축소되는 헤더
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.surface,
            leading: const SizedBox.shrink(),
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeaderBackground(context, user),
            ),
          ),

          // LessonPath를 Sliver로 감싸기
          SliverToBoxAdapter(
            child: LessonPathWidget(
              lessons: _convertLessonsToNodes(lessons),
              onLessonTap: (lessonNode) => _handleLessonTap(context, ref, lessonNode, lessons, problems),
            ),
          ),
        ],
      ),
    );
  }

  /// 듀오링고 스타일 헤더 배경
  Widget _buildHeaderBackground(BuildContext context, User user) {
    final dailyChallengeState = ref.watch(dailyChallengeProvider);

    return SafeArea(
      bottom: false,
      child: FadeTransition(
        opacity: _headerFadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          decoration: const BoxDecoration(
            color: AppColors.surface,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                // 프로필 아바타 (개선: 그림자 추가)
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.mathButtonGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.mathButtonBlue.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      user.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.surface,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Level ${user.level}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // 스트릭 & 하트 (staggered animation)
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(20 * (1 - value), 0),
                        child: child,
                      ),
                    );
                  },
                  child: _buildDuoStatBadge('🔥', '${user.streakDays}', AppColors.mathOrange),
                ),
                const SizedBox(width: AppDimensions.spacingS),
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOut,
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(20 * (1 - value), 0),
                        child: child,
                      ),
                    );
                  },
                  child: _buildDuoStatBadge('❤️', '${user.hearts}', AppColors.mathRed),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingM),
            // XP 진행률 바
            _buildDuoProgressBar(user),
            const SizedBox(height: AppDimensions.paddingM),
            // Daily Challenge 버튼 with scale animation
            GestureDetector(
              onTap: () async {
                await AppHapticFeedback.lightImpact();
                await _challengeController.forward();
                await _challengeController.reverse();

                if (context.mounted) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const DailyChallengeScreen(),
                    ),
                  );
                }
              },
              child: ScaleTransition(
                scale: _challengeScaleAnimation,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingM,
                    vertical: AppDimensions.paddingS,
                  ),
                  decoration: BoxDecoration(
                    gradient: dailyChallengeState.allCompleted
                        ? const LinearGradient(colors: AppColors.goldGradient)
                        : LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.8),
                              AppColors.primary,
                            ],
                          ),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '🎯',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: AppDimensions.spacingS),
                      Text(
                        dailyChallengeState.allCompleted
                            ? '일일 챌린지 완료! 🎉'
                            : '일일 챌린지 (${dailyChallengeState.completedCount}/${dailyChallengeState.challenges.length})',
                        style: const TextStyle(
                          color: AppColors.surface,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (!dailyChallengeState.allCompleted) ...[
                        const Spacer(),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: AppColors.surface,
                          size: 14,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildDuoStatBadge(String emoji, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderLight,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDuoProgressBar(User user) {
    final progress = user.levelProgress;
    final xpNeeded = user.xpToNextLevel;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '레벨 ${user.level + 1}까지',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$xpNeeded XP',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // 듀오링고 스타일 진행률 바 with shimmer animation
        Stack(
          children: [
            // 배경 바
            Container(
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            // 진행 바 with animation (GoMath 틸 색상)
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              tween: Tween(begin: 0.0, end: progress),
              builder: (context, value, child) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: value.clamp(0.05, 1.0),
                  child: Stack(
                    children: [
                      // 진행 바 배경
                      Container(
                        height: 16,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.mathTeal, AppColors.mathTealDark],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.mathTeal.withValues(alpha: 0.4),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      // Shimmer overlay
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.easeInOut,
                        tween: Tween(begin: -1.0, end: 2.0),
                        onEnd: () {
                          // Restart animation by updating state
                        },
                        builder: (context, shimmerValue, child) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Transform.translate(
                              offset: Offset(shimmerValue * 100, 0),
                              child: Container(
                                height: 16,
                                width: 50,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      AppColors.surface.withValues(alpha: 0.3),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  /// Lesson을 LessonNode로 변환
  List<LessonNode> _convertLessonsToNodes(List<Lesson> lessons) {
    return lessons.map((lesson) {
      return LessonNode(
        id: lesson.id,
        title: lesson.title,
        emoji: lesson.icon,
        isLocked: !lesson.isUnlocked,
        isCompleted: lesson.isCompleted,
        isCurrent: lesson.isUnlocked && !lesson.isCompleted,
        lessonNumber: lesson.order,
      );
    }).toList();
  }

  void _handleLessonTap(
    BuildContext context,
    WidgetRef ref,
    LessonNode lessonNode,
    List<Lesson> lessons,
    List<Problem> problems,
  ) async {
    if (lessonNode.isLocked) {
      await AppHapticFeedback.error();
      _showCustomSnackBar(
        context,
        '이전 레슨을 먼저 완료해주세요',
        AppColors.duolingoOrange,
      );
      return;
    }

    await AppHapticFeedback.mediumImpact();

    // LessonNode에서 실제 Lesson 찾기
    final lesson = lessons.firstWhere(
      (l) => l.id == lessonNode.id,
      orElse: () => lessons.first,
    );

    _startLearning(context, ref, lesson, problems);
  }

  void _startLearning(
    BuildContext context,
    WidgetRef ref,
    Lesson lesson,
    List<Problem> problems,
  ) async {
    Logger.ui('레슨 시작: ${lesson.title}', screen: 'HomeScreen', action: 'StartLesson');

    if (problems.isEmpty) {
      Logger.warning('문제 데이터 없음', tag: 'HomeScreen');
      _showCustomSnackBar(
        context,
        '문제 데이터를 로드하는 중입니다...',
        AppColors.duolingoOrange,
      );
      return;
    }

    final user = ref.read(userProvider);
    if (user == null) {
      Logger.error('사용자 데이터 없음', tag: 'HomeScreen');
      return;
    }

    // 클릭한 레슨의 모든 문제 가져오기
    final selectedProblems = ref
        .read(problemProvider.notifier)
        .getProblemsByLesson(lesson.id);

    if (selectedProblems.isEmpty) {
      Logger.error('선택된 문제 없음: ${lesson.id}', tag: 'HomeScreen');
      _showCustomSnackBar(
        context,
        '문제를 찾을 수 없습니다.',
        AppColors.duolingoRed,
      );
      return;
    }

    Logger.info('문제 ${selectedProblems.length}개 선택 완료', tag: 'HomeScreen');

    try {
      await AppHapticFeedback.success();

      final route = MaterialPageRoute(
        builder: (context) => ProblemScreen(
          lessonId: lesson.id,
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
        _showCustomSnackBar(
          context,
          '페이지 이동 중 오류가 발생했습니다.',
          AppColors.duolingoRed,
        );
      }
    }
  }

  void _showCustomSnackBar(
    BuildContext context,
    String message,
    Color backgroundColor,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.surface,
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
