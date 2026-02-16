// Wrong Answer Filter Chips
//
// Pill-shaped filter chips with filled/outlined states

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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildChip(
              label: '전체',
              filter: WrongAnswerFilter.all,
              icon: Icons.list_alt_rounded,
            ),
            const SizedBox(width: 8),
            _buildChip(
              label: '미해결',
              filter: WrongAnswerFilter.unresolved,
              icon: Icons.error_outline_rounded,
            ),
            const SizedBox(width: 8),
            _buildChip(
              label: '복습 필요',
              filter: WrongAnswerFilter.needsReview,
              icon: Icons.alarm_rounded,
            ),
            const SizedBox(width: 8),
            _buildChip(
              label: '해결 완료',
              filter: WrongAnswerFilter.resolved,
              icon: Icons.check_circle_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required WrongAnswerFilter filter,
    required IconData icon,
  }) {
    final isSelected = currentFilter == filter;

    return GestureDetector(
      onTap: () => onFilterChanged(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? Colors.white : AppColors.primary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
