// 📝 Logging Interceptor
//
// Logs all HTTP requests and responses for debugging

import 'package:dio/dio.dart';
import '../../../../core/utils/app_logger.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.debug(
      'REQUEST[${options.method}] => PATH: ${options.path}\n'
      'Headers: ${options.headers}\n'
      'Query Parameters: ${options.queryParameters}\n'
      'Data: ${options.data}',
      tag: 'HTTP',
    );

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.info(
      'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}\n'
      'Data: ${response.data}',
      tag: 'HTTP',
    );

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.error(
      'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}\n'
      'Message: ${err.message}\n'
      'Error: ${err.error}\n'
      'Response: ${err.response?.data}',
      tag: 'HTTP',
    );

    handler.next(err);
  }
}
