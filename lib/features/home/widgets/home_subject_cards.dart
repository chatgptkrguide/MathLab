import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_dimensions.dart';
import '../../../shared/constants/app_text_styles.dart';

/// Home screen subject cards — horizontal scrollable list of 7 Korean math subjects.
/// The first card (currently studying) gets an accent "학습 중" badge and bottom border
/// for natural visual variety (Anti-AI design touch).
class HomeSubjectCards extends StatelessWidget {
  final void Function(String subjectId) onSubjectTap;

  const HomeSubjectCards({
    super.key,
    required this.onSubjectTap,
  });

  static final List<_SubjectData> _subjects = [
    const _SubjectData(
      id: 'common_math_1',
      title: '공통수학 1',
      subtitle: '다항식, 방정식',
      icon: Icons.functions_rounded,
      color: Color(0xFF4575F6),
      progress: 0.45,
    ),
    const _SubjectData(
      id: 'common_math_2',
      title: '공통수학 2',
      subtitle: '집합, 함수, 도형',
      icon: Icons.show_chart_rounded,
      color: Color(0xFF45A6AD),
      progress: 0.12,
    ),
    const _SubjectData(
      id: 'math_1',
      title: '수학 I',
      subtitle: '지수, 삼각, 수열',
      icon: Icons.trending_up_rounded,
      color: Color(0xFF6B5CE7),
      progress: 0.0,
    ),
    const _SubjectData(
      id: 'math_2',
      title: '수학 II',
      subtitle: '극한, 미분, 적분',
      icon: Icons.auto_graph_rounded,
      color: Color(0xFFE74C6B),
      progress: 0.0,
    ),
    const _SubjectData(
      id: 'prob_stat',
      title: '확률과 통계',
      subtitle: '확률, 분포, 추정',
      icon: Icons.pie_chart_rounded,
      color: Color(0xFF43A047),
      progress: 0.0,
    ),
    const _SubjectData(
      id: 'calculus',
      title: '미적분',
      subtitle: '급수, 미분법, 적분법',
      icon: Icons.timeline_rounded,
      color: Color(0xFFFF7043),
      progress: 0.0,
    ),
    const _SubjectData(
      id: 'geometry',
      title: '기하',
      subtitle: '이차곡선, 벡터, 공간',
      icon: Icons.hexagon_rounded,
      color: Color(0xFF5C6BC0),
      progress: 0.0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '과목',
            style: AppTextStyles.titleLarge.copyWith(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              clipBehavior: Clip.none,
              itemCount: _subjects.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final subject = _subjects[index];
                final isActive = index == 0;
                return SizedBox(
                  width: 120,
                  child: _SubjectCard(
                    title: subject.title,
                    subtitle: subject.subtitle,
                    icon: subject.icon,
                    progress: subject.progress,
                    color: subject.color,
                    isActive: isActive,
                    onTap: () => onSubjectTap(subject.id),
                  ),
                );
              },
            ),
          ),
        ],
    );
  }
}

/// Individual subject card widget.
/// When [isActive] is true, shows a "학습 중" badge and a colored bottom border
/// with a slightly stronger shadow — giving the first card natural emphasis.
class _SubjectCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final double progress;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  const _SubjectCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.progress,
    required this.color,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radius12),
              border: isActive
                  ? Border(
                      bottom: BorderSide(color: color, width: 2),
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: isActive
                      ? color.withValues(alpha: 0.15)
                      : Colors.black.withValues(alpha: 0.06),
                  blurRadius: isActive ? 12 : 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon container
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const SizedBox(height: 6),

                // Title
                Text(
                  title,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.textDark,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),

                // Subtitle
                Text(
                  subtitle,
                  style: AppTextStyles.labelSmall.copyWith(fontSize: 9),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),

                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 3,
                    backgroundColor: color.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),

          // "학습 중" badge — only on active card
          if (isActive)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Internal data class for subject card information.
class _SubjectData {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final double progress;

  const _SubjectData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.progress,
  });
}
