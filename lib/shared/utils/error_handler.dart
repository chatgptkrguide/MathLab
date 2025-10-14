import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 전역 에러 핸들러
class AppErrorHandler {
  static void handleError(dynamic error, StackTrace? stackTrace, {String? context}) {
    if (kDebugMode) {
      debugPrint('🔴 Error in $context: $error');
      debugPrintStack(stackTrace: stackTrace);
    }

    // TODO: 프로덕션에서는 로깅 서비스로 전송
    // FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

/// 안전한 비동기 작업 실행기
class SafeAsyncExecutor {
  static Future<T?> execute<T>(
    Future<T> Function() operation, {
    String? context,
    bool showErrorToUser = false,
    BuildContext? errorContext,
  }) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      AppErrorHandler.handleError(error, stackTrace, context: context);

      if (showErrorToUser && errorContext != null) {
        AppErrorHandler.showErrorSnackBar(
          errorContext,
          '작업 중 오류가 발생했습니다.',
        );
      }

      return null;
    }
  }
}