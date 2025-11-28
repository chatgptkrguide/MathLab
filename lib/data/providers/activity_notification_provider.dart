import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/activity_notification_service.dart';
import 'user_provider.dart';

/// ActivityNotificationService 싱글톤 제공
final activityNotificationServiceProvider = Provider<ActivityNotificationService>((ref) {
  return ActivityNotificationService();
});

/// 사용자별 알림 설정 제공
final notificationSettingsProvider =
    FutureProvider.autoDispose<NotificationSettings?>((ref) async {
  final user = ref.watch(userProvider);
  if (user == null) return null;

  final service = ref.watch(activityNotificationServiceProvider);
  return service.getSettings(user.id);
});

/// 사용자별 알림 히스토리 제공
final notificationHistoryProvider =
    FutureProvider.autoDispose<List<NotificationHistory>>((ref) async {
  final user = ref.watch(userProvider);
  if (user == null) return [];

  final service = ref.watch(activityNotificationServiceProvider);
  return service.getHistory(user.id);
});

/// 사용자 비활동 일수 제공
final inactiveDaysProvider = FutureProvider.autoDispose<int>((ref) async {
  final user = ref.watch(userProvider);
  if (user == null) return 0;

  final service = ref.watch(activityNotificationServiceProvider);
  return service.getInactiveDays(user.id);
});

/// 마지막 활동 시간 제공
final lastActivityProvider =
    FutureProvider.autoDispose<DateTime?>((ref) async {
  final user = ref.watch(userProvider);
  if (user == null) return null;

  final service = ref.watch(activityNotificationServiceProvider);
  return service.getLastActivity(user.id);
});

/// 알림 설정 액션 프로바이더
final notificationActionsProvider = Provider<NotificationActions>((ref) {
  final service = ref.watch(activityNotificationServiceProvider);
  final user = ref.watch(userProvider);
  return NotificationActions(service, user?.id, ref);
});

/// 알림 설정 액션 클래스
class NotificationActions {
  final ActivityNotificationService _service;
  final String? _userId;
  final Ref _ref;

  NotificationActions(this._service, this._userId, this._ref);

  /// 알림 타입 토글
  Future<void> toggleType(NotificationType type) async {
    if (_userId == null) return;

    await _service.toggleNotificationType(_userId, type);
    _ref.invalidate(notificationSettingsProvider);
  }

  /// 일일 리마인더 시간 변경
  Future<void> updateDailyReminderTime(int hour, int minute) async {
    if (_userId == null) return;

    await _service.updateDailyReminderTime(_userId, hour, minute);
    _ref.invalidate(notificationSettingsProvider);
  }

  /// 비활동 알림 기준일 변경
  Future<void> updateInactivityDays(int days) async {
    if (_userId == null) return;

    await _service.updateInactivityDays(_userId, days);
    _ref.invalidate(notificationSettingsProvider);
  }

  /// 활동 기록
  Future<void> recordActivity() async {
    if (_userId == null) return;

    await _service.recordActivity(_userId);
    _ref.invalidate(inactiveDaysProvider);
    _ref.invalidate(lastActivityProvider);
  }

  /// 성취 알림 전송
  Future<void> sendAchievementNotification({
    required String title,
    required String body,
  }) async {
    if (_userId == null) return;

    await _service.sendAchievementNotification(
      userId: _userId,
      title: title,
      body: body,
    );
    _ref.invalidate(notificationHistoryProvider);
  }

  /// 하트 재생 알림 전송
  Future<void> sendHeartRecoveryNotification() async {
    if (_userId == null) return;

    await _service.sendHeartRecoveryNotification(_userId);
    _ref.invalidate(notificationHistoryProvider);
  }

  /// 알림 열람 처리
  Future<void> markAsOpened(String notificationId) async {
    if (_userId == null) return;

    await _service.markAsOpened(_userId, notificationId);
    _ref.invalidate(notificationHistoryProvider);
  }

  /// 모든 알림 비활성화
  Future<void> disableAll() async {
    if (_userId == null) return;

    await _service.disableAllNotifications(_userId);
    _ref.invalidate(notificationSettingsProvider);
  }

  /// 모든 알림 활성화
  Future<void> enableAll() async {
    if (_userId == null) return;

    await _service.enableAllNotifications(_userId);
    _ref.invalidate(notificationSettingsProvider);
  }

  /// 특정 설정 저장
  Future<void> saveSettings(NotificationSettings settings) async {
    await _service.saveSettings(settings);
    _ref.invalidate(notificationSettingsProvider);
  }
}
