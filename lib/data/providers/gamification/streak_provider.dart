import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_logger.dart';
import '../../../shared/constants/game_constants.dart';
import '../user/user_provider.dart';

class StreakState {
  final bool hasStreakFreeze;
  final int freezesRemaining;
  final DateTime? lastFreezeUsedAt;

  const StreakState({
    this.hasStreakFreeze = false,
    this.freezesRemaining = 0,
    this.lastFreezeUsedAt,
  });

  StreakState copyWith({
    bool? hasStreakFreeze,
    int? freezesRemaining,
    DateTime? lastFreezeUsedAt,
  }) {
    return StreakState(
      hasStreakFreeze: hasStreakFreeze ?? this.hasStreakFreeze,
      freezesRemaining: freezesRemaining ?? this.freezesRemaining,
      lastFreezeUsedAt: lastFreezeUsedAt ?? this.lastFreezeUsedAt,
    );
  }
}

class StreakNotifier extends StateNotifier<StreakState> {
  final Ref _ref;

  StreakNotifier(this._ref) : super(const StreakState()) {
    _syncFromUser();
  }

  void _syncFromUser() {
    final user = _ref.read(userProvider);
    if (user != null) {
      state = StreakState(
        hasStreakFreeze: user.streakFreezes > 0,
        freezesRemaining: user.streakFreezes,
        lastFreezeUsedAt: user.lastFreezeUsedAt,
      );
    }
  }

  /// Purchase streak freeze with gems
  Future<bool> purchaseStreakFreeze() async {
    final userNotifier = _ref.read(userProvider.notifier);
    final user = _ref.read(userProvider);
    if (user == null) return false;

    final cost = GameConstants.streakFreezeGemCost;
    final success = await userNotifier.spendGems(cost);
    if (!success) {
      AppLogger.warning('Not enough gems to purchase streak freeze', tag: 'Streak');
      return false;
    }

    final newFreezes = user.streakFreezes + 1;
    await userNotifier.updateStreakFreezes(newFreezes);

    state = state.copyWith(
      hasStreakFreeze: true,
      freezesRemaining: newFreezes,
    );

    AppLogger.info('Streak freeze purchased', tag: 'Streak', data: {'freezes': newFreezes});
    return true;
  }

  /// Auto-apply freeze when streak would break
  Future<bool> applyStreakFreeze() async {
    if (state.freezesRemaining <= 0) return false;

    final userNotifier = _ref.read(userProvider.notifier);
    final user = _ref.read(userProvider);
    if (user == null) return false;

    final now = DateTime.now();
    final newFreezes = state.freezesRemaining - 1;

    await userNotifier.updateStreakFreezes(newFreezes, lastUsedAt: now);

    state = StreakState(
      hasStreakFreeze: newFreezes > 0,
      freezesRemaining: newFreezes,
      lastFreezeUsedAt: now,
    );

    AppLogger.info('Streak freeze applied', tag: 'Streak', data: {'remaining': newFreezes});
    return true;
  }

  /// Check and handle streak status on app open
  Future<void> checkStreakOnAppOpen() async {
    final user = _ref.read(userProvider);
    if (user == null) return;

    _syncFromUser();

    if (!user.shouldBreakStreak) return;

    // Streak would break - try to apply freeze
    if (state.freezesRemaining > 0) {
      final applied = await applyStreakFreeze();
      if (applied) {
        AppLogger.info('Streak saved by freeze', tag: 'Streak');
        return;
      }
    }

    // No freeze available - streak breaks via updateStreak() in user_provider
    AppLogger.info('Streak will break - no freeze available', tag: 'Streak');
  }
}

final streakProvider = StateNotifierProvider<StreakNotifier, StreakState>((ref) {
  return StreakNotifier(ref);
});
