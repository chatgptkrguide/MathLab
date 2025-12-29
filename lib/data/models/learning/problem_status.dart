/// 문제 풀이 상태 데이터 모델
/// 사용자가 각 문제를 어떻게 풀었는지 추적합니다.
class ProblemStatus {
  final String problemId;
  final String userId;
  final ProblemState state;
  final DateTime? firstAttemptDate;
  final DateTime? lastAttemptDate;
  final int attemptCount;
  final int correctCount;
  final List<ProblemAttempt> attempts;

  ProblemStatus({
    required this.problemId,
    required this.userId,
    required this.state,
    this.firstAttemptDate,
    this.lastAttemptDate,
    this.attemptCount = 0,
    this.correctCount = 0,
    this.attempts = const [],
  });

  /// 정답률 계산
  double get accuracyRate {
    if (attemptCount == 0) return 0.0;
    return (correctCount / attemptCount) * 100;
  }

  /// 마지막 시도가 정답이었는지
  bool get lastAttemptCorrect {
    if (attempts.isEmpty) return false;
    return attempts.last.isCorrect;
  }

  /// 한 번도 맞힌 적이 없는지
  bool get neverCorrect => correctCount == 0;

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'problemId': problemId,
      'userId': userId,
      'state': state.name,
      'firstAttemptDate': firstAttemptDate?.toIso8601String(),
      'lastAttemptDate': lastAttemptDate?.toIso8601String(),
      'attemptCount': attemptCount,
      'correctCount': correctCount,
      'attempts': attempts.map((a) => a.toJson()).toList(),
    };
  }

  /// JSON에서 생성
  factory ProblemStatus.fromJson(Map<String, dynamic> json) {
    return ProblemStatus(
      problemId: json['problemId'] as String,
      userId: json['userId'] as String,
      state: ProblemState.values.firstWhere(
        (e) => e.name == json['state'],
        orElse: () => ProblemState.unsolved,
      ),
      firstAttemptDate: json['firstAttemptDate'] != null
          ? DateTime.parse(json['firstAttemptDate'] as String)
          : null,
      lastAttemptDate: json['lastAttemptDate'] != null
          ? DateTime.parse(json['lastAttemptDate'] as String)
          : null,
      attemptCount: json['attemptCount'] as int,
      correctCount: json['correctCount'] as int,
      attempts: (json['attempts'] as List<dynamic>?)
              ?.map((a) => ProblemAttempt.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// 복사 (업데이트용)
  ProblemStatus copyWith({
    String? problemId,
    String? userId,
    ProblemState? state,
    DateTime? firstAttemptDate,
    DateTime? lastAttemptDate,
    int? attemptCount,
    int? correctCount,
    List<ProblemAttempt>? attempts,
  }) {
    return ProblemStatus(
      problemId: problemId ?? this.problemId,
      userId: userId ?? this.userId,
      state: state ?? this.state,
      firstAttemptDate: firstAttemptDate ?? this.firstAttemptDate,
      lastAttemptDate: lastAttemptDate ?? this.lastAttemptDate,
      attemptCount: attemptCount ?? this.attemptCount,
      correctCount: correctCount ?? this.correctCount,
      attempts: attempts ?? this.attempts,
    );
  }
}

/// 문제 상태
enum ProblemState {
  unsolved('미해결'),
  solved('해결'),
  skipped('건너뜀'),
  reviewing('복습 필요');

  final String label;
  const ProblemState(this.label);
}

/// 문제 풀이 시도 기록
class ProblemAttempt {
  final DateTime attemptDate;
  final bool isCorrect;
  final int timeSpentSeconds;
  final String? userAnswer;
  final String? correctAnswer;

  ProblemAttempt({
    required this.attemptDate,
    required this.isCorrect,
    this.timeSpentSeconds = 0,
    this.userAnswer,
    this.correctAnswer,
  });

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'attemptDate': attemptDate.toIso8601String(),
      'isCorrect': isCorrect,
      'timeSpentSeconds': timeSpentSeconds,
      'userAnswer': userAnswer,
      'correctAnswer': correctAnswer,
    };
  }

  /// JSON에서 생성
  factory ProblemAttempt.fromJson(Map<String, dynamic> json) {
    return ProblemAttempt(
      attemptDate: DateTime.parse(json['attemptDate'] as String),
      isCorrect: json['isCorrect'] as bool,
      timeSpentSeconds: json['timeSpentSeconds'] as int? ?? 0,
      userAnswer: json['userAnswer'] as String?,
      correctAnswer: json['correctAnswer'] as String?,
    );
  }
}

/// 문제 필터 옵션
class ProblemFilter {
  final ProblemState? state;
  final bool? needsReview; // 틀린 문제만
  final bool? neverSolved; // 한 번도 못 푼 문제만
  final DateTime? attemptedAfter;
  final DateTime? attemptedBefore;

  ProblemFilter({
    this.state,
    this.needsReview,
    this.neverSolved,
    this.attemptedAfter,
    this.attemptedBefore,
  });
}

/// 문제 통계
class ProblemStatistics {
  final int totalProblems;
  final int solvedProblems;
  final int unsolvedProblems;
  final int skippedProblems;
  final int reviewingProblems;
  final double overallAccuracy;

  ProblemStatistics({
    required this.totalProblems,
    required this.solvedProblems,
    required this.unsolvedProblems,
    required this.skippedProblems,
    required this.reviewingProblems,
    required this.overallAccuracy,
  });

  /// 해결률
  double get solvedRate {
    if (totalProblems == 0) return 0.0;
    return (solvedProblems / totalProblems) * 100;
  }
}
