/// 🏅 Achievement Model
///
/// Represents an achievement badge and user progress

class AchievementModel {
  final String id;
  final String name;
  final String description;
  final AchievementCategory category;
  final AchievementRarity rarity;
  final String iconUrl;
  final AchievementCriteria criteria;
  final Map<String, dynamic> rewards;

  const AchievementModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.rarity,
    required this.iconUrl,
    required this.criteria,
    required this.rewards,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: AchievementCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => AchievementCategory.general,
      ),
      rarity: AchievementRarity.values.firstWhere(
        (e) => e.name == json['rarity'],
        orElse: () => AchievementRarity.common,
      ),
      iconUrl: json['iconUrl'] as String,
      criteria: AchievementCriteria.fromJson(json['criteria'] as Map<String, dynamic>),
      rewards: json['rewards'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'category': category.name,
        'rarity': rarity.name,
        'iconUrl': iconUrl,
        'criteria': criteria.toJson(),
        'rewards': rewards,
      };

  /// Get rarity color
  int get rarityColor {
    switch (rarity) {
      case AchievementRarity.common:
        return 0xFFB0BEC5; // Grey
      case AchievementRarity.rare:
        return 0xFF64B5F6; // Blue
      case AchievementRarity.epic:
        return 0xFF9C27B0; // Purple
      case AchievementRarity.legendary:
        return 0xFFFFB74D; // Orange
    }
  }

  /// Get rarity label
  String get rarityLabel {
    switch (rarity) {
      case AchievementRarity.common:
        return '일반';
      case AchievementRarity.rare:
        return '희귀';
      case AchievementRarity.epic:
        return '영웅';
      case AchievementRarity.legendary:
        return '전설';
    }
  }

  /// Get category icon
  String get categoryIcon {
    switch (category) {
      case AchievementCategory.general:
        return '🎯';
      case AchievementCategory.streak:
        return '🔥';
      case AchievementCategory.mastery:
        return '🎓';
      case AchievementCategory.social:
        return '👥';
      case AchievementCategory.speed:
        return '⚡';
      case AchievementCategory.perfectionist:
        return '💯';
      case AchievementCategory.explorer:
        return '🗺️';
    }
  }
}

/// Achievement category
enum AchievementCategory {
  general, // General achievements
  streak, // Streak-related achievements
  mastery, // Mastery achievements
  social, // Social achievements
  speed, // Speed achievements
  perfectionist, // Perfect score achievements
  explorer, // Content exploration achievements
}

/// Achievement rarity
enum AchievementRarity {
  common,
  rare,
  epic,
  legendary,
}

/// Achievement criteria
class AchievementCriteria {
  final AchievementType type;
  final int targetValue;
  final String? specificRequirement;

  const AchievementCriteria({
    required this.type,
    required this.targetValue,
    this.specificRequirement,
  });

  factory AchievementCriteria.fromJson(Map<String, dynamic> json) {
    return AchievementCriteria(
      type: AchievementType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AchievementType.totalXP,
      ),
      targetValue: json['targetValue'] as int,
      specificRequirement: json['specificRequirement'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'targetValue': targetValue,
        'specificRequirement': specificRequirement,
      };
}

/// Achievement type
enum AchievementType {
  totalXP, // Total XP earned
  streak, // Days of consecutive learning
  lessonsCompleted, // Number of lessons completed
  perfectScore, // Number of perfect scores
  fastSolver, // Problems solved quickly
  accuracy, // Accuracy percentage
  problemsSolved, // Total problems solved
  leagueRank, // League ranking achievement
  helpfulStudent, // Helping others
}

/// User achievement progress
class UserAchievementModel {
  final String id;
  final String userId;
  final String achievementId;
  final int currentProgress;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final bool isNotificationSent;

  const UserAchievementModel({
    required this.id,
    required this.userId,
    required this.achievementId,
    this.currentProgress = 0,
    this.isUnlocked = false,
    this.unlockedAt,
    this.isNotificationSent = false,
  });

  factory UserAchievementModel.fromJson(Map<String, dynamic> json) {
    return UserAchievementModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      achievementId: json['achievementId'] as String,
      currentProgress: json['currentProgress'] as int? ?? 0,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
      isNotificationSent: json['isNotificationSent'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'achievementId': achievementId,
        'currentProgress': currentProgress,
        'isUnlocked': isUnlocked,
        'unlockedAt': unlockedAt?.toIso8601String(),
        'isNotificationSent': isNotificationSent,
      };

  /// Calculate progress percentage
  double getProgressPercentage(int targetValue) {
    if (isUnlocked) return 1.0;
    return (currentProgress / targetValue).clamp(0.0, 1.0);
  }

  /// Check if close to unlocking (>80%)
  bool isCloseToUnlocking(int targetValue) {
    return !isUnlocked && getProgressPercentage(targetValue) >= 0.8;
  }

  UserAchievementModel copyWith({
    String? id,
    String? userId,
    String? achievementId,
    int? currentProgress,
    bool? isUnlocked,
    DateTime? unlockedAt,
    bool? isNotificationSent,
  }) {
    return UserAchievementModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      achievementId: achievementId ?? this.achievementId,
      currentProgress: currentProgress ?? this.currentProgress,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      isNotificationSent: isNotificationSent ?? this.isNotificationSent,
    );
  }
}
