import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../shared/constants/app_dimensions.dart';
import '../../shared/widgets/layout/responsive_wrapper.dart';
import '../../shared/widgets/animations/animations.dart';
import '../../shared/widgets/cards/lesson_card.dart';
import '../../shared/utils/page_transitions.dart';
import '../../data/models/models.dart';
import '../../data/providers/user_provider.dart';
import '../../data/providers/lesson_provider.dart';
import '../../data/providers/problem_provider.dart';
import '../problem/problem_screen.dart';

/// 학습 레슨 화면 (완전히 데이터 기반으로 재구성)
/// 실제 레슨 데이터를 카테고리별로 표시
class LessonsScreen extends ConsumerWidget {
  const LessonsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final lessons = ref.watch(lessonProvider);

    // 카테고리별로 레슨 그룹화
    final lessonsByCategory = _groupLessonsByCategory(lessons);

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
        child: SafeArea(
          child: ResponsiveWrapper(
            child: Column(
              children: [
                _buildHeader(),
                _buildUserStats(
                  userName: user?.name ?? '학습자',
                  streakDays: user?.streakDays ?? 0,
                  xp: user?.xp ?? 0,
                  level: user?.level ?? 1,
                ),
                const SizedBox(height: AppDimensions.spacingL),
                Expanded(
                  child: lessons.isEmpty
                      ? _buildEmptyState()
                      : _buildLessonsList(context, ref, lessonsByCategory),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 헤더 (간소화)
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: AppDimensions.paddingM,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 학습 경로 텍스트
          Text(
            '학습 경로',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.surface,
              fontWeight: FontWeight.bold,
            ),
          ),
          // GoMath 로고
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'GoMATH',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.mathButtonBlue,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 사용자 통계 (간소화)
  Widget _buildUserStats({
    required String userName,
    required int streakDays,
    required int xp,
    required int level,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: AppDimensions.paddingM,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 레벨
          _buildStatItem(Icons.star, 'Lv $level', AppColors.mathYellow),
          // 스트릭
          _buildStatItem(Icons.local_fire_department, '$streakDays일', AppColors.mathOrange),
          // XP
          _buildStatItem(Icons.diamond, '$xp XP', AppColors.mathTeal),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            color: AppColors.surface,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  /// 빈 상태 화면
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book,
            color: AppColors.surface.withValues(alpha: 0.5),
            size: 64,
          ),
          const SizedBox(height: AppDimensions.spacingL),
          Text(
            '아직 레슨이 없습니다',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.surface,
            ),
          ),
        ],
      ),
    );
  }

  /// 카테고리별 레슨 목록
  Widget _buildLessonsList(
    BuildContext context,
    WidgetRef ref,
    Map<String, List<Lesson>> lessonsByCategory,
  ) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 카테고리별로 섹션 표시
            ...lessonsByCategory.entries.map((entry) {
              final category = entry.key;
              final categoryLessons = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoryHeader(category),
                  const SizedBox(height: AppDimensions.spacingM),
                  _buildLessonGrid(context, ref, categoryLessons),
                  const SizedBox(height: AppDimensions.spacingXL),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  /// 카테고리 헤더
  Widget _buildCategoryHeader(String category) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.mathButtonGradient,
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          ),
        ),
        const SizedBox(width: AppDimensions.spacingM),
        Text(
          category,
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// 레슨 그리드
  Widget _buildLessonGrid(
    BuildContext context,
    WidgetRef ref,
    List<Lesson> lessons,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppDimensions.spacingM,
        crossAxisSpacing: AppDimensions.spacingM,
        childAspectRatio: 0.85,
      ),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        return FadeInWidget(
          delay: Duration(milliseconds: 100 * index),
          child: LessonCard(
            lesson: lesson,
            onTap: () => _onLessonTap(context, ref, lesson),
          ),
        );
      },
    );
  }

  /// 레슨 카드 탭 이벤트
  void _onLessonTap(BuildContext context, WidgetRef ref, Lesson lesson) {
    if (!lesson.isUnlocked) {
      // 잠긴 레슨
      _showLockedDialog(context);
      return;
    }

    // 해당 레슨의 문제들 가져오기
    final problems = ref
        .read(problemProvider.notifier)
        .getProblemsByLesson(lesson.id);

    if (problems.isEmpty) {
      _showNoProblemsDialog(context);
      return;
    }

    // 문제 풀이 화면으로 이동 (부드러운 전환 효과)
    Navigator.of(context).push(
      AppPageTransitions.slideAndFade(
        ProblemScreen(
          lessonId: lesson.id,
          problems: problems,
        ),
      ),
    );
  }

  /// 잠긴 레슨 다이얼로그 (개선된 디자인)
  void _showLockedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 아이콘
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.warningOrange.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline,
                  color: AppColors.warningOrange,
                  size: 32,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingL),
              // 제목
              Text(
                '잠긴 레슨',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingM),
              // 설명
              Text(
                '이전 레슨을 완료하면\n이 레슨을 시작할 수 있습니다.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.spacingL),
              // 확인 버튼
              AnimatedButton(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.mathButtonGradient,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '확인',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.surface,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 문제 없음 다이얼로그 (개선된 디자인)
  void _showNoProblemsDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 아이콘
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.mathBlue.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit_note,
                  color: AppColors.mathBlue,
                  size: 32,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingL),
              // 제목
              Text(
                '문제 준비 중',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingM),
              // 설명
              Text(
                '이 레슨의 문제가 아직 준비되지 않았습니다.\n곧 추가될 예정입니다!',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.spacingL),
              // 확인 버튼
              AnimatedButton(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.mathTeal, AppColors.mathTealDark],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '확인',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.surface,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 카테고리별로 레슨 그룹화
  Map<String, List<Lesson>> _groupLessonsByCategory(List<Lesson> lessons) {
    final Map<String, List<Lesson>> grouped = {};

    for (final lesson in lessons) {
      if (!grouped.containsKey(lesson.category)) {
        grouped[lesson.category] = [];
      }
      grouped[lesson.category]!.add(lesson);
    }

    // 각 카테고리의 레슨을 순서대로 정렬
    grouped.forEach((category, lessonList) {
      lessonList.sort((a, b) => a.order.compareTo(b.order));
    });

    return grouped;
  }
}
