// Statistics section — hero card (누적 XP) + 5-cell grid
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/user/user_model.dart';
import '../../../data/providers/lesson/lesson_progress_provider.dart';
import '../../../shared/constants/app_colors.dart';

class ProfileStatisticsSection extends ConsumerWidget {
  final UserModel user;

  /// Coachmark key for the statistics column.
  final Key? sectionKey;

  const ProfileStatisticsSection({
    super.key,
    required this.user,
    this.sectionKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressState = ref.watch(lessonProgressProvider(user.uid));
    final completedLessons = progressState.completedCount;
    final earnedStars = progressState.totalStars;

    final stats = [
      {
        'label': '챌린지 완료',
        'value': user.achievements.length.toString(),
        'icon': Icons.flag_rounded,
        'color': const Color(0xFFFF6B35),
      },
      {
        'label': '완료한 레슨',
        'value': completedLessons.toString(),
        'icon': Icons.check_circle_rounded,
        'color': AppColors.mathGreen,
      },
      {
        'label': '보유 다이아',
        'value': _formatNumber(user.gems),
        'icon': Icons.diamond_rounded,
        'color': const Color(0xFF42A5F5),
      },
      {
        'label': '누적 XP',
        'value': _formatNumber(user.totalXp),
        'icon': Icons.bolt_rounded,
        'color': AppColors.mathYellow,
      },
      {
        'label': '획득 별',
        'value': earnedStars.toString(),
        'icon': Icons.star_rounded,
        'color': const Color(0xFFFFB300),
      },
      {
        'label': '최장 연속',
        'value': '${user.longestStreak}일',
        'icon': Icons.local_fire_department_rounded,
        'color': const Color(0xFFFF7043),
      },
    ];

    return Column(
      key: sectionKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '나의 기록',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 14),
        // === Hero stat: 누적 XP를 전폭 featured 카드로 ===
        Builder(builder: (_) {
          final hero = stats.firstWhere((s) => s['label'] == '누적 XP',
              orElse: () => stats.first);
          final heroColor = (hero['color'] as Color?) ?? AppColors.mathYellow;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  heroColor.withValues(alpha: 0.18),
                  heroColor.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: heroColor.withValues(alpha: 0.25),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: heroColor,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: heroColor.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    (hero['icon'] as IconData?) ?? Icons.bolt_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (hero['label'] as String?) ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        (hero['value'] as String?) ?? '0',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark,
                          height: 1.05,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.trending_up_rounded,
                  color: heroColor,
                  size: 22,
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 12),
        // === Rest stats grid (5개, 마지막 한 칸 자연스럽게 빔) ===
        Builder(builder: (_) {
          final rest = stats.where((s) => s['label'] != '누적 XP').toList();
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.7,
            ),
            itemCount: rest.length,
            itemBuilder: (context, index) {
              final stat = rest[index];
              final statColor =
                  (stat['color'] as Color?) ?? AppColors.mathBlue;
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: statColor.withValues(alpha: 0.12),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: statColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        (stat['icon'] as IconData?) ?? Icons.star_rounded,
                        color: statColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            (stat['value'] as String?) ?? '0',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 1),
                          Text(
                            (stat['label'] as String?) ?? '',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ],
    );
  }
}

String _formatNumber(int number) {
  if (number >= 1000) {
    return '${(number / 1000).toStringAsFixed(number % 1000 == 0 ? 0 : 1)}k'
        .replaceAll('.0k', 'k');
  }
  return number.toString();
}
