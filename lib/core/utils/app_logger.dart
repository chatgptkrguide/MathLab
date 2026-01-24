/// 📝 Application Logging System
///
/// Centralized logging utility with multiple log levels, tags, and
/// conditional logging based on environment.
///
/// Usage:
/// ```dart
/// AppLogger.debug('Debug message');
/// AppLogger.info('User logged in', tag: 'Auth');
/// AppLogger.error('Failed to load', error: e, stackTrace: st);
/// ```

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../config/env_config.dart';

class AppLogger {
  AppLogger._();

  static final Logger _logger = Logger(
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

  /// Get log level based on environment
  static Level _getLogLevel() {
    if (kReleaseMode && EnvConfig.isProduction) {
      return Level.error; // Only errors in production
    } else if (EnvConfig.isProduction) {
      return Level.warning; // Warnings and errors in production debug
    }
    return Level.debug; // All logs in development
  }

  /// Debug log (detailed information for debugging)
  static void debug(
    String message, {
    String? tag,
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    if (!EnvConfig.enableLogging) return;

    final formattedMessage = _formatMessage(message, tag, data);
    _logger.d(formattedMessage, error: error, stackTrace: stackTrace);
  }

  /// Info log (general informational messages)
  static void info(
    String message, {
    String? tag,
    Map<String, dynamic>? data,
  }) {
    if (!EnvConfig.enableLogging) return;

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

    // TODO: Send to crash reporting service (Firebase Crashlytics, Sentry, etc.)
    _reportToCrashlytics(message, error, stackTrace, data);
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

    // TODO: Send to crash reporting service immediately
    _reportToCrashlytics(message, error, stackTrace, data);
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
  static void _reportToCrashlytics(
    String message,
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  ) {
    // TODO: Implement Firebase Crashlytics reporting
    // FirebaseCrashlytics.instance.recordError(error, stackTrace,
    //   reason: message,
    //   information: data?.entries.map((e) => '${e.key}: ${e.value}').toList() ?? [],
    // );
  }

  /// Log network request
  static void logNetworkRequest({
    required String method,
    required String url,
    Map<String, dynamic>? headers,
    dynamic body,
  }) {
    if (!EnvConfig.enableLogging || !kDebugMode) return;

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
    if (!EnvConfig.enableLogging || !kDebugMode) return;

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

    // TODO: Send to analytics service (Firebase Analytics, Mixpanel, etc.)
    // FirebaseAnalytics.instance.logEvent(
    //   name: action,
    //   parameters: parameters,
    // );
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
