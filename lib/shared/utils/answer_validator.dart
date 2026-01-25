/// 🎯 Answer Validator
///
/// Provides sophisticated answer validation logic with:
/// - Tolerance for numerical answers
/// - Case-insensitive string comparison
/// - Whitespace normalization
/// - Partial credit support

import 'dart:math';

/// Answer validation result
class ValidationResult {
  final bool isCorrect;
  final double score; // 0.0 to 1.0 (for partial credit)
  final String? feedback;
  final List<String>? hints;

  const ValidationResult({
    required this.isCorrect,
    this.score = 0.0,
    this.feedback,
    this.hints,
  });

  factory ValidationResult.correct({double score = 1.0, String? feedback}) {
    return ValidationResult(
      isCorrect: true,
      score: score,
      feedback: feedback,
    );
  }

  factory ValidationResult.incorrect({String? feedback, List<String>? hints}) {
    return ValidationResult(
      isCorrect: false,
      score: 0.0,
      feedback: feedback,
      hints: hints,
    );
  }

  factory ValidationResult.partialCredit({
    required double score,
    String? feedback,
    List<String>? hints,
  }) {
    return ValidationResult(
      isCorrect: score >= 0.5,
      score: score,
      feedback: feedback,
      hints: hints,
    );
  }
}

/// Answer validation options
class ValidationOptions {
  final bool ignoreCase;
  final bool ignoreWhitespace;
  final double? numericalTolerance; // Percentage tolerance (e.g., 0.01 for 1%)
  final bool allowPartialCredit;

  const ValidationOptions({
    this.ignoreCase = true,
    this.ignoreWhitespace = true,
    this.numericalTolerance,
    this.allowPartialCredit = false,
  });

  static const ValidationOptions strict = ValidationOptions(
    ignoreCase: false,
    ignoreWhitespace: false,
    numericalTolerance: null,
    allowPartialCredit: false,
  );

  static const ValidationOptions lenient = ValidationOptions(
    ignoreCase: true,
    ignoreWhitespace: true,
    numericalTolerance: 0.01, // 1% tolerance
    allowPartialCredit: true,
  );

  static const ValidationOptions mathematical = ValidationOptions(
    ignoreCase: true,
    ignoreWhitespace: true,
    numericalTolerance: 0.001, // 0.1% tolerance
    allowPartialCredit: false,
  );
}

/// Answer validator utility
class AnswerValidator {
  /// Validate a text answer
  static ValidationResult validateText(
    String userAnswer,
    String correctAnswer, {
    ValidationOptions options = const ValidationOptions(),
  }) {
    String processedUser = userAnswer;
    String processedCorrect = correctAnswer;

    // Apply options
    if (options.ignoreWhitespace) {
      processedUser = processedUser.trim().replaceAll(RegExp(r'\s+'), '');
      processedCorrect = processedCorrect.trim().replaceAll(RegExp(r'\s+'), '');
    }

    if (options.ignoreCase) {
      processedUser = processedUser.toLowerCase();
      processedCorrect = processedCorrect.toLowerCase();
    }

    // Check exact match
    if (processedUser == processedCorrect) {
      return ValidationResult.correct(
        feedback: '정답입니다! 🎉',
      );
    }

    // Check partial credit (Levenshtein distance)
    if (options.allowPartialCredit) {
      final similarity = _calculateSimilarity(processedUser, processedCorrect);
      if (similarity > 0.7) {
        return ValidationResult.partialCredit(
          score: similarity,
          feedback: '거의 맞았어요! 철자를 다시 확인해보세요.',
        );
      }
    }

    return ValidationResult.incorrect(
      feedback: '틀렸습니다. 다시 시도해보세요!',
    );
  }

  /// Validate a numerical answer
  static ValidationResult validateNumerical(
    String userAnswer,
    String correctAnswer, {
    ValidationOptions options = const ValidationOptions(),
  }) {
    // Try to parse both as numbers
    final userNum = double.tryParse(userAnswer.trim());
    final correctNum = double.tryParse(correctAnswer.trim());

    if (userNum == null) {
      return ValidationResult.incorrect(
        feedback: '숫자를 입력해주세요.',
      );
    }

    if (correctNum == null) {
      // Fallback to text validation
      return validateText(userAnswer, correctAnswer, options: options);
    }

    // Check exact match
    if (userNum == correctNum) {
      return ValidationResult.correct(
        feedback: '정답입니다! 🎉',
      );
    }

    // Check with tolerance
    if (options.numericalTolerance != null) {
      final tolerance = correctNum.abs() * options.numericalTolerance!;
      final difference = (userNum - correctNum).abs();

      if (difference <= tolerance) {
        return ValidationResult.correct(
          score: 1.0,
          feedback: '정답입니다! (반올림 오차 허용)',
        );
      }

      // Partial credit based on proximity
      if (options.allowPartialCredit) {
        final score = max(0.0, 1.0 - (difference / correctNum.abs()));
        if (score > 0.5) {
          return ValidationResult.partialCredit(
            score: score,
            feedback: '거의 맞았어요! 계산을 다시 확인해보세요.',
          );
        }
      }
    }

    return ValidationResult.incorrect(
      feedback: '틀렸습니다. 계산을 다시 확인해보세요!',
    );
  }

  /// Validate multiple choice answer
  static ValidationResult validateMultipleChoice(
    String userAnswer,
    String correctAnswer,
  ) {
    if (userAnswer == correctAnswer) {
      return ValidationResult.correct(
        feedback: '정답입니다! 🎉',
      );
    }

    return ValidationResult.incorrect(
      feedback: '틀렸습니다. 다시 생각해보세요!',
    );
  }

  /// Validate drag and drop answer
  static ValidationResult validateDragAndDrop(
    Map<String, String> userPlacements,
    Map<String, String> correctPlacements, {
    bool allowPartialCredit = true,
  }) {
    if (userPlacements.isEmpty) {
      return ValidationResult.incorrect(
        feedback: '항목을 배치해주세요.',
      );
    }

    int correctCount = 0;
    int totalCount = correctPlacements.length;

    for (var entry in correctPlacements.entries) {
      if (userPlacements[entry.key] == entry.value) {
        correctCount++;
      }
    }

    final score = correctCount / totalCount;

    if (score == 1.0) {
      return ValidationResult.correct(
        feedback: '모두 정답입니다! 🎉',
      );
    }

    if (allowPartialCredit && score > 0.5) {
      return ValidationResult.partialCredit(
        score: score,
        feedback: '$correctCount / $totalCount 개가 맞았어요! 나머지도 확인해보세요.',
      );
    }

    return ValidationResult.incorrect(
      feedback: '틀렸습니다. 다시 배치해보세요!',
    );
  }

  /// Calculate string similarity (normalized Levenshtein distance)
  static double _calculateSimilarity(String s1, String s2) {
    if (s1 == s2) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    final distance = _levenshteinDistance(s1, s2);
    final maxLength = max(s1.length, s2.length);

    return 1.0 - (distance / maxLength);
  }

  /// Calculate Levenshtein distance between two strings
  static int _levenshteinDistance(String s1, String s2) {
    final len1 = s1.length;
    final len2 = s2.length;

    // Create distance matrix
    final matrix = List.generate(
      len1 + 1,
      (i) => List.filled(len2 + 1, 0),
    );

    // Initialize first row and column
    for (int i = 0; i <= len1; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j <= len2; j++) {
      matrix[0][j] = j;
    }

    // Fill matrix
    for (int i = 1; i <= len1; i++) {
      for (int j = 1; j <= len2; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = min(
          min(
            matrix[i - 1][j] + 1, // deletion
            matrix[i][j - 1] + 1, // insertion
          ),
          matrix[i - 1][j - 1] + cost, // substitution
        );
      }
    }

    return matrix[len1][len2];
  }
}
