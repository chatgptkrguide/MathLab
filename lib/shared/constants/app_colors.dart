import 'package:flutter/material.dart';

/// Unified color system for the MathLab app.
/// Combines original Duolingo-style colors with Figma design tokens.
class AppColors {
  AppColors._();

  // ============================================================
  // === Brand Primary (single source of truth) ===
  // ============================================================
  static const primary = Color(0xFF1CB0F6); // Math/Duolingo blue
  static const primaryDark = Color(0xFF1899D6); // Button blue
  static const primaryLight = Color(0xFF61A1D8); // Sky blue (Figma)

  // ============================================================
  // === Brand Secondary ===
  // ============================================================
  static const mathBlue = primary; // alias
  static const mathGreen = Color(0xFF58CC02); // Duolingo green
  static const mathGreenLight = Color(0xFF89E219); // Light green (gradient)
  static const mathOrange = Color(0xFFFF9600); // Math orange
  static const mathYellow = Color(0xFFFFC800); // Math yellow
  static const mathPurple = Color(0xFFCE82FF); // Math purple
  static const mathRed = Color(0xFFFF4B4B); // Math red
  static const mathButtonBlue = primaryDark; // alias

  // ============================================================
  // === Figma Accent Colors ===
  // ============================================================
  static const skyBlue = primaryLight; // alias
  static const darkNavy = Color(0xFF211E41); // Splash/login bg
  static const royalBlue = Color(0xFF4575F6); // Accent
  static const deepBlue = Color(0xFF0014F7); // CTA button
  static const gold = Color(0xFFF3C283); // Challenge card
  static const tealGreen = Color(0xFF45A6AD); // Progress bar

  // ============================================================
  // === Semantic Colors ===
  // ============================================================
  static const success = mathGreen; // alias
  static const error = mathRed; // alias
  static const warning = mathOrange; // alias
  static const info = primary; // alias

  // Aliases for backward compatibility
  static const successGreen = mathGreen;
  static const errorRed = mathRed;
  static const warningOrange = mathOrange;
  static const disabled = Color(0xFFAFAFAF);

  // ============================================================
  // === Surface / Background ===
  // ============================================================
  static const surface = Colors.white;
  static const background = Colors.white;
  static const backgroundLight = Color(0xFFF7F7F7);
  static const cardBg = Color(0xFFF5F5F5);
  static const chipBg = Color(0xFFF1F2F1);
  static const profileBg = Color(0xFFE4F5FF);
  static const premiumBg = Color(0xFFD3E9FF);

  // ============================================================
  // === Text Colors ===
  // ============================================================
  static const textPrimary = Color(0xFF3C3C3C); // Main text
  static const textSecondary = Color(0xFF777777); // Secondary text
  static const textTertiary = Color(0xFFAFAFAF); // Inactive text
  static const textDark = Color(0xFF2A2E2D); // Figma main text
  static const textLight = Color(0xFFAAAAAA); // Figma inactive text
  static const textOnPrimary = Colors.white;

  // ============================================================
  // === Border Colors ===
  // ============================================================
  static const borderLight = Color(0xFFE5E5E5);
  static const borderDark = Color(0xFFCCCCCC);

  // ============================================================
  // === Duolingo Pastel Backgrounds ===
  // ============================================================
  static const beigOrange = Color(0xFFFFF7ED);
  static const beigBlue = Color(0xFFEEF2FF);
  static const beigGreen = Color(0xFFECFDF5);
  static const beigPurple = Color(0xFFF3E8FF);

  // ============================================================
  // === Gamification / Levels ===
  // ============================================================
  static const xpGold = Color(0xFFFFC800);
  static const streakOrange = Color(0xFFFF9600);
  static const levelPurple = Color(0xFFCE82FF);

  static const levelBronze = Color(0xFFCD7F32);
  static const levelSilver = Color(0xFFC0C0C0);
  static const levelGold = Color(0xFFFFD700);
  static const levelBronzeDark = Color(0xFFA0622E);
  static const levelSilverDark = Color(0xFF909090);
  static const levelGoldDark = Color(0xFFDAA520);

  // League tier tokens — profile_header _getLeagueInfo 등에서 참조.
  // (levelBronze/levelGold 와 별도 — 위는 단순 레벨 뱃지용 금속 색이고,
  //  아래는 5단계 리그 시스템의 base/gradientEnd 쌍.)
  static const leagueBronze = Color(0xFFCD7F32);
  static const leagueBronzeLight = Color(0xFFDEA05E);
  static const leagueSilver = Color(0xFF78909C);
  static const leagueSilverLight = Color(0xFFB0BEC5);
  static const leagueGold = Color(0xFFFF9800);
  static const leagueGoldLight = Color(0xFFFFB74D);
  static const leagueDiamond = Color(0xFF42A5F5);
  static const leagueDiamondLight = Color(0xFF90CAF9);
  static const leagueMaster = Color(0xFF7E57C2);
  static const leagueMasterLight = Color(0xFFB39DDB);

  // ============================================================
  // === Dark Variants ===
  // ============================================================
  static const mathOrangeDark = Color(0xFFE08600);
  static const mathGreenDark = Color(0xFF4CAF02);

  // ============================================================
  // === Node Colors (Figma lesson path) ===
  // ============================================================
  static const nodeGreen = Color(0xFF58CC02);
  static const nodeLocked = Color(0xFFB0B0B0);
  static const nodeOrange = Color(0xFFFF9600);
  static const nodePurple = Color(0xFFCE82FF);
  static const nodeRed = Color(0xFFFF4B4B);
  static const nodeBoss = Color(0xFF8B5CF6);
  static const nodeActive = Color(0xFF2B59FF);
  static const nodeLockedBg = Color(0xFFE4E9EA);
  static const nodeUnlockedBg = Color(0xFFE4F5FF);
  static const nodeHighlight = Color(0xFFD5F0FF);

  // ============================================================
  // === Premium ===
  // ============================================================
  static const premiumGold = Color(0xFFFFD700);
  static const premiumPurple = Color(0xFFCE82FF);
  static const premiumBlue = Color(0xFF2E90FA);
  static const premiumGradient = [Color(0xFFFFD700), Color(0xFFFFA500)];

  // ============================================================
  // === Badge / Streak (Figma) ===
  // ============================================================
  static const badgeOrange = Color(0xFFFF9121);
  static const streakGold = Color(0xFFFFB53E);

  // ============================================================
  // === Admin ===
  // ============================================================
  static const adminPurple = Color(0xFF9C27B0);
  static const adminPurpleDark = Color(0xFF7B1FA2);
  static const adminGradient = [Color(0xFF9C27B0), Color(0xFF7B1FA2)];

  // ============================================================
  // === Social Login ===
  // ============================================================
  static const googleBlue = Color(0xFF4285F4); // Google brand blue
  static const kakaoYellow = Color(0xFFFEE500);
  static const kakaoBrown = Color(0xFF3C1E1E);

  // ============================================================
  // === Header ===
  // ============================================================
  static const headerText = Colors.white;
  static const headerBlueGradient = [Color(0xFF1CB0F6), Color(0xFF1899D6)];

  // ============================================================
  // === Glassmorphism & Shimmer ===
  // ============================================================
  static const glassBg = Color(0x26FFFFFF); // 15% white
  static const glassBorder = Color(0x33FFFFFF); // 20% white
  static const shimmerBase = Color(0x33FFFFFF);
  static const shimmerHighlight = Color(0x80FFFFFF);
  static const glossyHighlight = Color(0x4DFFFFFF);

  // ============================================================
  // === Gradients ===
  // ============================================================
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

  static const homeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF61A1D8), Color(0xFF5494C8)],
  );

  static const skyBlueGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF61A1D8), Color(0xFF4A8BC2)],
  );

  static const tealGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF45A6AD), Color(0xFF3A8F95)],
  );

  static const deepBlueCTA = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A3CF7), Color(0xFF0014F7)],
  );

  static const greenCTA = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF58CC02), Color(0xFF46A302)],
  );

  static const goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF3C283), Color(0xFFE8A85C)],
  );
}
