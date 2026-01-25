import 'package:flutter/material.dart';
import 'app_colors.dart';

/// 앱 전체에서 사용하는 텍스트 스타일 정의
class AppTextStyles {
  // Display 스타일
  static const displayLarge = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.1,
  );

  // Headline 스타일
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

  // Title 스타일
  static const titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Body 스타일
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
}
