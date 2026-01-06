import 'package:flutter/material.dart';

/// Figma 디자인에서 추출한 정확한 색상 값들
/// 모든 색상은 Figma API에서 직접 추출하여 100% 동일하게 적용
class FigmaColors {
  FigmaColors._();

  // ========== 배경 그라디언트 ==========
  /// 홈 화면 상단 그라디언트 색상
  static const Color homeGradientTop = Color(0xFF61A1D8);

  /// 홈 화면 하단 그라디언트 색상
  static const Color homeGradientBottom = Color(0xFFA1C9E8);

  /// 홈 화면 배경 그라디언트
  static const LinearGradient homeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [homeGradientTop, homeGradientBottom],
  );

  // ========== 카드 색상 시스템 ==========
  /// 기본 카드 배경 (흰색)
  static const Color cardDefault = Color(0xFFFFFFFF);

  /// 강조 카드 배경 (주황색) - 중요 알림/업적용
  static const Color cardEmphasis = Color(0xFFF3C283);

  /// 정보 카드 배경 (연한 하늘색) - 학습 정보용
  static const Color cardInfo = Color(0xFFE4F5FF);

  /// 액션 카드 배경 (파란색) - 행동 유도용
  static const Color cardAction = Color(0xFFD3E9FF);

  // ========== 진행률 색상 ==========
  /// 진행률 바 색상 (청록색)
  static const Color progressTeal = Color(0xFF45A6AD);

  /// 진행률 바 배경색
  static const Color progressBackground = Color(0xFFE0E0E0);

  // ========== 텍스트 색상 ==========
  /// 기본 텍스트 색상 (검정)
  static const Color textPrimary = Color(0xFF000000);

  /// 보조 텍스트 색상 (회색)
  static const Color textSecondary = Color(0xFF7D8381);

  /// 흰색 텍스트
  static const Color textWhite = Color(0xFFFFFFFF);

  // ========== 추가 색상 ==========
  /// 밝은 파란색
  static const Color brightBlue = Color(0xFF138FD8);

  /// 초록색
  static const Color green = Color(0xFF08C64E);

  /// 빨간색
  static const Color red = Color(0xFFFF0066);

  /// 노란색
  static const Color yellow = Color(0xFFF1CB53);

  /// 보라색
  static const Color purple = Color(0xFF9669A4);

  // ========== 프로필 페이지 전용 색상 ==========
  /// 프로필 상단바 그라디언트
  static const LinearGradient profileTopBarGradient = LinearGradient(
    colors: [Color(0xFF4A9FE8), Color(0xFF5BA5EA)],
  );

  /// 프로필 카드 배경
  static const Color profileCardBackground = Color(0xFFFFFFFF);

  /// 프로필 카드 테두리
  static const Color profileCardBorder = Color(0xFFE8F4FD);

  /// 레벨 뱃지 빨간색
  static const Color levelBadgeRed = Color(0xFFE74C3C);

  /// 레벨 뱃지 금색
  static const Color levelBadgeGold = Color(0xFFFFB84D);

  /// 레벨 진행바 그라디언트
  static const LinearGradient levelProgressGradient = LinearGradient(
    colors: [
      Color(0xFFFF69B4), // 핑크
      Color(0xFFFF8C69), // 코랄
      Color(0xFFFFB84D), // 골드
    ],
  );

  /// 스트릭 카드 배경
  static const Color streakCardBackground = Color(0xFFE8F4FD);

  /// 스트릭 원형 주황색
  static const Color streakCircleOrange = Color(0xFFFF6B35);

  /// 통계 라벨 회색
  static const Color statLabelGray = Color(0xFF9E9E9E);

  /// 통계 값 검정
  static const Color statValueBlack = Color(0xFF1A1A1A);

  /// 탭 선택됨
  static const Color tabSelected = Color(0xFF1A1A1A);

  /// 탭 선택안됨
  static const Color tabUnselected = Color(0xFF9E9E9E);

  /// 작업 주황색
  static const Color taskOrange = Color(0xFFFF8C42);

  /// 프리미엄 배너 배경
  static const Color premiumBackground = Color(0xFFE8F4FD);

  /// 프리미엄 버튼
  static const Color premiumButton = Color(0xFF4A9FE8);

  // ========== 그림자 ==========
  /// 카드 그림자
  static BoxShadow cardShadow = BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 10,
    offset: const Offset(0, 4),
  );

  /// 작은 그림자
  static BoxShadow smallShadow = BoxShadow(
    color: Colors.black.withOpacity(0.05),
    blurRadius: 5,
    offset: const Offset(0, 2),
  );
}

/// Figma 디자인의 정확한 크기 값들
class FigmaSizes {
  FigmaSizes._();

  // ========== 카드 크기 ==========
  /// 기본 카드 너비
  static const double cardWidth = 343.0;

  /// 작은 카드 높이
  static const double cardHeightSmall = 48.0;

  /// 중간 카드 높이
  static const double cardHeightMedium = 76.0;

  /// 일일 목표 카드 높이
  static const double cardHeightGoal = 88.0;

  /// 큰 카드 높이
  static const double cardHeightLarge = 127.0;

  // ========== 원형 요소 크기 ==========
  /// 레벨/XP 원형 배지 크기
  static const double circularBadgeSize = 117.0;

  /// 아이콘 크기 (큰 것)
  static const double iconLarge = 60.0;

  /// 아이콘 크기 (중간)
  static const double iconMedium = 58.0;

  /// 아이콘 크기 (작은 것)
  static const double iconSmall = 24.0;

  // ========== 진행률 바 크기 ==========
  /// 일일 목표 진행률 바 높이
  static const double progressBarHeightGoal = 9.0;

  /// 일반 진행률 바 높이
  static const double progressBarHeightNormal = 12.0;

  // ========== Border Radius ==========
  /// 카드 모서리 둥글기
  static const double cardBorderRadius = 20.0;

  /// 진행률 바 모서리 둥글기
  static const double progressBorderRadius = 4.5;

  /// 작은 요소 모서리 둥글기
  static const double smallBorderRadius = 16.0;

  // ========== 네비게이션 바 ==========
  /// 네비게이션 바 높이
  static const double navbarHeight = 74.0;

  /// 네비게이션 아이콘 크기
  static const double navbarIconSize = 24.0;
}
