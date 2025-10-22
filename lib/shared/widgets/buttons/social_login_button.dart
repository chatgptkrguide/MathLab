import 'package:flutter/material.dart';
import '../../constants/constants.dart';

/// 소셜 로그인 버튼
/// Google, Kakao, Apple 로그인 버튼 위젯
class SocialLoginButton extends StatelessWidget {
  final SocialLoginProvider provider;
  final VoidCallback onPressed;
  final bool isLoading;

  const SocialLoginButton({
    super.key,
    required this.provider,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getBackgroundColor(),
          foregroundColor: _getTextColor(),
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            side: BorderSide(
              color: _getBorderColor(),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
            vertical: AppDimensions.paddingM,
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(_getTextColor()),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIcon(),
                  const SizedBox(width: AppDimensions.spacingM),
                  Flexible(
                    child: Text(
                      _getButtonText(),
                      style: AppTextStyles.titleMedium.copyWith(
                        color: _getTextColor(),
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildIcon() {
    switch (provider) {
      case SocialLoginProvider.google:
        return Image.asset(
          'assets/images/google_logo.png',
          width: 24,
          height: 24,
          errorBuilder: (context, error, stackTrace) {
            return const Text('🔵', style: TextStyle(fontSize: 20));
          },
        );

      case SocialLoginProvider.kakao:
        return Image.asset(
          'assets/images/kakao_logo.png',
          width: 24,
          height: 24,
          errorBuilder: (context, error, stackTrace) {
            return const Text('💛', style: TextStyle(fontSize: 20));
          },
        );

      case SocialLoginProvider.apple:
        return Icon(
          Icons.apple,
          size: 24,
          color: _getTextColor(),
        );
    }
  }

  Color _getBackgroundColor() {
    switch (provider) {
      case SocialLoginProvider.google:
        return Colors.white;
      case SocialLoginProvider.kakao:
        return const Color(0xFFFEE500); // Kakao Yellow
      case SocialLoginProvider.apple:
        return Colors.black;
    }
  }

  Color _getTextColor() {
    switch (provider) {
      case SocialLoginProvider.google:
        return Colors.black87;
      case SocialLoginProvider.kakao:
        return const Color(0xFF191919); // Kakao Brown/Black
      case SocialLoginProvider.apple:
        return Colors.white;
    }
  }

  Color _getBorderColor() {
    switch (provider) {
      case SocialLoginProvider.google:
        return AppColors.borderLight;
      case SocialLoginProvider.kakao:
        return const Color(0xFFFEE500);
      case SocialLoginProvider.apple:
        return Colors.black;
    }
  }

  String _getButtonText() {
    switch (provider) {
      case SocialLoginProvider.google:
        return 'Google로 계속하기';
      case SocialLoginProvider.kakao:
        return 'Kakao로 계속하기';
      case SocialLoginProvider.apple:
        return 'Apple로 계속하기';
    }
  }
}

/// 소셜 로그인 프로바이더 열거형
enum SocialLoginProvider {
  google,
  kakao,
  apple,
}
