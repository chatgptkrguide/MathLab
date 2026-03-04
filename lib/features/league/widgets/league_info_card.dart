// League Info Card Widget
//
// Shows user's status in the league (promotion/safe/relegation zone)
// with progress bar to next tier

import 'package:flutter/material.dart';
import '../../../data/models/league_model.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_text_styles.dart';

class LeagueInfoCard extends StatelessWidget {
  final UserLeagueStatus status;

  const LeagueInfoCard({
    super.key,
    required this.status,
  });

  Color _getStatusColor() {
    if (status.isPromotionZone) return Colors.green;
    if (status.isRelegationZone) return Colors.red;
    return AppColors.mathBlue;
  }

  IconData _getStatusIcon() {
    if (status.isPromotionZone) return Icons.trending_up;
    if (status.isRelegationZone) return Icons.trending_down;
    return Icons.check_circle;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border(
          left: BorderSide(color: statusColor, width: 4),
          top: BorderSide(color: statusColor.withValues(alpha: 0.15), width: 1),
          right: BorderSide(color: statusColor.withValues(alpha: 0.15), width: 1),
          bottom: BorderSide(color: statusColor.withValues(alpha: 0.15), width: 1),
        ),
      ),
      child: Column(
        children: [
          // Status Icon and Message
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getStatusIcon(),
                    color: statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    status.statusMessage,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Progress to promotion
          if (!status.isPromotionZone) ...[
            _buildProgressSection(statusColor),
            const SizedBox(height: 18),
          ],

          // Stats row
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  '다음 순위까지',
                  '${status.xpToNextRank} XP',
                  Icons.arrow_upward,
                ),

                const SizedBox(height: 10),
                Divider(color: AppColors.borderLight.withValues(alpha: 0.5), height: 1),
                const SizedBox(height: 10),

                if (status.isPromotionZone)
                  _buildInfoRow(
                    '승급권 유지 중',
                    '달성!',
                    Icons.star,
                  )
                else
                  _buildInfoRow(
                    '승급까지',
                    '${status.xpToPromotion} XP',
                    Icons.star,
                  ),

                const SizedBox(height: 14),

                // Statistics
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        '풀은 문제',
                        '${status.userEntry.problemsSolved}',
                        Icons.edit_note_rounded,
                        AppColors.mathBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        '정확도',
                        '${(status.userEntry.accuracy * 100).toStringAsFixed(1)}%',
                        Icons.check_circle_outline,
                        AppColors.mathGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(Color statusColor) {
    // Estimate progress ratio (xpToPromotion decreasing means closer)
    // Simple heuristic: show as a bar where 0 XP remaining = 100%
    final totalXpNeeded = status.xpToPromotion + status.userEntry.xp;
    final progress = totalXpNeeded > 0
        ? (status.userEntry.xp / totalXpNeeded).clamp(0.0, 1.0)
        : 0.0;
    final percent = (progress * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '승급 진행도',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '$percent%',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: AppColors.borderLight,
            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${status.xpToPromotion} XP 더 필요',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: AppColors.mathBlue,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
