// Edit profile daily learning goal selector card
import 'package:flutter/material.dart';

import '../../../shared/constants/constants.dart';

class EditProfileGoalCard extends StatelessWidget {
  final int selectedMinutes;
  final ValueChanged<int> onChanged;

  static const List<int> _goalOptions = [5, 10, 15, 20, 30];
  static const List<String> _goalLabels = [
    '가볍게',
    '기본',
    '적당히',
    '열심히',
    '빡세게',
  ];
  static const List<IconData> _goalIcons = [
    Icons.self_improvement_rounded,
    Icons.directions_walk_rounded,
    Icons.directions_run_rounded,
    Icons.fitness_center_rounded,
    Icons.whatshot_rounded,
  ];

  const EditProfileGoalCard({
    super.key,
    required this.selectedMinutes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.mathOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.timer_outlined,
                    size: 18, color: AppColors.mathOrange),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  '일일 학습 목표',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              // 선택된 시간 강조
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.mathBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '하루 $selectedMinutes분',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mathBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 목표 옵션들
          ...List.generate(_goalOptions.length, (i) {
            final minutes = _goalOptions[i];
            final isSelected = minutes == selectedMinutes;
            final label = _goalLabels[i];
            final icon = _goalIcons[i];

            return Padding(
              padding: EdgeInsets.only(
                  bottom: i < _goalOptions.length - 1 ? 8 : 0),
              child: GestureDetector(
                onTap: () => onChanged(minutes),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.mathBlue.withValues(alpha: 0.06)
                        : const Color(0xFFFAFAFB),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.mathBlue.withValues(alpha: 0.35)
                          : const Color(0xFFEEEEEE),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        size: 20,
                        color: isSelected
                            ? AppColors.mathBlue
                            : AppColors.textTertiary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Text(
                        '$minutes분',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? AppColors.mathBlue
                              : AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? AppColors.mathBlue
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.mathBlue
                                : const Color(0xFFD0D0D0),
                            width: isSelected ? 0 : 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check_rounded,
                                size: 14, color: Colors.white)
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
