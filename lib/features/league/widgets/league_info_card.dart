/// 9 League Info Card Widget
///
/// Shows user's status in the league (promotion/safe/relegation zone)

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
    return AppColors.primary;
  }

  IconData _getStatusIcon() {
    if (status.isPromotionZone) return Icons.trending_up;
    if (status.isRelegationZone) return Icons.trending_down;
    return Icons.check_circle;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStatusColor().withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Status Icon and Message
          Row(
            children: [
              Icon(
                _getStatusIcon(),
                color: _getStatusColor(),
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  status.statusMessage,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: _getStatusColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // XP to Next Rank
                _buildInfoRow(
                  '‰L L¿',
                  '${status.xpToNextRank} XP',
                  Icons.arrow_upward,
                ),

                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),

                // XP to Promotion
                if (status.isPromotionZone)
                  _buildInfoRow(
                    'π	  ¿',
                    'ƒç x%X8î!',
                    Icons.star,
                  )
                else
                  _buildInfoRow(
                    'π	L¿',
                    '${status.xpToPromotion} XP',
                    Icons.star,
                  ),

                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),

                // Statistics
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn(
                      '8 Ät',
                      '${status.userEntry.problemsSolved}',
                      Icons.edit,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey[300],
                    ),
                    _buildStatColumn(
                      'Uƒ',
                      '${(status.userEntry.accuracy * 100).toStringAsFixed(1)}%',
                      Icons.check_circle,
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

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[900],
          ),
        ),
      ],
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[900],
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
