import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

/// 적응형 앱 헤더 위젯
/// 그라디언트 배경과 제목, 선택적 leading/trailing 위젯을 포함합니다
/// 설정 화면, 상세 화면 등에서 통일된 헤더 디자인을 제공합니다
class AdaptiveAppHeader extends StatelessWidget {
  final String title;
  final List<Color>? gradientColors;
  final BorderRadius? borderRadius;
  final MainAxisAlignment titleAlignment;
  final Widget? leading;
  final Widget? trailing;
  final double height;
  final EdgeInsetsGeometry padding;

  const AdaptiveAppHeader({
    super.key,
    required this.title,
    this.gradientColors,
    this.borderRadius,
    this.titleAlignment = MainAxisAlignment.start,
    this.leading,
    this.trailing,
    this.height = 80,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ?? [AppColors.mathBlue, AppColors.mathBlue];

    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: borderRadius,
      ),
      child: Padding(
        padding: padding,
        child: Row(
          mainAxisAlignment: titleAlignment,
          children: [
            if (leading != null) leading!,
            if (leading != null) const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
