import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// 코치마크 단계 데이터
class CoachMarkStep {
  final GlobalKey targetKey;
  final String title;
  final String description;
  final ArrowDirection arrowDirection;
  final EdgeInsets tooltipOffset;
  final int? tabIndex; // null = 현재 탭 유지

  const CoachMarkStep({
    required this.targetKey,
    required this.title,
    required this.description,
    this.arrowDirection = ArrowDirection.up,
    this.tooltipOffset = EdgeInsets.zero,
    this.tabIndex,
  });
}

enum ArrowDirection { up, down, left, right }

/// 코치마크 오버레이 위젯
/// 화면을 어둡게 하고, 대상 위젯을 spotlight으로 강조하며 설명을 표시
class CoachMarkOverlay extends StatefulWidget {
  final List<CoachMarkStep> steps;
  final VoidCallback onComplete;
  final ValueChanged<int>? onTabChange;

  const CoachMarkOverlay({
    super.key,
    required this.steps,
    required this.onComplete,
    this.onTabChange,
  });

  @override
  State<CoachMarkOverlay> createState() => _CoachMarkOverlayState();
}

class _CoachMarkOverlayState extends State<CoachMarkOverlay>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _pulseAnimation = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeInOut,
      ),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < widget.steps.length - 1) {
      _animController.reset();
      final nextStep = widget.steps[_currentStep + 1];
      if (nextStep.tabIndex != null) {
        widget.onTabChange?.call(nextStep.tabIndex!);
        _waitAndShow(_currentStep + 1);
      } else {
        setState(() => _currentStep++);
        _animController.forward();
      }
    } else {
      widget.onComplete();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _animController.reset();
      final prevStep = widget.steps[_currentStep - 1];
      if (prevStep.tabIndex != null) {
        widget.onTabChange?.call(prevStep.tabIndex!);
        _waitAndShow(_currentStep - 1);
      } else {
        setState(() => _currentStep--);
        _animController.forward();
      }
    }
  }

  /// 탭 전환 후 타겟 위젯이 빌드될 때까지 대기
  void _waitAndShow(int targetStep, [int retries = 0]) {
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      final step = widget.steps[targetStep];
      final renderBox =
          step.targetKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null || !renderBox.attached) {
        if (retries < 5) {
          _waitAndShow(targetStep, retries + 1);
          return;
        }
        // 재시도 실패: 해당 스텝 건너뛰기
        final nextTarget = targetStep + 1;
        if (nextTarget < widget.steps.length) {
          setState(() => _currentStep = nextTarget);
          // 다음 스텝도 탭 전환이 필요하면 처리
          final nextStep = widget.steps[nextTarget];
          if (nextStep.tabIndex != null) {
            widget.onTabChange?.call(nextStep.tabIndex!);
            _waitAndShow(nextTarget);
          } else {
            _animController.forward();
          }
        } else {
          // 마지막이면 온보딩 완료
          widget.onComplete();
        }
        return;
      }
      setState(() => _currentStep = targetStep);
      _animController.forward();
    });
  }

  Rect? _getTargetRect() {
    final step = widget.steps[_currentStep];
    final renderBox =
        step.targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.attached) return null;

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    return Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height);
  }

  @override
  Widget build(BuildContext context) {
    final targetRect = _getTargetRect();
    final step = widget.steps[_currentStep];
    final screenSize = MediaQuery.of(context).size;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Dark overlay with spotlight cutout - absorb taps to prevent interaction with underlying UI
            GestureDetector(
              onTap: () {}, // Absorb taps on dark area
              behavior: HitTestBehavior.opaque,
              child: targetRect != null
                  ? _SpotlightPainterWidget(
                      targetRect: targetRect,
                      pulseAnimation: _pulseAnimation,
                      animController: _animController,
                    )
                  : Container(color: Colors.black.withValues(alpha: 0.7)),
            ),

            // Tooltip with arrow (or fallback centered tooltip when target not found)
            if (targetRect != null)
              _buildTooltip(targetRect, step, screenSize)
            else
              _buildFallbackTooltip(step, screenSize),
          ],
        ),
      ),
    );
  }

  /// Fallback tooltip shown when target widget is not found (e.g., user switched tabs)
  Widget _buildFallbackTooltip(CoachMarkStep step, Size screenSize) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          constraints: BoxConstraints(maxWidth: screenSize.width - 48),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkNavy,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                step.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    GestureDetector(
                      onTap: _prevStep,
                      child: Text(
                        '이전',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[500],
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  GestureDetector(
                    onTap: _nextStep,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.mathBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _currentStep == widget.steps.length - 1
                            ? '완료'
                            : '다음',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTooltip(
      Rect targetRect, CoachMarkStep step, Size screenSize) {
    final isAbove = step.arrowDirection == ArrowDirection.down ||
        targetRect.center.dy > screenSize.height * 0.45;
    final tooltipMaxWidth = screenSize.width - 48;
    final safeTop = MediaQuery.of(context).padding.top + 16;

    // Calculate tooltip position - ensure no overlap with target
    double top;
    if (isAbove) {
      // Place tooltip fully above target (tooltip height ~200 + arrow 12 + gap 8)
      top = targetRect.top - 220 + step.tooltipOffset.top;
    } else {
      // Place tooltip below target with gap
      top = targetRect.bottom + 16 + step.tooltipOffset.top;
    }
    top = top.clamp(safeTop, screenSize.height - 220);

    return Positioned(
      top: top,
      left: 24 + step.tooltipOffset.left,
      right: 24 - step.tooltipOffset.left,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Arrow pointing up (when tooltip is below target)
          if (!isAbove) _buildArrow(targetRect, isAbove: false),

          // Tooltip card
          Container(
            constraints: BoxConstraints(maxWidth: tooltipMaxWidth),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  step.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkNavy,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  step.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Previous button
                    if (_currentStep > 0)
                      GestureDetector(
                        onTap: _prevStep,
                        child: Text(
                          '이전',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[500],
                          ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    // Next button
                    GestureDetector(
                      onTap: _nextStep,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.mathBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _currentStep == widget.steps.length - 1
                              ? '완료'
                              : '다음',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Arrow pointing down (when tooltip is above target)
          if (isAbove) _buildArrow(targetRect, isAbove: true),
        ],
      ),
    );
  }

  Widget _buildArrow(Rect targetRect, {required bool isAbove}) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Calculate arrow horizontal position relative to tooltip
    final arrowX = (targetRect.center.dx - 24).clamp(20.0, screenWidth - 68);

    return Padding(
      padding: EdgeInsets.only(left: arrowX - 24),
      child: CustomPaint(
        size: const Size(24, 12),
        painter: _ArrowPainter(isAbove: isAbove),
      ),
    );
  }

}

/// Spotlight painter - draws dark overlay with a cutout around the target
class _SpotlightPainterWidget extends AnimatedWidget {
  final Rect targetRect;
  final Animation<double> pulseAnimation;

  const _SpotlightPainterWidget({
    required this.targetRect,
    required this.pulseAnimation,
    required AnimationController animController,
  }) : super(listenable: animController);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: MediaQuery.of(context).size,
      painter: _SpotlightPainter(
        targetRect: targetRect,
        pulse: pulseAnimation.value,
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final Rect targetRect;
  final double pulse;

  _SpotlightPainter({required this.targetRect, this.pulse = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.7);

    // Full screen path
    final fullPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Spotlight cutout (rounded rect with padding)
    final padding = 8.0 + pulse;
    final spotlightRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(
        targetRect.left - padding,
        targetRect.top - padding,
        targetRect.right + padding,
        targetRect.bottom + padding,
      ),
      const Radius.circular(12),
    );

    final cutoutPath = Path()..addRRect(spotlightRect);

    // Combine paths (full screen minus spotlight)
    final combinedPath =
        Path.combine(PathOperation.difference, fullPath, cutoutPath);

    canvas.drawPath(combinedPath, paint);

    // Draw glow border around spotlight
    final glowPaint = Paint()
      ..color = AppColors.mathBlue.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawRRect(spotlightRect, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) {
    return oldDelegate.targetRect != targetRect || oldDelegate.pulse != pulse;
  }
}

class _ArrowPainter extends CustomPainter {
  final bool isAbove;

  _ArrowPainter({required this.isAbove});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    if (isAbove) {
      // Arrow pointing down (tooltip is above)
      path.moveTo(0, 0);
      path.lineTo(size.width / 2, size.height);
      path.lineTo(size.width, 0);
    } else {
      // Arrow pointing up (tooltip is below)
      path.moveTo(0, size.height);
      path.lineTo(size.width / 2, 0);
      path.lineTo(size.width, size.height);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
