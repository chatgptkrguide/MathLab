import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../repositories/problem_repository.dart';
import '../../shared/utils/logger.dart';

/// 레벨 스킵 테스트 서비스
/// 사용자가 특정 레슨을 건너뛸 수 있는지 평가하는 테스트 관리
class LevelSkipService {
  // 싱글톤 패턴
  static final LevelSkipService _instance = LevelSkipService._internal();
  factory LevelSkipService() => _instance;
  LevelSkipService._internal();

  final ProblemRepository _problemRepository = ProblemRepository();

  // SharedPreferences 키
  static const String _testKey = 'level_skip_tests';
  static const String _resultKey = 'level_skip_results';
  static const String _testHistoryKey = 'level_skip_test_history';

  /// 스킵 테스트 생성
  ///
  /// [userId]: 사용자 ID
  /// [lessonId]: 레슨 ID
  /// [lessonTitle]: 레슨 제목
  /// [problemCount]: 문제 수 (기본 8개, 5-10개 권장)
  /// [requiredAccuracy]: 통과 기준 정확도 (기본 80%)
  ///
  /// Returns: 생성된 LevelSkipTest 객체
  Future<LevelSkipTest> createTest({
    required String userId,
    required String lessonId,
    required String lessonTitle,
    int problemCount = 8,
    int requiredAccuracy = 80,
  }) async {
    try {
      // 1. 레슨의 모든 문제 로드
      final allProblems =
          await _problemRepository.loadProblemsByLesson(lessonId);

      if (allProblems.isEmpty) {
        throw Exception('레슨에 문제가 없습니다: $lessonId');
      }

      // 2. 문제 수 조정 (최대 사용 가능한 문제 수)
      final actualCount = min(problemCount, allProblems.length);

      // 3. 랜덤하게 문제 선택
      final random = Random();
      final selectedProblems = <Problem>[];
      final availableIndices = List.generate(allProblems.length, (i) => i);

      for (int i = 0; i < actualCount; i++) {
        final randomIndex = random.nextInt(availableIndices.length);
        final problemIndex = availableIndices.removeAt(randomIndex);
        selectedProblems.add(allProblems[problemIndex]);
      }

      // 4. XP 보상 계산 (레슨 완료 보상의 1.5배)
      final xpReward = (actualCount * 10 * 1.5).round();

      // 5. 테스트 객체 생성
      final test = LevelSkipTest(
        id: 'skip_${userId}_${lessonId}_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        lessonId: lessonId,
        lessonTitle: lessonTitle,
        problems: selectedProblems,
        totalProblems: actualCount,
        requiredAccuracy: requiredAccuracy,
        xpReward: xpReward,
        createdAt: DateTime.now(),
      );

      // 6. 저장
      await _saveTest(test);

      Logger.info(
        'Skip test created: ${test.id} for lesson $lessonId with $actualCount problems',
        tag: 'LevelSkipService',
      );

      return test;
    } catch (e) {
      Logger.error('Failed to create skip test', error: e);
      rethrow;
    }
  }

  /// 테스트 시작
  Future<LevelSkipTest> startTest(String testId) async {
    try {
      final test = await getTest(testId);
      if (test == null) {
        throw Exception('테스트를 찾을 수 없습니다: $testId');
      }

      if (test.status != SkipTestStatus.notStarted) {
        throw Exception('이미 시작된 테스트입니다');
      }

      final updatedTest = test.copyWith(
        status: SkipTestStatus.inProgress,
        startedAt: DateTime.now(),
      );

      await _saveTest(updatedTest);

      Logger.info('Skip test started: $testId', tag: 'LevelSkipService');
      return updatedTest;
    } catch (e) {
      Logger.error('Failed to start skip test', error: e);
      rethrow;
    }
  }

  /// 답안 제출
  ///
  /// [testId]: 테스트 ID
  /// [answer]: 사용자 답안
  ///
  /// Returns: 업데이트된 LevelSkipTest 객체
  Future<LevelSkipTest> submitAnswer(String testId, dynamic answer) async {
    try {
      final test = await getTest(testId);
      if (test == null) {
        throw Exception('테스트를 찾을 수 없습니다: $testId');
      }

      if (test.status != SkipTestStatus.inProgress) {
        throw Exception('진행 중인 테스트가 아닙니다');
      }

      final currentProblem = test.currentProblem;
      if (currentProblem == null) {
        throw Exception('현재 문제를 찾을 수 없습니다');
      }

      // 정답 확인
      final isCorrect = _checkAnswer(currentProblem, answer);

      // 진행 상태 업데이트
      final newCorrectAnswers = test.correctAnswers + (isCorrect ? 1 : 0);
      final newIndex = test.currentProblemIndex + 1;

      // 테스트 완료 확인
      final isCompleted = newIndex >= test.totalProblems;
      final newStatus = isCompleted
          ? _evaluateTest(
              newCorrectAnswers, test.totalProblems, test.requiredAccuracy)
          : SkipTestStatus.inProgress;

      final updatedTest = test.copyWith(
        correctAnswers: newCorrectAnswers,
        currentProblemIndex: newIndex,
        status: newStatus,
        completedAt: isCompleted ? DateTime.now() : null,
      );

      await _saveTest(updatedTest);

      // 테스트 완료 시 결과 저장
      if (isCompleted) {
        await _saveResult(SkipTestResult.fromTest(updatedTest));
        await _addToHistory(updatedTest);

        Logger.info(
          'Skip test completed: $testId - ${updatedTest.status.label}',
          tag: 'LevelSkipService',
        );
      }

      return updatedTest;
    } catch (e) {
      Logger.error('Failed to submit answer', error: e);
      rethrow;
    }
  }

  /// 답안 확인
  bool _checkAnswer(Problem problem, dynamic answer) {
    // Problem 모델의 answer 타입에 따라 처리
    if (problem.answer is int && answer is int) {
      return problem.answer == answer;
    } else if (problem.answer is String && answer is String) {
      return problem.answer.toString().toLowerCase().trim() ==
          answer.toString().toLowerCase().trim();
    } else {
      return problem.answer.toString() == answer.toString();
    }
  }

  /// 테스트 평가 (통과/실패 판정)
  SkipTestStatus _evaluateTest(
    int correctAnswers,
    int totalProblems,
    int requiredAccuracy,
  ) {
    final accuracy = (correctAnswers / totalProblems * 100).round();
    return accuracy >= requiredAccuracy
        ? SkipTestStatus.passed
        : SkipTestStatus.failed;
  }

  /// 테스트 취소
  Future<void> cancelTest(String testId) async {
    try {
      final test = await getTest(testId);
      if (test == null) return;

      final cancelledTest = test.copyWith(
        status: SkipTestStatus.cancelled,
        completedAt: DateTime.now(),
      );

      await _saveTest(cancelledTest);

      Logger.info('Skip test cancelled: $testId', tag: 'LevelSkipService');
    } catch (e) {
      Logger.error('Failed to cancel skip test', error: e);
    }
  }

  /// 테스트 조회
  Future<LevelSkipTest?> getTest(String testId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('${_testKey}_$testId');

      if (json == null) return null;

      final map = jsonDecode(json) as Map<String, dynamic>;
      return LevelSkipTest.fromJson(map);
    } catch (e) {
      Logger.error('Failed to get skip test', error: e);
      return null;
    }
  }

  /// 사용자의 진행 중인 테스트 조회
  Future<LevelSkipTest?> getActiveTest(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      for (final key in keys) {
        if (key.startsWith(_testKey)) {
          final json = prefs.getString(key);
          if (json != null) {
            final map = jsonDecode(json) as Map<String, dynamic>;
            final test = LevelSkipTest.fromJson(map);

            if (test.userId == userId &&
                test.status == SkipTestStatus.inProgress) {
              return test;
            }
          }
        }
      }

      return null;
    } catch (e) {
      Logger.error('Failed to get active test', error: e);
      return null;
    }
  }

  /// 레슨의 스킵 테스트 결과 조회
  Future<SkipTestResult?> getResultByLesson(
      String userId, String lessonId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('${_resultKey}_${userId}_$lessonId');

      if (json == null) return null;

      final map = jsonDecode(json) as Map<String, dynamic>;
      return SkipTestResult.fromJson(map);
    } catch (e) {
      Logger.error('Failed to get skip test result', error: e);
      return null;
    }
  }

  /// 사용자의 모든 스킵 테스트 결과 조회
  Future<List<SkipTestResult>> getAllResults(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final results = <SkipTestResult>[];

      for (final key in keys) {
        if (key.startsWith('${_resultKey}_$userId')) {
          final json = prefs.getString(key);
          if (json != null) {
            final map = jsonDecode(json) as Map<String, dynamic>;
            results.add(SkipTestResult.fromJson(map));
          }
        }
      }

      // 최신 순으로 정렬
      results.sort((a, b) => b.completedAt.compareTo(a.completedAt));

      return results;
    } catch (e) {
      Logger.error('Failed to get all skip test results', error: e);
      return [];
    }
  }

  /// 테스트 히스토리 조회
  Future<List<LevelSkipTest>> getTestHistory(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('${_testHistoryKey}_$userId');

      if (json == null) return [];

      final list = jsonDecode(json) as List<dynamic>;
      return list
          .map((item) => LevelSkipTest.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      Logger.error('Failed to get test history', error: e);
      return [];
    }
  }

  /// 테스트 저장
  Future<void> _saveTest(LevelSkipTest test) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(test.toJson());
      await prefs.setString('${_testKey}_${test.id}', json);
    } catch (e) {
      Logger.error('Failed to save skip test', error: e);
      rethrow;
    }
  }

  /// 결과 저장
  Future<void> _saveResult(SkipTestResult result) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(result.toJson());
      await prefs.setString(
        '${_resultKey}_${result.userId}_${result.lessonId}',
        json,
      );
    } catch (e) {
      Logger.error('Failed to save skip test result', error: e);
    }
  }

  /// 히스토리에 추가
  Future<void> _addToHistory(LevelSkipTest test) async {
    try {
      final history = await getTestHistory(test.userId);
      history.add(test);

      // 최근 20개만 유지
      if (history.length > 20) {
        history.removeRange(0, history.length - 20);
      }

      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(history.map((t) => t.toJson()).toList());
      await prefs.setString('${_testHistoryKey}_${test.userId}', json);
    } catch (e) {
      Logger.error('Failed to add to test history', error: e);
    }
  }

  /// 테스트 삭제
  Future<void> deleteTest(String testId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('${_testKey}_$testId');

      Logger.info('Skip test deleted: $testId', tag: 'LevelSkipService');
    } catch (e) {
      Logger.error('Failed to delete skip test', error: e);
    }
  }

  /// 사용자의 모든 테스트 데이터 삭제
  Future<void> clearUserData(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      for (final key in keys) {
        if (key.contains(userId) &&
            (key.startsWith(_testKey) ||
                key.startsWith(_resultKey) ||
                key.startsWith(_testHistoryKey))) {
          await prefs.remove(key);
        }
      }

      Logger.info('Cleared skip test data for user: $userId',
          tag: 'LevelSkipService');
    } catch (e) {
      Logger.error('Failed to clear user data', error: e);
    }
  }
}
