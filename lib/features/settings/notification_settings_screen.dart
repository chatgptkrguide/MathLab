import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/constants/constants.dart';
import '../../data/providers/user/user_provider.dart';

/// Notification settings screen
/// - Per-type ON/OFF toggles
/// - Reminder time picker
class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  bool _dailyReminder = true;
  bool _streakReminder = true;
  bool _achievementAlert = true;
  bool _leagueUpdate = false;
  bool _weeklyReport = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final user = ref.read(userProvider);
    if (user != null) {
      setState(() {
        _dailyReminder = user.dailyReminderEnabled;
        _streakReminder = user.streakReminderEnabled;
        _achievementAlert = user.achievementAlertEnabled;
        _weeklyReport = user.weeklyReportEnabled;
        _reminderTime = TimeOfDay(hour: user.reminderHour, minute: user.reminderMinute);
      });
    }
  }

  void _saveSettings({
    bool? dailyReminderEnabled,
    int? reminderHour,
    int? reminderMinute,
    bool? streakReminderEnabled,
    bool? achievementAlertEnabled,
    bool? weeklyReportEnabled,
  }) {
    ref.read(userProvider.notifier).updateNotificationSettings(
      dailyReminderEnabled: dailyReminderEnabled,
      reminderHour: reminderHour,
      reminderMinute: reminderMinute,
      streakReminderEnabled: streakReminderEnabled,
      achievementAlertEnabled: achievementAlertEnabled,
      weeklyReportEnabled: weeklyReportEnabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('알림 설정'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppDimensions.paddingMedium),

            _buildSectionHeader('학습 알림'),
            _buildSwitchTile(
              icon: Icons.access_alarm,
              title: '일일 학습 알림',
              subtitle: '매일 설정한 시간에 학습 알림을 보내드립니다',
              value: _dailyReminder,
              onChanged: (value) {
                setState(() => _dailyReminder = value);
                _saveSettings(dailyReminderEnabled: value);
              },
            ),
            if (_dailyReminder)
              _buildTimePicker(),
            _buildSwitchTile(
              icon: Icons.local_fire_department,
              title: '스트릭 알림',
              subtitle: '연속 학습이 끊어지기 전에 알려드립니다',
              value: _streakReminder,
              onChanged: (value) {
                setState(() => _streakReminder = value);
                _saveSettings(streakReminderEnabled: value);
              },
            ),

            const Divider(height: 32),

            _buildSectionHeader('성과 알림'),
            _buildSwitchTile(
              icon: Icons.emoji_events,
              title: '업적 알림',
              subtitle: '새로운 업적을 달성했을 때 알려드립니다',
              value: _achievementAlert,
              onChanged: (value) {
                setState(() => _achievementAlert = value);
                _saveSettings(achievementAlertEnabled: value);
              },
            ),
            _buildSwitchTile(
              icon: Icons.leaderboard,
              title: '리그 업데이트',
              subtitle: '리그 순위 변동 시 알려드립니다',
              value: _leagueUpdate,
              onChanged: (value) {
                setState(() => _leagueUpdate = value);
              },
            ),

            const Divider(height: 32),

            _buildSectionHeader('리포트'),
            _buildSwitchTile(
              icon: Icons.bar_chart,
              title: '주간 리포트',
              subtitle: '매주 학습 현황 리포트를 보내드립니다',
              value: _weeklyReport,
              onChanged: (value) {
                setState(() => _weeklyReport = value);
                _saveSettings(weeklyReportEnabled: value);
              },
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLarge,
        vertical: AppDimensions.paddingSmall,
      ),
      child: Text(
        title,
        style: AppTextStyles.titleSmall.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.mathBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        ),
        child: Icon(icon, color: AppColors.mathBlue, size: 22),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppColors.mathGreen,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLarge,
        vertical: AppDimensions.paddingXSmall,
      ),
    );
  }

  Widget _buildTimePicker() {
    return ListTile(
      leading: const SizedBox(width: 40),
      title: Text(
        '알림 시간',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: TextButton(
        onPressed: () async {
          final time = await showTimePicker(
            context: context,
            initialTime: _reminderTime,
          );
          if (time != null) {
            setState(() => _reminderTime = time);
            _saveSettings(reminderHour: time.hour, reminderMinute: time.minute);
          }
        },
        child: Text(
          _reminderTime.format(context),
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.mathBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLarge,
      ),
    );
  }
}
