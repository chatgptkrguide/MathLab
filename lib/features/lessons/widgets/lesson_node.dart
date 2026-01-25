/// 🎯 Lesson Node Widget
///
/// Visual node representing a lesson in the curriculum tree (Duolingo-style).

import 'package:flutter/material.dart';
import '../../../data/models/lesson/lesson_model.dart';
import '../../../data/models/lesson/lesson_progress_model.dart';
import '../../../shared/constants/app_colors.dart';

class LessonNode extends StatelessWidget {
  final LessonModel lesson;
  final LessonProgressModel? progress;
  final VoidCallback? onTap;
  final bool isFirst; // First lesson in unit

  const LessonNode({
    Key? key,
    required this.lesson,
    this.progress,
    this.onTap,
    this.isFirst = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final status = progress?.status ?? LessonStatus.locked;
    final stars = progress?.stars ?? 0;
    final isUnlocked = status != LessonStatus.locked;
    final isCompleted = status == LessonStatus.completed;

    return GestureDetector(
      onTap: isUnlocked ? onTap : null,
      child: Column(
        children: [
          // Lesson node circle
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow for unlocked lessons
              if (isUnlocked && !isCompleted)
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _getNodeColor(status, lesson.type).withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),

              // Main circle
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getNodeColor(status, lesson.type),
                  border: Border.all(
                    color: isCompleted
                        ? AppColors.mathGreen
                        : status == LessonStatus.locked
                            ? AppColors.borderDark
                            : Colors.white,
                    width: 4,
                  ),
                ),
                child: _buildNodeContent(status, stars, lesson.type),
              ),

              // Stars indicator for completed lessons
              if (isCompleted && stars > 0)
                Positioned(
                  bottom: -5,
                  child: _buildStarsIndicator(stars),
                ),
            ],
          ),

          // Lesson title
          const SizedBox(height: 12),
          SizedBox(
            width: 100,
            child: Text(
              lesson.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isUnlocked ? FontWeight.w600 : FontWeight.normal,
                color: isUnlocked ? AppColors.textPrimary : AppColors.textTertiary,
              ),
            ),
          ),

          // XP reward badge
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isUnlocked
                  ? AppColors.mathOrange.withOpacity(0.15)
                  : AppColors.borderLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${lesson.xpReward} XP',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isUnlocked ? AppColors.mathOrange : AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNodeContent(LessonStatus status, int stars, LessonType type) {
    if (status == LessonStatus.locked) {
      return const Icon(
        Icons.lock,
        color: Colors.white54,
        size: 32,
      );
    }

    if (status == LessonStatus.completed) {
      return const Icon(
        Icons.check,
        color: Colors.white,
        size: 40,
      );
    }

    // Show type-specific icon for unlocked lessons
    return Icon(
      _getTypeIcon(type),
      color: Colors.white,
      size: 36,
    );
  }

  Widget _buildStarsIndicator(int stars) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.mathOrange,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          stars.clamp(0, 3),
          (index) => const Icon(
            Icons.star,
            color: Colors.white,
            size: 12,
          ),
        ),
      ),
    );
  }

  Color _getNodeColor(LessonStatus status, LessonType type) {
    if (status == LessonStatus.locked) {
      return AppColors.borderDark;
    }

    if (status == LessonStatus.completed) {
      return AppColors.mathGreen;
    }

    // Color based on lesson type for unlocked lessons
    switch (type) {
      case LessonType.story:
        return AppColors.mathPurple;
      case LessonType.practice:
        return AppColors.mathOrange;
      case LessonType.review:
        return AppColors.mathBlue;
      case LessonType.challenge:
        return AppColors.mathRed;
      case LessonType.boss:
        return const Color(0xFF8B5CF6); // Dark purple for boss
      default:
        return AppColors.mathBlue;
    }
  }

  IconData _getTypeIcon(LessonType type) {
    switch (type) {
      case LessonType.story:
        return Icons.menu_book;
      case LessonType.practice:
        return Icons.fitness_center;
      case LessonType.review:
        return Icons.replay;
      case LessonType.challenge:
        return Icons.flash_on;
      case LessonType.boss:
        return Icons.emoji_events;
      default:
        return Icons.school;
    }
  }
}
