import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart';
import '../../shared/utils/logger.dart';

/// 푸시 알림 및 로컬 알림 서비스
/// Firebase Cloud Messaging + Flutter Local Notifications
class NotificationService {
  // 싱글톤 패턴
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Firebase Messaging
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Local Notifications
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // FCM 토큰
  String? _fcmToken;

  /// 초기화
  Future<void> initialize() async {
    try {
      // 1. 알림 권한 요청
      await _requestPermission();

      // 2. FCM 토큰 가져오기
      await _getFCMToken();

      // 3. 로컬 알림 초기화
      await _initializeLocalNotifications();

      // 4. FCM 메시지 핸들러 설정
      _setupMessageHandlers();

      Logger.info('NotificationService initialized', tag: 'NotificationService');
    } catch (e) {
      Logger.error('Failed to initialize NotificationService', error: e);
    }
  }

  /// 알림 권한 요청
  Future<void> _requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    Logger.info(
      'User granted permission: ${settings.authorizationStatus}',
      tag: 'NotificationService',
    );
  }

  /// FCM 토큰 가져오기
  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      Logger.info('FCM Token: $_fcmToken', tag: 'NotificationService');

      // 토큰 갱신 리스너
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        Logger.info('FCM Token refreshed: $newToken', tag: 'NotificationService');
        // TODO: 서버에 새 토큰 저장
      });
    } catch (e) {
      Logger.error('Failed to get FCM token', error: e);
    }
  }

  /// 로컬 알림 초기화
  Future<void> _initializeLocalNotifications() async {
    // Android 설정
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS 설정
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    Logger.info('Local notifications initialized', tag: 'NotificationService');
  }

  /// FCM 메시지 핸들러 설정
  void _setupMessageHandlers() {
    // 포그라운드 메시지
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Logger.info(
        'Foreground message: ${message.notification?.title}',
        tag: 'NotificationService',
      );
      _showLocalNotification(message);
    });

    // 백그라운드 메시지 탭
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Logger.info(
        'Background message opened: ${message.notification?.title}',
        tag: 'NotificationService',
      );
      _handleNotificationTap(message.data);
    });
  }

  /// 로컬 알림 표시 (포그라운드 메시지용)
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'mathlab_channel',
      'MathLab Notifications',
      channelDescription: '학습 알림 및 리마인더',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: message.data.toString(),
    );
  }

  /// Public method for showing notifications
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'mathlab_channel',
      'MathLab Notifications',
      channelDescription: '학습 알림 및 리마인더',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// 알림 탭 핸들러
  void _onNotificationTapped(NotificationResponse response) {
    Logger.info(
      'Notification tapped: ${response.payload}',
      tag: 'NotificationService',
    );
    // TODO: 적절한 화면으로 네비게이션
  }

  /// 알림 데이터 핸들링
  void _handleNotificationTap(Map<String, dynamic> data) {
    // TODO: 알림 타입별 처리
    final type = data['type'] as String?;
    switch (type) {
      case 'streak_reminder':
        // 스트릭 화면으로 이동
        break;
      case 'heart_recovered':
        // 홈 화면으로 이동
        break;
      case 'league_update':
        // 리그 화면으로 이동
        break;
      default:
        // 홈 화면으로 이동
        break;
    }
  }

  /// 스트릭 유지 알림 스케줄링 (매일 저녁 8시)
  Future<void> scheduleStreakReminder({
    required int currentStreak,
    int hour = 20, // 저녁 8시
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'streak_channel',
        'Streak Reminders',
        channelDescription: '연속 학습 리마인더',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // 매일 저녁 8시에 알림
      await _localNotifications.zonedSchedule(
        0, // 알림 ID
        '🔥 스트릭을 지켜주세요!',
        '오늘 학습하지 않으면 $currentStreak일 스트릭이 사라져요! 지금 바로 학습하세요.',
        _nextInstanceOfTime(hour, 0),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      Logger.info('Streak reminder scheduled at $hour:00', tag: 'NotificationService');
    } catch (e) {
      Logger.error('Failed to schedule streak reminder', error: e);
    }
  }

  /// 하트 재생 알림 (30분 후)
  Future<void> scheduleHeartRecoveryNotification() async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'heart_channel',
        'Heart Recovery',
        channelDescription: '하트 재생 알림',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // 30분 후 알림
      await _localNotifications.zonedSchedule(
        1, // 알림 ID
        '❤️ 하트가 재생되었어요!',
        '이제 다시 학습할 수 있어요. 문제를 풀러 가볼까요?',
        _nextInstanceOfMinutes(30),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      Logger.info('Heart recovery notification scheduled', tag: 'NotificationService');
    } catch (e) {
      Logger.error('Failed to schedule heart recovery notification', error: e);
    }
  }

  /// 리그 종료 알림 (일요일 밤 11시)
  Future<void> scheduleLeagueEndNotification() async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'league_channel',
        'League Updates',
        channelDescription: '리그 순위 및 업데이트 알림',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.zonedSchedule(
        2, // 알림 ID
        '🏆 주간 리그가 곧 종료됩니다!',
        '순위를 지키려면 마지막 스퍼트! 1시간 남았어요.',
        _nextInstanceOfDayAndTime(DateTime.sunday, 23, 0),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );

      Logger.info('League end notification scheduled', tag: 'NotificationService');
    } catch (e) {
      Logger.error('Failed to schedule league end notification', error: e);
    }
  }

  /// 일일 챌린지 알림 (오전 9시)
  Future<void> scheduleDailyChallengeNotification() async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'challenge_channel',
        'Daily Challenges',
        channelDescription: '일일 챌린지 알림',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.zonedSchedule(
        3, // 알림 ID
        '🎯 새로운 일일 챌린지가 도착했어요!',
        '오늘의 챌린지를 완료하고 보상을 받으세요.',
        _nextInstanceOfTime(9, 0),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      Logger.info('Daily challenge notification scheduled', tag: 'NotificationService');
    } catch (e) {
      Logger.error('Failed to schedule daily challenge notification', error: e);
    }
  }

  /// 특정 시각의 다음 인스턴스 계산
  TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final location = getLocation('Asia/Seoul');
    final now = TZDateTime.now(location);
    var scheduledDate = TZDateTime(location, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// N분 후 시각 계산
  TZDateTime _nextInstanceOfMinutes(int minutes) {
    final location = getLocation('Asia/Seoul');
    return TZDateTime.now(location).add(Duration(minutes: minutes));
  }

  /// 특정 요일 및 시각의 다음 인스턴스 계산
  TZDateTime _nextInstanceOfDayAndTime(int weekday, int hour, int minute) {
    var scheduledDate = _nextInstanceOfTime(hour, minute);

    while (scheduledDate.weekday != weekday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// 모든 알림 취소
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
    Logger.info('All notifications cancelled', tag: 'NotificationService');
  }

  /// 특정 알림 취소
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
    Logger.info('Notification $id cancelled', tag: 'NotificationService');
  }

  /// FCM 토큰 가져오기
  String? get fcmToken => _fcmToken;
}

/// Timezone 초기화 (앱 시작 시 호출)
Future<void> initializeTimezone() async {
  tz.initializeTimeZones();
}
