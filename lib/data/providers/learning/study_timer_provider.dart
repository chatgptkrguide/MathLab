import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import '../../models/models.dart';
import '../../services/study_timer_service.dart';
import '../base/base_notifier.dart';

/// 학습 타이머 서비스 프로바이더
final studyTimerServiceProvider = Provider<StudyTimerService>((ref) {
  return StudyTimerService();
});

/// 현재 학습 세션 프로바이더
final currentStudySessionProvider =
    StateNotifierProvider<CurrentStudySessionNotifier, StudySession?>((ref) {
  return CurrentStudySessionNotifier(ref.read(studyTimerServiceProvider));
});

/// 현재 학습 세션 상태 관리 (BaseNotifier 최적화 버전)
///
/// **개선사항:**
/// - BaseNotifier 상속으로 중복 로깅 제거
/// - executeWithErrorHandling로 try-catch 자동화
class CurrentStudySessionNotifier extends BaseNotifier<StudySession?> {
  final StudyTimerService _service;
  StopWatchTimer? _stopWatchTimer;

  CurrentStudySessionNotifier(this._service) : super(null, 'StudyTimer') {
    _loadCurrentSession();
  }

  /// 현재 세션 로드
  Future<void> _loadCurrentSession() async {
    await executeWithErrorHandling(
      () async {
        final session = await _service.getCurrentSession();
        state = session;

        if (session != null) {
          logInfo('진행 중인 세션 복원: ${session.activityType.label}');
        }
      },
      errorMessage: '세션 로드 실패',
    );
  }

  /// 타이머 시작
  Future<void> startTimer({
    required String userId,
    required StudyActivityType activityType,
  }) async {
    await executeWithErrorHandling(
      () async {
        if (state != null) {
          await stopTimer();
        }

        final session = await _service.startSession(
          userId: userId,
          activityType: activityType,
        );

        state = session;

        _stopWatchTimer?.dispose();
        _stopWatchTimer = StopWatchTimer(mode: StopWatchMode.countUp);
        _stopWatchTimer!.onStartTimer();

        logInfo('타이머 시작: ${activityType.label}');
      },
      errorMessage: '타이머 시작 실패',
    );
  }

  /// 타이머 일시정지
  void pauseTimer() {
    _stopWatchTimer?.onStopTimer();
    logDebug('타이머 일시정지');
  }

  /// 타이머 재개
  void resumeTimer() {
    _stopWatchTimer?.onStartTimer();
    logDebug('타이머 재개');
  }

  /// 타이머 중지 및 세션 종료
  Future<StudySession?> stopTimer() async {
    return await executeWithErrorHandling<StudySession?>(
      () async {
        _stopWatchTimer?.onStopTimer();
        _stopWatchTimer?.dispose();
        _stopWatchTimer = null;

        final completedSession = await _service.endSession();
        state = null;

        logInfo('타이머 중지');
        return completedSession;
      },
      errorMessage: '타이머 중지 실패',
      fallback: () => null,
    );
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
final sessionHistoryProvider = FutureProvider<List<StudySession>>((ref) async {
  final service = ref.read(studyTimerServiceProvider);
  return await service.getSessionHistory();
});
