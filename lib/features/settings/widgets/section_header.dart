import 'package:flutter/material.dart';

import '../../../shared/constants/constants.dart';

/// 설정 화면 섹션 헤더
/// - 섹션 구분을 위한 타이틀 표시
class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLarge,
        vertical: AppDimensions.paddingSmall,
      ),
      child: Text(
        title,
        style: AppTextStyles.titleSmall.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
