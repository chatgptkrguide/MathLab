import 'package:flutter/material.dart';

import '../../../shared/constants/constants.dart';
import '../../../data/models/user/user_model.dart';

/// 설정 화면 사용자 정보 섹션
/// - 프로필 사진, 이름, 이메일 표시
class UserInfoSection extends StatelessWidget {
  final UserModel? user;
  final VoidCallback? onTap;

  const UserInfoSection({
    super.key,
    required this.user,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLarge,
        vertical: AppDimensions.paddingMedium,
      ),
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.mathBlue.withValues(alpha: 0.08),
            AppColors.mathPurple.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(
          color: AppColors.mathBlue.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.mathBlue.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 프로필 이미지
          _buildAvatar(),
          const SizedBox(width: AppDimensions.paddingMedium),

          // 사용자 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? '사용자',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (user?.email != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    user!.email!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 6),
                _buildLevelBadge(),
              ],
            ),
          ),

          // Chevron to indicate tappability
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.mathBlue,
            size: 24,
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.mathBlue.withValues(alpha: 0.1),
        border: Border.all(
          color: AppColors.mathBlue.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: user?.photoUrl != null
          ? ClipOval(
              child: Image.network(
                user!.photoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.person,
                    size: 28,
                    color: AppColors.mathBlue,
                  );
                },
              ),
            )
          : const Icon(
              Icons.person,
              size: 28,
              color: AppColors.mathBlue,
            ),
    );
  }

  Widget _buildLevelBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.mathOrange.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        'Lv.${user?.level ?? 1}',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.mathOrange,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}
