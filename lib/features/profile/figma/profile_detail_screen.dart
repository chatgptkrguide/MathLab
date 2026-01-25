/// 👤 Profile Detail Screen
///
/// Displays user profile information with clear login status indication.
/// Shows account type, user data, and provides profile management options.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers/auth/auth_provider.dart';
import '../../../data/providers/user/user_provider.dart';
import '../../../data/models/user/user_model.dart';
import '../../../shared/constants/app_colors.dart';

class ProfileDetailScreen extends ConsumerWidget {
  const ProfileDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Photo
                  _buildProfilePhoto(user),

                  const SizedBox(height: 16),

                  // User Name
                  Text(
                    user.displayName ?? '사용자',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // Login Status Badge - VERY CLEAR
                  _buildLoginStatusBadge(user.authProvider),

                  const SizedBox(height: 24),

                  // Account Information Card
                  _buildAccountInfoCard(context, user, authState),

                  const SizedBox(height: 16),

                  // Stats Card
                  _buildStatsCard(context, user),

                  const SizedBox(height: 24),

                  // Logout Button
                  if (!user.isGuest)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _handleLogout(context, ref),
                        icon: const Icon(Icons.logout),
                        label: const Text('로그아웃'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfilePhoto(UserModel user) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.mathBlue.withOpacity(0.1),
        border: Border.all(
          color: AppColors.mathBlue.withOpacity(0.3),
          width: 3,
        ),
      ),
      child: user.photoUrl != null
          ? ClipOval(
              child: Image.network(
                user.photoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultAvatar(user);
                },
              ),
            )
          : _buildDefaultAvatar(user),
    );
  }

  Widget _buildDefaultAvatar(UserModel user) {
    return Icon(
      Icons.person,
      size: 50,
      color: AppColors.mathBlue,
    );
  }

  /// 🎯 Login Status Badge - Prominently displays auth method
  Widget _buildLoginStatusBadge(AuthProvider provider) {
    final info = _getAuthProviderInfo(provider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: info.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: info.color,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            info.icon,
            color: info.color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            info.label,
            style: TextStyle(
              color: info.color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              '로그인됨',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfoCard(
    BuildContext context,
    UserModel user,
    AuthState authState,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '계정 정보',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            if (user.email != null) ...[
              _buildInfoRow(
                icon: Icons.email_outlined,
                label: '이메일',
                value: user.email!,
              ),
              const SizedBox(height: 12),
            ],

            _buildInfoRow(
              icon: Icons.account_circle_outlined,
              label: '계정 유형',
              value: _getAuthProviderInfo(user.authProvider).fullLabel,
            ),

            if (authState.firebaseUser?.emailVerified == false) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '이메일 인증이 필요합니다',
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, UserModel user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '학습 현황',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.stars,
                  label: '레벨',
                  value: '${user.level}',
                  color: AppColors.mathOrange,
                ),
                _buildStatItem(
                  icon: Icons.local_fire_department,
                  label: '연속 학습',
                  value: '${user.streak}일',
                  color: AppColors.mathRed,
                ),
                _buildStatItem(
                  icon: Icons.diamond,
                  label: '젬',
                  value: '${user.gems}',
                  color: AppColors.mathBlue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  AuthProviderInfo _getAuthProviderInfo(AuthProvider provider) {
    switch (provider) {
      case AuthProvider.google:
        return AuthProviderInfo(
          icon: Icons.g_mobiledata,
          label: 'Google',
          fullLabel: 'Google 계정',
          color: const Color(0xFF4285F4),
        );
      case AuthProvider.kakao:
        return AuthProviderInfo(
          icon: Icons.chat_bubble,
          label: 'Kakao',
          fullLabel: 'Kakao 계정',
          color: const Color(0xFFFEE500),
        );
      case AuthProvider.email:
        return AuthProviderInfo(
          icon: Icons.email,
          label: '이메일',
          fullLabel: '이메일 계정',
          color: AppColors.mathBlue,
        );
      case AuthProvider.guest:
        return AuthProviderInfo(
          icon: Icons.person_outline,
          label: '게스트',
          fullLabel: '게스트 계정',
          color: Colors.grey,
        );
    }
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃하시겠습니까?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(authProvider.notifier).signOut();
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/auth');
      }
    }
  }
}

class AuthProviderInfo {
  final IconData icon;
  final String label;
  final String fullLabel;
  final Color color;

  AuthProviderInfo({
    required this.icon,
    required this.label,
    required this.fullLabel,
    required this.color,
  });
}
