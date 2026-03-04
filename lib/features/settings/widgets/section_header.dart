import 'package:flutter/material.dart';

import '../../../shared/constants/constants.dart';

/// 설정 화면 섹션 헤더
/// - Left border accent for hand-crafted feel
/// - Optional accent color per section
class SectionHeader extends StatelessWidget {
  final String title;
  final Color? accentColor;

  const SectionHeader({
    super.key,
    required this.title,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.mathBlue;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLarge,
        vertical: AppDimensions.paddingSmall,
      ),
      child: Container(
        padding: const EdgeInsets.only(left: 12, top: 2, bottom: 2),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: color,
              width: 4,
            ),
          ),
        ),
        child: Text(
          title,
          style: AppTextStyles.titleSmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }
}
