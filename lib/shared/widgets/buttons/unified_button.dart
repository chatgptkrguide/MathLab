import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_dimensions.dart';
import '../../utils/haptic_feedback.dart';

/// 통합 애니메이션 버튼
///
/// AnimatedButton, DuolingoButton, PrimaryButton을 통합한 범용 버튼 위젯
/// - 듀오링고 스타일 3D 효과
/// - 부드러운 누르기 애니메이션
/// - Haptic 피드백
/// - 로딩 상태 지원
/// - 아이콘 지원
class UnifiedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final bool isLoading;
  final Color backgroundColor;
  final Color? shadowColor;
  final Color textColor;
  final IconData? icon;
  final double? width;
  final double? height;
  final Duration animationDuration;
  final bool enableAnimation;
  final bool enableHaptic;

  const UnifiedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isEnabled = true,
    this.isLoading = false,
    this.backgroundColor = AppColors.mathButtonBlue,
    this.shadowColor,
    this.textColor = AppColors.surface,
    this.icon,
    this.width,
    this.height,
    this.animationDuration = const Duration(milliseconds: 150),
    this.enableAnimation = true,
    this.enableHaptic = true,
  });

  /// 기본 버튼 (애니메이션 O, Haptic O)
  factory UnifiedButton.primary({
    required String text,
    VoidCallback? onPressed,
    bool isEnabled = true,
    bool isLoading = false,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    double? width,
    double? height,
  }) {
    return UnifiedButton(
      text: text,
      onPressed: onPressed,
      isEnabled: isEnabled,
      isLoading: isLoading,
      backgroundColor: backgroundColor ?? AppColors.mathButtonBlue,
      textColor: textColor ?? AppColors.surface,
      icon: icon,
      width: width,
      height: height,
    );
  }

  /// 정적 버튼 (애니메이션 X, Haptic X)
  factory UnifiedButton.static({
    required String text,
    VoidCallback? onPressed,
    bool isEnabled = true,
    bool isLoading = false,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    double? width,
    double? height,
  }) {
    return UnifiedButton(
      text: text,
      onPressed: onPressed,
      isEnabled: isEnabled,
      isLoading: isLoading,
      backgroundColor: backgroundColor ?? AppColors.mathButtonBlue,
      textColor: textColor ?? AppColors.surface,
      icon: icon,
      width: width,
      height: height,
      enableAnimation: false,
      enableHaptic: false,
    );
  }

  @override
  State<UnifiedButton> createState() => _UnifiedButtonState();
}

class _UnifiedButtonState extends State<UnifiedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // 스케일 애니메이션 (누르기 효과)
    _scaleController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  Color get _effectiveShadowColor {
    if (widget.shadowColor != null) return widget.shadowColor!;
    return _getDarkerColor(widget.backgroundColor);
  }

  Color _getDarkerColor(Color color) {
    // GoMath 브랜드 색상 매핑 (20% darker for 3D shadow)
    if (color == AppColors.mathButtonBlue) return AppColors.mathButtonBlueDark;
    if (color == AppColors.mathTeal) return AppColors.mathTealDark;
    if (color == AppColors.mathOrange) return AppColors.mathOrangeDark;
    if (color == AppColors.mathRed) return AppColors.mathRedDark;
    if (color == AppColors.mathPurple) return AppColors.mathPurpleDark;
    if (color == AppColors.successGreen) return AppColors.mathGreenDark;
    if (color == AppColors.mathBlue) return AppColors.mathBlueDark;

    // Default: darken by 20%
    return Color.fromARGB(
      (color.a * 255.0).round() & 0xff,
      (((color.r * 255.0).round() & 0xff) * 0.8).round(),
      (((color.g * 255.0).round() & 0xff) * 0.8).round(),
      (((color.b * 255.0).round() & 0xff) * 0.8).round(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.isEnabled && !widget.isLoading && widget.onPressed != null;

    Widget buttonContent = Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? 60,
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
                  color: _effectiveShadowColor,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          // Main button
          Container(
            decoration: BoxDecoration(
              color: enabled ? widget.backgroundColor : AppColors.borderLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: enabled
                    ? _effectiveShadowColor
                    : AppColors.borderLight.withOpacity(0.8),
                width: 3,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: enabled ? _handleTap : null,
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

    // 애니메이션 적용 여부
    if (widget.enableAnimation) {
      final contentToAnimate = buttonContent;
      buttonContent = Semantics(
        button: true,
        enabled: enabled,
        label: widget.text,
        onTap: enabled ? _handleTap : null,
        child: GestureDetector(
          onTapDown: enabled ? (_) => _onTapDown() : null,
          onTapUp: enabled ? (_) => _onTapUp() : null,
          onTapCancel: enabled ? _onTapCancel : null,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: contentToAnimate,
          ),
        ),
      );
    } else {
      buttonContent = Semantics(
        button: true,
        enabled: enabled,
        label: widget.text,
        onTap: enabled ? _handleTap : null,
        child: buttonContent,
      );
    }

    return buttonContent;
  }

  Widget _buildButtonContent() {
    if (widget.isLoading) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: AppDimensions.iconM,
            height: AppDimensions.iconM,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(widget.textColor),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingS),
          Text(
            '잠시만요...',
            style: AppTextStyles.buttonText.copyWith(
              color: widget.textColor,
            ),
          ),
        ],
      );
    }

    if (widget.icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.icon,
            color: widget.textColor,
            size: AppDimensions.iconM,
          ),
          const SizedBox(width: AppDimensions.spacingS),
          Text(
            widget.text,
            style: AppTextStyles.buttonText.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: widget.textColor,
            ),
          ),
        ],
      );
    }

    return Text(
      widget.text,
      style: AppTextStyles.buttonText.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: widget.textColor,
      ),
    );
  }

  void _onTapDown() async {
    if (widget.enableAnimation) {
      await _scaleController.forward();
    }
    if (widget.enableHaptic) {
      await AppHapticFeedback.lightImpact();
    }
  }

  void _onTapUp() async {
    if (widget.enableAnimation) {
      await _scaleController.reverse();
    }
  }

  void _onTapCancel() async {
    if (widget.enableAnimation) {
      await _scaleController.reverse();
    }
  }

  void _handleTap() async {
    if (widget.enableHaptic) {
      await AppHapticFeedback.selectionClick();
    }
    widget.onPressed?.call();
  }
}
