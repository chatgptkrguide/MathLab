import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_dimensions.dart';
import '../utils/haptic_feedback.dart';

/// 부드러운 애니메이션이 적용된 버튼
/// 듀오링고 스타일의 3D 효과 + 마이크로 인터렉션
class AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final List<Color> gradientColors;
  final IconData? icon;
  final double? width;
  final double? height;
  final Duration animationDuration;

  const AnimatedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isEnabled = true,
    this.gradientColors = AppColors.greenGradient,
    this.icon,
    this.width,
    this.height,
    this.animationDuration = const Duration(milliseconds: 150),
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _shimmerController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;

  bool _isPressed = false;

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

    // 쉬머 애니메이션 (반짝임 효과)
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    // 주기적 쉬머 효과
    _startPeriodicShimmer();
  }

  void _startPeriodicShimmer() {
    // 쉬머 효과는 필요할 때만 실행 (성능 최적화)
    // 비활성화하여 배터리 소모 방지
    // 필요시 onHover 등으로 활성화 가능
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.isEnabled && widget.onPressed != null;

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.text,
      onTap: enabled ? _handleTap : null,
      child: GestureDetector(
        onTapDown: enabled ? (_) => _onTapDown() : null,
        onTapUp: enabled ? (_) => _onTapUp() : null,
        onTapCancel: enabled ? _onTapCancel : null,
        child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _shimmerAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
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
                  // 3D 바닥 그림자 (깊이감)
                  BoxShadow(
                    color: enabled
                        ? widget.gradientColors[1].withValues(alpha: _isPressed ? 0.6 : 0.4)
                        : AppColors.disabled.withValues(alpha: 0.3),
                    offset: Offset(0, _isPressed ? 3 : 6),
                    blurRadius: 0,
                    spreadRadius: 0,
                  ),
                  // 부드러운 확산 그림자
                  BoxShadow(
                    color: enabled
                        ? widget.gradientColors[1].withValues(alpha: 0.2)
                        : AppColors.disabled.withValues(alpha: 0.1),
                    offset: const Offset(0, 8),
                    blurRadius: 16,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // 메인 버튼
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: enabled
                            ? widget.gradientColors
                            : [AppColors.disabled, AppColors.disabled.withValues(alpha: 0.8)],
                      ),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusXXL),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: enabled ? _handleTap : null,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusXXL),
                        child: Center(
                          child: _buildButtonContent(),
                        ),
                      ),
                    ),
                  ),
                  // 쉬머 효과 (활성화된 버튼만)
                  if (enabled)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusXXL),
                        child: AnimatedBuilder(
                          animation: _shimmerAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(
                                (widget.width ?? 300) * _shimmerAnimation.value,
                                0,
                              ),
                              child: Container(
                                width: 100,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.white.withValues(alpha: 0.3),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 0.5, 1.0],
                                  ),
                                ),
                              ),
                            );
                          },
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

  void _onTapDown() async {
    setState(() => _isPressed = true);
    await _scaleController.forward();
    await AppHapticFeedback.lightImpact();
  }

  void _onTapUp() async {
    await _scaleController.reverse();
    setState(() => _isPressed = false);
  }

  void _onTapCancel() async {
    await _scaleController.reverse();
    setState(() => _isPressed = false);
  }

  void _handleTap() async {
    await AppHapticFeedback.selectionClick();
    widget.onPressed?.call();
  }
}