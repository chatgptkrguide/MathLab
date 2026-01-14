import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

/// 앱 전체에서 사용할 로깅 유틸리티
/// 디버그/프로덕션 환경을 구분하여 로그 출력 제어
/// Firebase Crashlytics와 Analytics 통합
class Logger {
  // Private constructor to prevent instantiation
  Logger._();

  /// Firebase Analytics 인스턴스
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Firebase Crashlytics 인스턴스
  static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  /// Logger 초기화
  /// 앱 시작 시 호출하여 Crashlytics 설정
  static Future<void> initialize() async {
    // 프로덕션에서만 자동 수집 활성화
    await _crashlytics
        .setCrashlyticsCollectionEnabled(!kDebugMode);

    // Flutter 프레임워크 에러 캐치
    FlutterError.onError = (FlutterErrorDetails details) {
      if (kDebugMode) {
        FlutterError.presentError(details);
      } else {
        _crashlytics.recordFlutterFatalError(details);
      }
    };

    // Dart 비동기 에러 캐치
    PlatformDispatcher.instance.onError = (error, stack) {
      if (!kDebugMode) {
        _crashlytics.recordError(error, stack, fatal: true);
      }
      return true;
    };
  }

  /// 로그 레벨
  static const String _debugPrefix = '[DEBUG]';
  static const String _infoPrefix = '[INFO]';
  static const String _warningPrefix = '[WARNING]';
  static const String _errorPrefix = '[ERROR]';

  /// 디버그 로그
  /// 개발 중 디버깅 정보 출력
  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      final logMessage = tag != null ? '[$tag] $message' : message;
      debugPrint('$_debugPrefix $logMessage');
    }
  }

  /// 정보 로그
  /// 일반적인 정보성 메시지 출력
  static void info(String message, {String? tag}) {
    if (kDebugMode) {
      final logMessage = tag != null ? '[$tag] $message' : message;
      debugPrint('$_infoPrefix $logMessage');
    }
  }

  /// 경고 로그
  /// 잠재적 문제나 주의사항 출력
  static void warning(String message, {String? tag}) {
    if (kDebugMode) {
      final logMessage = tag != null ? '[$tag] $message' : message;
      debugPrint('$_warningPrefix $logMessage');
    }
  }

  /// 에러 로그
  /// 에러 및 스택 트레이스 출력
  /// 프로덕션에서는 Firebase Crashlytics로 자동 전송
  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? tag,
    bool fatal = false,
    Map<String, dynamic>? additionalInfo,
  }) {
    if (kDebugMode) {
      final logMessage = tag != null ? '[$tag] $message' : message;
      debugPrint('$_errorPrefix $logMessage');

      if (error != null) {
        debugPrint('$_errorPrefix Error: $error');
      }

      if (stackTrace != null) {
        debugPrint('$_errorPrefix StackTrace: $stackTrace');
      }
    }

    // 프로덕션에서는 Crashlytics로 전송
    if (!kDebugMode && error != null) {
      // 추가 정보 로깅
      if (additionalInfo != null) {
        additionalInfo.forEach((key, value) {
          _crashlytics.setCustomKey(key, value.toString());
        });
      }

      // 에러 기록
      _crashlytics.recordError(
        error,
        stackTrace,
        reason: message,
        fatal: fatal,
      );
    }
  }

  /// 사용자 정보 설정
  /// Crashlytics에서 사용자별 에러 추적을 위해 사용
  static Future<void> setUserId(String userId) async {
    if (!kDebugMode) {
      await _crashlytics.setUserIdentifier(userId);
      await _analytics.setUserId(id: userId);
    }
  }

  /// 사용자 속성 설정
  static Future<void> setUserProperty(String key, String value) async {
    if (!kDebugMode) {
      await _analytics.setUserProperty(name: key, value: value);
    }
  }

  /// 커스텀 키 설정 (에러 발생 시 컨텍스트 정보)
  static void setCustomKey(String key, dynamic value) {
    if (!kDebugMode) {
      _crashlytics.setCustomKey(key, value);
    }
  }

  /// 비즈니스 로직 에러 로그 (비치명적 에러)
  static void logNonFatalError(
    String message,
    Object errorObj,
    StackTrace stackTrace, {
    Map<String, dynamic>? additionalInfo,
  }) {
    Logger.error(
      message,
      error: errorObj,
      stackTrace: stackTrace,
      fatal: false,
      additionalInfo: additionalInfo,
    );
  }

  /// 네트워크 요청 로그
  static void network(String message, {String? method, String? url}) {
    if (kDebugMode) {
      final methodStr = method != null ? '[$method]' : '';
      final urlStr = url ?? '';
      debugPrint('$_infoPrefix [NETWORK] $methodStr $urlStr - $message');
    }
  }

  /// 상태 변경 로그 (Riverpod 등)
  static void state(String message, {required String provider}) {
    if (kDebugMode) {
      debugPrint('$_infoPrefix [STATE][$provider] $message');
    }
  }

  /// UI 이벤트 로그
  static void ui(String message, {String? screen, String? action}) {
    if (kDebugMode) {
      final screenStr = screen != null ? '[$screen]' : '';
      final actionStr = action != null ? '[$action]' : '';
      debugPrint('$_infoPrefix [UI]$screenStr$actionStr $message');
    }
  }

  /// 성능 측정 로그
  static void performance(String message, {int? durationMs}) {
    if (kDebugMode) {
      final duration = durationMs != null ? '(${durationMs}ms)' : '';
      debugPrint('$_infoPrefix [PERFORMANCE] $message $duration');
    }
  }

  /// 데이터 로드 로그
  static void data(String message, {String? source, int? count}) {
    if (kDebugMode) {
      final sourceStr = source != null ? '[$source]' : '';
      final countStr = count != null ? '(count: $count)' : '';
      debugPrint('$_infoPrefix [DATA]$sourceStr $message $countStr');
    }
  }

  /// 분석/추적 로그
  /// Firebase Analytics로 이벤트 전송
  static Future<void> analytics(
    String event, {
    Map<String, dynamic>? parameters,
  }) async {
    if (kDebugMode) {
      debugPrint('$_infoPrefix [ANALYTICS] Event: $event');
      if (parameters != null && parameters.isNotEmpty) {
        debugPrint('$_infoPrefix [ANALYTICS] Parameters: $parameters');
      }
    }

    // Firebase Analytics로 전송
    if (!kDebugMode && parameters != null) {
      // Map<String, dynamic>을 Map<String, Object>로 변환
      final convertedParams = parameters.map(
        (key, value) => MapEntry(key, value as Object),
      );
      await _analytics.logEvent(
        name: event,
        parameters: convertedParams,
      );
    } else if (!kDebugMode) {
      await _analytics.logEvent(name: event);
    }
  }

  /// 화면 뷰 로그
  static Future<void> logScreenView(String screenName) async {
    if (kDebugMode) {
      debugPrint('$_infoPrefix [SCREEN_VIEW] $screenName');
    }

    if (!kDebugMode) {
      await _analytics.logScreenView(
        screenName: screenName,
      );
    }
  }

  /// 앱 열림 이벤트
  static Future<void> logAppOpen() async {
    await analytics('app_open');
  }

  /// 로그인 이벤트
  static Future<void> logLogin(String method) async {
    await analytics('login', parameters: {'method': method});
  }

  /// 회원가입 이벤트
  static Future<void> logSignUp(String method) async {
    await analytics('sign_up', parameters: {'method': method});
  }

  /// 문제 풀이 시작 이벤트
  static Future<void> logProblemStart({
    required String problemId,
    required String category,
    required String difficulty,
  }) async {
    await analytics('problem_start', parameters: {
      'problem_id': problemId,
      'category': category,
      'difficulty': difficulty,
    });
  }

  /// 문제 풀이 완료 이벤트
  static Future<void> logProblemComplete({
    required String problemId,
    required bool isCorrect,
    required int timeSpentSeconds,
    required int hintsUsed,
  }) async {
    await analytics('problem_complete', parameters: {
      'problem_id': problemId,
      'is_correct': isCorrect,
      'time_spent_seconds': timeSpentSeconds,
      'hints_used': hintsUsed,
    });
  }

  /// 레슨 완료 이벤트
  static Future<void> logLessonComplete({
    required String lessonId,
    required int score,
    required int totalProblems,
  }) async {
    await analytics('lesson_complete', parameters: {
      'lesson_id': lessonId,
      'score': score,
      'total_problems': totalProblems,
    });
  }

  /// 레벨 업 이벤트
  static Future<void> logLevelUp({
    required int newLevel,
    required int xpGained,
  }) async {
    await analytics('level_up', parameters: {
      'level': newLevel,
      'xp_gained': xpGained,
    });
  }

  /// 업적 달성 이벤트
  static Future<void> logAchievementUnlock(String achievementId) async {
    await analytics('achievement_unlock',
        parameters: {'achievement_id': achievementId});
  }

  /// 인앱 구매 이벤트
  static Future<void> logPurchase({
    required String productId,
    required double value,
    required String currency,
  }) async {
    await analytics('purchase', parameters: {
      'product_id': productId,
      'value': value,
      'currency': currency,
    });
  }
}
