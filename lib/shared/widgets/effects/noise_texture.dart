import 'dart:math';
import 'package:flutter/material.dart';

/// Subtle grain/noise texture overlay.
///
/// Adds organic, hand-crafted feel to backgrounds by rendering
/// semi-transparent dots in a pseudo-random pattern.
/// Use as a Stack overlay with low opacity for best results.
class NoiseTexture extends StatelessWidget {
  final double opacity;
  final Color color;

  const NoiseTexture({
    super.key,
    this.opacity = 0.03,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: CustomPaint(
          painter: _NoisePainter(color: color),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _NoisePainter extends CustomPainter {
  final Color color;

  _NoisePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42); // Fixed seed for consistent pattern
    final paint = Paint()..color = color;
    final dotCount = (size.width * size.height / 120).toInt().clamp(0, 8000);

    for (var i = 0; i < dotCount; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 0.8 + 0.2;
      paint.color = color.withValues(alpha: random.nextDouble() * 0.6 + 0.2);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _NoisePainter oldDelegate) =>
      oldDelegate.color != color;
}
