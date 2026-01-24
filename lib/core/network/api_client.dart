/// 🌐 API Client
///
/// HTTP client with automatic error handling, logging, retry logic,
/// and authentication token injection.
///
/// Usage:
/// ```dart
/// final client = ApiClient();
/// final response = await client.get('/users/123');
/// ```

import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../config/env_config.dart';
import '../error/app_error.dart';
import '../utils/app_logger.dart';
import '../security/secure_storage_service.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

class ApiClient {
  late final Dio _dio;
  final SecureStorageService _storage = SecureStorageService();

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) {
          // Accept all status codes to handle errors in interceptor
          return status != null && status < 500;
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.addAll([
      AuthInterceptor(_storage),      // Inject auth tokens
      RetryInterceptor(_dio),          // Retry failed requests
      LoggingInterceptor(),            // Log requests/responses
    ]);
  }

  // ========================================
  // HTTP Methods
  // ========================================

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    await _checkConnectivity();

    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e, st) {
      throw AppErrorHandler.handle(e, st);
    }
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    await _checkConnectivity();

    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e, st) {
      throw AppErrorHandler.handle(e, st);
    }
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    await _checkConnectivity();

    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e, st) {
      throw AppErrorHandler.handle(e, st);
    }
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    await _checkConnectivity();

    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e, st) {
      throw AppErrorHandler.handle(e, st);
    }
  }

  /// PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    await _checkConnectivity();

    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e, st) {
      throw AppErrorHandler.handle(e, st);
    }
  }

  // ========================================
  // Error Handling
  // ========================================

  /// Convert Dio errors to AppException
  AppException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          message: '연결 시간이 초과되었습니다',
          code: 'TIMEOUT',
          statusCode: error.response?.statusCode,
          endpoint: error.requestOptions.path,
          originalError: error,
          stackTrace: error.stackTrace,
        );

      case DioExceptionType.badResponse:
        return NetworkException(
          message: _getErrorMessage(error.response),
          code: error.response?.statusCode.toString(),
          statusCode: error.response?.statusCode,
          endpoint: error.requestOptions.path,
          originalError: error,
          stackTrace: error.stackTrace,
        );

      case DioExceptionType.cancel:
        return NetworkException(
          message: '요청이 취소되었습니다',
          code: 'CANCELLED',
          endpoint: error.requestOptions.path,
          originalError: error,
          stackTrace: error.stackTrace,
        );

      case DioExceptionType.connectionError:
        return NetworkException(
          message: '네트워크 연결을 확인해주세요',
          code: 'CONNECTION_ERROR',
          endpoint: error.requestOptions.path,
          originalError: error,
          stackTrace: error.stackTrace,
        );

      case DioExceptionType.badCertificate:
        return NetworkException(
          message: '보안 인증서 오류가 발생했습니다',
          code: 'BAD_CERTIFICATE',
          endpoint: error.requestOptions.path,
          originalError: error,
          stackTrace: error.stackTrace,
        );

      case DioExceptionType.unknown:
        return NetworkException(
          message: '알 수 없는 오류가 발생했습니다',
          code: 'UNKNOWN',
          endpoint: error.requestOptions.path,
          originalError: error,
          stackTrace: error.stackTrace,
        );
    }
  }

  /// Extract error message from response
  String _getErrorMessage(Response? response) {
    if (response == null) return '서버 응답을 받지 못했습니다';

    try {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data['message'] ?? data['error'] ?? '오류가 발생했습니다';
      }
    } catch (e) {
      // Ignore parsing errors
    }

    return 'HTTP ${response.statusCode}: ${response.statusMessage ?? "오류"}';
  }

  // ========================================
  // Connectivity Check
  // ========================================

  /// Check network connectivity before making request
  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      throw const NetworkException(
        message: '인터넷 연결을 확인해주세요',
        code: 'NO_INTERNET',
      );
    }
  }

  // ========================================
  // Utility Methods
  // ========================================

  /// Get Dio instance for advanced usage
  Dio get dio => _dio;

  /// Update base URL (for environment switching)
  void updateBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }

  /// Add custom interceptor
  void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }

  /// Clear all interceptors
  void clearInterceptors() {
    _dio.interceptors.clear();
  }
}
