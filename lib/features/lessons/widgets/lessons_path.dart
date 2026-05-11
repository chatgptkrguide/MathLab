// Lessons path — zigzag lesson nodes column with unit dividers and lock logic
import 'package:flutter/material.dart';

import '../../../data/models/lesson/lesson_model.dart';
import '../../../data/models/lesson/lesson_progress_model.dart';
import '../../../data/models/lesson/unit_model.dart';
import '../../../data/providers/lesson/lesson_progress_provider.dart';
import '../../../shared/constants/app_colors.dart';
import '../lessons_screen.dart';
import 'lessons_node.dart';

class LessonsPath extends StatelessWidget {
  final List<LessonModel> lessons;
  final LessonProgressState progressState;
  final List<UnitModel> allUnits;
  final void Function(
    String lessonId,
    List<UnitModel> units,
    LessonProgressState progressState,
  ) onLessonTap;

  const LessonsPath({
    super.key,
    required this.lessons,
    required this.progressState,
    required this.allUnits,
    required this.onLessonTap,
  });

  @override
  Widget build(BuildContext context) {
    if (lessons.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text(
            '이 과목에는 아직 레슨이 없습니다',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    // 유닛 잠금 맵 생성 (같은 과목 내에서 이전 유닛 완료 여부)
    final unitUnlockMap = <String, bool>{};
    // 과목별로 그룹화하여 순차 잠금 적용
    final subjectGroups = <String, List<UnitModel>>{};
    for (final unit in allUnits) {
      subjectGroups.putIfAbsent(unit.subject, () => []).add(unit);
    }
    for (final subjectUnits in subjectGroups.values) {
      bool prevDone = true;
      for (final unit in subjectUnits) {
        unitUnlockMap[unit.id] = prevDone;
        bool allDone = unit.lessons.isNotEmpty;
        for (final l in unit.lessons) {
          if (progressState.progressMap[l.id]?.status !=
              LessonStatus.completed) {
            allDone = false;
          }
        }
        prevDone = allDone;
      }
    }

    // Determine current lesson index
    int currentIndex = 0;
    for (int i = 0; i < lessons.length; i++) {
      final lesson = lessons[i];
      final unit = allUnits
          .where((u) => u.lessons.any((l) => l.id == lesson.id))
          .firstOrNull;
      final unitUnlocked =
          unit != null ? (unitUnlockMap[unit.id] ?? true) : true;

      final progress = progressState.progressMap[lesson.id];
      final isFirstInUnit = unit != null &&
          unit.lessons.isNotEmpty &&
          unit.lessons.first.id == lesson.id;
      final isFirstOrPrevCompleted = (i == 0 || isFirstInUnit) ||
          (i > 0 &&
              progressState.progressMap[lessons[i - 1].id]?.status ==
                  LessonStatus.completed);
      LessonStatus status;
      if (!unitUnlocked) {
        status = progress?.status ?? LessonStatus.locked;
      } else {
        status = progress?.status ??
            (isFirstOrPrevCompleted
                ? LessonStatus.unlocked
                : LessonStatus.locked);
      }

      if (status == LessonStatus.unlocked ||
          status == LessonStatus.inProgress) {
        currentIndex = i;
        break;
      }
      if (status == LessonStatus.completed) {
        currentIndex = i + 1;
      }
    }
    if (currentIndex >= lessons.length) {
      currentIndex = lessons.length - 1;
    }

    // 유닛 구분선을 위한 레슨→유닛 매핑
    final lessonToUnit = <String, String>{};
    for (final unit in allUnits) {
      for (final l in unit.lessons) {
        lessonToUnit[l.id] = unit.id;
      }
    }

    return Column(
      children: List.generate(lessons.length, (index) {
        final lesson = lessons[index];
        final progress = progressState.progressMap[lesson.id];

        // 유닛 잠금 확인
        final unitId = lessonToUnit[lesson.id];
        final unit = allUnits.where((u) => u.id == unitId).firstOrNull;
        final unitUnlocked =
            unitId != null ? (unitUnlockMap[unitId] ?? true) : true;
        final isFirstInUnit = unit != null &&
            unit.lessons.isNotEmpty &&
            unit.lessons.first.id == lesson.id;

        final isFirstOrPrevCompleted = (index == 0 || isFirstInUnit) ||
            (index > 0 &&
                progressState.progressMap[lessons[index - 1].id]?.status ==
                    LessonStatus.completed);

        LessonStatus status;
        if (!unitUnlocked) {
          status = progress?.status ?? LessonStatus.locked;
        } else {
          status = progress?.status ??
              (isFirstOrPrevCompleted
                  ? LessonStatus.unlocked
                  : LessonStatus.locked);
        }

        final isCompleted = status == LessonStatus.completed;
        final isLocked = status == LessonStatus.locked;
        final isActive = !isLocked;
        final isCurrent = index == currentIndex && !isCompleted;

        // 유닛 구분선: 이전 레슨과 다른 유닛에 속할 때
        final showUnitDivider = index > 0 &&
            unitId != null &&
            lessonToUnit[lessons[index - 1].id] != unitId;

        // Zigzag alignment: center, left, right, left, right...
        final zigzagAlign = _getZigzagAlignment(index);

        final Alignment nodeAlignment;
        switch (zigzagAlign) {
          case _ZigzagAlign.left:
            nodeAlignment = const Alignment(-0.55, 0);
          case _ZigzagAlign.right:
            nodeAlignment = const Alignment(0.55, 0);
          case _ZigzagAlign.center:
            nodeAlignment = Alignment.center;
        }

        return Column(
          children: [
            // 유닛 구분선
            if (showUnitDivider && unit != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 20, top: 4),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: unitUnlocked
                        ? AppColors.skyBlue.withValues(alpha: 0.08)
                        : Colors.grey.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: unitUnlocked
                          ? AppColors.skyBlue.withValues(alpha: 0.2)
                          : Colors.grey.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        unitUnlocked
                            ? Icons.menu_book_rounded
                            : Icons.lock_outline_rounded,
                        size: 16,
                        color: unitUnlocked
                            ? AppColors.skyBlue
                            : Colors.grey[400],
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          unit.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: unitUnlocked
                                ? AppColors.skyBlue
                                : Colors.grey[400],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!unitUnlocked) ...[
                        const SizedBox(width: 6),
                        Text(
                          '이전 단원 완료 필요',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            Padding(
              key: index == 0 ? LessonsScreenFigma.lessonPathKey : null,
              padding: const EdgeInsets.only(bottom: 28),
              child: Align(
                alignment: nodeAlignment,
                child: LessonsNode(
                  index: index,
                  lesson: lesson,
                  status: status,
                  isActive: isActive,
                  isCompleted: isCompleted,
                  isCurrent: isCurrent,
                  allUnits: allUnits,
                  progressState: progressState,
                  onTap: onLessonTap,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  _ZigzagAlign _getZigzagAlignment(int index) {
    if (index == 0) return _ZigzagAlign.center;
    // Pattern: center, left, right, left, right...
    return index % 2 == 1 ? _ZigzagAlign.left : _ZigzagAlign.right;
  }
}

enum _ZigzagAlign { left, center, right }
