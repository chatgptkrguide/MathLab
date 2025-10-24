import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/constants.dart';
import '../../shared/widgets/buttons/animated_button.dart';
import '../../shared/widgets/buttons/social_login_button.dart';
import '../../shared/utils/haptic_feedback.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/user_provider.dart';

/// 듀오링고 스타일 초간단 인증 화면
/// - 큰 로고
/// - "시작하기" 버튼 (게스트)
/// - Google/Kakao 소셜 로그인
/// - 하단 로그인 링크
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mathBlue,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.mathBlueGradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),

              // 로고 섹션
              _buildLogo(),

              const Spacer(flex: 3),

              // 메인 액션 영역
              _buildMainActions(),

              const SizedBox(height: AppDimensions.spacingXL),

              // 구분선
              _buildDivider(),

              const SizedBox(height: AppDimensions.spacingXL),

              // 소셜 로그인
              _buildSocialLogins(),

              const Spacer(flex: 2),

              // 하단 로그인 링크
              _buildBottomLink(),

              const SizedBox(height: AppDimensions.spacingXL),
            ],
          ),
        ),
      ),
    );
  }

  /// 로고 섹션
  Widget _buildLogo() {
    return Column(
      children: [
        // π 로고 with 그라디언트
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.mathButtonGradient,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.mathButtonBlue.withOpacity(0.4),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'π',
              style: TextStyle(
                fontSize: 72,
                color: AppColors.surface,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingL),
        // 앱 이름
        Text(
          'GoMath',
          style: AppTextStyles.displayLarge.copyWith(
            color: AppColors.surface,
            fontWeight: FontWeight.w900,
            fontSize: 48,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingS),
        Text(
          '매일 5분, 수학이 쉬워진다',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.surface.withOpacity(0.9),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// 메인 액션 (시작하기 버튼)
  Widget _buildMainActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingXL),
      child: AnimatedButton(
        text: '시작하기',
        onPressed: _isLoading ? null : _handleGuestStart,
        backgroundColor: AppColors.mathYellow,
        shadowColor: AppColors.mathYellowDark,
        textColor: AppColors.textPrimary,
        width: double.infinity,
        height: 64,
      ),
    );
  }

  /// 구분선
  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingXL),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.surface.withOpacity(0.3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
            child: Text(
              '또는',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.surface.withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.surface.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  /// 소셜 로그인 버튼들
  Widget _buildSocialLogins() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingXL),
      child: Column(
        children: [
          // Google 로그인
          SocialLoginButton(
            provider: SocialLoginProvider.google,
            onPressed: _isLoading ? null : () => _handleGoogleLogin(),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          // Kakao 로그인
          SocialLoginButton(
            provider: SocialLoginProvider.kakao,
            onPressed: _isLoading ? null : () => _handleKakaoLogin(),
          ),
        ],
      ),
    );
  }

  /// 하단 로그인 링크
  Widget _buildBottomLink() {
    return TextButton(
      onPressed: _handleShowLoginOptions,
      child: Text(
        '이미 계정이 있나요?',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.surface,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  /// 게스트로 시작
  Future<void> _handleGuestStart() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    await AppHapticFeedback.mediumImpact();

    try {
      // 게스트 계정 생성 (기존 UserProvider 로직 사용)
      await ref.read(userProvider.notifier).createGuestUser();

      if (mounted) {
        await AppHapticFeedback.success();
        // AuthWrapper가 자동으로 홈으로 이동
      }
    } catch (e) {
      if (mounted) {
        await AppHapticFeedback.error();
        _showError('시작하기에 실패했습니다: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Google 로그인
  Future<void> _handleGoogleLogin() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    await AppHapticFeedback.mediumImpact();

    try {
      final success = await ref.read(authProvider.notifier).signInWithGoogle();

      if (mounted) {
        if (success) {
          await AppHapticFeedback.success();
        } else {
          await AppHapticFeedback.error();
          _showError('Google 로그인에 실패했습니다');
        }
      }
    } catch (e) {
      if (mounted) {
        await AppHapticFeedback.error();
        _showError('Google 로그인 오류: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Kakao 로그인
  Future<void> _handleKakaoLogin() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    await AppHapticFeedback.mediumImpact();

    try {
      final success = await ref.read(authProvider.notifier).signInWithKakao();

      if (mounted) {
        if (success) {
          await AppHapticFeedback.success();
        } else {
          await AppHapticFeedback.error();
          _showError('Kakao 로그인에 실패했습니다');
        }
      }
    } catch (e) {
      if (mounted) {
        await AppHapticFeedback.error();
        _showError('Kakao 로그인 오류: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 로그인 옵션 표시 (추후 구현)
  void _handleShowLoginOptions() {
    AppHapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusXL),
          ),
        ),
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),
            Text(
              '기존 계정으로 로그인',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),
            Text(
              '현재는 게스트 모드 또는 소셜 로그인만 지원합니다.\n이메일 로그인은 곧 추가될 예정입니다!',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingXL),
            AnimatedButton(
              text: '확인',
              onPressed: () => Navigator.pop(context),
              backgroundColor: AppColors.mathTeal,
              shadowColor: AppColors.mathTealDark,
            ),
            const SizedBox(height: AppDimensions.spacingM),
          ],
        ),
      ),
    );
  }

  /// 에러 메시지 표시
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.surface,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.mathRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
