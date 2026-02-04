/// Re-export problem models from problem directory
export '../problem/problem_model.dart';
export '../problem/problem_session_model.dart';

/// Problem alias used by hint system
/// Extends ProblemModel with hint support for the problem-solving UI
class Problem {
  final String id;
  final String lessonId;
  final String question;
  final String correctAnswer;
  final String? explanation;
  final List<String> options;
  final List<String> hints;
  final int points;
  final String? imageUrl;

  const Problem({
    required this.id,
    required this.lessonId,
    required this.question,
    required this.correctAnswer,
    this.explanation,
    this.options = const [],
    this.hints = const [],
    this.points = 10,
    this.imageUrl,
  });

  factory Problem.fromJson(Map<String, dynamic> json) {
    return Problem(
      id: json['id'] as String,
      lessonId: json['lessonId'] as String,
      question: json['question'] as String,
      correctAnswer: json['correctAnswer'] as String,
      explanation: json['explanation'] as String?,
      options: List<String>.from(json['options'] ?? []),
      hints: List<String>.from(json['hints'] ?? []),
      points: json['points'] as int? ?? 10,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'lessonId': lessonId,
        'question': question,
        'correctAnswer': correctAnswer,
        'explanation': explanation,
        'options': options,
        'hints': hints,
        'points': points,
        'imageUrl': imageUrl,
      };
}
