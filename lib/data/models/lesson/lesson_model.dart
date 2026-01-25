/// 📚 Lesson Model
///
/// Represents a single lesson with learning content and progress tracking.

class LessonModel {
  final String id;
  final String title;
  final String description;
  final int order; // Position in the unit
  final int xpReward; // XP earned upon completion
  final LessonType type;
  final LessonDifficulty difficulty;
  final List<String> concepts; // Math concepts covered
  final int estimatedMinutes;

  const LessonModel({
    required this.id,
    required this.title,
    required this.description,
    required this.order,
    this.xpReward = 10,
    this.type = LessonType.standard,
    this.difficulty = LessonDifficulty.beginner,
    this.concepts = const [],
    this.estimatedMinutes = 5,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      order: json['order'] as int,
      xpReward: json['xpReward'] as int? ?? 10,
      type: LessonType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => LessonType.standard,
      ),
      difficulty: LessonDifficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => LessonDifficulty.beginner,
      ),
      concepts: List<String>.from(json['concepts'] ?? []),
      estimatedMinutes: json['estimatedMinutes'] as int? ?? 5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'order': order,
      'xpReward': xpReward,
      'type': type.name,
      'difficulty': difficulty.name,
      'concepts': concepts,
      'estimatedMinutes': estimatedMinutes,
    };
  }

  @override
  String toString() => 'LessonModel(id: $id, title: $title, order: $order)';
}

/// Lesson Type
enum LessonType {
  standard, // Regular lesson
  story, // Story-based lesson
  practice, // Practice exercises
  review, // Review lesson
  challenge, // Challenge lesson
  boss, // Boss/Test lesson
}

/// Lesson Difficulty
enum LessonDifficulty {
  beginner,
  intermediate,
  advanced,
  expert,
}
