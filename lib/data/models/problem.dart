/// 간소화된 수학 문제 모델 (에러 수정 버전)
class Problem {
  final String id;
  final String lessonId; // 호환성을 위해 lessonId 유지
  final String question;
  final ProblemType type;
  final String explanation;
  final String category;
  final int difficulty;
  final List<String> tags;
  final int xpReward;

  // 객관식용
  final List<String>? options;
  final int? correctAnswerIndex;

  // 주관식용
  final String? correctAnswer;
  final String? inputHint;

  const Problem({
    required this.id,
    required this.lessonId,
    required this.question,
    required this.type,
    required this.explanation,
    required this.category,
    required this.difficulty,
    required this.tags,
    required this.xpReward,
    this.options,
    this.correctAnswerIndex,
    this.correctAnswer,
    this.inputHint,
  });

  factory Problem.fromJson(Map<String, dynamic> json) {
    return Problem(
      id: json['id'] as String,
      lessonId: json['lessonId'] ?? json['episodeId'] ?? 'lesson001',
      question: json['question'] as String,
      type: ProblemType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => ProblemType.multipleChoice,
      ),
      explanation: json['explanation'] as String,
      category: json['category'] as String,
      difficulty: json['difficulty'] as int,
      tags: List<String>.from(json['tags'] as List),
      xpReward: json['xpReward'] as int,
      options: json['options'] != null ? List<String>.from(json['options']) : null,
      correctAnswerIndex: json['correctAnswerIndex'] as int?,
      correctAnswer: json['correctAnswer'] as String?,
      inputHint: json['inputHint'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lessonId': lessonId,
      'question': question,
      'type': type.toString().split('.').last,
      'explanation': explanation,
      'category': category,
      'difficulty': difficulty,
      'tags': tags,
      'xpReward': xpReward,
      if (options != null) 'options': options,
      if (correctAnswerIndex != null) 'correctAnswerIndex': correctAnswerIndex,
      if (correctAnswer != null) 'correctAnswer': correctAnswer,
      if (inputHint != null) 'inputHint': inputHint,
    };
  }

  /// 정답 확인 (객관식)
  bool isCorrectAnswer(int selectedIndex) {
    if (type != ProblemType.multipleChoice || correctAnswerIndex == null) {
      return false;
    }
    return selectedIndex == correctAnswerIndex;
  }

  /// 정답 확인 (주관식)
  bool isCorrectTextAnswer(String userAnswer) {
    if (correctAnswer == null) return false;
    return userAnswer.trim().toLowerCase() == correctAnswer!.trim().toLowerCase();
  }

  /// 문제 유형별 아이콘
  String get typeIcon {
    switch (type) {
      case ProblemType.multipleChoice:
        return '📝';
      case ProblemType.shortAnswer:
        return '✏️';
      case ProblemType.calculation:
        return '🔢';
      default:
        return '❓';
    }
  }

  /// 난이도 텍스트
  String get difficultyText {
    switch (difficulty) {
      case 1: return '매우 쉬움';
      case 2: return '쉬움';
      case 3: return '보통';
      case 4: return '어려움';
      case 5: return '매우 어려움';
      default: return '보통';
    }
  }

  Problem copyWith({
    String? id,
    String? lessonId,
    String? question,
    ProblemType? type,
    String? explanation,
    String? category,
    int? difficulty,
    List<String>? tags,
    int? xpReward,
    List<String>? options,
    int? correctAnswerIndex,
    String? correctAnswer,
    String? inputHint,
  }) {
    return Problem(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      question: question ?? this.question,
      type: type ?? this.type,
      explanation: explanation ?? this.explanation,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      tags: tags ?? this.tags,
      xpReward: xpReward ?? this.xpReward,
      options: options ?? this.options,
      correctAnswerIndex: correctAnswerIndex ?? this.correctAnswerIndex,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      inputHint: inputHint ?? this.inputHint,
    );
  }

  @override
  String toString() => 'Problem{id: $id, type: $type}';

  @override
  bool operator ==(Object other) => other is Problem && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// 문제 유형 (간소화)
enum ProblemType {
  multipleChoice, // 객관식
  shortAnswer, // 주관식
  calculation, // 계산
}

/// 문제 풀이 결과 (간소화)
class ProblemResult {
  final String problemId;
  final String userId;
  final int? selectedAnswerIndex;
  final String? textAnswer;
  final bool isCorrect;
  final DateTime solvedAt;
  final int timeSpentSeconds;
  final int xpEarned;

  const ProblemResult({
    required this.problemId,
    required this.userId,
    this.selectedAnswerIndex,
    this.textAnswer,
    required this.isCorrect,
    required this.solvedAt,
    required this.timeSpentSeconds,
    required this.xpEarned,
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
    };
  }

  @override
  String toString() => 'ProblemResult{problemId: $problemId, isCorrect: $isCorrect}';
}