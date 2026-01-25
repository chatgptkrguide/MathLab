/// ⚠️ Error Interceptor
///
/// Handles and transforms API errors into user-friendly messages

import 'package:dio/dio.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String errorMessage;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = '서버 연결 시간이 초과되었습니다. 다시 시도해주세요.';
        break;

      case DioExceptionType.badResponse:
        errorMessage = _handleStatusCodeError(err.response?.statusCode);
        break;

      case DioExceptionType.cancel:
        errorMessage = '요청이 취소되었습니다.';
        break;

      case DioExceptionType.connectionError:
        errorMessage = '인터넷 연결을 확인해주세요.';
        break;

      case DioExceptionType.badCertificate:
        errorMessage = '보안 인증서 오류가 발생했습니다.';
        break;

      case DioExceptionType.unknown:
      default:
        errorMessage = '알 수 없는 오류가 발생했습니다.';
        break;
    }

    // Attach user-friendly message to the error
    err = err.copyWith(
      error: errorMessage,
    );

    handler.next(err);
  }

  String _handleStatusCodeError(int? statusCode) {
    switch (statusCode) {
      case 400:
        return '잘못된 요청입니다.';
      case 401:
        return '인증이 필요합니다. 다시 로그인해주세요.';
      case 403:
        return '접근 권한이 없습니다.';
      case 404:
        return '요청한 정보를 찾을 수 없습니다.';
      case 500:
        return '서버 오류가 발생했습니다.';
      case 503:
        return '서버가 일시적으로 사용할 수 없습니다.';
      default:
        return '서버 오류가 발생했습니다. (코드: $statusCode)';
    }
  }
}
