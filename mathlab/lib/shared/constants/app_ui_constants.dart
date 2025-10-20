import 'dart:ui';

/// UI 관련 상수 정의
class AppUIConstants {
  // Navigation Bar
  static const double navBarBaseHeight = 90.0;
  static const double navBarIconSize = 20.0;
  static const double navBarSpecialIconSize = 26.0;
  static const double navBarSpecialButtonSize = 60.0;

  // Shadow
  static const double shadowOpacity = 0.15;
  static const double shadowBlurRadius = 16.0;
  static const Offset shadowOffset = Offset(0, -4);

  // Animation
  static const Duration defaultAnimationDuration = Duration(milliseconds: 200);
  static const Duration longAnimationDuration = Duration(milliseconds: 300);

  // Breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;
}