/// 🔔 Firebase Cloud Messaging (FCM) Provider
///
/// Manages push notifications and FCM token

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../../shared/utils/logger.dart';

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

  /// Initialize FCM service
  Future<void> initialize() async {
    try {
      // Request notification permissions
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        Logger.info('FCM 권한 승인됨', tag: 'FCM');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        Logger.info('FCM 임시 권한 승인됨', tag: 'FCM');
      } else {
        Logger.warning('FCM 권한 거부됨', tag: 'FCM');
        return;
      }

      // Get FCM token
      _token = await _messaging.getToken();
      if (_token != null) {
        Logger.info('FCM 토큰 획득: ${_token!.substring(0, 20)}...', tag: 'FCM');
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        _token = newToken;
        Logger.info('FCM 토큰 갱신됨: ${newToken.substring(0, 20)}...', tag: 'FCM');
        // TODO: Send new token to server
      });

      // Configure foreground notification presentation
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background messages
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

      // Check if app was opened from a terminated state via notification
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleInitialMessage(initialMessage);
      }

      Logger.info('FCM 서비스 초기화 완료', tag: 'FCM');
    } catch (e) {
      Logger.error('FCM 초기화 실패', error: e, tag: 'FCM');
    }
  }

  /// Get current FCM token
  Future<String?> getToken() async {
    try {
      _token ??= await _messaging.getToken();
      return _token;
    } catch (e) {
      Logger.error('FCM 토큰 가져오기 실패', error: e, tag: 'FCM');
      return null;
    }
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      Logger.info('FCM 토픽 구독: $topic', tag: 'FCM');
    } catch (e) {
      Logger.error('FCM 토픽 구독 실패: $topic', error: e, tag: 'FCM');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      Logger.info('FCM 토픽 구독 해제: $topic', tag: 'FCM');
    } catch (e) {
      Logger.error('FCM 토픽 구독 해제 실패: $topic', error: e, tag: 'FCM');
    }
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    Logger.info(
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
    Logger.info(
      'FCM 백그라운드 메시지 수신 (앱 열림): ${message.notification?.title ?? "제목 없음"}',
      tag: 'FCM',
    );
    debugPrint('📬 알림 데이터: ${message.data}');

    // Navigate to specific screen based on message data
    _handleNotificationNavigation(message);
  }

  /// Handle initial message (app opened from terminated state)
  void _handleInitialMessage(RemoteMessage message) {
    Logger.info(
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

    // TODO: Implement navigation based on notification type
    // Example:
    // final type = data['type'];
    // final id = data['id'];
    //
    // switch (type) {
    //   case 'friend_request':
    //     navigatorKey.currentState?.pushNamed('/friends');
    //     break;
    //   case 'achievement':
    //     navigatorKey.currentState?.pushNamed('/achievements');
    //     break;
    //   case 'league':
    //     navigatorKey.currentState?.pushNamed('/league');
    //     break;
    // }

    Logger.info(
      'FCM 알림 네비게이션 요청: ${data["type"] ?? "타입 없음"}',
      tag: 'FCM',
    );
    debugPrint('📬 네비게이션 데이터: $data');
  }

  /// Cleanup resources
  void dispose() {
    Logger.info('FCM 서비스 정리됨', tag: 'FCM');
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  Logger.info(
    'FCM 백그라운드 메시지 처리 (앱 완전 종료 상태): ${message.notification?.title ?? "제목 없음"}',
    tag: 'FCM',
  );
  debugPrint('📬 백그라운드 알림 데이터: ${message.data}');
}
