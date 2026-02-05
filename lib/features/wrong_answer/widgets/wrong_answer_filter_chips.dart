// 🔍 Wrong Answer Filter Chips
//
// Filter chips for wrong answer list

import 'package:flutter/material.dart';
import '../../../data/providers/wrong_answer/wrong_answer_provider.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_text_styles.dart';

class WrongAnswerFilterChips extends StatelessWidget {
  final WrongAnswerFilter currentFilter;
  final Function(WrongAnswerFilter) onFilterChanged;

  const WrongAnswerFilterChips({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              label: '전체',
              filter: WrongAnswerFilter.all,
              icon: Icons.list_alt,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: '미해결',
              filter: WrongAnswerFilter.unresolved,
              icon: Icons.error_outline,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: '복습 필요',
              filter: WrongAnswerFilter.needsReview,
              icon: Icons.alarm,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: '해결 완료',
              filter: WrongAnswerFilter.resolved,
              icon: Icons.check_circle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required WrongAnswerFilter filter,
    required IconData icon,
  }) {
    final isSelected = currentFilter == filter;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : AppColors.primary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isSelected ? Colors.white : AppColors.primary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onFilterChanged(filter),
      backgroundColor: Colors.white,
      selectedColor: AppColors.primary,
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.primary.withValues(alpha: 0.3),
        width: isSelected ? 2 : 1,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}
