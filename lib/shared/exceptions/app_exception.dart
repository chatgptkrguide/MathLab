/// MathLab 앱의 커스텀 예외 클래스 계층 구조
/// 
/// 모든 앱 예외는 AppException을 상속받아야 하며,
/// 사용자에게 표시할 수 있는 메시지를 포함해야 합니다.

/// 기본 앱 예외 클래스
abstract class AppException implements Exception {
  /// 사용자에게 표시할 메시지
  final String message;
  
  /// 개발자를 위한 상세 정보 (로깅용)
  final String? details;
  
  /// 원본 에러 (있는 경우)
  final Object? originalError;
  
  /// 스택 트레이스
  final StackTrace? stackTrace;

  const AppException(
    this.message, {
    this.details,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() {
    final buffer = StringBuffer('$runtimeType: $message');
    if (details != null) {
      buffer.write('\nDetails: $details');
    }
    if (originalError != null) {
      buffer.write('\nOriginal error: $originalError');
    }
    return buffer.toString();
  }
}

// ==========================================
// 네트워크 관련 예외
// ==========================================

/// 네트워크 연결 실패
class NetworkException extends AppException {
  const NetworkException([
    String message = '네트워크 연결에 실패했습니다',
    String? details,
    Object? originalError,
    StackTrace? stackTrace,
  ]) : super(
          message,
          details: details,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// API 요청 타임아웃
class TimeoutException extends AppException {
  const TimeoutException([
    String message = '요청 시간이 초과되었습니다',
    String? details,
    Object? originalError,
    StackTrace? stackTrace,
  ]) : super(
          message,
          details: details,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// 서버 에러 (5xx)
class ServerException extends AppException {
  final int? statusCode;

  const ServerException([
    String message = '서버에서 오류가 발생했습니다',
    String? details,
    this.statusCode,
    Object? originalError,
    StackTrace? stackTrace,
  ]) : super(
          message,
          details: details,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

// ==========================================
// 인증 관련 예외
// ==========================================

/// 인증 실패
class AuthException extends AppException {
  const AuthException([
    String message = '인증에 실패했습니다',
    String? details,
    Object? originalError,
    StackTrace? stackTrace,
  ]) : super(
          message,
          details: details,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// 권한 없음 (403)
class UnauthorizedException extends AppException {
  const UnauthorizedException([
    String message = '접근 권한이 없습니다',
    String? details,
    Object? originalError,
    StackTrace? stackTrace,
  ]) : super(
          message,
          details: details,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// 세션 만료
class SessionExpiredException extends AuthException {
  const SessionExpiredException([
    String message = '세션이 만료되었습니다. 다시 로그인해주세요',
    String? details,
    Object? originalError,
    StackTrace? stackTrace,
  ]) : super(
          message,
          details,
          originalError,
          stackTrace,
        );
}

// ==========================================
// 데이터 관련 예외
// ==========================================

/// 데이터 로드 실패
class DataException extends AppException {
  const DataException([
    String message = '데이터를 불러올 수 없습니다',
    String? details,
    Object? originalError,
    StackTrace? stackTrace,
  ]) : super(
          message,
          details: details,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// 데이터를 찾을 수 없음 (404)
class NotFoundException extends DataException {
  const NotFoundException([
    String message = '요청한 데이터를 찾을 수 없습니다',
    String? details,
    Object? originalError,
    StackTrace? stackTrace,
  ]) : super(
          message,
          details,
          originalError,
          stackTrace,
        );
}

/// 데이터 파싱 실패
class ParseException extends DataException {
  const ParseException([
    String message = '데이터 형식이 올바르지 않습니다',
    String? details,
    Object? originalError,
    StackTrace? stackTrace,
  ]) : super(
          message,
          details,
          originalError,
          stackTrace,
        );
}

// ==========================================
// 유효성 검증 예외
// ==========================================

/// 입력값 검증 실패
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException([
    String message = '입력값이 올바르지 않습니다',
    String? details,
    this.fieldErrors,
    Object? originalError,
    StackTrace? stackTrace,
  ]) : super(
          message,
          details: details,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

// ==========================================
// 저장소 관련 예외
// ==========================================

/// 로컬 저장소 에러
class StorageException extends AppException {
  const StorageException([
    String message = '저장소 작업에 실패했습니다',
    String? details,
    Object? originalError,
    StackTrace? stackTrace,
  ]) : super(
          message,
          details: details,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// Firestore 에러
class FirestoreException extends DataException {
  const FirestoreException([
    String message = '데이터베이스 작업에 실패했습니다',
    String? details,
    Object? originalError,
    StackTrace? stackTrace,
  ]) : super(
          message,
          details,
          originalError,
          stackTrace,
        );
}

// ==========================================
// 비즈니스 로직 예외
// ==========================================

/// 비즈니스 규칙 위반
class BusinessException extends AppException {
  const BusinessException(
    String message, {
    String? details,
    Object? originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          details: details,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// 작업 중복 (이미 진행 중인 작업)
class DuplicateOperationException extends BusinessException {
  const DuplicateOperationException([
    String message = '이미 진행 중인 작업입니다',
    String? details,
    Object? originalError,
    StackTrace? stackTrace,
  ]) : super(
          message,
          details: details,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// 리소스 제한 초과
class ResourceLimitException extends BusinessException {
  const ResourceLimitException([
    String message = '허용된 제한을 초과했습니다',
    String? details,
    Object? originalError,
    StackTrace? stackTrace,
  ]) : super(
          message,
          details: details,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

// ==========================================
// 캐시 관련 예외
// ==========================================

/// 캐시 에러
class CacheException extends AppException {
  const CacheException([
    String message = '캐시 작업에 실패했습니다',
    String? details,
    Object? originalError,
    StackTrace? stackTrace,
  ]) : super(
          message,
          details: details,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

// ==========================================
// 알 수 없는 예외
// ==========================================

/// 예상치 못한 에러
class UnknownException extends AppException {
  const UnknownException([
    String message = '예상치 못한 오류가 발생했습니다',
    String? details,
    Object? originalError,
    StackTrace? stackTrace,
  ]) : super(
          message,
          details: details,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}
