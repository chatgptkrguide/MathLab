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
import '../problem/problem_screen.dart';

/// 듀오링고 스타일 홈 화면
/// S자 곡선 레슨 경로 적용
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
      backgroundColor: AppColors.background, // GoMath 배경색
      body: Column(
        children: [
          _buildHeader(user),
          Expanded(
            child: LessonPathWidget(
              lessons: _generateLessons(user),
              onLessonTap: (lesson) => _handleLessonTap(context, ref, lesson, problems),
            ),
          ),
        ],
      ),
    );
  }

  /// 듀오링고 스타일 헤더 (더 깔끔하게 개선)
  Widget _buildHeader(User user) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: AppColors.borderLight.withValues(alpha: 0.3),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // 프로필 아바타
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
                // 스트릭 & 하트
                _buildDuoStatBadge('🔥', '${user.streakDays}', AppColors.mathOrange),
                const SizedBox(width: AppDimensions.spacingS),
                _buildDuoStatBadge('❤️', '${user.hearts}', AppColors.mathRed),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingM),
            // XP 진행률 바
            _buildDuoProgressBar(user),
          ],
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
        const SizedBox(height: 6),
        // 듀오링고 스타일 진행률 바
        Stack(
          children: [
            // 배경 바
            Container(
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            // 진행 바 (GoMath 틸 색상)
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.05, 1.0),
              child: Container(
                height: 14,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.mathTeal, AppColors.mathTealDark],
                  ),
                  borderRadius: BorderRadius.circular(10),
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
          ],
        ),
      ],
    );
  }

  /// 샘플 레슨 데이터 생성 (추후 실제 데이터로 교체)
  List<LessonNode> _generateLessons(User user) {
    final currentLevel = user.level;

    return List.generate(20, (index) {
      final lessonNumber = index + 1;
      final isLocked = lessonNumber > currentLevel + 2;
      final isCompleted = lessonNumber < currentLevel;
      final isCurrent = lessonNumber == currentLevel || lessonNumber == currentLevel + 1;

      return LessonNode(
        id: 'lesson_$lessonNumber',
        title: '레슨 $lessonNumber',
        emoji: _getLessonEmoji(lessonNumber),
        isLocked: isLocked,
        isCompleted: isCompleted,
        isCurrent: isCurrent && !isCompleted,
        lessonNumber: lessonNumber,
      );
    });
  }

  String _getLessonEmoji(int lessonNumber) {
    const emojis = [
      '🔢', '➕', '➖', '✖️', '➗',
      '📐', '📏', '📊', '📈', '🎯',
      '🧮', '💡', '⭐', '🏆', '🎓',
      '🔶', '🔷', '🔺', '🔻', '⬛',
    ];
    return emojis[lessonNumber % emojis.length];
  }

  void _handleLessonTap(
    BuildContext context,
    WidgetRef ref,
    LessonNode lesson,
    List<Problem> problems,
  ) async {
    if (lesson.isLocked) {
      await AppHapticFeedback.error();
      _showCustomSnackBar(
        context,
        '이전 레슨을 먼저 완료해주세요',
        AppColors.duolingoOrange,
      );
      return;
    }

    await AppHapticFeedback.mediumImpact();
    _startLearning(context, ref, lesson, problems);
  }

  void _startLearning(
    BuildContext context,
    WidgetRef ref,
    LessonNode lesson,
    List<Problem> problems,
  ) async {
    Logger.ui('레슨 시작', screen: 'HomeScreen', action: 'StartLesson');

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

    // lesson001의 모든 문제 가져오기 (3개)
    final selectedProblems = ref
        .read(problemProvider.notifier)
        .getProblemsByLesson('lesson001');

    final lessonId = 'lesson001';

    if (selectedProblems.isEmpty) {
      Logger.error('선택된 문제 없음', tag: 'HomeScreen');
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
