import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/constants.dart';
import '../../shared/widgets/layout/adaptive_app_header.dart';
import '../../data/providers/user/user_provider.dart';
import '../profile/edit_profile_screen.dart';
import 'notification_settings_screen.dart';
import '../legal/terms_of_service_screen.dart';
import '../legal/privacy_policy_screen.dart';
import 'widgets/widgets.dart';
import 'dialogs/dialogs.dart';
import '../admin/admin_shell_screen.dart';
import '../../core/config/env_config.dart';
import '../../data/providers/infrastructure/feature_flag_provider.dart';

/// 설정 화면 (간소화)
/// - 닉네임 변경
/// - 알림 설정
/// - 앱 정보
/// - 로그아웃 / 계정 탈퇴
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AdaptiveAppHeader(
              title: '설정',
              gradientColors: AppColors.headerBlueGradient,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              titleAlignment: MainAxisAlignment.spaceBetween,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded,
                    color: AppColors.headerText, size: 28),
                onPressed: () {
                  if (context.mounted) Navigator.of(context).pop();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMedium,
                  vertical: AppDimensions.paddingSmall,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 사용자 정보
                    UserInfoSection(
                      user: user,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const EditProfileScreen()),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.spacing20),

                    // 계정
                    const SectionHeader(
                      title: '계정',
                      accentColor: AppColors.mathBlue,
                    ),
                    const SizedBox(height: AppDimensions.spacing8),
                    _buildSettingsCard(
                      children: [
                        SettingTile(
                          icon: Icons.person_outline,
                          title: '닉네임 변경',
                          subtitle: user?.displayName ?? '설정되지 않음',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const EditProfileScreen()),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.spacing20),

                    // 알림
                    const SectionHeader(
                      title: '알림',
                      accentColor: AppColors.mathOrange,
                    ),
                    const SizedBox(height: AppDimensions.spacing8),
                    _buildSettingsCard(
                      children: [
                        SettingTile(
                          icon: Icons.notifications_outlined,
                          title: '알림 설정',
                          subtitle: '알림 타입 및 시간 설정',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const NotificationSettingsScreen()),
                          ),
                        ),
                      ],
                    ),

                    // 관리자 (admin만)
                    if (user?.isAdmin == true) ...[
                      const SizedBox(height: AppDimensions.spacing20),
                      const SectionHeader(
                        title: '관리자',
                        accentColor: AppColors.mathGreen,
                      ),
                      const SizedBox(height: AppDimensions.spacing8),
                      _buildSettingsCard(
                        children: [
                          SettingTile(
                            icon: Icons.admin_panel_settings_outlined,
                            title: '관리자 패널',
                            subtitle: '콘텐츠 및 사용자 관리',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const AdminShellScreen()),
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Feature Flags (개발 전용)
                    if (!EnvConfig.isProduction) ...[
                      const SizedBox(height: AppDimensions.spacing20),
                      const SectionHeader(
                        title: 'Feature Flags',
                        accentColor: AppColors.mathOrange,
                      ),
                      const SizedBox(height: AppDimensions.spacing8),
                      _FeatureFlagsSection(),
                    ],

                    const SizedBox(height: AppDimensions.spacing20),

                    // 정보
                    const SectionHeader(
                      title: '정보',
                      accentColor: AppColors.tealGreen,
                    ),
                    const SizedBox(height: AppDimensions.spacing8),
                    _buildSettingsCard(
                      children: [
                        SettingTile(
                          icon: Icons.info_outline,
                          title: '앱 정보',
                          subtitle: 'v1.0.0',
                          onTap: () => _showAboutDialog(context),
                        ),
                        const _SettingDivider(),
                        SettingTile(
                          icon: Icons.description_outlined,
                          title: '이용약관',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const TermsOfServiceScreen()),
                          ),
                        ),
                        const _SettingDivider(),
                        SettingTile(
                          icon: Icons.privacy_tip_outlined,
                          title: '개인정보 처리방침',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const PrivacyPolicyScreen()),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.spacing20),

                    // 계정 관리
                    const SectionHeader(
                      title: '계정 관리',
                      accentColor: AppColors.mathRed,
                    ),
                    const SizedBox(height: AppDimensions.spacing8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.mathRed.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.mathRed.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Column(
                        children: [
                          SettingTile(
                            icon: Icons.logout,
                            title: '로그아웃',
                            titleColor: AppColors.mathRed,
                            onTap: () => showDialog(
                              context: context,
                              builder: (_) => const LogoutDialog(),
                            ),
                          ),
                          Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                            color: AppColors.mathRed.withValues(alpha: 0.12),
                          ),
                          SettingTile(
                            icon: Icons.delete_outline,
                            title: '계정 탈퇴',
                            titleColor: AppColors.mathRed,
                            onTap: () => showDialog(
                              context: context,
                              builder: (_) => const DeleteAccountDialog(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'MathLab',
      applicationVersion: '1.0.0',
      applicationIcon: Image.asset(
        'assets/icons/gomath_logo_small.png',
        width: 48,
        height: 48,
        errorBuilder: (_, __, ___) => const Text('M',
            style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: AppColors.mathBlue)),
      ),
      children: [
        Text('매일 5분, 수학이 쉬워진다',
            style: AppTextStyles.titleMedium),
        const SizedBox(height: AppDimensions.spacing16),
        Text('게이미피케이션을 통한 재미있는 수학 학습 앱',
            style: AppTextStyles.bodyMedium),
      ],
    );
  }
}

/// Feature Flags 섹션 (개발 전용)
class _FeatureFlagsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flags = ref.watch(featureFlagProvider);
    final notifier = ref.read(featureFlagProvider.notifier);

    final flagItems = {
      'hearts_enabled': flags.heartsEnabled ? 'ON' : 'OFF',
      'srs_enabled': flags.srsEnabled ? 'ON' : 'OFF',
      'league_enabled': flags.leagueEnabled ? 'ON' : 'OFF',
      'daily_challenge_enabled': flags.dailyChallengeEnabled ? 'ON' : 'OFF',
      'premium_enabled': flags.premiumEnabled ? 'ON' : 'OFF',
    };

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ...flagItems.entries.map((entry) => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key,
                        style: const TextStyle(
                            fontSize: 13, fontFamily: 'monospace')),
                    Text(entry.value,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: entry.value == 'ON'
                              ? AppColors.mathGreen
                              : AppColors.mathRed,
                        )),
                  ],
                ),
              )),
          const _SettingDivider(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () async {
                  await notifier.refresh();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Feature flags refreshed'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingDivider extends StatelessWidget {
  const _SettingDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: AppColors.borderLight,
    );
  }
}
