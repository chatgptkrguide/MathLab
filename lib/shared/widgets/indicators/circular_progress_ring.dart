import 'dart:math';
import 'package:flutter/material.dart';
import '../../constants/figma_colors.dart';
import '../../constants/app_text_styles.dart';

/// Figma 디자인 원형 진행률 표시
/// 크기: 190x190 (전체학습진행상태바)
/// 순수 디자인만 구현
class CircularProgressRing extends StatelessWidget {
  final double progress;
  final String centerText;
  final String subtitle;
  final double size;
  final double strokeWidth;

  const CircularProgressRing({
    super.key,
    required this.progress,
    required this.centerText,
    this.subtitle = '',
    this.size = 190.0,
    this.strokeWidth = 15.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 배경 원
          CustomPaint(
            size: Size(size, size),
            painter: _CircularProgressPainter(
              progress: 1.0,
              color: FigmaColors.progressBackground,
              strokeWidth: strokeWidth,
            ),
          ),
          // 진행률 원
          CustomPaint(
            size: Size(size, size),
            painter: _CircularProgressPainter(
              progress: progress,
              color: FigmaColors.progressTeal,
              strokeWidth: strokeWidth,
            ),
          ),
          // 중앙 텍스트
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                centerText,
                style: AppTextStyles.displaySmall.copyWith(
                  color: FigmaColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: FigmaColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // -90도부터 시작 (12시 방향)
    const startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
