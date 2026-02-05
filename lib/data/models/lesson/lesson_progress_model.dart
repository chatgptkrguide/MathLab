// 📊 Lesson Progress Model
//
// Tracks user's progress for a specific lesson.

import 'package:cloud_firestore/cloud_firestore.dart';

class LessonProgressModel {
  final String lessonId;
  final String userId;
  final LessonStatus status;
  final int stars; // 0-3 stars earned
  final int attemptsCount;
  final int correctAnswers;
  final int totalQuestions;
  final int xpEarned;
  final DateTime? completedAt;
  final DateTime? lastAttemptedAt;

  const LessonProgressModel({
    required this.lessonId,
    required this.userId,
    this.status = LessonStatus.locked,
    this.stars = 0,
    this.attemptsCount = 0,
    this.correctAnswers = 0,
    this.totalQuestions = 0,
    this.xpEarned = 0,
    this.completedAt,
    this.lastAttemptedAt,
  });

  /// Check if lesson is unlocked
  bool get isUnlocked => status != LessonStatus.locked;

  /// Check if lesson is completed
  bool get isCompleted => status == LessonStatus.completed;

  /// Get accuracy percentage
  double get accuracy {
    if (totalQuestions == 0) return 0;
    return (correctAnswers / totalQuestions).clamp(0.0, 1.0);
  }

  /// Check if can earn perfect stars (3 stars)
  bool get isPerfect => stars == 3;

  factory LessonProgressModel.fromJson(Map<String, dynamic> json) {
    return LessonProgressModel(
      lessonId: json['lessonId'] as String,
      userId: json['userId'] as String,
      status: LessonStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => LessonStatus.locked,
      ),
      stars: json['stars'] as int? ?? 0,
      attemptsCount: json['attemptsCount'] as int? ?? 0,
      correctAnswers: json['correctAnswers'] as int? ?? 0,
      totalQuestions: json['totalQuestions'] as int? ?? 0,
      xpEarned: json['xpEarned'] as int? ?? 0,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      lastAttemptedAt: json['lastAttemptedAt'] != null
          ? DateTime.parse(json['lastAttemptedAt'] as String)
          : null,
    );
  }

  /// Firestore에서 문서 변환
  factory LessonProgressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LessonProgressModel(
      lessonId: doc.id,
      userId: data['userId'] as String? ?? '',
      status: LessonStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => LessonStatus.locked,
      ),
      stars: data['stars'] as int? ?? 0,
      attemptsCount: data['attemptsCount'] as int? ?? 0,
      correctAnswers: data['correctAnswers'] as int? ?? 0,
      totalQuestions: data['totalQuestions'] as int? ?? 0,
      xpEarned: data['xpEarned'] as int? ?? 0,
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      lastAttemptedAt: data['lastAttemptedAt'] != null
          ? (data['lastAttemptedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Firestore 저장용 맵 변환
  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'status': status.name,
        'stars': stars,
        'attemptsCount': attemptsCount,
        'correctAnswers': correctAnswers,
        'totalQuestions': totalQuestions,
        'xpEarned': xpEarned,
        'completedAt':
            completedAt != null ? Timestamp.fromDate(completedAt!) : null,
        'lastAttemptedAt': lastAttemptedAt != null
            ? Timestamp.fromDate(lastAttemptedAt!)
            : null,
      };

  Map<String, dynamic> toJson() {
    return {
      'lessonId': lessonId,
      'userId': userId,
      'status': status.name,
      'stars': stars,
      'attemptsCount': attemptsCount,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'xpEarned': xpEarned,
      'completedAt': completedAt?.toIso8601String(),
      'lastAttemptedAt': lastAttemptedAt?.toIso8601String(),
    };
  }

  LessonProgressModel copyWith({
    String? lessonId,
    String? userId,
    LessonStatus? status,
    int? stars,
    int? attemptsCount,
    int? correctAnswers,
    int? totalQuestions,
    int? xpEarned,
    DateTime? completedAt,
    DateTime? lastAttemptedAt,
  }) {
    return LessonProgressModel(
      lessonId: lessonId ?? this.lessonId,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      stars: stars ?? this.stars,
      attemptsCount: attemptsCount ?? this.attemptsCount,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      xpEarned: xpEarned ?? this.xpEarned,
      completedAt: completedAt ?? this.completedAt,
      lastAttemptedAt: lastAttemptedAt ?? this.lastAttemptedAt,
    );
  }

  @override
  String toString() {
    return 'LessonProgressModel(lessonId: $lessonId, status: $status, stars: $stars)';
  }
}

/// Lesson Status
enum LessonStatus {
  locked, // Not accessible yet
  unlocked, // Can start
  inProgress, // Started but not completed
  completed, // Finished
}
