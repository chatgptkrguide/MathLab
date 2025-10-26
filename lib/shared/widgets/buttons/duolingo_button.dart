import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_dimensions.dart';
import '../../utils/haptic_feedback.dart';

/// 듀오링고 스타일 3D 효과 버튼
class DuolingoButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final Color backgroundColor;
  final Color shadowColor;
  final IconData? icon;
  final double? width;
  final double? height;

  const DuolingoButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isEnabled = true,
    this.backgroundColor = AppColors.mathButtonBlue, // GoMath 버튼 색상
    this.shadowColor = AppColors.mathButtonBlueDark, // 어두운 변형
    this.icon,
    this.width,
    this.height,
  });

  @override
  State<DuolingoButton> createState() => _DuolingoButtonState();
}

class _DuolingoButtonState extends State<DuolingoButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pressAnimation;
  // ignore: unused_field
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _pressAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.isEnabled && widget.onPressed != null;

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.text,
      child: GestureDetector(
        onTapDown: enabled ? (_) => _onTapDown() : null,
        onTapUp: enabled ? (_) => _onTapUp() : null,
        onTapCancel: enabled ? _onTapCancel : null,
        child: AnimatedBuilder(
        animation: _pressAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pressAnimation.value,
            child: Container(
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
                          color: widget.shadowColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  // Main button
                  Container(
                    decoration: BoxDecoration(
                      color: enabled ? widget.backgroundColor : AppColors.borderLight, // GoMath disabled gray
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: enabled ? widget.shadowColor : AppColors.borderLight.withValues(alpha: 0.8), // Darker border
                        width: 3,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: enabled ? widget.onPressed : null,
                        borderRadius: BorderRadius.circular(16),
                        child: Center(
                          child: _buildButtonContent(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (widget.icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.icon,
            color: AppColors.surface,
            size: AppDimensions.iconM,
          ),
          const SizedBox(width: AppDimensions.spacingS),
          Text(
            widget.text,
            style: AppTextStyles.buttonText.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.surface,
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
        color: AppColors.surface,
      ),
    );
  }

  void _onTapDown() async {
    setState(() {
      _isPressed = true;
    });
    await _animationController.forward();
    await AppHapticFeedback.lightImpact();
  }

  void _onTapUp() async {
    await _animationController.reverse();
    setState(() {
      _isPressed = false;
    });
  }

  void _onTapCancel() async {
    await _animationController.reverse();
    setState(() {
      _isPressed = false;
    });
  }
}