import 'package:flutter/material.dart';
import '../../../data/models/user/user_model.dart';

class HomeStatsCards extends StatelessWidget {
  final UserModel? user;

  const HomeStatsCards({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(child: _StatCard(icon: '⚡', label: 'XP', value: '${user?.xp ?? 0}')),
          const SizedBox(width: 12),
          Expanded(child: _StatCard(icon: '🎯', label: '레벨', value: '${user?.level ?? 1}')),
          const SizedBox(width: 12),
          Expanded(child: _StatCard(icon: '🔥', label: '연속', value: '${user?.streak ?? 0}일')),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _StatCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}
