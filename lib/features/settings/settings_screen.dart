import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/constants.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/user_provider.dart';
import '../auth/auth_screen.dart';
import '../profile/edit_profile_screen.dart';

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
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = '한국어';

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          '설정',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.mathBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 사용자 정보 섹션
            if (authState.currentAccount != null && !authState.isGuest)
              _buildUserInfoSection(user),

            const SizedBox(height: 8),

            // 계정 섹션
            _buildSectionHeader('계정'),
            _buildSettingTile(
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
              _buildSettingTile(
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
            _buildSettingTile(
              icon: Icons.email_outlined,
              title: '이메일 변경',
              onTap: () {
                _showEmailChangeDialog();
              },
            ),
            _buildSettingTile(
              icon: Icons.lock_outline,
              title: '비밀번호 변경',
              onTap: () {
                _showPasswordChangeDialog();
              },
            ),

            const Divider(height: 32),

            // 알림 섹션
            _buildSectionHeader('알림'),
            _buildSwitchTile(
              icon: Icons.notifications_outlined,
              title: '푸시 알림',
              subtitle: '학습 리마인더 및 업데이트 알림',
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            _buildSwitchTile(
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
            _buildSectionHeader('언어 및 테마'),
            _buildSettingTile(
              icon: Icons.language,
              title: '언어',
              subtitle: _selectedLanguage,
              onTap: () {
                _showLanguageDialog();
              },
            ),
            _buildSwitchTile(
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
            _buildSectionHeader('정보'),
            _buildSettingTile(
              icon: Icons.info_outline,
              title: '앱 정보',
              subtitle: 'v1.0.0',
              onTap: () {
                _showAboutDialog();
              },
            ),
            _buildSettingTile(
              icon: Icons.description_outlined,
              title: '이용약관',
              onTap: () {
                // TODO: 이용약관 화면으로 이동
              },
            ),
            _buildSettingTile(
              icon: Icons.privacy_tip_outlined,
              title: '개인정보 처리방침',
              onTap: () {
                // TODO: 개인정보 처리방침 화면으로 이동
              },
            ),

            const Divider(height: 32),

            // 로그아웃 / 탈퇴 섹션
            _buildSettingTile(
              icon: Icons.logout,
              title: '로그아웃',
              titleColor: AppColors.mathRed,
              onTap: () {
                _showLogoutDialog();
              },
            ),
            _buildSettingTile(
              icon: Icons.delete_outline,
              title: '계정 탈퇴',
              titleColor: AppColors.mathRed,
              onTap: () {
                _showDeleteAccountDialog();
              },
            ),

            const SizedBox(height: 100), // 네비게이션 바 공간
          ],
        ),
      ),
    );
  }

  /// 사용자 정보 섹션
  Widget _buildUserInfoSection(user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.mathBlueGradient,
        ),
      ),
      child: Column(
        children: [
          // 아바타
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 3,
              ),
            ),
            child: const Center(
              child: Text(
                '👤',
                style: TextStyle(fontSize: 40),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 이름
          Text(
            user?.name ?? 'Guest',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          // 이메일
          Text(
            user?.email ?? 'guest@gomath.com',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  /// 섹션 헤더
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title,
        style: AppTextStyles.titleMedium.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  /// 설정 항목 타일
  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(
                icon,
                color: titleColor ?? AppColors.textPrimary,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: titleColor ?? AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 스위치 타일
  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.textPrimary,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.mathBlue,
          ),
        ],
      ),
    );
  }

  /// 언어 선택 다이얼로그
  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('언어 선택'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption('한국어'),
              _buildLanguageOption('English'),
              _buildLanguageOption('日本語'),
              _buildLanguageOption('中文'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLanguageOption(String language) {
    final isSelected = _selectedLanguage == language;
    return RadioListTile<String>(
      value: language,
      groupValue: _selectedLanguage,
      onChanged: (value) {
        setState(() {
          _selectedLanguage = value!;
        });
        Navigator.pop(context);
      },
      title: Text(language),
      activeColor: AppColors.mathBlue,
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

  /// 로그아웃 확인 다이얼로그
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('로그아웃'),
          content: const Text('정말 로그아웃 하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                // 로그아웃 실행
                await ref.read(authProvider.notifier).signOut();
                if (mounted) {
                  Navigator.pop(context); // 다이얼로그 닫기
                  // 로그인 화면으로 이동 (AuthWrapper가 자동으로 처리)
                }
              },
              child: const Text(
                '로그아웃',
                style: TextStyle(color: AppColors.mathRed),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 이메일 변경 다이얼로그
  void _showEmailChangeDialog() {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('이메일 변경'),
          content: TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: '새 이메일',
              hintText: 'example@email.com',
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('이메일이 변경되었습니다'),
                  ),
                );
              },
              child: const Text('변경'),
            ),
          ],
        );
      },
    );
  }

  /// 비밀번호 변경 다이얼로그
  void _showPasswordChangeDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('비밀번호 변경'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                decoration: const InputDecoration(
                  labelText: '현재 비밀번호',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                decoration: const InputDecoration(
                  labelText: '새 비밀번호',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: '새 비밀번호 확인',
                ),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                if (newPasswordController.text != confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('새 비밀번호가 일치하지 않습니다'),
                    ),
                  );
                  return;
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('비밀번호가 변경되었습니다'),
                  ),
                );
              },
              child: const Text('변경'),
            ),
          ],
        );
      },
    );
  }

  /// 계정 탈퇴 확인 다이얼로그
  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('계정 탈퇴'),
          content: const Text(
            '계정을 탈퇴하면 모든 데이터가 삭제됩니다.\n정말 탈퇴하시겠습니까?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                // TODO: 계정 탈퇴 로직 구현
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('계정 탈퇴 기능은 준비 중입니다'),
                  ),
                );
              },
              child: const Text(
                '탈퇴',
                style: TextStyle(color: AppColors.mathRed),
              ),
            ),
          ],
        );
      },
    );
  }
}
