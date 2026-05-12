// 👤 User provider — settings / notifications / streak freeze / login tracking
//
// part of user_provider.dart.

// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

part of 'user_provider.dart';

extension UserSettings on User {
  /// Update user settings
  Future<void> updateSettings({
    String? preferredLanguage,
    bool? notificationsEnabled,
    bool? soundEnabled,
    int? dailyGoalMinutes,
  }) async {
    if (state == null) return;

    try {
      AppLogger.info('Updating user settings', tag: 'User');

      final updatedUser = state!.copyWith(
        preferredLanguage: preferredLanguage,
        notificationsEnabled: notificationsEnabled,
        soundEnabled: soundEnabled,
        dailyGoalMinutes: dailyGoalMinutes,
        updatedAt: DateTime.now(),
      );

      final updates = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(updatedUser.updatedAt),
      };

      if (preferredLanguage != null) updates['preferredLanguage'] = preferredLanguage;
      if (notificationsEnabled != null) updates['notificationsEnabled'] = notificationsEnabled;
      if (soundEnabled != null) updates['soundEnabled'] = soundEnabled;
      if (dailyGoalMinutes != null) updates['dailyGoalMinutes'] = dailyGoalMinutes;

      await _firestore
          .collection('users')
          .doc(state!.uid)
          .update(updates);

      state = updatedUser;
      AppLogger.info('User settings updated successfully', tag: 'User');
    } catch (e, st) {
      AppLogger.error('Failed to update settings', tag: 'User', error: e, stackTrace: st);
      throw DataException(
        message: '설정 업데이트에 실패했습니다',
        originalError: e,
        stackTrace: st,
      );
    }
  }

  /// Update notification settings
  Future<void> updateNotificationSettings({
    bool? dailyReminderEnabled,
    int? reminderHour,
    int? reminderMinute,
    bool? streakReminderEnabled,
    bool? achievementAlertEnabled,
    bool? leagueUpdateEnabled,
    bool? weeklyReportEnabled,
  }) async {
    if (state == null) return;

    try {
      AppLogger.info('Updating notification settings', tag: 'User');

      final now = DateTime.now();
      final updatedUser = state!.copyWith(
        dailyReminderEnabled: dailyReminderEnabled,
        reminderHour: reminderHour,
        reminderMinute: reminderMinute,
        streakReminderEnabled: streakReminderEnabled,
        achievementAlertEnabled: achievementAlertEnabled,
        leagueUpdateEnabled: leagueUpdateEnabled,
        weeklyReportEnabled: weeklyReportEnabled,
        updatedAt: now,
      );

      final updates = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(now),
      };

      if (dailyReminderEnabled != null) updates['dailyReminderEnabled'] = dailyReminderEnabled;
      if (reminderHour != null) updates['reminderHour'] = reminderHour;
      if (reminderMinute != null) updates['reminderMinute'] = reminderMinute;
      if (streakReminderEnabled != null) updates['streakReminderEnabled'] = streakReminderEnabled;
      if (achievementAlertEnabled != null) updates['achievementAlertEnabled'] = achievementAlertEnabled;
      if (leagueUpdateEnabled != null) updates['leagueUpdateEnabled'] = leagueUpdateEnabled;
      if (weeklyReportEnabled != null) updates['weeklyReportEnabled'] = weeklyReportEnabled;

      await _firestore
          .collection('users')
          .doc(state!.uid)
          .update(updates);

      state = updatedUser;
      AppLogger.info('Notification settings updated', tag: 'User');
    } catch (e, st) {
      AppLogger.error('Failed to update notification settings', tag: 'User', error: e, stackTrace: st);
    }
  }

  /// Update streak freeze count in Firestore
  Future<void> updateStreakFreezes(int freezes, {DateTime? lastUsedAt}) async {
    if (state == null) return;

    try {
      final now = DateTime.now();
      final updates = <String, dynamic>{
        'streakFreezes': freezes,
        'updatedAt': Timestamp.fromDate(now),
      };
      if (lastUsedAt != null) {
        updates['lastFreezeUsedAt'] = Timestamp.fromDate(lastUsedAt);
      }

      await _firestore
          .collection('users')
          .doc(state!.uid)
          .update(updates);

      state = state!.copyWith(
        streakFreezes: freezes,
        lastFreezeUsedAt: lastUsedAt,
        updatedAt: now,
      );
    } catch (e, st) {
      AppLogger.error('Failed to update streak freezes', tag: 'User', error: e, stackTrace: st);
    }
  }

  /// Update last login timestamp
  Future<void> updateLastLogin() async {
    if (state == null) return;

    try {
      final now = DateTime.now();

      final updatedUser = state!.copyWith(
        lastLoginAt: now,
        updatedAt: now,
      );

      await _firestore
          .collection('users')
          .doc(state!.uid)
          .update({
        'lastLoginAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      });

      state = updatedUser;
    } catch (e, st) {
      AppLogger.error('Failed to update last login', tag: 'User', error: e, stackTrace: st);
      // Don't throw - this is a non-critical operation
    }
  }
}
