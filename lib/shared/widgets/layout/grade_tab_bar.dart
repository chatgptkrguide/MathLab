import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_dimensions.dart';

/// 학년 탭 바 위젯
/// 중1, 중2, 고1 등을 선택하는 탭바
class GradeTabBar extends StatelessWidget {
  final List<String> grades;
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  const GradeTabBar({
    super.key,
    required this.grades,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: AppDimensions.paddingS,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Row(
        children: grades.asMap().entries.map((entry) {
          int index = entry.key;
          String grade = entry.value;
          bool isSelected = index == selectedIndex;

          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(index),
              child: AnimatedContainer(
                duration: AppDimensions.animationFast,
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.paddingM,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.cardShadow,
                            blurRadius: AppDimensions.cardElevation,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  grade,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: isSelected
                        ? AppColors.primaryBlue
                        : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}