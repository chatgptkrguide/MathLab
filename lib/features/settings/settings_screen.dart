import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/settings_provider.dart';
import '../../data/providers/auth_provider.dart';
import '../../shared/constants/constants.dart';
import '../../shared/utils/haptic_feedback.dart';

/// 설정 화면
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          '설정',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () async {
            await AppHapticFeedback.lightImpact();
            if (context.mounted) Navigator.of(context).pop();
          },
        ),
      ),
      body: ListView(
        children: [
          // 일반 설정
          _buildSection(
            title: '일반',
            children: [
              _SettingItem(
                icon: Icons.notifications,
                title: '알림',
                subtitle: '학습 리마인더 및 알림',
                value: settings.notificationsEnabled,
                onChanged: (value) async {
                  await AppHapticFeedback.lightImpact();
                  await ref.read(settingsProvider.notifier).toggleNotifications();
                },
              ),
              _SettingItem(
                icon: Icons.volume_up,
                title: '사운드',
                subtitle: '효과음 및 배경음악',
                value: settings.soundEnabled,
                onChanged: (value) async {
                  await AppHapticFeedback.lightImpact();
                  await ref.read(settingsProvider.notifier).toggleSound();
                },
              ),
              _SettingItem(
                icon: Icons.vibration,
                title: '햅틱 피드백',
                subtitle: '터치 시 진동',
                value: settings.hapticEnabled,
                onChanged: (value) async {
                  await AppHapticFeedback.lightImpact();
                  await ref.read(settingsProvider.notifier).toggleHaptic();
                },
              ),
            ],
          ),

          // 화면 설정
          _buildSection(
            title: '화면',
            children: [
              _SettingItem(
                icon: Icons.dark_mode,
                title: '다크 모드',
                subtitle: '어두운 테마 사용',
                value: settings.darkModeEnabled,
                onChanged: (value) async {
                  await AppHapticFeedback.lightImpact();
                  await ref.read(settingsProvider.notifier).toggleDarkMode();
                },
              ),
            ],
          ),

          // 언어
          _buildSection(
            title: '언어',
            children: [
              _SettingListItem(
                icon: Icons.language,
                title: '언어 설정',
                value: _getLanguageName(settings.language),
                onTap: () async {
                  await AppHapticFeedback.lightImpact();
                  // TODO: 언어 선택 다이얼로그 표시
                },
              ),
            ],
          ),

          // 계정
          _buildSection(
            title: '계정',
            children: [
              _SettingListItem(
                icon: Icons.logout,
                title: '로그아웃',
                value: '',
                onTap: () async {
                  await AppHapticFeedback.lightImpact();
                  _showLogoutDialog(context, ref);
                },
              ),
              _SettingListItem(
                icon: Icons.delete_forever,
                title: '계정 삭제',
                value: '',
                textColor: AppColors.error,
                onTap: () async {
                  await AppHapticFeedback.lightImpact();
                  _showDeleteAccountDialog(context, ref);
                },
              ),
            ],
          ),

          // 앱 정보
          _buildSection(
            title: '정보',
            children: [
              _SettingListItem(
                icon: Icons.info,
                title: '버전',
                value: '1.0.0',
                onTap: null,
              ),
              _SettingListItem(
                icon: Icons.privacy_tip,
                title: '개인정보 처리방침',
                value: '',
                onTap: () async {
                  await AppHapticFeedback.lightImpact();
                  // TODO: 개인정보 처리방침 표시
                },
              ),
              _SettingListItem(
                icon: Icons.description,
                title: '이용약관',
                value: '',
                onTap: () async {
                  await AppHapticFeedback.lightImpact();
                  // TODO: 이용약관 표시
                },
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingXL),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.paddingL,
            AppDimensions.paddingL,
            AppDimensions.paddingL,
            AppDimensions.paddingS,
          ),
          child: Text(
            title,
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          color: AppColors.surface,
          child: Column(children: children),
        ),
      ],
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'ko':
        return '한국어';
      case 'en':
        return 'English';
      default:
        return '한국어';
    }
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) {
                Navigator.of(context).pop();
                // TODO: 로그인 화면으로 이동
              }
            },
            child: const Text('로그아웃', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('계정 삭제'),
        content: const Text(
          '계정을 삭제하면 모든 데이터가 영구적으로 삭제됩니다.\n정말 계정을 삭제하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              // TODO: 계정 삭제 로직
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('삭제', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

/// 토글 설정 아이템
class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _SettingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }
}

/// 리스트 설정 아이템
class _SettingListItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? textColor;
  final VoidCallback? onTap;

  const _SettingListItem({
    required this.icon,
    required this.title,
    required this.value,
    this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppColors.primary),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      trailing: value.isNotEmpty
          ? Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          : const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}
