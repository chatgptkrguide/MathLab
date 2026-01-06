import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_dimensions.dart';

/// 학년 선택 다이얼로그
class GradeSelectionDialog extends StatefulWidget {
  final String currentGrade;
  final Function(String) onGradeSelected;

  const GradeSelectionDialog({
    super.key,
    required this.currentGrade,
    required this.onGradeSelected,
  });

  @override
  State<GradeSelectionDialog> createState() => _GradeSelectionDialogState();
}

class _GradeSelectionDialogState extends State<GradeSelectionDialog> {
  late String _selectedGrade;
  int _selectedSchoolIndex = 0; // 0: 초등, 1: 중등, 2: 고등

  // 학교 단계별 학년 목록
  final List<Map<String, dynamic>> _schools = [
    {
      'name': '초등학교',
      'grades': ['초1', '초2', '초3', '초4', '초5', '초6'],
      'icon': Icons.school,
      'color': AppColors.mathYellow,
      'gradeIcons': [
        Icons.local_florist,  // 초1: 꽃
        Icons.eco,            // 초2: 잎
        Icons.park,           // 초3: 나무
        Icons.star,           // 초4: 별
        Icons.emoji_events,   // 초5: 트로피
        Icons.military_tech,  // 초6: 메달
      ],
    },
    {
      'name': '중학교',
      'grades': ['중1', '중2', '중3'],
      'icon': Icons.menu_book,
      'color': AppColors.mathBlue,
      'gradeIcons': [
        Icons.menu_book,        // 중1: 책
        Icons.import_contacts,  // 중2: 열린 책
        Icons.school,           // 중3: 졸업모
      ],
    },
    {
      'name': '고등학교',
      'grades': ['고1', '고2', '고3'],
      'icon': Icons.library_books,
      'color': AppColors.mathPurple,
      'gradeIcons': [
        Icons.science,         // 고1: 과학
        Icons.biotech,         // 고2: 실험
        Icons.rocket_launch,   // 고3: 로켓
      ],
    },
  ];

  // 완료된 학년 목록 (추후 사용자 데이터에서 가져올 예정)
  // 테스트용: 초1, 초2, 중1 완료로 표시
  final Set<String> _completedGrades = {'초1', '초2', '중1'};

  @override
  void initState() {
    super.initState();
    _selectedGrade = widget.currentGrade;

    // 현재 학년에 따라 학교 단계 선택
    if (_selectedGrade.startsWith('초')) {
      _selectedSchoolIndex = 0;
    } else if (_selectedGrade.startsWith('중')) {
      _selectedSchoolIndex = 1;
    } else if (_selectedGrade.startsWith('고')) {
      _selectedSchoolIndex = 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.headerBlueGradient,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppDimensions.radiusXL),
                  topRight: Radius.circular(AppDimensions.radiusXL),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.school,
                    color: AppColors.headerText,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '학년 선택',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.headerText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.headerText),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // 학교 단계 선택 탭
            Container(
              margin: const EdgeInsets.all(AppDimensions.paddingL),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              ),
              child: Row(
                children: List.generate(3, (index) {
                  final school = _schools[index];
                  final isSelected = _selectedSchoolIndex == index;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedSchoolIndex = index;
                          // 현재 학년이 선택된 학교급에 속하지 않을 때만 변경
                          final grades = school['grades'] as List<String>;
                          if (!grades.contains(_selectedGrade)) {
                            _selectedGrade = grades[0];
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: AppDimensions.animationFast,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.paddingM,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.surface : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.cardShadow,
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          children: [
                            Icon(
                              school['icon'],
                              color: isSelected
                                  ? school['color']
                                  : AppColors.textSecondary,
                              size: 24,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              school['name'],
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isSelected
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // 학년 그리드
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingL,
              ),
              child: _buildGradeGrid(),
            ),

            const SizedBox(height: AppDimensions.spacingL),

            // 하단 버튼
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.paddingM,
                        ),
                        side: BorderSide(color: AppColors.borderLight),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                        ),
                      ),
                      child: Text(
                        '취소',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingM),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onGradeSelected(_selectedGrade);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mathBlue,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.paddingM,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                        ),
                      ),
                      child: Text(
                        '선택 완료',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 학년 그리드 빌더
  Widget _buildGradeGrid() {
    final school = _schools[_selectedSchoolIndex];
    final grades = school['grades'] as List<String>;
    final schoolColor = school['color'] as Color;
    final gradeIcons = school['gradeIcons'] as List<IconData>;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppDimensions.spacingM,
        mainAxisSpacing: AppDimensions.spacingM,
        childAspectRatio: 1.2,
      ),
      itemCount: grades.length,
      itemBuilder: (context, index) {
        final grade = grades[index];
        final isSelected = _selectedGrade == grade;
        final isCompleted = _completedGrades.contains(grade);
        final gradeIcon = gradeIcons[index];

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedGrade = grade;
            });
          },
          child: Stack(
            children: [
              AnimatedContainer(
                duration: AppDimensions.animationFast,
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            schoolColor,
                            schoolColor.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected ? null : AppColors.background,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                  border: Border.all(
                    color: isSelected
                        ? schoolColor
                        : isCompleted
                            ? AppColors.success
                            : AppColors.borderLight,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: schoolColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      gradeIcon,
                      color: isSelected
                          ? Colors.white
                          : isCompleted
                              ? schoolColor
                              : AppColors.textSecondary,
                      size: 28,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      grade,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // 완료 뱃지
              if (isCompleted)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.success.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
