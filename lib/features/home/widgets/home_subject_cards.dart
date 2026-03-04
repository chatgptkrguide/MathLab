import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_dimensions.dart';
import '../../../shared/constants/app_text_styles.dart';

/// Home screen subject cards with asymmetric layout:
/// - "공통수학 1" takes flex:3 with a "학습 중" tag and bottom border
/// - "공통수학 2" takes flex:2 with a different border radius
class HomeSubjectCards extends StatelessWidget {
  final void Function(String subjectId) onSubjectTap;

  const HomeSubjectCards({
    super.key,
    required this.onSubjectTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '과목 선택',
            style: AppTextStyles.titleLarge.copyWith(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing12),
          Row(
            children: [
              // Primary subject card: larger, with tag and bottom border
              Expanded(
                flex: 3,
                child: _PrimarySubjectCard(
                  title: '공통수학 1',
                  subtitle: '다항식, 방정식, 부등식',
                  icon: Icons.functions_rounded,
                  progress: 0.45,
                  color: AppColors.royalBlue,
                  onTap: () => onSubjectTap('common_math_1'),
                ),
              ),
              const SizedBox(width: AppDimensions.spacing12),
              // Secondary subject card: smaller, different radius
              Expanded(
                flex: 2,
                child: _SecondarySubjectCard(
                  title: '공통수학 2',
                  subtitle: '함수, 수열, 통계',
                  icon: Icons.show_chart_rounded,
                  progress: 0.12,
                  color: AppColors.tealGreen,
                  onTap: () => onSubjectTap('common_math_2'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Primary subject card with "학습 중" tag and bottom border accent
class _PrimarySubjectCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final double progress;
  final Color color;
  final VoidCallback onTap;

  const _PrimarySubjectCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.progress,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacing16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radius16),
              border: Border(
                bottom: BorderSide(
                  color: color,
                  width: 2,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radius12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(height: AppDimensions.spacing12),

                // Subject title
                Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontSize: 15,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing4),

                // Description
                Text(
                  subtitle,
                  style: AppTextStyles.labelSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.spacing12),

                // Progress bar
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radius4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: color.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing4),

                // Progress text
                Text(
                  '${(progress * 100).toInt()}% 완료',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          // "학습 중" tag positioned at top-right
          Positioned(
            top: AppDimensions.spacing8,
            right: AppDimensions.spacing8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing8,
                vertical: AppDimensions.spacing4,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppDimensions.radius8),
              ),
              child: Text(
                '학습 중',
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Secondary subject card with different border radius (radius12)
class _SecondarySubjectCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final double progress;
  final Color color;
  final VoidCallback onTap;

  const _SecondarySubjectCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.progress,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radius12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppDimensions.radius12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: AppDimensions.spacing12),

            // Subject title
            Text(
              title,
              style: AppTextStyles.titleMedium.copyWith(
                fontSize: 15,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: AppDimensions.spacing4),

            // Description
            Text(
              subtitle,
              style: AppTextStyles.labelSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppDimensions.spacing12),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radius4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: color.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: AppDimensions.spacing4),

            // Progress text
            Text(
              '${(progress * 100).toInt()}% 완료',
              style: AppTextStyles.labelSmall.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
