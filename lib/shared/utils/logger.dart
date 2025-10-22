import 'package:flutter/foundation.dart';

/// 앱 전체에서 사용할 로깅 유틸리티
/// 디버그/프로덕션 환경을 구분하여 로그 출력 제어
class Logger {
  // Private constructor to prevent instantiation
  Logger._();

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
  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? tag,
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

    // 프로덕션에서는 에러 리포팅 서비스로 전송
    // TODO: Sentry, Firebase Crashlytics 등 통합
    // if (!kDebugMode && error != null) {
    //   ErrorReportingService.report(error, stackTrace);
    // }
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
  static void analytics(String event, {Map<String, dynamic>? parameters}) {
    if (kDebugMode) {
      debugPrint('$_infoPrefix [ANALYTICS] Event: $event');
      if (parameters != null && parameters.isNotEmpty) {
        debugPrint('$_infoPrefix [ANALYTICS] Parameters: $parameters');
      }
    }

    // 프로덕션에서는 실제 분석 서비스로 전송
    // TODO: Google Analytics, Mixpanel 등 통합
    // if (!kDebugMode) {
    //   AnalyticsService.logEvent(event, parameters: parameters);
    // }
  }
}
