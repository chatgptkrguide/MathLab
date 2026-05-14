// Lessons blue header — subject dropdown (학년 그룹) + GoMath badge
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/lesson/unit_model.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/subject_labels.dart';

/// 과목 → 학년 분류 (2022 개정 교육과정 기준).
/// 드롭다운에서 학년 헤더 아래에 묶어 표시하기 위함.
const _gradeGroups = <String, List<String>>{
  '초등': ['기초수학'],
  '중등': ['중학수학'],
  '고1': ['공통수학1', '공통수학2'],
  '고2': ['수학I', '수학II'],
  '고3 (선택)': ['확률과통계', '미적분', '기하'],
};

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
    final allUnits = curriculumAsync.valueOrNull ?? [];
    final available = getFilteredSubjects(allUnits).toSet();

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
              // 과목 드롭다운 — 학년별 그룹 헤더 + 들여쓰기된 과목 항목
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
                    selectedItemBuilder: (context) =>
                        _buildSelectedLabels(available),
                    items: _buildGroupedItems(available),
                    onChanged: (v) {
                      // 헤더 sentinel ('__grade_*') 은 무시
                      if (v != null && v.startsWith('__grade_')) return;
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

  /// 학년 헤더(선택 불가) + 들여쓰기된 과목 항목 구성.
  /// 헤더 value 는 '__grade_<학년>' sentinel — onChanged 에서 필터링.
  List<DropdownMenuItem<String?>> _buildGroupedItems(Set<String> available) {
    final items = <DropdownMenuItem<String?>>[
      const DropdownMenuItem<String?>(
        value: null,
        child: Text('전체 과목'),
      ),
    ];

    for (final entry in _gradeGroups.entries) {
      final visibleSubjects =
          entry.value.where(available.contains).toList();
      if (visibleSubjects.isEmpty) continue;

      items.add(
        DropdownMenuItem<String?>(
          enabled: false,
          value: '__grade_${entry.key}',
          child: Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 2),
            child: Text(
              entry.key,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF999999),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      );

      for (final code in visibleSubjects) {
        items.add(
          DropdownMenuItem<String?>(
            value: code,
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(SubjectLabels.displayOf(code)),
            ),
          ),
        );
      }
    }

    return items;
  }

  /// DropdownButton 의 selected label — 들여쓰기 없이 깔끔하게 표시.
  List<Widget> _buildSelectedLabels(Set<String> available) {
    final labels = <Widget>[
      const Text('전체 과목'),
    ];
    for (final entry in _gradeGroups.entries) {
      final visibleSubjects =
          entry.value.where(available.contains).toList();
      if (visibleSubjects.isEmpty) continue;
      // 헤더 자리에는 빈 위젯 (sentinel 은 onChange 안 됨)
      labels.add(const SizedBox.shrink());
      for (final code in visibleSubjects) {
        labels.add(Text(SubjectLabels.displayOf(code)));
      }
    }
    return labels;
  }
}
