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
                  _showLanguageDialog(context, ref, settings);
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
                  _showPrivacyPolicyDialog(context);
                },
              ),
              _SettingListItem(
                icon: Icons.description,
                title: '이용약관',
                value: '',
                onTap: () async {
                  await AppHapticFeedback.lightImpact();
                  _showTermsDialog(context);
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
                // 앱 재시작 (스플래시 화면으로 이동)
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
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
              // 계정 삭제 로직
              await ref.read(authProvider.notifier).deleteAccount();
              if (context.mounted) {
                Navigator.of(context).pop();
                // 앱 재시작 (스플래시 화면으로 이동)
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              }
            },
            child: const Text('삭제', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('언어 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('한국어'),
              value: 'ko',
              groupValue: settings.language,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).setLanguage(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: settings.language,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).setLanguage(value);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('개인정보 처리방침'),
        content: const SingleChildScrollView(
          child: Text(
            'MathLab 개인정보 처리방침\n\n'
            '1. 수집하는 개인정보\n'
            '- 이메일 주소, 닉네임, 프로필 사진\n'
            '- 학습 진행 상황 및 통계 데이터\n\n'
            '2. 개인정보의 이용 목적\n'
            '- 서비스 제공 및 개선\n'
            '- 학습 분석 및 맞춤형 콘텐츠 제공\n\n'
            '3. 개인정보 보유 및 이용기간\n'
            '- 회원 탈퇴 시까지\n\n'
            '4. 개인정보의 제3자 제공\n'
            '- 원칙적으로 제3자에게 제공하지 않습니다\n\n'
            '5. 개인정보 보호책임자\n'
            '- 이메일: privacy@mathlab.com\n\n'
            '※ 본 방침은 2024년 1월 1일부터 시행됩니다.',
            style: TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이용약관'),
        content: const SingleChildScrollView(
          child: Text(
            'MathLab 이용약관\n\n'
            '제1조 (목적)\n'
            '본 약관은 MathLab이 제공하는 서비스의 이용과 관련하여 '
            '회사와 이용자의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.\n\n'
            '제2조 (서비스의 내용)\n'
            '1. 온라인 수학 학습 콘텐츠 제공\n'
            '2. 학습 진도 관리 및 통계 제공\n'
            '3. 게이미피케이션 요소를 통한 학습 동기 부여\n\n'
            '제3조 (회원의 의무)\n'
            '1. 회원은 본 약관 및 관련 법령을 준수해야 합니다\n'
            '2. 부정한 방법으로 서비스를 이용해서는 안 됩니다\n\n'
            '제4조 (서비스 이용제한)\n'
            '회사는 다음의 경우 서비스 이용을 제한할 수 있습니다:\n'
            '1. 타인의 정보 도용\n'
            '2. 서비스 운영 방해 행위\n'
            '3. 관련 법령 위반\n\n'
            '제5조 (면책조항)\n'
            '회사는 천재지변 등 불가항력적 사유로 인한 서비스 제공 불가에 대해 '
            '책임을 지지 않습니다.\n\n'
            '※ 본 약관은 2024년 1월 1일부터 시행됩니다.',
            style: TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
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
