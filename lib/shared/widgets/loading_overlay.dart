/// 🔄 Loading Overlay Widget
///
/// Full-screen loading overlay with customizable message and spinner.
/// Used during authentication and other async operations to provide visual feedback.

import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final String message;
  final Widget? child;

  const LoadingOverlay({
    super.key,
    this.message = '처리 중...',
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (child != null) child!,
        Container(
          color: Colors.black.withOpacity(0.5),
          child: Center(
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      message,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Show loading overlay as a dialog
  static void show(
    BuildContext context, {
    String message = '처리 중...',
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoadingOverlay(message: message),
    );
  }

  /// Hide loading overlay
  static void hide(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}

/// 🎯 Specific loading messages for different operations
class LoadingMessages {
  static const String signingIn = '로그인 중...';
  static const String signingUp = '회원가입 중...';
  static const String signingOut = '로그아웃 중...';
  static const String googleSignIn = 'Google 계정 연결 중...';
  static const String kakaoSignIn = 'Kakao 계정 연결 중...';
  static const String emailSignIn = '이메일로 로그인 중...';
  static const String emailSignUp = '계정 생성 중...';
  static const String savingProfile = '프로필 저장 중...';
  static const String loading = '로딩 중...';
  static const String processing = '처리 중...';
}
