// Home daily challenge card — gold card linking to the team/challenge tab.
import 'package:flutter/material.dart';

import '../../../shared/constants/app_colors.dart';
import '../home_screen.dart';

class HomeDailyChallenge extends StatelessWidget {
  final VoidCallback onTap;

  const HomeDailyChallenge({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: HomeScreenFigma.dailyChallengeKey,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.gold,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '데일리 챌린지',
                    style: TextStyle(
                      color: Color(0xFF0D061F),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '오늘의 챌린지 미션을 완료해 보세요',
                    style: TextStyle(
                      color: Color(0xFF0D061F),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFB5523),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF921B7A),
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Text(
                      '데일리 챌린지 미션',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Character illustration placeholder
            Image.asset(
              'assets/icons/challenge_character.png',
              width: 94,
              height: 95,
              errorBuilder: (_, __, ___) => const SizedBox(
                width: 94,
                height: 95,
                child: Icon(Icons.emoji_events_rounded, size: 48, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
