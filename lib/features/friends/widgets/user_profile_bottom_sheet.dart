import 'package:flutter/material.dart';
import '../../../data/models/models.dart';
import '../../../shared/constants/app_colors.dart';

/// 사용자 프로필 바텀시트
class UserProfileBottomSheet extends StatelessWidget {
  final User user;
  final VoidCallback onAddFriend;

  const UserProfileBottomSheet({
    super.key,
    required this.user,
    required this.onAddFriend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 핸들바
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 20),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 프로필 정보
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                user.avatarUrl,
                style: const TextStyle(fontSize: 48),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            user.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            user.email,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // 통계
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _UserStatRow(
                  label: '레벨',
                  value: '${user.level}',
                  icon: Icons.trending_up,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 16),
                _UserStatRow(
                  label: 'XP',
                  value: '${user.xp}',
                  icon: Icons.star,
                  color: AppColors.warning,
                ),
                const SizedBox(height: 16),
                _UserStatRow(
                  label: '스트릭',
                  value: '${user.streakDays}일',
                  icon: Icons.local_fire_department,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                _UserStatRow(
                  label: '학년',
                  value: user.currentGrade,
                  icon: Icons.school,
                  color: AppColors.success,
                ),
                const SizedBox(height: 16),
                _UserStatRow(
                  label: '등급',
                  value: user.userGrade,
                  icon: Icons.emoji_events,
                  color: AppColors.accentCyan,
                ),
              ],
            ),
          ),
          const Spacer(),

          // 친구 추가 버튼
          Container(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onAddFriend();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '친구 추가',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 사용자 통계 행 위젯
class _UserStatRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _UserStatRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}
