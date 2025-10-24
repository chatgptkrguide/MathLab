import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/local_storage_service.dart';
import '../../shared/constants/game_constants.dart';
import '../../shared/utils/logger.dart';

/// 문제 관련 상태 관리
class ProblemNotifier extends StateNotifier<List<Problem>> {
  ProblemNotifier() : super([]) {
    _loadProblems();
  }

  final LocalStorageService _storage = LocalStorageService();

  /// 문제 데이터 로드
  Future<void> _loadProblems() async {
    try {
      Logger.info('문제 데이터 로드 시작', tag: 'ProblemProvider');

      final String data = await rootBundle.loadString('assets/data/problems.json');
      final Map<String, dynamic> jsonData = jsonDecode(data);
      final List<dynamic> problemsData = jsonData['problems'];

      final problems = problemsData
          .map((problemData) => Problem.fromJson(problemData))
          .toList();

      state = problems;
      Logger.info('문제 ${problems.length}개 로드 완료', tag: 'ProblemProvider');
    } catch (e, stackTrace) {
      Logger.error(
        '문제 로드 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProblemProvider',
      );
      state = [];
    }
  }

  /// 레슨별 문제 조회
  List<Problem> getProblemsByLesson(String lessonId) {
    return state.where((problem) => problem.lessonId == lessonId).toList();
  }

  /// 카테고리별 문제 조회
  List<Problem> getProblemsByCategory(String category) {
    return state.where((problem) => problem.category == category).toList();
  }

  /// 난이도별 문제 조회
  List<Problem> getProblemsByDifficulty(int difficulty) {
    return state.where((problem) => problem.difficulty == difficulty).toList();
  }

  /// 랜덤 문제 조회
  List<Problem> getRandomProblems({int count = 10, String? category}) {
    List<Problem> filteredProblems = category != null
        ? getProblemsByCategory(category)
        : state;

    if (filteredProblems.isEmpty) {
      Logger.warning('랜덤 문제 조회 실패: 문제 없음', tag: 'ProblemProvider');
      return [];
    }

    // 원본 리스트를 변경하지 않도록 복사 후 셔플
    final shuffled = List<Problem>.from(filteredProblems)..shuffle();
    final result = shuffled.take(count).toList();

    Logger.debug(
      '랜덤 문제 ${result.length}개 조회 (카테고리: ${category ?? "전체"})',
      tag: 'ProblemProvider',
    );

    return result;
  }

  /// 특정 문제 조회
  Problem? getProblemById(String problemId) {
    try {
      return state.firstWhere(
        (problem) => problem.id == problemId,
        orElse: () => throw StateError('Problem not found: $problemId'),
      );
    } on StateError {
      Logger.warning('문제를 찾을 수 없음: $problemId', tag: 'ProblemProvider');
      return null;
    }
  }

  /// 사용자 레벨에 맞는 문제 추천
  List<Problem> getRecommendedProblems(
    int userLevel, {
    int count = GameConstants.recommendedProblemCount,
  }) {
    // 사용자 레벨에 따른 난이도 매핑
    int targetDifficulty;
    if (userLevel <= GameConstants.beginnerLevelMax) {
      targetDifficulty = 1;
    } else if (userLevel <= GameConstants.intermediateLevelMax) {
      targetDifficulty = 2;
    } else if (userLevel <= 15) {
      targetDifficulty = 3;
    } else {
      targetDifficulty = 4;
    }

    // 목표 난이도와 주변 난이도 문제들 선택
    final recommendedProblems = state.where((problem) {
      return problem.difficulty >= (targetDifficulty - 1) &&
          problem.difficulty <= (targetDifficulty + 1);
    }).toList();

    if (recommendedProblems.isEmpty) {
      Logger.warning(
        '추천 문제 없음 (레벨: $userLevel, 난이도: $targetDifficulty)',
        tag: 'ProblemProvider',
      );
      return [];
    }

    // 원본 리스트를 변경하지 않도록 복사 후 셔플
    final shuffled = List<Problem>.from(recommendedProblems)..shuffle();
    final result = shuffled.take(count).toList();

    Logger.info(
      '추천 문제 ${result.length}개 (레벨: $userLevel, 난이도: $targetDifficulty)',
      tag: 'ProblemProvider',
    );

    return result;
  }
}

/// 문제 결과 관리
class ProblemResultsNotifier extends StateNotifier<List<ProblemResult>> {
  ProblemResultsNotifier() : super([]) {
    _loadResults();
  }

  final LocalStorageService _storage = LocalStorageService();

  /// 결과 데이터 로드
  Future<void> _loadResults() async {
    try {
      Logger.debug('문제 결과 로드 시작', tag: 'ProblemResultsProvider');

      final results = await _storage.loadList<ProblemResult>(
        key: GameConstants.problemResultsKey,
        fromJson: ProblemResult.fromJson,
      );

      state = results;
      Logger.info('문제 결과 ${results.length}개 로드 완료', tag: 'ProblemResultsProvider');
    } catch (e, stackTrace) {
      Logger.error(
        '문제 결과 로드 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProblemResultsProvider',
      );
      state = [];
    }
  }

  /// 결과 데이터 저장
  Future<void> _saveResults() async {
    try {
      await _storage.saveList<ProblemResult>(
        key: GameConstants.problemResultsKey,
        data: state,
        toJson: (result) => result.toJson(),
      );
      Logger.debug('문제 결과 저장 완료: ${state.length}개', tag: 'ProblemResultsProvider');
    } catch (e, stackTrace) {
      Logger.error(
        '문제 결과 저장 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProblemResultsProvider',
      );
    }
  }

  /// 새 결과 추가
  Future<void> addResult(ProblemResult result) async {
    state = [...state, result];
    await _saveResults();
  }

  /// 사용자별 결과 조회
  List<ProblemResult> getResultsByUser(String userId) {
    return state.where((result) => result.userId == userId).toList();
  }

  /// 정답률 계산
  double getAccuracy(String userId) {
    final userResults = getResultsByUser(userId);
    if (userResults.isEmpty) return 0.0;

    final correctCount = userResults.where((result) => result.isCorrect).length;
    return correctCount / userResults.length;
  }

  /// 카테고리별 정답률
  Map<String, double> getCategoryAccuracy(String userId, List<Problem> problems) {
    final userResults = getResultsByUser(userId);
    final categoryAccuracy = <String, double>{};

    for (final problem in problems) {
      final categoryResults = userResults
          .where((result) => result.problemId == problem.id)
          .toList();

      if (categoryResults.isNotEmpty) {
        final correctCount = categoryResults
            .where((result) => result.isCorrect)
            .length;

        if (!categoryAccuracy.containsKey(problem.category)) {
          categoryAccuracy[problem.category] = 0.0;
        }

        categoryAccuracy[problem.category] = correctCount / categoryResults.length;
      }
    }

    return categoryAccuracy;
  }

  /// 총 획득 XP 계산
  int getTotalXP(String userId) {
    final userResults = getResultsByUser(userId);
    return userResults.fold(0, (total, result) => total + result.xpEarned);
  }

  /// 오늘 풀은 문제 수
  int getTodayProblemCount(String userId) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final userResults = getResultsByUser(userId);
    return userResults
        .where((result) {
          final resultDate = DateTime(
            result.solvedAt.year,
            result.solvedAt.month,
            result.solvedAt.day,
          );
          return resultDate.isAtSameMomentAs(today);
        })
        .length;
  }

  /// 틀린 문제들 조회 (오답 노트용)
  List<ProblemResult> getIncorrectResults(String userId) {
    final userResults = getResultsByUser(userId);
    return userResults.where((result) => !result.isCorrect).toList();
  }

  /// 연속 정답 수 계산
  int getConsecutiveCorrectCount(String userId) {
    final userResults = getResultsByUser(userId);
    userResults.sort((a, b) => b.solvedAt.compareTo(a.solvedAt)); // 최신순 정렬

    int consecutiveCount = 0;
    for (final result in userResults) {
      if (result.isCorrect) {
        consecutiveCount++;
      } else {
        break;
      }
    }

    return consecutiveCount;
  }

  /// 평균 풀이 시간
  double getAverageTimeSpent(String userId) {
    final userResults = getResultsByUser(userId);
    if (userResults.isEmpty) return 0.0;

    final totalTime = userResults.fold(0, (total, result) => total + result.timeSpentSeconds);
    return totalTime / userResults.length;
  }

  /// 결과 초기화 (테스트용)
  Future<void> clearResults() async {
    state = [];
    await _saveResults();
  }
}

/// 현재 학습 세션 관리
class LearningSessionNotifier extends StateNotifier<LearningSession?> {
  LearningSessionNotifier() : super(null);

  /// 새 학습 세션 시작
  void startSession({
    required String lessonId,
    required List<Problem> problems,
  }) {
    state = LearningSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      lessonId: lessonId,
      problems: problems,
      currentProblemIndex: 0,
      startTime: DateTime.now(),
      results: [],
    );
  }

  /// 다음 문제로 이동
  void nextProblem() {
    if (state == null) return;

    final nextIndex = state!.currentProblemIndex + 1;
    if (nextIndex < state!.problems.length) {
      state = state!.copyWith(currentProblemIndex: nextIndex);
    }
  }

  /// 문제 결과 추가
  void addProblemResult(ProblemResult result) {
    if (state == null) return;

    state = state!.copyWith(
      results: [...state!.results, result],
    );
  }

  /// 세션 완료
  LearningSessionSummary? completeSession() {
    if (state == null) return null;

    final summary = LearningSessionSummary(
      sessionId: state!.id,
      lessonId: state!.lessonId,
      totalProblems: state!.problems.length,
      correctAnswers: state!.results.where((r) => r.isCorrect).length,
      totalXPEarned: state!.results.fold(0, (total, r) => total + r.xpEarned),
      totalTimeSpent: DateTime.now().difference(state!.startTime),
      averageTimePerProblem: state!.averageTimePerProblem,
      completedAt: DateTime.now(),
    );

    state = null; // 세션 종료
    return summary;
  }

  /// 현재 문제
  Problem? get currentProblem {
    if (state == null || state!.currentProblemIndex >= state!.problems.length) {
      return null;
    }
    return state!.problems[state!.currentProblemIndex];
  }

  /// 진행률
  double get progress {
    if (state == null || state!.problems.isEmpty) return 0.0;
    return state!.currentProblemIndex / state!.problems.length;
  }

  /// 세션이 완료되었는지
  bool get isCompleted {
    if (state == null) return false;
    return state!.currentProblemIndex >= state!.problems.length;
  }
}

/// 학습 세션 모델
class LearningSession {
  final String id;
  final String lessonId;
  final List<Problem> problems;
  final int currentProblemIndex;
  final DateTime startTime;
  final List<ProblemResult> results;

  const LearningSession({
    required this.id,
    required this.lessonId,
    required this.problems,
    required this.currentProblemIndex,
    required this.startTime,
    required this.results,
  });

  LearningSession copyWith({
    String? id,
    String? lessonId,
    List<Problem>? problems,
    int? currentProblemIndex,
    DateTime? startTime,
    List<ProblemResult>? results,
  }) {
    return LearningSession(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      problems: problems ?? this.problems,
      currentProblemIndex: currentProblemIndex ?? this.currentProblemIndex,
      startTime: startTime ?? this.startTime,
      results: results ?? this.results,
    );
  }

  /// 평균 풀이 시간
  double get averageTimePerProblem {
    if (results.isEmpty) return 0.0;
    final totalTime = results.fold(0, (total, result) => total + result.timeSpentSeconds);
    return totalTime / results.length;
  }

  /// 정답률
  double get accuracy {
    if (results.isEmpty) return 0.0;
    final correctCount = results.where((result) => result.isCorrect).length;
    return correctCount / results.length;
  }
}

/// 학습 세션 요약
class LearningSessionSummary {
  final String sessionId;
  final String lessonId;
  final int totalProblems;
  final int correctAnswers;
  final int totalXPEarned;
  final Duration totalTimeSpent;
  final double averageTimePerProblem;
  final DateTime completedAt;

  const LearningSessionSummary({
    required this.sessionId,
    required this.lessonId,
    required this.totalProblems,
    required this.correctAnswers,
    required this.totalXPEarned,
    required this.totalTimeSpent,
    required this.averageTimePerProblem,
    required this.completedAt,
  });

  /// 정답률
  double get accuracy => totalProblems > 0 ? correctAnswers / totalProblems : 0.0;

  /// 성과 등급
  String get performanceGrade {
    final accuracyPercent = accuracy * 100;
    if (accuracyPercent >= 95) return 'S';
    if (accuracyPercent >= 85) return 'A';
    if (accuracyPercent >= 75) return 'B';
    if (accuracyPercent >= 65) return 'C';
    return 'D';
  }
}

/// 프로바이더들
final problemProvider = StateNotifierProvider<ProblemNotifier, List<Problem>>((ref) {
  return ProblemNotifier();
});

final problemResultsProvider = StateNotifierProvider<ProblemResultsNotifier, List<ProblemResult>>((ref) {
  return ProblemResultsNotifier();
});

final learningSessionProvider = StateNotifierProvider<LearningSessionNotifier, LearningSession?>((ref) {
  return LearningSessionNotifier();
});

/// 편의 프로바이더들
final currentProblemProvider = Provider<Problem?>((ref) {
  final session = ref.watch(learningSessionProvider);
  if (session == null || session.currentProblemIndex >= session.problems.length) {
    return null;
  }
  return session.problems[session.currentProblemIndex];
});

final sessionProgressProvider = Provider<double>((ref) {
  final session = ref.watch(learningSessionProvider);
  if (session == null || session.problems.isEmpty) return 0.0;
  return session.currentProblemIndex / session.problems.length;
});

final isSessionActiveProvider = Provider<bool>((ref) {
  final session = ref.watch(learningSessionProvider);
  return session != null;
});