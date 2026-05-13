// Subject section — horizontal scroll of representative subject cards
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers/infrastructure/navigation_provider.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/subject_labels.dart';

class ProfileSubjectSection extends ConsumerWidget {
  const ProfileSubjectSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 학년 필터 해제됨 — 모든 사용자에게 대표 과목 카드 노출.
    const displaySubjects = ['공통수학1', '공통수학2', '수학I'];
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
                    SubjectLabels.displayOf(name),
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
