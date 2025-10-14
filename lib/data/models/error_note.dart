/// 오답 노트 모델
class ErrorNote {
  final String id;
  final String userId;
  final String problemId;
  final String lessonId;
  final String question;
  final String userAnswer;
  final String correctAnswer;
  final String explanation;
  final String category; // 기초산술, 대수, 기하 등
  final DateTime createdAt;
  final List<DateTime> reviewDates; // 복습한 날짜들
  final ErrorStatus status;
  final int difficulty; // 1-5 난이도
  final List<String> tags; // 태그들

  const ErrorNote({
    required this.id,
    required this.userId,
    required this.problemId,
    required this.lessonId,
    required this.question,
    required this.userAnswer,
    required this.correctAnswer,
    required this.explanation,
    required this.category,
    required this.createdAt,
    required this.reviewDates,
    required this.status,
    required this.difficulty,
    required this.tags,
  });

  /// JSON으로부터 ErrorNote 객체 생성
  factory ErrorNote.fromJson(Map<String, dynamic> json) {
    return ErrorNote(
      id: json['id'] as String,
      userId: json['userId'] as String,
      problemId: json['problemId'] as String,
      lessonId: json['lessonId'] as String,
      question: json['question'] as String,
      userAnswer: json['userAnswer'] as String,
      correctAnswer: json['correctAnswer'] as String,
      explanation: json['explanation'] as String,
      category: json['category'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      reviewDates: (json['reviewDates'] as List)
          .map((date) => DateTime.parse(date as String))
          .toList(),
      status: ErrorStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      difficulty: json['difficulty'] as int,
      tags: List<String>.from(json['tags'] as List),
    );
  }

  /// ErrorNote 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'problemId': problemId,
      'lessonId': lessonId,
      'question': question,
      'userAnswer': userAnswer,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'reviewDates': reviewDates.map((date) => date.toIso8601String()).toList(),
      'status': status.toString().split('.').last,
      'difficulty': difficulty,
      'tags': tags,
    };
  }

  /// ErrorNote 객체 복사 (일부 값 변경)
  ErrorNote copyWith({
    String? id,
    String? userId,
    String? problemId,
    String? lessonId,
    String? question,
    String? userAnswer,
    String? correctAnswer,
    String? explanation,
    String? category,
    DateTime? createdAt,
    List<DateTime>? reviewDates,
    ErrorStatus? status,
    int? difficulty,
    List<String>? tags,
  }) {
    return ErrorNote(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      problemId: problemId ?? this.problemId,
      lessonId: lessonId ?? this.lessonId,
      question: question ?? this.question,
      userAnswer: userAnswer ?? this.userAnswer,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      explanation: explanation ?? this.explanation,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      reviewDates: reviewDates ?? this.reviewDates,
      status: status ?? this.status,
      difficulty: difficulty ?? this.difficulty,
      tags: tags ?? this.tags,
    );
  }

  /// 복습 횟수
  int get reviewCount => reviewDates.length;

  /// 마지막 복습 날짜
  DateTime? get lastReviewDate {
    if (reviewDates.isEmpty) return null;
    return reviewDates.reduce((a, b) => a.isAfter(b) ? a : b);
  }

  /// 다음 복습 예정 날짜 (망각 곡선 기반)
  DateTime get nextReviewDate {
    final baseDate = lastReviewDate ?? createdAt;

    // 복습 간격: 1일 -> 3일 -> 7일 -> 14일 -> 30일
    final intervals = [1, 3, 7, 14, 30];
    final intervalIndex = (reviewCount).clamp(0, intervals.length - 1);

    return baseDate.add(Duration(days: intervals[intervalIndex]));
  }

  /// 복습이 필요한지 확인
  bool get needsReview {
    if (status == ErrorStatus.mastered) return false;
    return DateTime.now().isAfter(nextReviewDate);
  }

  /// 생성된 지 몇 일이 지났는지
  int get daysSinceCreated {
    return DateTime.now().difference(createdAt).inDays;
  }

  /// 마지막 복습으로부터 몇 일이 지났는지
  int get daysSinceLastReview {
    final lastReview = lastReviewDate;
    if (lastReview == null) return daysSinceCreated;
    return DateTime.now().difference(lastReview).inDays;
  }

  /// 상태별 색상
  String get statusColor {
    switch (status) {
      case ErrorStatus.new_error:
        return '#EA4335'; // 빨간색
      case ErrorStatus.reviewing:
        return '#FF9800'; // 주황색
      case ErrorStatus.improving:
        return '#4285F4'; // 파란색
      case ErrorStatus.mastered:
        return '#34A853'; // 초록색
    }
  }

  /// 상태별 한글 텍스트
  String get statusText {
    switch (status) {
      case ErrorStatus.new_error:
        return '신규 오답';
      case ErrorStatus.reviewing:
        return '복습 중';
      case ErrorStatus.improving:
        return '향상 중';
      case ErrorStatus.mastered:
        return '완전 이해';
    }
  }

  /// 난이도별 텍스트
  String get difficultyText {
    switch (difficulty) {
      case 1:
        return '매우 쉬움';
      case 2:
        return '쉬움';
      case 3:
        return '보통';
      case 4:
        return '어려움';
      case 5:
        return '매우 어려움';
      default:
        return '보통';
    }
  }

  @override
  String toString() {
    return 'ErrorNote{id: $id, status: $status, reviewCount: $reviewCount}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ErrorNote && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 오답 상태
enum ErrorStatus {
  new_error, // 신규 오답
  reviewing, // 복습 중
  improving, // 향상 중
  mastered, // 완전 이해
}