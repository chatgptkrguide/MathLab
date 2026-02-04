import 'dart:math';
import 'package:flutter/material.dart';
import '../../../shared/constants/figma_colors.dart';

/// 듀오링고 스타일 S자 곡선 학습 경로 CustomPainter
///
/// 노드가 좌→우→좌로 지그재그 배치되며
/// QuadraticBezier 곡선으로 부드럽게 연결됨.
class CurvedPathPainter extends CustomPainter {
  final List<Offset> nodePositions;
  final int completedCount;
  final Color completedColor;
  final Color lockedColor;

  CurvedPathPainter({
    required this.nodePositions,
    required this.completedCount,
    this.completedColor = const Color(0xFF58CC02),
    this.lockedColor = const Color(0xFFD0D0D0),
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (nodePositions.length < 2) return;

    // 완료된 경로 그리기
    _drawPath(
      canvas,
      nodePositions,
      completedCount,
      completedColor,
      lockedColor,
    );
  }

  void _drawPath(
    Canvas canvas,
    List<Offset> positions,
    int completed,
    Color activeColor,
    Color inactiveColor,
  ) {
    for (int i = 0; i < positions.length - 1; i++) {
      final isCompleted = i < completed;
      final start = positions[i];
      final end = positions[i + 1];

      // 곡선의 제어점 계산
      final controlPoint = Offset(
        (start.dx + end.dx) / 2,
        (start.dy + end.dy) / 2,
      );

      final path = Path();
      path.moveTo(start.dx, start.dy);
      path.quadraticBezierTo(
        controlPoint.dx + (end.dx - start.dx) * 0.1,
        controlPoint.dy,
        end.dx,
        end.dy,
      );

      if (isCompleted) {
        // 완료된 경로 - 실선
        final paint = Paint()
          ..color = activeColor
          ..strokeWidth = 6
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
        canvas.drawPath(path, paint);
      } else {
        // 미완료 경로 - 점선
        _drawDashedPath(canvas, path, inactiveColor);
      }
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
      while (distance < metric.length) {
        final segment = metric.extractPath(distance, min(distance + 8, metric.length));
        canvas.drawPath(segment, paint);
        distance += 16; // 8px dash + 8px gap
      }
    }
  }

  @override
  bool shouldRepaint(covariant CurvedPathPainter oldDelegate) {
    return oldDelegate.completedCount != completedCount ||
        oldDelegate.nodePositions != nodePositions;
  }
}

/// 노드 좌표를 S자 곡선으로 계산하는 유틸리티
class PathLayoutCalculator {
  /// 주어진 노드 수에 대해 S자 지그재그 좌표를 생성
  ///
  /// [nodeCount] - 노드 수
  /// [width] - 전체 너비
  /// [startY] - 시작 Y 좌표
  /// [verticalSpacing] - 노드 간 수직 간격
  /// [amplitude] - 좌우 흔들림 크기 (중심으로부터의 거리)
  static List<Offset> calculateNodePositions({
    required int nodeCount,
    required double width,
    double startY = 60,
    double verticalSpacing = 140,
    double? amplitude,
  }) {
    final amp = amplitude ?? (width * 0.22);
    final centerX = width / 2;
    final positions = <Offset>[];

    for (int i = 0; i < nodeCount; i++) {
      // sin 곡선으로 좌우 배치 (좌→우→좌 반복)
      final xOffset = sin(i * pi / 2) * amp;
      final x = centerX + xOffset;
      final y = startY + (i * verticalSpacing);
      positions.add(Offset(x, y));
    }

    return positions;
  }
}
