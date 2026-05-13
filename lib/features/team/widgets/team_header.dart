import 'package:flutter/material.dart';
import '../../../data/models/team_model.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_text_styles.dart';

class TeamHeader extends StatelessWidget {
  final TeamModel team;
  final int memberCount;

  const TeamHeader({
    super.key,
    required this.team,
    required this.memberCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      decoration: const BoxDecoration(
        color: AppColors.primaryDark,
      ),
      child: Column(
        children: [
          // Team icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                team.displayIcon,
                style: const TextStyle(fontSize: 40),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Team name
          Text(
            team.name,
            style: AppTextStyles.headlineMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          if (team.description != null && team.description!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              team.description!,
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: 18),

          // Stats row — 주간 XP featured (flex:2), 멤버·총 XP compact (flex:1)
          Row(
            children: [
              Expanded(
                child: _buildStat('멤버', '$memberCount/${team.maxMembers}'),
              ),
              Container(
                width: 1,
                height: 28,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _buildStat('총 XP', _formatXp(team.totalXp)),
              ),
              Container(
                width: 1,
                height: 28,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              Expanded(
                flex: 2,
                child: _buildStat('주간 XP', _formatXp(team.weeklyXp),
                    featured: true),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, {bool featured = false}) {
    return Column(
      children: [
        Text(
          value,
          style: (featured ? AppTextStyles.headlineSmall : AppTextStyles.titleMedium)
              .copyWith(
            color: Colors.white,
            fontWeight: featured ? FontWeight.w900 : FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: Colors.white.withValues(alpha: featured ? 0.9 : 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _formatXp(int xp) {
    if (xp >= 1000) return '${(xp / 1000).toStringAsFixed(1)}K';
    return xp.toString();
  }
}
