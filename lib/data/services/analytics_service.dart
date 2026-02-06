import 'package:firebase_analytics/firebase_analytics.dart';
import '../../core/utils/app_logger.dart';

/// 분석 서비스
/// Firebase Analytics를 통한 앱 사용 이벤트 추적
class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Firebase Analytics observer (GoRouter/Navigator에서 사용)
  static FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  /// 일반 이벤트 로깅
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters,
      );
      AppLogger.info('Analytics event: $name', tag: 'Analytics');
    } catch (e) {
      AppLogger.error('Failed to log analytics event: $name', error: e);
    }
  }

  /// 화면 조회 추적
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
      AppLogger.info('Screen view: $screenName', tag: 'Analytics');
    } catch (e) {
      AppLogger.error('Failed to log screen view: $screenName', error: e);
    }
  }

  /// 사용자 속성 설정
  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
      AppLogger.info('User property set: $name=$value', tag: 'Analytics');
    } catch (e) {
      AppLogger.error('Failed to set user property: $name', error: e);
    }
  }

  /// 사용자 ID 설정
  Future<void> setUserId(String? userId) async {
    try {
      await _analytics.setUserId(id: userId);
      AppLogger.info('User ID set: $userId', tag: 'Analytics');
    } catch (e) {
      AppLogger.error('Failed to set user ID', error: e);
    }
  }

  // ========================================
  // 핵심 학습 이벤트
  // ========================================

  /// 레슨 시작
  Future<void> logLessonStarted({
    required String lessonId,
    required String lessonTitle,
  }) async {
    await logEvent(
      name: 'lesson_started',
      parameters: {
        'lesson_id': lessonId,
        'lesson_title': lessonTitle,
      },
    );
  }

  /// 레슨 완료
  Future<void> logLessonCompleted({
    required String lessonId,
    required int score,
    required int stars,
    required double accuracy,
    required int timeTakenSeconds,
  }) async {
    await logEvent(
      name: 'lesson_completed',
      parameters: {
        'lesson_id': lessonId,
        'score': score,
        'stars': stars,
        'accuracy': accuracy,
        'time_taken_seconds': timeTakenSeconds,
      },
    );
  }

  /// 문제 답변
  Future<void> logProblemAnswered({
    required String problemId,
    required String problemType,
    required bool isCorrect,
    required int timeTakenSeconds,
  }) async {
    await logEvent(
      name: 'problem_answered',
      parameters: {
        'problem_id': problemId,
        'problem_type': problemType,
        'is_correct': isCorrect.toString(),
        'time_taken_seconds': timeTakenSeconds,
      },
    );
  }

  /// 힌트 사용
  Future<void> logHintUsed({
    required String problemId,
    required int hintIndex,
    required int xpCost,
  }) async {
    await logEvent(
      name: 'hint_used',
      parameters: {
        'problem_id': problemId,
        'hint_index': hintIndex,
        'xp_cost': xpCost,
      },
    );
  }

  /// 스트릭 업데이트
  Future<void> logStreakUpdated({required int streakDays}) async {
    await logEvent(
      name: 'streak_updated',
      parameters: {'streak_days': streakDays},
    );
  }

  /// 레벨 업
  Future<void> logLevelUp({required int newLevel}) async {
    await logEvent(
      name: 'level_up',
      parameters: {'new_level': newLevel},
    );
  }

  /// 일일 보상 수령
  Future<void> logDailyRewardClaimed({
    required int day,
    required String rewardType,
    required int amount,
  }) async {
    await logEvent(
      name: 'daily_reward_claimed',
      parameters: {
        'day': day,
        'reward_type': rewardType,
        'amount': amount,
      },
    );
  }
}
