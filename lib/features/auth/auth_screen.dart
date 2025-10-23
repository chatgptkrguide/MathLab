import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/constants.dart';
import '../../shared/widgets/buttons/animated_button.dart';
import '../../shared/utils/haptic_feedback.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/models/models.dart';

/// 듀오링고 스타일 인증 화면
/// 깔끔하고 직관적한 시작 화면
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.mathBlueGradient,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  // 상단 여백
                  const SizedBox(height: AppDimensions.spacingXXL * 2),

                  // 로고 및 일러스트레이션
                  Expanded(
                    flex: 3,
                    child: _buildHeroSection(),
                  ),

                  // 버튼 영역
                  Expanded(
                    flex: 2,
                    child: _buildActionSection(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 히어로 섹션 (로고 + 일러스트레이션)
  Widget _buildHeroSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 메인 로고/아이콘
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.surface.withValues(alpha: 0.4),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.surface.withValues(alpha: 0.2),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'π',
                  style: TextStyle(
                    fontSize: 70,
                    fontWeight: FontWeight.bold,
                    color: AppColors.surface,
                    shadows: [
                      Shadow(
                        color: AppColors.mathButtonBlue.withValues(alpha: 0.5),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '∫ dx',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.surface.withValues(alpha: 0.9),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppDimensions.spacingXL),

        // 앱 이름
        Text(
          'MathLab',
          style: AppTextStyles.displayLarge.copyWith(
            color: AppColors.surface,
            fontWeight: FontWeight.bold,
            fontSize: 48,
            letterSpacing: 2,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.2),
                offset: const Offset(0, 3),
                blurRadius: 8,
              ),
            ],
          ),
        ),

        const SizedBox(height: AppDimensions.spacingM),

        // 서브 타이틀
        Text(
          '매일 성장하는 수학 학습',
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.surface.withValues(alpha: 0.9),
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  /// 액션 섹션 (버튼들)
  Widget _buildActionSection() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingXL,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 메인 CTA - 시작하기 (게스트 로그인)
          AnimatedButton(
            text: '시작하기',
            onPressed: _startAsGuest,
            backgroundColor: AppColors.mathYellow,
            shadowColor: AppColors.mathOrange,
            textColor: AppColors.textPrimary,
            height: 64,
            icon: Icons.rocket_launch_rounded,
          ),

          const SizedBox(height: AppDimensions.spacingL),

          // 소셜 로그인 버튼들
          Row(
            children: [
              Expanded(
                child: _buildSocialButton(
                  icon: '🔵',
                  label: 'Google',
                  onPressed: _signInWithGoogle,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(
                child: _buildSocialButton(
                  icon: '💬',
                  label: 'Kakao',
                  onPressed: _signInWithKakao,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingXL),

          // 계정이 있는 경우 로그인 링크
          TextButton(
            onPressed: _showLoginDialog,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingL,
                vertical: AppDimensions.paddingM,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '계정이 있으신가요?',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.surface.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '로그인',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.surface,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.spacingM),
        ],
      ),
    );
  }

  /// 소셜 로그인 버튼
  Widget _buildSocialButton({
    required String icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: AppColors.surface.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.paddingL,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            border: Border.all(
              color: AppColors.surface.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: AppDimensions.spacingS),
              Text(
                label,
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.surface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 게스트로 시작
  Future<void> _startAsGuest() async {
    await AppHapticFeedback.mediumImpact();

    try {
      final authNotifier = ref.read(authProvider.notifier);
      await authNotifier.continueAsGuest();

      if (mounted) {
        // 성공적으로 게스트 계정 생성됨
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '환영합니다! 지금 바로 학습을 시작해보세요 🎉',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.surface,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: AppColors.mathTeal,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '오류가 발생했습니다. 다시 시도해주세요.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.surface,
              ),
            ),
            backgroundColor: AppColors.mathRed,
          ),
        );
      }
    }
  }

  /// Google 로그인
  Future<void> _signInWithGoogle() async {
    await AppHapticFeedback.lightImpact();

    try {
      final authNotifier = ref.read(authProvider.notifier);
      final success = await authNotifier.signInWithGoogle();

      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Google 계정으로 로그인했습니다! 👋',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.surface,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: AppColors.mathBlue,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            ),
          ),
        );
      } else if (mounted && !success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Google 로그인에 실패했습니다.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.surface,
              ),
            ),
            backgroundColor: AppColors.mathRed,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '로그인 중 오류가 발생했습니다.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.surface,
              ),
            ),
            backgroundColor: AppColors.mathRed,
          ),
        );
      }
    }
  }

  /// Kakao 로그인
  Future<void> _signInWithKakao() async {
    await AppHapticFeedback.lightImpact();

    try {
      final authNotifier = ref.read(authProvider.notifier);
      final success = await authNotifier.signInWithKakao();

      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Kakao 계정으로 로그인했습니다! 👋',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.surface,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: AppColors.mathYellow,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            ),
          ),
        );
      } else if (mounted && !success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Kakao 로그인에 실패했습니다.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.surface,
              ),
            ),
            backgroundColor: AppColors.mathRed,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '로그인 중 오류가 발생했습니다.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.surface,
              ),
            ),
            backgroundColor: AppColors.mathRed,
          ),
        );
      }
    }
  }

  /// 기존 계정 로그인 다이얼로그
  Future<void> _showLoginDialog() async {
    await AppHapticFeedback.lightImpact();

    final authState = ref.read(authProvider);
    final accounts = authState.accounts;

    if (accounts.isEmpty) {
      // 계정이 없으면 소셜 로그인 안내
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
            ),
            title: Row(
              children: [
                const Text('ℹ️', style: TextStyle(fontSize: 28)),
                const SizedBox(width: AppDimensions.spacingM),
                Expanded(
                  child: Text(
                    '저장된 계정 없음',
                    style: AppTextStyles.headlineSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              'Google 또는 Kakao 계정으로 로그인하여\n학습 진행상황을 저장하세요.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  '확인',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.mathBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }
      return;
    }

    // 계정 선택 다이얼로그
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          ),
          title: Text(
            '계정 선택',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final account = accounts[index];
                return _buildAccountTile(account);
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                '취소',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  /// 계정 타일
  Widget _buildAccountTile(Account account) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          await AppHapticFeedback.selectionClick();
          final authNotifier = ref.read(authProvider.notifier);
          await authNotifier.switchAccount(account.id);
          if (mounted) {
            Navigator.of(context).pop();
          }
        },
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          margin: const EdgeInsets.only(bottom: AppDimensions.spacingS),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.borderLight,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          child: Row(
            children: [
              // 프로필 아이콘
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.blueGradient,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    account.name.isNotEmpty
                        ? account.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: AppColors.surface,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              // 계정 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      account.email ?? '게스트 계정',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // 로그인 타입 아이콘
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingS),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: Text(
                  _getLoginTypeIcon(account.loginType),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 로그인 타입 아이콘
  String _getLoginTypeIcon(LoginType type) {
    switch (type) {
      case LoginType.google:
        return '🔵';
      case LoginType.kakao:
        return '💬';
      case LoginType.guest:
        return '👤';
    }
  }
}
