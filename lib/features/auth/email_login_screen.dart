import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/app_colors.dart';
import '../../data/services/firebase_auth_service.dart';
import '../../data/providers/auth/auth_provider.dart';

/// 이메일 로그인/회원가입 화면
class EmailLoginScreen extends ConsumerStatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  ConsumerState<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends ConsumerState<EmailLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  final FirebaseAuthService _authService = FirebaseAuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        // 로그인
        final userCredential = await _authService.signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (userCredential != null && mounted) {
          // AuthProvider를 통해 계정 정보 업데이트
          final success =
              await ref.read(authProvider.notifier).signInWithEmailPassword(
                    email: _emailController.text.trim(),
                    displayName: userCredential.user?.displayName ?? '사용자',
                    uid: userCredential.user?.uid ?? '',
                  );

          if (success && mounted) {
            Navigator.of(context).pop(true);
          }
        }
      } else {
        // 회원가입
        final userCredential = await _authService.signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (userCredential != null) {
          // 사용자 이름 업데이트
          await userCredential.user
              ?.updateDisplayName(_nameController.text.trim());

          if (mounted) {
            // 회원가입 후 자동 로그인
            final success =
                await ref.read(authProvider.notifier).signInWithEmailPassword(
                      email: _emailController.text.trim(),
                      displayName: _nameController.text.trim(),
                      uid: userCredential.user?.uid ?? '',
                    );

            if (success && mounted) {
              Navigator.of(context).pop(true);
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.mathRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF211E41),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _isLogin ? '로그인' : '회원가입',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // 로고 또는 아이콘
                const Icon(
                  Icons.school,
                  size: 80,
                  color: AppColors.mathBlue,
                ),

                const SizedBox(height: 40),

                // 이름 입력 (회원가입일 때만)
                if (!_isLogin) ...[
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: '이름',
                      labelStyle:
                          TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon:
                          const Icon(Icons.person, color: Colors.white70),
                    ),
                    validator: (value) {
                      if (!_isLogin &&
                          (value == null || value.trim().isEmpty)) {
                        return '이름을 입력하세요';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // 이메일 입력
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: '이메일',
                    labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.email, color: Colors.white70),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '이메일을 입력하세요';
                    }
                    if (!value.contains('@')) {
                      return '올바른 이메일을 입력하세요';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // 비밀번호 입력
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호를 입력하세요';
                    }
                    if (!_isLogin && value.length < 6) {
                      return '비밀번호는 6자 이상이어야 합니다';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // 로그인/회원가입 버튼
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mathGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _isLogin ? '로그인' : '회원가입',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),

                const SizedBox(height: 16),

                // 전환 버튼
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                    });
                  },
                  child: Text(
                    _isLogin ? '계정이 없으신가요? 회원가입' : '이미 계정이 있으신가요? 로그인',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                ),

                if (_isLogin) ...[
                  TextButton(
                    onPressed: () async {
                      // 비밀번호 재설정 다이얼로그
                      final emailController = TextEditingController();
                      await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: const Color(0xFF2D2A4A),
                          title: const Text(
                            '비밀번호 재설정',
                            style: TextStyle(color: Colors.white),
                          ),
                          content: TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: '이메일을 입력하세요',
                              hintStyle: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5)),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('취소'),
                            ),
                            TextButton(
                              onPressed: () async {
                                if (emailController.text.isNotEmpty) {
                                  final navigator = Navigator.of(context);
                                  await _authService.sendPasswordResetEmail(
                                    emailController.text.trim(),
                                  );
                                  if (mounted) {
                                    navigator.pop();
                                    _showError('비밀번호 재설정 이메일을 전송했습니다');
                                  }
                                }
                              },
                              child: const Text('전송'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Text(
                      '비밀번호를 잊으셨나요?',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
