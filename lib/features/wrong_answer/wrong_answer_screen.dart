import 'package:flutter/material.dart';

class WrongAnswerScreen extends StatelessWidget {
  const WrongAnswerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('오답 노트')),
      body: const Center(child: Text('오답 노트 화면')),
    );
  }
}
