import 'package:flutter/foundation.dart';

/// 앱 전체에서 사용하는 로거 유틸리티
class Logger {
  /// 정보 로그
  static void info(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag]' : '';
      print('ℹ️ $prefix $message');
    }
  }

  /// 경고 로그
  static void warning(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag]' : '';
      print('⚠️ $prefix $message');
    }
  }

  /// 오류 로그
  static void error(String message, {Object? error, StackTrace? stackTrace, String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag]' : '';
      print('❌ $prefix $message');
      if (error != null) {
        print('   Error: $error');
      }
      if (stackTrace != null) {
        print('   StackTrace: $stackTrace');
      }
    }
  }

  /// 디버그 로그
  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag]' : '';
      print('🐛 $prefix $message');
    }
  }
}
