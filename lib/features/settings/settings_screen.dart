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
/// - 사용자 정보
/// - 설정 (닉네임 변경, 알림 설정)
/// - 앱 정보 + 로그아웃/탈퇴
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
                    // 섹션 1: 사용자 정보
                    UserInfoSection(
                      user: user,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const EditProfileScreen()),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.spacing20),

                    // 섹션 2: 설정
                    const SectionHeader(
                      title: '설정',
                      accentColor: AppColors.mathBlue,
                    ),
                    const SizedBox(height: AppDimensions.spacing8),
                    _buildSettingsCard(
                      children: [
                        SettingTile(
                          icon: Icons.person_outline,
                          title: '닉네임 변경',
                          subtitle: user?.displayName ?? '설정되지 않음',
                          trailing: const SizedBox.shrink(),
                          onTap: () => _showNicknameDialog(
                              context, ref, user?.displayName),
                        ),
                        const _SettingDivider(),
                        SettingTile(
                          icon: Icons.notifications_outlined,
                          title: '알림 설정',
                          subtitle: user?.dailyReminderEnabled == true
                              ? '알림 켜짐'
                              : '알림 꺼짐',
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

                    // Feature Flags (관리자 + 개발 환경 전용)
                    if (user?.isAdmin == true && !EnvConfig.isProduction) ...[
                      const SizedBox(height: AppDimensions.spacing20),
                      const SectionHeader(
                        title: 'Feature Flags',
                        accentColor: AppColors.mathOrange,
                      ),
                      const SizedBox(height: AppDimensions.spacing8),
                      _FeatureFlagsSection(),
                    ],

                    const SizedBox(height: AppDimensions.spacing20),

                    // 섹션 3: 앱 정보 + 로그아웃/탈퇴
                    const SectionHeader(
                      title: '앱 정보',
                      accentColor: AppColors.tealGreen,
                    ),
                    const SizedBox(height: AppDimensions.spacing8),
                    _buildSettingsCard(
                      children: [
                        SettingTile(
                          icon: Icons.info_outline,
                          title: '앱 정보',
                          subtitle: 'v1.0.0',
                          trailing: const SizedBox.shrink(),
                          onTap: () => _showAppInfoDialog(context),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.spacing24),

                    const SectionHeader(
                      title: '계정',
                      accentColor: AppColors.mathRed,
                    ),

                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingMedium,
                      ),
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
                            trailing: const SizedBox.shrink(),
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
                            trailing: const SizedBox.shrink(),
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

  void _showNicknameDialog(
      BuildContext context, WidgetRef ref, String? currentName) {
    final controller = TextEditingController(text: currentName);
    String? errorText;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            8,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDDDDD),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '닉네임 변경',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '2글자 이상 입력해주세요',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: '새 닉네임 입력',
                  hintStyle: TextStyle(
                    color: AppColors.textTertiary.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w400,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8F9FA),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.borderLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.borderLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.mathBlue, width: 1.5),
                  ),
                  errorText: errorText,
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.mathRed),
                  ),
                  suffixIcon: controller.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            controller.clear();
                            setSheetState(() {});
                          },
                          child: const Icon(Icons.close_rounded,
                              size: 18, color: AppColors.textTertiary),
                        )
                      : null,
                ),
                onChanged: (_) => setSheetState(() => errorText = null),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.borderLight),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '취소',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          final name = controller.text.trim();
                          if (name.length < 2) {
                            setSheetState(() =>
                                errorText = '닉네임은 2글자 이상이어야 합니다');
                            return;
                          }
                          await ref
                              .read(userProvider.notifier)
                              .updateProfile(displayName: name);
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mathBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '변경하기',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAppInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Image.asset(
              'assets/icons/gomath_logo_small.png',
              width: 32,
              height: 32,
              errorBuilder: (_, __, ___) => const Text('M',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.mathBlue)),
            ),
            const SizedBox(width: 12),
            const Text('MathLab'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('v1.0.0',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text('매일 5분, 수학이 쉬워진다',
                style: AppTextStyles.titleMedium),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const TermsOfServiceScreen()),
                    );
                  },
                  child: const Text('이용약관'),
                ),
                const Text(' · '),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PrivacyPolicyScreen()),
                    );
                  },
                  child: const Text('개인정보 처리방침'),
                ),
              ],
            ),
          ],
        ),
      ),
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
