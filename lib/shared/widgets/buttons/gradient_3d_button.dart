import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';

/// 듀오링고 스타일 3D 그라디언트 버튼
///
/// 눌렀을 때 3D 효과와 햅틱 피드백을 제공하는 재사용 가능한 버튼
/// - 홈 화면 시작 버튼
/// - 레벨 테스트 버튼
/// - 챌린지 참여 버튼
class Gradient3DButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final List<Color> gradientColors;
  final List<Color> gradientColorsPressed;
  final Color shadowColor;
  final Color borderColor;
  final double height;
  final double? width;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double shadowHeight;
  final bool enableHaptic;

  const Gradient3DButton({
    super.key,
    required this.child,
    required this.onPressed,
    required this.gradientColors,
    required this.gradientColorsPressed,
    required this.shadowColor,
    this.borderColor = Colors.white,
    this.height = 56,
    this.width,
    this.margin,
    this.borderRadius,
    this.shadowHeight = 4,
    this.enableHaptic = true,
  });

  /// 프리셋: Green 듀오링고 스타일 버튼
  factory Gradient3DButton.green({
    Key? key,
    required Widget child,
    required VoidCallback onPressed,
    double height = 56,
    double? width,
    EdgeInsetsGeometry? margin,
    bool enableHaptic = true,
  }) {
    return Gradient3DButton(
      key: key,
      onPressed: onPressed,
      gradientColors: const [Color(0xFF58CC02), Color(0xFF46A302)],
      gradientColorsPressed: const [Color(0xFF46A302), Color(0xFF3A8502)],
      shadowColor: const Color(0xFF46A302),
      borderColor: const Color(0xFF70D820),
      height: height,
      width: width,
      margin: margin,
      enableHaptic: enableHaptic,
      child: child,
    );
  }

  /// 프리셋: Blue 버튼
  factory Gradient3DButton.blue({
    Key? key,
    required Widget child,
    required VoidCallback onPressed,
    double height = 56,
    double? width,
    EdgeInsetsGeometry? margin,
    bool enableHaptic = true,
  }) {
    return Gradient3DButton(
      key: key,
      onPressed: onPressed,
      gradientColors: AppColors.blueGradient,
      gradientColorsPressed: [
        AppColors.blueGradient[1],
        AppColors.blueGradient[1].withOpacity(0.8),
      ],
      shadowColor: AppColors.blueGradient[1],
      borderColor: AppColors.blueGradient[0],
      height: height,
      width: width,
      margin: margin,
      enableHaptic: enableHaptic,
      child: child,
    );
  }

  /// 프리셋: Gold 버튼
  factory Gradient3DButton.gold({
    Key? key,
    required Widget child,
    required VoidCallback onPressed,
    double height = 56,
    double? width,
    EdgeInsetsGeometry? margin,
    bool enableHaptic = true,
  }) {
    return Gradient3DButton(
      key: key,
      onPressed: onPressed,
      gradientColors: AppColors.goldGradient,
      gradientColorsPressed: [
        AppColors.goldGradient[1],
        AppColors.goldGradient[1].withOpacity(0.8),
      ],
      shadowColor: AppColors.goldGradient[1],
      borderColor: AppColors.goldGradient[0],
      height: height,
      width: width,
      margin: margin,
      enableHaptic: enableHaptic,
      child: child,
    );
  }

  @override
  State<Gradient3DButton> createState() => _Gradient3DButtonState();
}

class _Gradient3DButtonState extends State<Gradient3DButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
    if (widget.enableHaptic) {
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTap() {
    if (widget.enableHaptic) {
      HapticFeedback.mediumImpact();
    }
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: widget.margin,
          width: widget.width ?? double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
            boxShadow: [
              // 하단 어두운 그림자 (3D 효과)
              BoxShadow(
                color: widget.shadowColor,
                offset: Offset(0, _isPressed ? widget.shadowHeight / 2 : widget.shadowHeight),
                blurRadius: 0,
                spreadRadius: 0,
              ),
              // 주변 부드러운 그림자
              BoxShadow(
                color: widget.gradientColors[0].withOpacity(_isPressed ? 0.3 : 0.4),
                blurRadius: _isPressed ? 8 : 12,
                offset: Offset(0, _isPressed ? 3 : 6),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isPressed
                    ? widget.gradientColorsPressed
                    : widget.gradientColors,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
              border: Border.all(
                color: widget.borderColor,
                width: 2,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 상단 하이라이트 (3D 효과)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(_isPressed ? 0.1 : 0.3),
                          Colors.white.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(
                          (widget.borderRadius ?? BorderRadius.circular(16))
                              .topLeft
                              .x -
                              2,
                        ),
                        topRight: Radius.circular(
                          (widget.borderRadius ?? BorderRadius.circular(16))
                              .topRight
                              .x -
                              2,
                        ),
                      ),
                    ),
                  ),
                ),
                // 버튼 내용
                widget.child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
