import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/heart_regen_service.dart';
import '../user/user_provider.dart';

class HeartRegenState {
  final int nextRegenSeconds;

  const HeartRegenState({this.nextRegenSeconds = 0});
}

class HeartRegenNotifier extends StateNotifier<HeartRegenState> {
  final Ref ref;
  Timer? _timer;

  HeartRegenNotifier(this.ref) : super(const HeartRegenState()) {
    _init();
  }

  void _init() {
    _applyPendingRegen();
    _startTimer();
  }

  /// Apply hearts that should have regenerated while the app was inactive.
  void _applyPendingRegen() {
    final user = ref.read(userProvider);
    if (user == null) return;
    if (user.hearts >= user.maxHearts) return;
    if (user.lastHeartLostAt == null) return;

    final heartsToAdd = HeartRegenService.calculateRegenHearts(
      lastLostAt: user.lastHeartLostAt!,
      currentHearts: user.hearts,
      maxHearts: user.maxHearts,
    );

    if (heartsToAdd > 0) {
      final newHearts = user.hearts + heartsToAdd;
      final isFull = newHearts >= user.maxHearts;
      ref.read(userProvider.notifier).updateHearts(
            newHearts,
            clearLastHeartLostAt: isFull,
          );
    }

    _updateCountdown();
  }

  /// Called when the app returns to foreground.
  void onAppResumed() {
    _applyPendingRegen();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _tick();
    });
  }

  void _tick() {
    final user = ref.read(userProvider);
    if (user == null ||
        user.hearts >= user.maxHearts ||
        user.lastHeartLostAt == null) {
      state = const HeartRegenState(nextRegenSeconds: 0);
      return;
    }

    final remaining = HeartRegenService.getNextRegenDuration(
      lastLostAt: user.lastHeartLostAt!,
      currentHearts: user.hearts,
      maxHearts: user.maxHearts,
    );

    if (remaining == null || remaining.inSeconds <= 0) {
      _applyPendingRegen();
      return;
    }

    state = HeartRegenState(nextRegenSeconds: remaining.inSeconds);
  }

  void _updateCountdown() {
    final user = ref.read(userProvider);
    if (user == null ||
        user.hearts >= user.maxHearts ||
        user.lastHeartLostAt == null) {
      state = const HeartRegenState(nextRegenSeconds: 0);
      return;
    }

    final remaining = HeartRegenService.getNextRegenDuration(
      lastLostAt: user.lastHeartLostAt!,
      currentHearts: user.hearts,
      maxHearts: user.maxHearts,
    );

    state = HeartRegenState(
      nextRegenSeconds: remaining?.inSeconds ?? 0,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final heartRegenProvider =
    StateNotifierProvider<HeartRegenNotifier, HeartRegenState>((ref) {
  return HeartRegenNotifier(ref);
});
