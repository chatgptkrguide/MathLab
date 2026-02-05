// 🎉 Welcome Dialog
//
// Displays a welcoming message after successful login with user information.
// Provides a smooth onboarding experience and confirms login success.

import 'package:flutter/material.dart';

import '../../data/models/user/user_model.dart';
import '../../shared/constants/app_colors.dart';

class WelcomeDialog extends StatelessWidget {
  final UserModel user;
  final String authMethod; // 'google', 'kakao', 'email', 'guest'

  const WelcomeDialog({
    super.key,
    required this.user,
    required this.authMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success Animation (you can replace with Lottie later)
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.mathGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 60,
                color: AppColors.mathGreen,
              ),
            ),

            const SizedBox(height: 24),

            // Welcome Message
            Text(
              '환영합니다! 🎉',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // User Name
            Text(
              '${user.displayName ?? '학습자'}님',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.mathBlue,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Login Method
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getAuthMethodColor(authMethod).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getAuthMethodColor(authMethod).withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                _getAuthMethodText(authMethod),
                style: TextStyle(
                  color: _getAuthMethodColor(authMethod),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Success Message
            Text(
              '수학 학습을 시작해볼까요?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Start Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mathBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  '시작하기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAuthMethodColor(String method) {
    switch (method) {
      case 'google':
        return const Color(0xFF4285F4); // Google Blue
      case 'kakao':
        return const Color(0xFFFEE500); // Kakao Yellow
      case 'email':
        return AppColors.mathBlue;
      case 'guest':
        return Colors.grey;
      default:
        return AppColors.mathBlue;
    }
  }

  String _getAuthMethodText(String method) {
    switch (method) {
      case 'google':
        return 'Google 계정으로 로그인';
      case 'kakao':
        return 'Kakao 계정으로 로그인';
      case 'email':
        return '이메일로 로그인';
      case 'guest':
        return '게스트로 시작';
      default:
        return '로그인 완료';
    }
  }

  /// Show welcome dialog
  static Future<void> show(
    BuildContext context, {
    required UserModel user,
    required String authMethod,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WelcomeDialog(
        user: user,
        authMethod: authMethod,
      ),
    );
  }
}
