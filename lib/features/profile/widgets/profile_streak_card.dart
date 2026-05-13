// Streak card — daily dots + flame counter
import 'package:flutter/material.dart';

import '../../../data/models/user/user_model.dart';
import '../../../shared/constants/app_colors.dart';

class ProfileStreakCard extends StatelessWidget {
  final UserModel user;

  const ProfileStreakCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final streakDays = user.streak;
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final today = DateTime.now().weekday; // 1=Mon, 7=Sun

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFD9B3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Top: streak count + flame
          Row(
            children: [
              // Big flame + number
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6D00),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    streakDays.toString(),
                    style: TextStyle(
                      fontSize: streakDays >= 100 ? 18 : 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          '🔥 연속 학습',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF18181B),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6D00)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$streakDays일째',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFE65100),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      streakDays == 0
                          ? '오늘 학습하고 스트릭을 시작하세요!'
                          : '꾸준히 하고 있어요! 계속 달려보세요 💪',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Week progress dots
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (i) {
              final dayIndex = i + 1; // 1=Mon
              final isToday = dayIndex == today;
              // Show as completed if within streak range
              final isCompleted =
                  dayIndex <= today && (today - dayIndex) < streakDays;
              return Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? const Color(0xFFFF6D00)
                          : isToday
                              ? const Color(0xFFFF6D00).withValues(alpha: 0.15)
                              : const Color(0xFFE0E0E0).withValues(alpha: 0.5),
                      border: isToday && !isCompleted
                          ? Border.all(
                              color: const Color(0xFFFF6D00), width: 2)
                          : null,
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check_rounded,
                            size: 18, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    weekdays[i],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          isToday ? FontWeight.w700 : FontWeight.w500,
                      color: isToday
                          ? const Color(0xFFE65100)
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
