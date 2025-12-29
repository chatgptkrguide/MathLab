import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../base/base_notifier.dart';



/// 주간테스트 상태 관리
class WeeklyTestNotifier extends BaseNotifier<List<WeeklyTest>> {
  WeeklyTestNotifier() : super([], 'WeeklyTestNotifier') {
    _loadWeeklyTests();
  }

  static const String _storageKey = 'weekly_tests';

  /// 앱 시작 시 주간테스트 목록 로드
  Future<void> _loadWeeklyTests() async {
    try {
      final tests = await storage.loadList<WeeklyTest>(
        key: _storageKey,
        fromJson: WeeklyTest.fromJson,
      );

      if (tests.isNotEmpty) {
        state = tests;
      }
    } catch (e, stackTrace) {
      logError(
        '주간테스트 목록 로드 실패',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 주간테스트 목록 저장
  Future<void> _saveWeeklyTests() async {
    try {
      await storage.saveList(
        key: _storageKey,
        data: state,
        toJson: (test) => test.toJson(),
      );
    } catch (e, stackTrace) {
      logError(
        '주간테스트 목록 저장 실패',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 주간테스트 생성 (선생님)
  Future<void> createWeeklyTest(WeeklyTest test) async {
    state = [...state, test];
    await _saveWeeklyTests();
  }

  /// 주간테스트 수정
  Future<void> updateWeeklyTest(WeeklyTest updatedTest) async {
    state = state.map((test) {
      return test.id == updatedTest.id ? updatedTest : test;
    }).toList();
    await _saveWeeklyTests();
  }

  /// 주간테스트 삭제
  Future<void> deleteWeeklyTest(String testId) async {
    state = state.where((t) => t.id != testId).toList();
    await _saveWeeklyTests();
  }

  /// 특정 학급의 주간테스트 조회
  List<WeeklyTest> getTestsByClass(String classId) {
    return state.where((test) => test.classId == classId).toList();
  }

  /// 특정 주차의 테스트 조회
  List<WeeklyTest> getTestsByWeek(String weekCode) {
    return state.where((test) => test.weekCode == weekCode).toList();
  }

  /// 제출 마감 임박 테스트 조회 (3일 이내)
  List<WeeklyTest> getUpcomingDueTests() {
    final now = DateTime.now();
    return state.where((test) {
      if (test.isOverdue) return false;
      final daysUntilDue = test.dueDate.difference(now).inDays;
      return daysUntilDue >= 0 && daysUntilDue <= 3;
    }).toList();
  }

  /// 제출 마감일 지난 테스트 조회
  List<WeeklyTest> getOverdueTests() {
    return state.where((test) => test.isOverdue).toList();
  }

  /// 현재 진행 중인 테스트 조회 (마감 전)
  List<WeeklyTest> getActiveTests() {
    return state.where((test) => !test.isOverdue).toList();
  }

  /// 제출 수 업데이트
  Future<void> updateSubmissionCount(String testId, int newCount) async {
    state = state.map((test) {
      if (test.id == testId) {
        return test.copyWith(submittedCount: newCount);
      }
      return test;
    }).toList();
    await _saveWeeklyTests();
  }

  /// 주차별 테스트 통계
  Map<String, dynamic> getWeeklyStats(String weekCode) {
    final weekTests = getTestsByWeek(weekCode);
    if (weekTests.isEmpty) {
      return {
        'totalTests': 0,
        'totalStudents': 0,
        'averageSubmissionRate': 0.0,
        'completedTests': 0,
      };
    }

    final totalStudents = weekTests.fold<int>(0, (sum, test) => sum + test.totalStudents);
    final totalSubmitted = weekTests.fold<int>(0, (sum, test) => sum + test.submittedCount);
    final averageRate = totalStudents > 0 ? (totalSubmitted / totalStudents) * 100 : 0.0;
    final completedTests = weekTests.where((test) => test.submissionRate == 100.0).length;

    return {
      'totalTests': weekTests.length,
      'totalStudents': totalStudents,
      'averageSubmissionRate': averageRate,
      'completedTests': completedTests,
    };
  }

  /// 학급별 테스트 통계
  Map<String, dynamic> getClassStats(String classId) {
    final classTests = getTestsByClass(classId);
    if (classTests.isEmpty) {
      return {
        'totalTests': 0,
        'activeTests': 0,
        'overdueTests': 0,
        'averageSubmissionRate': 0.0,
      };
    }

    final activeTests = classTests.where((test) => !test.isOverdue).length;
    final overdueTests = classTests.where((test) => test.isOverdue).length;
    final avgRate = classTests.fold<double>(0.0, (sum, test) => sum + test.submissionRate) / classTests.length;

    return {
      'totalTests': classTests.length,
      'activeTests': activeTests,
      'overdueTests': overdueTests,
      'averageSubmissionRate': avgRate,
    };
  }
}

/// Provider 선언
final weeklyTestProvider = StateNotifierProvider<WeeklyTestNotifier, List<WeeklyTest>>((ref) {
  return WeeklyTestNotifier();
});
