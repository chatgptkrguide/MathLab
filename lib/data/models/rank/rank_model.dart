// Rank Model
//
// Represents a user's rank/level in the gamification system.
// Based on Figma design "07_랭크 아이콘".
//
// 3 categories x 4 levels = 12 total ranks:
// - GT (영재/Gifted): GT Lv1, GT Lv2, GT Lv3, GT레전드
// - H (심화/Honor): H Lv1, H Lv2, H Lv3, H 레전드
// - A (기본/Advanced): A Lv1, A Lv2, A Lv3, A레전드

import 'package:flutter/material.dart';

/// Rank category representing the difficulty track.
enum RankCategory {
  gt, // 영재 (Gifted)
  h, // 심화 (Honor)
  a, // 기본 (Advanced)
}

/// Rank level within a category.
enum RankLevel {
  lv1,
  lv2,
  lv3,
  legend,
}

class RankModel {
  final RankCategory category;
  final RankLevel level;

  const RankModel({
    required this.category,
    required this.level,
  });

  /// Default rank for new users.
  static RankModel defaultRank() => const RankModel(
        category: RankCategory.h,
        level: RankLevel.lv1,
      );

  // ---------------------------------------------------------------------------
  // Display helpers
  // ---------------------------------------------------------------------------

  /// Human-readable name, e.g. "H Lv1", "GT레전드".
  String get displayName {
    final prefix = _categoryPrefix;
    if (level == RankLevel.legend) {
      // Korean convention: no space before 레전드 for GT/A, space for H
      switch (category) {
        case RankCategory.gt:
          return 'GT레전드';
        case RankCategory.h:
          return 'H 레전드';
        case RankCategory.a:
          return 'A레전드';
      }
    }
    return '$prefix Lv$_levelNumber';
  }

  /// Compact name for badges/tags, e.g. "HLv1", "GTL".
  String get shortName {
    final prefix = _categoryPrefix;
    if (level == RankLevel.legend) {
      return '${prefix}L';
    }
    return '${prefix}Lv$_levelNumber';
  }

  /// Korean description of the category.
  String get categoryDisplayName {
    switch (category) {
      case RankCategory.gt:
        return '영재';
      case RankCategory.h:
        return '심화';
      case RankCategory.a:
        return '기본';
    }
  }

  /// Korean description of the level.
  String get levelDisplayName {
    if (level == RankLevel.legend) return '레전드';
    return 'Lv$_levelNumber';
  }

  // ---------------------------------------------------------------------------
  // Visual properties
  // ---------------------------------------------------------------------------

  /// Primary colour for the rank category.
  Color get color {
    switch (category) {
      case RankCategory.gt:
        return const Color(0xFF9C27B0); // Purple
      case RankCategory.h:
        return const Color(0xFF2196F3); // Blue
      case RankCategory.a:
        return const Color(0xFF4CAF50); // Green
    }
  }

  /// A lighter tint for backgrounds / badges.
  Color get lightColor {
    switch (category) {
      case RankCategory.gt:
        return const Color(0xFFE1BEE7); // Purple 100
      case RankCategory.h:
        return const Color(0xFFBBDEFB); // Blue 100
      case RankCategory.a:
        return const Color(0xFFC8E6C9); // Green 100
    }
  }

  /// Fallback icon (used until actual image assets are provided).
  IconData get icon {
    if (level == RankLevel.legend) {
      return Icons.stars_rounded;
    }
    switch (level) {
      case RankLevel.lv1:
        return Icons.shield_outlined;
      case RankLevel.lv2:
        return Icons.shield_rounded;
      case RankLevel.lv3:
        return Icons.military_tech_rounded;
      case RankLevel.legend:
        return Icons.stars_rounded; // Already handled above, kept for exhaustive switch.
    }
  }

  /// Expected asset path, e.g. 'assets/images/ranks/h_lv1.png'.
  String get assetPath {
    final catKey = _categoryPrefix.toLowerCase();
    final lvKey = level == RankLevel.legend ? 'legend' : 'lv$_levelNumber';
    return 'assets/images/ranks/${catKey}_$lvKey.png';
  }

  // ---------------------------------------------------------------------------
  // Ordering / comparison
  // ---------------------------------------------------------------------------

  /// Numeric value for ordering (higher = better). GT > H > A, legend > lv3 > lv2 > lv1.
  int get numericValue {
    final categoryScore = _categoryScore * 10;
    final levelScore = _levelScore;
    return categoryScore + levelScore;
  }

  /// Whether this rank is higher than [other].
  bool isHigherThan(RankModel other) => numericValue > other.numericValue;

  // ---------------------------------------------------------------------------
  // Serialisation
  // ---------------------------------------------------------------------------

  factory RankModel.fromJson(Map<String, dynamic> json) {
    return RankModel(
      category: RankCategory.values.firstWhere(
        (e) => e.name == json['category'] as String,
        orElse: () => RankCategory.h,
      ),
      level: RankLevel.values.firstWhere(
        (e) => e.name == json['level'] as String,
        orElse: () => RankLevel.lv1,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'category': category.name,
        'level': level.name,
      };

  // ---------------------------------------------------------------------------
  // Static helpers
  // ---------------------------------------------------------------------------

  /// All 12 ranks ordered from lowest (A Lv1) to highest (GT Legend).
  static List<RankModel> get allRanks {
    final ranks = <RankModel>[];
    for (final cat in [RankCategory.a, RankCategory.h, RankCategory.gt]) {
      for (final lv in RankLevel.values) {
        ranks.add(RankModel(category: cat, level: lv));
      }
    }
    return ranks;
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  String get _categoryPrefix {
    switch (category) {
      case RankCategory.gt:
        return 'GT';
      case RankCategory.h:
        return 'H';
      case RankCategory.a:
        return 'A';
    }
  }

  int get _levelNumber {
    switch (level) {
      case RankLevel.lv1:
        return 1;
      case RankLevel.lv2:
        return 2;
      case RankLevel.lv3:
        return 3;
      case RankLevel.legend:
        return 4;
    }
  }

  int get _categoryScore {
    switch (category) {
      case RankCategory.a:
        return 1;
      case RankCategory.h:
        return 2;
      case RankCategory.gt:
        return 3;
    }
  }

  int get _levelScore {
    switch (level) {
      case RankLevel.lv1:
        return 1;
      case RankLevel.lv2:
        return 2;
      case RankLevel.lv3:
        return 3;
      case RankLevel.legend:
        return 4;
    }
  }

  // ---------------------------------------------------------------------------
  // Equality & toString
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RankModel &&
          runtimeType == other.runtimeType &&
          category == other.category &&
          level == other.level;

  @override
  int get hashCode => Object.hash(category, level);

  @override
  String toString() => 'RankModel($displayName)';
}
