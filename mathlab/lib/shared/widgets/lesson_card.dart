import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_dimensions.dart';

/// 레슨 카드 위젯
/// 커리큘럼 화면에서 각 레슨을 표시하는데 사용
class LessonCard extends StatelessWidget {
  final String icon;
  final String title;
  final String description;
  final double progress;
  final bool isLocked;
  final VoidCallback? onTap;

  const LessonCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.progress,
    this.isLocked = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = !isLocked && onTap != null;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: AppDimensions.spacingXS,
      ),
      child: Card(
        elevation: AppDimensions.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Row(
              children: [
                _buildIcon(),
                const SizedBox(width: AppDimensions.spacingL),
                Expanded(child: _buildContent()),
                const SizedBox(width: AppDimensions.spacingS),
                _buildTrailingIcon(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: AppDimensions.iconXXL,
      height: AppDimensions.iconXXL,
      decoration: BoxDecoration(
        color: isLocked
            ? AppColors.disabled.withValues(alpha: 0.1)
            : AppColors.secondaryBlue,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Center(
        child: Text(
          icon,
          style: AppTextStyles.emojiLarge.copyWith(
            color: isLocked ? AppColors.disabled : null,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: AppTextStyles.titleLarge.copyWith(
            color: isLocked ? AppColors.disabled : AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppDimensions.spacingXS),
        Flexible(
          child: Text(
            description,
            style: AppTextStyles.bodySmall.copyWith(
              color: isLocked ? AppColors.disabled : AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingS),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                '진행률',
                style: AppTextStyles.labelSmall.copyWith(
                  color: isLocked ? AppColors.disabled : AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: AppTextStyles.progressText.copyWith(
                color: isLocked ? AppColors.disabled : AppColors.primaryBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingXS),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: AppColors.progressBackground,
          valueColor: AlwaysStoppedAnimation(
            isLocked ? AppColors.disabled : AppColors.progressActive,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusS / 2),
          minHeight: AppDimensions.progressBarMinHeight,
        ),
      ],
    );
  }

  Widget _buildTrailingIcon() {
    if (isLocked) {
      return Icon(
        Icons.lock_outline,
        color: AppColors.disabled,
        size: AppDimensions.iconM,
      );
    }

    return Icon(
      Icons.chevron_right,
      color: AppColors.textSecondary,
      size: AppDimensions.iconM,
    );
  }
}