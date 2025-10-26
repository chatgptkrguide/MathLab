import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_dimensions.dart';

/// 주요 액션 버튼 위젯
/// "학습 시작하기" 같은 주요 CTA 버튼에 사용
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double? height;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isEnabled = true,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = isEnabled && !isLoading && onPressed != null;
    final btnBackgroundColor = backgroundColor ?? AppColors.mathButtonBlue; // GoMath 주 버튼 색상
    final btnShadowColor = _getDarkerColor(btnBackgroundColor);

    return Container(
      width: width ?? double.infinity,
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: AppDimensions.paddingS,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Duolingo 3D solid shadow
          if (enabled)
            Positioned(
              top: 6,
              left: 0,
              right: 0,
              bottom: -6,
              child: Container(
                decoration: BoxDecoration(
                  color: btnShadowColor,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          // Main button
          Container(
            height: height ?? AppDimensions.buttonHeightL,
            decoration: BoxDecoration(
              color: enabled ? btnBackgroundColor : AppColors.borderLight, // GoMath disabled gray
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: enabled ? btnShadowColor : AppColors.borderLight.withValues(alpha: 0.8), // Darker border
                width: 3,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: enabled ? onPressed : null,
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingL,
                      vertical: AppDimensions.paddingM,
                    ),
                    child: _buildButtonContent(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getDarkerColor(Color color) {
    // GoMath 브랜드 색상 매핑 (20% darker for 3D shadow)
    if (color == AppColors.mathButtonBlue) return AppColors.mathButtonBlueDark; // Button Blue Dark
    if (color == AppColors.mathTeal) return AppColors.mathTealDark; // Teal Dark
    if (color == AppColors.mathOrange) return AppColors.mathOrangeDark; // Orange Dark
    if (color == AppColors.mathRed) return AppColors.mathRedDark; // Red Dark
    if (color == AppColors.mathPurple) return AppColors.mathPurpleDark; // Purple Dark
    if (color == AppColors.successGreen) return AppColors.duolingoGreenDark; // Success Green Dark
    if (color == AppColors.mathBlue) return AppColors.mathBlueDark; // Math Blue Dark

    // Default: darken by 20%
    return Color.fromARGB(
      (color.a * 255.0).round() & 0xff,
      (((color.r * 255.0).round() & 0xff) * 0.8).round(),
      (((color.g * 255.0).round() & 0xff) * 0.8).round(),
      (((color.b * 255.0).round() & 0xff) * 0.8).round(),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: AppDimensions.iconM,
            height: AppDimensions.iconM,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(AppColors.surface),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingS),
          Text(
            '잠시만요...',
            style: AppTextStyles.buttonText,
          ),
        ],
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: AppDimensions.iconM,
          ),
          const SizedBox(width: AppDimensions.spacingS),
          Text(
            text,
            style: AppTextStyles.buttonText,
          ),
        ],
      );
    }

    return Text(
      text,
      style: const TextStyle(
        color: AppColors.surface,
        fontWeight: FontWeight.bold,
        fontSize: 17,
      ),
    );
  }
}