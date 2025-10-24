import 'package:flutter/material.dart';
import '../../../shared/constants/constants.dart';
import '../../../shared/widgets/buttons/animated_button.dart';
import '../../auth/auth_screen.dart';

/// 게스트 로그인 유도 위젯
class GuestLoginPrompt extends StatelessWidget {
  const GuestLoginPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.mathYellow.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: AppColors.mathYellow.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.mathYellow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text('🎯', style: TextStyle(fontSize: 24)),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '로그인하고 학습 기록을 저장하세요',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '소셜 로그인으로 간편하게 시작할 수 있어요',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          AnimatedButton(
            text: '로그인하러 가기',
            onPressed: () => _navigateToLogin(context),
            backgroundColor: AppColors.mathYellow,
            shadowColor: AppColors.mathYellowDark,
            textColor: AppColors.textPrimary,
            width: double.infinity,
            height: 48,
          ),
        ],
      ),
    );
  }

  void _navigateToLogin(BuildContext context) async {
    final shouldNavigate = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        title: const Text('로그인'),
        content: const Text(
          '로그인 화면으로 이동하시겠습니까?\n현재 게스트 계정의 학습 기록은 유지됩니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              '취소',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              '이동',
              style: TextStyle(color: AppColors.mathYellow),
            ),
          ),
        ],
      ),
    );

    if (shouldNavigate == true && context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    }
  }
}
