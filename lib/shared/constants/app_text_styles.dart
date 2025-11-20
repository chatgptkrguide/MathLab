import 'package:flutter/material.dart';
import 'app_colors.dart';

/// MathLab 앱의 텍스트 스타일 상수 정의
///
/// 폰트 전략:
/// - 한글: NexonGothic (깔끔하고 친근한 게임 폰트 - 무료 상업적 사용 가능)
/// - 숫자/수식: Inter (수학적 내용에 최적화)
/// - 본문: Roboto (기본 읽기 텍스트)
class AppTextStyles {
  AppTextStyles._(); // private constructor

  // 디스플레이 스타일 (Material 3)
  static const TextStyle displayLarge = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
    fontFamily: 'NexonGothic',
    fontFamilyFallback: ['Inter', 'Roboto'],
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.2,
    fontFamily: 'NexonGothic',
    fontFamilyFallback: ['Inter', 'Roboto'],
  );

  // 헤드라인 스타일
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
    fontFamily: 'NexonGothic',
    fontFamilyFallback: ['Inter', 'Roboto'],
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.2,
    fontFamily: 'NexonGothic',
    fontFamilyFallback: ['Inter', 'Roboto'],
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.2,
    fontFamily: 'NexonGothic',
    fontFamilyFallback: ['Inter', 'Roboto'],
  );

  // 타이틀 스타일
  static const TextStyle titleLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
    fontFamily: 'NexonGothic',
    fontFamilyFallback: ['Roboto', 'Inter'],
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.3,
    fontFamily: 'NexonGothic',
    fontFamilyFallback: ['Roboto', 'Inter'],
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.3,
    fontFamily: 'NexonGothic',
    fontFamilyFallback: ['Roboto', 'Inter'],
  );

  // 본문 스타일 (가독성 향상)
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16, // 14 → 16 (가독성 향상)
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5, // 1.4 → 1.5 (줄간격 향상)
    fontFamily: 'Roboto',
    fontFamilyFallback: ['NotoSansKR', 'Inter'],
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14, // 13 → 14 (가독성 향상)
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.5,
    fontFamily: 'Roboto',
    fontFamilyFallback: ['NotoSansKR', 'Inter'],
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 13, // 12 → 13 (모바일 가독성)
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.5,
    fontFamily: 'Roboto',
    fontFamilyFallback: ['NotoSansKR', 'Inter'],
  );

  // 라벨 스타일
  static const TextStyle labelLarge = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.3,
    fontFamily: 'Roboto',
    fontFamilyFallback: ['NotoSansKR', 'Inter'],
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.3,
    fontFamily: 'Roboto',
    fontFamilyFallback: ['NotoSansKR', 'Inter'],
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.3,
    fontFamily: 'Roboto',
    fontFamilyFallback: ['NotoSansKR', 'Inter'],
  );

  // 특별 스타일
  static const TextStyle statValue = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
    fontFamily: 'Inter', // 숫자는 Inter가 가장 보기 좋음
    fontFamilyFallback: ['Roboto', 'NotoSansKR'],
  );

  static const TextStyle statLabel = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.2,
    fontFamily: 'Roboto',
    fontFamilyFallback: ['NotoSansKR', 'Inter'],
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
    fontFamily: 'NexonGothic',
    fontFamilyFallback: ['Roboto', 'Inter'],
  );

  static const TextStyle progressText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryBlue,
    height: 1.2,
    fontFamily: 'Inter', // 진행률 숫자는 Inter
    fontFamilyFallback: ['Roboto', 'NotoSansKR'],
  );

  // 수학 문제 전용 스타일 (숫자와 수식에 최적화)
  static const TextStyle mathProblem = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.6,
    fontFamily: 'Inter', // 수학 수식은 Inter가 최적
    fontFamilyFallback: ['Roboto', 'NotoSansKR'],
    letterSpacing: 0.3, // 수식의 가독성을 위한 자간
  );

  static const TextStyle mathAnswer = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
    fontFamily: 'Inter',
    fontFamilyFallback: ['Roboto', 'NotoSansKR'],
    letterSpacing: 0.2,
  );

  // 이모지 스타일
  static const TextStyle emoji = TextStyle(
    fontSize: 20,
    height: 1.0,
  );

  static const TextStyle emojiSmall = TextStyle(
    fontSize: 16,
    height: 1.0,
  );

  static const TextStyle emojiLarge = TextStyle(
    fontSize: 24,
    height: 1.0,
  );
}