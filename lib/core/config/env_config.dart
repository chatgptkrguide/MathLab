// 🔐 Secure Environment Configuration
//
// This file provides type-safe access to environment variables
// with validation and fallback mechanisms.
//
// Usage:
// ```dart
// final apiUrl = EnvConfig.apiBaseUrl;
// final kakaoKey = EnvConfig.kakaoNativeAppKey;
// ```

import 'dart:developer' as developer;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  // Private constructor to prevent instantiation
  EnvConfig._();

  static bool _isInitialized = false;

  /// Initialize environment configuration
  /// Must be called before app starts
  static Future<void> initialize({String fileName = '.env'}) async {
    try {
      await dotenv.load(fileName: fileName);
      _isInitialized = true;
    } catch (e) {
      // .env file not found or empty - use defaults
      _isInitialized = false;
    }
  }

  // ========================================
  // API Configuration
  // ========================================

  /// API Base URL
  static String get apiBaseUrl {
    final url = _getEnvVar('API_BASE_URL', defaultValue: 'https://asia-northeast3-mathlab-gomath.cloudfunctions.net');
    // Enforce HTTPS in production
    if (isProduction && url.startsWith('http://')) {
      throw UnsupportedError('API_BASE_URL must use HTTPS in production');
    }
    return url;
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
    String? value;
    if (_isInitialized) {
      try {
        value = dotenv.env[key];
      } catch (_) {
        value = null;
      }
    }

    if (value == null || value.isEmpty) {
      if (required && _isInitialized) {
        throw Exception(
          'Required environment variable "$key" is not set. '
          'Please check your .env file.',
        );
      }
      if (defaultValue != null) {
        return defaultValue;
      }
      if (required) {
        throw Exception(
          'Environment variable "$key" is not set and .env file is not loaded.',
        );
      }
      return '';
    }

    return value;
  }

  /// Get boolean environment variable
  static bool _getBoolEnvVar(String key, {required bool defaultValue}) {
    if (!_isInitialized) return defaultValue;
    try {
      final value = dotenv.env[key];
      if (value == null || value.isEmpty) {
        return defaultValue;
      }
      return value.toLowerCase() == 'true' || value == '1';
    } catch (_) {
      return defaultValue;
    }
  }

  /// Validate all required environment variables
  static void validateEnvironment() {
    if (!_isInitialized) {
      // .env not loaded - skip validation (use defaults)
      return;
    }

    final requiredVars = [
      'API_BASE_URL',
      'GOOGLE_WEB_CLIENT_ID',
      'APP_ENV',
    ];

    final missingVars = <String>[];

    for (final varName in requiredVars) {
      try {
        final value = dotenv.env[varName];
        if (value == null || value.isEmpty) {
          missingVars.add(varName);
        }
      } catch (_) {
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
  /// Only use in development - never in production
  static void printConfig() {
    if (isProduction) {
      throw UnsupportedError('Cannot print config in production environment');
    }

    developer.log('=== Environment Configuration ===');
    developer.log('Initialized: $_isInitialized');
    developer.log('Environment: $appEnv');
    developer.log('API Base URL: $apiBaseUrl');
    developer.log('Logging Enabled: $enableLogging');
    developer.log('================================');
  }
}
