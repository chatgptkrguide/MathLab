import '../../shared/constants/game_constants.dart';

class HeartRegenService {
  const HeartRegenService._();

  /// Calculate how many hearts should be regenerated since lastHeartLostAt.
  static int calculateRegenHearts({
    required DateTime lastLostAt,
    required int currentHearts,
    required int maxHearts,
  }) {
    if (currentHearts >= maxHearts) return 0;

    final elapsed = DateTime.now().difference(lastLostAt);
    final regenCount = elapsed.inMinutes ~/ GameConstants.heartRegenMinutes;
    final heartsToAdd = regenCount.clamp(0, maxHearts - currentHearts);
    return heartsToAdd;
  }

  /// Get the Duration until the next heart regenerates.
  /// Returns null if hearts are full.
  static Duration? getNextRegenDuration({
    required DateTime lastLostAt,
    required int currentHearts,
    required int maxHearts,
  }) {
    if (currentHearts >= maxHearts) return null;

    final elapsed = DateTime.now().difference(lastLostAt);
    final regenPeriod = Duration(minutes: GameConstants.heartRegenMinutes);
    final elapsedInCurrentCycle = Duration(
      milliseconds: elapsed.inMilliseconds % regenPeriod.inMilliseconds,
    );
    final remaining = regenPeriod - elapsedInCurrentCycle;
    return remaining;
  }
}
