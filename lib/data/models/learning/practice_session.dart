import 'package:cloud_firestore/cloud_firestore.dart';
import '../base/base_model.dart';
import 'problem.dart';

/// 연습 모드 세션
class PracticeSession implements BaseModel {
  @override
  final String id;
  final String category; // 카테고리: 기초산술, 대수, 기하 등
  final List<Problem> problems;
  final DateTime startedAt;
  final DateTime? completedAt;
  final bool isCompleted;
  final int currentProblemIndex;

  /// 정답 개수
  final int correctCount;

  /// 오답 개수
  final int incorrectCount;

  /// 건너뛴 문제 개수
  final int skippedCount;

  const PracticeSession({
    required this.id,
    required this.category,
    required this.problems,
    required this.startedAt,
    this.completedAt,
    this.isCompleted = false,
    this.currentProblemIndex = 0,
    this.correctCount = 0,
    this.incorrectCount = 0,
    this.skippedCount = 0,
  });

  PracticeSession copyWith({
    String? id,
    String? category,
    List<Problem>? problems,
    DateTime? startedAt,
    DateTime? completedAt,
    bool? isCompleted,
    int? currentProblemIndex,
    int? correctCount,
    int? incorrectCount,
    int? skippedCount,
  }) {
    return PracticeSession(
      id: id ?? this.id,
      category: category ?? this.category,
      problems: problems ?? this.problems,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      currentProblemIndex: currentProblemIndex ?? this.currentProblemIndex,
      correctCount: correctCount ?? this.correctCount,
      incorrectCount: incorrectCount ?? this.incorrectCount,
      skippedCount: skippedCount ?? this.skippedCount,
    );
  }

  /// 현재 문제
  Problem? get currentProblem {
    if (currentProblemIndex >= problems.length) return null;
    return problems[currentProblemIndex];
  }

  /// 진행률 (0.0 ~ 1.0)
  double get progress {
    if (problems.isEmpty) return 0.0;
    return currentProblemIndex / problems.length;
  }

  /// 전체 문제 수
  int get totalProblems => problems.length;

  /// 답변한 문제 수
  int get answeredCount => correctCount + incorrectCount;

  /// 정답률 (0.0 ~ 1.0)
  double get accuracy {
    if (answeredCount == 0) return 0.0;
    return correctCount / answeredCount;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'problems': problems.map((p) => p.toJson()).toList(),
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'isCompleted': isCompleted,
      'currentProblemIndex': currentProblemIndex,
      'correctCount': correctCount,
      'incorrectCount': incorrectCount,
      'skippedCount': skippedCount,
    };
  }

  /// Firestore 형식으로 변환
  @override
  Map<String, dynamic> toFirestore() {
    return {
      'category': category,
      'problems': problems.map((p) => p.toJson()).toList(),
      'startedAt': Timestamp.fromDate(startedAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'isCompleted': isCompleted,
      'currentProblemIndex': currentProblemIndex,
      'correctCount': correctCount,
      'incorrectCount': incorrectCount,
      'skippedCount': skippedCount,
    };
  }

  /// Firestore 문서에서 생성
  factory PracticeSession.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return PracticeSession(
      id: doc.id,
      category: data['category'] as String,
      problems: (data['problems'] as List<dynamic>)
          .map((p) => Problem.fromJson(p as Map<String, dynamic>))
          .toList(),
      startedAt: (data['startedAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      isCompleted: data['isCompleted'] as bool? ?? false,
      currentProblemIndex: data['currentProblemIndex'] as int? ?? 0,
      correctCount: data['correctCount'] as int? ?? 0,
      incorrectCount: data['incorrectCount'] as int? ?? 0,
      skippedCount: data['skippedCount'] as int? ?? 0,
    );
  }

  factory PracticeSession.fromJson(Map<String, dynamic> json) {
    return PracticeSession(
      id: json['id'],
      category: json['category'],
      problems: (json['problems'] as List<dynamic>)
          .map((p) => Problem.fromJson(p as Map<String, dynamic>))
          .toList(),
      startedAt: DateTime.parse(json['startedAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      isCompleted: json['isCompleted'] ?? false,
      currentProblemIndex: json['currentProblemIndex'] ?? 0,
      correctCount: json['correctCount'] ?? 0,
      incorrectCount: json['incorrectCount'] ?? 0,
      skippedCount: json['skippedCount'] ?? 0,
    );
  }
}

/// 연습 카테고리
enum PracticeCategory {
  basicArithmetic('기초산술', '사칙연산, 분수, 소수'),
  algebra('대수', '방정식, 부등식, 함수'),
  geometry('기하', '도형, 각도, 면적, 부피'),
  statistics('통계', '평균, 확률, 그래프'),
  errorNote('오답 노트', '틀렸던 문제 다시 풀기');

  final String displayName;
  final String description;

  const PracticeCategory(this.displayName, this.description);
}
