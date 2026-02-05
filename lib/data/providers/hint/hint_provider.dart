// 💡 Hint Provider
//
// Manages hints and hint usage state

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../models/hint_model.dart';
import '../api_provider.dart';
import '../user/user_provider.dart';

final logger = Logger();

/// Hint State
class HintState {
  final List<HintModel> hints;
  final List<HintModel> unlockedHints;
  final bool isLoading;
  final String? error;

  const HintState({
    this.hints = const [],
    this.unlockedHints = const [],
    this.isLoading = false,
    this.error,
  });

  HintState copyWith({
    List<HintModel>? hints,
    List<HintModel>? unlockedHints,
    bool? isLoading,
    String? error,
  }) {
    return HintState(
      hints: hints ?? this.hints,
      unlockedHints: unlockedHints ?? this.unlockedHints,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  /// Get next available hint
  HintModel? get nextHint {
    final lockedHints = hints
        .where((h) => !unlockedHints.any((uh) => uh.id == h.id))
        .toList();

    if (lockedHints.isEmpty) return null;

    // Sort by level (ascending)
    lockedHints.sort((a, b) => a.level.compareTo(b.level));
    return lockedHints.first;
  }

  /// Check if all hints are unlocked
  bool get allHintsUnlocked => hints.length == unlockedHints.length;

  /// Get progress percentage
  double get progress {
    if (hints.isEmpty) return 0.0;
    return unlockedHints.length / hints.length;
  }
}

/// Hint Notifier
class HintNotifier extends StateNotifier<HintState> {
  final Ref _ref;
  final String problemId;

  HintNotifier(this._ref, this.problemId) : super(const HintState()) {
    loadHints();
  }

  /// Load hints for a problem
  Future<void> loadHints() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final lessonAPI = _ref.read(lessonAPIProvider);

      final hintsData = await lessonAPI.getHints(problemId: problemId);

      final hints = hintsData
          .map((data) => HintModel.fromJson(data))
          .toList();

      // Sort by level
      hints.sort((a, b) => a.level.compareTo(b.level));

      state = state.copyWith(
        hints: hints,
        isLoading: false,
      );

      logger.i('Loaded ${hints.length} hints for problem $problemId');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      logger.e('Failed to load hints: $e');
    }
  }

  /// Unlock a hint
  Future<bool> unlockHint(HintModel hint) async {
    final user = _ref.read(userProvider);
    if (user == null) {
      state = state.copyWith(error: 'User not found');
      return false;
    }

    try {
      final lessonAPI = _ref.read(lessonAPIProvider);

      // Check if user has enough XP or gems
      if (hint.requiresGems) {
        if (user.gems < hint.gemCost!) {
          state = state.copyWith(error: '젬이 부족합니다');
          return false;
        }
      } else {
        if (user.xp < hint.xpCost) {
          state = state.copyWith(error: 'XP가 부족합니다');
          return false;
        }
      }

      // Unlock hint via API
      await lessonAPI.unlockHint(
        userId: user.id,
        problemId: problemId,
        hintId: hint.id,
      );

      // Update local state
      final updatedUnlockedHints = [...state.unlockedHints, hint];

      state = state.copyWith(
        unlockedHints: updatedUnlockedHints,
        error: null,
      );

      // Update user's XP or gems
      if (hint.requiresGems) {
        await _ref.read(userProvider.notifier).spendGems(hint.gemCost!);
      } else {
        await _ref.read(userProvider.notifier).addXp(-hint.xpCost);
      }

      logger.i('Unlocked hint: ${hint.id}');
      return true;
    } catch (e) {
      logger.e('Failed to unlock hint: $e');
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Check if a hint is unlocked
  bool isHintUnlocked(String hintId) {
    return state.unlockedHints.any((h) => h.id == hintId);
  }

  /// Get unlocked hints by level
  List<HintModel> getUnlockedHintsByLevel(int level) {
    return state.unlockedHints.where((h) => h.level == level).toList();
  }

  /// Reset hints (for new problem)
  void reset() {
    state = const HintState();
  }
}

/// Hint Provider (family for different problems)
final hintProvider =
    StateNotifierProvider.family<HintNotifier, HintState, String>(
  (ref, problemId) => HintNotifier(ref, problemId),
);

/// Hint Usage History Provider
final hintUsageHistoryProvider =
    FutureProvider.family<List<HintUsageModel>, String>(
  (ref, userId) async {
    final lessonAPI = ref.watch(lessonAPIProvider);

    try {
      final historyData = await lessonAPI.getHintUsageHistory(userId: userId);

      return historyData
          .map((data) => HintUsageModel.fromJson(data))
          .toList();
    } catch (e) {
      logger.e('Failed to load hint usage history: $e');
      return [];
    }
  },
);
