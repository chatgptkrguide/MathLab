import 'package:flutter/material.dart';
import '../../../../data/models/user/user.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/utils/level_badge_mapper.dart';
import '../../../../shared/widgets/premium/premium_badge.dart';
import '../../edit_profile_screen.dart';

/// 사용자 프로필 카드 위젯
class UserProfileCard extends StatelessWidget {
  final User? user;

  const UserProfileCard({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final userLevel = user?.level ?? 1;
    final tierColor = Color(LevelBadgeMapper.getTierColor(userLevel));
    final rankName = LevelBadgeMapper.getRankName(userLevel);
    final progress = user?.levelProgress ?? 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            const Color(0xFFE3F2FD).withOpacity(0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // 프로필 사진 + 이름 + Edit 버튼 + 알림 아이콘
          Row(
            children: [
              // 프로필 사진 (파란 그라디언트 배경, 원형, 통일된 디자인)
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.mathButtonGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.mathBlue.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: user?.avatarUrl != null && user!.avatarUrl.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          user!.avatarUrl,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Center(
                        child: Text(
                          user?.name[0] ?? '학',
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: AppColors.surface,
                          ),
                        ),
                      ),
              ),

              const SizedBox(width: 16),

              // 이름 + 유저명 + Edit Profile 버튼
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user?.name ?? 'Jojo Selvey',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const PremiumBadge(
                          size: PremiumBadgeSize.small,
                          style: PremiumBadgeStyle.iconOnly,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${user?.email.split('@').first ?? 'jojoselvey04'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Edit Profile 버튼
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1A1A1A),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 알림 아이콘
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.notifications_none,
                  color: Color(0xFF1A1A1A),
                  size: 22,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 레벨 뱃지 + 진행률
          Row(
            children: [
              // 레벨 뱃지 아이콘
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [tierColor, tierColor.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: tierColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(6),
                child: Image.asset(
                  LevelBadgeMapper.getBadgeImagePath(userLevel),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 24,
                    );
                  },
                ),
              ),

              const SizedBox(width: 12),

              // 레벨명 + 진행률
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          rankName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: tierColor,
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // 진행률 바
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                        ),
                        child: Stack(
                          children: [
                            FractionallySizedBox(
                              widthFactor: progress,
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.mathRed,
                                      AppColors.mathOrange,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
