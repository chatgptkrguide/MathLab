// 🔐 Authentication Interceptor
//
// Automatically adds authentication headers to requests

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage storage;

  AuthInterceptor({required this.storage});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Get access token from secure storage
    final accessToken = await storage.read(key: 'access_token');

    if (accessToken != null) {
      // Add authorization header
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized
    if (err.response?.statusCode == 401) {
      // Try to refresh token
      final refreshToken = await storage.read(key: 'refresh_token');

      if (refreshToken != null) {
        try {
          // Attempt token refresh
          final newToken = await _refreshToken(refreshToken);

          if (newToken != null) {
            // Save new token
            await storage.write(key: 'access_token', value: newToken);

            // Retry the original request
            final response = await _retry(err.requestOptions, newToken);
            return handler.resolve(response);
          }
        } catch (e) {
          // Token refresh failed, proceed with error
          await _clearTokens();
        }
      }
    }

    handler.next(err);
  }

  Future<String?> _refreshToken(String refreshToken) async {
    try {
      // Create a new Dio instance without interceptors to avoid infinite loop
      final dio = Dio();

      final response = await dio.post(
        '/auth/refresh',
        data: {
          'refreshToken': refreshToken,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return data['accessToken'] as String?;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Response> _retry(RequestOptions requestOptions, String newToken) async {
    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $newToken',
      },
    );

    return Dio().request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  Future<void> _clearTokens() async {
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');
  }
}
