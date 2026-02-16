// Wrong Answer Statistics
//
// Horizontal scrollable gradient stat cards

import 'package:flutter/material.dart';
import '../../../shared/constants/app_text_styles.dart';

class WrongAnswerStats extends StatelessWidget {
  final Map<String, int> statistics;

  const WrongAnswerStats({
    super.key,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    final total = statistics['total'] ?? 0;
    final unresolved = statistics['unresolved'] ?? 0;
    final resolved = statistics['resolved'] ?? 0;
    final needsReview = statistics['needsReview'] ?? 0;

    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _StatCard(
            icon: Icons.list_alt_rounded,
            value: total,
            label: '총 오답수',
            gradientColors: const [Color(0xFFFF6B6B), Color(0xFFEE5A24)],
          ),
          _StatCard(
            icon: Icons.error_outline_rounded,
            value: unresolved,
            label: '미해결',
            gradientColors: const [Color(0xFFFF9F43), Color(0xFFEE5A24)],
          ),
          _StatCard(
            icon: Icons.check_circle_outline_rounded,
            value: resolved,
            label: '해결완료',
            gradientColors: const [Color(0xFF58CC02), Color(0xFF26A302)],
          ),
          _StatCard(
            icon: Icons.replay_rounded,
            value: needsReview,
            label: '재시도 횟수',
            gradientColors: const [Color(0xFF1CB0F6), Color(0xFF1899D6)],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;
  final List<Color> gradientColors;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const Spacer(),
          Text(
            value.toString(),
            style: AppTextStyles.headlineMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
