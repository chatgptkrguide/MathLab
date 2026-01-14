import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_dimensions.dart';

/// 듀오링고 스타일 로딩 인디케이터
class DuolingoLoadingIndicator extends StatefulWidget {
  final String? message;
  final double size;
  final Color? color;

  const DuolingoLoadingIndicator({
    super.key,
    this.message,
    this.size = 60.0,
    this.color,
  });

  @override
  State<DuolingoLoadingIndicator> createState() =>
      _DuolingoLoadingIndicatorState();
}

class _DuolingoLoadingIndicatorState extends State<DuolingoLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotationController.repeat();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: Listenable.merge([_rotationAnimation, _pulseAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Transform.rotate(
                angle: _rotationAnimation.value,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.color ?? AppColors.mathBlue,
                        (widget.color ?? AppColors.mathBlue).withValues(alpha: 0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(widget.size / 2),
                    boxShadow: [
                      BoxShadow(
                        color: (widget.color ?? AppColors.mathBlue)
                            .withValues(alpha: 0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '🧮',
                      style: TextStyle(fontSize: widget.size * 0.4),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.message != null) ...[
          const SizedBox(height: AppDimensions.spacingL),
          Text(
            widget.message!,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// 스켈레톤 로딩 (카드 모양)
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 12.0,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: AnimatedBuilder(
        animation: _shimmerAnimation,
        builder: (context, child) {
          return Stack(
            children: [
              // 베이스 색상
              Container(
                decoration: BoxDecoration(
                  color: AppColors.borderLight.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                ),
              ),
              // 쉬머 효과
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  child: Transform.translate(
                    offset: Offset(
                      (widget.width as double? ?? 200) *
                          _shimmerAnimation.value,
                      0,
                    ),
                    child: Container(
                      width: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppColors.borderLight.withValues(alpha: 0.5),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 스켈레톤 카드 (홈 화면용)
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        border: Border.all(color: AppColors.borderLight, width: 1.5),
      ),
      child: Column(
        children: [
          SkeletonLoader(height: 48, borderRadius: 24), // 아이콘 영역
          const SizedBox(height: AppDimensions.spacingM),
          SkeletonLoader(height: 12, borderRadius: 6), // 라벨 영역
          const SizedBox(height: AppDimensions.spacingS),
          SkeletonLoader(height: 20, borderRadius: 4), // 값 영역
        ],
      ),
    );
  }
}

/// 프로그레스 카드 스켈레톤
class SkeletonProgressCard extends StatelessWidget {
  const SkeletonProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      padding: const EdgeInsets.all(AppDimensions.paddingXL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        border: Border.all(color: AppColors.borderLight, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonLoader(width: 120, height: 20, borderRadius: 4),
              SkeletonLoader(width: 80, height: 16, borderRadius: 4),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingL),
          SkeletonLoader(height: 12, borderRadius: 6), // 프로그레스 바
          const SizedBox(height: AppDimensions.spacingM),
          SkeletonLoader(width: 150, height: 14, borderRadius: 4),
        ],
      ),
    );
  }
}

/// 범용 스켈레톤 로딩 위젯 (호환성 함수)
Widget skeletonLoading({
  double? width,
  double height = 20,
  double borderRadius = 4,
}) {
  return SkeletonLoader(
    width: width ?? double.infinity,
    height: height,
    borderRadius: borderRadius,
  );
}
