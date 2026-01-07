import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'logger.dart';

/// 앱 전체 에러 핸들러
///
/// API, Firebase, 일반 에러를 일관되게 처리
class ErrorHandler {
  /// API 에러 처리
  static AppException handleApiError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          Logger.error('네트워크 타임아웃', tag: 'ErrorHandler', error: error);
          return NetworkException(
            message: '서버 응답이 없습니다. 네트워크 연결을 확인해주세요.',
            statusCode: 408,
          );

        case DioExceptionType.connectionError:
          Logger.error('네트워크 연결 실패', tag: 'ErrorHandler', error: error);
          return NetworkException(
            message: '인터넷 연결을 확인해주세요.',
            statusCode: 0,
          );

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode ?? 500;
          final message = _getHttpErrorMessage(statusCode);
          Logger.error('HTTP 에러: $statusCode',
              tag: 'ErrorHandler', error: error);

          return ApiException(
            message: message,
            statusCode: statusCode,
            response: error.response?.data,
          );

        case DioExceptionType.cancel:
          Logger.warning('요청 취소됨', tag: 'ErrorHandler');
          return AppException(message: '요청이 취소되었습니다.');

        default:
          Logger.error('알 수 없는 네트워크 에러', tag: 'ErrorHandler', error: error);
          return NetworkException(
            message: '네트워크 오류가 발생했습니다.',
            statusCode: 0,
          );
      }
    }

    Logger.error('알 수 없는 API 에러', tag: 'ErrorHandler', error: error);
    return AppException(message: '알 수 없는 오류가 발생했습니다.');
  }

  /// Firebase Auth 에러 처리
  static AppException handleFirebaseAuthError(FirebaseAuthException error) {
    Logger.error('Firebase Auth 에러: ${error.code}',
        tag: 'ErrorHandler', error: error);

    switch (error.code) {
      case 'weak-password':
        return AuthException(
          message: '비밀번호가 너무 약합니다. 6자 이상 입력해주세요.',
          code: error.code,
        );

      case 'email-already-in-use':
        return AuthException(
          message: '이미 사용 중인 이메일입니다.',
          code: error.code,
        );

      case 'invalid-email':
        return AuthException(
          message: '유효하지 않은 이메일 주소입니다.',
          code: error.code,
        );

      case 'user-not-found':
        return AuthException(
          message: '등록되지 않은 이메일입니다.',
          code: error.code,
        );

      case 'wrong-password':
        return AuthException(
          message: '비밀번호가 올바르지 않습니다.',
          code: error.code,
        );

      case 'user-disabled':
        return AuthException(
          message: '비활성화된 계정입니다.',
          code: error.code,
        );

      case 'too-many-requests':
        return AuthException(
          message: '너무 많은 요청이 발생했습니다. 잠시 후 다시 시도해주세요.',
          code: error.code,
        );

      case 'operation-not-allowed':
        return AuthException(
          message: '이 로그인 방법은 현재 사용할 수 없습니다.',
          code: error.code,
        );

      case 'requires-recent-login':
        return AuthException(
          message: '보안을 위해 다시 로그인해주세요.',
          code: error.code,
        );

      case 'expired-action-code':
        return AuthException(
          message: '인증 코드가 만료되었습니다.',
          code: error.code,
        );

      case 'invalid-action-code':
        return AuthException(
          message: '유효하지 않은 인증 코드입니다.',
          code: error.code,
        );

      default:
        return AuthException(
          message: error.message ?? '인증 오류가 발생했습니다.',
          code: error.code,
        );
    }
  }

  /// Firestore 에러 처리
  static AppException handleFirestoreError(FirebaseException error) {
    Logger.error('Firestore 에러: ${error.code}',
        tag: 'ErrorHandler', error: error);

    switch (error.code) {
      case 'permission-denied':
        return FirestoreException(
          message: '권한이 없습니다.',
          code: error.code,
        );

      case 'not-found':
        return FirestoreException(
          message: '요청한 데이터를 찾을 수 없습니다.',
          code: error.code,
        );

      case 'already-exists':
        return FirestoreException(
          message: '이미 존재하는 데이터입니다.',
          code: error.code,
        );

      case 'resource-exhausted':
        return FirestoreException(
          message: '할당량을 초과했습니다. 잠시 후 다시 시도해주세요.',
          code: error.code,
        );

      case 'cancelled':
        return FirestoreException(
          message: '작업이 취소되었습니다.',
          code: error.code,
        );

      case 'unavailable':
        return FirestoreException(
          message: '서버에 연결할 수 없습니다.',
          code: error.code,
        );

      case 'deadline-exceeded':
        return FirestoreException(
          message: '작업 시간이 초과되었습니다.',
          code: error.code,
        );

      default:
        return FirestoreException(
          message: error.message ?? '데이터베이스 오류가 발생했습니다.',
          code: error.code,
        );
    }
  }

  /// 일반 예외 처리
  static AppException handleGenericError(Object error) {
    if (error is AppException) {
      return error;
    }

    if (error is FirebaseAuthException) {
      return handleFirebaseAuthError(error);
    }

    if (error is FirebaseException) {
      return handleFirestoreError(error);
    }

    if (error is DioException) {
      return handleApiError(error);
    }

    Logger.error('처리되지 않은 에러', tag: 'ErrorHandler', error: error);
    return AppException(message: '알 수 없는 오류가 발생했습니다.');
  }

  /// HTTP 상태 코드별 메시지
  static String _getHttpErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return '잘못된 요청입니다.';
      case 401:
        return '인증이 필요합니다. 다시 로그인해주세요.';
      case 403:
        return '접근 권한이 없습니다.';
      case 404:
        return '요청한 리소스를 찾을 수 없습니다.';
      case 408:
        return '요청 시간이 초과되었습니다.';
      case 409:
        return '충돌이 발생했습니다. 다시 시도해주세요.';
      case 429:
        return '너무 많은 요청입니다. 잠시 후 다시 시도해주세요.';
      case 500:
        return '서버 내부 오류가 발생했습니다.';
      case 502:
        return '서버 게이트웨이 오류입니다.';
      case 503:
        return '서비스를 일시적으로 사용할 수 없습니다.';
      case 504:
        return '서버 응답 시간이 초과되었습니다.';
      default:
        if (statusCode >= 500) {
          return '서버 오류가 발생했습니다.';
        } else if (statusCode >= 400) {
          return '요청 처리 중 오류가 발생했습니다.';
        }
        return '알 수 없는 오류가 발생했습니다.';
    }
  }
}

// ==================== 예외 클래스 ====================

/// 기본 앱 예외
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AppException({
    required this.message,
    this.code,
    this.details,
  });

  @override
  String toString() => message;
}

/// API 예외
class ApiException extends AppException {
  final int statusCode;
  final dynamic response;

  ApiException({
    required super.message,
    required this.statusCode,
    this.response,
    super.code,
  }) : super(details: response);
}

/// 네트워크 예외
class NetworkException extends AppException {
  final int statusCode;

  NetworkException({
    required super.message,
    required this.statusCode,
    super.code,
  });
}

/// 인증 예외
class AuthException extends AppException {
  AuthException({
    required super.message,
    super.code,
  });
}

/// Firestore 예외
class FirestoreException extends AppException {
  FirestoreException({
    required super.message,
    super.code,
  });
}

/// 검증 예외
class ValidationException extends AppException {
  final Map<String, String>? errors;

  ValidationException({
    required super.message,
    this.errors,
  }) : super(details: errors);
}

/// 권한 예외
class PermissionException extends AppException {
  PermissionException({
    required super.message,
    super.code,
  });
}

/// 비즈니스 로직 예외
class BusinessException extends AppException {
  BusinessException({
    required super.message,
    super.code,
    super.details,
  });
}

// ==================== 재시도 유틸리티 ====================

/// 재시도 헬퍼
class RetryHelper {
  /// 지수 백오프로 재시도
  static Future<T> retryWithBackoff<T>({
    required Future<T> Function() operation,
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
    double backoffMultiplier = 2.0,
    bool Function(Object)? shouldRetry,
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;

    while (true) {
      try {
        return await operation();
      } catch (error) {
        attempt++;

        // 재시도 가능 여부 확인
        final canRetry = shouldRetry?.call(error) ?? _defaultShouldRetry(error);

        if (attempt >= maxRetries || !canRetry) {
          Logger.error(
            '재시도 최대 횟수 초과 또는 재시도 불가 에러',
            tag: 'RetryHelper',
            error: error,
          );
          rethrow;
        }

        Logger.warning(
          '재시도 ($attempt/$maxRetries) - ${delay.inSeconds}초 대기',
          tag: 'RetryHelper',
        );

        await Future.delayed(delay);
        delay = Duration(
            milliseconds: (delay.inMilliseconds * backoffMultiplier).round());
      }
    }
  }

  /// 기본 재시도 조건
  static bool _defaultShouldRetry(Object error) {
    // 네트워크 에러는 재시도
    if (error is DioException) {
      return error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionError ||
          (error.response?.statusCode != null &&
              error.response!.statusCode! >= 500);
    }

    // Firebase unavailable 에러는 재시도
    if (error is FirebaseException) {
      return error.code == 'unavailable' ||
          error.code == 'deadline-exceeded' ||
          error.code == 'resource-exhausted';
    }

    return false;
  }
}
