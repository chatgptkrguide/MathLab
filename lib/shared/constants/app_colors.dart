import 'package:flutter/material.dart';

/// 앱 전체에서 사용하는 색상 정의
class AppColors {
  // 브랜드 컬러
  static const mathBlue = Color(0xFF1CB0F6); // 수학 파랑 (듀오링고 스타일)
  static const primary = mathBlue; // Primary color (alias for mathBlue)
  static const mathGreen = Color(0xFF58CC02); // 듀오링고 녹색
  static const mathOrange = Color(0xFFFF9600); // 수학 주황
  static const mathYellow = Color(0xFFFFC800); // 수학 노랑
  static const mathPurple = Color(0xFFCE82FF); // 수학 보라
  static const mathRed = Color(0xFFFF4B4B); // 수학 빨강

  // 버튼 컬러
  static const mathButtonBlue = Color(0xFF1899D6); // 버튼 파랑

  // 그라디언트
  static const mathBlueGradient = LinearGradient(
    colors: [Color(0xFF1CB0F6), Color(0xFF1899D6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const mathButtonGradient = LinearGradient(
    colors: [Color(0xFF58CC02), Color(0xFF4CAF02)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Surface (배경)
  static const surface = Colors.white;

  // 텍스트 컬러
  static const textPrimary = Color(0xFF3C3C3C); // 주요 텍스트
  static const textSecondary = Color(0xFF777777); // 보조 텍스트
  static const textTertiary = Color(0xFFAFAFAF); // 비활성 텍스트

  // 배경 컬러
  static const background = Colors.white;
  static const backgroundLight = Color(0xFFF7F7F7);

  // 테두리 컬러
  static const borderLight = Color(0xFFE5E5E5);
  static const borderDark = Color(0xFFCCCCCC);

  // 상태 컬러
  static const success = Color(0xFF58CC02); // 성공
  static const error = Color(0xFFFF4B4B); // 오류
  static const warning = Color(0xFFFF9600); // 경고
  static const info = Color(0xFF1CB0F6); // 정보

  // 듀오링고 스타일 배경색
  static const beigOrange = Color(0xFFFFF7ED); // 주황 베이지
  static const beigBlue = Color(0xFFEEF2FF); // 파랑 베이지
  static const beigGreen = Color(0xFFECFDF5); // 녹색 베이지
  static const beigPurple = Color(0xFFF3E8FF); // 보라 베이지

  // 추가 상태 색상
  static const successGreen = Color(0xFF58CC02); // 성공 녹색
  static const errorRed = Color(0xFFFF4B4B); // 에러 빨강
  static const warningOrange = Color(0xFFFF9600); // 경고 주황
  static const disabled = Color(0xFFAFAFAF); // 비활성

  // 프리미엄 색상
  static const premiumGold = Color(0xFFFFD700); // 프리미엄 골드
  static const premiumPurple = Color(0xFFCE82FF); // 프리미엄 보라
  static const premiumGradient = [Color(0xFFFFD700), Color(0xFFFFA500)]; // 프리미엄 그라디언트

  // 헤더 색상
  static const headerText = Colors.white; // 헤더 텍스트
  static const headerBlueGradient = [Color(0xFF1CB0F6), Color(0xFF1899D6)]; // 헤더 블루 그라디언트

  // 레벨 색상
  static const levelBronze = Color(0xFFCD7F32); // 브론즈
  static const levelSilver = Color(0xFFC0C0C0); // 실버
  static const levelGold = Color(0xFFFFD700); // 골드
  static const levelBronzeDark = Color(0xFFA0622E); // 브론즈 다크
  static const levelSilverDark = Color(0xFF909090); // 실버 다크
  static const levelGoldDark = Color(0xFFDAA520); // 골드 다크

  // 다크 변형 색상
  static const mathOrangeDark = Color(0xFFE08600); // 주황 다크
  static const mathGreenDark = Color(0xFF4CAF02); // 녹색 다크

  // 소셜 로그인 색상
  static const kakaoYellow = Color(0xFFFEE500); // 카카오 노랑
  static const kakaoBrown = Color(0xFF3C1E1E); // 카카오 브라운
}
