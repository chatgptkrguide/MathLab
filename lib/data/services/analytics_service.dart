import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import '../../shared/utils/logger.dart';

/// 분석 및 크래시 리포팅 서비스
/// Firebase Analytics 및 Crashlytics 통합
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  /// 서비스 초기화
  Future<void> initialize() async {
    try {
      // Crashlytics 활성화 (프로덕션 빌드에서만)
      if (kReleaseMode) {
        await _crashlytics.setCrashlyticsCollectionEnabled(true);
        FlutterError.onError = _crashlytics.recordFlutterFatalError;

        // 비동기 에러 캐치
        PlatformDispatcher.instance.onError = (error, stack) {
          _crashlytics.recordError(error, stack, fatal: true);
          return true;
        };
      }

      // Analytics 활성화
      await _analytics.setAnalyticsCollectionEnabled(true);

      Logger.info('Analytics 및 Crashlytics 초기화 완료', tag: 'Analytics');
    } catch (e, stackTrace) {
      Logger.error('Analytics 초기화 실패', error: e, stackTrace: stackTrace, tag: 'Analytics');
    }
  }

  // ==========================================
  // Analytics - 사용자 속성
  // ==========================================

  /// 사용자 ID 설정
  Future<void> setUserId(String userId) async {
    try {
      await _analytics.setUserId(id: userId);
      await _crashlytics.setUserIdentifier(userId);
      Logger.debug('사용자 ID 설정: $userId', tag: 'Analytics');
    } catch (e) {
      Logger.error('사용자 ID 설정 실패', error: e, tag: 'Analytics');
    }
  }

  /// 사용자 속성 설정
  Future<void> setUserProperty(String name, String? value) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
      Logger.debug('사용자 속성 설정: $name = $value', tag: 'Analytics');
    } catch (e) {
      Logger.error('사용자 속성 설정 실패', error: e, tag: 'Analytics');
    }
  }

  // ==========================================
  // Analytics - 이벤트 로깅
  // ==========================================

  /// 일반 이벤트 로그
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters,
      );
      Logger.analytics(name, parameters: parameters);
    } catch (e) {
      Logger.error('이벤트 로그 실패: $name', error: e, tag: 'Analytics');
    }
  }

  /// 화면 조회 로그
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
      Logger.debug('화면 조회: $screenName', tag: 'Analytics');
    } catch (e) {
      Logger.error('화면 조회 로그 실패', error: e, tag: 'Analytics');
    }
  }

  // ==========================================
  // Analytics - 학습 이벤트
  // ==========================================

  /// 레슨 시작
  Future<void> logLessonStart({
    required String lessonId,
    required String lessonName,
    String? unitId,
  }) async {
    await logEvent(
      name: 'lesson_start',
      parameters: {
        'lesson_id': lessonId,
        'lesson_name': lessonName,
        if (unitId != null) 'unit_id': unitId,
      },
    );
  }

  /// 레슨 완료
  Future<void> logLessonComplete({
    required String lessonId,
    required String lessonName,
    required int score,
    required int timeSeconds,
  }) async {
    await logEvent(
      name: 'lesson_complete',
      parameters: {
        'lesson_id': lessonId,
        'lesson_name': lessonName,
        'score': score,
        'time_seconds': timeSeconds,
      },
    );
  }

  /// 문제 정답
  Future<void> logProblemCorrect({
    required String problemId,
    required String problemType,
    required int attemptCount,
  }) async {
    await logEvent(
      name: 'problem_correct',
      parameters: {
        'problem_id': problemId,
        'problem_type': problemType,
        'attempt_count': attemptCount,
      },
    );
  }

  /// 문제 오답
  Future<void> logProblemIncorrect({
    required String problemId,
    required String problemType,
    required int attemptCount,
  }) async {
    await logEvent(
      name: 'problem_incorrect',
      parameters: {
        'problem_id': problemId,
        'problem_type': problemType,
        'attempt_count': attemptCount,
      },
    );
  }

  // ==========================================
  // Analytics - 게이미피케이션 이벤트
  // ==========================================

  /// 레벨 업
  Future<void> logLevelUp({
    required int level,
    required int xp,
  }) async {
    await _analytics.logLevelUp(level: level);
    await logEvent(
      name: 'level_up',
      parameters: {
        'level': level,
        'total_xp': xp,
      },
    );
  }

  /// 업적 달성
  Future<void> logAchievementUnlock({
    required String achievementId,
    required String achievementName,
  }) async {
    await _analytics.logUnlockAchievement(id: achievementId);
    await logEvent(
      name: 'achievement_unlock',
      parameters: {
        'achievement_id': achievementId,
        'achievement_name': achievementName,
      },
    );
  }

  /// 스트릭 달성
  Future<void> logStreakAchieved({
    required int streakDays,
  }) async {
    await logEvent(
      name: 'streak_achieved',
      parameters: {
        'streak_days': streakDays,
      },
    );
  }

  // ==========================================
  // Analytics - 구매 이벤트
  // ==========================================

  /// 프리미엄 구매
  Future<void> logPremiumPurchase({
    required String productId,
    required double price,
    required String currency,
  }) async {
    await _analytics.logPurchase(
      value: price,
      currency: currency,
      items: [
        AnalyticsEventItem(
          itemId: productId,
          itemName: 'Premium Subscription',
        ),
      ],
    );
  }

  // ==========================================
  // Analytics - 소셜 이벤트
  // ==========================================

  /// 친구 추가
  Future<void> logFriendAdded({
    required String friendId,
  }) async {
    await logEvent(
      name: 'friend_added',
      parameters: {
        'friend_id': friendId,
      },
    );
  }

  /// 메시지 전송
  Future<void> logMessageSent({
    required String recipientId,
    String? messageType,
  }) async {
    await logEvent(
      name: 'message_sent',
      parameters: {
        'recipient_id': recipientId,
        if (messageType != null) 'message_type': messageType,
      },
    );
  }

  // ==========================================
  // Crashlytics - 에러 리포팅
  // ==========================================

  /// 에러 기록
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {
    try {
      await _crashlytics.recordError(
        exception,
        stack,
        reason: reason,
        fatal: fatal,
      );
      Logger.error('크래시 기록', error: exception, stackTrace: stack, tag: 'Crashlytics');
    } catch (e) {
      Logger.error('크래시 기록 실패', error: e, tag: 'Crashlytics');
    }
  }

  /// Flutter 에러 기록
  Future<void> recordFlutterError(FlutterErrorDetails details) async {
    try {
      await _crashlytics.recordFlutterError(details);
      Logger.error('Flutter 에러 기록', error: details.exception, stackTrace: details.stack, tag: 'Crashlytics');
    } catch (e) {
      Logger.error('Flutter 에러 기록 실패', error: e, tag: 'Crashlytics');
    }
  }

  /// 커스텀 로그 추가
  Future<void> log(String message) async {
    try {
      await _crashlytics.log(message);
      Logger.debug('Crashlytics 로그: $message', tag: 'Crashlytics');
    } catch (e) {
      Logger.error('Crashlytics 로그 실패', error: e, tag: 'Crashlytics');
    }
  }

  /// 커스텀 키-값 설정
  Future<void> setCustomKey(String key, Object value) async {
    try {
      await _crashlytics.setCustomKey(key, value);
      Logger.debug('커스텀 키 설정: $key = $value', tag: 'Crashlytics');
    } catch (e) {
      Logger.error('커스텀 키 설정 실패', error: e, tag: 'Crashlytics');
    }
  }

  /// 테스트 크래시 (디버그 전용)
  Future<void> testCrash() async {
    if (kDebugMode) {
      _crashlytics.crash();
    }
  }
}
