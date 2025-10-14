import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_dimensions.dart';

/// 듀오링고 스타일 3D 효과 버튼
class DuolingoButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final List<Color> gradientColors;
  final IconData? icon;
  final double? width;
  final double? height;

  const DuolingoButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isEnabled = true,
    this.gradientColors = AppColors.greenGradient,
    this.icon,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  State<DuolingoButton> createState() => _DuolingoButtonState();
}

class _DuolingoButtonState extends State<DuolingoButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pressAnimation;
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

    return GestureDetector(
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
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimensions.radiusXXL),
                boxShadow: [
                  // 3D 바닥 그림자 (더 명확한 깊이감)
                  BoxShadow(
                    color: widget.gradientColors[1].withOpacity(0.6),
                    offset: const Offset(0, 8),
                    blurRadius: 0,
                    spreadRadius: 0,
                  ),
                  // 부드러운 확산 그림자
                  BoxShadow(
                    color: widget.gradientColors[1].withOpacity(0.3),
                    offset: const Offset(0, 12),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: enabled
                        ? widget.gradientColors
                        : [AppColors.disabled, AppColors.disabled],
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXXL),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: enabled ? widget.onPressed : null,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusXXL),
                    child: Center(
                      child: _buildButtonContent(),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
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
            color: Colors.white,
            size: AppDimensions.iconM,
          ),
          const SizedBox(width: AppDimensions.spacingS),
          Text(
            widget.text,
            style: AppTextStyles.buttonText.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
        color: Colors.white,
      ),
    );
  }

  void _onTapDown() {
    setState(() {
      _isPressed = true;
    });
    _animationController.forward();
  }

  void _onTapUp() {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }
}