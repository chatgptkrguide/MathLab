import 'dart:ui';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';

/// Frosted glass container with blur backdrop and subtle border.
///
/// Uses the AppColors glassmorphism tokens (glassBg, glassBorder,
/// glossyHighlight) defined in the design system.
class GlassmorphismContainer extends StatelessWidget {
  final Widget child;
  final double blurAmount;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? borderColor;

  const GlassmorphismContainer({
    super.key,
    required this.child,
    this.blurAmount = 12.0,
    this.borderRadius = AppDimensions.radius20,
    this.padding,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: blurAmount,
          sigmaY: blurAmount,
        ),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.glassBg,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ?? AppColors.glassBorder,
              width: 1.5,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.glossyHighlight,
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
