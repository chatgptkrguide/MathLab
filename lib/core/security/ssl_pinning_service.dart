// SSL Certificate Pinning Service
//
// Provides SSL certificate pinning to prevent Man-in-the-Middle (MITM) attacks
// by validating server certificates against known SHA256 fingerprints.
//
// Configuration:
// SSL pins are loaded from the SSL_PINS environment variable (comma-separated).
// When SSL_PINS is empty or unset, pinning is disabled (development mode).
//
// Production setup:
// 1. Get your server's SHA256 fingerprint:
//    openssl s_client -connect api.mathlab.app:443 < /dev/null 2>/dev/null | \
//      openssl x509 -fingerprint -sha256 -noout -in /dev/stdin
// 2. Set SSL_PINS in your .env file:
//    SSL_PINS=AA:BB:CC:...:ZZ,11:22:33:...:99
//    (multiple pins separated by commas for certificate rotation)
//
// Usage:
// ```dart
// if (SSLPinningService.isEnabled) {
//   await SSLPinningService.checkCertificate(
//     serverURL: 'https://api.mathlab.app',
//   );
// }
// ```

import 'dart:io';
import 'package:http_certificate_pinning/http_certificate_pinning.dart';
import 'package:flutter/foundation.dart';
import '../../core/config/env_config.dart';

class SSLPinningService {
  // Singleton pattern
  static final SSLPinningService _instance = SSLPinningService._internal();

  factory SSLPinningService() => _instance;

  SSLPinningService._internal();

  // ========================================
  // Certificate Fingerprints Configuration
  // ========================================

  /// SSL pin list - loaded from environment variables
  /// Returns empty list when SSL_PINS is not configured (disables pinning)
  static List<String> get pinnedCertificates {
    final pins = EnvConfig.sslPins;
    if (pins.isEmpty && kDebugMode) {
      debugPrint('SSL Pinning: No pins configured - pinning disabled');
    }
    return pins;
  }

  /// Whether SSL pinning is active
  static bool get isEnabled => pinnedCertificates.isNotEmpty;

  // ========================================
  // SSL Pinning Check Methods
  // ========================================

  /// Check SSL certificate for a given server URL
  ///
  /// Throws [SSLPinningException] if certificate validation fails
  static Future<bool> checkCertificate({
    required String serverURL,
    List<String>? customFingerprints,
    int timeout = 60,
    SHA sha = SHA.SHA256,
  }) async {
    // SSL pinning is not supported on web platform
    if (kIsWeb) {
      if (kDebugMode) {
        debugPrint('SSL Pinning: Skipped on web platform for $serverURL');
      }
      return true;
    }

    // Skip SSL pinning in debug mode for easier development
    if (kDebugMode) {
      debugPrint('SSL Pinning: Skipped in debug mode for $serverURL');
      return true;
    }

    // Skip if no pins are configured
    if (!isEnabled && customFingerprints == null) {
      return true;
    }

    try {
      final fingerprints = customFingerprints ?? pinnedCertificates;

      if (fingerprints.isEmpty) {
        throw SSLPinningException(
          'No SSL fingerprints configured for $serverURL. '
          'Set SSL_PINS environment variable with your server fingerprints.',
        );
      }

      // Perform certificate pinning check
      await HttpCertificatePinning.check(
        serverURL: serverURL,
        headerHttp: {},
        sha: sha,
        allowedSHAFingerprints: fingerprints,
        timeout: timeout,
      );

      if (kDebugMode) {
        debugPrint('SSL Pinning: Certificate validated for $serverURL');
      }
      return true;
    } on Exception catch (e) {
      throw SSLPinningException(
        'SSL Certificate validation failed for $serverURL: $e',
      );
    }
  }

  /// Check multiple servers at once
  static Future<Map<String, bool>> checkMultipleServers({
    required List<String> serverURLs,
    int timeout = 60,
  }) async {
    final results = <String, bool>{};

    for (final url in serverURLs) {
      try {
        results[url] = await checkCertificate(
          serverURL: url,
          timeout: timeout,
        );
      } catch (e) {
        results[url] = false;
        if (kDebugMode) {
          debugPrint('SSL Pinning failed for $url: $e');
        }
      }
    }

    return results;
  }

  // ========================================
  // Dio Interceptor Support
  // ========================================

  /// Get custom HttpClient with SSL pinning for Dio
  /// Returns null on web platform (HttpClient not available)
  static HttpClient? getSecureHttpClient() {
    // HttpClient is not available on web
    if (kIsWeb) {
      if (kDebugMode) {
        debugPrint('SSL Pinning: HttpClient not available on web');
      }
      return null;
    }

    final httpClient = HttpClient();

    // Skip in debug mode
    if (kDebugMode) {
      return httpClient;
    }

    // Skip if no pins configured
    if (!isEnabled) {
      return httpClient;
    }

    httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) {
      final fingerprints = pinnedCertificates;

      if (fingerprints.isEmpty) {
        if (kDebugMode) {
          debugPrint('No fingerprints configured for $host - rejecting certificate');
        }
        return false;
      }

      // Get certificate SHA256 fingerprint from DER encoding
      final certBytes = cert.der;
      final certSHA256 = certBytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();

      // Check if certificate matches any allowed fingerprint
      final isValid = fingerprints.contains(certSHA256);

      if (!isValid) {
        if (kDebugMode) {
          debugPrint('Certificate mismatch for $host');
          debugPrint('   Expected one of: $fingerprints');
          debugPrint('   Received: $certSHA256');
        }
      }

      return isValid;
    };

    return httpClient;
  }

  /// Test SSL connection without throwing exceptions
  static Future<SSLCheckResult> testConnection({
    required String serverURL,
    int timeout = 10,
  }) async {
    try {
      final success = await checkCertificate(
        serverURL: serverURL,
        timeout: timeout,
      );

      return SSLCheckResult(
        url: serverURL,
        isValid: success,
        message: 'Certificate validated successfully',
      );
    } on SSLPinningException catch (e) {
      return SSLCheckResult(
        url: serverURL,
        isValid: false,
        message: e.message,
      );
    } catch (e) {
      return SSLCheckResult(
        url: serverURL,
        isValid: false,
        message: 'Unexpected error: $e',
      );
    }
  }
}

// ========================================
// Data Classes
// ========================================

/// Result of SSL certificate check
class SSLCheckResult {
  final String url;
  final bool isValid;
  final String message;

  SSLCheckResult({
    required this.url,
    required this.isValid,
    required this.message,
  });

  @override
  String toString() => 'SSLCheckResult(url: $url, valid: $isValid, message: $message)';
}

// ========================================
// Custom Exception
// ========================================

class SSLPinningException implements Exception {
  final String message;

  SSLPinningException(this.message);

  @override
  String toString() => 'SSLPinningException: $message';
}
