import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

/// 앱 전역 에러 핸들러
///
/// 모든 에러를 중앙집중식으로 처리하며, 개발/프로덕션 환경에 따라
/// 다른 처리를 수행합니다.
class AppErrorHandler {
  AppErrorHandler._(); // private constructor

  /// 전역 네비게이터 키 (다이얼로그 표시용)
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// 에러 처리
  ///
  /// [error]: 발생한 에러
  /// [stackTrace]: 스택 트레이스
  /// [context]: 에러 발생 컨텍스트 (선택적)
  /// [showToUser]: 사용자에게 에러 메시지 표시 여부
  static Future<void> handleError(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
    bool showToUser = true,
  }) async {
    // 1. 디버그 모드: 콘솔 로그
    if (kDebugMode) {
      debugPrint('🔴 Error${context != null ? ' in $context' : ''}: $error');
      if (stackTrace != null) {
        debugPrintStack(stackTrace: stackTrace, label: 'Stack Trace');
      }
    }

    // 2. 프로덕션 모드: 로깅 서비스 전송
    if (kReleaseMode) {
      // Firebase Crashlytics 또는 Sentry 등으로 전송
      // await FirebaseCrashlytics.instance.recordError(
      //   error,
      //   stackTrace,
      //   reason: context,
      // );
    }

    // 3. 사용자에게 친화적인 메시지 표시
    if (showToUser) {
      final friendlyMessage = _getUserFriendlyMessage(error);
      _showErrorToUser(friendlyMessage);
    }
  }

  /// 에러를 사용자 친화적 메시지로 변환
  static String _getUserFriendlyMessage(dynamic error) {
    if (error is TimeoutException) {
      return '요청 시간이 초과되었습니다. 다시 시도해주세요.';
    }

    if (error is FormatException) {
      return '데이터 형식이 올바르지 않습니다.';
    }

    if (error is TypeError) {
      return '일시적인 오류가 발생했습니다.';
    }

    // 네트워크 관련 에러
    if (error.toString().contains('SocketException') ||
        error.toString().contains('NetworkException')) {
      return '인터넷 연결을 확인해주세요.';
    }

    // 인증 관련 에러
    if (error.toString().contains('Unauthorized') ||
        error.toString().contains('401')) {
      return '로그인이 필요합니다.';
    }

    // 권한 관련 에러
    if (error.toString().contains('Forbidden') ||
        error.toString().contains('403')) {
      return '접근 권한이 없습니다.';
    }

    // 서버 에러
    if (error.toString().contains('500') ||
        error.toString().contains('ServerException')) {
      return '서버에 문제가 발생했습니다. 잠시 후 다시 시도해주세요.';
    }

    // 기본 메시지
    return '일시적인 오류가 발생했습니다. 다시 시도해주세요.';
  }

  /// 사용자에게 에러 메시지 표시
  static void _showErrorToUser(String message) {
    final context = navigatorKey.currentContext;
    if (context == null || !context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('오류'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  /// SnackBar로 에러 표시 (간단한 에러용)
  static void showErrorSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: '확인',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// 성공 메시지 표시
  static void showSuccessSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// 정보 메시지 표시
  static void showInfoSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue.shade600,
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