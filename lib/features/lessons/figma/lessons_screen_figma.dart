import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/figma_components/figma_user_info_bar.dart';
import '../../../shared/widgets/drawers/learning_calendar_drawer.dart';
import '../../../shared/widgets/drawers/top_slide_drawer.dart';
import '../../../shared/widgets/layout/common_app_bar.dart';
import '../../../data/providers/user_provider.dart';
import '../../../data/providers/lesson_progress_provider.dart';
import '../../../data/services/korean_math_curriculum.dart';
import '../../practice/practice_screen.dart';
import '../../level_test/level_test_screen.dart';
import '../../problems/problem_solving_screen.dart';

/// Figma 디자인 "01" 학습 페이지 100% 재현
/// 레퍼런스: assets/images/figma_01_lessons_reference.png
class LessonsScreenFigma extends ConsumerWidget {
  final String? selectedGrade;

  const LessonsScreenFigma({super.key, this.selectedGrade});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final displayGrade = selectedGrade ?? user?.currentGrade ?? '중1';
    final currentLessonIndex = ref.watch(currentLessonIndexProvider(displayGrade));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFF5F5F5), // 밝은 회색 배경
        child: Column(
          children: [
            // 상단 바 (Home 제목 + 메뉴 버튼)
            CommonAppBar(
              title: 'Home',
              leading: IconButton(
                icon: const Icon(Icons.menu, size: 28),
                onPressed: () {
                  TopSlideDrawer.show(
                    context,
                    const LearningCalendarDrawer(),
                  );
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),

          // 사용자 정보 바 (선택된 학년 표시)
          FigmaUserInfoBar(
            userName: displayGrade,
            streakDays: user?.streakDays ?? 6,
            xp: user?.xp ?? 549,
            level: 'HLv${user?.level ?? 1}',
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
              child: _buildLearningPath(context, currentLessonIndex),
            ),
          ),
          ],
        ),
      ),
    );
  }

  /// 듀오링고 스타일 학습 경로 (지그재그 레이아웃)
  Widget _buildLearningPath(BuildContext context, int currentLessonIndex) {
    final screenWidth = MediaQuery.of(context).size.width;

    // 선택된 학년에 따른 한국 수학 교육과정 데이터 가져오기
    final displayGrade = selectedGrade ?? '중1';
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
    BuildContext context, {
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
      onTap: !isLocked && lessonId != null ? () => _navigateToProblems(context, lessonId) : null,
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
  Future<void> _navigateToProblems(BuildContext context, String lessonId) async {
    // 선택된 학년의 교육과정 데이터 가져오기
    final displayGrade = selectedGrade ?? '중1';
    final curriculumLessons = KoreanMathCurriculum.getLessonsByGrade(displayGrade);

    // 레슨 타이틀 찾기
    final lesson = curriculumLessons.firstWhere(
      (lesson) => lesson.id == lessonId,
      orElse: () => curriculumLessons.first,
    );

    // 문제 풀이 화면으로 이동
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProblemSolvingScreen(
            lessonId: lessonId,
            lessonTitle: lesson.title,
          ),
        ),
      );
    }
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
