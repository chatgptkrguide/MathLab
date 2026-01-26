import 'package:flutter/material.dart';

/// 회원가입 뷰
class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
      ),
      body: const Center(
        child: Text('회원가입 화면'),
      ),
    );
  }
}
