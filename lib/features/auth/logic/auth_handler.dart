// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_logger.dart';
import '../../../data/providers/auth/auth_provider.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_durations.dart';
import '../../../shared/widgets/loading_overlay.dart';

/// 인증 관련 로직 핸들러
class AuthHandler {
  /// 게스트로 시작
  static Future<bool> handleGuestStart({
    required BuildContext context,
    required WidgetRef ref,
    required bool mounted,
  }) async {
    // Show loading overlay
    if (mounted) {
      LoadingOverlay.show(context, message: '게스트 계정 생성 중...');
    }

    try {
      // 게스트 계정 생성
      final success = await ref.read(authProvider.notifier).signInAsGuest();

      if (!mounted) return false;

      if (success) {
        // Hide loading overlay - guest user already created with displayName='게스트'
        // by createGuestUser() in signInAsGuest(), no need to update profile separately
        if (mounted) {
          LoadingOverlay.hide(context);
        }

        // AuthWrapper will detect auth state change and navigate to MainNavigation
        return true;
      } else {
        // Hide loading overlay on error
        if (mounted) {
          LoadingOverlay.hide(context);
        }

        if (mounted) {
          _showErrorSnackBar(
            context: context,
            message: '게스트 계정 생성에 실패했습니다. 다시 시도해주세요.',
          );
        }
        return false;
      }
    } catch (e, stackTrace) {
      // Log detailed error information for debugging
      AppLogger.error(
        'Guest account creation failed',
        error: e,
        stackTrace: stackTrace,
      );

      // Hide loading overlay on error
      if (mounted) {
        LoadingOverlay.hide(context);
      }

      // Show user-friendly error message (no sensitive info)
      if (mounted) {
        _showErrorSnackBar(
          context: context,
          message: '예상치 못한 오류가 발생했습니다. 잠시 후 다시 시도해주세요.',
        );
      }
      return false;
    }
  }

  /// Google 로그인
  static Future<bool> handleGoogleLogin({
    required BuildContext context,
    required WidgetRef ref,
    required bool mounted,
  }) async {
    // Show loading overlay
    if (mounted) {
      LoadingOverlay.show(context, message: LoadingMessages.googleSignIn);
    }

    try {
      final success = await ref.read(authProvider.notifier).signInWithGoogle();

      if (mounted) {
        LoadingOverlay.hide(context);
      }

      if (!mounted) return false;

      if (success) {
        // AuthWrapper가 프로필 설정/메인 화면 전환을 자동 처리
        return true;
      } else {
        if (mounted) {
          _showErrorSnackBar(
            context: context,
            message: 'Google 로그인에 실패했습니다. 다시 시도해주세요.',
          );
        }
        return false;
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Google Sign-In failed',
        error: e,
        stackTrace: stackTrace,
      );

      if (mounted) {
        LoadingOverlay.hide(context);
      }

      if (mounted) {
        _showErrorSnackBar(
          context: context,
          message: 'Google 로그인 중 문제가 발생했습니다. 네트워크를 확인해주세요.',
        );
      }
      return false;
    }
  }

  /// Apple 로그인
  static Future<bool> handleAppleLogin({
    required BuildContext context,
    required WidgetRef ref,
    required bool mounted,
  }) async {
    if (mounted) {
      LoadingOverlay.show(context, message: 'Apple 로그인 중...');
    }

    try {
      final success = await ref.read(authProvider.notifier).signInWithApple();

      if (mounted) {
        LoadingOverlay.hide(context);
      }

      if (!mounted) return false;

      if (success) {
        // AuthWrapper가 프로필 설정/메인 화면 전환을 자동 처리
        return true;
      } else {
        if (mounted) {
          _showErrorSnackBar(
            context: context,
            message: 'Apple 로그인에 실패했습니다. 다시 시도해주세요.',
          );
        }
        return false;
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Apple Sign-In failed',
        error: e,
        stackTrace: stackTrace,
      );

      if (mounted) {
        LoadingOverlay.hide(context);
      }

      if (mounted) {
        _showErrorSnackBar(
          context: context,
          message: 'Apple 로그인 중 문제가 발생했습니다.',
        );
      }
      return false;
    }
  }

  /// Kakao 로그인 (개발 단계)
  static Future<bool> handleKakaoLogin({
    required BuildContext context,
    required WidgetRef ref,
    required bool mounted,
  }) async {
    if (mounted) {
      LoadingOverlay.show(context, message: LoadingMessages.kakaoSignIn);
    }

    try {
      final success = await ref.read(authProvider.notifier).signInWithKakao();

      if (mounted) {
        LoadingOverlay.hide(context);
      }

      if (!mounted) return false;

      if (success) {
        return true;
      } else {
        if (mounted) {
          _showErrorSnackBar(
            context: context,
            message: 'Kakao 로그인에 실패했습니다. 다시 시도해주세요.',
          );
        }
        return false;
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Kakao Sign-In failed',
        error: e,
        stackTrace: stackTrace,
      );

      if (mounted) {
        LoadingOverlay.hide(context);
      }

      if (mounted) {
        _showErrorSnackBar(
          context: context,
          message: 'Kakao 로그인 중 문제가 발생했습니다.',
        );
      }
      return false;
    }
  }

  /// 이메일 로그인
  static Future<bool> handleEmailLogin({
    required String email,
    required String password,
    required BuildContext context,
    required WidgetRef ref,
    required bool mounted,
  }) async {
    // Show loading overlay
    if (mounted) {
      LoadingOverlay.show(context, message: LoadingMessages.emailSignIn);
    }

    try {
      final success = await ref.read(authProvider.notifier).signInWithEmail(
            email,
            password,
          );

      // Hide loading overlay
      if (mounted) {
        LoadingOverlay.hide(context);
      }

      if (!mounted) return false;

      if (success) {
        // WelcomeDialog is handled by AuthWrapper to avoid duplicate display
        return true;
      } else {
        if (mounted) {
          _showErrorSnackBar(
            context: context,
            message: '이메일 또는 비밀번호를 확인해주세요.',
          );
        }
        return false;
      }
    } catch (e, stackTrace) {
      // Log error for debugging
      AppLogger.error(
        'Email Sign-In failed',
        error: e,
        stackTrace: stackTrace,
      );

      // Hide loading overlay on error
      if (mounted) {
        LoadingOverlay.hide(context);
      }

      // Show generic message (no error details)
      if (mounted) {
        _showErrorSnackBar(
          context: context,
          message: '로그인 중 문제가 발생했습니다. 다시 시도해주세요.',
        );
      }
      return false;
    }
  }

  /// 이메일 회원가입
  static Future<bool> handleEmailSignup({
    required String email,
    required String password,
    required BuildContext context,
    required WidgetRef ref,
    required bool mounted,
  }) async {
    // Show loading overlay
    if (mounted) {
      LoadingOverlay.show(context, message: LoadingMessages.emailSignUp);
    }

    try {
      final success = await ref.read(authProvider.notifier).signUpWithEmail(
            email,
            password,
          );

      // Hide loading overlay
      if (mounted) {
        LoadingOverlay.hide(context);
      }

      if (!mounted) return false;

      if (success) {
        if (mounted) {
          _showSuccessSnackBar(
            context: context,
            message: '회원가입이 완료되었습니다! 이메일을 확인해주세요. 📧',
          );
        }
        return true;
      } else {
        if (mounted) {
          _showErrorSnackBar(
            context: context,
            message: '회원가입에 실패했습니다. 다시 시도해주세요.',
          );
        }
        return false;
      }
    } catch (e, stackTrace) {
      // Log error for debugging
      AppLogger.error(
        'Email Sign-Up failed',
        error: e,
        stackTrace: stackTrace,
      );

      // Hide loading overlay on error
      if (mounted) {
        LoadingOverlay.hide(context);
      }

      // Show safe error message
      if (mounted) {
        _showErrorSnackBar(
          context: context,
          message: '회원가입 중 문제가 발생했습니다. 네트워크를 확인해주세요.',
        );
      }
      return false;
    }
  }

  /// 비밀번호 재설정 이메일 전송
  static Future<bool> sendPasswordResetEmail({
    required String email,
    required BuildContext context,
    required bool mounted,
  }) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (mounted) {
        _showSuccessSnackBar(
          context: context,
          message: '비밀번호 재설정 이메일을 발송했습니다. 이메일을 확인해주세요.',
        );
      }
      return true;
    } on FirebaseAuthException catch (e) {
      AppLogger.error(
        'Password reset email failed',
        error: e,
      );

      String message;
      switch (e.code) {
        case 'user-not-found':
          message = '등록되지 않은 이메일 주소입니다.';
          break;
        case 'invalid-email':
          message = '올바른 이메일 주소를 입력해주세요.';
          break;
        case 'too-many-requests':
          message = '너무 많은 요청이 있었습니다. 잠시 후 다시 시도해주세요.';
          break;
        default:
          message = '비밀번호 재설정 이메일 발송에 실패했습니다.';
      }

      if (mounted) {
        _showErrorSnackBar(context: context, message: message);
      }
      return false;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Password reset email failed',
        error: e,
        stackTrace: stackTrace,
      );

      if (mounted) {
        _showErrorSnackBar(
          context: context,
          message: '비밀번호 재설정 중 문제가 발생했습니다. 다시 시도해주세요.',
        );
      }
      return false;
    }
  }

  /// 성공 스낵바 표시
  static void _showSuccessSnackBar({
    required BuildContext context,
    required String message,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.mathGreen,
        behavior: SnackBarBehavior.floating,
        duration: AppDurations.snackBarShort,
      ),
    );
  }

  /// 에러 스낵바 표시
  static void _showErrorSnackBar({
    required BuildContext context,
    required String message,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
