/// 🏅 Achievement Provider
///
/// Manages achievements and user progress

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../models/achievement_model.dart';
import '../api_provider.dart';

final logger = Logger();

/// Achievement State
class AchievementState {
  final List<AchievementModel> achievements;
  final Map<String, UserAchievementModel> userProgress;
  final List<AchievementModel> unlockedAchievements;
  final List<AchievementModel> lockedAchievements;
  final bool isLoading;
  final String? error;

  const AchievementState({
    this.achievements = const [],
    this.userProgress = const {},
    this.unlockedAchievements = const [],
    this.lockedAchievements = const [],
    this.isLoading = false,
    this.error,
  });

  AchievementState copyWith({
    List<AchievementModel>? achievements,
    Map<String, UserAchievementModel>? userProgress,
    List<AchievementModel>? unlockedAchievements,
    List<AchievementModel>? lockedAchievements,
    bool? isLoading,
    String? error,
  }) {
    return AchievementState(
      achievements: achievements ?? this.achievements,
      userProgress: userProgress ?? this.userProgress,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      lockedAchievements: lockedAchievements ?? this.lockedAchievements,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  /// Get progress for achievement
  UserAchievementModel? getProgress(String achievementId) {
    return userProgress[achievementId];
  }

  /// Check if achievement is unlocked
  bool isUnlocked(String achievementId) {
    return userProgress[achievementId]?.isUnlocked ?? false;
  }

  /// Get completion percentage
  double getCompletionPercentage() {
    if (achievements.isEmpty) return 0.0;
    return unlockedAchievements.length / achievements.length;
  }

  /// Get achievements by category
  List<AchievementModel> getByCategory(AchievementCategory category) {
    return achievements.where((a) => a.category == category).toList();
  }

  /// Get achievements by rarity
  List<AchievementModel> getByRarity(AchievementRarity rarity) {
    return achievements.where((a) => a.rarity == rarity).toList();
  }
}

/// Achievement Notifier
class AchievementNotifier extends StateNotifier<AchievementState> {
  final Ref _ref;
  final String userId;

  AchievementNotifier(this._ref, this.userId) : super(const AchievementState()) {
    loadAchievements();
  }

  /// Load all achievements and user progress
  Future<void> loadAchievements() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final achievementAPI = _ref.read(achievementAPIProvider);

      // Load all achievements
      final achievementsData = await achievementAPI.getAchievements();
      final achievements = (achievementsData as List)
          .map((data) => AchievementModel.fromJson(data))
          .toList();

      // Load user progress
      final progressData =
          await achievementAPI.getUserAchievementProgress(userId: userId);
      final progressList = (progressData as List)
          .map((data) => UserAchievementModel.fromJson(data))
          .toList();

      // Create progress map
      final progressMap = <String, UserAchievementModel>{};
      for (var progress in progressList) {
        progressMap[progress.achievementId] = progress;
      }

      // Separate unlocked and locked
      final unlocked = <AchievementModel>[];
      final locked = <AchievementModel>[];

      for (var achievement in achievements) {
        final progress = progressMap[achievement.id];
        if (progress?.isUnlocked ?? false) {
          unlocked.add(achievement);
        } else {
          locked.add(achievement);
        }
      }

      state = state.copyWith(
        achievements: achievements,
        userProgress: progressMap,
        unlockedAchievements: unlocked,
        lockedAchievements: locked,
        isLoading: false,
      );

      logger.i('Loaded ${achievements.length} achievements');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      logger.e('Failed to load achievements: $e');
    }
  }

  /// Check for newly unlocked achievements
  Future<List<AchievementModel>> checkForUnlocks() async {
    try {
      final achievementAPI = _ref.read(achievementAPIProvider);

      final newlyUnlockedData =
          await achievementAPI.checkAchievements(userId: userId);

      final newlyUnlocked = (newlyUnlockedData as List)
          .map((data) => AchievementModel.fromJson(data))
          .toList();

      if (newlyUnlocked.isNotEmpty) {
        // Reload achievements to get updated progress
        await loadAchievements();
        logger.i('Unlocked ${newlyUnlocked.length} new achievements');
      }

      return newlyUnlocked;
    } catch (e) {
      logger.e('Failed to check for unlocks: $e');
      return [];
    }
  }

  /// Get achievements close to unlocking
  List<AchievementModel> getCloseToUnlocking() {
    return state.lockedAchievements.where((achievement) {
      final progress = state.userProgress[achievement.id];
      if (progress == null) return false;
      return progress.isCloseToUnlocking(achievement.criteria.targetValue);
    }).toList();
  }

  /// Filter achievements by category
  void filterByCategory(AchievementCategory? category) {
    if (category == null) {
      // Show all
      final unlocked = <AchievementModel>[];
      final locked = <AchievementModel>[];

      for (var achievement in state.achievements) {
        final progress = state.userProgress[achievement.id];
        if (progress?.isUnlocked ?? false) {
          unlocked.add(achievement);
        } else {
          locked.add(achievement);
        }
      }

      state = state.copyWith(
        unlockedAchievements: unlocked,
        lockedAchievements: locked,
      );
    } else {
      // Filter by category
      final categoryAchievements =
          state.achievements.where((a) => a.category == category).toList();

      final unlocked = <AchievementModel>[];
      final locked = <AchievementModel>[];

      for (var achievement in categoryAchievements) {
        final progress = state.userProgress[achievement.id];
        if (progress?.isUnlocked ?? false) {
          unlocked.add(achievement);
        } else {
          locked.add(achievement);
        }
      }

      state = state.copyWith(
        unlockedAchievements: unlocked,
        lockedAchievements: locked,
      );
    }
  }
}

/// Achievement Provider
final achievementProvider = StateNotifierProvider.family<
    AchievementNotifier,
    AchievementState,
    String>(
  (ref, userId) => AchievementNotifier(ref, userId),
);

/// Recent Achievements Provider
final recentAchievementsProvider =
    FutureProvider.family<List<AchievementModel>, String>(
  (ref, userId) async {
    final achievementAPI = ref.watch(achievementAPIProvider);

    try {
      final recentData = await achievementAPI.getRecentAchievements(
        userId: userId,
        limit: 5,
      );

      return (recentData as List)
          .map((data) => AchievementModel.fromJson(data))
          .toList();
    } catch (e) {
      logger.e('Failed to load recent achievements: $e');
      return [];
    }
  },
);
