import 'package:flutter/material.dart';

import '../../../shared/constants/constants.dart';

/// 설정 항목 타일
/// - 아이콘, 제목, 부제목, 탭 핸들러를 지원
class SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final VoidCallback? onTap;

  const SettingTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.titleColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (titleColor ?? AppColors.mathBlue).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        ),
        child: Icon(
          icon,
          color: titleColor ?? AppColors.mathBlue,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          color: titleColor ?? AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: AppTextStyles.bodySmall,
            )
          : null,
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textTertiary,
        size: 24,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLarge,
        vertical: AppDimensions.paddingXSmall,
      ),
      onTap: onTap,
    );
  }
}
