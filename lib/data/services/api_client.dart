import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/utils/logger.dart';

/// Backend API 클라이언트
///
/// GCP Cloud Run에 배포된 Node.js 백엔드 서버와 통신
class ApiClient {
  late final Dio _dio;

  // TODO: 프로덕션 배포 후 실제 URL로 변경
  static const String _baseUrl = 'http://localhost:3000';
  static const String _apiVersion = 'v1';

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: '$_baseUrl/api/$_apiVersion',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
  }

  /// 요청 인터셉터 - Firebase ID 토큰 자동 추가
  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Firebase Auth에서 ID 토큰 가져오기
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final token = await user.getIdToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
      }

      Logger.debug('API Request: ${options.method} ${options.path}', tag: 'ApiClient');
    } catch (error) {
      Logger.error('Error adding auth token', tag: 'ApiClient', error: error);
    }

    handler.next(options);
  }

  /// 응답 인터셉터
  void _onResponse(Response response, ResponseInterceptorHandler handler) {
    Logger.debug(
      'API Response: ${response.statusCode} ${response.requestOptions.path}',
      tag: 'ApiClient',
    );
    handler.next(response);
  }

  /// 에러 인터셉터
  void _onError(DioException error, ErrorInterceptorHandler handler) {
    Logger.error(
      'API Error: ${error.response?.statusCode} ${error.requestOptions.path}',
      tag: 'ApiClient',
      error: error,
    );

    // 401 Unauthorized - 토큰 만료 or 무효
    if (error.response?.statusCode == 401) {
      // TODO: 토큰 갱신 로직 추가
      Logger.warning('Unauthorized - token expired or invalid', tag: 'ApiClient');
    }

    handler.next(error);
  }

  /// FCM 토큰 등록/갱신
  Future<void> registerFcmToken({
    required String token,
    required String deviceType,
    String? deviceId,
  }) async {
    try {
      await _dio.post('/fcm/token', data: {
        'token': token,
        'deviceType': deviceType,
        'deviceId': deviceId,
      });
      Logger.info('FCM token registered successfully', tag: 'ApiClient');
    } catch (error) {
      Logger.error('Failed to register FCM token', tag: 'ApiClient', error: error);
      rethrow;
    }
  }

  /// FCM 토큰 삭제
  Future<void> deleteFcmToken(String userId, {String? deviceId}) async {
    try {
      await _dio.delete(
        '/fcm/token/$userId',
        queryParameters: deviceId != null ? {'deviceId': deviceId} : null,
      );
      Logger.info('FCM token deleted successfully', tag: 'ApiClient');
    } catch (error) {
      Logger.error('Failed to delete FCM token', tag: 'ApiClient', error: error);
      rethrow;
    }
  }

  /// FCM 토픽 구독
  Future<void> subscribeToTopic({
    required String token,
    required String topic,
  }) async {
    try {
      await _dio.post('/fcm/subscribe', data: {
        'token': token,
        'topic': topic,
      });
      Logger.info('Subscribed to topic: $topic', tag: 'ApiClient');
    } catch (error) {
      Logger.error('Failed to subscribe to topic', tag: 'ApiClient', error: error);
      rethrow;
    }
  }

  /// FCM 토픽 구독 해제
  Future<void> unsubscribeFromTopic({
    required String token,
    required String topic,
  }) async {
    try {
      await _dio.post('/fcm/unsubscribe', data: {
        'token': token,
        'topic': topic,
      });
      Logger.info('Unsubscribed from topic: $topic', tag: 'ApiClient');
    } catch (error) {
      Logger.error('Failed to unsubscribe from topic', tag: 'ApiClient', error: error);
      rethrow;
    }
  }

  // TODO: Auth API endpoints
  // Future<Map<String, dynamic>> login(String email, String password) async {}
  // Future<Map<String, dynamic>> register(...) async {}
  // Future<String> refreshToken(String refreshToken) async {}

  // TODO: Payment verification endpoints
  // Future<bool> verifyIosReceipt(String receiptData) async {}
  // Future<bool> verifyAndroidReceipt(String purchaseToken) async {}
}

/// ApiClient Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});
