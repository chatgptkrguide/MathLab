/// 🔐 Authentication API
///
/// Handles all authentication-related API calls

import 'package:dio/dio.dart';
import '../dio_client.dart';

class AuthAPI {
  final DioClient _client;

  AuthAPI({required DioClient client}) : _client = client;

  /// Sign up with email and password
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await _client.post(
      '/auth/signup',
      data: {
        'email': email,
        'password': password,
        'name': name,
      },
    );

    return response.data as Map<String, dynamic>;
  }

  /// Sign in with email and password
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      '/auth/signin',
      data: {
        'email': email,
        'password': password,
      },
    );

    return response.data as Map<String, dynamic>;
  }

  /// Sign in with Google
  Future<Map<String, dynamic>> signInWithGoogle({
    required String idToken,
  }) async {
    final response = await _client.post(
      '/auth/google',
      data: {
        'idToken': idToken,
      },
    );

    return response.data as Map<String, dynamic>;
  }

  /// Sign in with Kakao
  Future<Map<String, dynamic>> signInWithKakao({
    required String accessToken,
  }) async {
    final response = await _client.post(
      '/auth/kakao',
      data: {
        'accessToken': accessToken,
      },
    );

    return response.data as Map<String, dynamic>;
  }

  /// Sign out
  Future<void> signOut() async {
    await _client.post('/auth/signout');
  }

  /// Refresh access token
  Future<Map<String, dynamic>> refreshToken({
    required String refreshToken,
  }) async {
    final response = await _client.post(
      '/auth/refresh',
      data: {
        'refreshToken': refreshToken,
      },
    );

    return response.data as Map<String, dynamic>;
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail({
    required String email,
  }) async {
    await _client.post(
      '/auth/reset-password',
      data: {
        'email': email,
      },
    );
  }

  /// Verify email
  Future<void> verifyEmail({
    required String token,
  }) async {
    await _client.post(
      '/auth/verify-email',
      data: {
        'token': token,
      },
    );
  }

  /// Check if email exists
  Future<bool> checkEmailExists({
    required String email,
  }) async {
    final response = await _client.get(
      '/auth/check-email',
      queryParameters: {
        'email': email,
      },
    );

    return response.data['exists'] as bool;
  }
}
