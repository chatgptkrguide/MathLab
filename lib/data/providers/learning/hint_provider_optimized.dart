// 💡 Hint Provider Optimized
//
// Optimized hint management with XP-based unlock system

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/learning/problem.dart';
import '../user/user_provider.dart';

/// Hint state for optimized provider
class HintStateOptimized {
  final Set<String> unlockedHints;
  final bool isLoading;
  final String? error;

  const HintStateOptimized({
    this.unlockedHints = const {},
    this.isLoading = false,
    this.error,
  });

  HintStateOptimized copyWith({
    Set<String>? unlockedHints,
    bool? isLoading,
    String? error,
  }) {
    return HintStateOptimized(
      unlockedHints: unlockedHints ?? this.unlockedHints,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Optimized hint notifier with XP cost system
class HintProviderOptimized extends StateNotifier<HintStateOptimized> {
  final Ref _ref;

  /// Cost in XP to unlock a hint
  static const int hintCost = 20;

  HintProviderOptimized(this._ref) : super(const HintStateOptimized());

  /// Unlock a hint for a problem
  Future<bool> unlockHint(Problem problem, int hintIndex) async {
    final hintKey = '${problem.id}_$hintIndex';

    // Already unlocked
    if (state.unlockedHints.contains(hintKey)) return true;

    // Check user XP
    final user = _ref.read(userProvider);
    if (user == null || user.xp < hintCost) {
      state = state.copyWith(error: 'XP가 부족합니다');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      // Deduct XP
      await _ref.read(userProvider.notifier).addXp(-hintCost);

      // Update unlocked hints
      final updatedHints = {...state.unlockedHints, hintKey};
      state = state.copyWith(
        unlockedHints: updatedHints,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '힌트 잠금 해제에 실패했습니다',
      );
      return false;
    }
  }

  /// Check if a hint is unlocked
  bool isHintUnlocked(String problemId, int hintIndex) {
    return state.unlockedHints.contains('${problemId}_$hintIndex');
  }

  /// Reset hints
  void reset() {
    state = const HintStateOptimized();
  }
}

/// Provider for optimized hint management
final hintProviderOptimized =
    StateNotifierProvider<HintProviderOptimized, HintStateOptimized>(
  (ref) => HintProviderOptimized(ref),
);
