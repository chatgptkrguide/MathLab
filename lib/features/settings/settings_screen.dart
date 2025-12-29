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
  bool _soundEnabled = true;
  bool _darkModeEnabled = false;
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
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.headerText, size: 28),
                onPressed: () {
                  if (context.mounted) Navigator.of(context).pop();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 사용자 정보 섹션
                    if (authState.currentAccount != null && !authState.isGuest)
                      UserInfoSection(user: user),

                    const SizedBox(height: 8),

                    // 계정 섹션
                    const SectionHeader(title: '계정'),
                    SettingTile(
                      icon: Icons.person_outline,
                      title: '프로필 편집',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        );
                      },
                    ),
                    if (authState.isGuest)
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
                    SettingTile(
                      icon: Icons.email_outlined,
                      title: '이메일 변경',
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => const EmailChangeDialog(),
                        );
                      },
                    ),
                    SettingTile(
                      icon: Icons.lock_outline,
                      title: '비밀번호 변경',
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => const PasswordChangeDialog(),
                        );
                      },
                    ),

                    const Divider(height: 32),

                    // 알림 섹션
                    const SectionHeader(title: '알림'),
                    SettingTile(
                      icon: Icons.notifications_outlined,
                      title: '알림 설정',
                      subtitle: '알림 타입 및 시간 설정',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationSettingsScreen(),
                          ),
                        );
                      },
                    ),
                    SettingSwitchTile(
                      icon: Icons.volume_up_outlined,
                      title: '사운드',
                      subtitle: '효과음 및 배경음악',
                      value: _soundEnabled,
                      onChanged: (value) {
                        setState(() {
                          _soundEnabled = value;
                        });
                      },
                    ),

                    const Divider(height: 32),

                    // 언어 및 테마 섹션
                    const SectionHeader(title: '언어 및 테마'),
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
                    SettingSwitchTile(
                      icon: Icons.dark_mode_outlined,
                      title: '다크 모드',
                      subtitle: '어두운 테마 사용',
                      value: _darkModeEnabled,
                      onChanged: (value) {
                        setState(() {
                          _darkModeEnabled = value;
                        });
                      },
                    ),

                    const Divider(height: 32),

                    // 정보 섹션
                    const SectionHeader(title: '정보'),
                    SettingTile(
                      icon: Icons.info_outline,
                      title: '앱 정보',
                      subtitle: 'v1.0.0',
                      onTap: () {
                        _showAboutDialog();
                      },
                    ),
                    SettingTile(
                      icon: Icons.description_outlined,
                      title: '이용약관',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TermsOfServiceScreen(),
                          ),
                        );
                      },
                    ),
                    SettingTile(
                      icon: Icons.privacy_tip_outlined,
                      title: '개인정보 처리방침',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PrivacyPolicyScreen(),
                          ),
                        );
                      },
                    ),

                    const Divider(height: 32),

                    // 학습 데이터 섹션
                    const SectionHeader(title: '학습 데이터'),
                    SettingTile(
                      icon: Icons.refresh,
                      title: '학습 초기화',
                      subtitle: '모든 학습 진행 상태를 초기화합니다',
                      titleColor: AppColors.warning,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => const ResetProgressDialog(),
                        );
                      },
                    ),

                    const Divider(height: 32),

                    // 로그아웃 / 탈퇴 섹션
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
                    SettingTile(
                      icon: Icons.delete_outline,
                      title: '계정 탈퇴',
                      titleColor: AppColors.mathRed,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => const DeleteAccountDialog(),
                        );
                      },
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

  /// 앱 정보 다이얼로그
  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'GoMath',
      applicationVersion: '1.0.0',
      applicationIcon: const Text('🧮', style: TextStyle(fontSize: 40)),
      children: [
        const Text(
          '매일 5분, 수학이 쉬워진다',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        const Text(
          '게이미피케이션을 통한 재미있는 수학 학습 앱',
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
