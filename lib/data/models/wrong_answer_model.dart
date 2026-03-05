// 📝 Wrong Answer Model
//
// Represents a problem that was answered incorrectly

import 'package:cloud_firestore/cloud_firestore.dart';

class WrongAnswerModel {
  final String id;
  final String lessonId;
  final String lessonTitle;
  final String problemId;
  final String problemType;
  final String question;
  final String correctAnswer;
  final String userAnswer;
  final String? hint;
  final String? explanation;
  final DateTime attemptDate;
  final int attemptCount;
  final bool isRetried;
  final bool isResolved;
  final DateTime? resolvedDate;
  final double easeFactor;
  final int interval;
  final int repetition;
  final DateTime? nextReviewDate;
  final int difficulty;

  const WrongAnswerModel({
    required this.id,
    required this.lessonId,
    required this.lessonTitle,
    required this.problemId,
    required this.problemType,
    required this.question,
    required this.correctAnswer,
    required this.userAnswer,
    this.hint,
    this.explanation,
    required this.attemptDate,
    this.attemptCount = 1,
    this.isRetried = false,
    this.isResolved = false,
    this.resolvedDate,
    this.easeFactor = 2.5,
    this.interval = 1,
    this.repetition = 0,
    this.nextReviewDate,
    this.difficulty = 0,
  });

  /// 레거시 필드 호환용 (기존 코드와 호환)
  String get lessonName => lessonTitle;
  String get unitName => lessonId.split('_').first;
  String get problemText => question;

  factory WrongAnswerModel.fromJson(Map<String, dynamic> json) {
    return WrongAnswerModel(
      id: json['id'] as String,
      lessonId: json['lessonId'] as String,
      lessonTitle: json['lessonTitle'] as String? ?? json['lessonName'] as String? ?? '',
      problemId: json['problemId'] as String,
      problemType: json['problemType'] as String? ?? 'multipleChoice',
      question: json['question'] as String? ?? json['problemText'] as String? ?? '',
      correctAnswer: json['correctAnswer'] as String,
      userAnswer: json['userAnswer'] as String,
      hint: json['hint'] as String?,
      explanation: json['explanation'] as String?,
      attemptDate: DateTime.parse(json['attemptDate'] as String),
      attemptCount: json['attemptCount'] as int? ?? 1,
      isRetried: json['isRetried'] as bool? ?? false,
      isResolved: json['isResolved'] as bool? ?? false,
      resolvedDate: json['resolvedDate'] != null
          ? DateTime.parse(json['resolvedDate'] as String)
          : null,
      easeFactor: (json['easeFactor'] as num?)?.toDouble() ?? 2.5,
      interval: json['interval'] as int? ?? 1,
      repetition: json['repetition'] as int? ?? 0,
      nextReviewDate: json['nextReviewDate'] != null
          ? DateTime.parse(json['nextReviewDate'] as String)
          : null,
      difficulty: json['difficulty'] as int? ?? 0,
    );
  }

  /// Firestore에서 문서 변환
  factory WrongAnswerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WrongAnswerModel(
      id: doc.id,
      lessonId: data['lessonId'] as String? ?? '',
      lessonTitle: data['lessonTitle'] as String? ?? data['lessonName'] as String? ?? '',
      problemId: data['problemId'] as String? ?? '',
      problemType: data['problemType'] as String? ?? 'multipleChoice',
      question: data['question'] as String? ?? data['problemText'] as String? ?? '',
      correctAnswer: data['correctAnswer'] as String? ?? '',
      userAnswer: data['userAnswer'] as String? ?? '',
      hint: data['hint'] as String?,
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
      easeFactor: (data['easeFactor'] as num?)?.toDouble() ?? 2.5,
      interval: data['interval'] as int? ?? 1,
      repetition: data['repetition'] as int? ?? 0,
      nextReviewDate: data['nextReviewDate'] != null
          ? (data['nextReviewDate'] as Timestamp).toDate()
          : null,
      difficulty: data['difficulty'] as int? ?? 0,
    );
  }

  /// Firestore 저장용 맵 변환
  Map<String, dynamic> toFirestore() => {
        'lessonId': lessonId,
        'lessonTitle': lessonTitle,
        'problemId': problemId,
        'problemType': problemType,
        'question': question,
        'correctAnswer': correctAnswer,
        'userAnswer': userAnswer,
        'hint': hint,
        'explanation': explanation,
        'attemptDate': Timestamp.fromDate(attemptDate),
        'attemptCount': attemptCount,
        'isRetried': isRetried,
        'isResolved': isResolved,
        'resolvedDate':
            resolvedDate != null ? Timestamp.fromDate(resolvedDate!) : null,
        'easeFactor': easeFactor,
        'interval': interval,
        'repetition': repetition,
        'nextReviewDate':
            nextReviewDate != null ? Timestamp.fromDate(nextReviewDate!) : null,
        'difficulty': difficulty,
      };

  Map<String, dynamic> toJson() => {
        'id': id,
        'lessonId': lessonId,
        'lessonTitle': lessonTitle,
        'problemId': problemId,
        'problemType': problemType,
        'question': question,
        'correctAnswer': correctAnswer,
        'userAnswer': userAnswer,
        'hint': hint,
        'explanation': explanation,
        'attemptDate': attemptDate.toIso8601String(),
        'attemptCount': attemptCount,
        'isRetried': isRetried,
        'isResolved': isResolved,
        'resolvedDate': resolvedDate?.toIso8601String(),
        'easeFactor': easeFactor,
        'interval': interval,
        'repetition': repetition,
        'nextReviewDate': nextReviewDate?.toIso8601String(),
        'difficulty': difficulty,
      };

  WrongAnswerModel copyWith({
    String? id,
    String? lessonId,
    String? lessonTitle,
    String? problemId,
    String? problemType,
    String? question,
    String? correctAnswer,
    String? userAnswer,
    String? hint,
    String? explanation,
    DateTime? attemptDate,
    int? attemptCount,
    bool? isRetried,
    bool? isResolved,
    DateTime? resolvedDate,
    double? easeFactor,
    int? interval,
    int? repetition,
    DateTime? nextReviewDate,
    int? difficulty,
  }) {
    return WrongAnswerModel(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      lessonTitle: lessonTitle ?? this.lessonTitle,
      problemId: problemId ?? this.problemId,
      problemType: problemType ?? this.problemType,
      question: question ?? this.question,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      userAnswer: userAnswer ?? this.userAnswer,
      hint: hint ?? this.hint,
      explanation: explanation ?? this.explanation,
      attemptDate: attemptDate ?? this.attemptDate,
      attemptCount: attemptCount ?? this.attemptCount,
      isRetried: isRetried ?? this.isRetried,
      isResolved: isResolved ?? this.isResolved,
      resolvedDate: resolvedDate ?? this.resolvedDate,
      easeFactor: easeFactor ?? this.easeFactor,
      interval: interval ?? this.interval,
      repetition: repetition ?? this.repetition,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  /// Get days since last attempt
  int get daysSinceAttempt {
    return DateTime.now().difference(attemptDate).inDays;
  }

  /// Check if this should be reviewed (spaced repetition)
  bool shouldReview() {
    if (isResolved) return false;

    // Use SRS nextReviewDate if available
    if (nextReviewDate != null) {
      final now = DateTime.now();
      return now.isAfter(nextReviewDate!) ||
          now.year == nextReviewDate!.year &&
              now.month == nextReviewDate!.month &&
              now.day == nextReviewDate!.day;
    }

    // Fallback: legacy interval logic
    final intervals = [1, 3, 7, 14];
    final daysSince = daysSinceAttempt;

    for (var i in intervals) {
      if (daysSince >= i && attemptCount <= intervals.indexOf(i) + 1) {
        return true;
      }
    }

    return false;
  }
}
