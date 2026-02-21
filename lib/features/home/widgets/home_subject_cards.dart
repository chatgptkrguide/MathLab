import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_dimensions.dart';
import '../../../shared/constants/app_text_styles.dart';

/// 피그마 "00 home" 과목 선택 카드
/// 공통수학 1, 공통수학 2 카드 2개를 가로로 배치
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
              Expanded(
                child: _SubjectCard(
                  title: '공통수학 1',
                  subtitle: '다항식, 방정식, 부등식',
                  icon: Icons.functions_rounded,
                  progress: 0.45,
                  color: AppColors.royalBlue,
                  onTap: () => onSubjectTap('common_math_1'),
                ),
              ),
              const SizedBox(width: AppDimensions.spacing12),
              Expanded(
                child: _SubjectCard(
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

class _SubjectCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final double progress;
  final Color color;
  final VoidCallback onTap;

  const _SubjectCard({
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
          borderRadius: BorderRadius.circular(AppDimensions.radius16),
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
            // 아이콘
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

            // 과목명
            Text(
              title,
              style: AppTextStyles.titleMedium.copyWith(
                fontSize: 15,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: AppDimensions.spacing4),

            // 설명
            Text(
              subtitle,
              style: AppTextStyles.labelSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppDimensions.spacing12),

            // 진행률 바
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

            // 진행률 텍스트
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
