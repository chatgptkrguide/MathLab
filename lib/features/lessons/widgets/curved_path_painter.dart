import 'dart:math';
import 'package:flutter/material.dart';

/// 듀오링고 스타일 S자 곡선 학습 경로 CustomPainter
///
/// 노드가 좌→우→좌로 지그재그 배치되며
/// QuadraticBezier 곡선으로 부드럽게 연결됨.
/// [pathProgress] 0.0~1.0 으로 완료 경로가 점진적으로 그려짐.
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
    this.lockedColor = const Color(0xFFD0D0D0),
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (nodePositions.length < 2) return;

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
    // 미완료 경로를 먼저 (아래 레이어)
    for (int i = 0; i < positions.length - 1; i++) {
      final isCompleted = i < completed;
      if (isCompleted) continue;

      final start = positions[i];
      final end = positions[i + 1];
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
      _drawDashedPath(canvas, path, inactiveColor);
    }

    // 완료 경로 (위 레이어) - pathProgress 로 부분 렌더링
    if (completed > 0) {
      final completedPath = Path();
      for (int i = 0; i < completed && i < positions.length - 1; i++) {
        final start = positions[i];
        final end = positions[i + 1];
        final controlPoint = Offset(
          (start.dx + end.dx) / 2,
          (start.dy + end.dy) / 2,
        );

        if (i == 0) {
          completedPath.moveTo(start.dx, start.dy);
        }
        completedPath.quadraticBezierTo(
          controlPoint.dx + (end.dx - start.dx) * 0.1,
          controlPoint.dy,
          end.dx,
          end.dy,
        );
      }

      final paint = Paint()
        ..color = activeColor
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      if (pathProgress >= 1.0) {
        canvas.drawPath(completedPath, paint);
      } else {
        // 부분 경로 렌더링
        for (final metric in completedPath.computeMetrics()) {
          final extractLen = metric.length * pathProgress.clamp(0.0, 1.0);
          if (extractLen > 0) {
            final partial = metric.extractPath(0, extractLen);
            canvas.drawPath(partial, paint);
          }
        }
      }

      // 완료 경로 글로우
      final glowPaint = Paint()
        ..color = activeColor.withValues(alpha: 0.25)
        ..strokeWidth = 14
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      if (pathProgress >= 1.0) {
        canvas.drawPath(completedPath, glowPaint);
      } else {
        for (final metric in completedPath.computeMetrics()) {
          final extractLen = metric.length * pathProgress.clamp(0.0, 1.0);
          if (extractLen > 0) {
            final partial = metric.extractPath(0, extractLen);
            canvas.drawPath(partial, glowPaint);
          }
        }
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
        oldDelegate.nodePositions != nodePositions ||
        oldDelegate.pathProgress != pathProgress;
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
