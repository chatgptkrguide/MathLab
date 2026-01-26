import 'package:flutter/material.dart';

/// 계정 전환 뷰
class AccountSwitcherView extends StatelessWidget {
  const AccountSwitcherView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('계정 전환'),
      ),
      body: const Center(
        child: Text('계정 전환 화면'),
      ),
    );
  }
}
