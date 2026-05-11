// Achievement basic info section — name and description text fields.
import 'package:flutter/material.dart';

import '../../../../shared/constants/constants.dart';

class AchievementBasicInfoSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;

  const AchievementBasicInfoSection({
    super.key,
    required this.nameController,
    required this.descriptionController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name
        _buildSectionLabel('업적 이름'),
        const SizedBox(height: AppDimensions.spacing4),
        TextFormField(
          controller: nameController,
          decoration: const InputDecoration(
            hintText: '예: 첫 걸음',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          validator: (v) => v == null || v.isEmpty ? '이름을 입력하세요' : null,
        ),
        const SizedBox(height: AppDimensions.spacing16),

        // Description
        _buildSectionLabel('설명'),
        const SizedBox(height: AppDimensions.spacing4),
        TextFormField(
          controller: descriptionController,
          maxLines: 2,
          decoration: const InputDecoration(
            hintText: '예: 첫 번째 레슨을 완료하세요',
            border: OutlineInputBorder(),
          ),
          validator: (v) => v == null || v.isEmpty ? '설명을 입력하세요' : null,
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(text, style: AppTextStyles.titleSmall);
  }
}
