// Coach mark overlay — dark spotlight that highlights a target widget and shows
// a tooltip with title / description / next-prev navigation.
import 'package:flutter/material.dart';

import 'widgets/coach_mark_arrow.dart';
import 'widgets/coach_mark_spotlight.dart';
import 'widgets/coach_mark_step.dart';
import 'widgets/coach_mark_tooltip_card.dart';

export 'widgets/coach_mark_step.dart' show CoachMarkStep, ArrowDirection;

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
                  ? CoachMarkSpotlight(
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
        child: CoachMarkTooltipCard(
          title: step.title,
          description: step.description,
          showPrevious: _currentStep > 0,
          isLastStep: _currentStep == widget.steps.length - 1,
          onNext: _nextStep,
          onPrevious: _prevStep,
          constraints: BoxConstraints(maxWidth: screenSize.width - 48),
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
          if (!isAbove)
            CoachMarkArrow(targetRect: targetRect, isAbove: false),

          // Tooltip card
          CoachMarkTooltipCard(
            title: step.title,
            description: step.description,
            showPrevious: _currentStep > 0,
            isLastStep: _currentStep == widget.steps.length - 1,
            onNext: _nextStep,
            onPrevious: _prevStep,
            constraints: BoxConstraints(maxWidth: tooltipMaxWidth),
          ),

          // Arrow pointing down (when tooltip is above target)
          if (isAbove)
            CoachMarkArrow(targetRect: targetRect, isAbove: true),
        ],
      ),
    );
  }
}
