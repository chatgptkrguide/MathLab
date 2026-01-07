import 'package:flutter/material.dart';

/// 듀오링고 스타일 UI 상수 정의
///
/// 앱 전체에서 사용되는 듀오링고 스타일의 3D 효과, 그라디언트, 그림자 등을 정의합니다.
class DuolingoStyles {
  DuolingoStyles._(); // Private constructor to prevent instantiation

  // ============================================
  // 색상 정의
  // ============================================

  /// 듀오링고 그린 색상
  static const Color duolingoGreen = Color(0xFF58CC02);
  static const Color duolingoGreenDark = Color(0xFF46A302);
  static const Color duolingoGreenBorder = Color(0xFF70D820);

  /// 듀오링고 블루 색상
  static const Color duolingoBlue = Color(0xFF4A90E2);
  static final Color duoBlueBorder = Colors.blue.shade200;
  static final Color duoBlueLight = Colors.blue.shade50;

  // ============================================
  // 간격 상수
  // ============================================

  static const double cardBorderRadius = 16.0;
  static const double cardBorderWidth = 2.0;
  static const double cardPaddingVertical = 14.0;
  static const double cardPaddingHorizontal = 14.0;

  static const double highlightHeight = 6.0;
  static const double shadowOffset = 3.0;
  static const double shadowBlurRadius = 8.0;
  static const double shadowSpreadRadius = 0.0;

  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;

  // ============================================
  // 그라디언트
  // ============================================

  /// 듀오링고 그린 그라디언트 (일반 상태)
  static const Gradient greenGradient = LinearGradient(
    colors: [duolingoGreen, duolingoGreenDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// 듀오링고 그린 그라디언트 (눌린 상태)
  static const Gradient greenGradientPressed = LinearGradient(
    colors: [duolingoGreenDark, Color(0xFF3A8502)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// 듀오링고 그린 배경 그라디언트
  static const Gradient greenBackgroundGradient = LinearGradient(
    colors: [Color(0xFFE8F5E9), Colors.white],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// 듀오링고 블루 배경 그라디언트
  static LinearGradient get blueBackgroundGradient => LinearGradient(
        colors: [duoBlueLight, Colors.white],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  /// 화이트 그라디언트 (스탯 카드용)
  static LinearGradient get whiteGradient => LinearGradient(
        colors: [Colors.white, Colors.grey.shade50],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  // ============================================
  // 그림자 효과
  // ============================================

  /// 듀오링고 그린 3D 그림자
  static List<BoxShadow> get greenShadow => [
        const BoxShadow(
          color: duolingoGreenDark,
          offset: Offset(0, shadowOffset),
          blurRadius: shadowSpreadRadius,
          spreadRadius: shadowSpreadRadius,
        ),
        BoxShadow(
          color: duolingoGreen.withOpacity(0.4),
          blurRadius: shadowBlurRadius,
          offset: const Offset(0, 4),
        ),
      ];

  /// 듀오링고 그린 3D 그림자 (눌린 상태)
  static List<BoxShadow> get greenShadowPressed => [
        const BoxShadow(
          color: duolingoGreenDark,
          offset: Offset(0, 2),
          blurRadius: shadowSpreadRadius,
          spreadRadius: shadowSpreadRadius,
        ),
        BoxShadow(
          color: duolingoGreen.withOpacity(0.3),
          blurRadius: shadowBlurRadius,
          offset: const Offset(0, 3),
        ),
      ];

  /// 듀오링고 블루 3D 그림자
  static List<BoxShadow> get blueShadow => [
        BoxShadow(
          color: Colors.blue.shade300.withOpacity(0.4),
          offset: const Offset(0, shadowOffset),
          blurRadius: shadowSpreadRadius,
          spreadRadius: shadowSpreadRadius,
        ),
        BoxShadow(
          color: Colors.blue.shade200.withOpacity(0.3),
          blurRadius: shadowBlurRadius,
          offset: const Offset(0, 4),
        ),
      ];

  /// 화이트 카드 3D 그림자
  static List<BoxShadow> get whiteShadow => [
        const BoxShadow(
          color: Color(0xFFE0E0E0),
          offset: Offset(0, shadowOffset),
          blurRadius: shadowSpreadRadius,
          spreadRadius: shadowSpreadRadius,
        ),
        BoxShadow(
          color: Colors.grey.shade200.withOpacity(0.5),
          blurRadius: shadowBlurRadius,
          offset: const Offset(0, 4),
        ),
      ];

  // ============================================
  // 상단 하이라이트 효과
  // ============================================

  /// 화이트 상단 하이라이트 (일반)
  static BoxDecoration get topHighlight => BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.8),
            Colors.white.withOpacity(0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(14),
          topRight: Radius.circular(14),
        ),
      );

  /// 화이트 상단 하이라이트 (눌린 상태)
  static BoxDecoration get topHighlightPressed => BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(14),
          topRight: Radius.circular(14),
        ),
      );

  // ============================================
  // 텍스트 스타일
  // ============================================

  /// 카드 라벨 텍스트 스타일
  static TextStyle get cardLabelStyle => TextStyle(
        fontSize: 11,
        color: Colors.grey.shade600,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      );

  /// 카드 값 텍스트 스타일 (블루)
  static TextStyle get cardValueBlueStyle => TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: Colors.blue.shade700,
        letterSpacing: 0.3,
      );

  /// 카드 값 텍스트 스타일 (그린)
  static const TextStyle cardValueGreenStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    color: duolingoGreenDark,
    letterSpacing: 0.3,
  );

  /// 카드 값 텍스트 스타일 (다크)
  static const TextStyle cardValueDarkStyle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w800,
    color: Color(0xFF1A1A1A),
    letterSpacing: 0.3,
  );

  /// 버튼 텍스트 스타일 (일반)
  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  /// 버튼 텍스트 스타일 (눌린 상태)
  static const TextStyle buttonTextStylePressed = TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.w800,
    color: Colors.white,
    letterSpacing: 0.5,
  );
}
