import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/constants.dart';
import '../../shared/utils/utils.dart';
import '../../shared/widgets/layout/lesson_path_widget.dart';
import '../../shared/widgets/indicators/loading_widgets.dart';
import '../../shared/widgets/animations/animations.dart';
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
  late Animation<double> _headerFadeAnimation;

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

    // 초기 애니메이션 시작
    _headerController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
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
            expandedHeight: 180,
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
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
            vertical: AppDimensions.paddingM,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                // 프로필 아바타 (간소화)
                Container(
                  width: 42,
                  height: 42,
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
                  child: _buildDuoStatBadge(Icons.local_fire_department, '${user.streakDays}', AppColors.mathOrange),
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
                  child: _buildDuoStatBadge(Icons.favorite, '${user.hearts}', AppColors.mathRed),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingM),
            // XP 진행률 바
            _buildDuoProgressBar(user),
            const SizedBox(height: AppDimensions.spacingM),
            // Daily Challenge 버튼 (간소화)
            InteractiveButton(
              onTap: () async {
                if (context.mounted) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const DailyChallengeScreen(),
                    ),
                  );
                }
              },
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingM,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: dailyChallengeState.allCompleted
                      ? const LinearGradient(colors: AppColors.goldGradient)
                      : const LinearGradient(
                          colors: [AppColors.mathTeal, AppColors.mathTealDark],
                        ),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.emoji_events, color: AppColors.surface, size: 18),
                    const SizedBox(width: AppDimensions.spacingS),
                    Text(
                      dailyChallengeState.allCompleted
                          ? '챌린지 완료! ✨'
                          : '일일 챌린지',
                      style: const TextStyle(
                        color: AppColors.surface,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildDuoStatBadge(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
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
              'Lv ${user.level}',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$xpNeeded XP',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        AnimatedProgressBar(
          progress: progress,
          height: 10,
          backgroundColor: AppColors.borderLight,
          gradient: const LinearGradient(
            colors: [AppColors.mathTeal, AppColors.mathTealDark],
          ),
          borderRadius: BorderRadius.circular(8),
          duration: const Duration(milliseconds: 600),
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
