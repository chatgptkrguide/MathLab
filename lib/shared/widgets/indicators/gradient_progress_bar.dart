import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// 그라디언트 진행률 바 위젯
///
/// 다양한 색상의 그라디언트로 진행률을 표시하는 재사용 가능한 위젯
/// - 업적 진행률
/// - 레벨 진행률
/// - 학습 진행률
/// - 챌린지 진행률
class GradientProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final List<Color> gradientColors;
  final Color backgroundColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;

  const GradientProgressBar({
    super.key,
    required this.progress,
    this.height = 4,
    required this.gradientColors,
    this.backgroundColor = AppColors.disabled,
    this.borderRadius,
    this.margin,
  });

  /// 프리셋: Gold 진행률 바
  factory GradientProgressBar.gold({
    Key? key,
    required double progress,
    double height = 4,
    Color backgroundColor = AppColors.disabled,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? margin,
  }) {
    return GradientProgressBar(
      key: key,
      progress: progress,
      height: height,
      gradientColors: AppColors.goldGradient,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      margin: margin,
    );
  }

  /// 프리셋: Green 진행률 바
  factory GradientProgressBar.green({
    Key? key,
    required double progress,
    double height = 4,
    Color backgroundColor = AppColors.disabled,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? margin,
  }) {
    return GradientProgressBar(
      key: key,
      progress: progress,
      height: height,
      gradientColors: AppColors.greenGradient,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      margin: margin,
    );
  }

  /// 프리셋: Blue 진행률 바
  factory GradientProgressBar.blue({
    Key? key,
    required double progress,
    double height = 4,
    Color backgroundColor = AppColors.disabled,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? margin,
  }) {
    return GradientProgressBar(
      key: key,
      progress: progress,
      height: height,
      gradientColors: AppColors.blueGradient,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      margin: margin,
    );
  }

  /// 프리셋: Purple 진행률 바
  factory GradientProgressBar.purple({
    Key? key,
    required double progress,
    double height = 4,
    Color backgroundColor = AppColors.disabled,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? margin,
  }) {
    return GradientProgressBar(
      key: key,
      progress: progress,
      height: height,
      gradientColors: AppColors.purpleGradient,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      margin: margin,
    );
  }

  /// 프리셋: Orange 진행률 바
  factory GradientProgressBar.orange({
    Key? key,
    required double progress,
    double height = 4,
    Color backgroundColor = AppColors.disabled,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? margin,
  }) {
    return GradientProgressBar(
      key: key,
      progress: progress,
      height: height,
      gradientColors: AppColors.orangeGradient,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      margin: margin,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(height / 2);
    final clampedProgress = progress.clamp(0.0, 1.0);

    return Container(
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: effectiveBorderRadius,
        color: backgroundColor,
      ),
      child: ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: clampedProgress,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
