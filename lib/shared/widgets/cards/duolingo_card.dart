import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_dimensions.dart';

/// 듀오링고 스타일 카드
/// 3D 효과와 그라디언트가 적용된 카드
class DuolingoCard extends StatelessWidget {
  final Widget child;
  final List<Color>? gradientColors;
  final Color? borderColor;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? elevation;

  const DuolingoCard({
    super.key,
    required this.child,
    this.gradientColors,
    this.borderColor,
    this.onTap,
    this.padding,
    this.margin,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ??
          const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
            vertical: AppDimensions.paddingS,
          ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        boxShadow: [
          // 3D 바닥 그림자
          BoxShadow(
            color: (borderColor ?? AppColors.successGreen).withValues(alpha: 0.3), // GoMath green
            offset: const Offset(0, 4),
            blurRadius: 0,
          ),
          // 부드러운 그림자
          BoxShadow(
            color: AppColors.cardShadow.withValues(alpha: 0.1),
            offset: const Offset(0, 8),
            blurRadius: 16,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: gradientColors != null
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors!,
                )
              : null,
          color: gradientColors == null ? AppColors.surface : null,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          border: borderColor != null
              ? Border.all(color: borderColor!, width: 2)
              : Border.all(color: AppColors.borderLight.withValues(alpha: 0.3), width: 1),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
            child: Padding(
              padding: padding ?? const EdgeInsets.all(AppDimensions.paddingL),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// 듀오링고 스타일 통계 카드
class DuolingoStatCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String value;
  final Color iconColor;
  final VoidCallback? onTap;

  const DuolingoStatCard({
    super.key,
    required this.emoji,
    required this.title,
    required this.value,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DuolingoCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 3D 아이콘 배경 (플렉서블)
          Flexible(
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    iconColor.withValues(alpha: 0.8),
                    iconColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  // 더 강한 3D 효과
                  BoxShadow(
                    color: iconColor.withValues(alpha: 0.4),
                    offset: const Offset(0, 4),
                    blurRadius: 0,
                  ),
                  BoxShadow(
                    color: iconColor.withValues(alpha: 0.2),
                    offset: const Offset(0, 8),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              value,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// 듀오링고 스타일 레슨 패스 아이템
class DuolingoLessonNode extends StatelessWidget {
  final String emoji;
  final bool isCompleted;
  final bool isActive;
  final bool isLocked;
  final double progress; // 0.0 - 1.0
  final VoidCallback? onTap;

  const DuolingoLessonNode({
    super.key,
    required this.emoji,
    this.isCompleted = false,
    this.isActive = false,
    this.isLocked = false,
    this.progress = 0.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    List<Color> gradientColors;

    if (isLocked) {
      backgroundColor = AppColors.disabled;
      gradientColors = [AppColors.disabled, AppColors.disabled];
    } else if (isCompleted) {
      backgroundColor = AppColors.mathYellow; // GoMath yellow (gold)
      gradientColors = [AppColors.mathYellow.withValues(alpha: 0.8), AppColors.mathYellow]; // GoMath gradient
    } else if (isActive) {
      backgroundColor = AppColors.successGreen; // GoMath green
      gradientColors = AppColors.greenGradient;
    } else {
      backgroundColor = AppColors.mathBlue; // GoMath blue
      gradientColors = AppColors.blueGradient;
    }

    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          boxShadow: [
            // 3D 바닥 그림자
            BoxShadow(
              color: gradientColors[1].withValues(alpha: 0.4),
              offset: const Offset(0, 6),
              blurRadius: 0,
            ),
            // 부드러운 그림자
            BoxShadow(
              color: AppColors.cardShadow.withValues(alpha: 0.2),
              offset: const Offset(0, 8),
              blurRadius: 16,
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: gradientColors,
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  emoji,
                  style: TextStyle(
                    fontSize: 32,
                    color: isLocked ? AppColors.surface.withValues(alpha: 0.5) : AppColors.surface,
                  ),
                ),
              ),
              if (!isCompleted && !isLocked && progress > 0)
                Positioned.fill(
                  child: CustomPaint(
                    painter: ProgressRingPainter(
                      progress: progress,
                      color: AppColors.surface.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              if (isCompleted)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.successGreen, // GoMath green
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.surface, width: 2),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: AppColors.surface,
                      size: 16,
                    ),
                  ),
                ),
              if (isLocked)
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    ),
                    child: const Icon(
                      Icons.lock,
                      color: AppColors.surface,
                      size: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 진행률 링 페인터
class ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  ProgressRingPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * 3.14159 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}