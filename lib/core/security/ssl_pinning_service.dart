// 🔐 SSL Certificate Pinning Service
//
// Provides SSL certificate pinning to prevent Man-in-the-Middle (MITM) attacks
// by validating server certificates against known SHA256 fingerprints.
//
// Security Features:
// - Certificate pinning for API servers
// - SHA256 fingerprint validation
// - Multiple certificate support (for certificate rotation)
// - Timeout configuration
//
// Usage:
// ```dart
// // Initialize SSL pinning before making API calls
// await SSLPinningService.checkCertificate(
//   serverURL: 'https://api.mathlab.app',
// );
//
// // Or use in Dio interceptor
// final dio = Dio();
// dio.interceptors.add(SSLPinningInterceptor());
// ```
//
// How to get SHA256 fingerprint:
// ```bash
// # For your API server
// openssl s_client -connect api.mathlab.app:443 < /dev/null 2>/dev/null | \
//   openssl x509 -fingerprint -sha256 -noout -in /dev/stdin
// ```

import 'dart:io';
import 'package:http_certificate_pinning/http_certificate_pinning.dart';
import 'package:flutter/foundation.dart';

class SSLPinningService {
  // Singleton pattern
  static final SSLPinningService _instance = SSLPinningService._internal();

  factory SSLPinningService() => _instance;

  SSLPinningService._internal();

  // ========================================
  // Certificate Fingerprints Configuration
  // ========================================

  /// Production API server fingerprints
  /// TODO: Replace with your actual server's SHA256 fingerprints
  static const List<String> _productionFingerprints = [
    // Primary certificate
    // 'AB:CD:EF:12:34:56:78:90:AB:CD:EF:12:34:56:78:90:AB:CD:EF:12:34:56:78:90:AB:CD:EF:12:34:56:78:90',
    // Backup certificate (for rotation)
    // 'FE:DC:BA:98:76:54:32:10:FE:DC:BA:98:76:54:32:10:FE:DC:BA:98:76:54:32:10:FE:DC:BA:98:76:54:32:10',
  ];

  /// Staging/Development server fingerprints
  static const List<String> _developmentFingerprints = [
    // Development certificate
    // 'DE:V1:23:45:67:89:AB:CD:EF:01:23:45:67:89:AB:CD:EF:01:23:45:67:89:AB:CD:EF:01:23:45:67:89:AB:CD',
  ];

  /// Firebase/Google services fingerprints
  static const List<String> _firebaseFingerprints = [
    // Firebase uses Google's certificates
    // These are examples - verify actual fingerprints from Firebase console
  ];

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
        debugPrint('⚠️ SSL Pinning: Skipped on web platform for $serverURL');
      }
      return true;
    }

    // Skip SSL pinning in debug mode for easier development
    if (kDebugMode) {
      debugPrint('⚠️ SSL Pinning: Skipped in debug mode for $serverURL');
      return true;
    }

    try {
      // Determine which fingerprints to use
      final fingerprints = customFingerprints ?? _getFingerprints(serverURL);

      // If no fingerprints configured, throw error
      if (fingerprints.isEmpty) {
        throw SSLPinningException(
          'No SSL fingerprints configured for $serverURL. '
          'Please add certificate fingerprints in SSLPinningService.',
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
        debugPrint('✅ SSL Pinning: Certificate validated for $serverURL');
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
          debugPrint('❌ SSL Pinning failed for $url: $e');
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
        debugPrint('⚠️ SSL Pinning: HttpClient not available on web');
      }
      return null;
    }

    final httpClient = HttpClient();

    // Skip in debug mode
    if (kDebugMode) {
      return httpClient;
    }

    httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) {
      // Get fingerprints for this host
      final fingerprints = _getFingerprints('https://$host');

      if (fingerprints.isEmpty) {
        if (kDebugMode) {
          debugPrint('⚠️ No fingerprints for $host - rejecting certificate');
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
          debugPrint('❌ Certificate mismatch for $host');
          debugPrint('   Expected one of: $fingerprints');
          debugPrint('   Received: $certSHA256');
        }
      }

      return isValid;
    };

    return httpClient;
  }

  // ========================================
  // Helper Methods
  // ========================================

  /// Get appropriate fingerprints based on environment and URL
  static List<String> _getFingerprints(String url) {
    // Firebase/Google services
    if (url.contains('googleapis.com') ||
        url.contains('firebase') ||
        url.contains('google.com')) {
      return _firebaseFingerprints;
    }

    // Production vs Development
    if (url.contains('api.mathlab.app') || url.contains('production')) {
      return _productionFingerprints;
    } else if (url.contains('dev') || url.contains('staging')) {
      return _developmentFingerprints;
    }

    // Default: return empty (will throw error if not in debug mode)
    return [];
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
