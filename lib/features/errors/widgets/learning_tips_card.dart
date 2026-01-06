import 'package:flutter/material.dart';
import '../../../shared/constants/constants.dart';

/// 학습 팁 카드
class LearningTipsCard extends StatelessWidget {
  const LearningTipsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingL),
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.warningOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: AppColors.warningOrange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.warningOrange,
                size: AppDimensions.iconM,
              ),
              const SizedBox(width: AppDimensions.spacingS),
              Flexible(
                child: Text(
                  '오답 노트 활용 팁',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.warningOrange,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            '• 틀린 문제는 자동으로 오답 노트에 저장됩니다',
            style: AppTextStyles.bodySmall,
          ),
          Text(
            '• 같은 유형의 문제를 선택해서 집중 복습하세요',
            style: AppTextStyles.bodySmall,
          ),
          Text(
            '• 맞춤 복습 세트를 만들어 체계적으로 학습하세요',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}
