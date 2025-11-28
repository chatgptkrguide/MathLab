import 'problem.dart';

/// 레벨 스킵 테스트 상태
enum SkipTestStatus {
  notStarted('시작 전'),
  inProgress('진행중'),
  passed('통과'),
  failed('실패'),
  cancelled('취소');

  final String label;
  const SkipTestStatus(this.label);
}

/// 레벨 스킵 테스트 모델
/// 사용자가 특정 레슨을 건너뛸 수 있는지 평가하는 테스트
class LevelSkipTest {
  final String id;
  final String userId;
  final String lessonId;
  final String lessonTitle;
  final List<Problem> problems; // 테스트 문제들 (5-10개)
  final int totalProblems;
  final int correctAnswers; // 맞춘 문제 수
  final int currentProblemIndex; // 현재 문제 인덱스
  final SkipTestStatus status;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final int requiredAccuracy; // 통과 기준 정확도 (기본 80%)
  final int xpReward; // 통과 시 획득 XP

  const LevelSkipTest({
    required this.id,
    required this.userId,
    required this.lessonId,
    required this.lessonTitle,
    required this.problems,
    required this.totalProblems,
    this.correctAnswers = 0,
    this.currentProblemIndex = 0,
    this.status = SkipTestStatus.notStarted,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    this.requiredAccuracy = 80,
    required this.xpReward,
  });

  /// JSON으로부터 LevelSkipTest 객체 생성
  factory LevelSkipTest.fromJson(Map<String, dynamic> json) {
    return LevelSkipTest(
      id: json['id'] as String,
      userId: json['userId'] as String,
      lessonId: json['lessonId'] as String,
      lessonTitle: json['lessonTitle'] as String,
      problems: (json['problems'] as List)
          .map((p) => Problem.fromJson(p as Map<String, dynamic>))
          .toList(),
      totalProblems: json['totalProblems'] as int,
      correctAnswers: json['correctAnswers'] as int? ?? 0,
      currentProblemIndex: json['currentProblemIndex'] as int? ?? 0,
      status: SkipTestStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => SkipTestStatus.notStarted,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      requiredAccuracy: json['requiredAccuracy'] as int? ?? 80,
      xpReward: json['xpReward'] as int,
    );
  }

  /// LevelSkipTest 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'lessonId': lessonId,
      'lessonTitle': lessonTitle,
      'problems': problems.map((p) => p.toJson()).toList(),
      'totalProblems': totalProblems,
      'correctAnswers': correctAnswers,
      'currentProblemIndex': currentProblemIndex,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'requiredAccuracy': requiredAccuracy,
      'xpReward': xpReward,
    };
  }

  /// LevelSkipTest 객체 복사
  LevelSkipTest copyWith({
    String? id,
    String? userId,
    String? lessonId,
    String? lessonTitle,
    List<Problem>? problems,
    int? totalProblems,
    int? correctAnswers,
    int? currentProblemIndex,
    SkipTestStatus? status,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    int? requiredAccuracy,
    int? xpReward,
  }) {
    return LevelSkipTest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      lessonId: lessonId ?? this.lessonId,
      lessonTitle: lessonTitle ?? this.lessonTitle,
      problems: problems ?? this.problems,
      totalProblems: totalProblems ?? this.totalProblems,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      currentProblemIndex: currentProblemIndex ?? this.currentProblemIndex,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      requiredAccuracy: requiredAccuracy ?? this.requiredAccuracy,
      xpReward: xpReward ?? this.xpReward,
    );
  }

  /// 현재 문제
  Problem? get currentProblem {
    if (currentProblemIndex >= 0 && currentProblemIndex < problems.length) {
      return problems[currentProblemIndex];
    }
    return null;
  }

  /// 진행률 (0.0 ~ 1.0)
  double get progress {
    if (totalProblems == 0) return 0.0;
    return currentProblemIndex / totalProblems;
  }

  /// 현재 정확도 (%)
  int get currentAccuracy {
    if (currentProblemIndex == 0) return 0;
    return ((correctAnswers / currentProblemIndex) * 100).round();
  }

  /// 테스트 완료 여부
  bool get isCompleted {
    return status == SkipTestStatus.passed || status == SkipTestStatus.failed;
  }

  /// 테스트 통과 여부
  bool get isPassed {
    return status == SkipTestStatus.passed;
  }

  /// 최종 정확도 (%)
  int get finalAccuracy {
    if (totalProblems == 0) return 0;
    return ((correctAnswers / totalProblems) * 100).round();
  }

  /// 테스트 통과 가능 여부 (현재까지 진행 기준)
  bool get canPass {
    // 남은 문제를 모두 맞춰도 통과할 수 있는지 확인
    final remainingProblems = totalProblems - currentProblemIndex;
    final maxPossibleCorrect = correctAnswers + remainingProblems;
    final maxPossibleAccuracy = (maxPossibleCorrect / totalProblems) * 100;
    return maxPossibleAccuracy >= requiredAccuracy;
  }

  /// 소요 시간 (초)
  int? get durationInSeconds {
    if (startedAt == null || completedAt == null) return null;
    return completedAt!.difference(startedAt!).inSeconds;
  }

  @override
  String toString() {
    return 'LevelSkipTest(id: $id, lesson: $lessonTitle, '
        'status: ${status.label}, progress: $currentProblemIndex/$totalProblems, '
        'accuracy: ${finalAccuracy}%)';
  }
}

/// 레벨 스킵 테스트 결과 모델
class SkipTestResult {
  final String testId;
  final String userId;
  final String lessonId;
  final bool passed;
  final int correctAnswers;
  final int totalProblems;
  final int accuracy; // 정확도 (%)
  final int durationSeconds; // 소요 시간 (초)
  final int xpEarned; // 획득한 XP
  final DateTime completedAt;

  const SkipTestResult({
    required this.testId,
    required this.userId,
    required this.lessonId,
    required this.passed,
    required this.correctAnswers,
    required this.totalProblems,
    required this.accuracy,
    required this.durationSeconds,
    required this.xpEarned,
    required this.completedAt,
  });

  /// JSON으로부터 SkipTestResult 객체 생성
  factory SkipTestResult.fromJson(Map<String, dynamic> json) {
    return SkipTestResult(
      testId: json['testId'] as String,
      userId: json['userId'] as String,
      lessonId: json['lessonId'] as String,
      passed: json['passed'] as bool,
      correctAnswers: json['correctAnswers'] as int,
      totalProblems: json['totalProblems'] as int,
      accuracy: json['accuracy'] as int,
      durationSeconds: json['durationSeconds'] as int,
      xpEarned: json['xpEarned'] as int,
      completedAt: DateTime.parse(json['completedAt'] as String),
    );
  }

  /// SkipTestResult 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'testId': testId,
      'userId': userId,
      'lessonId': lessonId,
      'passed': passed,
      'correctAnswers': correctAnswers,
      'totalProblems': totalProblems,
      'accuracy': accuracy,
      'durationSeconds': durationSeconds,
      'xpEarned': xpEarned,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  /// LevelSkipTest로부터 결과 생성
  factory SkipTestResult.fromTest(LevelSkipTest test) {
    return SkipTestResult(
      testId: test.id,
      userId: test.userId,
      lessonId: test.lessonId,
      passed: test.isPassed,
      correctAnswers: test.correctAnswers,
      totalProblems: test.totalProblems,
      accuracy: test.finalAccuracy,
      durationSeconds: test.durationInSeconds ?? 0,
      xpEarned: test.isPassed ? test.xpReward : 0,
      completedAt: test.completedAt ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'SkipTestResult('
        'passed: $passed, accuracy: $accuracy%, '
        'correct: $correctAnswers/$totalProblems, '
        'xp: $xpEarned)';
  }
}
