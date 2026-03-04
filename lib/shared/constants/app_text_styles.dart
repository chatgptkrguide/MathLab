import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Unified text style system for the MathLab app.
class AppTextStyles {
  AppTextStyles._();

  // ============================================================
  // === Display (large hero text) ===
  // ============================================================
  static const displayLarge = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.1,
  );

  static const displaySmall = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  // ============================================================
  // === Headline (section headers) ===
  // ============================================================
  static const headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const headlineMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const headlineSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  // Convenience aliases
  static const heading1 = headlineLarge;
  static const heading2 = headlineMedium;

  // ============================================================
  // === Title (card titles, list headers) ===
  // ============================================================
  static const titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // ============================================================
  // === Body (paragraph text) ===
  // ============================================================
  static const bodyLarge = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  static const bodyMedium = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
  );

  static const bodySmall = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  // ============================================================
  // === Label / Caption (metadata, chips, badges) ===
  // ============================================================
  static const labelLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const labelMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const caption = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.normal,
  );

  // ============================================================
  // === Button text ===
  // ============================================================
  static const button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const buttonSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // ============================================================
  // === Anti-AI: Dramatic Contrast Styles ===
  // ============================================================

  /// Extra large display for hero numbers/text
  static const displayXL = TextStyle(
    fontSize: 56,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.0,
    letterSpacing: -1.0,
  );

  /// Section divider label (small, uppercase-like, spaced)
  static const sectionLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textTertiary,
    letterSpacing: 2.0,
  );
}
