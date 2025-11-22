import 'package:cloud_firestore/cloud_firestore.dart';

/// 학습 진행상황 모델
class ProgressModel {
  final String userId;
  final String grade; // 학년
  final String chapter; // 단원
  final String lessonId; // 레슨 ID
  final int problemsCompleted; // 완료한 문제 수
  final int totalProblems; // 전체 문제 수
  final int correctAnswers; // 정답 수
  final int xpEarned; // 획득한 XP
  final bool isCompleted; // 완료 여부
  final DateTime? completedAt; // 완료 시간
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProgressModel({
    required this.userId,
    required this.grade,
    required this.chapter,
    required this.lessonId,
    this.problemsCompleted = 0,
    this.totalProblems = 0,
    this.correctAnswers = 0,
    this.xpEarned = 0,
    this.isCompleted = false,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Firestore에서 데이터 가져오기
  factory ProgressModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ProgressModel(
      userId: data['userId'] as String,
      grade: data['grade'] as String,
      chapter: data['chapter'] as String,
      lessonId: data['lessonId'] as String,
      problemsCompleted: data['problemsCompleted'] as int? ?? 0,
      totalProblems: data['totalProblems'] as int? ?? 0,
      correctAnswers: data['correctAnswers'] as int? ?? 0,
      xpEarned: data['xpEarned'] as int? ?? 0,
      isCompleted: data['isCompleted'] as bool? ?? false,
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Firestore에 저장할 데이터로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'grade': grade,
      'chapter': chapter,
      'lessonId': lessonId,
      'problemsCompleted': problemsCompleted,
      'totalProblems': totalProblems,
      'correctAnswers': correctAnswers,
      'xpEarned': xpEarned,
      'isCompleted': isCompleted,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// 진행률 계산
  double get progress {
    if (totalProblems == 0) return 0.0;
    return problemsCompleted / totalProblems;
  }

  /// 정답률
  double get accuracy {
    if (problemsCompleted == 0) return 0.0;
    return correctAnswers / problemsCompleted;
  }

  /// copyWith 메서드
  ProgressModel copyWith({
    String? userId,
    String? grade,
    String? chapter,
    String? lessonId,
    int? problemsCompleted,
    int? totalProblems,
    int? correctAnswers,
    int? xpEarned,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProgressModel(
      userId: userId ?? this.userId,
      grade: grade ?? this.grade,
      chapter: chapter ?? this.chapter,
      lessonId: lessonId ?? this.lessonId,
      problemsCompleted: problemsCompleted ?? this.problemsCompleted,
      totalProblems: totalProblems ?? this.totalProblems,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      xpEarned: xpEarned ?? this.xpEarned,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 일일 학습 기록 모델
class DailyStudyModel {
  final String userId;
  final DateTime date;
  final int problemsCompleted;
  final int xpEarned;
  final int studyTimeMinutes; // 학습 시간 (분)
  final Map<String, int> categoryProgress; // 카테고리별 진행상황
  final DateTime createdAt;

  const DailyStudyModel({
    required this.userId,
    required this.date,
    this.problemsCompleted = 0,
    this.xpEarned = 0,
    this.studyTimeMinutes = 0,
    this.categoryProgress = const {},
    required this.createdAt,
  });

  /// Firestore에서 데이터 가져오기
  factory DailyStudyModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return DailyStudyModel(
      userId: data['userId'] as String,
      date: (data['date'] as Timestamp).toDate(),
      problemsCompleted: data['problemsCompleted'] as int? ?? 0,
      xpEarned: data['xpEarned'] as int? ?? 0,
      studyTimeMinutes: data['studyTimeMinutes'] as int? ?? 0,
      categoryProgress: Map<String, int>.from(data['categoryProgress'] as Map? ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Firestore에 저장할 데이터로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'problemsCompleted': problemsCompleted,
      'xpEarned': xpEarned,
      'studyTimeMinutes': studyTimeMinutes,
      'categoryProgress': categoryProgress,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
