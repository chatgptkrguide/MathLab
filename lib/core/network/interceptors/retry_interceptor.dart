// 🔄 Retry Interceptor
//
// Automatically retries failed requests with exponential backoff.
// Only retries on network errors and 5xx server errors.

import 'package:dio/dio.dart';
import '../../utils/app_logger.dart';

class RetryInterceptor extends Interceptor {
  final Dio _dio;
  final int maxRetries;
  final Duration initialDelay;

  RetryInterceptor(
    this._dio, {
    this.maxRetries = 3,
    this.initialDelay = const Duration(seconds: 1),
  });

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Only retry on specific error types
    if (!_shouldRetry(err)) {
      return handler.next(err);
    }

    // Get retry count from extra data
    final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;

    if (retryCount >= maxRetries) {
      AppLogger.warning(
        'Max retries ($maxRetries) reached',
        tag: 'Network',
      );
      return handler.next(err);
    }

    // Calculate delay with exponential backoff
    final delay = initialDelay * (1 << retryCount); // 2^retryCount

    AppLogger.info(
      'Retrying request (attempt ${retryCount + 1}/$maxRetries) after ${delay.inSeconds}s',
      tag: 'Network',
    );

    // Wait before retrying
    await Future.delayed(delay);

    // Retry the request
    final options = err.requestOptions;
    options.extra['retryCount'] = retryCount + 1;

    try {
      final response = await _dio.fetch(options);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  /// Determine if request should be retried
  bool _shouldRetry(DioException err) {
    // Retry on network errors
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      return true;
    }

    // Retry on 5xx server errors
    final statusCode = err.response?.statusCode;
    if (statusCode != null && statusCode >= 500 && statusCode < 600) {
      return true;
    }

    // Don't retry on client errors (4xx)
    return false;
  }
}
