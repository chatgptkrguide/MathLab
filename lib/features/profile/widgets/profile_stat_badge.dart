import 'package:flutter/material.dart';
import '../../../shared/constants/constants.dart';

/// 프로필 상단 통계 뱃지
class ProfileStatBadge extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const ProfileStatBadge({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 듀오링고 스타일: 아이콘을 컨테이너로 감싸서 강조
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.mathYellow,
              size: 24, // 20 → 24
            ),
          ),
          const SizedBox(height: 6), // 4 → 6
          Text(
            value,
            style: const TextStyle(
              color: AppColors.surface,
              fontWeight: FontWeight.bold,
              fontSize: 22, // 18 → 22 (듀오링고 스타일: 더 크게)
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 3), // 2 → 3
          Text(
            label,
            style: const TextStyle(
              color: AppColors.surface,
              fontSize: 12, // 11 → 12
              fontWeight: FontWeight.w600, // w500 → w600
            ),
          ),
        ],
      ),
    );
  }
}
