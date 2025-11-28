import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/models.dart';
import '../../data/providers/activity_notification_provider.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/layout/adaptive_app_header.dart';

/// 알림 설정 화면
/// 알림 타입별 on/off, 일일 리마인더 시간, 비활동 기준일 설정
class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(notificationSettingsProvider);
    final actions = ref.watch(notificationActionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            AdaptiveAppHeader(
              title: '알림 설정',
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            Expanded(
              child: settingsAsync.when(
                data: (settings) {
                  if (settings == null) {
                    return Center(
                      child: Text(
                        '알림 설정을 불러올 수 없습니다',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),

                        // 알림 타입별 설정
                        _buildSectionHeader('알림 유형'),
                        _buildNotificationTypesList(context, settings, actions),

                        const SizedBox(height: 24),

                        // 일일 리마인더 시간 설정
                        _buildSectionHeader('일일 리마인더 시간'),
                        _buildTimeSettingCard(context, settings, actions),

                        const SizedBox(height: 24),

                        // 비활동 알림 설정
                        _buildSectionHeader('비활동 알림'),
                        _buildInactivitySettingCard(context, settings, actions),

                        const SizedBox(height: 24),

                        // 전체 제어
                        _buildSectionHeader('전체 제어'),
                        _buildQuickActionsCard(context, actions),

                        const SizedBox(height: 100),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('데이터를 불러올 수 없습니다'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.invalidate(notificationSettingsProvider);
                        },
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 섹션 헤더
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  /// 알림 타입별 리스트
  Widget _buildNotificationTypesList(
    BuildContext context,
    NotificationSettings settings,
    NotificationActions actions,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: NotificationType.values.map((type) {
          final isEnabled = settings.isEnabled(type);
          final isFirst = type == NotificationType.values.first;
          final isLast = type == NotificationType.values.last;

          return Column(
            children: [
              if (!isFirst) const Divider(height: 1, indent: 56),
              _buildNotificationTypeTile(
                context,
                type,
                isEnabled,
                actions,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  /// 알림 타입 타일
  Widget _buildNotificationTypeTile(
    BuildContext context,
    NotificationType type,
    bool isEnabled,
    NotificationActions actions,
  ) {
    IconData icon;
    switch (type) {
      case NotificationType.dailyReminder:
        icon = Icons.alarm;
        break;
      case NotificationType.streakRisk:
        icon = Icons.local_fire_department;
        break;
      case NotificationType.inactivity:
        icon = Icons.snooze;
        break;
      case NotificationType.achievement:
        icon = Icons.emoji_events;
        break;
      case NotificationType.heartRecovery:
        icon = Icons.favorite;
        break;
      case NotificationType.leagueUpdate:
        icon = Icons.leaderboard;
        break;
      case NotificationType.dailyChallenge:
        icon = Icons.flag;
        break;
    }

    return SwitchListTile(
      value: isEnabled,
      onChanged: (value) async {
        await actions.toggleType(type);
      },
      title: Text(
        type.label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      secondary: Icon(icon, color: AppColors.primary),
      activeColor: AppColors.primary,
    );
  }

  /// 시간 설정 카드
  Widget _buildTimeSettingCard(
    BuildContext context,
    NotificationSettings settings,
    NotificationActions actions,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time, color: AppColors.primary),
              const SizedBox(width: 12),
              const Text(
                '리마인더 알림 시간',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => _showTimePicker(context, settings, actions),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${settings.dailyReminderHour.toString().padLeft(2, '0')}:${settings.dailyReminderMinute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.edit, color: AppColors.primary, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '매일 이 시간에 학습 리마인더 알림을 받습니다',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// 비활동 설정 카드
  Widget _buildInactivitySettingCard(
    BuildContext context,
    NotificationSettings settings,
    NotificationActions actions,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, color: AppColors.warning),
              const SizedBox(width: 12),
              const Text(
                '비활동 알림 기준일',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [1, 3, 5, 7].map((days) {
              final isSelected = settings.inactivityDays == days;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: () async {
                      await actions.updateInactivityDays(days);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.warning
                            : AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.warning
                              : AppColors.warning.withOpacity(0.3),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$days일',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Text(
            '선택한 일수 동안 활동하지 않으면 알림을 받습니다',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// 빠른 제어 카드
  Widget _buildQuickActionsCard(
    BuildContext context,
    NotificationActions actions,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.notifications_active, color: AppColors.success),
            title: const Text('모든 알림 활성화'),
            onTap: () async {
              await actions.enableAll();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('모든 알림이 활성화되었습니다'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
          ),
          const Divider(height: 1, indent: 56),
          ListTile(
            leading: Icon(Icons.notifications_off, color: AppColors.error),
            title: const Text('모든 알림 비활성화'),
            onTap: () async {
              await actions.disableAll();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('모든 알림이 비활성화되었습니다'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  /// 시간 선택 다이얼로그
  void _showTimePicker(
    BuildContext context,
    NotificationSettings settings,
    NotificationActions actions,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: settings.dailyReminderHour,
        minute: settings.dailyReminderMinute,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      await actions.updateDailyReminderTime(picked.hour, picked.minute);
    }
  }
}
