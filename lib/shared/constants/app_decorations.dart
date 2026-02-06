import 'package:flutter/material.dart';

/// 앱 전체에서 공통으로 사용하는 데코레이션 상수
class AppDecorations {
  AppDecorations._();

  // ========================================
  // Box Shadows
  // ========================================

  /// 카드 기본 그림자 (가장 많이 사용)
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ];

  /// 카드 위쪽 그림자 (하단 액션 바 등)
  static List<BoxShadow> get cardShadowUp => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, -2),
        ),
      ];

  /// 강한 그림자 (플로팅 요소, 드래그 중)
  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  /// 미세한 그림자 (리스트 아이템 등)
  static List<BoxShadow> get subtleShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 6,
          offset: const Offset(0, 1),
        ),
      ];

  // ========================================
  // Card Decorations
  // ========================================

  /// 기본 카드 데코레이션 (흰색 배경 + 그림자 + 둥근 모서리)
  static BoxDecoration get card => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: cardShadow,
      );

  /// 둥근 모서리 12px 카드
  static BoxDecoration get cardSmall => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: cardShadow,
      );
}
