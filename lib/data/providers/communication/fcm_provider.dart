// 🔔 Firebase Cloud Messaging (FCM) Provider
//
// Manages push notifications and FCM token

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../../core/utils/app_logger.dart';

// FCM Service Provider
final fcmServiceProvider = Provider<FCMService>((ref) {
  return FCMService();
});

// FCM Service Initialized Provider
final fcmServiceInitializedProvider = FutureProvider<bool>((ref) async {
  final fcmService = ref.read(fcmServiceProvider);
  await fcmService.initialize();
  return true;
});

// FCM Token Provider
final fcmTokenProvider = FutureProvider<String?>((ref) async {
  final fcmService = ref.read(fcmServiceProvider);
  return fcmService.getToken();
});

class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? _token;
  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _foregroundMsgSub;
  StreamSubscription<RemoteMessage>? _backgroundMsgSub;

  /// Initialize FCM service
  Future<void> initialize() async {
    try {
      // Request notification permissions (with timeout for web/headless)
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      ).timeout(const Duration(seconds: 8), onTimeout: () {
        AppLogger.warning('FCM 권한 요청 타임아웃', tag: 'FCM');
        return const NotificationSettings(
          authorizationStatus: AuthorizationStatus.denied,
          alert: AppleNotificationSetting.disabled,
          announcement: AppleNotificationSetting.disabled,
          badge: AppleNotificationSetting.disabled,
          carPlay: AppleNotificationSetting.disabled,
          criticalAlert: AppleNotificationSetting.disabled,
          lockScreen: AppleNotificationSetting.disabled,
          notificationCenter: AppleNotificationSetting.disabled,
          showPreviews: AppleShowPreviewSetting.never,
          sound: AppleNotificationSetting.disabled,
          timeSensitive: AppleNotificationSetting.disabled,
          providesAppNotificationSettings: AppleNotificationSetting.disabled,
        );
      });

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        AppLogger.info('FCM 권한 승인됨', tag: 'FCM');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        AppLogger.info('FCM 임시 권한 승인됨', tag: 'FCM');
      } else {
        AppLogger.warning('FCM 권한 거부됨', tag: 'FCM');
        return;
      }

      // Get FCM token
      _token = await _messaging.getToken();
      if (_token != null) {
        AppLogger.info('FCM 토큰 획득: ${_token!.substring(0, 20)}...', tag: 'FCM');
      }

      // Save initial token to Firestore
      if (_token != null) {
        await _saveFcmTokenToFirestore(_token!);
      }

      // Listen for token refresh
      _tokenRefreshSub?.cancel();
      _tokenRefreshSub = _messaging.onTokenRefresh.listen((newToken) {
        _token = newToken;
        AppLogger.info('FCM 토큰 갱신됨: ${newToken.substring(0, 20)}...', tag: 'FCM');
        _saveFcmTokenToFirestore(newToken);
      });

      // Configure foreground notification presentation
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Handle foreground messages
      _foregroundMsgSub?.cancel();
      _foregroundMsgSub = FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background messages
      _backgroundMsgSub?.cancel();
      _backgroundMsgSub = FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

      // Check if app was opened from a terminated state via notification
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleInitialMessage(initialMessage);
      }

      AppLogger.info('FCM 서비스 초기화 완료', tag: 'FCM');
    } catch (e) {
      AppLogger.error('FCM 초기화 실패', error: e, tag: 'FCM');
    }
  }

  /// Save FCM token to Firestore for the current user
  Future<void> _saveFcmTokenToFirestore(String token) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        AppLogger.debug('FCM 토큰 저장 스킵: 로그인된 사용자 없음', tag: 'FCM');
        return;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });

      AppLogger.info('FCM 토큰 Firestore 저장 완료', tag: 'FCM');
    } catch (e) {
      AppLogger.error('FCM 토큰 Firestore 저장 실패', error: e, tag: 'FCM');
    }
  }

  /// Get current FCM token
  Future<String?> getToken() async {
    try {
      _token ??= await _messaging.getToken();
      return _token;
    } catch (e) {
      AppLogger.error('FCM 토큰 가져오기 실패', error: e, tag: 'FCM');
      return null;
    }
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      AppLogger.info('FCM 토픽 구독: $topic', tag: 'FCM');
    } catch (e) {
      AppLogger.error('FCM 토픽 구독 실패: $topic', error: e, tag: 'FCM');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      AppLogger.info('FCM 토픽 구독 해제: $topic', tag: 'FCM');
    } catch (e) {
      AppLogger.error('FCM 토픽 구독 해제 실패: $topic', error: e, tag: 'FCM');
    }
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    AppLogger.info(
      'FCM 포그라운드 메시지 수신: ${message.notification?.title ?? "제목 없음"}',
      tag: 'FCM',
    );
    debugPrint('📬 알림 데이터: ${message.data}');

    // Show in-app notification or update UI
    if (message.notification != null) {
      final notification = message.notification!;
      debugPrint('📬 알림: ${notification.title}');
      debugPrint('   내용: ${notification.body}');
    }
  }

  /// Handle background messages (app in background)
  void _handleBackgroundMessage(RemoteMessage message) {
    AppLogger.info(
      'FCM 백그라운드 메시지 수신 (앱 열림): ${message.notification?.title ?? "제목 없음"}',
      tag: 'FCM',
    );
    debugPrint('📬 알림 데이터: ${message.data}');

    // Navigate to specific screen based on message data
    _handleNotificationNavigation(message);
  }

  /// Handle initial message (app opened from terminated state)
  void _handleInitialMessage(RemoteMessage message) {
    AppLogger.info(
      'FCM 초기 메시지 수신 (종료 상태에서 앱 열림): ${message.notification?.title ?? "제목 없음"}',
      tag: 'FCM',
    );
    debugPrint('📬 알림 데이터: ${message.data}');

    // Navigate to specific screen based on message data
    _handleNotificationNavigation(message);
  }

  /// Handle notification navigation
  void _handleNotificationNavigation(RemoteMessage message) {
    final data = message.data;

    if (data.isEmpty) return;

    // TODO: Phase 2 - 알림 타입별 네비게이션 구현

    AppLogger.info(
      'FCM 알림 네비게이션 요청: ${data["type"] ?? "타입 없음"}',
      tag: 'FCM',
    );
    debugPrint('📬 네비게이션 데이터: $data');
  }

  /// Process pending deep link
  void processPendingDeepLink(dynamic context) {
    // TODO: Phase 2 - 대기 중인 딥링크 처리 구현
    AppLogger.info('대기 중인 딥링크 처리 요청됨', tag: 'FCM');
  }

  /// Cleanup resources
  void dispose() {
    _tokenRefreshSub?.cancel();
    _foregroundMsgSub?.cancel();
    _backgroundMsgSub?.cancel();
    _tokenRefreshSub = null;
    _foregroundMsgSub = null;
    _backgroundMsgSub = null;
    AppLogger.info('FCM 서비스 정리됨', tag: 'FCM');
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  AppLogger.info(
    'FCM 백그라운드 메시지 처리 (앱 완전 종료 상태): ${message.notification?.title ?? "제목 없음"}',
    tag: 'FCM',
  );
  debugPrint('📬 백그라운드 알림 데이터: ${message.data}');
}
