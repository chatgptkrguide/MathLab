import 'package:flutter/material.dart';

import '../../../shared/constants/constants.dart';
import '../../../data/models/user/user_model.dart';

/// 설정 화면 사용자 정보 섹션
/// - 프로필 사진, 이름, 이메일 표시
class UserInfoSection extends StatelessWidget {
  final UserModel? user;

  const UserInfoSection({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLarge,
        vertical: AppDimensions.paddingMedium,
      ),
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: AppColors.borderLight),
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
                  style: AppTextStyles.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (user?.email != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    user!.email!,
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                _buildLevelBadge(),
              ],
            ),
          ),
        ],
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
