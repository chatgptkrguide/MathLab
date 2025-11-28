import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/problem_management_service.dart';
import 'user_provider.dart';
import '../../shared/utils/logger.dart';

/// 문제 관리 서비스 프로바이더
final problemManagementServiceProvider =
    Provider<ProblemManagementService>((ref) {
  return ProblemManagementService();
});

/// 모든 문제 상태 프로바이더
final allProblemStatusesProvider =
    FutureProvider.autoDispose<List<ProblemStatus>>((ref) async {
  final user = ref.watch(userProvider);
  if (user == null) return [];

  final service = ref.read(problemManagementServiceProvider);
  return await service.getAllProblemStatuses(user.id);
});

/// 필터링된 문제 목록 프로바이더
final filteredProblemsProvider = FutureProvider.autoDispose
    .family<List<ProblemStatus>, ProblemFilter>((ref, filter) async {
  final user = ref.watch(userProvider);
  if (user == null) return [];

  final service = ref.read(problemManagementServiceProvider);
  return await service.getFilteredProblems(user.id, filter);
});

/// 문제 통계 프로바이더
final problemStatisticsProvider =
    FutureProvider.autoDispose<ProblemStatistics>((ref) async {
  final user = ref.watch(userProvider);
  if (user == null) {
    return ProblemStatistics(
      totalProblems: 0,
      solvedProblems: 0,
      unsolvedProblems: 0,
      skippedProblems: 0,
      reviewingProblems: 0,
      overallAccuracy: 0.0,
    );
  }

  final service = ref.read(problemManagementServiceProvider);
  return await service.getProblemStatistics(user.id);
});

/// 특정 문제 상태 프로바이더
final problemStatusProvider = FutureProvider.autoDispose
    .family<ProblemStatus?, String>((ref, problemId) async {
  final user = ref.watch(userProvider);
  if (user == null) return null;

  final service = ref.read(problemManagementServiceProvider);
  return await service.getProblemStatus(user.id, problemId);
});

/// 복습 필요 문제 프로바이더
final reviewNeededProblemsProvider =
    FutureProvider.autoDispose<List<ProblemStatus>>((ref) async {
  final user = ref.watch(userProvider);
  if (user == null) return [];

  final service = ref.read(problemManagementServiceProvider);
  final filter = ProblemFilter(needsReview: true);
  return await service.getFilteredProblems(user.id, filter);
});

/// 한 번도 못 푼 문제 프로바이더
final neverSolvedProblemsProvider =
    FutureProvider.autoDispose<List<ProblemStatus>>((ref) async {
  final user = ref.watch(userProvider);
  if (user == null) return [];

  final service = ref.read(problemManagementServiceProvider);
  final filter = ProblemFilter(neverSolved: true);
  return await service.getFilteredProblems(user.id, filter);
});

/// 문제 관리 액션 프로바이더
final problemManagementActionsProvider = Provider((ref) {
  return ProblemManagementActions(ref);
});

/// 문제 관리 액션 클래스
class ProblemManagementActions {
  final Ref _ref;

  ProblemManagementActions(this._ref);

  /// 문제 시도 기록
  Future<void> recordAttempt({
    required String problemId,
    required bool isCorrect,
    int timeSpentSeconds = 0,
    String? userAnswer,
    String? correctAnswer,
  }) async {
    try {
      final user = _ref.read(userProvider);
      if (user == null) {
        Logger.warning('사용자 정보 없음', tag: 'ProblemManagement');
        return;
      }

      final service = _ref.read(problemManagementServiceProvider);
      await service.recordAttempt(
        userId: user.id,
        problemId: problemId,
        isCorrect: isCorrect,
        timeSpentSeconds: timeSpentSeconds,
        userAnswer: userAnswer,
        correctAnswer: correctAnswer,
      );

      // 관련 프로바이더 새로고침
      _ref.invalidate(allProblemStatusesProvider);
      _ref.invalidate(problemStatisticsProvider);
      _ref.invalidate(problemStatusProvider(problemId));

      Logger.info(
        '문제 시도 기록 완료: $problemId (정답: $isCorrect)',
        tag: 'ProblemManagement',
      );
    } catch (e, stackTrace) {
      Logger.error(
        '문제 시도 기록 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProblemManagement',
      );
      rethrow;
    }
  }

  /// 문제 건너뛰기
  Future<void> skipProblem(String problemId) async {
    try {
      final user = _ref.read(userProvider);
      if (user == null) {
        Logger.warning('사용자 정보 없음', tag: 'ProblemManagement');
        return;
      }

      final service = _ref.read(problemManagementServiceProvider);
      await service.skipProblem(
        userId: user.id,
        problemId: problemId,
      );

      // 관련 프로바이더 새로고침
      _ref.invalidate(allProblemStatusesProvider);
      _ref.invalidate(problemStatisticsProvider);
      _ref.invalidate(problemStatusProvider(problemId));

      Logger.info('문제 건너뛰기 완료: $problemId', tag: 'ProblemManagement');
    } catch (e, stackTrace) {
      Logger.error(
        '문제 건너뛰기 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProblemManagement',
      );
      rethrow;
    }
  }

  /// 데이터 초기화
  Future<void> clearAllData() async {
    try {
      final user = _ref.read(userProvider);
      if (user == null) {
        Logger.warning('사용자 정보 없음', tag: 'ProblemManagement');
        return;
      }

      final service = _ref.read(problemManagementServiceProvider);
      await service.clearAllData(user.id);

      // 모든 프로바이더 새로고침
      _ref.invalidate(allProblemStatusesProvider);
      _ref.invalidate(problemStatisticsProvider);

      Logger.info('문제 관리 데이터 초기화 완료', tag: 'ProblemManagement');
    } catch (e, stackTrace) {
      Logger.error(
        '데이터 초기화 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProblemManagement',
      );
      rethrow;
    }
  }
}
