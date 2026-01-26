import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_logger.dart';
import '../../../data/providers/auth/auth_provider.dart';
import '../../../data/providers/user/user_provider.dart';
import '../../../data/services/temp_profile_storage.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_durations.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/welcome_dialog.dart';
import '../../profile/onboarding_profile_setup_screen.dart';

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
        // 기본 프로필로 시작
        final defaultProfile = TempProfileData(
          name: '테스터',
          birthDate: DateTime.now().subtract(const Duration(days: 365 * 15)),
          gender: null,
          currentGrade: '중1',
          schoolName: null,
          bio: null,
        );

        // TODO: Implement applyTempProfileToAccount
        // await ref
        //     .read(authProvider.notifier)
        //     .applyTempProfileToAccount(defaultProfile);

        // Hide loading overlay
        if (mounted) {
          LoadingOverlay.hide(context);
        }

        // Show welcome dialog
        final user = ref.read(userProvider);
        if (mounted && user != null) {
          await WelcomeDialog.show(
            context,
            user: user,
            authMethod: 'guest',
          );
        }

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
      // 1. 구글 로그인 먼저 실행
      final success = await ref.read(authProvider.notifier).signInWithGoogle();

      // Hide loading overlay
      if (mounted) {
        LoadingOverlay.hide(context);
      }

      if (!mounted) return false;

      if (success) {
        // 2. 로그인 성공 후 프로필 설정 화면으로 이동
        final profileResult = await Navigator.of(context).push<TempProfileData>(
          MaterialPageRoute(
            builder: (context) => const OnboardingProfileSetupScreen(),
          ),
        );

        if (profileResult == null || !mounted) return false;

        // Show saving profile overlay
        if (mounted) {
          LoadingOverlay.show(context, message: LoadingMessages.savingProfile);
        }

        // 3. 프로필 정보를 사용자 계정에 업데이트
        // TODO: Implement applyTempProfileToAccount
        // await ref.read(authProvider.notifier).applyTempProfileToAccount(
        //       profileResult,
        //     );

        if (!mounted) return false;

        // 4. 임시 프로필 정보 삭제
        // TODO: Implement tempProfileStorageProvider
        // final tempStorage = ref.read(tempProfileStorageProvider);
        // await tempStorage.clearTempProfile();

        // Hide saving overlay
        if (mounted) {
          LoadingOverlay.hide(context);
        }

        // 5. Show welcome dialog
        final user = ref.read(userProvider);
        if (mounted && user != null) {
          await WelcomeDialog.show(
            context,
            user: user,
            authMethod: 'google',
          );
        }

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
      // Log detailed error for debugging (server-side only)
      AppLogger.error(
        'Google Sign-In failed',
        error: e,
        stackTrace: stackTrace,
      );

      // Hide loading overlay on error
      if (mounted) {
        LoadingOverlay.hide(context);
      }

      // Show generic user-friendly message
      if (mounted) {
        _showErrorSnackBar(
          context: context,
          message: 'Google 로그인 중 문제가 발생했습니다. 네트워크를 확인해주세요.',
        );
      }
      return false;
    }
  }

  /// Kakao 로그인
  static Future<bool> handleKakaoLogin({
    required BuildContext context,
    required WidgetRef ref,
    required bool mounted,
  }) async {
    try {
      final success = await ref.read(authProvider.notifier).signInWithKakao();
      if (!mounted) return false;

      if (!success && mounted) {
        _showErrorSnackBar(
          context: context,
          message: 'Kakao 로그인에 실패했습니다',
        );
      }

      return success;
    } catch (e, stackTrace) {
      // Log detailed error (never expose to user)
      AppLogger.error(
        'Kakao Sign-In failed',
        error: e,
        stackTrace: stackTrace,
      );

      // Show safe error message to user
      if (mounted) {
        _showErrorSnackBar(
          context: context,
          message: 'Kakao 로그인에 실패했습니다. 다시 시도해주세요.',
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
        // Show welcome dialog
        final user = ref.read(userProvider);
        if (mounted && user != null) {
          await WelcomeDialog.show(
            context,
            user: user,
            authMethod: 'email',
          );
        }
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
  static Future<void> sendPasswordResetEmail({
    required String email,
  }) async {
    // TODO: Implement password reset email sending
    // This requires Firebase Auth integration
    // Example:
    // await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    throw UnimplementedError('비밀번호 재설정 기능은 아직 구현되지 않았습니다');
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
