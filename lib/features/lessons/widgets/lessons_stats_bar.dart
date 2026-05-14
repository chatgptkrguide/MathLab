// Lessons stats bar — unit chip + streak/XP/level icons
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/lesson/unit_model.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/grade_groups.dart';

class LessonsStatsBar extends StatelessWidget {
  final int streak;
  final int xp;
  final int level;
  final AsyncValue<List<UnitModel>> curriculumAsync;
  final String? selectedSubject;

  const LessonsStatsBar({
    super.key,
    required this.streak,
    required this.xp,
    required this.level,
    required this.curriculumAsync,
    required this.selectedSubject,
  });

  @override
  Widget build(BuildContext context) {
    // Get current unit name
    String unitName = '전체 과목';
    final units = curriculumAsync.valueOrNull;
    if (units != null && selectedSubject != null) {
      if (GradeGroups.isGradeSentinel(selectedSubject)) {
        final grade = GradeGroups.gradeFromSentinel(selectedSubject)!;
        unitName = '$grade 전체';
      } else {
        final filteredUnits =
            units.where((u) => u.subject == selectedSubject).toList();
        if (filteredUnits.isNotEmpty) {
          unitName = filteredUnits.first.title;
        }
      }
    } else if (units != null && units.isNotEmpty) {
      unitName = units.first.title;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      color: const Color(0xFFFAFAFA),
      child: Row(
        children: [
          // Unit name chip — sky-blue tinted bg for visibility on #FAFAFA
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.skyBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppColors.skyBlue.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Text(
              unitName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.skyBlue,
                letterSpacing: 1,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(width: 12),

          // Streak (fire icon + number)
          const Icon(
            Icons.local_fire_department_rounded,
            color: AppColors.mathOrange,
            size: 20,
          ),
          const SizedBox(width: 2),
          Text(
            '$streak',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: 1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(width: 12),

          // XP (graphene icon + number)
          Image.asset(
            'assets/icons/xp_icon.png',
            width: 23,
            height: 23,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.bolt_rounded,
              color: AppColors.mathYellow,
              size: 20,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$xp',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: 1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const Spacer(),

          // Level (shield icon + text)
          Image.asset(
            'assets/icons/level_icon.png',
            width: 20,
            height: 20,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.shield_rounded,
              color: AppColors.skyBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'Lv.$level',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: 1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
