// Badges section — 3 achievement badges (current MVP placeholders)
import 'package:flutter/material.dart';

import '../../../data/models/user/user_model.dart';
import '../../../shared/constants/app_colors.dart';

class ProfileBadgesSection extends StatelessWidget {
  final UserModel user;

  /// Coachmark key for the badges column.
  final Key? sectionKey;

  const ProfileBadgesSection({
    super.key,
    required this.user,
    this.sectionKey,
  });

  @override
  Widget build(BuildContext context) {
    final badges = [
      {
        'name': '첫번째 챌린지 완성',
        'icon': Icons.emoji_events_rounded,
        'color': AppColors.streakGold,
      },
      {
        'name': '연속학습 달성',
        'icon': Icons.local_fire_department_rounded,
        'color': const Color(0xFFFF6B35),
      },
      {
        'name': '챌린지 마스터',
        'icon': Icons.workspace_premium_rounded,
        'color': const Color(0xFF7E57C2),
      },
    ];

    return Column(
      key: sectionKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '보유 뱃지',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF18181B),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: badges.map((badge) {
            final achieved = user.achievements.isNotEmpty;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                    right: badge != badges.last ? 10.0 : 0.0),
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${badge['name']}'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: achieved
                              ? ((badge['color'] as Color?) ??
                                      AppColors.mathBlue)
                                  .withValues(alpha: 0.15)
                              : AppColors.cardBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          (badge['icon'] as IconData?) ?? Icons.star_rounded,
                          size: 28,
                          color: achieved
                              ? (badge['color'] as Color?) ??
                                  AppColors.mathBlue
                              : AppColors.borderDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        (badge['name'] as String?) ?? '',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: achieved
                              ? const Color(0xFF18181B)
                              : AppColors.textLight,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
