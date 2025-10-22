import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

/// XP 획득 애니메이션 위젯
/// 화면에 떠오르는 XP 획득 표시
class XPAnimationWidget extends StatefulWidget {
  final int xp;
  final Offset startPosition;
  final VoidCallback? onComplete;

  const XPAnimationWidget({
    super.key,
    required this.xp,
    required this.startPosition,
    this.onComplete,
  });

  @override
  State<XPAnimationWidget> createState() => _XPAnimationWidgetState();
}

class _XPAnimationWidgetState extends State<XPAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // 위로 올라가는 애니메이션
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: -150.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
    ));

    // 페이드 아웃
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
    ));

    // 스케일 애니메이션
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.5, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 50,
      ),
    ]).animate(_controller);

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: widget.startPosition.dx,
          top: widget.startPosition.dy + _slideAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.mathTealGradient,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.mathTeal.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '🔶',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '+${widget.xp} XP',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// XP 획득 오버레이
/// 화면 전체에 XP 획득 애니메이션 표시
class XPOverlay extends StatelessWidget {
  final int xp;
  final VoidCallback? onComplete;

  const XPOverlay({
    super.key,
    required this.xp,
    this.onComplete,
  });

  static OverlayEntry? _currentEntry;

  /// XP 획득 애니메이션 표시
  static void show(BuildContext context, int xp, {VoidCallback? onComplete}) {
    // 기존 오버레이가 있으면 제거
    _currentEntry?.remove();

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;

    if (renderBox == null) return;

    final size = renderBox.size;
    final startPosition = Offset(
      size.width / 2 - 75, // 중앙 정렬 (대략적인 위젯 너비의 절반)
      size.height / 2,
    );

    _currentEntry = OverlayEntry(
      builder: (context) => XPAnimationWidget(
        xp: xp,
        startPosition: startPosition,
        onComplete: () {
          _currentEntry?.remove();
          _currentEntry = null;
          onComplete?.call();
        },
      ),
    );

    overlay.insert(_currentEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

/// 콤보 애니메이션 (연속 정답 시)
class ComboAnimationWidget extends StatefulWidget {
  final int combo;
  final Offset position;
  final VoidCallback? onComplete;

  const ComboAnimationWidget({
    super.key,
    required this.combo,
    required this.position,
    this.onComplete,
  });

  @override
  State<ComboAnimationWidget> createState() => _ComboAnimationWidgetState();
}

class _ComboAnimationWidgetState extends State<ComboAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.5)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.5, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 40,
      ),
    ]).animate(_controller);

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
    ));

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: widget.position.dx,
          top: widget.position.dy,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Column(
                children: [
                  Text(
                    '🔥',
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.combo}x COMBO!',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.mathOrange,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
