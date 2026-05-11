// Achievement criteria section — type, target value, and specific requirement.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../data/models/achievement_model.dart';
import '../../../../shared/constants/constants.dart';

class AchievementCriteriaSection extends StatelessWidget {
  final AchievementType selectedCriteriaType;
  final ValueChanged<AchievementType> onCriteriaTypeChanged;
  final TextEditingController targetValueController;
  final TextEditingController specificRequirementController;

  const AchievementCriteriaSection({
    super.key,
    required this.selectedCriteriaType,
    required this.onCriteriaTypeChanged,
    required this.targetValueController,
    required this.specificRequirementController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacing12),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(AppDimensions.radius12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '달성 조건',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing12),

          // Criteria type
          _buildSectionLabel('조건 유형'),
          const SizedBox(height: AppDimensions.spacing4),
          DropdownButtonFormField<AchievementType>(
            initialValue: selectedCriteriaType,
            isExpanded: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacing12, vertical: 10),
            ),
            items: AchievementType.values
                .map((t) => DropdownMenuItem(
                      value: t,
                      child: Text(
                        _criteriaTypeLabel(t),
                        style: AppTextStyles.bodyMedium,
                      ),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) onCriteriaTypeChanged(v);
            },
          ),
          const SizedBox(height: AppDimensions.spacing12),

          // Target value
          _buildSectionLabel('목표 값'),
          const SizedBox(height: AppDimensions.spacing4),
          TextFormField(
            controller: targetValueController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              hintText: '예: 100',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            validator: (v) {
              if (v == null || v.isEmpty) {
                return '목표 값을 입력하세요';
              }
              if (int.tryParse(v) == null) {
                return '숫자를 입력하세요';
              }
              return null;
            },
          ),
          const SizedBox(height: AppDimensions.spacing12),

          // Specific requirement (optional)
          _buildSectionLabel('특수 조건 (선택)'),
          const SizedBox(height: AppDimensions.spacing4),
          TextFormField(
            controller: specificRequirementController,
            decoration: const InputDecoration(
              hintText: '예: algebra_unit',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(text, style: AppTextStyles.titleSmall);
  }

  String _criteriaTypeLabel(AchievementType type) {
    switch (type) {
      case AchievementType.totalXP:
        return '총 XP';
      case AchievementType.streak:
        return '연속학습 일수';
      case AchievementType.lessonsCompleted:
        return '레슨 완료 수';
      case AchievementType.perfectScore:
        return '만점 횟수';
      case AchievementType.fastSolver:
        return '빠른 풀이 횟수';
      case AchievementType.accuracy:
        return '정확도 (%)';
      case AchievementType.problemsSolved:
        return '문제 풀이 수';
      case AchievementType.leagueRank:
        return '리그 순위';
      case AchievementType.helpfulStudent:
        return '도움 횟수';
    }
  }
}
