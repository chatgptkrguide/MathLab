import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_dimensions.dart';
import '../../../shared/widgets/fade_in_widget.dart';

/// 오답 노트 통계 그리드 위젯
///
/// 2x2 그리드로 오답 통계를 표시
/// - errors_screen과 wrong_answer_screen에서 공통 사용
/// - GoMath flat style 디자인
/// - 통계: 총 오답, 미복습, 1회 복습, 2회 이상
class ErrorStatsGrid extends StatelessWidget {
  final Map<String, int> errorStats;

  const ErrorStatsGrid({
    super.key,
    required this.errorStats,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInWidget(
      duration: const Duration(milliseconds: 600),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.paddingL,
          AppDimensions.paddingM,
          AppDimensions.paddingL,
          AppDimensions.paddingL,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: _ErrorStatCard(
                    label: '총 오답',
                    value: errorStats['total']?.toString() ?? '0',
                    valueColor: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingM),
                Expanded(
                  child: _ErrorStatCard(
                    label: '미복습',
                    value: errorStats['unreviewed']?.toString() ?? '0',
                    valueColor: AppColors.errorRed,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Row(
              children: [
                Expanded(
                  child: _ErrorStatCard(
                    label: '1회 복습',
                    value: errorStats['reviewedOnce']?.toString() ?? '0',
                    valueColor: AppColors.warningOrange,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingM),
                Expanded(
                  child: _ErrorStatCard(
                    label: '2회 이상',
                    value: errorStats['reviewedTwice']?.toString() ?? '0',
                    valueColor: AppColors.successGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 통계 카드 위젯
///
/// GoMath flat style로 개별 통계 표시
/// - 넉넉한 여백
/// - 색상별 값 표시
class _ErrorStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _ErrorStatCard({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: AppDimensions.paddingL + 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderLight,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
