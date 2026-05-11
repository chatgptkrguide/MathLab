// Home action buttons — stacked full-width CTAs (assignments, AI tutor, chat).
import 'package:flutter/material.dart';

class HomeActionButtons extends StatelessWidget {
  final VoidCallback onAssignmentsTap;
  final VoidCallback onAiTutorTap;
  final VoidCallback onChatTap;

  const HomeActionButtons({
    super.key,
    required this.onAssignmentsTap,
    required this.onAiTutorTap,
    required this.onChatTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Blue: Assignments & Weekly Tests
        _ActionItem(
          color: const Color(0xFF3195FF),
          shadowColor: const Color(0xFF1C7CE2),
          icon: Icons.assignment_rounded,
          iconBgOpacity: 0.5,
          label: '과제  및 주간테스트 확인 & 제출',
          borderRadius: 8,
          onTap: onAssignmentsTap,
        ),
        const SizedBox(height: 16),
        // Light purple: AI Tutor
        _ActionItem(
          color: const Color(0xFFA2B6FF),
          shadowColor: const Color(0xFF499609),
          icon: Icons.smart_toy_rounded,
          label: 'AI 튜터에게 물어보세요',
          borderRadius: 14,
          onTap: onAiTutorTap,
          comingSoon: true,
        ),
        const SizedBox(height: 16),
        // Dark blue: Chat
        _ActionItem(
          color: const Color(0xFF0F31AC),
          shadowColor: const Color(0xFFD27312),
          icon: Icons.chat_rounded,
          label: '맴버들 채팅하기',
          borderRadius: 14,
          onTap: onChatTap,
          comingSoon: true,
        ),
      ],
    );
  }
}

class _ActionItem extends StatelessWidget {
  final Color color;
  final Color shadowColor;
  final IconData icon;
  final String label;
  final double borderRadius;
  final double iconBgOpacity;
  final VoidCallback onTap;
  final bool comingSoon;

  const _ActionItem({
    required this.color,
    required this.shadowColor,
    required this.icon,
    required this.label,
    required this.borderRadius,
    this.iconBgOpacity = 0.12,
    required this.onTap,
    this.comingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: iconBgOpacity),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (comingSoon) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: const Text(
                  '출시 예정',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ],
        ),
      ),
    );
  }
}
