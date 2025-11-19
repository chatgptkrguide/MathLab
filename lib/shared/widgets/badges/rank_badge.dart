import 'package:flutter/material.dart';

/// 랭크 뱃지 위젯 - 피그마 디자인 "07_랭크 아이콘" 구현
/// GT (Great), H (High), A (Average) 레벨별 뱃지
class RankBadge extends StatelessWidget {
  final String rankType; // 'GT', 'H', 'A'
  final int level; // 1, 2, 3, or 0 for 레전드
  final double size;

  const RankBadge({
    super.key,
    required this.rankType,
    required this.level,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColorsForRank(rankType);
    final isLegend = level == 0;

    return Container(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _HexagonBadgePainter(
          colors: colors,
          level: level,
          isLegend: isLegend,
        ),
        child: Center(
          child: isLegend
              ? Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: size * 0.4,
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white.withOpacity(0.9),
                      size: size * 0.3,
                    ),
                    Text(
                      rankType,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size * 0.15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  List<Color> _getColorsForRank(String rank) {
    switch (rank) {
      case 'GT':
        return [
          const Color(0xFF7B1FA2), // 보라색
          const Color(0xFF9C27B0),
        ];
      case 'H':
        return [
          const Color(0xFFD84315), // 오렌지/빨강
          const Color(0xFFFF6F00),
        ];
      case 'A':
        return [
          const Color(0xFF1976D2), // 파란색
          const Color(0xFF2196F3),
        ];
      default:
        return [Colors.grey, Colors.grey.shade400];
    }
  }
}

/// 육각형 뱃지 그리기
class _HexagonBadgePainter extends CustomPainter {
  final List<Color> colors;
  final int level;
  final bool isLegend;

  _HexagonBadgePainter({
    required this.colors,
    required this.level,
    required this.isLegend,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width / 2.2;

    // 육각형 그리기
    for (int i = 0; i < 6; i++) {
      final angle = (60 * i - 30) * 3.14159 / 180;
      final x = centerX + radius * cos(angle);
      final y = centerY + radius * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);

    // 레벨 표시선 그리기 (레전드가 아닌 경우)
    if (!isLegend && level > 0) {
      final linePaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      for (int i = 0; i < level; i++) {
        final yPos = centerY - (radius * 0.3) + (i * radius * 0.25);
        canvas.drawLine(
          Offset(centerX - radius * 0.4, yPos),
          Offset(centerX + radius * 0.4, yPos),
          linePaint,
        );
      }
    }

    // 레전드 날개 그리기
    if (isLegend) {
      final wingPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.fill;

      // 왼쪽 날개
      final leftWing = Path()
        ..moveTo(centerX - radius * 0.8, centerY)
        ..lineTo(centerX - radius * 1.3, centerY - radius * 0.3)
        ..lineTo(centerX - radius * 1.2, centerY)
        ..lineTo(centerX - radius * 1.3, centerY + radius * 0.3)
        ..close();
      canvas.drawPath(leftWing, wingPaint);

      // 오른쪽 날개
      final rightWing = Path()
        ..moveTo(centerX + radius * 0.8, centerY)
        ..lineTo(centerX + radius * 1.3, centerY - radius * 0.3)
        ..lineTo(centerX + radius * 1.2, centerY)
        ..lineTo(centerX + radius * 1.3, centerY + radius * 0.3)
        ..close();
      canvas.drawPath(rightWing, wingPaint);
    }
  }

  double cos(double angle) => angle == 0 ? 1 : (angle == 3.14159 ? -1 : angle.cos);
  double sin(double angle) => angle == 0 ? 0 : (angle == 3.14159 ? 0 : angle.sin);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

extension on double {
  double get cos {
    // 간단한 cos 근사치
    final x = this;
    return 1 - (x * x) / 2 + (x * x * x * x) / 24;
  }

  double get sin {
    // 간단한 sin 근사치
    final x = this;
    return x - (x * x * x) / 6 + (x * x * x * x * x) / 120;
  }
}
