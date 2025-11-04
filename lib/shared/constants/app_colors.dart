import 'package:flutter/material.dart';

/// MathLab 앱의 색상 상수 정의
/// GoMath 브랜드 색상 (Figma 디자인 기반)
class AppColors {
  AppColors._(); // private constructor

  // ==========================================
  // 1. GoMath 브랜드 메인 색상
  // ==========================================

  /// 메인 파란색 (상단)
  static const Color mathBlue = Color(0xFF61A1D8);

  /// 메인 버튼/카드 파란색
  static const Color mathButtonBlue = Color(0xFF3B5BFF);

  /// 메인 틸색 (진행바)
  static const Color mathTeal = Color(0xFF48C9B0);

  /// 메인 오렌지 (스트릭)
  static const Color mathOrange = Color(0xFFFF9600);

  /// 메인 노란색 (별/XP)
  static const Color mathYellow = Color(0xFFFFD900);

  /// 메인 빨간색 (에러/하트)
  static const Color mathRed = Color(0xFFFF4B4B);

  /// 메인 퍼플 (힌트)
  static const Color mathPurple = Color(0xFFCE82FF);

  /// 메인 초록색 (정답/성공)
  static const Color mathGreen = Color(0xFF58CC02);

  // ==========================================
  // 2. 시맨틱 색상 (용도별 색상)
  // ==========================================

  static const Color primary = mathButtonBlue;
  static const Color success = mathGreen;
  static const Color error = mathRed;
  static const Color warning = mathOrange;

  // ==========================================
  // 3. 중성 색상
  // ==========================================

  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF4A4A4A);
  static const Color borderLight = Color(0xFFDADCE0);
  static const Color disabled = Color(0xFF9AA0A6);
  static const Color cardShadow = Color(0x0D000000);

  // ==========================================
  // 4. 게이미피케이션 색상
  // ==========================================

  static const Color xpGold = Color(0xFFFFD700);
  static const Color streakOrange = Color(0xFFFF6B35);
  static const Color levelBronze = Color(0xFFCD7F32);
  static const Color levelSilver = Color(0xFFC0C0C0);
  static const Color levelGold = Color(0xFFFFD700);
  static const Color levelDiamond = Color(0xFFB9F2FF);

  // ==========================================
  // 5. 소셜 로그인 색상
  // ==========================================

  static const Color kakaoYellow = Color(0xFFFEE500);
  static const Color kakaoBrown = Color(0xFF191919);
  static const Color appleDark = Color(0xFF1A1A1A);

  // ==========================================
  // 6. 그라디언트 색상
  // ==========================================

  static const List<Color> mathBlueGradient = [
    Color(0xFF61A1D8),
    Color(0xFFA1C9E8)
  ];

  static const List<Color> mathButtonGradient = [
    Color(0xFF3B5BFF),
    Color(0xFF2B4BEF)
  ];

  static const List<Color> mathTealGradient = [
    Color(0xFF48C9B0),
    Color(0xFF38B9A0)
  ];

  static const List<Color> mathOrangeGradient = [
    Color(0xFFFFB74D),
    Color(0xFFFF9600)
  ];

  static const List<Color> mathYellowGradient = [
    Color(0xFFFFF59D),
    Color(0xFFFFD900)
  ];

  static const List<Color> mathPurpleGradient = [
    Color(0xFFE1BEE7),
    Color(0xFFCE82FF)
  ];

  static const List<Color> greenGradient = [
    Color(0xFF89E219),
    Color(0xFF58CC02)
  ];

  static const List<Color> goldGradient = [
    Color(0xFFFFD700),
    Color(0xFFFFA500)
  ];

  // ==========================================
  // 7. 레벨 색상 맵
  // ==========================================

  static final Map<String, Color> levelColors = {
    'bronze': levelBronze,
    'silver': levelSilver,
    'gold': levelGold,
    'diamond': levelDiamond,
  };

  // ==========================================
  // 8. 더 어두운/밝은 색상 유틸리티
  // ==========================================

  /// 색상을 더 어둡게 만드는 헬퍼 메서드
  static Color darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  /// 색상을 더 밝게 만드는 헬퍼 메서드
  static Color lighten(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }

  // ==========================================
  // 9. 추가 색상 (빌드 호환용)
  // ==========================================

  // Darker variants (20% darker)
  static const Color mathButtonBlueDark = Color(0xFF2A41CC);  // Darker blue
  static const Color mathTealDark = Color(0xFF39A08D);  // Darker teal
  static const Color mathYellowDark = Color(0xFFCCAD00);  // Darker yellow
  static const Color mathOrangeDark = Color(0xFFCC7A00);  // Darker orange
  static const Color mathRedDark = Color(0xFFCC3C3C);  // Darker red
  static const Color mathPurpleDark = Color(0xFFA568CC);  // Darker purple
  static const Color mathBlueDark = Color(0xFF4D81AD);  // Darker math blue
  static const Color kakaoYellowDark = Color(0xFFCBB700);  // Darker kakao
  static const Color levelGoldDark = Color(0xFFCCAD00);  // Darker gold
  static const Color levelSilverDark = Color(0xFF9A9A9A);  // Darker silver
  static const Color levelBronzeDark = Color(0xFFA46628);  // Darker bronze
  static const Color duolingoGreenDark = Color(0xFF46A301);  // Darker green

  // Additional colors
  static const Color successGreen = mathGreen;
  static const Color errorRed = mathRed;
  static const Color warningOrange = mathOrange;
  static const Color warningYellow = Color(0xFFFFC107);
  static const Color accentCyan = Color(0xFF00BCD4);
  static const Color progressActive = mathTeal;
  static const Color progressActiveBlue = mathButtonBlue;
  static const Color duolingoRed = mathRed;
  static const Color duolingoOrange = mathOrange;

  // Additional gradients
  static const List<Color> blueGradient = mathBlueGradient;
  static const List<Color> purpleGradient = mathPurpleGradient;
  static const List<Color> orangeGradient = mathOrangeGradient;

  // ==========================================
  // 10. 호환성을 위한 별칭 (Deprecated - 추후 제거 예정)
  // ==========================================

  @deprecated
  static const Color duolingoGreen = mathGreen;

  @deprecated
  static const Color duolingoBlue = mathBlue;

  @deprecated
  static const Color primaryGreen = mathGreen;

  @deprecated
  static const Color primaryBlue = mathBlue;

  @deprecated
  static const Color progressBackground = Color(0xFFE5E5E5);

  @deprecated
  static const Color highlightGreen = Color(0xFFD4F4DD);
}