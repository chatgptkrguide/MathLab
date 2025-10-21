import 'package:flutter/material.dart';

/// MathLab 앱의 색상 상수 정의
/// Figma 디자인을 기반으로 한 정확한 색상값들
class AppColors {
  AppColors._(); // private constructor

  // GoMath 브랜드 색상 (Figma 디자인 기반)
  static const Color mathBlue = Color(0xFF61A1D8); // 메인 파란색 (상단)
  static const Color mathBlueLight = Color(0xFFA1C9E8); // 밝은 파란색 (하단)
  static const Color mathButtonBlue = Color(0xFF3B5BFF); // 버튼/카드 파란색
  static const Color mathTeal = Color(0xFF48C9B0); // 진행바 틸색
  static const Color mathOrange = Color(0xFFFF9600); // 스트릭 오렌지
  static const Color mathYellow = Color(0xFFFFD900); // 별 노란색
  static const Color mathRed = Color(0xFFFF4B4B); // 에러 빨간색

  // 듀오링고 스타일 브랜드 색상 (호환성 유지)
  static const Color duolingoGreen = Color(0xFF58CC02); // 듀오링고 메인 그린
  static const Color duolingoBlue = mathBlue; // GoMath 파란색으로 매핑
  static const Color duolingoOrange = mathOrange; // 오렌지
  static const Color duolingoRed = mathRed; // 레드
  static const Color duolingoPurple = Color(0xFFCE82FF); // 듀오링고 퍼플
  static const Color duolingoYellow = mathYellow; // 노란색

  // 기본 색상들 (호환성)
  static const Color primaryGreen = duolingoGreen;
  static const Color primaryBlue = duolingoBlue;
  static const Color secondaryBlue = Color(0xFFE3F2FD);
  static const Color accentCyan = duolingoBlue;
  static const Color warningOrange = duolingoOrange;
  static const Color successGreen = duolingoGreen;
  static const Color errorRed = duolingoRed;
  static const Color purpleAccent = duolingoPurple;

  // 중성 색상 (접근성 향상)
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A1A); // 더 진한 검정 (대비 향상)
  static const Color textSecondary = Color(0xFF4A4A4A); // 더 진한 회색 (가독성 향상)
  static const Color borderLight = Color(0xFFDADCE0);
  static const Color borderColor = Color(0xFFDADCE0); // 경계선 색상
  static const Color disabled = Color(0xFF9AA0A6);

  // 게이미피케이션 색상
  static const Color xpGold = Color(0xFFFFD700);
  static const Color streakOrange = Color(0xFFFF6B35);
  static const Color levelBronze = Color(0xFFCD7F32);
  static const Color levelSilver = Color(0xFFC0C0C0);
  static const Color levelGold = Color(0xFFFFD700);
  static const Color levelDiamond = Color(0xFFB9F2FF);

  // 진행률 색상 (Figma 디자인)
  static const Color progressBackground = Color(0xFFE5E5E5);
  static const Color progressActive = mathTeal; // 기본 진행률 (틸색)
  static const Color progressActiveGreen = duolingoGreen; // 초록 진행률
  static const Color progressActiveBlue = mathBlue; // 파란 진행률
  static const Color progressActiveTeal = mathTeal; // 틸 진행률

  // GoMath 그라디언트 색상들 (Figma 디자인)
  static const List<Color> mathBlueGradient = [mathBlue, mathBlueLight]; // 메인 배경
  static const List<Color> mathButtonGradient = [Color(0xFF3B5BFF), Color(0xFF2B4BEF)]; // 버튼
  static const List<Color> mathTealGradient = [Color(0xFF48C9B0), Color(0xFF38B9A0)]; // 진행바

  // 기존 그라디언트 (호환성)
  static const List<Color> greenGradient = [Color(0xFF89E219), Color(0xFF58CC02)];
  static const List<Color> blueGradient = mathBlueGradient; // GoMath 그라디언트로 매핑
  static const List<Color> orangeGradient = [Color(0xFFFFB74D), mathOrange];
  static const List<Color> purpleGradient = [Color(0xFFE1BEE7), Color(0xFFCE82FF)];

  // 카드 그림자
  static const Color cardShadow = Color(0x0D000000);

  // 상태별 색상
  static final Map<String, Color> levelColors = {
    'bronze': levelBronze,
    'silver': levelSilver,
    'gold': levelGold,
    'diamond': levelDiamond,
  };
}