// Application Error Handling System
// Centralized error handling with logging, user-friendly messages, and recovery strategies.

import '../utils/app_logger.dart';

// ========================================
// Base Exception Classes
// ========================================

/// Base class for all application exceptions
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;
  final Map<String, dynamic>? metadata;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
    this.metadata,
  });

  /// User-friendly error message (for display in UI)
  String get userMessage => message;

  /// Developer-friendly error message (for logging)
  String get developerMessage =>
    '$runtimeType: $message${code != null ? ' (Code: $code)' : ''}';

  @override
  String toString() => developerMessage;
}

// ========================================
// Network Exceptions
// ========================================

/// Network-related errors (connection, timeout, server errors)
class NetworkException extends AppException {
  final int? statusCode;
  final String? endpoint;

  const NetworkException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
    super.metadata,
    this.statusCode,
    this.endpoint,
  });

  @override
  String get userMessage {
    if (statusCode == 401 || statusCode == 403) {
      return '로그인이 필요합니다. 다시 로그인해주세요.';
    } else if (statusCode == 404) {
      return '요청한 정보를 찾을 수 없습니다.';
    } else if (statusCode == 500 || statusCode == 502 || statusCode == 503) {
      return '서버에 일시적인 문제가 발생했습니다. 잠시 후 다시 시도해주세요.';
    } else if (message.contains('timeout')) {
      return '네트워크 연결이 지연되고 있습니다. 잠시 후 다시 시도해주세요.';
    } else if (message.contains('socket') || message.contains('connection')) {
      return '인터넷 연결을 확인해주세요.';
    }
    return '네트워크 오류가 발생했습니다. 다시 시도해주세요.';
  }
}

// ========================================
// Authentication Exceptions
// ========================================

/// Authentication and authorization errors
class AuthException extends AppException {
  final AuthErrorType type;

  const AuthException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
    super.metadata,
    this.type = AuthErrorType.unknown,
  });

  @override
  String get userMessage {
    switch (type) {
      case AuthErrorType.invalidCredentials:
        return '이메일 또는 비밀번호가 올바르지 않습니다.';
      case AuthErrorType.userNotFound:
        return '존재하지 않는 계정입니다.';
      case AuthErrorType.emailAlreadyInUse:
        return '이미 사용 중인 이메일입니다.';
      case AuthErrorType.weakPassword:
        return '비밀번호가 너무 약합니다. 8자 이상 사용해주세요.';
      case AuthErrorType.networkError:
        return '네트워크 연결을 확인해주세요.';
      case AuthErrorType.tooManyRequests:
        return '너무 많은 시도가 있었습니다. 잠시 후 다시 시도해주세요.';
      case AuthErrorType.accountDisabled:
        return '비활성화된 계정입니다. 고객센터에 문의해주세요.';
      case AuthErrorType.sessionExpired:
        return '로그인 세션이 만료되었습니다. 다시 로그인해주세요.';
      case AuthErrorType.unknown:
        return '로그인 중 오류가 발생했습니다. 다시 시도해주세요.';
    }
  }
}

enum AuthErrorType {
  invalidCredentials,
  userNotFound,
  emailAlreadyInUse,
  weakPassword,
  networkError,
  tooManyRequests,
  accountDisabled,
  sessionExpired,
  unknown,
}

// ========================================
// Data Exceptions
// ========================================

/// Data parsing and validation errors
class DataException extends AppException {
  final String? fieldName;
  final dynamic invalidValue;

  const DataException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
    super.metadata,
    this.fieldName,
    this.invalidValue,
  });

  @override
  String get userMessage => '데이터 처리 중 오류가 발생했습니다.';
}

// ========================================
// Storage Exceptions
// ========================================

/// Local storage and database errors
class StorageException extends AppException {
  final StorageErrorType type;

  const StorageException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
    super.metadata,
    this.type = StorageErrorType.unknown,
  });

  @override
  String get userMessage {
    switch (type) {
      case StorageErrorType.notFound:
        return '데이터를 찾을 수 없습니다.';
      case StorageErrorType.permissionDenied:
        return '저장소 접근 권한이 없습니다.';
      case StorageErrorType.diskFull:
        return '저장 공간이 부족합니다.';
      case StorageErrorType.corrupted:
        return '데이터가 손상되었습니다.';
      case StorageErrorType.unknown:
        return '저장 중 오류가 발생했습니다.';
    }
  }
}

enum StorageErrorType {
  notFound,
  permissionDenied,
  diskFull,
  corrupted,
  unknown,
}

// ========================================
// Validation Exceptions
// ========================================

/// Input validation errors
class ValidationException extends AppException {
  final Map<String, List<String>>? errors;

  const ValidationException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
    super.metadata,
    this.errors,
  });

  @override
  String get userMessage {
    if (errors != null && errors!.isNotEmpty) {
      final firstError = errors!.values.first.first;
      return firstError;
    }
    return message;
  }
}

// ========================================
// Business Logic Exceptions
// ========================================

/// Business rule violations
class BusinessException extends AppException {
  const BusinessException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
    super.metadata,
  });

  @override
  String get userMessage => message;
}

// ========================================
// Error Handler
// ========================================

/// Centralized error handler
class AppErrorHandler {
  AppErrorHandler._();

  /// Handle any error and convert to AppException
  static AppException handle(dynamic error, [StackTrace? stackTrace]) {
    // Already an AppException
    if (error is AppException) {
      _logError(error);
      return error;
    }

    // Convert to appropriate AppException
    final appException = _convertToAppException(error, stackTrace);
    _logError(appException);
    return appException;
  }

  /// Convert unknown errors to AppException
  static AppException _convertToAppException(
    dynamic error,
    StackTrace? stackTrace,
  ) {
    // Network errors (from Dio, http, etc.)
    if (error.toString().contains('SocketException') ||
        error.toString().contains('Connection') ||
        error.toString().contains('timeout')) {
      return NetworkException(
        message: error.toString(),
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    // Firebase Auth errors
    if (error.toString().contains('firebase_auth')) {
      return AuthException(
        message: error.toString(),
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    // Format errors (JSON parsing, etc.)
    if (error is FormatException || error is TypeError) {
      return DataException(
        message: error.toString(),
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    // Generic app exception
    return DataException(
      message: error.toString(),
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  /// Log error with appropriate level
  static void _logError(AppException error) {
    final errorData = {
      'type': error.runtimeType.toString(),
      'message': error.message,
      'code': error.code,
      'metadata': error.metadata,
    };

    if (error is NetworkException) {
      AppLogger.warning(
        'Network Error',
        tag: 'Network',
        error: error,
        stackTrace: error.stackTrace,
        data: errorData,
      );
    } else if (error is AuthException) {
      AppLogger.error(
        'Auth Error',
        tag: 'Auth',
        error: error,
        stackTrace: error.stackTrace,
        data: errorData,
      );
    } else if (error is DataException) {
      AppLogger.error(
        'Data Error',
        tag: 'Data',
        error: error,
        stackTrace: error.stackTrace,
        data: errorData,
      );
    } else {
      AppLogger.error(
        'App Error',
        tag: 'Error',
        error: error,
        stackTrace: error.stackTrace,
        data: errorData,
      );
    }
  }

  /// Show error to user.
  ///
  /// 기본 구현은 로그만 남긴다. UI 레이어에서 BuildContext가 필요하므로
  /// 화면 단에서 직접 ScaffoldMessenger/SnackBar를 띄우는 것을 권장한다.
  /// 글로벌 핸들러 패턴이 필요하면 `GlobalKey&lt;ScaffoldMessengerState&gt;`를 주입해 확장.
  static void showToUser(AppException error) {
    AppLogger.debug('Show to user: ${error.userMessage}');
  }
}
