import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/constants.dart';
import '../../shared/widgets/widgets.dart';
import '../../shared/widgets/responsive_wrapper.dart';
import '../../shared/widgets/buttons/social_login_button.dart';
import '../../shared/utils/haptic_feedback.dart';
import '../../data/models/user_account.dart';
import '../../data/providers/auth_provider.dart';

/// 로그인/회원가입 화면
/// 듀오링고 스타일의 매력적인 인증 화면
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();

  late TabController _tabController;
  bool _isSignUp = false;
  String _selectedGrade = '중1';
  AccountType _selectedAccountType = AccountType.student;

  final List<String> _grades = ['중1', '중2', '중3', '고1', '고2', '고3'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _isSignUp = _tabController.index == 1;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF235390),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF235390), Color(0xFF1CB0F6)],
          ),
        ),
        child: SafeArea(
          child: ResponsiveWrapper(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingXL),
                child: Column(
                  children: [
                    const SizedBox(height: AppDimensions.spacingXXL),
                    _buildHeader(),
                    const SizedBox(height: AppDimensions.spacingXXL),
                    _buildAccountSelector(),
                    const SizedBox(height: AppDimensions.spacingXL),
                    _buildAuthTabs(),
                    const SizedBox(height: AppDimensions.spacingXL),
                    _buildAuthForm(authState),
                    const SizedBox(height: AppDimensions.spacingXXL),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 헤더 (로고 + 환영 메시지)
  Widget _buildHeader() {
    return Column(
      children: [
        // 로고 대신 수학 이모지 + 타이틀
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.white, Color(0xFFF0F0F0)],
            ),
            borderRadius: BorderRadius.circular(60),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Center(
            child: Text(
              '🧮',
              style: TextStyle(fontSize: 48),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingL),
        Text(
          'MathLab',
          style: AppTextStyles.headlineLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 32,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingS),
        Text(
          '재미있는 수학 학습의 시작',
          style: AppTextStyles.bodyLarge.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 기존 계정 선택
  Widget _buildAccountSelector() {
    final accounts = ref.watch(availableAccountsProvider);

    if (accounts.isEmpty) return const SizedBox.shrink();

    return DuolingoCard(
      gradientColors: const [Colors.white, Color(0xFFF8F9FA)],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '기존 계정으로 계속하기',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          ...accounts.map((account) => _buildAccountItem(account)),
        ],
      ),
    );
  }

  /// 계정 아이템
  Widget _buildAccountItem(UserAccount account) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingS),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(int.parse(account.accountColor.replaceFirst('#', '0xFF'))),
          child: Text(
            account.avatarText,
            style: AppTextStyles.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          account.displayName,
          style: AppTextStyles.titleMedium,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        subtitle: Text(
          '${account.email} • ${account.accountTypeText}',
          style: AppTextStyles.bodySmall,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () async {
          await AppHapticFeedback.lightImpact();
          await ref.read(authProvider.notifier).signIn(account.email);
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
      ),
    );
  }

  /// 인증 탭
  Widget _buildAuthTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: '로그인'),
          Tab(text: '회원가입'),
        ],
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
        indicator: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        indicatorPadding: const EdgeInsets.all(4),
      ),
    );
  }

  /// 인증 폼
  Widget _buildAuthForm(AuthState authState) {
    return DuolingoCard(
      gradientColors: const [Colors.white, Color(0xFFF8F9FA)],
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isSignUp ? '새 계정 만들기' : '계정에 로그인',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingXL),

            // 이메일 입력
            _buildInputField(
              controller: _emailController,
              label: '이메일',
              hint: 'your@email.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
            ),

            if (_isSignUp) ...[
              const SizedBox(height: AppDimensions.spacingL),
              // 이름 입력
              _buildInputField(
                controller: _nameController,
                label: '이름',
                hint: '홍길동',
                icon: Icons.person_outline,
                validator: _validateName,
              ),

              const SizedBox(height: AppDimensions.spacingL),
              // 학년 선택
              _buildGradeSelector(),

              const SizedBox(height: AppDimensions.spacingL),
              // 계정 타입 선택
              _buildAccountTypeSelector(),
            ],

            const SizedBox(height: AppDimensions.spacingXXL),

            // 제출 버튼
            AnimatedButton(
              text: _isSignUp ? '계정 만들기' : '로그인',
              onPressed: authState.isLoading ? null : _handleAuth,
              isEnabled: !authState.isLoading,
              gradientColors: AppColors.greenGradient,
              height: 56,
            ),

            if (authState.error != null) ...[
              const SizedBox(height: AppDimensions.spacingL),
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.duolingoRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  border: Border.all(color: AppColors.duolingoRed.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.duolingoRed, size: 20),
                    const SizedBox(width: AppDimensions.spacingS),
                    Expanded(
                      child: Text(
                        authState.error!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.duolingoRed,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppDimensions.spacingXL),

            // 구분선
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
                  child: Text(
                    '또는',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),

            const SizedBox(height: AppDimensions.spacingXL),

            // 소셜 로그인 버튼들
            SocialLoginButton(
              provider: SocialLoginProvider.google,
              onPressed: _signInWithGoogle,
              isLoading: authState.isLoading,
            ),

            const SizedBox(height: AppDimensions.spacingM),

            SocialLoginButton(
              provider: SocialLoginProvider.kakao,
              onPressed: _signInWithKakao,
              isLoading: authState.isLoading,
            ),

            const SizedBox(height: AppDimensions.spacingM),

            // Apple 로그인은 iOS에서만 표시
            if (Platform.isIOS) ...[
              SocialLoginButton(
                provider: SocialLoginProvider.apple,
                onPressed: _signInWithApple,
                isLoading: authState.isLoading,
              ),
              const SizedBox(height: AppDimensions.spacingM),
            ],

            const SizedBox(height: AppDimensions.spacingL),

            // 게스트로 계속하기
            TextButton(
              onPressed: _continueAsGuest,
              child: Text(
                '게스트로 계속하기',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 입력 필드
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingS),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              borderSide: BorderSide(color: AppColors.duolingoBlue, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  /// 학년 선택
  Widget _buildGradeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '학년',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingS),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderLight),
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedGrade,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(AppDimensions.paddingL),
              prefixIcon: Icon(Icons.school_outlined),
            ),
            items: _grades.map((grade) {
              return DropdownMenuItem(
                value: grade,
                child: Text(grade),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedGrade = value;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  /// 계정 타입 선택
  Widget _buildAccountTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '계정 유형',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingS),
        Wrap(
          spacing: AppDimensions.spacingS,
          children: AccountType.values.map((type) {
            final isSelected = _selectedAccountType == type;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedAccountType = type;
                });
                AppHapticFeedback.lightImpact();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL,
                  vertical: AppDimensions.paddingS,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(colors: AppColors.blueGradient)
                      : null,
                  color: isSelected ? null : AppColors.background,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.duolingoBlue
                        : AppColors.borderLight,
                  ),
                ),
                child: Text(
                  _getAccountTypeText(type),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // 이벤트 핸들러들

  void _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    await AppHapticFeedback.mediumImpact();

    final email = _emailController.text.trim();
    final name = _nameController.text.trim();

    bool success = false;

    if (_isSignUp) {
      success = await ref.read(authProvider.notifier).signUp(
        email: email,
        displayName: name,
        grade: _selectedGrade,
        accountType: _selectedAccountType,
      );
    } else {
      success = await ref.read(authProvider.notifier).signIn(email);
    }

    if (success) {
      await AppHapticFeedback.success();
      if (mounted) {
        Navigator.of(context).pop(); // 인증 성공 시 메인 화면으로
      }
    } else {
      await AppHapticFeedback.error();
    }
  }

  void _continueAsGuest() async {
    await AppHapticFeedback.lightImpact();

    // 게스트 계정 생성
    final success = await ref.read(authProvider.notifier).signUp(
      email: 'guest@mathlab.com',
      displayName: '게스트',
      grade: _selectedGrade,
      accountType: AccountType.student,
    );

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  // ==================== 소셜 로그인 핸들러 ====================

  void _signInWithGoogle() async {
    await AppHapticFeedback.mediumImpact();

    final success = await ref.read(authProvider.notifier).signInWithGoogle();

    if (success) {
      await AppHapticFeedback.success();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } else {
      await AppHapticFeedback.error();
    }
  }

  void _signInWithKakao() async {
    await AppHapticFeedback.mediumImpact();

    final success = await ref.read(authProvider.notifier).signInWithKakao();

    if (success) {
      await AppHapticFeedback.success();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } else {
      await AppHapticFeedback.error();
    }
  }

  void _signInWithApple() async {
    await AppHapticFeedback.mediumImpact();

    final success = await ref.read(authProvider.notifier).signInWithApple();

    if (success) {
      await AppHapticFeedback.success();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } else {
      await AppHapticFeedback.error();
    }
  }

  // 유틸리티 메서드들

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '이메일을 입력해주세요';
    }
    if (!value.contains('@')) {
      return '올바른 이메일 형식이 아닙니다';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '이름을 입력해주세요';
    }
    if (value.trim().length < 2) {
      return '이름은 2글자 이상이어야 합니다';
    }
    return null;
  }

  String _getAccountTypeText(AccountType type) {
    switch (type) {
      case AccountType.student:
        return '학생 👨‍🎓';
      case AccountType.parent:
        return '학부모 👨‍👩‍👧‍👦';
      case AccountType.teacher:
        return '선생님 👨‍🏫';
      case AccountType.admin:
        return '관리자 👨‍💼';
    }
  }
}

/// 사용자 전환 화면 (프로필에서 접근)
class UserSwitchScreen extends ConsumerWidget {
  const UserSwitchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF235390),
      appBar: AppBar(
        title: const Text('계정 전환', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF235390), Color(0xFF1CB0F6)],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          itemCount: authState.availableAccounts.length + 1,
          itemBuilder: (context, index) {
            if (index == authState.availableAccounts.length) {
              // 새 계정 추가 버튼
              return Container(
                margin: const EdgeInsets.only(top: AppDimensions.spacingL),
                child: AnimatedButton(
                  text: '새 계정 추가',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AuthScreen(),
                      ),
                    );
                  },
                  gradientColors: AppColors.purpleGradient,
                  icon: Icons.add,
                ),
              );
            }

            final account = authState.availableAccounts[index];
            final isCurrent = account.id == authState.currentAccount?.id;

            return DuolingoCard(
              margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
              onTap: isCurrent
                  ? null
                  : () async {
                      await AppHapticFeedback.selectionClick();
                      await ref.read(authProvider.notifier).switchAccount(account.id);
                      Navigator.of(context).pop();
                    },
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(int.parse(account.accountColor.replaceFirst('#', '0xFF'))),
                  radius: 24,
                  child: Text(
                    account.avatarText,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  account.displayName,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                subtitle: Text(
                  '${account.email}\n${account.accountTypeText}',
                  style: AppTextStyles.bodySmall,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                trailing: isCurrent
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingS,
                          vertical: AppDimensions.spacingXS,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: AppColors.greenGradient),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                        ),
                        child: Text(
                          '현재',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : const Icon(Icons.arrow_forward_ios, size: 16),
                isThreeLine: true,
              ),
            );
          },
        ),
      ),
    );
  }

  /// 슬라이드 업 애니메이션으로 페이지 이동
  static PageRoute slideUpRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const AuthScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}