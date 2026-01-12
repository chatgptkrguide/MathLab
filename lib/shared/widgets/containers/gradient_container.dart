import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';

/// 그라디언트 컨테이너 위젯
///
/// 다양한 상황에서 재사용 가능한 그라디언트 배경 컨테이너
/// - 업적 카드
/// - 리그 헤더
/// - 레벨 업 다이얼로그
/// - 일일 보상 화면
class GradientContainer extends StatelessWidget {
  final Widget child;
  final List<Color> gradientColors;
  final AlignmentGeometry gradientBegin;
  final AlignmentGeometry gradientEnd;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow>? boxShadow;
  final bool animated;
  final Duration animationDuration;

  const GradientContainer({
    super.key,
    required this.child,
    required this.gradientColors,
    this.gradientBegin = Alignment.topLeft,
    this.gradientEnd = Alignment.bottomRight,
    this.borderRadius,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderColor,
    this.borderWidth = 1.0,
    this.boxShadow,
    this.animated = false,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  /// 프리셋: Gold 그라디언트 컨테이너
  factory GradientContainer.gold({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
    bool animated = false,
  }) {
    return GradientContainer(
      key: key,
      gradientColors: AppColors.goldGradient,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius ?? BorderRadius.circular(AppDimensions.radiusL),
      animated: animated,
      child: child,
    );
  }

  /// 프리셋: Green 그라디언트 컨테이너
  factory GradientContainer.green({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
    bool animated = false,
  }) {
    return GradientContainer(
      key: key,
      gradientColors: AppColors.greenGradient,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius ?? BorderRadius.circular(AppDimensions.radiusL),
      animated: animated,
      child: child,
    );
  }

  /// 프리셋: Blue 그라디언트 컨테이너
  factory GradientContainer.blue({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
    bool animated = false,
  }) {
    return GradientContainer(
      key: key,
      gradientColors: AppColors.blueGradient,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius ?? BorderRadius.circular(AppDimensions.radiusL),
      animated: animated,
      child: child,
    );
  }

  /// 프리셋: Purple 그라디언트 컨테이너
  factory GradientContainer.purple({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
    bool animated = false,
  }) {
    return GradientContainer(
      key: key,
      gradientColors: AppColors.purpleGradient,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius ?? BorderRadius.circular(AppDimensions.radiusL),
      animated: animated,
      child: child,
    );
  }

  /// 프리셋: Orange 그라디언트 컨테이너
  factory GradientContainer.orange({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
    bool animated = false,
  }) {
    return GradientContainer(
      key: key,
      gradientColors: AppColors.orangeGradient,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius ?? BorderRadius.circular(AppDimensions.radiusL),
      animated: animated,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final container = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: gradientBegin,
          end: gradientEnd,
          colors: gradientColors,
        ),
        borderRadius: borderRadius,
        border: borderColor != null
            ? Border.all(
                color: borderColor!,
                width: borderWidth,
              )
            : null,
        boxShadow: boxShadow,
      ),
      child: child,
    );

    if (animated) {
      return AnimatedContainer(
        duration: animationDuration,
        width: width,
        height: height,
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: gradientBegin,
            end: gradientEnd,
            colors: gradientColors,
          ),
          borderRadius: borderRadius,
          border: borderColor != null
              ? Border.all(
                  color: borderColor!,
                  width: borderWidth,
                )
              : null,
          boxShadow: boxShadow,
        ),
        child: child,
      );
    }

    return container;
  }
}
