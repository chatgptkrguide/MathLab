// Lessons blue header — subject dropdown (학년 그룹) + GoMath badge
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/lesson/unit_model.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/grade_groups.dart';
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

  /// 학년 헤더 (학년 전체 선택) + 들여쓰기된 과목 항목 구성.
  /// 헤더 value 는 '__grade_<학년>' sentinel — 선택 시 그 학년 모든 과목
  /// 으로 필터링 (lessons_screen 에서 분기 처리).
  List<DropdownMenuItem<String?>> _buildGroupedItems(Set<String> available) {
    final items = <DropdownMenuItem<String?>>[
      const DropdownMenuItem<String?>(
        value: null,
        child: Text('전체 과목'),
      ),
    ];

    for (final entry in GradeGroups.map.entries) {
      final visibleSubjects =
          entry.value.where(available.contains).toList();
      if (visibleSubjects.isEmpty) continue;

      // 학년 전체 선택 — 굵게 + 학년 라벨
      items.add(
        DropdownMenuItem<String?>(
          value: GradeGroups.sentinelFor(entry.key),
          child: Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.skyBlue,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '전체',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.skyBlue.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      for (final code in visibleSubjects) {
        items.add(
          DropdownMenuItem<String?>(
            value: code,
            child: Padding(
              padding: const EdgeInsets.only(left: 14),
              child: Text(SubjectLabels.displayOf(code)),
            ),
          ),
        );
      }
    }

    return items;
  }

  /// DropdownButton 의 selected label — 들여쓰기 없이 깔끔하게 표시.
  /// items 순서와 정확히 일치해야 함 (Flutter assert).
  List<Widget> _buildSelectedLabels(Set<String> available) {
    final labels = <Widget>[
      const Text('전체 과목'),
    ];
    for (final entry in GradeGroups.map.entries) {
      final visibleSubjects =
          entry.value.where(available.contains).toList();
      if (visibleSubjects.isEmpty) continue;
      // 학년 sentinel 의 label — '고1 전체' 형태
      labels.add(Text('${entry.key} 전체'));
      for (final code in visibleSubjects) {
        labels.add(Text(SubjectLabels.displayOf(code)));
      }
    }
    return labels;
  }
}
