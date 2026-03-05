// SM-2 Spaced Repetition Algorithm Engine

class SrsResult {
  final int nextInterval;
  final double nextEaseFactor;
  final int nextRepetition;
  final DateTime nextReviewDate;

  const SrsResult({
    required this.nextInterval,
    required this.nextEaseFactor,
    required this.nextRepetition,
    required this.nextReviewDate,
  });
}

class SrsEngine {
  /// Calculate next review schedule using SM-2 algorithm.
  ///
  /// [quality] 0-5 scale:
  ///   0 = complete blackout
  ///   1 = wrong, but recognized answer
  ///   2 = wrong, but answer seemed easy to recall
  ///   3 = correct with serious difficulty
  ///   4 = correct with some hesitation
  ///   5 = correct with ease
  static SrsResult calculate({
    required int quality,
    required int repetition,
    required double easeFactor,
    required int interval,
  }) {
    final clampedQuality = quality.clamp(0, 5);

    int nextRepetition;
    int nextInterval;
    double nextEaseFactor;

    if (clampedQuality >= 3) {
      // Correct response
      nextRepetition = repetition + 1;
      if (repetition == 0) {
        nextInterval = 1;
      } else if (repetition == 1) {
        nextInterval = 6;
      } else {
        nextInterval = (interval * easeFactor).round();
      }
    } else {
      // Incorrect response — reset
      nextRepetition = 0;
      nextInterval = 1;
    }

    // Update ease factor
    nextEaseFactor = easeFactor +
        (0.1 - (5 - clampedQuality) * (0.08 + (5 - clampedQuality) * 0.02));
    if (nextEaseFactor < 1.3) nextEaseFactor = 1.3;

    final nextReviewDate =
        DateTime.now().add(Duration(days: nextInterval));

    return SrsResult(
      nextInterval: nextInterval,
      nextEaseFactor: nextEaseFactor,
      nextRepetition: nextRepetition,
      nextReviewDate: nextReviewDate,
    );
  }

  /// Convert user difficulty rating (1=easy, 2=normal, 3=hard) to SM-2 quality.
  /// For correct answers only.
  static int difficultyToQuality(int difficulty) {
    switch (difficulty) {
      case 1:
        return 5; // easy
      case 2:
        return 4; // normal
      case 3:
        return 3; // hard
      default:
        return 4; // default to normal
    }
  }

  /// Convert wrong answer to SM-2 quality (always < 3).
  static int wrongAnswerQuality() => 1;
}
