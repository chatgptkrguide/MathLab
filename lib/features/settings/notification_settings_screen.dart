import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/constants/constants.dart';

/// 알림 설정 화면
/// - 알림 유형별 ON/OFF 설정
/// - 알림 시간 설정
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

            // 학습 알림 섹션
            _buildSectionHeader('학습 알림'),
            _buildSwitchTile(
              icon: Icons.access_alarm,
              title: '일일 학습 알림',
              subtitle: '매일 설정한 시간에 학습 알림을 보내드립니다',
              value: _dailyReminder,
              onChanged: (value) {
                setState(() => _dailyReminder = value);
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
              },
            ),

            const Divider(height: 32),

            // 성과 알림 섹션
            _buildSectionHeader('성과 알림'),
            _buildSwitchTile(
              icon: Icons.emoji_events,
              title: '업적 알림',
              subtitle: '새로운 업적을 달성했을 때 알려드립니다',
              value: _achievementAlert,
              onChanged: (value) {
                setState(() => _achievementAlert = value);
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

            // 리포트 섹션
            _buildSectionHeader('리포트'),
            _buildSwitchTile(
              icon: Icons.bar_chart,
              title: '주간 리포트',
              subtitle: '매주 학습 현황 리포트를 보내드립니다',
              value: _weeklyReport,
              onChanged: (value) {
                setState(() => _weeklyReport = value);
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
