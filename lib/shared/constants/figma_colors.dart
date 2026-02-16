import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Figma design colors - deprecated in favor of unified AppColors.
/// All values redirect to AppColors for a single source of truth.
@Deprecated('Use AppColors instead')
class FigmaColors {
  FigmaColors._();

  // === Main Colors ===
  @Deprecated('Use AppColors.skyBlue instead')
  static const Color skyBlue = AppColors.skyBlue;
  @Deprecated('Use AppColors.darkNavy instead')
  static const Color darkNavy = AppColors.darkNavy;
  @Deprecated('Use AppColors.royalBlue instead')
  static const Color royalBlue = AppColors.royalBlue;
  @Deprecated('Use AppColors.deepBlue instead')
  static const Color deepBlue = AppColors.deepBlue;
  @Deprecated('Use AppColors.gold instead')
  static const Color gold = AppColors.gold;
  @Deprecated('Use AppColors.tealGreen instead')
  static const Color tealGreen = AppColors.tealGreen;

  // === Legacy aliases ===
  @Deprecated('Use AppColors.primary instead')
  static const Color primary = AppColors.primary;
  @Deprecated('Use AppColors.mathGreen instead')
  static const Color secondary = AppColors.mathGreen;

  // === Node Colors ===
  @Deprecated('Use AppColors.nodeGreen instead')
  static const Color nodeGreen = AppColors.nodeGreen;
  @Deprecated('Use AppColors.nodeLocked instead')
  static const Color nodeLocked = AppColors.nodeLocked;
  @Deprecated('Use AppColors.nodeOrange instead')
  static const Color nodeOrange = AppColors.nodeOrange;
  @Deprecated('Use AppColors.nodePurple instead')
  static const Color nodePurple = AppColors.nodePurple;
  @Deprecated('Use AppColors.nodeRed instead')
  static const Color nodeRed = AppColors.nodeRed;
  @Deprecated('Use AppColors.nodeBoss instead')
  static const Color nodeBoss = AppColors.nodeBoss;
  @Deprecated('Use AppColors.nodeActive instead')
  static const Color nodeActive = AppColors.nodeActive;
  @Deprecated('Use AppColors.nodeLockedBg instead')
  static const Color nodeLockedBg = AppColors.nodeLockedBg;
  @Deprecated('Use AppColors.nodeUnlockedBg instead')
  static const Color nodeUnlockedBg = AppColors.nodeUnlockedBg;
  @Deprecated('Use AppColors.nodeHighlight instead')
  static const Color nodeHighlight = AppColors.nodeHighlight;

  // === Text / UI Colors ===
  @Deprecated('Use AppColors.textDark instead')
  static const Color textDark = AppColors.textDark;
  @Deprecated('Use AppColors.textSecondary instead')
  static const Color textSecondary = AppColors.textSecondary;
  @Deprecated('Use AppColors.textLight instead')
  static const Color textLight = AppColors.textLight;
  @Deprecated('Use AppColors.cardBg instead')
  static const Color cardBg = AppColors.cardBg;
  @Deprecated('Use AppColors.chipBg instead')
  static const Color chipBg = AppColors.chipBg;
  @Deprecated('Use AppColors.profileBg instead')
  static const Color profileBg = AppColors.profileBg;
  @Deprecated('Use AppColors.premiumBg instead')
  static const Color premiumBg = AppColors.premiumBg;
  @Deprecated('Use AppColors.premiumBlue instead')
  static const Color premiumBlue = AppColors.premiumBlue;
  @Deprecated('Use AppColors.badgeOrange instead')
  static const Color badgeOrange = AppColors.badgeOrange;
  @Deprecated('Use AppColors.streakGold instead')
  static const Color streakGold = AppColors.streakGold;

  // === Gradients ===
  @Deprecated('Use AppColors.homeGradient instead')
  static const LinearGradient homeGradient = AppColors.homeGradient;
  @Deprecated('Use AppColors.skyBlueGradient instead')
  static const LinearGradient skyBlueGradient = AppColors.skyBlueGradient;
  @Deprecated('Use AppColors.tealGradient instead')
  static const LinearGradient tealGradient = AppColors.tealGradient;
  @Deprecated('Use AppColors.deepBlueCTA instead')
  static const LinearGradient deepBlueCTA = AppColors.deepBlueCTA;
  @Deprecated('Use AppColors.greenCTA instead')
  static const LinearGradient greenCTA = AppColors.greenCTA;
  @Deprecated('Use AppColors.goldGradient instead')
  static const LinearGradient goldGradient = AppColors.goldGradient;

  // === Glassmorphism & Shimmer ===
  @Deprecated('Use AppColors.glassBg instead')
  static const Color glassBg = AppColors.glassBg;
  @Deprecated('Use AppColors.glassBorder instead')
  static const Color glassBorder = AppColors.glassBorder;
  @Deprecated('Use AppColors.shimmerBase instead')
  static const Color shimmerBase = AppColors.shimmerBase;
  @Deprecated('Use AppColors.shimmerHighlight instead')
  static const Color shimmerHighlight = AppColors.shimmerHighlight;
  @Deprecated('Use AppColors.glossyHighlight instead')
  static const Color glossyHighlight = AppColors.glossyHighlight;
}
