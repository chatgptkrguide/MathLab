import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/models.dart';
import '../../shared/utils/logger.dart';

/// 문제 관리 서비스
/// 사용자의 문제 풀이 기록을 추적하고 관리합니다.
class ProblemManagementService {
  static const String _problemStatusKey = 'problem_status_history';

  /// 문제 시도 기록
  Future<void> recordAttempt({
    required String userId,
    required String problemId,
    required bool isCorrect,
    int timeSpentSeconds = 0,
    String? userAnswer,
    String? correctAnswer,
  }) async {
    try {
      final statuses = await getAllProblemStatuses(userId);
      final existingIndex = statuses.indexWhere(
        (s) => s.problemId == problemId && s.userId == userId,
      );

      final attempt = ProblemAttempt(
        attemptDate: DateTime.now(),
        isCorrect: isCorrect,
        timeSpentSeconds: timeSpentSeconds,
        userAnswer: userAnswer,
        correctAnswer: correctAnswer,
      );

      ProblemStatus status;

      if (existingIndex == -1) {
        // 새로운 문제
        status = ProblemStatus(
          problemId: problemId,
          userId: userId,
          state: isCorrect ? ProblemState.solved : ProblemState.reviewing,
          firstAttemptDate: DateTime.now(),
          lastAttemptDate: DateTime.now(),
          attemptCount: 1,
          correctCount: isCorrect ? 1 : 0,
          attempts: [attempt],
        );
        statuses.add(status);
      } else {
        // 기존 문제 업데이트
        final existing = statuses[existingIndex];
        final newAttempts = [...existing.attempts, attempt];
        final newCorrectCount =
            existing.correctCount + (isCorrect ? 1 : 0);

        // 상태 결정
        ProblemState newState;
        if (isCorrect && existing.state != ProblemState.solved) {
          newState = ProblemState.solved;
        } else if (!isCorrect && existing.correctCount == 0) {
          newState = ProblemState.reviewing;
        } else {
          newState = existing.state;
        }

        status = existing.copyWith(
          state: newState,
          lastAttemptDate: DateTime.now(),
          attemptCount: existing.attemptCount + 1,
          correctCount: newCorrectCount,
          attempts: newAttempts,
        );
        statuses[existingIndex] = status;
      }

      await _saveAllStatuses(statuses);

      Logger.info(
        '문제 시도 기록: $problemId (정답: $isCorrect)',
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
  Future<void> skipProblem({
    required String userId,
    required String problemId,
  }) async {
    try {
      final statuses = await getAllProblemStatuses(userId);
      final existingIndex = statuses.indexWhere(
        (s) => s.problemId == problemId && s.userId == userId,
      );

      if (existingIndex == -1) {
        // 새로운 문제
        final status = ProblemStatus(
          problemId: problemId,
          userId: userId,
          state: ProblemState.skipped,
          firstAttemptDate: DateTime.now(),
          lastAttemptDate: DateTime.now(),
        );
        statuses.add(status);
      } else {
        // 기존 문제 업데이트
        final existing = statuses[existingIndex];
        statuses[existingIndex] = existing.copyWith(
          state: ProblemState.skipped,
          lastAttemptDate: DateTime.now(),
        );
      }

      await _saveAllStatuses(statuses);

      Logger.info('문제 건너뛰기: $problemId', tag: 'ProblemManagement');
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

  /// 특정 문제의 상태 가져오기
  Future<ProblemStatus?> getProblemStatus(
      String userId, String problemId) async {
    try {
      final statuses = await getAllProblemStatuses(userId);
      return statuses.firstWhere(
        (s) => s.problemId == problemId && s.userId == userId,
        orElse: () => ProblemStatus(
          problemId: problemId,
          userId: userId,
          state: ProblemState.unsolved,
        ),
      );
    } catch (e) {
      Logger.error('문제 상태 조회 실패', error: e, tag: 'ProblemManagement');
      return null;
    }
  }

  /// 모든 문제 상태 가져오기
  Future<List<ProblemStatus>> getAllProblemStatuses(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '${_problemStatusKey}_$userId';
      final statusesJson = prefs.getString(key);

      if (statusesJson == null) {
        return [];
      }

      final List<dynamic> jsonList = json.decode(statusesJson);
      return jsonList
          .map((json) => ProblemStatus.fromJson(json))
          .where((s) => s.userId == userId)
          .toList();
    } catch (e, stackTrace) {
      Logger.error(
        '문제 상태 목록 로드 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProblemManagement',
      );
      return [];
    }
  }

  /// 필터링된 문제 목록 가져오기
  Future<List<ProblemStatus>> getFilteredProblems(
    String userId,
    ProblemFilter filter,
  ) async {
    try {
      var statuses = await getAllProblemStatuses(userId);

      // 상태 필터
      if (filter.state != null) {
        statuses = statuses.where((s) => s.state == filter.state).toList();
      }

      // 복습 필요 필터
      if (filter.needsReview == true) {
        statuses = statuses
            .where((s) =>
                s.state == ProblemState.reviewing ||
                (s.attemptCount > 0 && !s.lastAttemptCorrect))
            .toList();
      }

      // 한 번도 못 푼 문제 필터
      if (filter.neverSolved == true) {
        statuses = statuses.where((s) => s.neverCorrect).toList();
      }

      // 날짜 필터
      if (filter.attemptedAfter != null) {
        statuses = statuses
            .where((s) =>
                s.lastAttemptDate != null &&
                s.lastAttemptDate!.isAfter(filter.attemptedAfter!))
            .toList();
      }

      if (filter.attemptedBefore != null) {
        statuses = statuses
            .where((s) =>
                s.lastAttemptDate != null &&
                s.lastAttemptDate!.isBefore(filter.attemptedBefore!))
            .toList();
      }

      return statuses;
    } catch (e, stackTrace) {
      Logger.error(
        '필터링된 문제 목록 조회 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProblemManagement',
      );
      return [];
    }
  }

  /// 문제 통계 가져오기
  Future<ProblemStatistics> getProblemStatistics(String userId) async {
    try {
      final statuses = await getAllProblemStatuses(userId);

      final totalProblems = statuses.length;
      final solvedProblems =
          statuses.where((s) => s.state == ProblemState.solved).length;
      final unsolvedProblems =
          statuses.where((s) => s.state == ProblemState.unsolved).length;
      final skippedProblems =
          statuses.where((s) => s.state == ProblemState.skipped).length;
      final reviewingProblems =
          statuses.where((s) => s.state == ProblemState.reviewing).length;

      // 전체 정답률 계산
      double overallAccuracy = 0.0;
      if (totalProblems > 0) {
        final totalCorrect =
            statuses.fold(0, (sum, s) => sum + s.correctCount);
        final totalAttempts =
            statuses.fold(0, (sum, s) => sum + s.attemptCount);
        if (totalAttempts > 0) {
          overallAccuracy = (totalCorrect / totalAttempts) * 100;
        }
      }

      return ProblemStatistics(
        totalProblems: totalProblems,
        solvedProblems: solvedProblems,
        unsolvedProblems: unsolvedProblems,
        skippedProblems: skippedProblems,
        reviewingProblems: reviewingProblems,
        overallAccuracy: overallAccuracy,
      );
    } catch (e, stackTrace) {
      Logger.error(
        '문제 통계 조회 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProblemManagement',
      );
      return ProblemStatistics(
        totalProblems: 0,
        solvedProblems: 0,
        unsolvedProblems: 0,
        skippedProblems: 0,
        reviewingProblems: 0,
        overallAccuracy: 0.0,
      );
    }
  }

  /// 모든 상태 저장
  Future<void> _saveAllStatuses(List<ProblemStatus> statuses) async {
    try {
      if (statuses.isEmpty) return;

      final userId = statuses.first.userId;
      final prefs = await SharedPreferences.getInstance();
      final key = '${_problemStatusKey}_$userId';
      final jsonList = statuses.map((s) => s.toJson()).toList();
      await prefs.setString(key, json.encode(jsonList));

      Logger.debug(
        '문제 상태 ${statuses.length}개 저장 완료',
        tag: 'ProblemManagement',
      );
    } catch (e, stackTrace) {
      Logger.error(
        '문제 상태 저장 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProblemManagement',
      );
    }
  }

  /// 데이터 초기화 (테스트용)
  Future<void> clearAllData(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '${_problemStatusKey}_$userId';
      await prefs.remove(key);
      Logger.warning('문제 관리 데이터 초기화', tag: 'ProblemManagement');
    } catch (e, stackTrace) {
      Logger.error(
        '데이터 초기화 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProblemManagement',
      );
    }
  }
}
