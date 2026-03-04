// 📧 Email Login Screen
//
// Provides email/password authentication with form validation and error handling.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/security/input_validator.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_dimensions.dart';
import '../../shared/widgets/effects/noise_texture.dart';
import 'logic/auth_handler.dart';

class EmailLoginScreen extends ConsumerStatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  ConsumerState<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends ConsumerState<EmailLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLogin = true; // true = login, false = signup
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Get form values
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() => _isLoading = true);

    try {
      bool success;
      if (_isLogin) {
        // Login
        success = await AuthHandler.handleEmailLogin(
          email: email,
          password: password,
          context: context,
          ref: ref,
          mounted: mounted,
        );
      } else {
        // Signup
        success = await AuthHandler.handleEmailSignup(
          email: email,
          password: password,
          context: context,
          ref: ref,
          mounted: mounted,
        );
      }

      if (mounted && success) {
        // Pop back - AuthWrapper will handle navigation via state change
        Navigator.of(context).pop(true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? '로그인' : '회원가입'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // Subtle background gradient (Anti-AI: not pure white)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF8F9FA), Colors.white],
              ),
            ),
          ),
          // Noise texture overlay
          const NoiseTexture(opacity: 0.025),
          SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.spacing24,
            AppDimensions.spacing20,
            AppDimensions.spacing24,
            AppDimensions.spacing24,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppDimensions.spacing36),

                // Title
                Text(
                  _isLogin ? '이메일로 로그인' : '이메일로 가입하기',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppDimensions.spacing36),

                // Form card with left border accent (Anti-AI: handcrafted detail)
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: AppColors.skyBlue,
                        width: 3,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.only(left: AppDimensions.spacing14),
                  child: Column(
                    children: [

                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: '이메일',
                    hintText: '이메일을 입력하세요',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radius12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '이메일을 입력해주세요';
                    }

                    final sanitized = value.trim();
                    if (!InputValidator.isValidEmail(sanitized)) {
                      return '유효한 이메일 주소를 입력해주세요';
                    }

                    return null;
                  },
                  onChanged: (value) {
                    // Clear validation error when user types
                    if (_formKey.currentState != null) {
                      _formKey.currentState!.validate();
                    }
                  },
                ),

                const SizedBox(height: AppDimensions.spacing14),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    hintText: _isLogin ? '비밀번호를 입력하세요' : '최소 6자 이상 입력하세요',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radius12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호를 입력해주세요';
                    }

                    if (!_isLogin && value.length < 6) {
                      return '비밀번호는 최소 6자 이상이어야 합니다';
                    }

                    return null;
                  },
                  onFieldSubmitted: (_) => _handleSubmit(),
                  onChanged: (value) {
                    // Clear validation error when user types
                    if (_formKey.currentState != null) {
                      _formKey.currentState!.validate();
                    }
                  },
                ),

                if (!_isLogin) ...[
                  const SizedBox(height: AppDimensions.spacing8),
                  Text(
                    '비밀번호는 최소 6자 이상이어야 합니다',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],

                    ], // Close left-border Column children
                  ), // Close left-border Container
                ), // Close left-border padding

                const SizedBox(height: AppDimensions.spacing28),

                // Submit Button (Anti-AI: gradient filled main CTA)
                SizedBox(
                  width: double.infinity,
                  height: AppDimensions.buttonHeightLarge,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: _isLoading ? null : AppColors.deepBlueCTA,
                      color: _isLoading ? AppColors.nodeLockedBg : null,
                      borderRadius: BorderRadius.circular(AppDimensions.radius16),
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacing16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radius16),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _isLogin ? '로그인' : '가입하기',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.spacing18),

                // Toggle Login/Signup (Anti-AI: text-only tertiary button)
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          setState(() {
                            _isLogin = !_isLogin;
                            // Clear form
                            _formKey.currentState?.reset();
                          });
                        },
                  child: Text(
                    _isLogin
                        ? '계정이 없으신가요? 가입하기'
                        : '이미 계정이 있으신가요? 로그인',
                  ),
                ),

                if (_isLogin) ...[
                  const SizedBox(height: AppDimensions.spacing4),

                  // Forgot Password (Anti-AI: text-only, subtle)
                  TextButton(
                    onPressed: _isLoading ? null : _handleForgotPassword,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                    ),
                    child: const Text('비밀번호를 잊으셨나요?'),
                  ),
                ],

                const SizedBox(height: AppDimensions.spacing32),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '또는',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: AppDimensions.spacing20),

                // Social Login Buttons (Anti-AI: outlined secondary style, different from main CTA)
                OutlinedButton.icon(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          final success = await AuthHandler.handleGoogleLogin(
                            context: context,
                            ref: ref,
                            mounted: mounted,
                          );

                          if (mounted && success && context.mounted) {
                            Navigator.of(context).pop(true);
                          }
                        },
                  icon: const Icon(Icons.g_mobiledata),
                  label: const Text('Google로 계속하기'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radius12),
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.spacing12),

                OutlinedButton.icon(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          final success = await AuthHandler.handleKakaoLogin(
                            context: context,
                            ref: ref,
                            mounted: mounted,
                          );

                          if (mounted && success && context.mounted) {
                            Navigator.of(context).pop(true);
                          }
                        },
                  icon: const Icon(Icons.chat_bubble),
                  label: const Text('Kakao로 계속하기'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: AppColors.kakaoYellow,
                    foregroundColor: AppColors.kakaoBrown,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radius12),
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.spacing36),

                // Terms and Privacy
                if (!_isLogin)
                  Text(
                    '가입하면 MathLab의 서비스 약관 및 개인정보 처리방침에 동의하게 됩니다.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ),
      ),
        ], // Close Stack children
      ), // Close Stack
    );
  }

  Future<void> _handleForgotPassword() async {
    // Show dialog to enter email for password reset
    final emailController = TextEditingController();

    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('비밀번호 재설정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('이메일 주소를 입력하시면 비밀번호 재설정 링크를 보내드립니다.'),
            const SizedBox(height: 16),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: '이메일',
                hintText: '가입한 이메일을 입력하세요',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();

              if (!InputValidator.isValidEmail(email)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('유효한 이메일 주소를 입력해주세요')),
                );
                return;
              }

              Navigator.of(context).pop(true);

              // 다이얼로그 닫은 후 비밀번호 재설정 이메일 전송
              await AuthHandler.sendPasswordResetEmail(
                email: email,
                context: this.context,
                mounted: mounted,
              );
            },
            child: const Text('전송'),
          ),
        ],
      ),
    );

    // 스낵바는 AuthHandler.sendPasswordResetEmail 에서 처리됨
  }
}
