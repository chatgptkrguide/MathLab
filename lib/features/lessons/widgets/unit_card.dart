// 📦 Unit Card Widget
//
// Visual card representing a unit with its lessons in a tree structure.

import 'package:flutter/material.dart';
import '../../../data/models/lesson/unit_model.dart';
import '../../../data/models/lesson/lesson_progress_model.dart';
import '../../../shared/constants/app_colors.dart';
import 'lesson_node.dart';

class UnitCard extends StatelessWidget {
  final UnitModel unit;
  final Map<String, LessonProgressModel> progressMap;
  final Function(String lessonId) onLessonTap;

  const UnitCard({
    super.key,
    required this.unit,
    required this.progressMap,
    required this.onLessonTap,
  });

  @override
  Widget build(BuildContext context) {
    final completedCount = unit.lessons.where((lesson) {
      final progress = progressMap[lesson.id];
      return progress?.status == LessonStatus.completed;
    }).length;

    final totalLessons = unit.lessons.length;
    final progressPercentage = totalLessons > 0 ? (completedCount / totalLessons) : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Unit header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _getUnitThemeColor().withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Unit emoji
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _getUnitThemeColor().withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          unit.emoji,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Unit ${unit.order}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _getUnitThemeColor(),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            unit.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  unit.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),

                // Progress bar
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progressPercentage,
                          minHeight: 8,
                          backgroundColor: AppColors.borderLight,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getUnitThemeColor(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$completedCount/$totalLessons',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Lessons tree
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: _buildLessonsTree(context),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonsTree(BuildContext context) {
    if (unit.lessons.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            '레슨이 준비 중입니다',
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Column(
      children: List.generate(
        unit.lessons.length,
        (index) {
          final lesson = unit.lessons[index];
          final progress = progressMap[lesson.id];
          final isFirst = index == 0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              children: [
                // Connection line from previous lesson
                if (!isFirst)
                  Container(
                    width: 3,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          _getUnitThemeColor().withValues(alpha: 0.3),
                          _getUnitThemeColor().withValues(alpha: 0.1),
                        ],
                      ),
                    ),
                  ),

                // Lesson node
                LessonNode(
                  lesson: lesson,
                  progress: progress,
                  isFirst: isFirst,
                  onTap: () => onLessonTap(lesson.id),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getUnitThemeColor() {
    switch (unit.theme) {
      case UnitTheme.blue:
        return AppColors.mathBlue;
      case UnitTheme.green:
        return AppColors.mathGreen;
      case UnitTheme.orange:
        return AppColors.mathOrange;
      case UnitTheme.purple:
        return AppColors.mathPurple;
      case UnitTheme.red:
        return AppColors.mathRed;
      case UnitTheme.yellow:
        return const Color(0xFFFFC107);
    }
  }
}
