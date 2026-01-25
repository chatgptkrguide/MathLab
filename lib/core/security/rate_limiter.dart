/// 🚦 Rate Limiter Service
///
/// Provides rate limiting functionality to prevent brute force attacks,
/// API abuse, and excessive resource consumption.
///
/// Features:
/// - Sliding window rate limiting
/// - Customizable time windows and attempt limits
/// - IP-based and user-based limiting
/// - Automatic cleanup of old attempts
/// - Lock-out period after excessive attempts
///
/// Usage:
/// ```dart
/// // Check if user can attempt login
/// if (!RateLimiter.isAllowed('user@example.com', context: RateLimitContext.login)) {
///   throw Exception('Too many login attempts. Try again later.');
/// }
///
/// // Record successful attempt
/// RateLimiter.recordSuccess('user@example.com', context: RateLimitContext.login);
///
/// // Get remaining attempts
/// final remaining = RateLimiter.getRemainingAttempts('user@example.com');
/// ```

import 'package:flutter/foundation.dart';

/// Rate limit contexts for different operations
enum RateLimitContext {
  /// Login attempts - strict limits
  login,

  /// Password reset - moderate limits
  passwordReset,

  /// Email verification - moderate limits
  emailVerification,

  /// API calls - lenient limits
  apiCall,

  /// Form submission - moderate limits
  formSubmission,

  /// Content creation - lenient limits
  contentCreation,

  /// File upload - strict limits
  fileUpload,
}

class RateLimiter {
  // Singleton pattern
  static final RateLimiter _instance = RateLimiter._internal();

  factory RateLimiter() => _instance;

  RateLimiter._internal();

  /// Storage for attempt records: identifier -> list of attempt timestamps
  static final Map<String, List<DateTime>> _attempts = {};

  /// Storage for lock-out records: identifier -> lock-out expiry time
  static final Map<String, DateTime> _lockouts = {};

  /// Configuration for different contexts
  static final Map<RateLimitContext, RateLimitConfig> _configs = {
    RateLimitContext.login: RateLimitConfig(
      maxAttempts: 5,
      window: Duration(minutes: 15),
      lockoutDuration: Duration(hours: 1),
      description: 'Login attempts',
    ),
    RateLimitContext.passwordReset: RateLimitConfig(
      maxAttempts: 3,
      window: Duration(hours: 1),
      lockoutDuration: Duration(hours: 24),
      description: 'Password reset requests',
    ),
    RateLimitContext.emailVerification: RateLimitConfig(
      maxAttempts: 5,
      window: Duration(hours: 1),
      lockoutDuration: Duration(hours: 6),
      description: 'Email verification requests',
    ),
    RateLimitContext.apiCall: RateLimitConfig(
      maxAttempts: 100,
      window: Duration(minutes: 1),
      lockoutDuration: Duration(minutes: 5),
      description: 'API calls',
    ),
    RateLimitContext.formSubmission: RateLimitConfig(
      maxAttempts: 10,
      window: Duration(minutes: 5),
      lockoutDuration: Duration(minutes: 15),
      description: 'Form submissions',
    ),
    RateLimitContext.contentCreation: RateLimitConfig(
      maxAttempts: 20,
      window: Duration(minutes: 10),
      lockoutDuration: Duration(minutes: 30),
      description: 'Content creation',
    ),
    RateLimitContext.fileUpload: RateLimitConfig(
      maxAttempts: 10,
      window: Duration(minutes: 30),
      lockoutDuration: Duration(hours: 2),
      description: 'File uploads',
    ),
  };

  // ========================================
  // Main Rate Limiting Methods
  // ========================================

  /// Check if an action is allowed for the given identifier
  ///
  /// Returns `true` if the action is allowed, `false` if rate limited
  static bool isAllowed(
    String identifier, {
    required RateLimitContext context,
    RateLimitConfig? customConfig,
  }) {
    final config = customConfig ?? _configs[context]!;
    final key = _generateKey(identifier, context);

    // Check if currently locked out
    if (_isLockedOut(key)) {
      final lockoutExpiry = _lockouts[key]!;
      final remainingTime = lockoutExpiry.difference(DateTime.now());

      debugPrint(
        '🚫 Rate Limit: $identifier is locked out for ${context.name}. '
        'Remaining: ${remainingTime.inMinutes} minutes',
      );

      return false;
    }

    // Get or create attempts list
    _attempts.putIfAbsent(key, () => []);
    final now = DateTime.now();

    // Remove old attempts outside the time window
    _attempts[key]!.removeWhere(
      (time) => now.difference(time) > config.window,
    );

    // Check if limit exceeded
    if (_attempts[key]!.length >= config.maxAttempts) {
      // Apply lock-out
      _applyLockout(key, config.lockoutDuration);

      debugPrint(
        '⚠️ Rate Limit: Maximum ${config.maxAttempts} ${config.description} '
        'exceeded for $identifier. Locked out for ${config.lockoutDuration.inMinutes} minutes.',
      );

      return false;
    }

    // Record this attempt
    _attempts[key]!.add(now);

    final remaining = config.maxAttempts - _attempts[key]!.length;
    debugPrint(
      '✅ Rate Limit: Allowed for $identifier. '
      'Remaining attempts: $remaining/${config.maxAttempts}',
    );

    return true;
  }

  /// Record a successful action (resets attempts for this identifier)
  static void recordSuccess(
    String identifier, {
    required RateLimitContext context,
  }) {
    final key = _generateKey(identifier, context);
    _attempts.remove(key);
    _lockouts.remove(key);

    debugPrint('✨ Rate Limit: Success recorded for $identifier (${context.name}). Counter reset.');
  }

  /// Get remaining attempts for an identifier
  static int getRemainingAttempts(
    String identifier, {
    required RateLimitContext context,
  }) {
    final config = _configs[context]!;
    final key = _generateKey(identifier, context);

    if (_isLockedOut(key)) {
      return 0;
    }

    _attempts.putIfAbsent(key, () => []);
    final now = DateTime.now();

    // Clean old attempts
    _attempts[key]!.removeWhere(
      (time) => now.difference(time) > config.window,
    );

    return config.maxAttempts - _attempts[key]!.length;
  }

  /// Get time remaining until lock-out expires
  static Duration? getLockoutRemaining(
    String identifier, {
    required RateLimitContext context,
  }) {
    final key = _generateKey(identifier, context);

    if (!_isLockedOut(key)) {
      return null;
    }

    final lockoutExpiry = _lockouts[key]!;
    return lockoutExpiry.difference(DateTime.now());
  }

  /// Check if identifier is currently locked out
  static bool isLockedOut(
    String identifier, {
    required RateLimitContext context,
  }) {
    final key = _generateKey(identifier, context);
    return _isLockedOut(key);
  }

  // ========================================
  // Utility Methods
  // ========================================

  /// Clear all rate limit data for an identifier (admin use only)
  static void clearLimits(String identifier) {
    final keysToRemove = <String>[];

    for (final key in _attempts.keys) {
      if (key.startsWith(identifier)) {
        keysToRemove.add(key);
      }
    }

    for (final key in keysToRemove) {
      _attempts.remove(key);
      _lockouts.remove(key);
    }

    debugPrint('🗑️ Rate Limit: Cleared all limits for $identifier');
  }

  /// Clear all rate limit data (use with caution)
  static void clearAll() {
    _attempts.clear();
    _lockouts.clear();
    debugPrint('🗑️ Rate Limit: Cleared all rate limit data');
  }

  /// Get statistics for debugging
  static RateLimitStats getStats(
    String identifier, {
    required RateLimitContext context,
  }) {
    final config = _configs[context]!;
    final key = _generateKey(identifier, context);
    final attempts = _attempts[key]?.length ?? 0;
    final remaining = getRemainingAttempts(identifier, context: context);
    final lockedOut = _isLockedOut(key);
    final lockoutRemaining = lockedOut ? getLockoutRemaining(identifier, context: context) : null;

    return RateLimitStats(
      identifier: identifier,
      context: context,
      currentAttempts: attempts,
      maxAttempts: config.maxAttempts,
      remainingAttempts: remaining,
      isLockedOut: lockedOut,
      lockoutRemaining: lockoutRemaining,
      window: config.window,
    );
  }

  // ========================================
  // Private Helper Methods
  // ========================================

  /// Generate unique key for identifier and context
  static String _generateKey(String identifier, RateLimitContext context) {
    return '${identifier}_${context.name}';
  }

  /// Check if a key is currently locked out
  static bool _isLockedOut(String key) {
    if (!_lockouts.containsKey(key)) {
      return false;
    }

    final lockoutExpiry = _lockouts[key]!;
    final now = DateTime.now();

    // If lockout expired, remove it
    if (now.isAfter(lockoutExpiry)) {
      _lockouts.remove(key);
      return false;
    }

    return true;
  }

  /// Apply lockout for a key
  static void _applyLockout(String key, Duration duration) {
    final lockoutExpiry = DateTime.now().add(duration);
    _lockouts[key] = lockoutExpiry;

    debugPrint(
      '🔒 Rate Limit: Lock-out applied for $key until '
      '${lockoutExpiry.toIso8601String()}',
    );
  }

  /// Periodic cleanup of old data (call this periodically in production)
  static void performCleanup() {
    final now = DateTime.now();
    final expiredKeys = <String>[];

    // Find expired attempts
    for (final entry in _attempts.entries) {
      // If all attempts are old, remove the entry
      if (entry.value.isEmpty ||
          entry.value.every((time) => now.difference(time) > Duration(hours: 24))) {
        expiredKeys.add(entry.key);
      }
    }

    // Find expired lockouts
    for (final entry in _lockouts.entries) {
      if (now.isAfter(entry.value)) {
        expiredKeys.add(entry.key);
      }
    }

    // Remove expired data
    for (final key in expiredKeys) {
      _attempts.remove(key);
      _lockouts.remove(key);
    }

    if (expiredKeys.isNotEmpty) {
      debugPrint('🧹 Rate Limit: Cleaned up ${expiredKeys.length} expired entries');
    }
  }
}

// ========================================
// Configuration Classes
// ========================================

/// Configuration for rate limiting
class RateLimitConfig {
  /// Maximum number of attempts allowed within the time window
  final int maxAttempts;

  /// Time window for counting attempts
  final Duration window;

  /// Duration to lock out after exceeding max attempts
  final Duration lockoutDuration;

  /// Human-readable description
  final String description;

  const RateLimitConfig({
    required this.maxAttempts,
    required this.window,
    required this.lockoutDuration,
    required this.description,
  });
}

/// Statistics about rate limiting for an identifier
class RateLimitStats {
  final String identifier;
  final RateLimitContext context;
  final int currentAttempts;
  final int maxAttempts;
  final int remainingAttempts;
  final bool isLockedOut;
  final Duration? lockoutRemaining;
  final Duration window;

  RateLimitStats({
    required this.identifier,
    required this.context,
    required this.currentAttempts,
    required this.maxAttempts,
    required this.remainingAttempts,
    required this.isLockedOut,
    required this.lockoutRemaining,
    required this.window,
  });

  @override
  String toString() => '''
RateLimitStats(
  identifier: $identifier,
  context: ${context.name},
  attempts: $currentAttempts/$maxAttempts,
  remaining: $remainingAttempts,
  lockedOut: $isLockedOut,
  lockoutRemaining: ${lockoutRemaining?.inMinutes ?? 0} minutes,
  window: ${window.inMinutes} minutes
)''';
}

/// Custom exception for rate limiting
class RateLimitException implements Exception {
  final String message;
  final Duration? retryAfter;

  RateLimitException(this.message, {this.retryAfter});

  @override
  String toString() {
    if (retryAfter != null) {
      return 'RateLimitException: $message (Retry after ${retryAfter!.inMinutes} minutes)';
    }
    return 'RateLimitException: $message';
  }
}
