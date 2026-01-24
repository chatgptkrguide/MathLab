import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/auth/auth_provider.dart';
import '../../../data/services/temp_profile_storage.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_durations.dart';
import '../../profile/onboarding_profile_setup_screen.dart';

/// 인증 관련 로직 핸들러
class AuthHandler {
  /// 게스트로 시작
  static Future<bool> handleGuestStart({
    required BuildContext context,
    required WidgetRef ref,
    required bool mounted,
  }) async {
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

        await ref
            .read(authProvider.notifier)
            .applyTempProfileToAccount(defaultProfile);

        // Success feedback
        if (mounted) {
          _showSuccessSnackBar(
            context: context,
            message: '${defaultProfile.name}님, 환영합니다! 🎉',
          );
        }

        return true;
      } else {
        if (mounted) {
          _showErrorSnackBar(
            context: context,
            message: '게스트 계정 생성에 실패했습니다. 다시 시도해주세요.',
          );
        }
        return false;
      }
    } catch (e) {
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
    try {
      // 1. 구글 로그인 먼저 실행
      final success = await ref.read(authProvider.notifier).signInWithGoogle();

      if (!mounted) return false;

      if (success) {
        // 2. 로그인 성공 후 프로필 설정 화면으로 이동
        final profileResult = await Navigator.of(context).push<TempProfileData>(
          MaterialPageRoute(
            builder: (context) => const OnboardingProfileSetupScreen(),
          ),
        );

        if (profileResult == null || !mounted) return false;

        // 3. 프로필 정보를 사용자 계정에 업데이트
        await ref.read(authProvider.notifier).applyTempProfileToAccount(
              profileResult,
            );

        if (!mounted) return false;

        // 4. 임시 프로필 정보 삭제
        final tempStorage = ref.read(tempProfileStorageProvider);
        await tempStorage.clearTempProfile();

        // Success feedback
        if (mounted) {
          _showSuccessSnackBar(
            context: context,
            message: '${profileResult.name}님, 환영합니다! 🎉',
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
    } catch (e) {
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
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(
          context: context,
          message: 'Kakao 로그인 실패: $e',
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
