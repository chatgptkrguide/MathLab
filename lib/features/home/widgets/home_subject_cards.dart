import 'package:flutter/material.dart';
import '../../../shared/constants/figma_colors.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '과목 선택',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SubjectCard(
                  title: '공통수학 1',
                  subtitle: '다항식, 방정식, 부등식',
                  icon: Icons.functions_rounded,
                  progress: 0.45,
                  color: FigmaColors.royalBlue,
                  onTap: () => onSubjectTap('common_math_1'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SubjectCard(
                  title: '공통수학 2',
                  subtitle: '함수, 수열, 통계',
                  icon: Icons.show_chart_rounded,
                  progress: 0.12,
                  color: FigmaColors.tealGreen,
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
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
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),

            // 과목명
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: FigmaColors.textDark,
              ),
            ),
            const SizedBox(height: 4),

            // 설명
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: FigmaColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // 진행률 바
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: color.withOpacity(0.12),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 4),

            // 진행률 텍스트
            Text(
              '${(progress * 100).toInt()}% 완료',
              style: TextStyle(
                fontSize: 11,
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
