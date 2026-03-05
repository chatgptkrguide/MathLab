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

  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() => _isLoading = true);

    try {
      bool success;
      if (_isLogin) {
        success = await AuthHandler.handleEmailLogin(
          email: email,
          password: password,
          context: context,
          ref: ref,
          mounted: mounted,
        );
      } else {
        success = await AuthHandler.handleEmailSignup(
          email: email,
          password: password,
          context: context,
          ref: ref,
          mounted: mounted,
        );
      }

      if (mounted && success) {
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
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Blue gradient background (top area)
          Container(
            height: MediaQuery.of(context).size.height * 0.35,
            decoration: const BoxDecoration(
              gradient: AppColors.skyBlueGradient,
            ),
          ),
          const NoiseTexture(opacity: 0.03),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),
                // Header row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isLogin ? '로그인' : '회원가입',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // White card area
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              _isLogin ? '이메일로 로그인' : '이메일로 가입하기',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),

                            // Email field
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: '이메일',
                                hintText: '이메일을 입력하세요',
                                prefixIcon: const Icon(Icons.email_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppDimensions.radius12),
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
                                if (_formKey.currentState != null) {
                                  _formKey.currentState!.validate();
                                }
                              },
                            ),
                            const SizedBox(height: 12),

                            // Password field
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              decoration: InputDecoration(
                                labelText: '비밀번호',
                                hintText: _isLogin
                                    ? '비밀번호를 입력하세요'
                                    : '최소 6자 이상 입력하세요',
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
                                  borderRadius: BorderRadius.circular(
                                      AppDimensions.radius12),
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
                                if (_formKey.currentState != null) {
                                  _formKey.currentState!.validate();
                                }
                              },
                            ),

                            if (!_isLogin) ...[
                              const SizedBox(height: 6),
                              Text(
                                '비밀번호는 최소 6자 이상이어야 합니다',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Colors.grey),
                              ),
                            ],

                            const SizedBox(height: 20),

                            // Submit button
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient:
                                      _isLoading ? null : AppColors.deepBlueCTA,
                                  color: _isLoading
                                      ? AppColors.nodeLockedBg
                                      : null,
                                  borderRadius: BorderRadius.circular(
                                      AppDimensions.radius16),
                                ),
                                child: ElevatedButton(
                                  onPressed:
                                      _isLoading ? null : _handleSubmit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          AppDimensions.radius16),
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

                            const SizedBox(height: 12),

                            // Toggle login/signup
                            TextButton(
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      setState(() {
                                        _isLogin = !_isLogin;
                                        _formKey.currentState?.reset();
                                      });
                                    },
                              child: Text(
                                _isLogin
                                    ? '계정이 없으신가요? 가입하기'
                                    : '이미 계정이 있으신가요? 로그인',
                              ),
                            ),

                            if (_isLogin)
                              TextButton(
                                onPressed:
                                    _isLoading ? null : _handleForgotPassword,
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.textSecondary,
                                ),
                                child: const Text('비밀번호를 잊으셨나요?'),
                              ),

                            if (!_isLogin) ...[
                              const SizedBox(height: 12),
                              Text(
                                '가입하면 MathLab의 서비스 약관 및 개인정보 처리방침에 동의하게 됩니다.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                            ],

                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Loading overlay
          if (_isLoading)
            const Positioned.fill(
              child: ColoredBox(
                color: Colors.transparent,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleForgotPassword() async {
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
  }
}
