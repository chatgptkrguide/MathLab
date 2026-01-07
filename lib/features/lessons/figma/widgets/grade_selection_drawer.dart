import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../data/providers/user/user_provider.dart';

/// 학년/단원 선택 Drawer
class GradeSelectionDrawer extends ConsumerWidget {
  final String currentGrade;

  const GradeSelectionDrawer({
    super.key,
    required this.currentGrade,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 학교급별로 학년 그룹화
    final elementaryGrades = ['초1', '초2', '초3', '초4', '초5', '초6'];
    final middleGrades = ['중1', '중2', '중3'];
    final highGrades = ['고1', '고2', '고3'];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '학년 선택',
                    style: AppTextStyles.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 현재 학년 표시
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.mathBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.mathBlue, width: 2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.school,
                        color: AppColors.mathBlue, size: 24),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '현재 학년',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          currentGrade,
                          style: AppTextStyles.headlineSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.mathBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 초등학교 섹션
              _buildSchoolSection(
                context: context,
                ref: ref,
                title: '🎒 초등학교',
                grades: elementaryGrades,
                currentGrade: currentGrade,
                color: const Color(0xFF4CAF50),
              ),

              const SizedBox(height: 20),

              // 중학교 섹션
              _buildSchoolSection(
                context: context,
                ref: ref,
                title: '📚 중학교',
                grades: middleGrades,
                currentGrade: currentGrade,
                color: const Color(0xFF2196F3),
              ),

              const SizedBox(height: 20),

              // 고등학교 섹션
              _buildSchoolSection(
                context: context,
                ref: ref,
                title: '🎓 고등학교',
                grades: highGrades,
                currentGrade: currentGrade,
                color: const Color(0xFF9C27B0),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// 학교급별 섹션 위젯
  Widget _buildSchoolSection({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required List<String> grades,
    required String currentGrade,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 12),
        // 3열 그리드 레이아웃
        LayoutBuilder(
          builder: (context, constraints) {
            // 전체 너비에서 간격을 제외한 버튼 영역 계산
            final totalWidth = constraints.maxWidth;
            final spacing = 12.0;
            final buttonWidth = (totalWidth - (spacing * 2)) / 3;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: grades.map((grade) {
                final isSelected = grade == currentGrade;
                return SizedBox(
                  width: buttonWidth,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        // 학년 변경
                        await ref
                            .read(userProvider.notifier)
                            .updateCurrentGrade(grade);

                        if (context.mounted) {
                          Navigator.pop(context);

                          // 성공 스낵바 표시
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$grade 학년으로 변경되었습니다'),
                              backgroundColor: AppColors.success,
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: isSelected ? color : AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? color : AppColors.borderLight,
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          grade,
                          style: AppTextStyles.titleMedium.copyWith(
                            color: isSelected
                                ? AppColors.surface
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
