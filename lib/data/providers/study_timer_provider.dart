import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import '../models/models.dart';
import '../services/study_timer_service.dart';
import '../../shared/utils/logger.dart';

/// 학습 타이머 서비스 프로바이더
final studyTimerServiceProvider = Provider<StudyTimerService>((ref) {
  return StudyTimerService();
});

/// 현재 학습 세션 프로바이더
final currentStudySessionProvider =
    StateNotifierProvider<CurrentStudySessionNotifier, StudySession?>((ref) {
  return CurrentStudySessionNotifier(ref.read(studyTimerServiceProvider));
});

/// 현재 학습 세션 상태 관리
class CurrentStudySessionNotifier extends StateNotifier<StudySession?> {
  final StudyTimerService _service;
  StopWatchTimer? _stopWatchTimer;

  CurrentStudySessionNotifier(this._service) : super(null) {
    _loadCurrentSession();
  }

  /// 현재 세션 로드
  Future<void> _loadCurrentSession() async {
    try {
      final session = await _service.getCurrentSession();
      state = session;

      if (session != null) {
        Logger.info('진행 중인 세션 복원: ${session.activityType.label}',
            tag: 'StudyTimer');
      }
    } catch (e) {
      Logger.error('세션 로드 실패', error: e, tag: 'StudyTimer');
    }
  }

  /// 타이머 시작
  Future<void> startTimer({
    required String userId,
    required StudyActivityType activityType,
  }) async {
    try {
      // 기존 세션이 있으면 종료
      if (state != null) {
        await stopTimer();
      }

      // 새 세션 시작
      final session = await _service.startSession(
        userId: userId,
        activityType: activityType,
      );

      state = session;

      // StopWatch 타이머 시작
      _stopWatchTimer?.dispose();
      _stopWatchTimer = StopWatchTimer(
        mode: StopWatchMode.countUp,
      );
      _stopWatchTimer!.onStartTimer();

      Logger.info('타이머 시작: ${activityType.label}', tag: 'StudyTimer');
    } catch (e, stackTrace) {
      Logger.error('타이머 시작 실패', error: e, stackTrace: stackTrace,
          tag: 'StudyTimer');
    }
  }

  /// 타이머 일시정지
  void pauseTimer() {
    _stopWatchTimer?.onStopTimer();
    Logger.debug('타이머 일시정지', tag: 'StudyTimer');
  }

  /// 타이머 재개
  void resumeTimer() {
    _stopWatchTimer?.onStartTimer();
    Logger.debug('타이머 재개', tag: 'StudyTimer');
  }

  /// 타이머 중지 및 세션 종료
  Future<StudySession?> stopTimer() async {
    try {
      _stopWatchTimer?.onStopTimer();
      _stopWatchTimer?.dispose();
      _stopWatchTimer = null;

      final completedSession = await _service.endSession();
      state = null;

      Logger.info('타이머 중지', tag: 'StudyTimer');
      return completedSession;
    } catch (e, stackTrace) {
      Logger.error('타이머 중지 실패', error: e, stackTrace: stackTrace,
          tag: 'StudyTimer');
      return null;
    }
  }

  /// 현재 경과 시간 (밀리초)
  Stream<int>? get rawTimeStream => _stopWatchTimer?.rawTime;

  /// 타이머가 실행 중인지
  bool get isRunning => _stopWatchTimer?.isRunning ?? false;

  @override
  void dispose() {
    _stopWatchTimer?.dispose();
    super.dispose();
  }
}

/// 오늘 학습 시간 프로바이더 (초)
final todayStudyTimeProvider = FutureProvider<int>((ref) async {
  final service = ref.read(studyTimerServiceProvider);
  return await service.getTodayTotalSeconds();
});

/// 이번 주 학습 시간 프로바이더 (초)
final thisWeekStudyTimeProvider = FutureProvider<int>((ref) async {
  final service = ref.read(studyTimerServiceProvider);
  return await service.getThisWeekTotalSeconds();
});

/// 일일 학습 통계 프로바이더
final dailyStudyStatsProvider =
    FutureProvider.family<DailyStudyStats?, DateTime>((ref, date) async {
  final service = ref.read(studyTimerServiceProvider);
  return await service.getDailyStats(date);
});

/// 주간 학습 통계 프로바이더
final weeklyStudyStatsProvider =
    FutureProvider.family<WeeklyStudyStats, DateTime>((ref, weekStart) async {
  final service = ref.read(studyTimerServiceProvider);
  return await service.getWeeklyStats(weekStart);
});

/// 세션 기록 프로바이더
final sessionHistoryProvider =
    FutureProvider<List<StudySession>>((ref) async {
  final service = ref.read(studyTimerServiceProvider);
  return await service.getSessionHistory();
});
