import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/drawers/top_slide_drawer.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../data/providers/user/user_provider.dart';
import '../../../data/providers/learning/lesson_progress_provider.dart';
import '../../../data/providers/assessment/level_skip_provider.dart';
import '../../../data/providers/learning/problem_provider.dart';
import '../../../data/services/korean_math_curriculum.dart';
import '../../problem/problem_screen.dart';
import '../../level_skip/level_skip_test_screen.dart';
import 'widgets/widgets.dart';

/// Figma 디자인 "01" 학습 페이지 100% 재현
/// 레퍼런스: assets/images/figma_01_lessons_reference.png
class LessonsScreenFigma extends ConsumerWidget {
  const LessonsScreenFigma({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final displayGrade = user?.currentGrade ?? '중1';
    final currentLessonIndex =
        ref.watch(currentLessonIndexProvider(displayGrade));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFF5F5F5), // 밝은 회색 배경
        child: SafeArea(
          child: Column(
            children: [
              // 상단 바 (학습 제목 + 메뉴 버튼)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: AppColors.headerBlueGradient,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu,
                          color: AppColors.headerText, size: 28),
                      onPressed: () {
                        _showGradeSelectionDrawer(context, ref);
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '학습',
                            style: AppTextStyles.headlineMedium.copyWith(
                              color: AppColors.headerText,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.headerText.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              displayGrade,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.headerText,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48), // 대칭을 위한 빈 공간
                  ],
                ),
              ),

              // Quick Action Buttons (Practice & Level Test)
              const QuickActionButtons(),

              const SizedBox(height: 12),

              // 듀오링고 스타일 학습 경로 (지그재그)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 20, bottom: 100),
                  child: _buildLearningPath(context, ref, currentLessonIndex),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 듀오링고 스타일 학습 경로 (지그재그 레이아웃)
  Widget _buildLearningPath(
      BuildContext context, WidgetRef ref, int currentLessonIndex) {
    final screenWidth = MediaQuery.of(context).size.width;
    final user = ref.watch(userProvider);
    final displayGrade = user?.currentGrade ?? '중1';

    // 현재 학년에 따른 한국 수학 교육과정 데이터 가져오기
    final curriculumLessons =
        KoreanMathCurriculum.getLessonsByGrade(displayGrade);

    // 레슨 데이터를 UI 형식으로 변환
    final lessons = curriculumLessons.asMap().entries.map((entry) {
      final index = entry.key;
      final lesson = entry.value;

      return {
        'image': 'assets/images/${_getLessonImage(index)}.png',
        'label': lesson.title,
        'isLocked': index > currentLessonIndex, // 현재 인덱스 이후는 잠금
        'lessonId': lesson.id,
        'isCompleted': index < currentLessonIndex, // 현재 인덱스 이전은 완료
        'icon': lesson.icon,
      };
    }).toList();

    return Stack(
      children: [
        // 연결선 (점선 경로)
        CustomPaint(
          size: Size(screenWidth, lessons.length * 200.0),
          painter: LearningPathPainter(lessons.length),
        ),

        // 레슨 카드들
        Column(
          children: List.generate(lessons.length, (index) {
            final lesson = lessons[index];
            // 지그재그 패턴: 짝수는 왼쪽, 홀수는 오른쪽
            final isLeft = index % 2 == 0;

            return Container(
              margin: EdgeInsets.only(
                top: index == 0 ? 0 : 48,
                bottom: index == lessons.length - 1 ? 0 : 0,
              ),
              child: Align(
                alignment:
                    isLeft ? Alignment.centerLeft : Alignment.centerRight,
                child: Container(
                  margin: EdgeInsets.only(
                      left: isLeft ? 24 : 0, right: isLeft ? 0 : 24),
                  child: LessonCard(
                    image: lesson['image'] as String,
                    label: lesson['label'] as String,
                    isLocked: lesson['isLocked'] as bool,
                    isCurrent: index == currentLessonIndex,
                    isCompleted: lesson['isCompleted'] as bool,
                    height: 160,
                    onTap: () => _navigateToProblems(
                        context, ref, lesson['lessonId'] as String?),
                    onLongPress: () => _showLessonOptions(
                      context,
                      ref,
                      lesson['lessonId'] as String?,
                      lesson['label'] as String,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  /// 레슨 인덱스에 따른 이미지 파일명 반환
  String _getLessonImage(int index) {
    final images = [
      'book_pencil',
      'book',
      'rulers',
      'bag',
      'clock',
      'winner',
      'laptop',
      'globe',
      'blackboard',
      'microscope',
    ];
    return images[index % images.length];
  }

  /// 문제 풀이 화면으로 네비게이션
  Future<void> _navigateToProblems(
      BuildContext context, WidgetRef ref, String? lessonId) async {
    if (lessonId == null) return;

    // 문제 데이터 가져오기
    final problems =
        ref.read(problemProvider.notifier).getProblemsByLesson(lessonId);

    // 문제가 없는 경우 경고 표시
    if (problems.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('아직 준비된 문제가 없습니다.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    // 문제 풀이 화면으로 이동
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProblemScreen(
            lessonId: lessonId,
            problems: problems,
          ),
        ),
      );
    }
  }

  /// 학년/단원 선택 drawer 표시
  void _showGradeSelectionDrawer(BuildContext context, WidgetRef ref) {
    TopSlideDrawer.show(
      context,
      GradeSelectionDrawer(
        currentGrade: ref.read(userProvider)?.currentGrade ?? '중1',
      ),
    );
  }

  /// 레슨 옵션 표시 (레벨 스킵 테스트 등)
  void _showLessonOptions(
    BuildContext context,
    WidgetRef ref,
    String? lessonId,
    String lessonTitle,
  ) {
    if (lessonId == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 타이틀
            Text(
              lessonTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),

            // 레벨 스킵 테스트 옵션
            ListTile(
              leading: const Icon(Icons.flash_on,
                  color: AppColors.warning, size: 32),
              title: const Text(
                '레벨 스킵 테스트',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: const Text(
                '80% 이상 맞추면 레슨을 건너뛸 수 있습니다',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _startSkipTest(context, ref, lessonId, lessonTitle);
              },
            ),

            const Divider(),

            // 일반 학습 옵션
            ListTile(
              leading: const Icon(Icons.play_arrow,
                  color: AppColors.primary, size: 32),
              title: const Text(
                '일반 학습 시작',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _navigateToProblems(context, ref, lessonId);
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// 레벨 스킵 테스트 시작
  Future<void> _startSkipTest(
    BuildContext context,
    WidgetRef ref,
    String lessonId,
    String lessonTitle,
  ) async {
    try {
      // 로딩 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // 테스트 생성
      final actions = ref.read(skipTestActionsProvider);
      final test = await actions.createTest(
        lessonId: lessonId,
        lessonTitle: lessonTitle,
      );

      // 로딩 닫기
      if (context.mounted) {
        Navigator.pop(context);
      }

      // 테스트 화면으로 이동
      if (test != null && context.mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LevelSkipTestScreen(testId: test.id),
          ),
        );
      }
    } catch (e) {
      // 로딩 닫기
      if (context.mounted) {
        Navigator.pop(context);
      }

      // 에러 표시
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('테스트 생성 실패: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
