import 'package:flutter/material.dart';

class LeagueScreen extends StatelessWidget {
  const LeagueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('리그')),
      body: const Center(child: Text('리그 화면')),
    );
  }
}
