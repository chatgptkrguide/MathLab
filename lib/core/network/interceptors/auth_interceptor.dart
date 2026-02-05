// 🔐 Authentication Interceptor
//
// Automatically injects authentication tokens into requests
// and handles token refresh when expired.

import 'package:dio/dio.dart';
import '../../security/secure_storage_service.dart';
import '../../utils/app_logger.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService _storage;

  AuthInterceptor(this._storage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for public endpoints
    if (_isPublicEndpoint(options.path)) {
      return handler.next(options);
    }

    // Get auth token from secure storage
    final token = await _storage.getAuthToken();

    if (token != null) {
      // Add Bearer token to headers
      options.headers['Authorization'] = 'Bearer $token';
      AppLogger.debug('Auth token added to request', tag: 'Auth');
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 Unauthorized - try to refresh token
    if (err.response?.statusCode == 401) {
      AppLogger.warning('Received 401 Unauthorized', tag: 'Auth');

      // Try to refresh token
      final newToken = await _tryRefreshToken();

      if (newToken != null) {
        // Retry the original request with new token
        final options = err.requestOptions;
        options.headers['Authorization'] = 'Bearer $newToken';

        try {
          final response = await Dio().fetch(options);
          return handler.resolve(response);
        } catch (e) {
          return handler.next(err);
        }
      } else {
        // Refresh failed - user needs to login again
        await _handleLogout();
        return handler.next(err);
      }
    }

    return handler.next(err);
  }

  /// Check if endpoint is public (doesn't require auth)
  bool _isPublicEndpoint(String path) {
    const publicEndpoints = [
      '/auth/login',
      '/auth/register',
      '/auth/refresh',
      '/auth/forgot-password',
      '/public/',
    ];

    return publicEndpoints.any((endpoint) => path.contains(endpoint));
  }

  /// Try to refresh the authentication token
  Future<String?> _tryRefreshToken() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null) {
        AppLogger.warning('No refresh token available', tag: 'Auth');
        return null;
      }

      // TODO: Call your refresh token API endpoint
      // final response = await Dio().post('/auth/refresh', data: {
      //   'refreshToken': refreshToken,
      // });
      //
      // final newToken = response.data['accessToken'];
      // final newRefreshToken = response.data['refreshToken'];
      //
      // await _storage.saveAuthToken(newToken);
      // await _storage.saveRefreshToken(newRefreshToken);
      //
      // AppLogger.info('Token refreshed successfully', tag: 'Auth');
      // return newToken;

      return null; // Placeholder
    } catch (e) {
      AppLogger.error('Failed to refresh token', tag: 'Auth', error: e);
      return null;
    }
  }

  /// Handle logout when token refresh fails
  Future<void> _handleLogout() async {
    await _storage.clearAll();
    AppLogger.info('User logged out due to invalid token', tag: 'Auth');

    // TODO: Navigate to login screen
    // Get.offAllNamed('/login');
  }
}
