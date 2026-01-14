import 'package:flutter/material.dart';

/// 듀오링고 스타일 학습 경로 연결선 그리기
class LearningPathPainter extends CustomPainter {
  final int lessonCount;

  LearningPathPainter(this.lessonCount);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFBDBDBD).withValues(alpha: 0.5)
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
        controlPoint1X,
        controlPoint1Y,
        controlPoint2X,
        controlPoint2Y,
        endX,
        endY,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
