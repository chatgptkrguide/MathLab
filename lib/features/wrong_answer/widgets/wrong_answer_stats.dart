// Wrong Answer Statistics — Anti-AI 재설계
//
// 변경 사항:
// - 균일 그라데이션 카드 4개 제거 → 비대칭 인라인 수평 레이아웃
// - 숫자 크기에 극적 위계: 미해결 수치 크게, 해결 수치 중간, 복습 수치 작게
// - 그라데이션 대신 단색 + border-left 수작업 강조선
// - 통계 행 사이 자연스러운 불규칙 여백

import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_text_styles.dart';

class WrongAnswerStats extends StatelessWidget {
  final Map<String, int> statistics;

  const WrongAnswerStats({
    super.key,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    final total = statistics['total'] ?? 0;
    final unresolved = statistics['unresolved'] ?? 0;
    final resolved = statistics['resolved'] ?? 0;
    final needsReview = statistics['needsReview'] ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 미해결 — 가장 큰 숫자, 강조색
            _StatItem(
              value: unresolved,
              label: '미해결',
              valueColor: AppColors.mathRed,
              valueFontSize: 28,
              stripeColor: AppColors.mathRed,
            ),
            const _Divider(),
            // 복습 필요
            _StatItem(
              value: needsReview,
              label: '복습',
              valueColor: AppColors.mathOrange,
              valueFontSize: 22,
              stripeColor: AppColors.mathOrange,
            ),
            const _Divider(),
            // 해결 완료
            _StatItem(
              value: resolved,
              label: '해결',
              valueColor: Colors.white,
              valueFontSize: 18,
              stripeColor: AppColors.mathGreen,
            ),
            const _Divider(),
            // 총합 — 가장 작게 (맥락 정보)
            _StatItem(
              value: total,
              label: '전체',
              valueColor: Colors.white.withValues(alpha: 0.6),
              valueFontSize: 15,
              stripeColor: Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final int value;
  final String label;
  final Color valueColor;
  final double valueFontSize;
  final Color stripeColor;

  const _StatItem({
    required this.value,
    required this.label,
    required this.valueColor,
    required this.valueFontSize,
    required this.stripeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // border-left 강조선 — 수작업 디테일
          if (stripeColor != Colors.transparent)
            Container(
              width: 2,
              height: valueFontSize * 1.1,
              color: stripeColor.withValues(alpha: 0.7),
              margin: const EdgeInsets.only(right: 7, top: 2),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.toString(),
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontSize: valueFontSize,
                    fontWeight: FontWeight.w800,
                    color: valueColor,
                    height: 1.0,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 30,
      color: Colors.white.withValues(alpha: 0.15),
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
