import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import 'base/base_notifier.dart';
import '../services/level_skip_service.dart';
import 'user_provider.dart';
import '../../shared/utils/logger.dart';

/// LevelSkipService 싱글톤 제공
final levelSkipServiceProvider = Provider<LevelSkipService>((ref) {
  return LevelSkipService();
});

/// 현재 활성화된 스킵 테스트 제공
final activeSkipTestProvider =
    FutureProvider.autoDispose<LevelSkipTest?>((ref) async {
  final user = ref.watch(userProvider);
  if (user == null) return null;

  final service = ref.watch(levelSkipServiceProvider);
  return service.getActiveTest(user.id);
});

/// 특정 테스트 ID로 스킵 테스트 조회
final skipTestProvider =
    FutureProvider.autoDispose.family<LevelSkipTest?, String>((ref, testId) async {
  final service = ref.watch(levelSkipServiceProvider);
  return service.getTest(testId);
});

/// 사용자의 모든 스킵 테스트 결과 제공
final skipTestResultsProvider =
    FutureProvider.autoDispose<List<SkipTestResult>>((ref) async {
  final user = ref.watch(userProvider);
  if (user == null) return [];

  final service = ref.watch(levelSkipServiceProvider);
  return service.getAllResults(user.id);
});

/// 특정 레슨의 스킵 테스트 결과 제공
final skipTestResultByLessonProvider = FutureProvider.autoDispose
    .family<SkipTestResult?, String>((ref, lessonId) async {
  final user = ref.watch(userProvider);
  if (user == null) return null;

  final service = ref.watch(levelSkipServiceProvider);
  return service.getResultByLesson(user.id, lessonId);
});

/// 테스트 히스토리 제공
final skipTestHistoryProvider =
    FutureProvider.autoDispose<List<LevelSkipTest>>((ref) async {
  final user = ref.watch(userProvider);
  if (user == null) return [];

  final service = ref.watch(levelSkipServiceProvider);
  return service.getTestHistory(user.id);
});

/// 레슨의 스킵 가능 여부 제공
/// 이미 통과한 테스트가 있거나, 진행 중인 테스트가 있으면 스킵 가능
final canSkipLessonProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, lessonId) async {
  final user = ref.watch(userProvider);
  if (user == null) return false;

  final service = ref.watch(levelSkipServiceProvider);

  // 이미 통과한 결과가 있는지 확인
  final result = await service.getResultByLesson(user.id, lessonId);
  if (result != null && result.passed) {
    return true; // 이미 통과함
  }

  return false; // 스킵 불가능
});

/// 스킵 테스트 액션 프로바이더
final skipTestActionsProvider = Provider<SkipTestActions>((ref) {
  final service = ref.watch(levelSkipServiceProvider);
  final user = ref.watch(userProvider);
  return SkipTestActions(service, user?.id, ref);
});

/// 스킵 테스트 액션 클래스
class SkipTestActions {
  final LevelSkipService _service;
  final String? _userId;
  final Ref _ref;

  SkipTestActions(this._service, this._userId, this._ref);

  /// 스킵 테스트 생성
  Future<LevelSkipTest?> createTest({
    required String lessonId,
    required String lessonTitle,
    int problemCount = 8,
    int requiredAccuracy = 80,
  }) async {
    if (_userId == null) return null;

    try {
      final test = await _service.createTest(
        userId: _userId,
        lessonId: lessonId,
        lessonTitle: lessonTitle,
        problemCount: problemCount,
        requiredAccuracy: requiredAccuracy,
      );

      // 활성 테스트 프로바이더 갱신
      _ref.invalidate(activeSkipTestProvider);
      _ref.invalidate(skipTestProvider(test.id));

      return test;
    } catch (e) {
      Logger.error('Failed to create skip test', error: e, tag: 'LevelSkip');
      return null;
    }
  }

  /// 테스트 시작
  Future<LevelSkipTest?> startTest(String testId) async {
    try {
      final test = await _service.startTest(testId);

      // 관련 프로바이더 갱신
      _ref.invalidate(activeSkipTestProvider);
      _ref.invalidate(skipTestProvider(testId));

      return test;
    } catch (e) {
      Logger.error('Failed to start skip test', error: e, tag: 'LevelSkip');
      return null;
    }
  }

  /// 답안 제출
  Future<LevelSkipTest?> submitAnswer(String testId, dynamic answer) async {
    try {
      final test = await _service.submitAnswer(testId, answer);

      // 관련 프로바이더 갱신
      _ref.invalidate(activeSkipTestProvider);
      _ref.invalidate(skipTestProvider(testId));

      // 테스트 완료 시 결과 및 히스토리 갱신
      if (test.isCompleted) {
        _ref.invalidate(skipTestResultsProvider);
        _ref.invalidate(skipTestResultByLessonProvider(test.lessonId));
        _ref.invalidate(skipTestHistoryProvider);
        _ref.invalidate(canSkipLessonProvider(test.lessonId));
      }

      return test;
    } catch (e) {
      Logger.error('Failed to submit answer', error: e, tag: 'LevelSkip');
      return null;
    }
  }

  /// 테스트 취소
  Future<void> cancelTest(String testId) async {
    try {
      await _service.cancelTest(testId);

      // 관련 프로바이더 갱신
      _ref.invalidate(activeSkipTestProvider);
      _ref.invalidate(skipTestProvider(testId));
      _ref.invalidate(skipTestHistoryProvider);
    } catch (e) {
      Logger.error('Failed to cancel skip test', error: e, tag: 'LevelSkip');
    }
  }

  /// 테스트 삭제
  Future<void> deleteTest(String testId) async {
    try {
      await _service.deleteTest(testId);

      // 관련 프로바이더 갱신
      _ref.invalidate(activeSkipTestProvider);
      _ref.invalidate(skipTestProvider(testId));
      _ref.invalidate(skipTestHistoryProvider);
    } catch (e) {
      Logger.error('Failed to delete skip test', error: e, tag: 'LevelSkip');
    }
  }

  /// 사용자 데이터 초기화
  Future<void> clearUserData() async {
    if (_userId == null) return;

    try {
      await _service.clearUserData(_userId);

      // 모든 관련 프로바이더 갱신
      _ref.invalidate(activeSkipTestProvider);
      _ref.invalidate(skipTestResultsProvider);
      _ref.invalidate(skipTestHistoryProvider);
    } catch (e) {
      Logger.error('Failed to clear user data', error: e, tag: 'LevelSkip');
    }
  }
}

/// 스킵 테스트 상태 노티파이어 (실시간 업데이트용)
class SkipTestNotifier extends BaseNotifier<AsyncValue<LevelSkipTest?>> {
  SkipTestNotifier(this._service, this._testId)
      : super(const AsyncValue.loading(), 'SkipTestNotifier') {
    _loadTest();
  }

  final LevelSkipService _service;
  final String _testId;

  Future<void> _loadTest() async {
    state = const AsyncValue.loading();
    try {
      final test = await _service.getTest(_testId);
      state = AsyncValue.data(test);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// 테스트 갱신
  Future<void> refresh() async {
    await _loadTest();
  }

  /// 답안 제출
  Future<bool> submitAnswer(dynamic answer) async {
    try {
      final test = await _service.submitAnswer(_testId, answer);
      state = AsyncValue.data(test);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  /// 테스트 취소
  Future<void> cancel() async {
    try {
      await _service.cancelTest(_testId);
      await _loadTest();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

/// 스킵 테스트 노티파이어 프로바이더
final skipTestNotifierProvider = StateNotifierProvider.autoDispose
    .family<SkipTestNotifier, AsyncValue<LevelSkipTest?>, String>(
  (ref, testId) {
    final service = ref.watch(levelSkipServiceProvider);
    return SkipTestNotifier(service, testId);
  },
);
