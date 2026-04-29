// 📝 Application Logging System
//
// Centralized logging utility with multiple log levels, tags, and
// conditional logging based on environment.
//
// Usage:
// ```dart
// AppLogger.debug('Debug message');
// AppLogger.info('User logged in', tag: 'Auth');
// AppLogger.error('Failed to load', error: e, stackTrace: st);
// ```

import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:logger/logger.dart';
import '../config/env_config.dart';

class AppLogger {
  AppLogger._();

  static Logger? _loggerInstance;

  static Logger get _logger {
    _loggerInstance ??= Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 5,
        lineLength: 80,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      level: _getLogLevel(),
    );
    return _loggerInstance!;
  }

  /// EnvConfig.enableLogging 조회 — env 미로드 시 안전하게 true 반환.
  static bool _loggingEnabled() {
    try {
      return EnvConfig.enableLogging;
    } catch (_) {
      // env not initialized yet → allow logging in this very early window
      return true;
    }
  }

  /// Get log level based on environment.
  /// EnvConfig 초기화 전에 호출되면 dotenv 미로드 예외가 던져질 수 있어 의도적으로 무시한다.
  static Level _getLogLevel() {
    try {
      if (kReleaseMode && EnvConfig.isProduction) {
        return Level.error;
      } else if (EnvConfig.isProduction) {
        return Level.warning;
      }
    } catch (_) {
      // Fallback: assume development before env is loaded.
    }
    return Level.debug;
  }

  /// Debug log (detailed information for debugging)
  static void debug(
    String message, {
    String? tag,
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    if (!_loggingEnabled()) return;

    final formattedMessage = _formatMessage(message, tag, data);
    _logger.d(formattedMessage, error: error, stackTrace: stackTrace);
  }

  /// Info log (general informational messages)
  static void info(
    String message, {
    String? tag,
    Map<String, dynamic>? data,
  }) {
    if (!_loggingEnabled()) return;

    final formattedMessage = _formatMessage(message, tag, data);
    _logger.i(formattedMessage);
  }

  /// Warning log (potentially harmful situations)
  static void warning(
    String message, {
    String? tag,
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    final formattedMessage = _formatMessage(message, tag, data);
    _logger.w(formattedMessage, error: error, stackTrace: stackTrace);
  }

  /// Error log (error events that might still allow the app to continue)
  static void error(
    String message, {
    String? tag,
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    final formattedMessage = _formatMessage(message, tag, data);
    _logger.e(formattedMessage, error: error, stackTrace: stackTrace);

    // Send to Firebase Crashlytics (non-fatal)
    _reportToCrashlytics(message, error, stackTrace, data, fatal: false);
  }

  /// Fatal log (very severe error events that will presumably lead the app to abort)
  static void fatal(
    String message, {
    String? tag,
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    final formattedMessage = _formatMessage(message, tag, data);
    _logger.f(formattedMessage, error: error, stackTrace: stackTrace);

    // Send to Firebase Crashlytics (fatal)
    _reportToCrashlytics(message, error, stackTrace, data, fatal: true);
  }

  /// Format message with tag and data
  static String _formatMessage(
    String message,
    String? tag,
    Map<String, dynamic>? data,
  ) {
    final buffer = StringBuffer();

    if (tag != null) {
      buffer.write('[$tag] ');
    }

    buffer.write(message);

    if (data != null && data.isNotEmpty) {
      buffer.write('\nData: ${data.toString()}');
    }

    return buffer.toString();
  }

  /// Report to crash reporting service (Firebase Crashlytics)
  static Future<void> _reportToCrashlytics(
    String message,
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data, {
    bool fatal = false,
  }) async {
    // Skip in debug mode to avoid polluting crashlytics with dev errors
    if (kDebugMode) {
      return;
    }

    try {
      final crashlytics = FirebaseCrashlytics.instance;

      // Set custom keys for additional context
      if (data != null) {
        for (final entry in data.entries) {
          await crashlytics.setCustomKey(entry.key, entry.value.toString());
        }
      }

      // Log the message
      await crashlytics.log(message);

      // Record the error if present
      if (error != null) {
        await crashlytics.recordError(
          error,
          stackTrace,
          reason: message,
          fatal: fatal,
        );
      }
    } catch (e) {
      // Silently fail if crashlytics fails (avoid infinite loop)
      debugPrint('Failed to report to Crashlytics: $e');
    }
  }

  /// Log network request
  static void logNetworkRequest({
    required String method,
    required String url,
    Map<String, dynamic>? headers,
    dynamic body,
  }) {
    if (!kDebugMode || !_loggingEnabled()) return;

    debug(
      'HTTP Request',
      tag: 'Network',
      data: {
        'method': method,
        'url': url,
        if (headers != null) 'headers': headers,
        if (body != null) 'body': body,
      },
    );
  }

  /// Log network response
  static void logNetworkResponse({
    required String method,
    required String url,
    required int statusCode,
    dynamic body,
    Duration? duration,
  }) {
    if (!kDebugMode || !_loggingEnabled()) return;

    debug(
      'HTTP Response',
      tag: 'Network',
      data: {
        'method': method,
        'url': url,
        'statusCode': statusCode,
        if (duration != null) 'duration': '${duration.inMilliseconds}ms',
        if (body != null) 'body': body,
      },
    );
  }

  /// Log user action for analytics
  static void logUserAction(
    String action, {
    Map<String, dynamic>? parameters,
  }) {
    info(
      'User Action: $action',
      tag: 'Analytics',
      data: parameters,
    );

    // Send to Firebase Analytics
    logEvent(action, parameters: parameters?.map(
      (key, value) => MapEntry(key, value is Object ? value : value.toString()),
    ));
  }

  /// Send analytics event to Firebase Analytics
  static Future<void> logEvent(
    String name, {
    Map<String, Object>? parameters,
  }) async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: name,
        parameters: parameters,
      );
    } catch (e) {
      // Analytics failure should not affect app behavior
      debugPrint('Failed to log analytics event: $e');
    }
  }

  /// Log performance metrics
  static void logPerformance(
    String operation,
    Duration duration, {
    Map<String, dynamic>? metadata,
  }) {
    info(
      'Performance: $operation took ${duration.inMilliseconds}ms',
      tag: 'Performance',
      data: metadata,
    );
  }
}
