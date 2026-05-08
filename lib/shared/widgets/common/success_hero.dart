import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// 성공·축하 모멘트의 공통 hero 아이콘.
/// 다이얼로그 / 완료 화면 / 보상 알림 등에서 동일한 시각 언어를 제공한다.
///
/// - 그라데이션 원형 배경 + accent 색상 그림자
/// - 큰 흰 아이콘 (size의 55%)
class SuccessHero extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const SuccessHero({
    super.key,
    this.icon = Icons.celebration_rounded,
    this.color = AppColors.mathGreen,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withValues(alpha: 0.85),
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: size * 0.55,
      ),
    );
  }
}
