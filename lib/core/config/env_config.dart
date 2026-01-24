/// 🔐 Secure Environment Configuration
///
/// This file provides type-safe access to environment variables
/// with validation and fallback mechanisms.
///
/// Usage:
/// ```dart
/// final apiUrl = EnvConfig.apiBaseUrl;
/// final kakaoKey = EnvConfig.kakaoNativeAppKey;
/// ```

import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  // Private constructor to prevent instantiation
  EnvConfig._();

  /// Initialize environment configuration
  /// Must be called before app starts
  static Future<void> initialize({String fileName = '.env'}) async {
    try {
      await dotenv.load(fileName: fileName);
    } catch (e) {
      throw Exception('Failed to load environment file: $fileName. Error: $e');
    }
  }

  // ========================================
  // API Configuration
  // ========================================

  /// API Base URL
  static String get apiBaseUrl {
    return _getEnvVar('API_BASE_URL', defaultValue: 'http://localhost:8080/api/v1');
  }

  /// Check if running in production
  static bool get isProduction {
    return appEnv == 'production';
  }

  /// Check if running in development
  static bool get isDevelopment {
    return appEnv == 'development';
  }

  // ========================================
  // Social Login Configuration
  // ========================================

  /// Kakao Native App Key
  /// ⚠️  Never hardcode this value
  static String get kakaoNativeAppKey {
    return _getEnvVar('KAKAO_NATIVE_APP_KEY', required: true);
  }

  /// Google Web Client ID
  /// ⚠️  Never hardcode this value
  static String get googleWebClientId {
    return _getEnvVar('GOOGLE_WEB_CLIENT_ID', required: true);
  }

  // ========================================
  // Firebase Configuration
  // ========================================

  /// FCM Web Push Key
  /// ⚠️  Never hardcode this value
  static String get fcmWebPushKey {
    return _getEnvVar('FCM_WEB_PUSH_KEY', required: true);
  }

  /// FCM Sender ID
  /// ⚠️  Never hardcode this value
  static String get fcmSenderId {
    return _getEnvVar('FCM_SENDER_ID', required: true);
  }

  // ========================================
  // App Configuration
  // ========================================

  /// App environment: development | staging | production
  static String get appEnv {
    return _getEnvVar('APP_ENV', defaultValue: 'development');
  }

  /// Enable logging
  static bool get enableLogging {
    return _getBoolEnvVar('ENABLE_LOGGING', defaultValue: true);
  }

  // ========================================
  // OpenAI Configuration
  // ========================================

  /// OpenAI API Key
  /// ⚠️  ONLY for development/testing - DO NOT use in production
  /// Production should use backend API with server-side key management
  static String? get openAiApiKey {
    if (isProduction) {
      // Never use client-side OpenAI key in production
      throw UnsupportedError(
        'OpenAI API key should not be accessed from client in production. '
        'Use backend API instead.',
      );
    }
    return _getEnvVar('OPENAI_API_KEY', required: false);
  }

  // ========================================
  // Helper Methods
  // ========================================

  /// Get environment variable with validation
  static String _getEnvVar(
    String key, {
    bool required = false,
    String? defaultValue,
  }) {
    final value = dotenv.env[key];

    if (value == null || value.isEmpty) {
      if (required) {
        throw Exception(
          'Required environment variable "$key" is not set. '
          'Please check your .env file.',
        );
      }
      if (defaultValue != null) {
        return defaultValue;
      }
      throw Exception(
        'Environment variable "$key" is not set and no default value provided.',
      );
    }

    return value;
  }

  /// Get boolean environment variable
  static bool _getBoolEnvVar(String key, {required bool defaultValue}) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      return defaultValue;
    }
    return value.toLowerCase() == 'true' || value == '1';
  }

  /// Validate all required environment variables
  static void validateEnvironment() {
    final requiredVars = [
      'API_BASE_URL',
      'KAKAO_NATIVE_APP_KEY',
      'GOOGLE_WEB_CLIENT_ID',
      'FCM_WEB_PUSH_KEY',
      'FCM_SENDER_ID',
      'APP_ENV',
    ];

    final missingVars = <String>[];

    for (final varName in requiredVars) {
      final value = dotenv.env[varName];
      if (value == null || value.isEmpty) {
        missingVars.add(varName);
      }
    }

    if (missingVars.isNotEmpty) {
      throw Exception(
        'Missing required environment variables:\n'
        '${missingVars.map((v) => '  - $v').join('\n')}\n\n'
        'Please check your .env file and ensure all required variables are set.',
      );
    }
  }

  /// Print environment configuration (for debugging)
  /// ⚠️  Only use in development - never in production
  static void printConfig() {
    if (isProduction) {
      throw UnsupportedError('Cannot print config in production environment');
    }

    print('=== Environment Configuration ===');
    print('Environment: $appEnv');
    print('API Base URL: $apiBaseUrl');
    print('Logging Enabled: $enableLogging');
    print('Kakao Key: ${_maskSecret(kakaoNativeAppKey)}');
    print('Google Client ID: ${_maskSecret(googleWebClientId)}');
    print('FCM Sender ID: ${_maskSecret(fcmSenderId)}');
    print('================================');
  }

  /// Mask secret values for safe logging
  static String _maskSecret(String secret) {
    if (secret.length <= 8) {
      return '***';
    }
    return '${secret.substring(0, 4)}...${secret.substring(secret.length - 4)}';
  }
}
