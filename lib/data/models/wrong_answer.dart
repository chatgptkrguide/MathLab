import 'problem.dart';

/// 오답 정보
class WrongAnswer {
  final String id;
  final Problem problem;
  final int selectedAnswerIndex;
  final DateTime timestamp;
  final int reviewCount; // 복습 횟수
  final DateTime? lastReviewDate; // 마지막 복습 날짜
  final bool isMastered; // 완전 학습 여부

  const WrongAnswer({
    required this.id,
    required this.problem,
    required this.selectedAnswerIndex,
    required this.timestamp,
    this.reviewCount = 0,
    this.lastReviewDate,
    this.isMastered = false,
  });

  /// 다음 복습 날짜 (망각 곡선 기반)
  /// 1일 → 3일 → 7일 → 14일 → 30일
  DateTime get nextReviewDate {
    if (lastReviewDate == null) {
      return timestamp.add(const Duration(days: 1));
    }

    final intervals = [1, 3, 7, 14, 30];
    final intervalIndex = reviewCount.clamp(0, intervals.length - 1);
    final days = intervals[intervalIndex];

    return lastReviewDate!.add(Duration(days: days));
  }

  /// 복습 필요 여부
  bool get needsReview {
    if (isMastered) return false;

    final now = DateTime.now();
    return now.isAfter(nextReviewDate);
  }

  /// 남은 일수
  int get daysUntilReview {
    final now = DateTime.now();
    final diff = nextReviewDate.difference(now).inDays;
    return diff.clamp(0, 999);
  }

  /// 긴급도 (0: 낮음, 1: 보통, 2: 높음)
  int get urgency {
    if (isMastered) return 0;

    final daysOverdue = DateTime.now().difference(nextReviewDate).inDays;

    if (daysOverdue > 3) return 2; // 3일 이상 지연 - 긴급
    if (daysOverdue > 0) return 1; // 복습 시기 도래 - 보통
    return 0; // 아직 시간 여유 있음 - 낮음
  }

  WrongAnswer copyWith({
    String? id,
    Problem? problem,
    int? selectedAnswerIndex,
    DateTime? timestamp,
    int? reviewCount,
    DateTime? lastReviewDate,
    bool? isMastered,
  }) {
    return WrongAnswer(
      id: id ?? this.id,
      problem: problem ?? this.problem,
      selectedAnswerIndex: selectedAnswerIndex ?? this.selectedAnswerIndex,
      timestamp: timestamp ?? this.timestamp,
      reviewCount: reviewCount ?? this.reviewCount,
      lastReviewDate: lastReviewDate ?? this.lastReviewDate,
      isMastered: isMastered ?? this.isMastered,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'problem': problem.toJson(),
      'selectedAnswerIndex': selectedAnswerIndex,
      'timestamp': timestamp.toIso8601String(),
      'reviewCount': reviewCount,
      'lastReviewDate': lastReviewDate?.toIso8601String(),
      'isMastered': isMastered,
    };
  }

  factory WrongAnswer.fromJson(Map<String, dynamic> json) {
    return WrongAnswer(
      id: json['id'] as String,
      problem: Problem.fromJson(json['problem'] as Map<String, dynamic>),
      selectedAnswerIndex: json['selectedAnswerIndex'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      reviewCount: json['reviewCount'] as int? ?? 0,
      lastReviewDate: json['lastReviewDate'] != null
          ? DateTime.parse(json['lastReviewDate'] as String)
          : null,
      isMastered: json['isMastered'] as bool? ?? false,
    );
  }
}
