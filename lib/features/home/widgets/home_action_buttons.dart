import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_dimensions.dart';
import '../../../shared/constants/app_text_styles.dart';

/// Home screen CTA section with visual hierarchy:
/// - Featured card (full width) on top
/// - Two smaller buttons below in a row with distinct styles
class HomeActionButtons extends StatelessWidget {
  const HomeActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing20),
      child: Column(
        children: [
          // Featured card: full width, horizontal layout with left border accent
          _FeaturedActionCard(
            icon: Icons.assignment_rounded,
            label: '과제 및 주간테스트',
            sublabel: '확인 & 제출',
            color: AppColors.tealGreen,
            onTap: () {},
          ),
          const SizedBox(height: AppDimensions.spacing12),
          // Two secondary buttons in a row with different styles
          Row(
            children: [
              Expanded(
                child: _OutlinedActionButton(
                  icon: Icons.smart_toy_rounded,
                  label: 'AI 튜터에게',
                  sublabel: '물어보세요',
                  color: AppColors.royalBlue,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: AppDimensions.spacing12),
              Expanded(
                child: _CompactActionButton(
                  icon: Icons.chat_rounded,
                  label: '멤버들',
                  sublabel: '채팅하기',
                  color: AppColors.mathPurple,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Featured action card: full width, horizontal layout with left border accent
class _FeaturedActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? sublabel;
  final Color color;
  final VoidCallback onTap;

  const _FeaturedActionCard({
    required this.icon,
    required this.label,
    this.sublabel,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spacing16,
          horizontal: AppDimensions.spacing16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radius16),
          border: const Border(
            left: BorderSide(
              color: AppColors.tealGreen,
              width: 4,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppDimensions.radius12),
              ),
              child: Icon(icon, color: color, size: AppDimensions.iconMedium),
            ),
            const SizedBox(width: AppDimensions.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.labelSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (sublabel != null) ...[
                    const SizedBox(height: AppDimensions.spacing2),
                    Text(
                      sublabel!,
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 10,
                        color: color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: color.withValues(alpha: 0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

/// Outlined action button: no fill, border only
class _OutlinedActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? sublabel;
  final Color color;
  final VoidCallback onTap;

  const _OutlinedActionButton({
    required this.icon,
    required this.label,
    this.sublabel,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spacing16,
          horizontal: AppDimensions.spacing8,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.0),
          borderRadius: BorderRadius.circular(AppDimensions.radius16),
          border: Border.all(
            color: AppColors.royalBlue,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppDimensions.radius12),
              ),
              child: Icon(icon, color: color, size: AppDimensions.iconMedium),
            ),
            const SizedBox(height: AppDimensions.spacing8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.labelSmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.royalBlue,
                height: 1.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (sublabel != null) ...[
              const SizedBox(height: AppDimensions.spacing2),
              Text(
                sublabel!,
                textAlign: TextAlign.center,
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 10,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Compact action button: filled white, smaller padding
class _CompactActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? sublabel;
  final Color color;
  final VoidCallback onTap;

  const _CompactActionButton({
    required this.icon,
    required this.label,
    this.sublabel,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spacing12,
          horizontal: AppDimensions.spacing8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radius16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppDimensions.radius12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: AppDimensions.spacing4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.labelSmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (sublabel != null) ...[
              const SizedBox(height: AppDimensions.spacing2),
              Text(
                sublabel!,
                textAlign: TextAlign.center,
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 10,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
