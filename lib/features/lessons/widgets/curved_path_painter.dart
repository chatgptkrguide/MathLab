import 'package:flutter/material.dart';

/// 듀오링고 스타일 S자 곡선 학습 경로 CustomPainter
///
/// 노드가 좌→우→좌로 지그재그 배치되며
/// Cubic Bezier 곡선으로 부드럽게 연결됨.
class CurvedPathPainter extends CustomPainter {
  final List<Offset> nodePositions;
  final int completedCount;
  final double pathProgress;
  final Color completedColor;
  final Color lockedColor;

  CurvedPathPainter({
    required this.nodePositions,
    required this.completedCount,
    this.pathProgress = 1.0,
    this.completedColor = const Color(0xFF58CC02),
    this.lockedColor = const Color(0xFFE5E5E5),
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (nodePositions.length < 2) return;

    // 미완료 경로 (점선)
    for (int i = 0; i < nodePositions.length - 1; i++) {
      if (i < completedCount) continue;
      _drawSegment(canvas, i, lockedColor, isDashed: true);
    }

    // 완료 경로 (실선 + 글로우)
    for (int i = 0; i < completedCount && i < nodePositions.length - 1; i++) {
      _drawSegment(canvas, i, completedColor, isDashed: false, withGlow: true);
    }
  }

  void _drawSegment(
    Canvas canvas,
    int index,
    Color color, {
    bool isDashed = false,
    bool withGlow = false,
  }) {
    final start = nodePositions[index];
    final end = nodePositions[index + 1];

    // S자 곡선을 위한 컨트롤 포인트 계산
    final midY = (start.dy + end.dy) / 2;
    final controlPoint1 = Offset(start.dx, midY);
    final controlPoint2 = Offset(end.dx, midY);

    final path = Path();
    path.moveTo(start.dx, start.dy);
    path.cubicTo(
      controlPoint1.dx,
      controlPoint1.dy,
      controlPoint2.dx,
      controlPoint2.dy,
      end.dx,
      end.dy,
    );

    if (withGlow) {
      // 글로우 효과
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..strokeWidth = 16
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawPath(path, glowPaint);
    }

    if (isDashed) {
      _drawDashedPath(canvas, path, color);
    } else {
      final paint = Paint()
        ..color = color
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(path, paint);
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      const dashLength = 10.0;
      const gapLength = 8.0;
      bool draw = true;

      while (distance < metric.length) {
        final length = draw ? dashLength : gapLength;
        if (draw) {
          final segment = metric.extractPath(
            distance,
            (distance + length).clamp(0, metric.length),
          );
          canvas.drawPath(segment, paint);
        }
        distance += length;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CurvedPathPainter oldDelegate) {
    return oldDelegate.completedCount != completedCount ||
        oldDelegate.nodePositions != nodePositions ||
        oldDelegate.pathProgress != pathProgress;
  }
}

/// 노드 좌표를 듀오링고 스타일 S자 곡선으로 계산
class PathLayoutCalculator {
  /// 지그재그 패턴으로 노드 위치 생성 (좌-중-우-중-좌 반복)
  static List<Offset> calculateNodePositions({
    required int nodeCount,
    required double width,
    double startY = 80,
    double verticalSpacing = 130,
    double? amplitude,
  }) {
    final amp = amplitude ?? (width * 0.25);
    final centerX = width / 2;
    final positions = <Offset>[];

    for (int i = 0; i < nodeCount; i++) {
      // 지그재그 패턴: 왼쪽 → 오른쪽 → 왼쪽 → 오른쪽
      double xOffset;
      switch (i % 4) {
        case 0:
          xOffset = -amp * 0.3; // 약간 왼쪽
          break;
        case 1:
          xOffset = amp; // 오른쪽
          break;
        case 2:
          xOffset = -amp * 0.3; // 약간 왼쪽
          break;
        case 3:
          xOffset = amp; // 오른쪽
          break;
        default:
          xOffset = 0;
      }

      // 첫 번째 노드는 중앙에
      if (i == 0) xOffset = 0;

      final x = centerX + xOffset;
      final y = startY + (i * verticalSpacing);
      positions.add(Offset(x, y));
    }

    return positions;
  }
}
