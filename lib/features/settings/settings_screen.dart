import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/constants.dart';
import '../../shared/widgets/layout/adaptive_app_header.dart';
import '../../data/providers/auth/auth_provider.dart';
import '../../data/providers/user/user_provider.dart';
import '../auth/auth_screen.dart';
import '../profile/edit_profile_screen.dart';
import 'notification_settings_screen.dart';
import '../legal/terms_of_service_screen.dart';
import '../legal/privacy_policy_screen.dart';
import 'widgets/widgets.dart';
import 'dialogs/dialogs.dart';
import '../admin/admin_shell_screen.dart';
import '../../core/config/env_config.dart';
import '../../data/providers/infrastructure/feature_flag_provider.dart';
import '../shop/shop_screen.dart';

/// 설정 화면
/// - 계정 관리
/// - 알림 설정
/// - 언어 선택
/// - 테마 설정
/// - 로그아웃
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final bool _darkModeEnabled = false;
  String _selectedLanguage = '한국어';

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 통합 헤더 (홈 화면과 동일한 디자인)
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
                    // 사용자 정보 섹션
                    if (authState.currentAccount != null && !authState.isGuest)
                      UserInfoSection(
                        user: user,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                        ),
                      ),

                    const SizedBox(height: AppDimensions.spacing12),

                    // 계정 섹션
                    const SectionHeader(
                      title: '계정',
                      accentColor: AppColors.mathBlue,
                    ),
                    const SizedBox(height: AppDimensions.spacing8),
                    _buildSettingsCard(
                      children: [
                        SettingTile(
                          icon: Icons.person_outline,
                          title: '프로필 편집',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const EditProfileScreen(),
                              ),
                            );
                          },
                        ),
                        if (authState.isGuest) ...[
                          const _SettingDivider(),
                          SettingTile(
                            icon: Icons.login,
                            title: '회원가입 / 로그인',
                            subtitle: '게스트 계정을 연결하세요',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AuthScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                        const _SettingDivider(),
                        SettingTile(
                          icon: Icons.email_outlined,
                          title: '이메일 변경',
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  const EmailChangeDialog(),
                            );
                          },
                        ),
                        const _SettingDivider(),
                        SettingTile(
                          icon: Icons.lock_outline,
                          title: '비밀번호 변경',
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  const PasswordChangeDialog(),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.spacing20),

                    // 알림 섹션
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
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const NotificationSettingsScreen(),
                              ),
                            );
                          },
                        ),
                        const _SettingDivider(),
                        SettingSwitchTile(
                          icon: Icons.volume_up_outlined,
                          title: '사운드',
                          subtitle: '효과음 및 배경음악',
                          value: user?.soundEnabled ?? true,
                          onChanged: (value) {
                            ref.read(userProvider.notifier).updateSettings(
                              soundEnabled: value,
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.spacing20),

                    // 상점 섹션
                    const SectionHeader(
                      title: '상점',
                      accentColor: Color(0xFF6B5CE7),
                    ),
                    const SizedBox(height: AppDimensions.spacing8),
                    _buildSettingsCard(
                      children: [
                        SettingTile(
                          icon: Icons.diamond_rounded,
                          title: '젬 상점',
                          subtitle: '하트, 스트릭 보호 등 아이템 구매',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ShopScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.spacing20),

                    // 언어 및 테마 섹션
                    const SectionHeader(
                      title: '언어 및 테마',
                      accentColor: AppColors.mathPurple,
                    ),
                    const SizedBox(height: AppDimensions.spacing8),
                    _buildSettingsCard(
                      children: [
                        SettingTile(
                          icon: Icons.language,
                          title: '언어',
                          subtitle: _selectedLanguage,
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => LanguageSelectionDialog(
                                currentLanguage: _selectedLanguage,
                                onLanguageChanged: (language) {
                                  setState(() {
                                    _selectedLanguage = language;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                        const _SettingDivider(),
                        SettingSwitchTile(
                          icon: Icons.dark_mode_outlined,
                          title: '다크 모드',
                          subtitle: '어두운 테마 사용',
                          value: _darkModeEnabled,
                          onChanged: (value) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('다크 모드는 준비 중입니다'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    // 관리자 섹션 (admin만 표시)
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
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AdminShellScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],

                    // Feature Flags debug section (development only)
                    if (!EnvConfig.isProduction) ...[
                      const SizedBox(height: AppDimensions.spacing20),
                      const SectionHeader(
                        title: 'Feature Flags',
                        accentColor: AppColors.mathOrange,
                      ),
                      const SizedBox(height: AppDimensions.spacing8),
                      _buildFeatureFlagsSection(),
                    ],

                    const SizedBox(height: AppDimensions.spacing20),

                    // 정보 섹션
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
                          onTap: () {
                            _showAboutDialog();
                          },
                        ),
                        const _SettingDivider(),
                        SettingTile(
                          icon: Icons.description_outlined,
                          title: '이용약관',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const TermsOfServiceScreen(),
                              ),
                            );
                          },
                        ),
                        const _SettingDivider(),
                        SettingTile(
                          icon: Icons.privacy_tip_outlined,
                          title: '개인정보 처리방침',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PrivacyPolicyScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.spacing20),

                    // 위험 영역 - 학습 초기화, 로그아웃, 계정 탈퇴
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
                            icon: Icons.refresh,
                            title: '학습 초기화',
                            subtitle: '모든 학습 진행 상태를 초기화합니다',
                            titleColor: AppColors.warning,
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    const ResetProgressDialog(),
                              );
                            },
                          ),
                          Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                            color: AppColors.mathRed.withValues(alpha: 0.12),
                          ),
                          SettingTile(
                            icon: Icons.logout,
                            title: '로그아웃',
                            titleColor: AppColors.mathRed,
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => const LogoutDialog(),
                              );
                            },
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
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    const DeleteAccountDialog(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 100), // 네비게이션 바 공간
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Feature flags debug section (development only)
  Widget _buildFeatureFlagsSection() {
    final flags = ref.watch(featureFlagProvider);
    final notifier = ref.read(featureFlagProvider.notifier);

    final flagItems = <String, String>{
      'hearts_enabled': flags.heartsEnabled ? 'ON' : 'OFF',
      'srs_enabled': flags.srsEnabled ? 'ON' : 'OFF',
      'league_enabled': flags.leagueEnabled ? 'ON' : 'OFF',
      'daily_challenge_enabled': flags.dailyChallengeEnabled ? 'ON' : 'OFF',
      'premium_enabled': flags.premiumEnabled ? 'ON' : 'OFF',
      'max_hearts': '${flags.maxHearts}',
      'heart_regen_minutes': '${flags.heartRegenMinutes}',
      'daily_goal_xp': '${flags.dailyGoalXP}',
      'maintenance_message':
          flags.maintenanceMessage.isEmpty ? '(none)' : flags.maintenanceMessage,
      'min_app_version': flags.minAppVersion,
      'onboarding_v2_enabled': flags.onboardingV2Enabled ? 'ON' : 'OFF',
    };

    return _buildSettingsCard(
      children: [
        ...flagItems.entries.map((entry) => Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'monospace',
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    entry.value,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: entry.value == 'ON'
                          ? AppColors.mathGreen
                          : entry.value == 'OFF'
                              ? AppColors.mathRed
                              : AppColors.textSecondary,
                    ),
                  ),
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
                if (mounted) {
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
    );
  }

  /// Settings card container with white bg, borderRadius 16, subtle shadow
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

  /// 앱 정보 다이얼로그
  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'MathLab',
      applicationVersion: '1.0.0',
      applicationIcon: Image.asset(
        'assets/icons/gomath_logo_small.png',
        width: 48,
        height: 48,
        errorBuilder: (_, __, ___) => const Text('M', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.mathBlue)),
      ),
      children: [
        Text(
          '매일 5분, 수학이 쉬워진다',
          style: AppTextStyles.titleMedium,
        ),
        const SizedBox(height: AppDimensions.spacing16),
        Text(
          '게이미피케이션을 통한 재미있는 수학 학습 앱',
          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
  }
}

/// Light gray divider with inset
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
