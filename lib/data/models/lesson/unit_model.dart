/// 📦 Unit Model
///
/// Represents a unit (collection of lessons) in the curriculum.

import 'lesson_model.dart';

class UnitModel {
  final String id;
  final String title;
  final String description;
  final int order; // Position in the curriculum
  final String emoji; // Unit icon emoji
  final List<LessonModel> lessons;
  final UnitTheme theme;

  const UnitModel({
    required this.id,
    required this.title,
    required this.description,
    required this.order,
    required this.emoji,
    this.lessons = const [],
    this.theme = UnitTheme.blue,
  });

  /// Get total XP available in this unit
  int get totalXP => lessons.fold(0, (sum, lesson) => sum + lesson.xpReward);

  /// Get number of lessons in this unit
  int get lessonCount => lessons.length;

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      order: json['order'] as int,
      emoji: json['emoji'] as String,
      lessons: (json['lessons'] as List<dynamic>?)
              ?.map((e) => LessonModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      theme: UnitTheme.values.firstWhere(
        (e) => e.name == json['theme'],
        orElse: () => UnitTheme.blue,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'order': order,
      'emoji': emoji,
      'lessons': lessons.map((e) => e.toJson()).toList(),
      'theme': theme.name,
    };
  }

  @override
  String toString() => 'UnitModel(id: $id, title: $title, order: $order)';
}

/// Unit Theme (for visual styling)
enum UnitTheme {
  blue,
  green,
  orange,
  purple,
  red,
  yellow,
}
