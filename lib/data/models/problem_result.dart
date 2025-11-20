/// 문제 풀이 결과 데이터 모델
class ProblemResult {
  final String problemId;
  final String userId;
  final int? selectedAnswerIndex; // 객관식 선택 인덱스
  final String? textAnswer; // 주관식 텍스트 답변
  final bool isCorrect;
  final DateTime solvedAt;
  final int timeSpentSeconds;
  final int xpEarned;
  final int? hintsUsed;

  const ProblemResult({
    required this.problemId,
    required this.userId,
    this.selectedAnswerIndex,
    this.textAnswer,
    required this.isCorrect,
    required this.solvedAt,
    required this.timeSpentSeconds,
    required this.xpEarned,
    this.hintsUsed,
  });

  factory ProblemResult.fromJson(Map<String, dynamic> json) {
    return ProblemResult(
      problemId: json['problemId'] as String,
      userId: json['userId'] as String,
      selectedAnswerIndex: json['selectedAnswerIndex'] as int?,
      textAnswer: json['textAnswer'] as String?,
      isCorrect: json['isCorrect'] as bool,
      solvedAt: DateTime.parse(json['solvedAt'] as String),
      timeSpentSeconds: json['timeSpentSeconds'] as int,
      xpEarned: json['xpEarned'] as int,
      hintsUsed: json['hintsUsed'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'problemId': problemId,
      'userId': userId,
      'selectedAnswerIndex': selectedAnswerIndex,
      'textAnswer': textAnswer,
      'isCorrect': isCorrect,
      'solvedAt': solvedAt.toIso8601String(),
      'timeSpentSeconds': timeSpentSeconds,
      'xpEarned': xpEarned,
      'hintsUsed': hintsUsed,
    };
  }
}
