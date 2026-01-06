import 'dart:async';
// import 'dart:isolate';
// import 'dart:ui';
// import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:workmanager/workmanager.dart';  // 일시적으로 비활성화
import '../../shared/utils/logger.dart';
import '../models/user/user.dart';

/// 하트 재생 백그라운드 서비스
///
/// 백그라운드에서 주기적으로 실행되어 하트를 재생하고 알림을 보내는 서비스
/// Workmanager를 사용하여 iOS/Android 모두 지원
class HeartRegenerationService {
  static const String _tag = 'HeartRegeneration';

  // 타이머 관리
  static Timer? _heartRegenTimer;

  // 하트 재생 관련 상수
  static const int maxHearts = 5;
  static const Duration heartRegenInterval = Duration(minutes: 30); // 30분마다 1개 재생
  static const Duration checkInterval = Duration(minutes: 15); // 15분마다 체크 (더 자주 체크)

  // SharedPreferences 키
  static const String _lastHeartUpdateKey = 'last_heart_update_time';
  static const String _currentHeartsKey = 'current_hearts';
  static const String _userIdKey = 'current_user_id';

  // 알림 설정
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static const String _channelId = 'heart_regeneration';
  static const String _channelName = '하트 재생 알림';
  static const String _channelDesc = '하트가 재생되었을 때 알림을 받습니다';

  /// 서비스 초기화
  static Future<void> initialize() async {
    try {
      Logger.info('하트 재생 서비스 초기화 시작', tag: _tag);

      // 알림 초기화
      await _initializeNotifications();

      // Timer 기반 초기화로 변경 (Workmanager 대신)
      Logger.info('하트 재생 서비스 초기화 완료 (Timer 모드)', tag: _tag);
    } catch (e, stackTrace) {
      Logger.error(
        '하트 재생 서비스 초기화 실패',
        error: e,
        stackTrace: stackTrace,
        tag: _tag,
      );
    }
  }

  /// 알림 초기화
  static Future<void> _initializeNotifications() async {
    // Android 알림 채널 설정
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.defaultImportance,
      playSound: true,
      enableVibration: true,
    );

    // iOS 알림 설정
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Android 알림 설정
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // 초기화 설정 결합
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // 알림 플러그인 초기화
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );

    // Android 알림 채널 생성
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(androidChannel);

    Logger.debug('알림 시스템 초기화 완료', tag: _tag);
  }

  /// 알림 응답 처리
  static void _handleNotificationResponse(NotificationResponse response) {
    Logger.info('알림 클릭: ${response.payload}', tag: _tag);
    // TODO: 알림 클릭 시 앱 열기 및 하트 화면으로 이동
  }

  /// 백그라운드 작업 시작 (Timer 방식)
  static Future<void> startBackgroundTask(String userId) async {
    try {
      Logger.info('백그라운드 작업 시작 (Timer): $userId', tag: _tag);

      // 사용자 ID 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userIdKey, userId);

      // 기존 타이머 취소
      _heartRegenTimer?.cancel();

      // 주기적으로 하트 재생 체크 (15분마다)
      _heartRegenTimer = Timer.periodic(checkInterval, (_) async {
        await regenerateHearts();
      });

      // 첫 실행
      await regenerateHearts();

      Logger.info('백그라운드 작업 시작 완료 (Timer)', tag: _tag);
    } catch (e, stackTrace) {
      Logger.error(
        '백그라운드 작업 시작 실패',
        error: e,
        stackTrace: stackTrace,
        tag: _tag,
      );
    }
  }

  /// 백그라운드 작업 중지 (Timer 방식)
  static Future<void> stopBackgroundTask() async {
    try {
      Logger.info('백그라운드 작업 중지 (Timer)', tag: _tag);
      _heartRegenTimer?.cancel();
      _heartRegenTimer = null;
    } catch (e, stackTrace) {
      Logger.error(
        '백그라운드 작업 중지 실패',
        error: e,
        stackTrace: stackTrace,
        tag: _tag,
      );
    }
  }

  /// 하트 재생 로직 실행
  static Future<void> regenerateHearts() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 현재 하트 수 가져오기
      final currentHearts = prefs.getInt(_currentHeartsKey) ?? maxHearts;

      // 이미 최대치면 재생 불필요
      if (currentHearts >= maxHearts) {
        Logger.debug('하트가 이미 최대치입니다: $currentHearts/$maxHearts', tag: _tag);
        return;
      }

      // 마지막 업데이트 시간 가져오기
      final lastUpdateMillis = prefs.getInt(_lastHeartUpdateKey);
      final now = DateTime.now();

      if (lastUpdateMillis == null) {
        // 첫 실행 - 현재 시간 저장
        await prefs.setInt(_lastHeartUpdateKey, now.millisecondsSinceEpoch);
        Logger.debug('첫 실행 - 타이머 시작', tag: _tag);
        return;
      }

      final lastUpdate = DateTime.fromMillisecondsSinceEpoch(lastUpdateMillis);
      final elapsed = now.difference(lastUpdate);

      // 경과 시간에 따라 재생할 하트 수 계산
      final heartsToRegen = elapsed.inMinutes ~/ heartRegenInterval.inMinutes;

      if (heartsToRegen > 0) {
        final newHearts = (currentHearts + heartsToRegen).clamp(0, maxHearts);
        final actuallyRegenerated = newHearts - currentHearts;

        if (actuallyRegenerated > 0) {
          // 하트 업데이트
          await prefs.setInt(_currentHeartsKey, newHearts);
          await prefs.setInt(_lastHeartUpdateKey, now.millisecondsSinceEpoch);

          Logger.info(
            '하트 재생 완료: $currentHearts → $newHearts (+$actuallyRegenerated)',
            tag: _tag,
          );

          // 알림 발송
          if (newHearts == maxHearts) {
            await _sendFullHeartsNotification();
          } else {
            await _sendHeartRegenNotification(actuallyRegenerated, newHearts);
          }

          // TODO: Firebase에 업데이트
          // 여기서는 백그라운드 작업이므로 직접 Firebase 업데이트는 피하고
          // 다음 앱 실행 시 동기화하도록 플래그만 설정
          await prefs.setBool('hearts_need_sync', true);
        }
      }

      Logger.debug(
        '하트 체크 완료 - 현재: $currentHearts, 경과 시간: ${elapsed.inMinutes}분',
        tag: _tag,
      );
    } catch (e, stackTrace) {
      Logger.error(
        '하트 재생 실패',
        error: e,
        stackTrace: stackTrace,
        tag: _tag,
      );
    }
  }

  /// 하트 재생 알림 발송
  static Future<void> _sendHeartRegenNotification(int regenerated, int total) async {
    try {
      const notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          showWhen: true,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      await _notifications.show(
        1001, // 알림 ID
        '하트가 재생되었습니다! 💖',
        '+$regenerated 하트가 재생되어 현재 $total/$maxHearts 개의 하트를 보유하고 있습니다.',
        notificationDetails,
        payload: 'heart_regenerated',
      );

      Logger.debug('하트 재생 알림 발송 완료', tag: _tag);
    } catch (e, stackTrace) {
      Logger.error(
        '알림 발송 실패',
        error: e,
        stackTrace: stackTrace,
        tag: _tag,
      );
    }
  }

  /// 하트 풀 충전 알림 발송
  static Future<void> _sendFullHeartsNotification() async {
    try {
      const notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      await _notifications.show(
        1002, // 알림 ID
        '하트가 가득 찼습니다! 💖💖💖',
        '모든 하트가 재생되었습니다. 학습을 계속해보세요!',
        notificationDetails,
        payload: 'hearts_full',
      );

      Logger.debug('하트 풀 충전 알림 발송 완료', tag: _tag);
    } catch (e, stackTrace) {
      Logger.error(
        '알림 발송 실패',
        error: e,
        stackTrace: stackTrace,
        tag: _tag,
      );
    }
  }

  /// 하트 수동 업데이트 (앱 내에서 하트 사용 시)
  static Future<void> updateHearts(int hearts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_currentHeartsKey, hearts.clamp(0, maxHearts));
      await prefs.setInt(_lastHeartUpdateKey, DateTime.now().millisecondsSinceEpoch);

      Logger.info('하트 수동 업데이트: $hearts', tag: _tag);

      // 하트가 0이 되면 재생 타이머 시작을 위해 백그라운드 작업 재시작
      if (hearts == 0) {
        final userId = prefs.getString(_userIdKey);
        if (userId != null) {
          await startBackgroundTask(userId);
        }
      }
    } catch (e, stackTrace) {
      Logger.error(
        '하트 수동 업데이트 실패',
        error: e,
        stackTrace: stackTrace,
        tag: _tag,
      );
    }
  }

  /// 현재 하트 수 가져오기
  static Future<int> getCurrentHearts() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 먼저 백그라운드에서 재생된 하트 확인
      await regenerateHearts();

      return prefs.getInt(_currentHeartsKey) ?? maxHearts;
    } catch (e, stackTrace) {
      Logger.error(
        '현재 하트 수 가져오기 실패',
        error: e,
        stackTrace: stackTrace,
        tag: _tag,
      );
      return maxHearts;
    }
  }

  /// 다음 하트 재생까지 남은 시간
  static Future<Duration?> getTimeToNextHeart() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final currentHearts = prefs.getInt(_currentHeartsKey) ?? maxHearts;
      if (currentHearts >= maxHearts) {
        return null; // 이미 최대치
      }

      final lastUpdateMillis = prefs.getInt(_lastHeartUpdateKey);
      if (lastUpdateMillis == null) {
        return heartRegenInterval; // 아직 시작 안 함
      }

      final lastUpdate = DateTime.fromMillisecondsSinceEpoch(lastUpdateMillis);
      final now = DateTime.now();
      final elapsed = now.difference(lastUpdate);

      final minutesUntilNext = heartRegenInterval.inMinutes - (elapsed.inMinutes % heartRegenInterval.inMinutes);

      return Duration(minutes: minutesUntilNext);
    } catch (e, stackTrace) {
      Logger.error(
        '다음 하트 재생 시간 계산 실패',
        error: e,
        stackTrace: stackTrace,
        tag: _tag,
      );
      return null;
    }
  }
}

// Workmanager 콜백 - 일시적으로 비활성화
// @pragma('vm:entry-point')
// void _callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     try {
//       print('[HeartRegeneration] 백그라운드 작업 실행: $task');

//       // DartPluginRegistrant 등록 (백그라운드 Isolate에서 플러그인 사용)
//       if (Platform.isAndroid) {
//         DartPluginRegistrant.ensureInitialized();
//       }

//       // 하트 재생 체크
//       if (task == HeartRegenerationService._heartCheckTaskName) {
//         await HeartRegenerationService.regenerateHearts();
//       }

//       return true; // 작업 성공
//     } catch (e, stack) {
//       print('[HeartRegeneration] 백그라운드 작업 실패: $e\n$stack');
//       return false; // 작업 실패
//     }
//   });
// }

