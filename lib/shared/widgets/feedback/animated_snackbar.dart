import 'package:flutter/material.dart';
import '../../constants/app_animations.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_dimensions.dart';
import '../../utils/haptic_feedback.dart';

/// 애니메이션이 적용된 스낵바
class AnimatedSnackbar {
  /// 일반 스낵바 표시
  static void show(
    BuildContext context, {
    required String message,
    IconData? icon,
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _AnimatedSnackbarWidget(
        message: message,
        icon: icon,
        backgroundColor: backgroundColor ?? AppColors.surface,
        textColor: textColor ?? AppColors.textPrimary,
        duration: duration,
        onTap: onTap,
        onDismiss: () {
          overlayEntry.remove();
        },
      ),
    );

    overlay.insert(overlayEntry);
    AppHapticFeedback.lightImpact();
  }

  /// 성공 스낵바
  static void showSuccess(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    show(
      context,
      message: message,
      icon: Icons.check_circle,
      backgroundColor: AppColors.successGreen,
      textColor: Colors.white,
      duration: duration,
      onTap: onTap,
    );
  }

  /// 에러 스낵바
  static void showError(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
  }) {
    AppHapticFeedback.error();
    show(
      context,
      message: message,
      icon: Icons.error,
      backgroundColor: AppColors.errorRed,
      textColor: Colors.white,
      duration: duration,
      onTap: onTap,
    );
  }

  /// 경고 스낵바
  static void showWarning(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    show(
      context,
      message: message,
      icon: Icons.warning,
      backgroundColor: AppColors.warningYellow,
      textColor: AppColors.textPrimary,
      duration: duration,
      onTap: onTap,
    );
  }

  /// 정보 스낵바
  static void showInfo(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    show(
      context,
      message: message,
      icon: Icons.info,
      backgroundColor: AppColors.mathBlue,
      textColor: Colors.white,
      duration: duration,
      onTap: onTap,
    );
  }
}

/// 스낵바 위젯
class _AnimatedSnackbarWidget extends StatefulWidget {
  final String message;
  final IconData? icon;
  final Color backgroundColor;
  final Color textColor;
  final Duration duration;
  final VoidCallback? onTap;
  final VoidCallback onDismiss;

  const _AnimatedSnackbarWidget({
    required this.message,
    this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.duration,
    this.onTap,
    required this.onDismiss,
  });

  @override
  State<_AnimatedSnackbarWidget> createState() =>
      _AnimatedSnackbarWidgetState();
}

class _AnimatedSnackbarWidgetState extends State<_AnimatedSnackbarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: AppAnimations.normal,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppAnimations.spring,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();

    // 자동 닫기
    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: GestureDetector(
                  onTap: () {
                    if (widget.onTap != null) {
                      widget.onTap!();
                    }
                    _dismiss();
                  },
                  onVerticalDragUpdate: (details) {
                    if (details.delta.dy < -5) {
                      _dismiss();
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.all(AppDimensions.paddingM),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingL,
                      vertical: AppDimensions.paddingM,
                    ),
                    decoration: BoxDecoration(
                      color: widget.backgroundColor,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusL),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            color: widget.textColor,
                            size: 24,
                          ),
                          const SizedBox(width: AppDimensions.spacingM),
                        ],
                        Expanded(
                          child: Text(
                            widget.message,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: widget.textColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 토스트 메시지 (화면 하단)
class AnimatedToast {
  /// 일반 토스트 표시
  static void show(
    BuildContext context, {
    required String message,
    IconData? icon,
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 2),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _AnimatedToastWidget(
        message: message,
        icon: icon,
        backgroundColor: backgroundColor ?? AppColors.textPrimary,
        textColor: textColor ?? AppColors.surface,
        duration: duration,
        onDismiss: () {
          overlayEntry.remove();
        },
      ),
    );

    overlay.insert(overlayEntry);
    AppHapticFeedback.lightImpact();
  }

  /// XP 획득 토스트
  static void showXP(
    BuildContext context, {
    required int xp,
  }) {
    show(
      context,
      message: '+$xp XP',
      icon: Icons.star,
      backgroundColor: AppColors.mathGold,
      textColor: Colors.white,
      duration: const Duration(milliseconds: 1500),
    );
  }

  /// 하트 손실 토스트
  static void showHeartLoss(BuildContext context) {
    AppHapticFeedback.error();
    show(
      context,
      message: '하트 -1',
      icon: Icons.favorite,
      backgroundColor: AppColors.errorRed,
      textColor: Colors.white,
      duration: const Duration(milliseconds: 1500),
    );
  }

  /// 스트릭 유지 토스트
  static void showStreak(
    BuildContext context, {
    required int streak,
  }) {
    show(
      context,
      message: '$streak일 연속 학습!',
      icon: Icons.local_fire_department,
      backgroundColor: AppColors.streakOrange,
      textColor: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
}

/// 토스트 위젯
class _AnimatedToastWidget extends StatefulWidget {
  final String message;
  final IconData? icon;
  final Color backgroundColor;
  final Color textColor;
  final Duration duration;
  final VoidCallback onDismiss;

  const _AnimatedToastWidget({
    required this.message,
    this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_AnimatedToastWidget> createState() => _AnimatedToastWidgetState();
}

class _AnimatedToastWidgetState extends State<_AnimatedToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: AppAnimations.normal,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppAnimations.spring,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppAnimations.elastic,
      ),
    );

    _controller.forward();

    // 자동 닫기
    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 100,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: AppDimensions.paddingXL),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingL,
                      vertical: AppDimensions.paddingM,
                    ),
                    decoration: BoxDecoration(
                      color: widget.backgroundColor,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusXL),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            color: widget.textColor,
                            size: 24,
                          ),
                          const SizedBox(width: AppDimensions.spacingM),
                        ],
                        Text(
                          widget.message,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: widget.textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
}
