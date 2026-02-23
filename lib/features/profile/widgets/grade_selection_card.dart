import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_dimensions.dart';
import '../../../shared/constants/app_text_styles.dart';

/// 학년 선택 카드 위젯
///
/// 온보딩 과정에서 학년을 선택할 수 있는 카드 위젯입니다.
class GradeSelectionCard extends StatelessWidget {
  final String title;
  final String icon;
  final List<String> grades;
  final Color color;
  final String selectedGrade;
  final ValueChanged<String> onGradeSelected;

  const GradeSelectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.grades,
    required this.color,
    required this.selectedGrade,
    required this.onGradeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // 세부 학년 선택 다이얼로그 표시
        showDialog(
          context: context,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radius24),
            ),
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.spacing24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 아이콘과 제목
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        icon,
                        style: const TextStyle(fontSize: 40),
                      ),
                      const SizedBox(width: AppDimensions.spacing12),
                      Text(
                        title,
                        style: AppTextStyles.headlineMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacing24),
                  // 세부 학년 선택
                  Wrap(
                    spacing: AppDimensions.spacing12,
                    runSpacing: AppDimensions.spacing12,
                    alignment: WrapAlignment.center,
                    children: grades.map((grade) {
                      final isSelected = selectedGrade == grade;
                      return InkWell(
                        onTap: () {
                          onGradeSelected(grade);
                          Navigator.pop(context); // 다이얼로그 닫기
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: isSelected ? color : Colors.white,
                            borderRadius: BorderRadius.circular(AppDimensions.radius16),
                            border: Border.all(
                              color: isSelected ? color : AppColors.borderLight,
                              width: 2,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              grade,
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing20, vertical: AppDimensions.spacing16), // Reduced padding
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radius20),
          border: Border.all(
            color: grades.contains(selectedGrade)
                ? color
                : AppColors.borderLight,
            width: 3,
          ),
          boxShadow: grades.contains(selectedGrade)
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // 아이콘
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radius12),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.spacing16),
            // 텍스트
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.headlineSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing4),
                  Text(
                    grades.contains(selectedGrade)
                        ? selectedGrade
                        : '탭하여 선택',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: grades.contains(selectedGrade)
                          ? color
                          : AppColors.textSecondary,
                      fontWeight: grades.contains(selectedGrade)
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            // 화살표
            Icon(
              Icons.arrow_forward_ios,
              color: grades.contains(selectedGrade)
                  ? color
                  : AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
