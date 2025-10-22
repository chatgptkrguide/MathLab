import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import '../../utils/haptic_feedback.dart';

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
    final enabled = !isLoading && onPressed != null;

    return Semantics(
      button: true,
      enabled: enabled,
      label: _getButtonText(),
      onTap: enabled ? () async {
        await AppHapticFeedback.selectionClick();
        onPressed?.call();
      } : null,
      child: Container(
        width: double.infinity,
        height: 56,
        margin: const EdgeInsets.symmetric(vertical: AppDimensions.paddingS),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Duolingo 3D solid shadow
            if (enabled)
              Positioned(
                top: 4,
                left: 0,
                right: 0,
                bottom: -4,
                child: Container(
                  decoration: BoxDecoration(
                    color: _getShadowColor(),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            // Main button
            Container(
              decoration: BoxDecoration(
                color: enabled ? _getBackgroundColor() : const Color(0xFFE5E5E5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: enabled ? _getShadowColor() : const Color(0xFFD0D0D0),
                  width: 3,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: enabled ? () async {
                    await AppHapticFeedback.selectionClick();
                    onPressed?.call();
                  } : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingL,
                        vertical: AppDimensions.paddingM,
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
                              mainAxisSize: MainAxisSize.min,
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
                  ),
                ),
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

  Color _getShadowColor() {
    switch (provider) {
      case SocialLoginProvider.google:
        return const Color(0xFFD0D0D0); // Light gray shadow
      case SocialLoginProvider.kakao:
        return const Color(0xFFDDC800); // Darker yellow shadow
      case SocialLoginProvider.apple:
        return const Color(0xFF1A1A1A); // Very dark gray shadow
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
