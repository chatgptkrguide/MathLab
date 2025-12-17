import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/drawers/top_slide_drawer.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../data/providers/user_provider.dart';
import '../../../data/providers/lesson_progress_provider.dart';
import '../../../data/providers/level_skip_provider.dart';
import '../../../data/providers/problem_provider.dart';
import '../../../data/services/korean_math_curriculum.dart';
import '../../practice/practice_screen.dart';
import '../../level_test/level_test_screen.dart';
import '../../problem/problem_screen.dart';
import '../../level_skip/level_skip_test_screen.dart';

/// Figma 디자인 "01" 학습 페이지 100% 재현
/// 레퍼런스: assets/images/figma_01_lessons_reference.png
class LessonsScreenFigma extends ConsumerWidget {
  const LessonsScreenFigma({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final displayGrade = user?.currentGrade ?? '중1';
    final currentLessonIndex = ref.watch(currentLessonIndexProvider(displayGrade));

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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: AppColors.headerBlueGradient,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu, color: AppColors.headerText, size: 28),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PracticeCategoryScreen(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4CAF50).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              '연습 모드',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LevelTestScreen(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF9800).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.assignment, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              '레벨 테스트',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 듀오링고 스타일 학습 경로 (지그재그)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16),
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
  Widget _buildLearningPath(BuildContext context, WidgetRef ref, int currentLessonIndex) {
    final screenWidth = MediaQuery.of(context).size.width;
    final user = ref.watch(userProvider);
    final displayGrade = user?.currentGrade ?? '중1';

    // 현재 학년에 따른 한국 수학 교육과정 데이터 가져오기
    final curriculumLessons = KoreanMathCurriculum.getLessonsByGrade(displayGrade);

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
          painter: _LearningPathPainter(lessons.length),
        ),

        // 레슨 카드들
        Column(
          children: List.generate(lessons.length, (index) {
            final lesson = lessons[index];
            // 지그재그 패턴: 짝수는 왼쪽, 홀수는 오른쪽
            final isLeft = index % 2 == 0;

            return Container(
              margin: EdgeInsets.only(
                top: index == 0 ? 0 : 40,
                bottom: index == lessons.length - 1 ? 100 : 0,
              ),
              child: Align(
                alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
                child: Container(
                  margin: EdgeInsets.only(left: isLeft ? 24 : 0, right: isLeft ? 0 : 24),
                  child: _buildLessonCard(
                    context,
                    ref,
                    image: lesson['image'] as String,
                    label: lesson['label'] as String,
                    isLocked: lesson['isLocked'] as bool,
                    isCurrent: index == currentLessonIndex,
                    isCompleted: lesson['isCompleted'] as bool,
                    height: 160,
                    lessonId: lesson['lessonId'] as String?,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  /// 레슨 카드
  Widget _buildLessonCard(
    BuildContext context,
    WidgetRef ref, {
    required String image,
    required String label,
    required bool isLocked,
    required bool isCurrent,
    required bool isCompleted,
    required double height,
    String? lessonId,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.38;

    return GestureDetector(
      onTap: !isLocked && lessonId != null ? () => _navigateToProblems(context, ref, lessonId) : null,
      onLongPress: !isLocked && lessonId != null && !isCompleted
          ? () => _showLessonOptions(context, ref, lessonId, label)
          : null,
      child: Container(
      width: cardWidth,
      height: height,
      decoration: BoxDecoration(
        color: isLocked
            ? const Color(0xFFD8E7F3) // 잠긴 카드는 밝은 파란색
            : isCompleted
                ? const Color(0xFF4CAF50) // 완료된 카드는 초록색
                : const Color(0xFF4A90E2), // 활성 카드는 진한 파란색
        borderRadius: BorderRadius.circular(20),
        border: isCurrent && !isLocked
            ? Border.all(
                color: const Color(0xFFFFD700), // 현재 진행중은 금색 테두리
                width: 4,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: isCurrent && !isLocked
                ? const Color(0xFFFFD700).withOpacity(0.5)
                : Colors.black.withOpacity(0.1),
            blurRadius: isCurrent && !isLocked ? 20 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 이미지
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Image.asset(
                image,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.book,
                    size: 60,
                    color: isLocked
                        ? Colors.grey.shade400
                        : Colors.white.withOpacity(0.7),
                  );
                },
              ),
            ),
          ),

          // 라벨 (제거됨 - 요청사항)

          // 잠금 오버레이
          if (isLocked)
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Icon(
                  Icons.lock,
                  size: 36,
                  color: Colors.white,
                ),
              ),
            ),

          // 완료 체크 표시
          if (isCompleted && !isLocked)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check,
                  size: 20,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ),

          // 현재 진행중 표시
          if (isCurrent && !isLocked && !isCompleted)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  '진행중',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
    );
  }

  /// 레슨 인덱스에 따른 이미지 파일명 반환
  String _getLessonImage(int index) {
    final images = [
      'book_pencil', 'book', 'rulers', 'bag', 'clock',
      'winner', 'laptop', 'globe', 'blackboard', 'microscope',
    ];
    return images[index % images.length];
  }

  /// 문제 풀이 화면으로 네비게이션
  Future<void> _navigateToProblems(BuildContext context, WidgetRef ref, String lessonId) async {
    // 현재 학년의 교육과정 데이터 가져오기
    final user = ref.read(userProvider);
    final displayGrade = user?.currentGrade ?? '중1';
    final curriculumLessons = KoreanMathCurriculum.getLessonsByGrade(displayGrade);

    // 문제 데이터 가져오기
    final problems = ref.read(problemProvider.notifier).getProblemsByLesson(lessonId);

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
      _GradeSelectionDrawer(
        currentGrade: ref.read(userProvider)?.currentGrade ?? '중1',
      ),
    );
  }

  /// 레슨 옵션 표시 (레벨 스킵 테스트 등)
  void _showLessonOptions(
    BuildContext context,
    WidgetRef ref,
    String lessonId,
    String lessonTitle,
  ) {
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
              leading: const Icon(Icons.flash_on, color: AppColors.warning, size: 32),
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
              leading: const Icon(Icons.play_arrow, color: AppColors.primary, size: 32),
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

/// 학년/단원 선택 Drawer
class _GradeSelectionDrawer extends ConsumerWidget {
  final String currentGrade;

  const _GradeSelectionDrawer({required this.currentGrade});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 학교급별로 학년 그룹화
    final elementaryGrades = ['초1', '초2', '초3', '초4', '초5', '초6'];
    final middleGrades = ['중1', '중2', '중3'];
    final highGrades = ['고1', '고2', '고3'];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '학년 선택',
                    style: AppTextStyles.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 현재 학년 표시
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.mathBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.mathBlue, width: 2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.school, color: AppColors.mathBlue, size: 24),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '현재 학년',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          currentGrade,
                          style: AppTextStyles.headlineSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.mathBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 초등학교 섹션
              _buildSchoolSection(
                context: context,
                ref: ref,
                title: '🎒 초등학교',
                grades: elementaryGrades,
                currentGrade: currentGrade,
                color: const Color(0xFF4CAF50),
              ),

              const SizedBox(height: 20),

              // 중학교 섹션
              _buildSchoolSection(
                context: context,
                ref: ref,
                title: '📚 중학교',
                grades: middleGrades,
                currentGrade: currentGrade,
                color: const Color(0xFF2196F3),
              ),

              const SizedBox(height: 20),

              // 고등학교 섹션
              _buildSchoolSection(
                context: context,
                ref: ref,
                title: '🎓 고등학교',
                grades: highGrades,
                currentGrade: currentGrade,
                color: const Color(0xFF9C27B0),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// 학교급별 섹션 위젯
  Widget _buildSchoolSection({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required List<String> grades,
    required String currentGrade,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 12),
        // 3열 그리드 레이아웃
        LayoutBuilder(
          builder: (context, constraints) {
            // 전체 너비에서 간격을 제외한 버튼 영역 계산
            final totalWidth = constraints.maxWidth;
            final spacing = 12.0;
            final buttonWidth = (totalWidth - (spacing * 2)) / 3;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: grades.map((grade) {
                final isSelected = grade == currentGrade;
                return SizedBox(
                  width: buttonWidth,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        // 학년 변경
                        await ref.read(userProvider.notifier).updateCurrentGrade(grade);

                        if (context.mounted) {
                          Navigator.pop(context);

                          // 성공 스낵바 표시
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$grade 학년으로 변경되었습니다'),
                              backgroundColor: AppColors.success,
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: isSelected ? color : AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? color : AppColors.borderLight,
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          grade,
                          style: AppTextStyles.titleMedium.copyWith(
                            color: isSelected
                                ? AppColors.surface
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

/// 듀오링고 스타일 학습 경로 연결선 그리기
class _LearningPathPainter extends CustomPainter {
  final int lessonCount;

  _LearningPathPainter(this.lessonCount);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFBDBDBD).withOpacity(0.5)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final cardWidth = size.width * 0.38;
    final leftX = 24 + cardWidth / 2;
    final rightX = size.width - 24 - cardWidth / 2;
    final verticalSpacing = 200.0;

    // 시작점 (첫 번째 카드 중앙)
    path.moveTo(leftX, 80);

    for (int i = 0; i < lessonCount - 1; i++) {
      final startY = 80 + (i * verticalSpacing);
      final endY = 80 + ((i + 1) * verticalSpacing);
      final startX = i % 2 == 0 ? leftX : rightX;
      final endX = (i + 1) % 2 == 0 ? leftX : rightX;

      // 곡선 경로 (베지어 곡선)
      final controlPoint1X = startX;
      final controlPoint1Y = startY + (endY - startY) * 0.3;
      final controlPoint2X = endX;
      final controlPoint2Y = startY + (endY - startY) * 0.7;

      path.cubicTo(
        controlPoint1X, controlPoint1Y,
        controlPoint2X, controlPoint2Y,
        endX, endY,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
