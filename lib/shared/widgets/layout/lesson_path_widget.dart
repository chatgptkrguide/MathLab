import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';

/// 듀오링고 스타일 레슨 경로 위젯
/// S자 형태로 레슨들이 배치됨
class LessonPathWidget extends StatelessWidget {
  final List<LessonNode> lessons;
  final Function(LessonNode) onLessonTap;

  const LessonPathWidget({
    super.key,
    required this.lessons,
    required this.onLessonTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF7F7F7), // 듀오링고 스타일 밝은 회색 배경
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingXL, // 더 넓은 패딩으로 가운데 정렬
            vertical: AppDimensions.paddingXXL,
          ),
          child: Column(
            children: List.generate(lessons.length, (index) {
              final lesson = lessons[index];
              // 듀오링고 스타일: 왼쪽-중앙-오른쪽-중앙 패턴
              final position = index % 4;
              final isLeft = position == 0;
              final isRight = position == 2;
              final isCenter = position == 1 || position == 3;

              return Column(
                children: [
                  // 레슨 노드
                  _buildLessonNode(lesson, isLeft, isCenter, isRight),

                  // 연결 경로 (마지막 레슨 제외)
                  if (index < lessons.length - 1)
                    _buildPath(isLeft, isCenter, isRight, index),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  /// 레슨 노드 빌드 (듀오링고 스타일)
  Widget _buildLessonNode(LessonNode lesson, bool isLeft, bool isCenter, bool isRight) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Align(
        alignment: isLeft
            ? Alignment.centerLeft
            : isRight
                ? Alignment.centerRight
                : Alignment.center,
        child: GestureDetector(
          onTap: lesson.isLocked ? null : () => onLessonTap(lesson),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 듀오링고 스타일 3D 그림자 (solid shadow)
              if (!lesson.isLocked)
                Positioned(
                  top: 6,
                  left: 0,
                  right: 0,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: _getDarkerColor(lesson),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

              // 메인 버튼
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: _getColor(lesson),
                  shape: BoxShape.circle,
                  border: lesson.isCompleted
                      ? Border.all(color: Colors.white, width: 4)
                      : null,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 메인 아이콘/이모지
                    Text(
                      lesson.emoji,
                      style: TextStyle(
                        fontSize: lesson.isLocked ? 36 : 44,
                        shadows: lesson.isLocked
                            ? []
                            : [
                                const Shadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                      ),
                    ),

                    // 잠금 아이콘
                    if (lesson.isLocked)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),

                    // 완료 체크마크 (듀오링고 스타일 - 골드 크라운)
                    if (lesson.isCompleted && !lesson.isLocked)
                      Positioned(
                        right: -4,
                        bottom: -4,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700), // 골드
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.stars_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),

                    // 별 표시 (현재 레슨)
                    if (lesson.isCurrent && !lesson.isLocked && !lesson.isCompleted)
                      Positioned(
                        top: -8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700), // 골드
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.star_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 경로 연결선 빌드 (듀오링고 스타일 - 점선)
  Widget _buildPath(bool isLeft, bool isCenter, bool isRight, int index) {
    final nextPosition = (index + 1) % 4;
    final nextIsLeft = nextPosition == 0;
    final nextIsRight = nextPosition == 2;
    final nextIsCenter = nextPosition == 1 || nextPosition == 3;

    return SizedBox(
      height: 40,
      child: CustomPaint(
        size: const Size(double.infinity, 40),
        painter: DuolingoPathPainter(
          isLeft: isLeft,
          isCenter: isCenter,
          isRight: isRight,
          nextIsLeft: nextIsLeft,
          nextIsCenter: nextIsCenter,
          nextIsRight: nextIsRight,
        ),
      ),
    );
  }

  /// 듀오링고 스타일 플랫 색상
  Color _getColor(LessonNode lesson) {
    if (lesson.isLocked) return const Color(0xFFE5E5E5); // 밝은 회색
    if (lesson.isCompleted) return const Color(0xFF58CC02); // 듀오링고 그린
    if (lesson.isCurrent) return const Color(0xFF1CB0F6); // 듀오링고 블루

    // 다양한 파스텔 색상들 (듀오링고 스타일)
    final colors = [
      const Color(0xFF58CC02), // 그린
      const Color(0xFF1CB0F6), // 블루
      const Color(0xFFFF9600), // 오렌지
      const Color(0xFFCE82FF), // 퍼플
      const Color(0xFFFF4B4B), // 레드
      const Color(0xFF2CB8E6), // 하늘색
    ];
    return colors[lesson.lessonNumber % colors.length];
  }

  /// 3D 그림자용 더 어두운 색상
  Color _getDarkerColor(LessonNode lesson) {
    if (lesson.isCompleted) return const Color(0xFF46A302); // 어두운 그린
    if (lesson.isCurrent) return const Color(0xFF1899D6); // 어두운 블루

    final darkColors = [
      const Color(0xFF46A302), // 어두운 그린
      const Color(0xFF1899D6), // 어두운 블루
      const Color(0xFFE07B00), // 어두운 오렌지
      const Color(0xFFB568E0), // 어두운 퍼플
      const Color(0xFFE03B3B), // 어두운 레드
      const Color(0xFF23A0C6), // 어두운 하늘색
    ];
    return darkColors[lesson.lessonNumber % darkColors.length];
  }
}

/// 듀오링고 스타일 경로 연결선 (점선)
class DuolingoPathPainter extends CustomPainter {
  final bool isLeft;
  final bool isCenter;
  final bool isRight;
  final bool nextIsLeft;
  final bool nextIsCenter;
  final bool nextIsRight;

  DuolingoPathPainter({
    required this.isLeft,
    required this.isCenter,
    required this.isRight,
    required this.nextIsLeft,
    required this.nextIsCenter,
    required this.nextIsRight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 시작점 결정 (노드 중심에서 시작)
    final startX = isLeft
        ? 45.0
        : isRight
            ? size.width - 45.0
            : size.width / 2;

    // 종료점 결정
    final endX = nextIsLeft
        ? 45.0
        : nextIsRight
            ? size.width - 45.0
            : size.width / 2;

    // 듀오링고 스타일 점선 그리기
    final paint = Paint()
      ..color = const Color(0xFFD7D7D7) // 밝은 회색 점선
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // 직선이면 수직 점선, 아니면 곡선 점선
    if ((startX - endX).abs() < 5) {
      // 수직 점선
      _drawDottedLine(canvas, startX, 0, endX, size.height, paint);
    } else {
      // 곡선 점선
      _drawDottedCurve(canvas, startX, 0, endX, size.height, paint);
    }
  }

  void _drawDottedLine(Canvas canvas, double x1, double y1, double x2, double y2, Paint paint) {
    const dashLength = 8.0;
    const gapLength = 6.0;

    final path = Path()
      ..moveTo(x1, y1)
      ..lineTo(x2, y2);

    final metrics = path.computeMetrics().first;
    double distance = 0;

    while (distance < metrics.length) {
      final start = metrics.getTangentForOffset(distance);
      distance += dashLength;
      final end = metrics.getTangentForOffset(distance);

      if (start != null && end != null) {
        canvas.drawLine(start.position, end.position, paint);
      }
      distance += gapLength;
    }
  }

  void _drawDottedCurve(Canvas canvas, double x1, double y1, double x2, double y2, Paint paint) {
    const dashLength = 8.0;
    const gapLength = 6.0;

    final path = Path();
    path.moveTo(x1, y1);

    // 부드러운 베지어 곡선
    final controlX1 = (x1 + x2) / 2;
    final controlY1 = y2 / 3;
    final controlX2 = (x1 + x2) / 2;
    final controlY2 = (y2 * 2) / 3;

    path.cubicTo(controlX1, controlY1, controlX2, controlY2, x2, y2);

    final metrics = path.computeMetrics().first;
    double distance = 0;

    while (distance < metrics.length) {
      final start = metrics.getTangentForOffset(distance);
      distance += dashLength;
      final end = metrics.getTangentForOffset(distance.clamp(0, metrics.length));

      if (start != null && end != null) {
        canvas.drawLine(start.position, end.position, paint);
      }
      distance += gapLength;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 레슨 노드 데이터 모델
class LessonNode {
  final String id;
  final String title;
  final String emoji;
  final bool isLocked;
  final bool isCompleted;
  final bool isCurrent;
  final int lessonNumber;

  const LessonNode({
    required this.id,
    required this.title,
    required this.emoji,
    this.isLocked = false,
    this.isCompleted = false,
    this.isCurrent = false,
    required this.lessonNumber,
  });
}
