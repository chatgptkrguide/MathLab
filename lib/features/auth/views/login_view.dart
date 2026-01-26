import 'package:flutter/material.dart';

/// 로그인 뷰
class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인'),
      ),
      body: const Center(
        child: Text('로그인 화면'),
      ),
    );
  }
}
