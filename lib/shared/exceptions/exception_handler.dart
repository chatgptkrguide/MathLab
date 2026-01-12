import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'app_exception.dart';

/// 예외 변환 및 처리 유틸리티
class ExceptionHandler {
  ExceptionHandler._();

  /// Firebase Auth 에러를 AppException으로 변환
  static AppException fromFirebaseAuth(
    firebase_auth.FirebaseAuthException error,
  ) {
    switch (error.code) {
      case 'user-not-found':
      case 'wrong-password':
        return AuthException(
          '이메일 또는 비밀번호가 올바르지 않습니다',
          details: error.code,
          originalError: error,
          stackTrace: error.stackTrace,
        );
      case 'email-already-in-use':
        return AuthException(
          '이미 사용 중인 이메일입니다',
          details: error.code,
          originalError: error,
          stackTrace: error.stackTrace,
        );
      case 'invalid-email':
        return ValidationException(
          '유효하지 않은 이메일 형식입니다',
          details: error.code,
          originalError: error,
          stackTrace: error.stackTrace,
        );
      case 'weak-password':
        return ValidationException(
          '비밀번호가 너무 약합니다',
          details: error.code,
          originalError: error,
          stackTrace: error.stackTrace,
        );
      case 'user-disabled':
        return AuthException(
          '비활성화된 계정입니다',
          details: error.code,
          originalError: error,
          stackTrace: error.stackTrace,
        );
      case 'too-many-requests':
        return ResourceLimitException(
          '너무 많은 시도가 있었습니다. 잠시 후 다시 시도해주세요',
          details: error.code,
          originalError: error,
          stackTrace: error.stackTrace,
        );
      case 'operation-not-allowed':
        return UnauthorizedException(
          '허용되지 않은 작업입니다',
          details: error.code,
          originalError: error,
          stackTrace: error.stackTrace,
        );
      case 'network-request-failed':
        return NetworkException(
          '네트워크 연결을 확인해주세요',
          details: error.code,
          originalError: error,
          stackTrace: error.stackTrace,
        );
      default:
        return AuthException(
          error.message ?? '인증 중 오류가 발생했습니다',
          details: error.code,
          originalError: error,
          stackTrace: error.stackTrace,
        );
    }
  }

  /// Firestore 에러를 AppException으로 변환
  static AppException fromFirestore(
    firestore.FirebaseException error,
  ) {
    switch (error.code) {
      case 'permission-denied':
        return UnauthorizedException(
          '접근 권한이 없습니다',
          details: error.code,
          originalError: error,
          stackTrace: error.stackTrace,
        );
      case 'not-found':
        return NotFoundException(
          '데이터를 찾을 수 없습니다',
          details: error.code,
          originalError: error,
          stackTrace: error.stackTrace,
        );
      case 'already-exists':
        return DuplicateOperationException(
          '이미 존재하는 데이터입니다',
          details: error.code,
          originalError: error,
          stackTrace: error.stackTrace,
        );
      case 'resource-exhausted':
        return ResourceLimitException(
          '할당량을 초과했습니다',
          details: error.code,
          originalError: error,
          stackTrace: error.stackTrace,
        );
      case 'unavailable':
        return ServerException(
          '서버를 사용할 수 없습니다',
          details: error.code,
          originalError: error,
          stackTrace: error.stackTrace,
        );
      case 'deadline-exceeded':
        return TimeoutException(
          '요청 시간이 초과되었습니다',
          details: error.code,
          originalError: error,
          stackTrace: error.stackTrace,
        );
      default:
        return FirestoreException(
          error.message ?? '데이터베이스 작업 중 오류가 발생했습니다',
          details: error.code,
          originalError: error,
          stackTrace: error.stackTrace,
        );
    }
  }

  /// 일반 Exception을 AppException으로 변환
  static AppException fromException(
    Object error, [
    StackTrace? stackTrace,
  ]) {
    // 이미 AppException인 경우 그대로 반환
    if (error is AppException) {
      return error;
    }

    // Firebase Auth Exception
    if (error is firebase_auth.FirebaseAuthException) {
      return fromFirebaseAuth(error);
    }

    // Firestore Exception
    if (error is firestore.FirebaseException) {
      return fromFirestore(error);
    }

    // FormatException (파싱 에러)
    if (error is FormatException) {
      return ParseException(
        '데이터 형식이 올바르지 않습니다',
        details: error.message,
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    // 기타 예외
    return UnknownException(
      '예상치 못한 오류가 발생했습니다',
      details: error.toString(),
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  /// 에러를 사용자 친화적인 메시지로 변환
  static String getUserMessage(Object error) {
    if (error is AppException) {
      return error.message;
    }
    return '오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
  }

  /// 에러가 재시도 가능한지 확인
  static bool isRetryable(Object error) {
    if (error is NetworkException ||
        error is TimeoutException ||
        error is ServerException) {
      return true;
    }
    return false;
  }

  /// 에러가 인증 재시도가 필요한지 확인
  static bool needsReauth(Object error) {
    return error is SessionExpiredException || error is UnauthorizedException;
  }
}
