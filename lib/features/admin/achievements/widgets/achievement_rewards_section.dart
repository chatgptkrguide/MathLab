// Achievement rewards section — XP and gems numeric inputs.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../shared/constants/constants.dart';

class AchievementRewardsSection extends StatelessWidget {
  final TextEditingController xpRewardController;
  final TextEditingController gemsRewardController;

  const AchievementRewardsSection({
    super.key,
    required this.xpRewardController,
    required this.gemsRewardController,
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
            '보상',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionLabel('XP 보상'),
                    const SizedBox(height: AppDimensions.spacing4),
                    TextFormField(
                      controller: xpRewardController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        hintText: '0',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: AppDimensions.spacing12, vertical: 10),
                      ),
                      validator: (v) {
                        if (v != null &&
                            v.isNotEmpty &&
                            int.tryParse(v) == null) {
                          return '숫자를 입력하세요';
                        }
                        return null;
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
                    _buildSectionLabel('젬 보상'),
                    const SizedBox(height: AppDimensions.spacing4),
                    TextFormField(
                      controller: gemsRewardController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        hintText: '0',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: AppDimensions.spacing12, vertical: 10),
                      ),
                      validator: (v) {
                        if (v != null &&
                            v.isNotEmpty &&
                            int.tryParse(v) == null) {
                          return '숫자를 입력하세요';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(text, style: AppTextStyles.titleSmall);
  }
}
