// 🏠 Home Top Section
//
// Displays user welcome message with clear login status indication.
// Shows auth provider and makes it obvious the user is logged in.

import 'package:flutter/material.dart';
import '../../../data/models/user/user_model.dart';
import '../../../shared/constants/app_colors.dart';
import '../../settings/settings_screen.dart';

class HomeTopSection extends StatelessWidget {
  final UserModel? user;

  const HomeTopSection({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App bar: hamburger menu + "Home" + GoMath logo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.menu_rounded, color: Colors.white, size: 22),
                ),
              ),
              const Text(
                'Home',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Image.asset(
                'assets/icons/gomath_logo_small.png',
                height: 32,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Text(
                    'GoMath',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Welcome message with user name
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '안녕하세요,',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w400,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '${user?.displayName ?? '학습자'}님',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Login status indicator
                        _buildLoginBadge(),
                      ],
                    ),
                  ],
                ),
              ),

              // Streak display
              if (user != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '🔥',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${user!.streak}일',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Login status badge showing auth provider
  Widget _buildLoginBadge() {
    if (user == null) return const SizedBox.shrink();

    final info = _getAuthProviderInfo(user!.authProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: info.color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: info.color.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            info.icon,
            color: info.textColor,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            info.label,
            style: TextStyle(
              color: info.textColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  AuthProviderInfo _getAuthProviderInfo(AuthProvider provider) {
    switch (provider) {
      case AuthProvider.google:
        return AuthProviderInfo(
          icon: Icons.g_mobiledata,
          label: 'Google',
          color: const Color(0xFF4285F4),
          textColor: Colors.white,
        );
      case AuthProvider.kakao:
        return AuthProviderInfo(
          icon: Icons.chat_bubble,
          label: 'Kakao',
          color: AppColors.kakaoYellow,
          textColor: AppColors.kakaoBrown,
        );
      case AuthProvider.email:
        return AuthProviderInfo(
          icon: Icons.email,
          label: '이메일',
          color: AppColors.mathBlue,
          textColor: Colors.white,
        );
      case AuthProvider.guest:
        return AuthProviderInfo(
          icon: Icons.person_outline,
          label: '게스트',
          color: AppColors.textTertiary,
          textColor: Colors.white,
        );
    }
  }
}

class AuthProviderInfo {
  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;

  AuthProviderInfo({
    required this.icon,
    required this.label,
    required this.color,
    required this.textColor,
  });
}
