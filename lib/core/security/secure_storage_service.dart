// 🔐 Secure Storage Service
//
// Provides encrypted storage for sensitive data like authentication tokens,
// user credentials, and other security-critical information.
//
// Uses flutter_secure_storage with AES encryption on device.
//
// Usage:
// ```dart
// final storage = SecureStorageService();
//
// // Store token
// await storage.saveAuthToken('jwt_token_here');
//
// // Retrieve token
// final token = await storage.getAuthToken();
//
// // Delete token
// await storage.deleteAuthToken();
// ```

import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  // Singleton pattern
  static final SecureStorageService _instance = SecureStorageService._internal();

  factory SecureStorageService() => _instance;

  SecureStorageService._internal();

  // Secure storage instance with encryption
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      resetOnError: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.unlocked_this_device,
      accountName: 'com.gomath.mathlab',
    ),
  );

  // Storage keys (using constants to avoid typos)
  static const String _keyAuthToken = 'auth_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keyLastLoginTime = 'last_login_time';

  // ========================================
  // Authentication Token Management
  // ========================================

  /// Save authentication token (JWT)
  Future<void> saveAuthToken(String token) async {
    try {
      await _storage.write(key: _keyAuthToken, value: token);
    } catch (e) {
      throw SecureStorageException('Failed to save auth token: $e');
    }
  }

  /// Get authentication token
  Future<String?> getAuthToken() async {
    try {
      return await _storage.read(key: _keyAuthToken);
    } catch (e) {
      throw SecureStorageException('Failed to retrieve auth token: $e');
    }
  }

  /// Delete authentication token
  Future<void> deleteAuthToken() async {
    try {
      await _storage.delete(key: _keyAuthToken);
    } catch (e) {
      throw SecureStorageException('Failed to delete auth token: $e');
    }
  }

  /// Check if auth token exists
  Future<bool> hasAuthToken() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  // ========================================
  // Refresh Token Management
  // ========================================

  /// Save refresh token
  Future<void> saveRefreshToken(String token) async {
    try {
      await _storage.write(key: _keyRefreshToken, value: token);
    } catch (e) {
      throw SecureStorageException('Failed to save refresh token: $e');
    }
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _keyRefreshToken);
    } catch (e) {
      throw SecureStorageException('Failed to retrieve refresh token: $e');
    }
  }

  /// Delete refresh token
  Future<void> deleteRefreshToken() async {
    try {
      await _storage.delete(key: _keyRefreshToken);
    } catch (e) {
      throw SecureStorageException('Failed to delete refresh token: $e');
    }
  }

  // ========================================
  // User Information
  // ========================================

  /// Save user ID
  Future<void> saveUserId(String userId) async {
    try {
      await _storage.write(key: _keyUserId, value: userId);
    } catch (e) {
      throw SecureStorageException('Failed to save user ID: $e');
    }
  }

  /// Get user ID
  Future<String?> getUserId() async {
    try {
      return await _storage.read(key: _keyUserId);
    } catch (e) {
      throw SecureStorageException('Failed to retrieve user ID: $e');
    }
  }

  /// Save user email
  Future<void> saveUserEmail(String email) async {
    try {
      await _storage.write(key: _keyUserEmail, value: email);
    } catch (e) {
      throw SecureStorageException('Failed to save user email: $e');
    }
  }

  /// Get user email
  Future<String?> getUserEmail() async {
    try {
      return await _storage.read(key: _keyUserEmail);
    } catch (e) {
      throw SecureStorageException('Failed to retrieve user email: $e');
    }
  }

  // ========================================
  // Session Management
  // ========================================

  /// Record last login time
  Future<void> recordLoginTime() async {
    final timestamp = DateTime.now().toIso8601String();
    await _storage.write(key: _keyLastLoginTime, value: timestamp);
  }

  /// Get last login time
  Future<DateTime?> getLastLoginTime() async {
    try {
      final timestamp = await _storage.read(key: _keyLastLoginTime);
      if (timestamp == null) return null;
      return DateTime.parse(timestamp);
    } catch (e) {
      return null;
    }
  }

  /// Check if session is expired (2 hours timeout)
  Future<bool> isSessionExpired({Duration timeout = const Duration(hours: 2)}) async {
    final lastLogin = await getLastLoginTime();
    if (lastLogin == null) return true;

    final now = DateTime.now();
    return now.difference(lastLogin) > timeout;
  }

  // ========================================
  // Biometric Settings
  // ========================================

  /// Enable/disable biometric authentication
  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(
      key: _keyBiometricEnabled,
      value: enabled.toString(),
    );
  }

  /// Check if biometric is enabled
  Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: _keyBiometricEnabled);
    return value == 'true';
  }

  // ========================================
  // Utility Methods
  // ========================================

  /// Clear all stored data (logout)
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw SecureStorageException('Failed to clear storage: $e');
    }
  }

  /// Save custom encrypted value
  Future<void> saveSecure(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      throw SecureStorageException('Failed to save value for key "$key": $e');
    }
  }

  /// Read custom encrypted value
  Future<String?> readSecure(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      throw SecureStorageException('Failed to read value for key "$key": $e');
    }
  }

  /// Delete custom encrypted value
  Future<void> deleteSecure(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      throw SecureStorageException('Failed to delete value for key "$key": $e');
    }
  }

  /// Get all stored keys (for debugging only)
  Future<Map<String, String>> getAllSecure() async {
    assert(!kReleaseMode, 'getAllSecure() must not be called in production');
    try {
      return await _storage.readAll();
    } catch (e) {
      throw SecureStorageException('Failed to read all values: $e');
    }
  }

  /// Check if storage is accessible
  Future<bool> isAccessible() async {
    try {
      await _storage.write(key: '_test_key', value: 'test');
      final value = await _storage.read(key: '_test_key');
      await _storage.delete(key: '_test_key');
      return value == 'test';
    } catch (e) {
      return false;
    }
  }
}

// ========================================
// Custom Exception
// ========================================

class SecureStorageException implements Exception {
  final String message;

  SecureStorageException(this.message);

  @override
  String toString() => 'SecureStorageException: $message';
}
