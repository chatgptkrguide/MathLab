// Subject section — horizontal scroll of grade-based subject cards
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers/user/user_provider.dart';
import '../../../data/providers/infrastructure/navigation_provider.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/grade_curriculum_map.dart';

class ProfileSubjectSection extends ConsumerWidget {
  const ProfileSubjectSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final grade = user?.currentGrade ?? '중1';
    final gradeSubjects = GradeCurriculumMap.getSubjectsForGrade(grade);
    final hasContent = GradeCurriculumMap.hasContentForGrade(grade);

    // 콘텐츠 미보유 학년은 안내 카드로 대체.
    if (!hasContent && gradeSubjects.isNotEmpty) {
      return Container(
        height: 130,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.hourglass_bottom_rounded,
                    size: 22, color: Color(0xFF8B8B93)),
                const SizedBox(width: 8),
                Text(
                  '${gradeSubjects.first} 콘텐츠 준비 중',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF18181B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              '곧 학년 맞춤 콘텐츠를 만나보실 수 있어요.\n그동안 다른 학년 콘텐츠로 미리 체험해 보세요.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF52525B),
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    final displaySubjects = gradeSubjects.isEmpty
        ? ['공통수학1', '공통수학2', '수학I']
        : gradeSubjects;
    final subjects = displaySubjects.map((name) => {'name': name}).toList();

    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: subjects.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final subject = subjects[index];
          final name = subject['name'] ?? '과목';
          return GestureDetector(
            onTap: () => ref.read(navigationProvider.notifier).goToLessons(),
            child: Container(
              width: 120,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF18181B),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.skyBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      size: 20,
                      color: AppColors.skyBlue,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
