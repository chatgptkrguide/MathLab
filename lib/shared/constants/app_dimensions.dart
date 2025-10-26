import 'dart:ui';

/// MathLab 앱의 크기 및 간격 상수 정의
class AppDimensions {
  AppDimensions._(); // private constructor

  // 기본 간격
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 12.0;
  static const double spacingL = 16.0;
  static const double spacingXL = 20.0;
  static const double spacingXXL = 24.0;
  static const double spacingXXXL = 32.0;

  // 패딩 추가 크기
  static const double paddingXS = 4.0;
  static const double paddingXXXL = 32.0;

  // 패딩
  static const double paddingS = 8.0;
  static const double paddingM = 12.0;
  static const double paddingL = 16.0;
  static const double paddingXL = 20.0;
  static const double paddingXXL = 24.0;

  // 반지름 - 새 디자인 (더 둥글게)
  static const double radiusS = 8.0;
  static const double radiusM = 16.0;
  static const double radiusL = 20.0;
  static const double radiusXL = 24.0;
  static const double radiusXXL = 32.0;

  // 아이콘 크기
  static const double iconS = 16.0;
  static const double iconM = 20.0;
  static const double iconL = 24.0;
  static const double iconXL = 32.0;
  static const double iconXXL = 48.0;

  // 버튼 높이 (터치 접근성 향상)
  static const double buttonHeightS = 44.0; // 36 → 44 (최소 터치 영역)
  static const double buttonHeightM = 48.0; // 44 → 48
  static const double buttonHeightL = 56.0; // 48 → 56 (주요 버튼)
  static const double buttonHeightXL = 64.0; // 56 → 64 (메인 CTA)

  // 카드 크기
  static const double cardElevation = 2.0;
  static const double cardElevationHover = 4.0;

  // 앱바 높이
  static const double appBarHeight = 56.0;
  static const double tabBarHeight = 48.0;

  // 통계 카드 크기
  static const double statCardHeight = 80.0;
  static const double statCardMinWidth = 80.0;

  // 진행률 바
  static const double progressBarHeight = 8.0;
  static const double progressBarMinHeight = 4.0;

  // 아바타 크기
  static const double avatarS = 24.0;
  static const double avatarM = 32.0;
  static const double avatarL = 48.0;
  static const double avatarXL = 64.0;

  // 리스트 아이템 높이
  static const double listItemHeight = 72.0;
  static const double listItemMinHeight = 56.0;

  // 브레이크포인트 (반응형)
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1024.0;
  static const double desktopBreakpoint = 1440.0;

  // 콘텐츠 최대 너비
  static const double maxContentWidth = 1200.0;

  // 그리드
  static const int mobileColumns = 2;
  static const int tabletColumns = 4;
  static const int desktopColumns = 6;

  // 애니메이션 지속시간
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Navigation Bar (from AppUIConstants)
  static const double navBarBaseHeight = 90.0;
  static const double navBarIconSize = 20.0;
  static const double navBarSpecialIconSize = 26.0;
  static const double navBarSpecialButtonSize = 60.0;

  // Shadow (from AppUIConstants)
  static const double shadowOpacity = 0.15;
  static const double shadowBlurRadius = 16.0;
  static const shadowOffset = Offset(0, -4);
}