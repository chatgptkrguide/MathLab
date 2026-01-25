/// 🎉 Weekly Results Dialog
///
/// Shows league end results with promotion/relegation status

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../data/services/league_management_service.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_text_styles.dart';

class WeeklyResultsDialog extends StatelessWidget {
  final Map<String, dynamic> results;

  const WeeklyResultsDialog({
    super.key,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    final action = results['action'] as String;
    final rewards = results['rewards'] as Map<String, dynamic>;
    final message = results['message'] as String;
    final stats = results['stats'] as Map<String, dynamic>;

    final isPromotion = action == LeagueAction.promotion.name;
    final isRelegation = action == LeagueAction.relegation.name;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with animation
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isPromotion
                      ? [Colors.green, Colors.green.shade700]
                      : isRelegation
                          ? [Colors.red, Colors.red.shade700]
                          : [AppColors.primary, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // Animation or Icon
                  if (isPromotion)
                    const Icon(
                      Icons.emoji_events,
                      size: 64,
                      color: Colors.white,
                    )
                  else if (isRelegation)
                    const Icon(
                      Icons.trending_down,
                      size: 64,
                      color: Colors.white,
                    )
                  else
                    const Icon(
                      Icons.check_circle,
                      size: 64,
                      color: Colors.white,
                    ),

                  const SizedBox(height: 16),

                  Text(
                    isPromotion
                        ? '승급!'
                        : isRelegation
                            ? '강등'
                            : '리그 종료',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Result message
                  Text(
                    message,
                    style: AppTextStyles.bodyLarge,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),

                  // Stats
                  _buildStatRow('최종 순위', '#${stats['rank']}'),
                  const SizedBox(height: 12),
                  _buildStatRow('획득 XP', '${stats['xp']} XP'),
                  const SizedBox(height: 12),
                  _buildStatRow('정확도', '${(stats['accuracy'] * 100).toStringAsFixed(1)}%'),
                  const SizedBox(height: 12),
                  _buildStatRow('상위', '${stats['percentile']}%'),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),

                  // Rewards
                  Text(
                    '보상',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildRewardItem(
                              '⭐',
                              '${rewards['xp']} XP',
                            ),
                            if ((rewards['gems'] as int) > 0)
                              _buildRewardItem(
                                '💎',
                                '${rewards['gems']} 젬',
                              ),
                          ],
                        ),
                        if ((rewards['badges'] as List).isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: (rewards['badges'] as List)
                                .map((badge) => Chip(
                                      label: Text(
                                        badge.toString(),
                                        style: AppTextStyles.bodySmall,
                                      ),
                                      backgroundColor: Colors.amber.shade100,
                                    ))
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Close button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('확인'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRewardItem(String icon, String label) {
    return Column(
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 32),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
