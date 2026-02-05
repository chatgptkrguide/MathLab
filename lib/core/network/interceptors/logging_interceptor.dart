// 📝 Logging Interceptor
//
// Logs all HTTP requests and responses for debugging purposes.
// Only active in development mode.

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../utils/app_logger.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      AppLogger.logNetworkRequest(
        method: options.method,
        url: options.uri.toString(),
        headers: options.headers,
        body: options.data,
      );
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      AppLogger.logNetworkResponse(
        method: response.requestOptions.method,
        url: response.requestOptions.uri.toString(),
        statusCode: response.statusCode ?? 0,
        body: response.data,
      );
    }

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      AppLogger.error(
        'Network Error',
        tag: 'Network',
        error: err,
        data: {
          'method': err.requestOptions.method,
          'url': err.requestOptions.uri.toString(),
          'statusCode': err.response?.statusCode,
          'message': err.message,
        },
      );
    }

    super.onError(err, handler);
  }
}
