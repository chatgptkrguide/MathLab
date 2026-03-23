// 💡 Hint Provider
//
// Hint management with XP-based unlock system

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/problem/problem_model.dart';

/// Hint state
class HintState {
  final Set<String> unlockedHints;
  final bool isLoading;
  final String? error;

  const HintState({
    this.unlockedHints = const {},
    this.isLoading = false,
    this.error,
  });

  HintState copyWith({
    Set<String>? unlockedHints,
    bool? isLoading,
    String? error,
  }) {
    return HintState(
      unlockedHints: unlockedHints ?? this.unlockedHints,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Hint notifier (free unlock)
class HintNotifier extends StateNotifier<HintState> {
  /// Cost in XP to unlock a hint (0 = free)
  static const int hintCost = 0;

  HintNotifier(Ref ref) : super(const HintState());

  /// Unlock a hint for a problem (currently free)
  Future<bool> unlockHint(ProblemModel problem, int hintIndex) async {
    final hintKey = '${problem.id}_$hintIndex';

    // Already unlocked
    if (state.unlockedHints.contains(hintKey)) return true;

    state = state.copyWith(isLoading: true, error: null);

    try {
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
    state = const HintState();
  }
}

/// Provider for hint management
final hintProvider =
    StateNotifierProvider<HintNotifier, HintState>(
  (ref) => HintNotifier(ref),
);

