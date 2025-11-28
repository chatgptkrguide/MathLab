import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import 'notification_service.dart';
import '../../shared/utils/logger.dart';

/// 활동 기반 알림 서비스
/// 비활동 추적, 성취 알림, 사용자 설정 기반 알림 관리
class ActivityNotificationService {
  // 싱글톤 패턴
  static final ActivityNotificationService _instance =
      ActivityNotificationService._internal();
  factory ActivityNotificationService() => _instance;
  ActivityNotificationService._internal();

  // 기본 알림 서비스
  final NotificationService _notificationService = NotificationService();

  // SharedPreferences 키
  static const String _settingsKey = 'notification_settings';
  static const String _historyKey = 'notification_history';
  static const String _lastActivityKey = 'last_activity_date';

  /// 알림 설정 저장
  Future<void> saveSettings(NotificationSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(settings.toJson());
      await prefs.setString('${_settingsKey}_${settings.userId}', json);

      // 설정 변경 시 알림 다시 스케줄링
      await _rescheduleNotifications(settings);

      Logger.info(
        'Notification settings saved for user: ${settings.userId}',
        tag: 'ActivityNotificationService',
      );
    } catch (e) {
      Logger.error('Failed to save notification settings', error: e);
    }
  }

  /// 알림 설정 로드
  Future<NotificationSettings?> getSettings(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('${_settingsKey}_$userId');

      if (json == null) {
        // 기본 설정 생성 및 저장
        final defaultSettings = NotificationSettings(userId: userId);
        await saveSettings(defaultSettings);
        return defaultSettings;
      }

      final map = jsonDecode(json) as Map<String, dynamic>;
      return NotificationSettings.fromJson(map);
    } catch (e) {
      Logger.error('Failed to load notification settings', error: e);
      return null;
    }
  }

  /// 마지막 활동 시간 저장
  Future<void> recordActivity(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        '${_lastActivityKey}_$userId',
        DateTime.now().toIso8601String(),
      );

      // 비활동 알림 재스케줄
      final settings = await getSettings(userId);
      if (settings != null && settings.isEnabled(NotificationType.inactivity)) {
        await _scheduleInactivityNotification(userId, settings.inactivityDays);
      }

      Logger.info(
        'Activity recorded for user: $userId',
        tag: 'ActivityNotificationService',
      );
    } catch (e) {
      Logger.error('Failed to record activity', error: e);
    }
  }

  /// 마지막 활동 시간 로드
  Future<DateTime?> getLastActivity(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateStr = prefs.getString('${_lastActivityKey}_$userId');

      if (dateStr == null) return null;
      return DateTime.parse(dateStr);
    } catch (e) {
      Logger.error('Failed to get last activity', error: e);
      return null;
    }
  }

  /// 비활동 기간 계산 (일 단위)
  Future<int> getInactiveDays(String userId) async {
    final lastActivity = await getLastActivity(userId);
    if (lastActivity == null) return 0;

    final now = DateTime.now();
    return now.difference(lastActivity).inDays;
  }

  /// 설정에 따라 알림 재스케줄링
  Future<void> _rescheduleNotifications(NotificationSettings settings) async {
    // 모든 알림 취소
    await _notificationService.cancelAllNotifications();

    // 일일 리마인더
    if (settings.isEnabled(NotificationType.dailyReminder)) {
      await _scheduleDailyReminder(
        settings.userId,
        settings.dailyReminderHour,
        settings.dailyReminderMinute,
      );
    }

    // 스트릭 위험 알림 (기본 NotificationService 사용)
    if (settings.isEnabled(NotificationType.streakRisk)) {
      await _notificationService.scheduleStreakReminder(
        currentStreak: 1, // 실제 값은 UserProvider에서 가져와야 함
        hour: settings.dailyReminderHour,
      );
    }

    // 일일 챌린지
    if (settings.isEnabled(NotificationType.dailyChallenge)) {
      await _notificationService.scheduleDailyChallengeNotification();
    }

    // 리그 업데이트
    if (settings.isEnabled(NotificationType.leagueUpdate)) {
      await _notificationService.scheduleLeagueEndNotification();
    }

    // 비활동 알림
    if (settings.isEnabled(NotificationType.inactivity)) {
      await _scheduleInactivityNotification(
        settings.userId,
        settings.inactivityDays,
      );
    }
  }

  /// 일일 학습 리마인더 스케줄링
  Future<void> _scheduleDailyReminder(
    String userId,
    int hour,
    int minute,
  ) async {
    try {
      // TODO: 기존 NotificationService에 시간 커스터마이징 추가
      // 임시로 scheduleStreakReminder 사용
      Logger.info(
        'Daily reminder scheduled at $hour:$minute',
        tag: 'ActivityNotificationService',
      );
    } catch (e) {
      Logger.error('Failed to schedule daily reminder', error: e);
    }
  }

  /// 비활동 알림 스케줄링
  Future<void> _scheduleInactivityNotification(
    String userId,
    int days,
  ) async {
    try {
      final lastActivity = await getLastActivity(userId);
      if (lastActivity == null) return;

      final nextNotification = lastActivity.add(Duration(days: days));
      final now = DateTime.now();

      if (nextNotification.isAfter(now)) {
        // TODO: 특정 시간에 알림 스케줄링 기능 구현
        Logger.info(
          'Inactivity notification scheduled for $nextNotification',
          tag: 'ActivityNotificationService',
        );
      } else {
        // 이미 비활동 기간이 지남 - 즉시 알림
        await _sendInactivityNotification(userId, days);
      }
    } catch (e) {
      Logger.error('Failed to schedule inactivity notification', error: e);
    }
  }

  /// 비활동 알림 즉시 전송
  Future<void> _sendInactivityNotification(String userId, int days) async {
    try {
      // TODO: FCM을 통한 푸시 알림 전송 (백엔드 필요)
      // 로컬 알림으로 대체

      final history = NotificationHistory(
        id: '${userId}_inactivity_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        type: NotificationType.inactivity,
        title: '🤔 오랜만이에요!',
        body: '$days일 동안 학습하지 않았어요. 오늘 다시 시작해볼까요?',
        sentAt: DateTime.now(),
      );

      await _saveHistory(history);

      Logger.info(
        'Inactivity notification sent to user: $userId',
        tag: 'ActivityNotificationService',
      );
    } catch (e) {
      Logger.error('Failed to send inactivity notification', error: e);
    }
  }

  /// 성취 알림 전송 (레벨업, 뱃지 획득 등)
  Future<void> sendAchievementNotification({
    required String userId,
    required String title,
    required String body,
  }) async {
    try {
      final settings = await getSettings(userId);
      if (settings == null ||
          !settings.isEnabled(NotificationType.achievement)) {
        return;
      }

      final history = NotificationHistory(
        id: '${userId}_achievement_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        type: NotificationType.achievement,
        title: title,
        body: body,
        sentAt: DateTime.now(),
      );

      await _saveHistory(history);

      // TODO: 실제 로컬 알림 또는 FCM 전송

      Logger.info(
        'Achievement notification sent: $title',
        tag: 'ActivityNotificationService',
      );
    } catch (e) {
      Logger.error('Failed to send achievement notification', error: e);
    }
  }

  /// 하트 재생 알림
  Future<void> sendHeartRecoveryNotification(String userId) async {
    try {
      final settings = await getSettings(userId);
      if (settings == null ||
          !settings.isEnabled(NotificationType.heartRecovery)) {
        return;
      }

      await _notificationService.scheduleHeartRecoveryNotification();

      final history = NotificationHistory(
        id: '${userId}_heart_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        type: NotificationType.heartRecovery,
        title: '❤️ 하트가 재생되었어요!',
        body: '이제 다시 학습할 수 있어요. 문제를 풀러 가볼까요?',
        sentAt: DateTime.now(),
      );

      await _saveHistory(history);

      Logger.info(
        'Heart recovery notification sent',
        tag: 'ActivityNotificationService',
      );
    } catch (e) {
      Logger.error('Failed to send heart recovery notification', error: e);
    }
  }

  /// 알림 히스토리 저장
  Future<void> _saveHistory(NotificationHistory history) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '${_historyKey}_${history.userId}';

      // 기존 히스토리 로드
      final existing = await getHistory(history.userId);
      existing.add(history);

      // 최근 30개만 유지
      if (existing.length > 30) {
        existing.removeRange(0, existing.length - 30);
      }

      // 저장
      final jsonList = existing.map((h) => h.toJson()).toList();
      await prefs.setString(key, jsonEncode(jsonList));

      Logger.info('Notification history saved', tag: 'ActivityNotificationService');
    } catch (e) {
      Logger.error('Failed to save notification history', error: e);
    }
  }

  /// 알림 히스토리 로드
  Future<List<NotificationHistory>> getHistory(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '${_historyKey}_$userId';
      final jsonStr = prefs.getString(key);

      if (jsonStr == null) return [];

      final jsonList = jsonDecode(jsonStr) as List<dynamic>;
      return jsonList
          .map((json) => NotificationHistory.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      Logger.error('Failed to load notification history', error: e);
      return [];
    }
  }

  /// 알림 열람 처리
  Future<void> markAsOpened(String userId, String notificationId) async {
    try {
      final history = await getHistory(userId);
      final index = history.indexWhere((h) => h.id == notificationId);

      if (index != -1) {
        history[index] = history[index].copyWith(
          opened: true,
          openedAt: DateTime.now(),
        );

        // 저장
        final prefs = await SharedPreferences.getInstance();
        final key = '${_historyKey}_$userId';
        final jsonList = history.map((h) => h.toJson()).toList();
        await prefs.setString(key, jsonEncode(jsonList));

        Logger.info('Notification marked as opened: $notificationId',
            tag: 'ActivityNotificationService');
      }
    } catch (e) {
      Logger.error('Failed to mark notification as opened', error: e);
    }
  }

  /// 특정 타입 알림 토글
  Future<void> toggleNotificationType(
    String userId,
    NotificationType type,
  ) async {
    try {
      final settings = await getSettings(userId);
      if (settings == null) return;

      final newSettings = settings.toggleType(type);
      await saveSettings(newSettings);

      Logger.info(
        'Notification type toggled: ${type.name}',
        tag: 'ActivityNotificationService',
      );
    } catch (e) {
      Logger.error('Failed to toggle notification type', error: e);
    }
  }

  /// 일일 리마인더 시간 변경
  Future<void> updateDailyReminderTime(
    String userId,
    int hour,
    int minute,
  ) async {
    try {
      final settings = await getSettings(userId);
      if (settings == null) return;

      final newSettings = settings.copyWith(
        dailyReminderHour: hour,
        dailyReminderMinute: minute,
      );
      await saveSettings(newSettings);

      Logger.info(
        'Daily reminder time updated: $hour:$minute',
        tag: 'ActivityNotificationService',
      );
    } catch (e) {
      Logger.error('Failed to update daily reminder time', error: e);
    }
  }

  /// 비활동 알림 기준일 변경
  Future<void> updateInactivityDays(String userId, int days) async {
    try {
      final settings = await getSettings(userId);
      if (settings == null) return;

      final newSettings = settings.copyWith(inactivityDays: days);
      await saveSettings(newSettings);

      Logger.info(
        'Inactivity days updated: $days',
        tag: 'ActivityNotificationService',
      );
    } catch (e) {
      Logger.error('Failed to update inactivity days', error: e);
    }
  }

  /// 모든 알림 비활성화
  Future<void> disableAllNotifications(String userId) async {
    try {
      final settings = await getSettings(userId);
      if (settings == null) return;

      final disabledTypes = {
        for (var type in NotificationType.values) type: false
      };

      final newSettings = settings.copyWith(enabledTypes: disabledTypes);
      await saveSettings(newSettings);
      await _notificationService.cancelAllNotifications();

      Logger.info(
        'All notifications disabled',
        tag: 'ActivityNotificationService',
      );
    } catch (e) {
      Logger.error('Failed to disable all notifications', error: e);
    }
  }

  /// 모든 알림 활성화
  Future<void> enableAllNotifications(String userId) async {
    try {
      final settings = await getSettings(userId);
      if (settings == null) return;

      final enabledTypes = {
        for (var type in NotificationType.values) type: true
      };

      final newSettings = settings.copyWith(enabledTypes: enabledTypes);
      await saveSettings(newSettings);

      Logger.info(
        'All notifications enabled',
        tag: 'ActivityNotificationService',
      );
    } catch (e) {
      Logger.error('Failed to enable all notifications', error: e);
    }
  }
}
