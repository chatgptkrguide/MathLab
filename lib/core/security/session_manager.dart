// 🕐 Session Manager Service
//
// Provides automatic session timeout and inactivity detection
// to enhance security by logging out inactive users.
//
// Features:
// - Automatic logout after inactivity period
// - Session timeout configuration
// - Activity tracking across the app
// - Background/Foreground state handling
// - Manual session refresh
//
// Usage:
// ```dart
// // Initialize in main app
// SessionManager.initialize(
//   onSessionExpired: () {
//     // Navigate to login screen
//     Navigator.of(context).pushReplacementNamed('/login');
//   },
// );
//
// // Record user activity
// SessionManager.recordActivity(); // Call on user interactions
//
// // Check session validity
// if (!SessionManager.isSessionValid()) {
//   // Force logout
// }
//
// // Stop monitoring (on logout)
// SessionManager.stopMonitoring();
// ```

import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/app_logger.dart';
import 'secure_storage_service.dart';

class SessionManager {
  // Singleton pattern
  static final SessionManager _instance = SessionManager._internal();

  factory SessionManager() => _instance;

  SessionManager._internal();

  // ========================================
  // Configuration
  // ========================================

  /// Default session timeout duration (2 hours)
  static const Duration defaultSessionTimeout = Duration(hours: 2);

  /// Default inactivity timeout duration (30 minutes)
  static const Duration defaultInactivityTimeout = Duration(minutes: 30);

  /// Warning period before logout (2 minutes)
  static const Duration warningPeriod = Duration(minutes: 2);

  // ========================================
  // State Management
  // ========================================

  static DateTime? _lastActivityTime;
  static Timer? _inactivityTimer;
  static Timer? _sessionCheckTimer;
  static VoidCallback? _onSessionExpired;
  static VoidCallback? _onInactivityWarning;

  static Duration _sessionTimeout = defaultSessionTimeout;
  static Duration _inactivityTimeout = defaultInactivityTimeout;

  static bool _isMonitoring = false;
  static bool _hasWarned = false;

  // ========================================
  // Initialization & Configuration
  // ========================================

  /// Initialize session manager with callbacks
  static void initialize({
    required VoidCallback onSessionExpired,
    VoidCallback? onInactivityWarning,
    Duration? sessionTimeout,
    Duration? inactivityTimeout,
  }) {
    _onSessionExpired = onSessionExpired;
    _onInactivityWarning = onInactivityWarning;

    if (sessionTimeout != null) {
      _sessionTimeout = sessionTimeout;
    }

    if (inactivityTimeout != null) {
      _inactivityTimeout = inactivityTimeout;
    }

    AppLogger.info(
      'SessionManager initialized',
      data: {
        'sessionTimeout': _sessionTimeout.inMinutes,
        'inactivityTimeout': _inactivityTimeout.inMinutes,
      },
    );
  }

  /// Start monitoring session activity
  static void startMonitoring() {
    if (_isMonitoring) {
      AppLogger.warning('SessionManager already monitoring');
      return;
    }

    _isMonitoring = true;
    _lastActivityTime = DateTime.now();
    _hasWarned = false;

    // Start inactivity timer
    _startInactivityTimer();

    // Start periodic session check (every minute)
    _sessionCheckTimer = Timer.periodic(
      Duration(minutes: 1),
      (_) => _checkSession(),
    );

    AppLogger.info('SessionManager: Monitoring started');
  }

  /// Stop monitoring session activity
  static void stopMonitoring() {
    _inactivityTimer?.cancel();
    _sessionCheckTimer?.cancel();
    _inactivityTimer = null;
    _sessionCheckTimer = null;
    _lastActivityTime = null;
    _isMonitoring = false;
    _hasWarned = false;

    AppLogger.info('SessionManager: Monitoring stopped');
  }

  // ========================================
  // Activity Tracking
  // ========================================

  /// Record user activity (call this on user interactions)
  static void recordActivity() {
    if (!_isMonitoring) {
      return;
    }

    final now = DateTime.now();
    _lastActivityTime = now;
    _hasWarned = false;

    // Reset inactivity timer
    _startInactivityTimer();

    // Update last activity in secure storage
    _updateLastActivityInStorage(now);

    debugPrint('📱 Session: Activity recorded at ${now.toIso8601String()}');
  }

  // ========================================
  // Session Validation
  // ========================================

  /// Check if current session is valid
  static Future<bool> isSessionValid() async {
    if (_lastActivityTime == null) {
      return false;
    }

    final now = DateTime.now();
    final storage = SecureStorageService();

    // Check absolute session timeout (from login time)
    final lastLoginTime = await storage.getLastLoginTime();
    if (lastLoginTime != null) {
      final sessionDuration = now.difference(lastLoginTime);
      if (sessionDuration > _sessionTimeout) {
        AppLogger.warning(
          'Session expired (timeout)',
          data: {'sessionDuration': sessionDuration.inMinutes},
        );
        return false;
      }
    }

    // Check inactivity timeout
    final inactivityDuration = now.difference(_lastActivityTime!);
    if (inactivityDuration > _inactivityTimeout) {
      AppLogger.warning(
        'Session expired (inactivity)',
        data: {'inactivityDuration': inactivityDuration.inMinutes},
      );
      return false;
    }

    return true;
  }

  /// Get remaining time until session expires
  static Duration? getRemainingSessionTime() {
    if (_lastActivityTime == null) {
      return null;
    }

    final now = DateTime.now();
    final elapsed = now.difference(_lastActivityTime!);
    final remaining = _inactivityTimeout - elapsed;

    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Get remaining time until inactivity warning
  static Duration? getTimeUntilWarning() {
    final remaining = getRemainingSessionTime();
    if (remaining == null) {
      return null;
    }

    final timeUntilWarning = remaining - warningPeriod;
    return timeUntilWarning.isNegative ? Duration.zero : timeUntilWarning;
  }

  // ========================================
  // Session Management
  // ========================================

  /// Manually refresh session (extends timeout)
  static void refreshSession() {
    recordActivity();
    AppLogger.info('Session manually refreshed');
  }

  /// Force logout (session expired or manual)
  static Future<void> forceLogout({String? reason}) async {
    AppLogger.warning(
      'Session: Force logout triggered',
      data: {'reason': reason ?? 'Manual logout'},
    );

    // Stop monitoring
    stopMonitoring();

    // Clear secure storage
    final storage = SecureStorageService();
    await storage.clearAll();

    // Trigger callback
    _onSessionExpired?.call();
  }

  // ========================================
  // Private Helper Methods
  // ========================================

  /// Start or restart inactivity timer
  static void _startInactivityTimer() {
    _inactivityTimer?.cancel();

    _inactivityTimer = Timer(_inactivityTimeout, () async {
      AppLogger.warning('Inactivity timeout reached');
      await forceLogout(reason: 'Inactivity timeout');
    });
  }

  /// Periodic session check
  static Future<void> _checkSession() async {
    if (!_isMonitoring) {
      return;
    }

    final isValid = await isSessionValid();

    if (!isValid) {
      await forceLogout(reason: 'Session validation failed');
      return;
    }

    // Check if warning should be shown
    final remainingTime = getRemainingSessionTime();
    if (remainingTime != null && remainingTime <= warningPeriod && !_hasWarned) {
      _hasWarned = true;
      _onInactivityWarning?.call();

      AppLogger.warning(
        'Inactivity warning',
        data: {'remainingMinutes': remainingTime.inMinutes},
      );
    }
  }

  /// Update last activity time in storage
  static Future<void> _updateLastActivityInStorage(DateTime time) async {
    try {
      final storage = SecureStorageService();
      await storage.saveSecure(
        'last_activity_time',
        time.toIso8601String(),
      );
    } catch (e) {
      AppLogger.error('Failed to update activity time in storage', error: e);
    }
  }

  // ========================================
  // Getters
  // ========================================

  static DateTime? get lastActivityTime => _lastActivityTime;
  static bool get isMonitoring => _isMonitoring;
  static Duration get sessionTimeout => _sessionTimeout;
  static Duration get inactivityTimeout => _inactivityTimeout;
}

/// Widget to automatically track user activity
class SessionActivityTracker extends StatefulWidget {
  final Widget child;

  const SessionActivityTracker({
    super.key,
    required this.child,
  });

  @override
  State<SessionActivityTracker> createState() => _SessionActivityTrackerState();
}

class _SessionActivityTrackerState extends State<SessionActivityTracker> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // App returned to foreground - check session validity
        _checkSessionOnResume();
        break;
      case AppLifecycleState.paused:
        // App went to background - record last activity
        SessionManager.recordActivity();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  Future<void> _checkSessionOnResume() async {
    final isValid = await SessionManager.isSessionValid();
    if (!isValid && mounted) {
      // Session expired while app was in background
      await SessionManager.forceLogout(reason: 'Session expired in background');
    } else {
      // Session still valid - record activity
      SessionManager.recordActivity();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: SessionManager.recordActivity,
      onPanDown: (_) => SessionManager.recordActivity(),
      onScaleStart: (_) => SessionManager.recordActivity(),
      behavior: HitTestBehavior.translucent,
      child: widget.child,
    );
  }
}
