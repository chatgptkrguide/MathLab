// ❓ Problem Model
//
// Represents a math problem with question, answers, and metadata.

class ProblemModel {
  final String id;
  final String lessonId;
  final String question; // Question text
  final ProblemType type;
  final ProblemDifficulty difficulty;
  final List<String> options; // For multiple choice
  final String correctAnswer;
  final String? explanation; // Explanation for the answer
  final String? hint; // Hint for the problem (legacy, use hints instead)
  final List<String> hints; // Step-by-step hints (단계별 힌트)
  final int points; // Points awarded for correct answer
  final String? imageUrl; // Optional single image (legacy, use imageUrls)
  final List<String> imageUrls; // Multiple images for the problem

  const ProblemModel({
    required this.id,
    required this.lessonId,
    required this.question,
    required this.type,
    this.difficulty = ProblemDifficulty.easy,
    this.options = const [],
    required this.correctAnswer,
    this.explanation,
    this.hint,
    this.hints = const [],
    this.points = 10,
    this.imageUrl,
    this.imageUrls = const [],
  });

  /// All images (imageUrls list or legacy single imageUrl)
  List<String> get allImages {
    if (imageUrls.isNotEmpty) return imageUrls;
    if (imageUrl != null) return [imageUrl!];
    return [];
  }

  /// 모든 힌트 가져오기 (hints 리스트 또는 레거시 hint)
  List<String> get allHints {
    if (hints.isNotEmpty) return hints;
    if (hint != null) return [hint!];
    return [];
  }

  factory ProblemModel.fromJson(Map<String, dynamic> json) {
    return ProblemModel(
      id: json['id'] as String,
      lessonId: json['lessonId'] as String,
      question: json['question'] as String,
      type: ProblemType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ProblemType.multipleChoice,
      ),
      difficulty: ProblemDifficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => ProblemDifficulty.easy,
      ),
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'] as String,
      explanation: json['explanation'] as String?,
      hint: json['hint'] as String?,
      hints: List<String>.from(json['hints'] ?? []),
      points: json['points'] as int? ?? 10,
      imageUrl: json['imageUrl'] as String?,
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lessonId': lessonId,
      'question': question,
      'type': type.name,
      'difficulty': difficulty.name,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'hint': hint,
      'hints': hints,
      'points': points,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
    };
  }

  @override
  String toString() => 'ProblemModel(id: $id, question: $question)';
}

/// Problem Type
enum ProblemType {
  multipleChoice, // Multiple choice (4 options)
  shortAnswer, // Short answer
  trueFalse, // True/False
  fillInBlank, // Fill in the blank
  matching, // Matching pairs
  dragAndDrop, // Drag and drop
}

/// Problem Difficulty
enum ProblemDifficulty {
  easy,
  medium,
  hard,
  expert,
}
