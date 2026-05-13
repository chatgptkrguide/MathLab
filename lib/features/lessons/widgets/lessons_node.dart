// Lessons node — single zigzag node tile with START label and title
import 'package:flutter/material.dart';

import '../../../data/models/lesson/lesson_model.dart';
import '../../../data/models/lesson/lesson_progress_model.dart';
import '../../../data/models/lesson/unit_model.dart';
import '../../../data/providers/lesson/lesson_progress_provider.dart';
import '../../../shared/constants/app_colors.dart';

class LessonsNode extends StatelessWidget {
  final int index;
  final LessonModel lesson;
  final LessonStatus status;
  final bool isActive;
  final bool isCompleted;
  final bool isCurrent;
  final List<UnitModel> allUnits;
  final LessonProgressState progressState;
  final void Function(
    String lessonId,
    List<UnitModel> units,
    LessonProgressState progressState,
  ) onTap;

  const LessonsNode({
    super.key,
    required this.index,
    required this.lesson,
    required this.status,
    required this.isActive,
    required this.isCompleted,
    required this.isCurrent,
    required this.allUnits,
    required this.progressState,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Node icon based on lesson type
    final nodeIcon = _getLessonIcon(lesson.type, index);

    // Colors
    const activeColor = AppColors.nodeActive;
    const completedColor = AppColors.mathGreen;
    const lockedBgColor = AppColors.profileBg;

    final bgColor = isCompleted
        ? completedColor
        : isActive
            ? activeColor
            : lockedBgColor;

    final isLocked = !isActive;
    final iconOpacity = isLocked ? 0.2 : 1.0;

    return GestureDetector(
      onTap: () => onTap(lesson.id, allUnits, progressState),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // START button for current lesson
          if (isCurrent) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.nodeActive, Color(0xFF1A3CF7)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Text(
                '시작!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Node: rounded square — current 레슨은 더 크게(110), 그 외 84
          Container(
            width: isCurrent ? 110 : 84,
            height: isCurrent ? 110 : 84,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(isCurrent ? 16 : 12),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: bgColor.withValues(
                          alpha: isCurrent ? 0.5 : 0.35,
                        ),
                        blurRadius: isCurrent ? 18 : 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
              border: isLocked
                  ? Border.all(
                      color: AppColors.profileBg,
                      width: 0,
                    )
                  : null,
            ),
            child: Center(
              child: Opacity(
                opacity: iconOpacity,
                child: Icon(
                  isCompleted ? Icons.check_rounded : nodeIcon,
                  color: isLocked ? AppColors.skyBlue : Colors.white,
                  size: isCompleted
                      ? 36
                      : isCurrent
                          ? 44
                          : 32,
                ),
              ),
            ),
          ),

          const SizedBox(height: 6),

          // Lesson title
          SizedBox(
            width: 100,
            child: Text(
              lesson.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? AppColors.textPrimary
                    : AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getLessonIcon(LessonType type, int index) {
    // Cycle through different icons for visual variety (matching Figma design)
    const iconCycle = [
      Icons.auto_stories_rounded, // book
      Icons.straighten_rounded, // ruler
      Icons.menu_book_rounded, // book alt
      Icons.backpack_rounded, // bag
      Icons.schedule_rounded, // clock
      Icons.emoji_events_rounded, // trophy
      Icons.laptop_mac_rounded, // laptop
      Icons.language_rounded, // globe
      Icons.dashboard_rounded, // blackboard
    ];

    // Use lesson type for specific icons, fallback to cycle
    switch (type) {
      case LessonType.story:
        return Icons.auto_stories_rounded;
      case LessonType.practice:
        return Icons.fitness_center_rounded;
      case LessonType.review:
        return Icons.replay_rounded;
      case LessonType.challenge:
        return Icons.flash_on_rounded;
      case LessonType.boss:
        return Icons.emoji_events_rounded;
      default:
        return iconCycle[index % iconCycle.length];
    }
  }
}
