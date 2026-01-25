/// 🎯 Practice Session Model
///
/// Represents a practice session without consequences

class PracticeSessionModel {
  final String id;
  final String userId;
  final String? lessonId;
  final String? unitId;
  final PracticeMode mode;
  final DateTime startTime;
  final DateTime? endTime;
  final List<PracticeProblemAttempt> attempts;
  final PracticeSessionStats stats;

  const PracticeSessionModel({
    required this.id,
    required this.userId,
    this.lessonId,
    this.unitId,
    required this.mode,
    required this.startTime,
    this.endTime,
    this.attempts = const [],
    required this.stats,
  });

  factory PracticeSessionModel.fromJson(Map<String, dynamic> json) {
    return PracticeSessionModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      lessonId: json['lessonId'] as String?,
      unitId: json['unitId'] as String?,
      mode: PracticeMode.values.firstWhere(
        (e) => e.name == json['mode'],
        orElse: () => PracticeMode.free,
      ),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      attempts: json['attempts'] != null
          ? (json['attempts'] as List)
              .map((e) =>
                  PracticeProblemAttempt.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      stats: PracticeSessionStats.fromJson(json['stats'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'lessonId': lessonId,
        'unitId': unitId,
        'mode': mode.name,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'attempts': attempts.map((e) => e.toJson()).toList(),
        'stats': stats.toJson(),
      };

  /// Check if session is active
  bool get isActive => endTime == null;

  /// Get session duration
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  /// Get mode icon
  String get modeIcon {
    switch (mode) {
      case PracticeMode.free:
        return '🆓';
      case PracticeMode.timed:
        return '⏱️';
      case PracticeMode.weakAreas:
        return '💪';
      case PracticeMode.wrongAnswers:
        return '📝';
      case PracticeMode.mixed:
        return '🎲';
    }
  }

  /// Get mode description
  String get modeDescription {
    switch (mode) {
      case PracticeMode.free:
        return '자유 연습';
      case PracticeMode.timed:
        return '시간 제한 연습';
      case PracticeMode.weakAreas:
        return '취약 영역 연습';
      case PracticeMode.wrongAnswers:
        return '오답 복습';
      case PracticeMode.mixed:
        return '혼합 문제';
    }
  }

  PracticeSessionModel copyWith({
    String? id,
    String? userId,
    String? lessonId,
    String? unitId,
    PracticeMode? mode,
    DateTime? startTime,
    DateTime? endTime,
    List<PracticeProblemAttempt>? attempts,
    PracticeSessionStats? stats,
  }) {
    return PracticeSessionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      lessonId: lessonId ?? this.lessonId,
      unitId: unitId ?? this.unitId,
      mode: mode ?? this.mode,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      attempts: attempts ?? this.attempts,
      stats: stats ?? this.stats,
    );
  }
}

/// Practice mode types
enum PracticeMode {
  free, // No restrictions, no consequences
  timed, // Time limit per problem
  weakAreas, // Focus on weak areas
  wrongAnswers, // Review wrong answers
  mixed, // Mix of different problem types
}

/// Practice problem attempt
class PracticeProblemAttempt {
  final String problemId;
  final String userAnswer;
  final bool isCorrect;
  final int timeTaken;
  final DateTime attemptTime;
  final int hintUsed;

  const PracticeProblemAttempt({
    required this.problemId,
    required this.userAnswer,
    required this.isCorrect,
    required this.timeTaken,
    required this.attemptTime,
    this.hintUsed = 0,
  });

  factory PracticeProblemAttempt.fromJson(Map<String, dynamic> json) {
    return PracticeProblemAttempt(
      problemId: json['problemId'] as String,
      userAnswer: json['userAnswer'] as String,
      isCorrect: json['isCorrect'] as bool,
      timeTaken: json['timeTaken'] as int,
      attemptTime: DateTime.parse(json['attemptTime'] as String),
      hintUsed: json['hintUsed'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'problemId': problemId,
        'userAnswer': userAnswer,
        'isCorrect': isCorrect,
        'timeTaken': timeTaken,
        'attemptTime': attemptTime.toIso8601String(),
        'hintUsed': hintUsed,
      };
}

/// Practice session statistics
class PracticeSessionStats {
  final int totalProblems;
  final int correctAnswers;
  final int incorrectAnswers;
  final int hintsUsed;
  final int averageTime;
  final double accuracy;

  const PracticeSessionStats({
    this.totalProblems = 0,
    this.correctAnswers = 0,
    this.incorrectAnswers = 0,
    this.hintsUsed = 0,
    this.averageTime = 0,
    this.accuracy = 0.0,
  });

  factory PracticeSessionStats.fromJson(Map<String, dynamic> json) {
    return PracticeSessionStats(
      totalProblems: json['totalProblems'] as int? ?? 0,
      correctAnswers: json['correctAnswers'] as int? ?? 0,
      incorrectAnswers: json['incorrectAnswers'] as int? ?? 0,
      hintsUsed: json['hintsUsed'] as int? ?? 0,
      averageTime: json['averageTime'] as int? ?? 0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalProblems': totalProblems,
        'correctAnswers': correctAnswers,
        'incorrectAnswers': incorrectAnswers,
        'hintsUsed': hintsUsed,
        'averageTime': averageTime,
        'accuracy': accuracy,
      };

  /// Calculate stats from attempts
  factory PracticeSessionStats.fromAttempts(
      List<PracticeProblemAttempt> attempts) {
    if (attempts.isEmpty) {
      return const PracticeSessionStats();
    }

    final totalProblems = attempts.length;
    final correctAnswers =
        attempts.where((a) => a.isCorrect).length;
    final incorrectAnswers = totalProblems - correctAnswers;
    final hintsUsed = attempts.fold<int>(0, (sum, a) => sum + a.hintUsed);
    final totalTime = attempts.fold<int>(0, (sum, a) => sum + a.timeTaken);
    final averageTime = (totalTime / totalProblems).round();
    final accuracy = correctAnswers / totalProblems;

    return PracticeSessionStats(
      totalProblems: totalProblems,
      correctAnswers: correctAnswers,
      incorrectAnswers: incorrectAnswers,
      hintsUsed: hintsUsed,
      averageTime: averageTime,
      accuracy: accuracy,
    );
  }

  PracticeSessionStats copyWith({
    int? totalProblems,
    int? correctAnswers,
    int? incorrectAnswers,
    int? hintsUsed,
    int? averageTime,
    double? accuracy,
  }) {
    return PracticeSessionStats(
      totalProblems: totalProblems ?? this.totalProblems,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      incorrectAnswers: incorrectAnswers ?? this.incorrectAnswers,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      averageTime: averageTime ?? this.averageTime,
      accuracy: accuracy ?? this.accuracy,
    );
  }
}
