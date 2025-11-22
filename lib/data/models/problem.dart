/// 수학 문제 데이터 모델
class Problem {
  final String id;
  final String title;
  final String question;
  final ProblemType type;
  final String category;
  final int difficulty; // 1-5
  final List<String> choices; // 객관식 선택지
  final dynamic answer; // 정답 (객관식: int index, 주관식: String)
  final List<String> hints; // 힌트 리스트
  final String? explanation; // 풀이 설명
  final String? imageUrl; // 문제 이미지 경로
  final String? answerImageUrl; // 답 이미지 경로
  final Map<String, dynamic>? metadata; // 추가 메타데이터

  const Problem({
    required this.id,
    required this.title,
    required this.question,
    required this.type,
    required this.category,
    required this.difficulty,
    this.choices = const [],
    required this.answer,
    this.hints = const [],
    this.explanation,
    this.imageUrl,
    this.answerImageUrl,
    this.metadata,
  });

  // Backward compatibility factory constructor for old code
  factory Problem.legacy({
    required String id,
    String? lessonId,
    required ProblemType type,
    required String question,
    required String category,
    required int difficulty,
    List<String>? tags,
    int? xpReward,
    List<String>? options,
    int? correctAnswerIndex,
    String? correctAnswer,
    String? explanation,
    List<String>? hints,
  }) {
    return Problem(
      id: id,
      title: category,
      question: question,
      type: type,
      category: category,
      difficulty: difficulty,
      choices: options ?? [],
      answer: correctAnswerIndex ?? correctAnswer ?? 0,
      hints: hints ?? [],
      explanation: explanation,
      metadata: {
        if (lessonId != null) 'lessonId': lessonId,
        if (tags != null) 'tags': tags,
        if (xpReward != null) 'xpReward': xpReward,
      },
    );
  }

  factory Problem.fromJson(Map<String, dynamic> json) {
    return Problem(
      id: json['id'] as String,
      title: json['title'] as String,
      question: json['question'] as String,
      type: ProblemType.values.firstWhere(
        (e) => e.toString() == 'ProblemType.${json['type']}',
      ),
      category: json['category'] as String,
      difficulty: json['difficulty'] as int,
      choices: (json['choices'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      answer: json['answer'],
      hints: (json['hints'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      explanation: json['explanation'] as String?,
      imageUrl: json['imageUrl'] as String?,
      answerImageUrl: json['answerImageUrl'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'question': question,
      'type': type.toString().split('.').last,
      'category': category,
      'difficulty': difficulty,
      'choices': choices,
      'answer': answer,
      'hints': hints,
      'explanation': explanation,
      'imageUrl': imageUrl,
      'answerImageUrl': answerImageUrl,
      'metadata': metadata,
    };
  }

  // 기존 코드 호환성을 위한 getter들
  List<String>? get options => choices.isNotEmpty ? choices : null;
  String? get lessonId => metadata?['lessonId'] as String?;
  List<String> get tags => (metadata?['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
  int get xpReward => (metadata?['xpReward'] as int?) ?? 10;
  String? get correctAnswer => answer is String ? answer as String : (answer is int && choices.isNotEmpty ? choices[answer as int] : null);
  int? get correctAnswerIndex => answer is int ? answer as int : null;

  // 한국 교육과정 관련 getter들
  String? get grade => metadata?['grade'] as String?;
  String? get chapter => metadata?['chapter'] as String?;
  String get typeIcon {
    switch (type) {
      case ProblemType.multipleChoice:
        return '✓';
      case ProblemType.shortAnswer:
        return '✎';
      case ProblemType.dragAndDrop:
        return '⇄';
      case ProblemType.stepByStep:
        return '⋯';
      case ProblemType.calculation:
        return '≈';
    }
  }

  bool isCorrectAnswer(int selectedIndex) {
    if (answer is int) {
      return selectedIndex == answer;
    } else if (answer is String && choices.isNotEmpty) {
      return choices[selectedIndex] == answer;
    }
    return false;
  }
}

/// 문제 유형
enum ProblemType {
  multipleChoice, // 객관식
  shortAnswer, // 주관식
  dragAndDrop, // 드래그 앤 드롭
  stepByStep, // 단계별 풀이
  calculation, // 계산 문제 (기존 코드 호환성)
}
