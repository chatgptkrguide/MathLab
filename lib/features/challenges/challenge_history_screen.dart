// Challenge History Screen — Figma Screen 03 Design
// Blue rounded header + stats bar + calendar with highlighted days

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/lesson/lesson_progress_model.dart';
import '../../data/providers/auth/auth_provider.dart';
import '../../data/providers/curriculum/curriculum_provider.dart';
import '../../data/providers/lesson/lesson_progress_provider.dart';
import '../../data/providers/user/user_provider.dart';
import '../../shared/constants/app_colors.dart';

class ChallengeHistoryScreen extends ConsumerWidget {
  const ChallengeHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = ref.watch(userProvider);
    final uid = authState.firebaseUser?.uid;

    if (uid == null || user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final progressState = ref.watch(lessonProgressProvider(uid));
    final curriculumAsync = ref.watch(curriculumProvider);

    return curriculumAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(
        child: Text('커리큘럼을 불러오는데 실패했습니다'),
      ),
      data: (allUnits) {
        final totalLessons =
            allUnits.fold<int>(0, (sum, u) => sum + u.lessonCount);
        final completedLessons = progressState.completedCount;

        // Find active unit
        String activeUnitTitle = allUnits.first.title;
        for (final unit in allUnits) {
          for (final lesson in unit.lessons) {
            final lp = progressState.progressMap[lesson.id];
            if (lp != null && lp.status == LessonStatus.inProgress) {
              activeUnitTitle = unit.title;
              break;
            }
          }
        }

        // Collect completed dates from lesson progress for calendar
        final completedDates = <DateTime>{};
        for (final progress in progressState.progressMap.values) {
          if (progress.isCompleted && progress.completedAt != null) {
            final d = progress.completedAt!;
            completedDates.add(DateTime(d.year, d.month, d.day));
          }
          if (progress.lastAttemptedAt != null) {
            final d = progress.lastAttemptedAt!;
            completedDates.add(DateTime(d.year, d.month, d.day));
          }
        }

        // Calculate challenge days and remaining
        final challengeDays = user.streak;
        final totalChallengeDays = totalLessons;
        final remainingDays =
            (totalChallengeDays - challengeDays).clamp(0, totalChallengeDays);

        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              // Blue rounded header
              _buildHeader(context, activeUnitTitle, user.streak,
                  user.totalXp, user.level),
              // Main content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '챌린지',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF333333),
                            ),
                          ),
                          Text(
                            '$completedLessons/$totalLessons',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Level badge with progress bar
                      _buildLevelBadge(user.level, user.levelProgress),

                      const SizedBox(height: 16),

                      // Two stat boxes side by side
                      Row(
                        children: [
                          Expanded(
                            child: _buildChallengeStatBox(
                              icon: Icons.local_fire_department_rounded,
                              iconColor: const Color(0xFFFF9600),
                              title: 'Challenge Done',
                              value: '$challengeDays Days',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildChallengeStatBox(
                              icon: Icons.calendar_month_rounded,
                              iconColor: AppColors.skyBlue,
                              title: 'Remaining',
                              value: '$remainingDays Days',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Calendar section
                      _buildCalendarSection(completedDates),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Blue rounded header with back arrow, logo, and stats bar
  Widget _buildHeader(BuildContext context, String activeUnitTitle,
      int streak, int totalXp, int level) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.skyBlue,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              // Top row: back arrow + logo
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'G',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'GoMath',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const SizedBox(width: 20), // balance for back arrow
                ],
              ),

              const SizedBox(height: 12),

              // Stats bar
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Subject name
                    Flexible(
                      child: Text(
                        activeUnitTitle,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildHeaderDivider(),
                    // Streak
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_fire_department_rounded,
                          color: Color(0xFFFF9600),
                          size: 16,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '$streak',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    _buildHeaderDivider(),
                    // XP
                    Text(
                      '$totalXp',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    _buildHeaderDivider(),
                    // Level
                    Text(
                      'HLv$level',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderDivider() {
    return Container(
      width: 1,
      height: 14,
      color: Colors.white.withValues(alpha: 0.3),
    );
  }

  /// Level badge: shield icon + "H Lv1" with orange progress bar
  Widget _buildLevelBadge(int level, double progress) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Shield icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFF9600).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.shield_rounded,
              color: Color(0xFFFF9600),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'H Lv$level',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor:
                        const Color(0xFFFF9600).withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFFF9600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Stat box for Challenge Done / Remaining
  Widget _buildChallengeStatBox({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }

  /// Calendar section with month title and grid
  Widget _buildCalendarSection(Set<DateTime> completedDates) {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;

    // Month names in Korean
    const monthNames = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Calendar header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${monthNames[month]} $year',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF333333),
              ),
            ),
            Text(
              'VIEW',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.skyBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildCalendarGrid(year, month, completedDates),
      ],
    );
  }

  /// Calendar grid with day labels and date cells
  Widget _buildCalendarGrid(
      int year, int month, Set<DateTime> completedDates) {
    const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    // Monday = 1, Sunday = 7
    final startWeekday = firstDay.weekday; // 1 = Monday

    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);

    return Column(
      children: [
        // Day labels row
        Row(
          children: dayLabels.map((label) {
            return Expanded(
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        // Date cells
        ..._buildCalendarRows(
            year, month, daysInMonth, startWeekday, completedDates, todayNorm),
      ],
    );
  }

  List<Widget> _buildCalendarRows(int year, int month, int daysInMonth,
      int startWeekday, Set<DateTime> completedDates, DateTime today) {
    final rows = <Widget>[];
    // startWeekday: 1=Mon ... 7=Sun
    // offset: how many empty cells before day 1
    final offset = startWeekday - 1;
    final totalCells = offset + daysInMonth;
    final rowCount = (totalCells / 7).ceil();

    for (int row = 0; row < rowCount; row++) {
      final cells = <Widget>[];
      for (int col = 0; col < 7; col++) {
        final cellIndex = row * 7 + col;
        final dayNum = cellIndex - offset + 1;

        if (dayNum < 1 || dayNum > daysInMonth) {
          cells.add(const Expanded(child: SizedBox(height: 40)));
          continue;
        }

        final date = DateTime(year, month, dayNum);
        final isCompleted = completedDates.contains(date);
        final isToday = date == today;

        cells.add(
          Expanded(
            child: Container(
              height: 40,
              margin: const EdgeInsets.symmetric(vertical: 2),
              child: Center(
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? AppColors.skyBlue
                        : isToday
                            ? AppColors.skyBlue.withValues(alpha: 0.12)
                            : Colors.transparent,
                  ),
                  child: Center(
                    child: Text(
                      '$dayNum',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            (isCompleted || isToday)
                                ? FontWeight.w700
                                : FontWeight.w400,
                        color: isCompleted
                            ? Colors.white
                            : isToday
                                ? AppColors.skyBlue
                                : const Color(0xFF555555),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
      rows.add(Row(children: cells));
    }

    return rows;
  }
}
