import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/utils/logger.dart';
import '../../shared/config/app_config.dart';

/// Backend API 클라이언트
///
/// GCP Cloud Run에 배포된 Node.js 백엔드 서버와 통신
class ApiClient {
  late final Dio _dio;
  final AppConfig _config = AppConfig();

  // 토큰 갱신 중 플래그
  bool _isRefreshing = false;

  // 토큰 갱신 대기 중인 요청들
  final List<Function> _refreshQueue = [];

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: _config.fullApiUrl,
      connectTimeout: _config.connectTimeout,
      receiveTimeout: _config.receiveTimeout,
      sendTimeout: _config.sendTimeout,
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

    // 재시도 인터셉터 추가
    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        logPrint: (message) => Logger.debug(message, tag: 'RetryInterceptor'),
        retries: _config.maxRetries,
        retryDelays: List.generate(
          _config.maxRetries,
          (index) => _config.retryDelay * (index + 1),
        ),
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

      Logger.debug('API Request: ${options.method} ${options.path}',
          tag: 'ApiClient');
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
  Future<void> _onError(
      DioException error, ErrorInterceptorHandler handler) async {
    Logger.error(
      'API Error: ${error.response?.statusCode} ${error.requestOptions.path}',
      tag: 'ApiClient',
      error: error,
    );

    // 401 Unauthorized - 토큰 만료 or 무효
    if (error.response?.statusCode == 401) {
      Logger.warning('Unauthorized - attempting token refresh',
          tag: 'ApiClient');

      try {
        // 토큰 갱신 중이 아니면 갱신 시작
        if (!_isRefreshing) {
          _isRefreshing = true;

          // Firebase ID 토큰 강제 갱신
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            await user.getIdToken(true); // forceRefresh = true
            Logger.info('Token refreshed successfully', tag: 'ApiClient');

            // 대기 중인 요청들 재시도
            for (final callback in _refreshQueue) {
              callback();
            }
            _refreshQueue.clear();

            // 원래 요청 재시도
            _isRefreshing = false;
            final options = error.requestOptions;
            final newToken = await user.getIdToken();
            options.headers['Authorization'] = 'Bearer $newToken';

            final response = await _dio.fetch(options);
            return handler.resolve(response);
          } else {
            Logger.error('No user logged in - cannot refresh token',
                tag: 'ApiClient');
            _isRefreshing = false;
            return handler.reject(error);
          }
        } else {
          // 이미 토큰 갱신 중이면 대기열에 추가
          await Future.delayed(const Duration(milliseconds: 100));
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            final options = error.requestOptions;
            final newToken = await user.getIdToken();
            options.headers['Authorization'] = 'Bearer $newToken';

            final response = await _dio.fetch(options);
            return handler.resolve(response);
          }
        }
      } catch (e) {
        Logger.error('Token refresh failed', tag: 'ApiClient', error: e);
        _isRefreshing = false;
        _refreshQueue.clear();
      }
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
      Logger.error('Failed to register FCM token',
          tag: 'ApiClient', error: error);
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
      Logger.error('Failed to delete FCM token',
          tag: 'ApiClient', error: error);
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
      Logger.error('Failed to subscribe to topic',
          tag: 'ApiClient', error: error);
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
      Logger.error('Failed to unsubscribe from topic',
          tag: 'ApiClient', error: error);
      rethrow;
    }
  }

  // ==================== Auth API ====================

  /// 이메일/비밀번호 로그인
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      Logger.info('Login successful', tag: 'ApiClient');
      return response.data as Map<String, dynamic>;
    } catch (error) {
      Logger.error('Login failed', tag: 'ApiClient', error: error);
      rethrow;
    }
  }

  /// 회원가입
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String displayName,
    String? photoUrl,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'email': email,
        'password': password,
        'displayName': displayName,
        'photoUrl': photoUrl,
      });

      Logger.info('Registration successful', tag: 'ApiClient');
      return response.data as Map<String, dynamic>;
    } catch (error) {
      Logger.error('Registration failed', tag: 'ApiClient', error: error);
      rethrow;
    }
  }

  /// 토큰 갱신
  Future<String> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post('/auth/refresh', data: {
        'refreshToken': refreshToken,
      });

      final newToken = response.data['accessToken'] as String;
      Logger.info('Token refresh successful', tag: 'ApiClient');
      return newToken;
    } catch (error) {
      Logger.error('Token refresh failed', tag: 'ApiClient', error: error);
      rethrow;
    }
  }

  /// 비밀번호 재설정 요청
  Future<void> requestPasswordReset(String email) async {
    try {
      await _dio.post('/auth/reset-password', data: {
        'email': email,
      });

      Logger.info('Password reset email sent', tag: 'ApiClient');
    } catch (error) {
      Logger.error('Password reset request failed',
          tag: 'ApiClient', error: error);
      rethrow;
    }
  }

  /// 이메일 인증
  Future<void> verifyEmail(String token) async {
    try {
      await _dio.post('/auth/verify-email', data: {
        'token': token,
      });

      Logger.info('Email verified successfully', tag: 'ApiClient');
    } catch (error) {
      Logger.error('Email verification failed', tag: 'ApiClient', error: error);
      rethrow;
    }
  }

  // ==================== User API ====================

  /// 사용자 프로필 조회
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final response = await _dio.get('/users/$userId');
      return response.data as Map<String, dynamic>;
    } catch (error) {
      Logger.error('Failed to get user profile',
          tag: 'ApiClient', error: error);
      rethrow;
    }
  }

  /// 사용자 프로필 업데이트
  Future<Map<String, dynamic>> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.put('/users/$userId', data: data);
      Logger.info('User profile updated', tag: 'ApiClient');
      return response.data as Map<String, dynamic>;
    } catch (error) {
      Logger.error('Failed to update user profile',
          tag: 'ApiClient', error: error);
      rethrow;
    }
  }

  // ==================== Payment API ====================

  /// iOS 영수증 검증
  Future<bool> verifyIosReceipt(String receiptData) async {
    try {
      final response = await _dio.post('/payment/verify/ios', data: {
        'receiptData': receiptData,
      });

      final isValid = response.data['valid'] as bool;
      Logger.info('iOS receipt verification: $isValid', tag: 'ApiClient');
      return isValid;
    } catch (error) {
      Logger.error('iOS receipt verification failed',
          tag: 'ApiClient', error: error);
      rethrow;
    }
  }

  /// Android 영수증 검증
  Future<bool> verifyAndroidReceipt({
    required String packageName,
    required String productId,
    required String purchaseToken,
  }) async {
    try {
      final response = await _dio.post('/payment/verify/android', data: {
        'packageName': packageName,
        'productId': productId,
        'purchaseToken': purchaseToken,
      });

      final isValid = response.data['valid'] as bool;
      Logger.info('Android receipt verification: $isValid', tag: 'ApiClient');
      return isValid;
    } catch (error) {
      Logger.error('Android receipt verification failed',
          tag: 'ApiClient', error: error);
      rethrow;
    }
  }

  /// 구독 상태 조회
  Future<Map<String, dynamic>> getSubscriptionStatus(String userId) async {
    try {
      final response = await _dio.get('/payment/subscription/$userId');
      return response.data as Map<String, dynamic>;
    } catch (error) {
      Logger.error('Failed to get subscription status',
          tag: 'ApiClient', error: error);
      rethrow;
    }
  }

  /// 구독 취소
  Future<void> cancelSubscription(String userId) async {
    try {
      await _dio.post('/payment/subscription/$userId/cancel');
      Logger.info('Subscription cancelled', tag: 'ApiClient');
    } catch (error) {
      Logger.error('Failed to cancel subscription',
          tag: 'ApiClient', error: error);
      rethrow;
    }
  }
}

/// Retry 인터셉터
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int retries;
  final List<Duration> retryDelays;
  final void Function(String)? logPrint;

  RetryInterceptor({
    required this.dio,
    required this.retries,
    required this.retryDelays,
    this.logPrint,
  });

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    final extra = err.requestOptions.extra;
    final retryCount = extra['retryCount'] ?? 0;

    // 재시도 가능한 에러인지 확인
    if (_shouldRetry(err) && retryCount < retries) {
      logPrint?.call('Retrying request (${retryCount + 1}/$retries)');

      // 재시도 지연
      await Future.delayed(retryDelays[retryCount]);

      // 재시도 카운트 증가
      err.requestOptions.extra['retryCount'] = retryCount + 1;

      try {
        // 요청 재시도
        final response = await dio.fetch(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        // 재시도 실패 시 다음 재시도로 넘어감
        return super.onError(err, handler);
      }
    }

    // 재시도 불가능하거나 최대 재시도 횟수 초과
    return super.onError(err, handler);
  }

  /// 재시도 가능한 에러인지 확인
  bool _shouldRetry(DioException err) {
    // 네트워크 에러
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      return true;
    }

    // 5xx 서버 에러
    if (err.response?.statusCode != null) {
      final statusCode = err.response!.statusCode!;
      return statusCode >= 500 && statusCode < 600;
    }

    return false;
  }
}

/// ApiClient Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});
