// Lessons blue header — subject dropdown + GoMath badge
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/lesson/unit_model.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/subject_labels.dart';

class LessonsBlueHeader extends StatelessWidget {
  final AsyncValue<List<UnitModel>> curriculumAsync;
  final String? selectedSubject;
  final List<String> Function(List<UnitModel> units) getFilteredSubjects;
  final ValueChanged<String?> onSubjectChanged;

  const LessonsBlueHeader({
    super.key,
    required this.curriculumAsync,
    required this.selectedSubject,
    required this.getFilteredSubjects,
    required this.onSubjectChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Firestore에서 가져온 유닛들의 subject 목록 (학년 필터 적용)
    final allUnits = curriculumAsync.valueOrNull ?? [];
    final subjects = getFilteredSubjects(allUnits);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.skyBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // 과목 드롭다운
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: selectedSubject,
                    isDense: true,
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: AppColors.skyBlue, size: 20),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.skyBlue,
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('전체 과목'),
                      ),
                      ...subjects.map((s) => DropdownMenuItem<String?>(
                            value: s,
                            child: Text(SubjectLabels.displayOf(s)),
                          )),
                    ],
                    onChanged: (v) {
                      HapticFeedback.selectionClick();
                      onSubjectChanged(v);
                    },
                  ),
                ),
              ),
              const Spacer(),
              // GoMath 로고
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'GoMath',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
