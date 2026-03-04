// League Header Widget
//
// Displays tier badge with gradient glow, league name, and user rank

import 'package:flutter/material.dart';
import '../../../data/models/league_model.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../shared/widgets/effects/noise_texture.dart';

class LeagueHeader extends StatelessWidget {
  final UserLeagueStatus status;

  const LeagueHeader({
    super.key,
    required this.status,
  });

  /// Tier-specific gradient colors
  List<Color> _getTierGradient() {
    final tier = status.league.displayTier.toLowerCase();
    if (tier.contains('diamond') || tier.contains('다이아')) {
      return [const Color(0xFF42A5F5), const Color(0xFF1E88E5)];
    } else if (tier.contains('gold') || tier.contains('골드')) {
      return [const Color(0xFFFFD700), const Color(0xFFFFA000)];
    } else if (tier.contains('silver') || tier.contains('실버')) {
      return [const Color(0xFFB0BEC5), const Color(0xFF78909C)];
    } else if (tier.contains('master') || tier.contains('마스터')) {
      return [const Color(0xFF7E57C2), const Color(0xFF5E35B1)];
    }
    // Bronze default
    return [const Color(0xFFCD7F32), const Color(0xFFA0622E)];
  }

  Color _getTierGlowColor() {
    final tier = status.league.displayTier.toLowerCase();
    if (tier.contains('diamond') || tier.contains('다이아')) {
      return const Color(0xFF42A5F5);
    } else if (tier.contains('gold') || tier.contains('골드')) {
      return const Color(0xFFFFD700);
    } else if (tier.contains('silver') || tier.contains('실버')) {
      return const Color(0xFFB0BEC5);
    } else if (tier.contains('master') || tier.contains('마스터')) {
      return const Color(0xFF7E57C2);
    }
    return const Color(0xFFCD7F32);
  }

  @override
  Widget build(BuildContext context) {
    final tierColors = _getTierGradient();
    final glowColor = _getTierGlowColor();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: tierColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: NoiseTexture(opacity: 0.02)),
          Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      child: Column(
        children: [
          // Tier Icon with animated glow effect
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: glowColor.withValues(alpha: 0.5),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Center(
              child: Text(
                status.league.tierIcon,
                style: const TextStyle(fontSize: 52),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // League Name
          Text(
            status.league.name,
            style: AppTextStyles.headlineMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 6),

          // Tier
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status.league.displayTier,
              style: AppTextStyles.titleMedium.copyWith(
                color: Colors.white.withValues(alpha: 0.95),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 18),

          // User Rank badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.emoji_events,
                  color: tierColors[0],
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '현재 순위',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '#${status.userEntry.rank}',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: tierColors[0],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // XP
          Text(
            '${status.userEntry.xp} XP',
            style: AppTextStyles.titleMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
          ),
        ],
      ),
    );
  }
}
