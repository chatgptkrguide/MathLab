// 📊 Problem Session Model
//
// Tracks a user's problem-solving session for a lesson.

import 'problem_model.dart';

class ProblemSessionModel {
  final String sessionId;
  final String lessonId;
  final String userId;
  final List<ProblemModel> problems;
  final Map<String, String> userAnswers; // problemId -> answer
  final Map<String, bool> correctness; // problemId -> isCorrect
  final int currentProblemIndex;
  final int hearts; // Remaining hearts
  final int score; // Current score
  final DateTime startedAt;
  final SessionStatus status;

  const ProblemSessionModel({
    required this.sessionId,
    required this.lessonId,
    required this.userId,
    required this.problems,
    this.userAnswers = const {},
    this.correctness = const {},
    this.currentProblemIndex = 0,
    this.hearts = 5,
    this.score = 0,
    required this.startedAt,
    this.status = SessionStatus.inProgress,
  });

  /// Get current problem
  ProblemModel? get currentProblem {
    if (currentProblemIndex >= 0 && currentProblemIndex < problems.length) {
      return problems[currentProblemIndex];
    }
    return null;
  }

  /// Check if session is completed
  bool get isCompleted => currentProblemIndex >= problems.length;

  /// Get total problems
  int get totalProblems => problems.length;

  /// Get answered problems count
  int get answeredCount => userAnswers.length;

  /// Get correct answers count
  int get correctCount => correctness.values.where((v) => v).length;

  /// Get accuracy percentage
  double get accuracy {
    if (answeredCount == 0) return 0;
    return (correctCount / answeredCount).clamp(0.0, 1.0);
  }

  /// Get progress percentage
  double get progress {
    if (totalProblems == 0) return 0;
    return (currentProblemIndex / totalProblems).clamp(0.0, 1.0);
  }

  /// Calculate stars earned (0-3)
  int get starsEarned {
    if (accuracy >= 0.9) return 3;
    if (accuracy >= 0.7) return 2;
    if (accuracy >= 0.5) return 1;
    return 0;
  }

  ProblemSessionModel copyWith({
    String? sessionId,
    String? lessonId,
    String? userId,
    List<ProblemModel>? problems,
    Map<String, String>? userAnswers,
    Map<String, bool>? correctness,
    int? currentProblemIndex,
    int? hearts,
    int? score,
    DateTime? startedAt,
    SessionStatus? status,
  }) {
    return ProblemSessionModel(
      sessionId: sessionId ?? this.sessionId,
      lessonId: lessonId ?? this.lessonId,
      userId: userId ?? this.userId,
      problems: problems ?? this.problems,
      userAnswers: userAnswers ?? this.userAnswers,
      correctness: correctness ?? this.correctness,
      currentProblemIndex: currentProblemIndex ?? this.currentProblemIndex,
      hearts: hearts ?? this.hearts,
      score: score ?? this.score,
      startedAt: startedAt ?? this.startedAt,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'ProblemSessionModel(sessionId: $sessionId, progress: ${(progress * 100).toStringAsFixed(1)}%, accuracy: ${(accuracy * 100).toStringAsFixed(1)}%)';
  }
}

/// Session Status
enum SessionStatus {
  inProgress,
  completed,
  abandoned,
}
