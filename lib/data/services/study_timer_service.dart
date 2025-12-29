import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/models.dart';
import '../../shared/utils/logger.dart';

/// 학습 타이머 서비스
/// 학습 세션 추적 및 통계 관리
class StudyTimerService {
  static const String _sessionHistoryKey = 'study_session_history';
  static const String _currentSessionKey = 'current_study_session';

  /// 현재 진행 중인 세션 시작
  Future<StudySession> startSession({
    required String userId,
    required StudyActivityType activityType,
  }) async {
    try {
      final session = StudySession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        startTime: DateTime.now(),
        durationSeconds: 0,
        activityType: activityType,
      );

      await _saveCurrentSession(session);
      Logger.info(
        '학습 세션 시작: ${activityType.label}',
        tag: 'StudyTimer',
      );

      return session;
    } catch (e, stackTrace) {
      Logger.error(
        '학습 세션 시작 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'StudyTimer',
      );
      rethrow;
    }
  }

  /// 현재 세션 종료
  Future<StudySession?> endSession() async {
    try {
      final currentSession = await getCurrentSession();
      if (currentSession == null) {
        Logger.warning('종료할 세션이 없습니다', tag: 'StudyTimer');
        return null;
      }

      final endTime = DateTime.now();
      final duration = endTime.difference(currentSession.startTime).inSeconds;

      final completedSession = currentSession.copyWith(
        endTime: endTime,
        durationSeconds: duration,
      );

      // 기록에 추가
      await _addToHistory(completedSession);

      // 현재 세션 삭제
      await _clearCurrentSession();

      Logger.info(
        '학습 세션 종료: ${completedSession.activityType.label} ($duration초)',
        tag: 'StudyTimer',
      );

      return completedSession;
    } catch (e, stackTrace) {
      Logger.error(
        '학습 세션 종료 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'StudyTimer',
      );
      rethrow;
    }
  }

  /// 현재 진행 중인 세션 가져오기
  Future<StudySession?> getCurrentSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = prefs.getString(_currentSessionKey);

      if (sessionJson == null) {
        return null;
      }

      return StudySession.fromJson(json.decode(sessionJson));
    } catch (e, stackTrace) {
      Logger.error(
        '현재 세션 로드 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'StudyTimer',
      );
      return null;
    }
  }

  /// 현재 세션 저장
  Future<void> _saveCurrentSession(StudySession session) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _currentSessionKey,
        json.encode(session.toJson()),
      );
    } catch (e, stackTrace) {
      Logger.error(
        '현재 세션 저장 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'StudyTimer',
      );
    }
  }

  /// 현재 세션 삭제
  Future<void> _clearCurrentSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentSessionKey);
    } catch (e, stackTrace) {
      Logger.error(
        '현재 세션 삭제 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'StudyTimer',
      );
    }
  }

  /// 세션을 기록에 추가
  Future<void> _addToHistory(StudySession session) async {
    try {
      final history = await getSessionHistory();
      history.add(session);

      final prefs = await SharedPreferences.getInstance();
      final jsonList = history.map((s) => s.toJson()).toList();
      await prefs.setString(_sessionHistoryKey, json.encode(jsonList));

      Logger.debug('세션 기록 저장 완료: ${history.length}개', tag: 'StudyTimer');
    } catch (e, stackTrace) {
      Logger.error(
        '세션 기록 저장 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'StudyTimer',
      );
    }
  }

  /// 전체 세션 기록 가져오기
  Future<List<StudySession>> getSessionHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_sessionHistoryKey);

      if (historyJson == null) {
        return [];
      }

      final List<dynamic> jsonList = json.decode(historyJson);
      return jsonList
          .map((json) => StudySession.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      Logger.error(
        '세션 기록 로드 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'StudyTimer',
      );
      return [];
    }
  }

  /// 일일 학습 통계 가져오기
  Future<DailyStudyStats?> getDailyStats(DateTime date) async {
    try {
      final history = await getSessionHistory();
      final dateOnly = DateTime(date.year, date.month, date.day);

      // 해당 날짜의 세션만 필터링
      final dailySessions = history.where((session) {
        final sessionDate = DateTime(
          session.startTime.year,
          session.startTime.month,
          session.startTime.day,
        );
        return sessionDate == dateOnly;
      }).toList();

      if (dailySessions.isEmpty) {
        return null;
      }

      // 활동 유형별 시간 계산
      final Map<StudyActivityType, int> activityDurations = {};
      int totalSeconds = 0;

      for (final session in dailySessions) {
        totalSeconds += session.durationSeconds;
        activityDurations[session.activityType] =
            (activityDurations[session.activityType] ?? 0) +
                session.durationSeconds;
      }

      return DailyStudyStats(
        date: dateOnly,
        totalSeconds: totalSeconds,
        activityDurations: activityDurations,
        sessionCount: dailySessions.length,
      );
    } catch (e, stackTrace) {
      Logger.error(
        '일일 통계 조회 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'StudyTimer',
      );
      return null;
    }
  }

  /// 주간 학습 통계 가져오기
  Future<WeeklyStudyStats> getWeeklyStats(DateTime weekStart) async {
    try {
      final List<DailyStudyStats> dailyStats = [];

      for (int i = 0; i < 7; i++) {
        final date = weekStart.add(Duration(days: i));
        final dayStats = await getDailyStats(date);

        if (dayStats != null) {
          dailyStats.add(dayStats);
        }
      }

      return WeeklyStudyStats(
        weekStartDate: weekStart,
        dailyStats: dailyStats,
      );
    } catch (e, stackTrace) {
      Logger.error(
        '주간 통계 조회 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'StudyTimer',
      );
      return WeeklyStudyStats(
        weekStartDate: weekStart,
        dailyStats: [],
      );
    }
  }

  /// 오늘 학습 시간 (초)
  Future<int> getTodayTotalSeconds() async {
    final today = DateTime.now();
    final stats = await getDailyStats(today);
    return stats?.totalSeconds ?? 0;
  }

  /// 이번 주 학습 시간 (초)
  Future<int> getThisWeekTotalSeconds() async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStats = await getWeeklyStats(weekStart);
    return weekStats.totalSeconds;
  }

  /// 기록 초기화 (테스트용)
  Future<void> clearAllHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionHistoryKey);
      await prefs.remove(_currentSessionKey);
      Logger.warning('모든 학습 기록 초기화', tag: 'StudyTimer');
    } catch (e, stackTrace) {
      Logger.error(
        '기록 초기화 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'StudyTimer',
      );
    }
  }
}
