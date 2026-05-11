// Problem form hints list — optional hints rendered in display order.
import 'package:flutter/material.dart';

import '../../../../shared/constants/constants.dart';
import 'problem_form_basic_section.dart' show problemFormSectionLabel;

class ProblemFormHintsSection extends StatelessWidget {
  final List<TextEditingController> hintControllers;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  const ProblemFormHintsSection({
    super.key,
    required this.hintControllers,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        problemFormSectionLabel('힌트 (선택)'),
        const SizedBox(height: AppDimensions.spacing4),
        ...hintControllers.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.spacing8),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: entry.value,
                    decoration: InputDecoration(
                      hintText: '힌트 ${entry.key + 1}',
                      border: const OutlineInputBorder(),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacing12, vertical: 10),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline,
                      size: AppDimensions.spacing20, color: AppColors.mathRed),
                  onPressed: () => onRemove(entry.key),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.only(left: AppDimensions.spacing4),
                ),
              ],
            ),
          );
        }),
        TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('힌트 추가'),
        ),
      ],
    );
  }
}
