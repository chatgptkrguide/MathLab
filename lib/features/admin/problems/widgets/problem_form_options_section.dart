// Problem form options list — shown only for multipleChoice problems.
import 'package:flutter/material.dart';

import '../../../../shared/constants/constants.dart';
import 'problem_form_basic_section.dart' show problemFormSectionLabel;

class ProblemFormOptionsSection extends StatelessWidget {
  final List<TextEditingController> optionControllers;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  /// Maximum number of options allowed (the "선택지 추가" button is hidden
  /// when [optionControllers.length] reaches this value).
  final int maxOptions;

  /// Minimum number of options that must remain visible (the per-row remove
  /// button is hidden when [optionControllers.length] is at or below this).
  final int minOptions;

  const ProblemFormOptionsSection({
    super.key,
    required this.optionControllers,
    required this.onAdd,
    required this.onRemove,
    this.maxOptions = 6,
    this.minOptions = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        problemFormSectionLabel('선택지'),
        const SizedBox(height: AppDimensions.spacing4),
        ...optionControllers.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.spacing8),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    '${entry.key + 1}.',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: entry.value,
                    decoration: InputDecoration(
                      hintText: '선택지 ${entry.key + 1}',
                      border: const OutlineInputBorder(),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacing12, vertical: 10),
                    ),
                  ),
                ),
                if (optionControllers.length > minOptions)
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline,
                        size: AppDimensions.spacing20,
                        color: AppColors.mathRed),
                    onPressed: () => onRemove(entry.key),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.only(left: AppDimensions.spacing4),
                  ),
              ],
            ),
          );
        }),
        if (optionControllers.length < maxOptions)
          TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('선택지 추가'),
          ),
        const SizedBox(height: AppDimensions.spacing8),
      ],
    );
  }
}
