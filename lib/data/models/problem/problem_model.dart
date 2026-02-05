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
  final String? hint; // Hint for the problem
  final int points; // Points awarded for correct answer
  final String? imageUrl; // Optional image for the problem

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
    this.points = 10,
    this.imageUrl,
  });

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
      points: json['points'] as int? ?? 10,
      imageUrl: json['imageUrl'] as String?,
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
      'points': points,
      'imageUrl': imageUrl,
    };
  }

  @override
  String toString() => 'ProblemModel(id: $id, question: $question)';
}

/// Problem Type
enum ProblemType {
  multipleChoice, // Multiple choice (4 options)
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
}
