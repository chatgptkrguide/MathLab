import 'package:flutter/material.dart';
import '../../../data/models/team_model.dart';
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5B8EC9), Color(0xFF61A1D8)],
        ),
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

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStat('멤버', '$memberCount/${team.maxMembers}'),
              Container(
                width: 1,
                height: 28,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              _buildStat('총 XP', _formatXp(team.totalXp)),
              Container(
                width: 1,
                height: 28,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              _buildStat('주간 XP', _formatXp(team.weeklyXp)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  String _formatXp(int xp) {
    if (xp >= 1000) return '${(xp / 1000).toStringAsFixed(1)}K';
    return xp.toString();
  }
}
