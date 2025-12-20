import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';
import '../services/deep_link_service.dart';
import '../../shared/utils/logger.dart';

/// FCM 토큰 Provider
final fcmTokenProvider = FutureProvider<String?>((ref) async {
  try {
    final messaging = FirebaseMessaging.instance;

    // 알림 권한 요청
    final settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      Logger.info('FCM 권한 승인됨', tag: 'FCM');
      final token = await messaging.getToken();
      Logger.info('FCM 토큰: $token', tag: 'FCM');
      return token;
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      Logger.info('FCM 임시 권한 승인됨', tag: 'FCM');
      final token = await messaging.getToken();
      return token;
    } else {
      Logger.warning('FCM 권한 거부됨', tag: 'FCM');
      return null;
    }
  } catch (e, stackTrace) {
    Logger.error('FCM 토큰 가져오기 실패', error: e, stackTrace: stackTrace, tag: 'FCM');
    return null;
  }
});

/// FCM 메시지 스트림 Provider (포그라운드)
final fcmMessagesProvider = StreamProvider<RemoteMessage>((ref) {
  return FirebaseMessaging.onMessage;
});

/// FCM 메시지 오픈 스트림 Provider (백그라운드에서 알림 탭)
final fcmMessageOpenedProvider = StreamProvider<RemoteMessage>((ref) {
  return FirebaseMessaging.onMessageOpenedApp;
});

/// FCM 서비스 초기화 및 핸들러 설정
class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final NotificationService _notificationService = NotificationService();
  final DeepLinkService _deepLinkService = DeepLinkService();

  /// FCM 초기화
  Future<void> initialize() async {
    try {
      Logger.info('FCM 서비스 초기화 시작', tag: 'FCM');

      // 포그라운드 메시지 핸들러
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // 백그라운드 메시지 핸들러 (앱이 백그라운드에 있을 때)
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpened);

      // 앱이 종료된 상태에서 알림을 탭하여 앱을 실행한 경우
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpened(initialMessage);
      }

      // FCM 토큰 갱신 리스너
      _messaging.onTokenRefresh.listen((newToken) {
        Logger.info('FCM 토큰 갱신: $newToken', tag: 'FCM');
        // TODO: 서버에 새 토큰 전송
      });

      Logger.info('FCM 서비스 초기화 완료', tag: 'FCM');
    } catch (e, stackTrace) {
      Logger.error('FCM 서비스 초기화 실패', error: e, stackTrace: stackTrace, tag: 'FCM');
    }
  }

  /// 포그라운드 메시지 처리
  void _handleForegroundMessage(RemoteMessage message) {
    Logger.info('포그라운드 메시지 수신: ${message.notification?.title}', tag: 'FCM');

    // 로컬 알림 표시
    if (message.notification != null) {
      _notificationService.showNotification(
        title: message.notification!.title ?? '알림',
        body: message.notification!.body ?? '',
        payload: message.data.toString(),
      );
    }

    // 데이터 메시지 처리
    if (message.data.isNotEmpty) {
      _handleDataMessage(message.data);
    }
  }

  /// 메시지 오픈 처리 (백그라운드에서 알림 탭)
  void _handleMessageOpened(RemoteMessage message) {
    Logger.info('메시지 오픈: ${message.notification?.title}', tag: 'FCM');

    // 데이터 메시지 처리 (딥링크, 화면 이동 등)
    if (message.data.isNotEmpty) {
      _handleDataMessage(message.data);
    }
  }

  /// 데이터 메시지 처리
  void _handleDataMessage(Map<String, dynamic> data) {
    Logger.debug('데이터 메시지 처리: $data', tag: 'FCM');

    // 딥링크 데이터 저장 (나중에 BuildContext가 있을 때 처리)
    _pendingDeepLinkData = data;
  }

  // 대기 중인 딥링크 데이터
  Map<String, dynamic>? _pendingDeepLinkData;

  /// 대기 중인 딥링크 처리 (BuildContext가 있을 때)
  Future<void> processPendingDeepLink(BuildContext context) async {
    if (_pendingDeepLinkData != null) {
      await _deepLinkService.handleNotification(context, _pendingDeepLinkData!);
      _pendingDeepLinkData = null;
    }
  }

  /// 특정 토픽 구독
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      Logger.info('토픽 구독: $topic', tag: 'FCM');
    } catch (e, stackTrace) {
      Logger.error('토픽 구독 실패: $topic', error: e, stackTrace: stackTrace, tag: 'FCM');
    }
  }

  /// 특정 토픽 구독 해제
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      Logger.info('토픽 구독 해제: $topic', tag: 'FCM');
    } catch (e, stackTrace) {
      Logger.error('토픽 구독 해제 실패: $topic', error: e, stackTrace: stackTrace, tag: 'FCM');
    }
  }

  /// FCM 토큰 가져오기
  Future<String?> getToken() async {
    try {
      final token = await _messaging.getToken();
      Logger.info('현재 FCM 토큰: $token', tag: 'FCM');
      return token;
    } catch (e, stackTrace) {
      Logger.error('FCM 토큰 가져오기 실패', error: e, stackTrace: stackTrace, tag: 'FCM');
      return null;
    }
  }

  /// FCM 토큰 삭제
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      Logger.info('FCM 토큰 삭제 완료', tag: 'FCM');
    } catch (e, stackTrace) {
      Logger.error('FCM 토큰 삭제 실패', error: e, stackTrace: stackTrace, tag: 'FCM');
    }
  }
}

/// FCM 서비스 Provider
final fcmServiceProvider = Provider<FcmService>((ref) {
  return FcmService();
});

/// FCM 서비스 초기화 Provider
final fcmServiceInitializedProvider = FutureProvider<bool>((ref) async {
  final fcmService = ref.watch(fcmServiceProvider);
  await fcmService.initialize();
  return true;
});
