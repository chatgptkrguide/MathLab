import 'package:flutter/material.dart';
import '../constants/figma_colors.dart';

/// Figma 디자인 공통 사용자 정보 바
/// 프로필 이미지, 스트릭, XP, 레벨 표시
class FigmaUserInfoBar extends StatelessWidget {
  final String userName;
  final int streakDays;
  final int xp;
  final String level;
  final String? profileImageUrl;

  const FigmaUserInfoBar({
    super.key,
    required this.userName,
    required this.streakDays,
    required this.xp,
    required this.level,
    this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        gradient: FigmaColors.homeGradient,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 프로필 + 사용자명
          Expanded(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  backgroundImage: profileImageUrl != null
                      ? NetworkImage(profileImageUrl!)
                      : null,
                  child: profileImageUrl == null
                      ? const Icon(Icons.person, color: Colors.white, size: 24)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // 통계 (스트릭, XP, 레벨)
          Row(
            children: [
              // 스트릭
              _buildStatItem(
                icon: '🔥',
                value: streakDays.toString(),
              ),
              const SizedBox(width: 12),
              // XP
              _buildStatItem(
                icon: '💎',
                value: xp.toString(),
              ),
              const SizedBox(width: 12),
              // 레벨 (winner.png 아이콘 사용)
              _buildStatItem(
                icon: '🏅', // 폴백용
                value: level,
                backgroundColor: Colors.red.shade700,
                isLevel: true, // 이미지 사용
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String icon,
    required String value,
    Color? backgroundColor,
    bool isLevel = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 레벨인 경우 이미지 사용, 아니면 이모지 사용
          if (isLevel)
            Image.asset(
              'assets/images/winner.png',
              width: 18,
              height: 18,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 18,
                );
              },
            )
          else
            Text(
              icon,
              style: const TextStyle(fontSize: 16),
            ),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
