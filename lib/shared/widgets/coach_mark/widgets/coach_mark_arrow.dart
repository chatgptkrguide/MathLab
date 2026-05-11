// Coach mark arrow — small triangular pointer connecting tooltip card to its target.
import 'package:flutter/material.dart';

class CoachMarkArrow extends StatelessWidget {
  final Rect targetRect;
  final bool isAbove;

  const CoachMarkArrow({
    super.key,
    required this.targetRect,
    required this.isAbove,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Calculate arrow horizontal position relative to tooltip
    final arrowX = (targetRect.center.dx - 24).clamp(20.0, screenWidth - 68);

    return Padding(
      padding: EdgeInsets.only(left: arrowX - 24),
      child: CustomPaint(
        size: const Size(24, 12),
        painter: _ArrowPainter(isAbove: isAbove),
      ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  final bool isAbove;

  _ArrowPainter({required this.isAbove});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    if (isAbove) {
      // Arrow pointing down (tooltip is above)
      path.moveTo(0, 0);
      path.lineTo(size.width / 2, size.height);
      path.lineTo(size.width, 0);
    } else {
      // Arrow pointing up (tooltip is below)
      path.moveTo(0, size.height);
      path.lineTo(size.width / 2, 0);
      path.lineTo(size.width, size.height);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
