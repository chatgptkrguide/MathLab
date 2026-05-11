// Achievement meta section — category and rarity dropdowns row.
import 'package:flutter/material.dart';

import '../../../../data/models/achievement_model.dart';
import '../../../../shared/constants/constants.dart';

class AchievementMetaSection extends StatelessWidget {
  final AchievementCategory selectedCategory;
  final AchievementRarity selectedRarity;
  final ValueChanged<AchievementCategory> onCategoryChanged;
  final ValueChanged<AchievementRarity> onRarityChanged;

  const AchievementMetaSection({
    super.key,
    required this.selectedCategory,
    required this.selectedRarity,
    required this.onCategoryChanged,
    required this.onRarityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionLabel('카테고리'),
              const SizedBox(height: AppDimensions.spacing4),
              DropdownButtonFormField<AchievementCategory>(
                initialValue: selectedCategory,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacing12, vertical: 10),
                ),
                items: AchievementCategory.values
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(
                            _categoryLabel(c),
                            style: AppTextStyles.bodyMedium,
                          ),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) onCategoryChanged(v);
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: AppDimensions.spacing12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionLabel('희귀도'),
              const SizedBox(height: AppDimensions.spacing4),
              DropdownButtonFormField<AchievementRarity>(
                initialValue: selectedRarity,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacing12, vertical: 10),
                ),
                items: AchievementRarity.values
                    .map((r) => DropdownMenuItem(
                          value: r,
                          child: Text(
                            _rarityLabel(r),
                            style: AppTextStyles.titleSmall.copyWith(
                              color: Color(_rarityColor(r)),
                            ),
                          ),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) onRarityChanged(v);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(text, style: AppTextStyles.titleSmall);
  }

  String _categoryLabel(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.general:
        return '일반';
      case AchievementCategory.streak:
        return '연속학습';
      case AchievementCategory.mastery:
        return '숙달';
      case AchievementCategory.social:
        return '소셜';
      case AchievementCategory.speed:
        return '속도';
      case AchievementCategory.perfectionist:
        return '완벽주의';
      case AchievementCategory.explorer:
        return '탐험가';
    }
  }

  String _rarityLabel(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common:
        return '일반';
      case AchievementRarity.rare:
        return '희귀';
      case AchievementRarity.epic:
        return '영웅';
      case AchievementRarity.legendary:
        return '전설';
    }
  }

  int _rarityColor(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common:
        return 0xFFB0BEC5;
      case AchievementRarity.rare:
        return 0xFF64B5F6;
      case AchievementRarity.epic:
        return 0xFF9C27B0;
      case AchievementRarity.legendary:
        return 0xFFFFB74D;
    }
  }
}
