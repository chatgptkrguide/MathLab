// Spotlight painter — draws dark overlay with a rounded cutout around the target.
import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';

class CoachMarkSpotlight extends AnimatedWidget {
  final Rect targetRect;
  final Animation<double> pulseAnimation;

  const CoachMarkSpotlight({
    super.key,
    required this.targetRect,
    required this.pulseAnimation,
    required AnimationController animController,
  }) : super(listenable: animController);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: MediaQuery.of(context).size,
      painter: _SpotlightPainter(
        targetRect: targetRect,
        pulse: pulseAnimation.value,
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final Rect targetRect;
  final double pulse;

  _SpotlightPainter({required this.targetRect, this.pulse = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.7);

    // Full screen path
    final fullPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Spotlight cutout (rounded rect with padding)
    final padding = 8.0 + pulse;
    final spotlightRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(
        targetRect.left - padding,
        targetRect.top - padding,
        targetRect.right + padding,
        targetRect.bottom + padding,
      ),
      const Radius.circular(12),
    );

    final cutoutPath = Path()..addRRect(spotlightRect);

    // Combine paths (full screen minus spotlight)
    final combinedPath =
        Path.combine(PathOperation.difference, fullPath, cutoutPath);

    canvas.drawPath(combinedPath, paint);

    // Draw glow border around spotlight
    final glowPaint = Paint()
      ..color = AppColors.mathBlue.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawRRect(spotlightRect, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) {
    return oldDelegate.targetRect != targetRect || oldDelegate.pulse != pulse;
  }
}
