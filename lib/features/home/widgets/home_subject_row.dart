// Home subject row — grade-based horizontal subject chips.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers/infrastructure/navigation_provider.dart';
import '../../../data/providers/user/user_provider.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/grade_curriculum_map.dart';
import '../home_screen.dart';

class HomeSubjectRow extends ConsumerWidget {
  const HomeSubjectRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final grade = user?.currentGrade ?? '중1';
    final subjects = GradeCurriculumMap.getSubjectsForGrade(grade);
    // 전체 접근이면 대표 과목 2개만 표시
    final displaySubjects = subjects.isEmpty
        ? ['공통수학1', '공통수학2']
        : subjects.take(2).toList();

    final subjectStyles = {
      '기초수학': (Icons.calculate_rounded, AppColors.mathGreen, const Color(0xFFE8FFE0)),
      '중학수학': (Icons.school_rounded, AppColors.mathBlue, const Color(0xFFE0F0FF)),
      '공통수학1': (Icons.functions_rounded, AppColors.royalBlue, const Color(0xFFE8EEFF)),
      '공통수학2': (Icons.show_chart_rounded, AppColors.tealGreen, const Color(0xFFE0F5F6)),
      '수학I': (Icons.trending_up_rounded, AppColors.mathOrange, const Color(0xFFFFF3E0)),
      '수학II': (Icons.auto_graph_rounded, AppColors.mathPurple, const Color(0xFFF3E8FF)),
      '확률과통계': (Icons.bar_chart_rounded, AppColors.mathGreen, const Color(0xFFE8FFE0)),
      '미적분': (Icons.timeline_rounded, AppColors.mathRed, const Color(0xFFFFE8E8)),
      '기하': (Icons.hexagon_rounded, AppColors.skyBlue, const Color(0xFFE0F0FF)),
    };

    return SizedBox(
      key: HomeScreenFigma.subjectRowKey,
      height: 48,
      child: Row(
        children: displaySubjects.asMap().entries.map((entry) {
          final i = entry.key;
          final name = entry.value;
          final style = subjectStyles[name] ?? (Icons.menu_book_rounded, AppColors.mathBlue, const Color(0xFFE0F0FF));

          return Expanded(
            child: Row(
              children: [
                if (i > 0)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(Icons.arrow_forward_ios_rounded, size: 20, color: Color(0xFF18181B)),
                  ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => ref.read(navigationProvider.notifier).goToLessons(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(color: style.$3, shape: BoxShape.circle),
                            child: Icon(style.$1, size: 16, color: style.$2),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF18181B)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
