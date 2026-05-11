// ❓ Problem Model
//
// Represents a math problem with question, answers, and metadata.
//
// Legacy compatibility:
//   레거시 Firestore 문서는 단수 'hint' / 'imageUrl' 키를 사용했다.
//   fromJson 이 단수 키를 읽으면 hints / imageUrls 리스트에 흡수하므로
//   기존 문서를 다시 마이그레이션하지 않아도 동작이 동일하다.
//   toJson 은 더 이상 단수 키를 쓰지 않는다.

class ProblemModel {
  final String id;
  final String lessonId;
  final String question; // Question text
  final ProblemType type;
  final ProblemDifficulty difficulty;
  final List<String> options; // For multiple choice
  final String correctAnswer;
  final String? explanation; // Explanation for the answer
  final List<String> hints; // Step-by-step hints (단계별 힌트)
  final int points; // Points awarded for correct answer
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
    this.hints = const [],
    this.points = 10,
    this.imageUrls = const [],
  });

  /// All images — 외부 호출자 호환 목적. 현재는 imageUrls 와 동일.
  List<String> get allImages => imageUrls;

  /// 모든 힌트 — 외부 호출자 호환 목적. 현재는 hints 와 동일.
  List<String> get allHints => hints;

  factory ProblemModel.fromJson(Map<String, dynamic> json) {
    final hintsList = List<String>.from(json['hints'] ?? const []);
    final legacyHint = json['hint'] as String?;
    if (hintsList.isEmpty && legacyHint != null && legacyHint.isNotEmpty) {
      hintsList.add(legacyHint);
    }

    final imageUrlsList = List<String>.from(json['imageUrls'] ?? const []);
    final legacyImageUrl = json['imageUrl'] as String?;
    if (imageUrlsList.isEmpty &&
        legacyImageUrl != null &&
        legacyImageUrl.isNotEmpty) {
      imageUrlsList.add(legacyImageUrl);
    }

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
      options: List<String>.from(json['options'] ?? const []),
      correctAnswer: json['correctAnswer'] as String,
      explanation: json['explanation'] as String?,
      hints: hintsList,
      points: json['points'] as int? ?? 10,
      imageUrls: imageUrlsList,
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
      'hints': hints,
      'points': points,
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
