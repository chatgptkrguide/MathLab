import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

/// 듀오링고 스타일 원형 진행률 표시
class DuolingoCircularProgress extends StatefulWidget {
  final double progress; // 0.0 - 1.0
  final int level;
  final String? emoji;
  final double size;
  final Color? progressColor;
  final VoidCallback? onTap;

  const DuolingoCircularProgress({
    super.key,
    required this.progress,
    required this.level,
    this.emoji,
    this.size = 80.0,
    this.progressColor,
    this.onTap,
  });

  @override
  State<DuolingoCircularProgress> createState() => _DuolingoCircularProgressState();
}

class _DuolingoCircularProgressState extends State<DuolingoCircularProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: widget.progress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(DuolingoCircularProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.progress,
        end: widget.progress,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return CustomPaint(
              painter: DuolingoProgressPainter(
                progress: _progressAnimation.value,
                progressColor: widget.progressColor ?? AppColors.duolingoGreen,
                backgroundColor: AppColors.progressBackground,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.emoji != null)
                      Text(
                        widget.emoji!,
                        style: TextStyle(fontSize: widget.size * 0.25),
                      ),
                    Text(
                      widget.level.toString(),
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: widget.size * 0.2,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 듀오링고 스타일 원형 진행률 페인터
class DuolingoProgressPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;

  DuolingoProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    // 배경 원
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // 진행률 원 (듀오링고 스타일 그라디언트)
    if (progress > 0) {
      final progressPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            progressColor.withValues(alpha: 0.8),
            progressColor,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, // 12시 방향부터 시작
        sweepAngle,
        false,
        progressPaint,
      );

      // 진행률 끝점에 작은 원점 추가 (듀오링고 스타일)
      if (progress < 1.0) {
        final endAngle = -math.pi / 2 + sweepAngle;
        final endPoint = Offset(
          center.dx + radius * math.cos(endAngle),
          center.dy + radius * math.sin(endAngle),
        );

        final dotPaint = Paint()
          ..color = progressColor
          ..style = PaintingStyle.fill;

        canvas.drawCircle(endPoint, 6, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(DuolingoProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.progressColor != progressColor ||
           oldDelegate.backgroundColor != backgroundColor;
  }
}