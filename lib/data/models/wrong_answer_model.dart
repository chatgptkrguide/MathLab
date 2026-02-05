/// 📝 Wrong Answer Model
///
/// Represents a problem that was answered incorrectly

import 'package:cloud_firestore/cloud_firestore.dart';

class WrongAnswerModel {
  final String id;
  final String userId;
  final String problemId;
  final String lessonId;
  final String lessonName;
  final String unitName;
  final String problemText;
  final String userAnswer;
  final String correctAnswer;
  final String? explanation;
  final DateTime attemptDate;
  final int attemptCount;
  final bool isRetried;
  final bool isResolved;
  final DateTime? resolvedDate;

  const WrongAnswerModel({
    required this.id,
    required this.userId,
    required this.problemId,
    required this.lessonId,
    required this.lessonName,
    required this.unitName,
    required this.problemText,
    required this.userAnswer,
    required this.correctAnswer,
    this.explanation,
    required this.attemptDate,
    this.attemptCount = 1,
    this.isRetried = false,
    this.isResolved = false,
    this.resolvedDate,
  });

  factory WrongAnswerModel.fromJson(Map<String, dynamic> json) {
    return WrongAnswerModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      problemId: json['problemId'] as String,
      lessonId: json['lessonId'] as String,
      lessonName: json['lessonName'] as String,
      unitName: json['unitName'] as String,
      problemText: json['problemText'] as String,
      userAnswer: json['userAnswer'] as String,
      correctAnswer: json['correctAnswer'] as String,
      explanation: json['explanation'] as String?,
      attemptDate: DateTime.parse(json['attemptDate'] as String),
      attemptCount: json['attemptCount'] as int? ?? 1,
      isRetried: json['isRetried'] as bool? ?? false,
      isResolved: json['isResolved'] as bool? ?? false,
      resolvedDate: json['resolvedDate'] != null
          ? DateTime.parse(json['resolvedDate'] as String)
          : null,
    );
  }

  /// Firestore에서 문서 변환
  factory WrongAnswerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WrongAnswerModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      problemId: data['problemId'] as String? ?? '',
      lessonId: data['lessonId'] as String? ?? '',
      lessonName: data['lessonName'] as String? ?? '',
      unitName: data['unitName'] as String? ?? '',
      problemText: data['problemText'] as String? ?? '',
      userAnswer: data['userAnswer'] as String? ?? '',
      correctAnswer: data['correctAnswer'] as String? ?? '',
      explanation: data['explanation'] as String?,
      attemptDate: data['attemptDate'] != null
          ? (data['attemptDate'] as Timestamp).toDate()
          : DateTime.now(),
      attemptCount: data['attemptCount'] as int? ?? 1,
      isRetried: data['isRetried'] as bool? ?? false,
      isResolved: data['isResolved'] as bool? ?? false,
      resolvedDate: data['resolvedDate'] != null
          ? (data['resolvedDate'] as Timestamp).toDate()
          : null,
    );
  }

  /// Firestore 저장용 맵 변환
  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'problemId': problemId,
        'lessonId': lessonId,
        'lessonName': lessonName,
        'unitName': unitName,
        'problemText': problemText,
        'userAnswer': userAnswer,
        'correctAnswer': correctAnswer,
        'explanation': explanation,
        'attemptDate': Timestamp.fromDate(attemptDate),
        'attemptCount': attemptCount,
        'isRetried': isRetried,
        'isResolved': isResolved,
        'resolvedDate':
            resolvedDate != null ? Timestamp.fromDate(resolvedDate!) : null,
      };

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'problemId': problemId,
        'lessonId': lessonId,
        'lessonName': lessonName,
        'unitName': unitName,
        'problemText': problemText,
        'userAnswer': userAnswer,
        'correctAnswer': correctAnswer,
        'explanation': explanation,
        'attemptDate': attemptDate.toIso8601String(),
        'attemptCount': attemptCount,
        'isRetried': isRetried,
        'isResolved': isResolved,
        'resolvedDate': resolvedDate?.toIso8601String(),
      };

  WrongAnswerModel copyWith({
    String? id,
    String? userId,
    String? problemId,
    String? lessonId,
    String? lessonName,
    String? unitName,
    String? problemText,
    String? userAnswer,
    String? correctAnswer,
    String? explanation,
    DateTime? attemptDate,
    int? attemptCount,
    bool? isRetried,
    bool? isResolved,
    DateTime? resolvedDate,
  }) {
    return WrongAnswerModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      problemId: problemId ?? this.problemId,
      lessonId: lessonId ?? this.lessonId,
      lessonName: lessonName ?? this.lessonName,
      unitName: unitName ?? this.unitName,
      problemText: problemText ?? this.problemText,
      userAnswer: userAnswer ?? this.userAnswer,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      explanation: explanation ?? this.explanation,
      attemptDate: attemptDate ?? this.attemptDate,
      attemptCount: attemptCount ?? this.attemptCount,
      isRetried: isRetried ?? this.isRetried,
      isResolved: isResolved ?? this.isResolved,
      resolvedDate: resolvedDate ?? this.resolvedDate,
    );
  }

  /// Get days since last attempt
  int get daysSinceAttempt {
    return DateTime.now().difference(attemptDate).inDays;
  }

  /// Check if this should be reviewed (spaced repetition)
  bool shouldReview() {
    if (isResolved) return false;

    // Review intervals: 1, 3, 7, 14 days
    final intervals = [1, 3, 7, 14];
    final daysSince = daysSinceAttempt;

    for (var interval in intervals) {
      if (daysSince >= interval && attemptCount <= intervals.indexOf(interval) + 1) {
        return true;
      }
    }

    return false;
  }
}
