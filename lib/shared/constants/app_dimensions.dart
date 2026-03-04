/// Unified spacing, sizing, and dimension constants for the MathLab app.
class AppDimensions {
  AppDimensions._();

  // ============================================================
  // === Spacing Scale: 2, 4, 8, 12, 16, 20, 24, 32, 40, 48 ===
  // ============================================================
  static const double spacing2 = 2.0;
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;

  // === Anti-AI: Organic Spacing (non-round numbers) ===
  static const double spacing14 = 14.0;
  static const double spacing18 = 18.0;
  static const double spacing28 = 28.0;
  static const double spacing36 = 36.0;

  // === Spacing aliases (semantic) ===
  static const double spacingXXS = spacing2;
  static const double spacingXS = spacing4;
  static const double spacingS = spacing8;
  static const double spacingM = spacing16;
  static const double spacingL = spacing24;
  static const double spacingXL = spacing32;
  static const double spacingXXL = spacing48;

  // ============================================================
  // === Padding (aliases for spacing) ===
  // ============================================================
  static const double paddingXSmall = spacing4;
  static const double paddingSmall = spacing8;
  static const double paddingMedium = spacing16;
  static const double paddingLarge = spacing24;
  static const double paddingXLarge = spacing32;

  // Short aliases
  static const double paddingXS = paddingXSmall;
  static const double paddingS = paddingSmall;
  static const double paddingM = paddingMedium;
  static const double paddingL = paddingLarge;
  static const double paddingXL = paddingXLarge;

  // ============================================================
  // === Margin (aliases for spacing) ===
  // ============================================================
  static const double marginXSmall = spacing4;
  static const double marginSmall = spacing8;
  static const double marginMedium = spacing16;
  static const double marginLarge = spacing24;
  static const double marginXLarge = spacing32;

  // ============================================================
  // === Border Radius Scale: 4, 6, 8, 10, 12, 16, 20, 24 ===
  // ============================================================
  static const double radius4 = 4.0;
  static const double radius6 = 6.0;
  static const double radius8 = 8.0;
  static const double radius10 = 10.0;
  static const double radius12 = 12.0;
  static const double radius16 = 16.0;
  static const double radius20 = 20.0;
  static const double radius24 = 24.0;
  static const double radiusFull = 999.0;

  // Semantic radius aliases
  static const double radiusS = radius8;
  static const double radiusSmall = radius8;
  static const double radiusM = radius12;
  static const double radiusMedium = radius12;
  static const double radiusL = radius16;
  static const double radiusLarge = radius16;
  static const double radiusXL = radius24;
  static const double radiusXLarge = radius24;

  // ============================================================
  // === Icon Sizes ===
  // ============================================================
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 48.0;

  // ============================================================
  // === Button Heights ===
  // ============================================================
  static const double buttonHeightSmall = 40.0;
  static const double buttonHeightMedium = 48.0;
  static const double buttonHeightLarge = 56.0;

  // Auth screen button heights
  static const double mainButtonHeight = 64.0;
  static const double socialButtonHeight = 56.0;

  // ============================================================
  // === Screen Layout ===
  // ============================================================
  static const double screenHorizontalPadding = 24.0;

  // Auth screen layout
  static const double authMathIsTopSpacing = 40.0;
  static const double authMathIsFunSpacing = 20.0;
  static const double authChatbotTopPosition = 80.0;
  static const double chatbotImageSize = 200.0;
  static const double authGomathButtonSpacing = 60.0;
  static const double authButtonSpacing = 20.0;
  static const double authDividerButtonSpacing = 20.0;
  static const double authButtonSmallSpacing = 12.0;

  // ============================================================
  // === Logo ===
  // ============================================================
  static const double logoWidth = 120.0;
  static const double logoHeight = 40.0;

  // ============================================================
  // === Elevation ===
  // ============================================================
  static const double elevationNone = 0.0;
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
}
