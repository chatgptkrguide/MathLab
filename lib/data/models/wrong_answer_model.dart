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
