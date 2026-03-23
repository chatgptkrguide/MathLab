import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/lesson/lesson_model.dart';
import '../../data/models/lesson/lesson_progress_model.dart';
import '../../data/models/lesson/unit_model.dart';
import '../../data/providers/curriculum/curriculum_provider.dart';
import '../../data/providers/lesson/lesson_progress_provider.dart';
import '../../data/providers/user/user_provider.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/grade_curriculum_map.dart';
import '../problems/problem_solving_screen.dart';

class LessonsScreenFigma extends ConsumerStatefulWidget {
  /// 코치마크용 GlobalKey
  static final lessonPathKey = GlobalKey(debugLabel: 'lessonPath');

  const LessonsScreenFigma({super.key});

  @override
  ConsumerState<LessonsScreenFigma> createState() => _LessonsScreenFigmaState();
}

class _LessonsScreenFigmaState extends ConsumerState<LessonsScreenFigma>
    with SingleTickerProviderStateMixin {
  // Subject selection state
  String? _selectedSubject; // null = 전체

  late AnimationController _bannerController;
  late Animation<Offset> _bannerSlideAnimation;
  late Animation<double> _bannerFadeAnimation;

  @override
  void initState() {
    super.initState();

    _bannerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _bannerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _bannerController,
      curve: Curves.easeOutCubic,
    ));
    _bannerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bannerController, curve: Curves.easeOut),
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _bannerController.forward();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFirstLessonsIfNeeded();
    });
  }

  void _initializeFirstLessonsIfNeeded() {
    final user = ref.read(userProvider);
    if (user == null) return;

    final curriculumAsync = ref.read(curriculumProvider);
    final units = curriculumAsync.valueOrNull;
    if (units == null) return;

    final progressState = ref.read(lessonProgressProvider(user.uid));

    if (progressState.progressMap.isEmpty) {
      final firstLessonIds = <String>[];
      for (final unit in units) {
        if (unit.lessons.isNotEmpty) {
          firstLessonIds.add(unit.lessons.first.id);
        }
      }

      if (firstLessonIds.isNotEmpty) {
        ref
            .read(lessonProgressProvider(user.uid).notifier)
            .initializeFirstLessons(firstLessonIds);
      }
    }
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  // Firestore subject 값 → 표시 이름
  static const _subjectLabels = {
    '공통수학1': '공통수학1',
    '공통수학2': '공통수학2',
    '수학I': '수학I',
    '수학II': '수학II',
    '확률과통계': '확률과통계',
    '미적분': '미적분',
    '기하': '기하',
  };

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final progressState = user != null
        ? ref.watch(lessonProgressProvider(user.uid))
        : const LessonProgressState();
    final curriculumAsync = ref.watch(curriculumProvider);

    final streak = user?.streak ?? 0;
    final xp = user?.xp ?? 0;
    final level = user?.level ?? 1;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          // Blue rounded header with dropdown
          _buildBlueHeader(curriculumAsync),

          // Stats bar
          _buildStatsBar(streak, xp, level, curriculumAsync),

          // Main content: lesson path
          if (progressState.isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.skyBlue,
                ),
              ),
            )
          else
            curriculumAsync.when(
              loading: () => const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.skyBlue,
                  ),
                ),
              ),
              error: (_, __) => Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '커리큘럼을 불러오는데 실패했습니다',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => ref.invalidate(curriculumProvider),
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (allUnits) {
                // Filter units by user's grade
                final grade = user?.currentGrade ?? '중1';
                final allowedSubjects =
                    GradeCurriculumMap.getSubjectsForGrade(grade);
                final gradeFilteredUnits =
                    GradeCurriculumMap.hasFullAccess(grade)
                        ? allUnits
                        : allUnits
                            .where(
                                (u) => allowedSubjects.contains(u.subject))
                            .toList();

                final units = _selectedSubject == null
                    ? gradeFilteredUnits
                    : gradeFilteredUnits
                        .where((u) => u.subject == _selectedSubject)
                        .toList();

                // Flatten all lessons from all units for the path
                final allLessons = <LessonModel>[];
                final lessonUnitMap = <String, UnitModel>{};
                for (final unit in units) {
                  for (final lesson in unit.lessons) {
                    allLessons.add(lesson);
                    lessonUnitMap[lesson.id] = unit;
                  }
                }

                return Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(curriculumProvider);
                    },
                    color: AppColors.skyBlue,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.only(
                        top: 24,
                        bottom: 100,
                      ),
                      child: SlideTransition(
                        position: _bannerSlideAnimation,
                        child: FadeTransition(
                          opacity: _bannerFadeAnimation,
                          child: _buildLessonPath(
                            allLessons,
                            progressState,
                            allUnits,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBlueHeader(AsyncValue<List<UnitModel>> curriculumAsync) {
    // Filter subjects by user's grade
    final user = ref.read(userProvider);
    final grade = user?.currentGrade ?? '중1';
    final allowedSubjects = GradeCurriculumMap.getSubjectsForGrade(grade);
    final fullAccess = GradeCurriculumMap.hasFullAccess(grade);

    // Firestore에서 가져온 유닛들의 subject 목록 (학년 필터 적용)
    final subjects = <String>[];
    final allUnits = curriculumAsync.valueOrNull ?? [];
    for (final u in allUnits) {
      if (!subjects.contains(u.subject)) {
        if (fullAccess || allowedSubjects.contains(u.subject)) {
          subjects.add(u.subject);
        }
      }
    }

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
              // 과목 드롭다운
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: _selectedSubject,
                    isDense: true,
                    icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.skyBlue, size: 20),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.skyBlue,
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('전체 과목'),
                      ),
                      ...subjects.map((s) => DropdownMenuItem<String?>(
                        value: s,
                        child: Text(_subjectLabels[s] ?? s),
                      )),
                    ],
                    onChanged: (v) {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedSubject = v);
                    },
                  ),
                ),
              ),
              const Spacer(),
              // GoMath 로고
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

  Widget _buildStatsBar(
    int streak,
    int xp,
    int level,
    AsyncValue<List<UnitModel>> curriculumAsync,
  ) {
    // Get current unit name
    String unitName = '전체 과목';
    final units = curriculumAsync.valueOrNull;
    if (units != null && _selectedSubject != null) {
      final filteredUnits =
          units.where((u) => u.subject == _selectedSubject).toList();
      if (filteredUnits.isNotEmpty) {
        unitName = filteredUnits.first.title;
      }
    } else if (units != null && units.isNotEmpty) {
      unitName = units.first.title;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      color: const Color(0xFFFAFAFA),
      child: Row(
        children: [
          // Unit name chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              unitName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
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


  // ============================================================
  // === Zigzag Lesson Path ===
  // ============================================================

  Widget _buildLessonPath(
    List<LessonModel> lessons,
    LessonProgressState progressState,
    List<UnitModel> allUnits,
  ) {
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

    // Determine current lesson index
    int currentIndex = 0;
    for (int i = 0; i < lessons.length; i++) {
      final progress = progressState.progressMap[lessons[i].id];
      final isFirstOrPrevCompleted = i == 0 ||
          (i > 0 &&
              progressState.progressMap[lessons[i - 1].id]?.status ==
                  LessonStatus.completed);
      final status = progress?.status ??
          (isFirstOrPrevCompleted
              ? LessonStatus.unlocked
              : LessonStatus.locked);

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

    return Column(
      children: List.generate(lessons.length, (index) {
        final lesson = lessons[index];
        final progress = progressState.progressMap[lesson.id];
        final isFirstOrPrevCompleted = index == 0 ||
            (index > 0 &&
                progressState.progressMap[lessons[index - 1].id]?.status ==
                    LessonStatus.completed);
        final status = progress?.status ??
            (isFirstOrPrevCompleted
                ? LessonStatus.unlocked
                : LessonStatus.locked);
        final isCompleted = status == LessonStatus.completed;
        final isLocked = status == LessonStatus.locked;
        final isActive = !isLocked;
        final isCurrent = index == currentIndex && !isCompleted;

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

        return Padding(
          key: index == 0 ? LessonsScreenFigma.lessonPathKey : null,
          padding: const EdgeInsets.only(bottom: 28),
          child: Align(
            alignment: nodeAlignment,
            child: _buildLessonNode(
              index: index,
              lesson: lesson,
              status: status,
              isActive: isActive,
              isCompleted: isCompleted,
              isCurrent: isCurrent,
              allUnits: allUnits,
              progressState: progressState,
            ),
          ),
        );
      }),
    );
  }

  _ZigzagAlign _getZigzagAlignment(int index) {
    if (index == 0) return _ZigzagAlign.center;
    // Pattern: center, left, right, left, right...
    return index % 2 == 1 ? _ZigzagAlign.left : _ZigzagAlign.right;
  }

  Widget _buildLessonNode({
    required int index,
    required LessonModel lesson,
    required LessonStatus status,
    required bool isActive,
    required bool isCompleted,
    required bool isCurrent,
    required List<UnitModel> allUnits,
    required LessonProgressState progressState,
  }) {
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
      onTap: () => _handleLessonTap(lesson.id, allUnits, progressState),
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

          // Node: rounded square
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: bgColor.withValues(alpha: 0.35),
                        blurRadius: 12,
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
                  color: isLocked
                      ? AppColors.skyBlue
                      : Colors.white,
                  size: isCompleted ? 36 : 32,
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

  void _handleLessonTap(
    String lessonId,
    List<UnitModel> units,
    LessonProgressState progressState,
  ) {
    final user = ref.read(userProvider);
    if (user == null) return;

    final progress = progressState.progressMap[lessonId];

    // Find lesson model and index
    LessonModel? lesson;
    int lessonIndex = -1;
    List<LessonModel>? parentLessons;

    for (final unit in units) {
      for (int i = 0; i < unit.lessons.length; i++) {
        if (unit.lessons[i].id == lessonId) {
          lesson = unit.lessons[i];
          lessonIndex = i;
          parentLessons = unit.lessons;
          break;
        }
      }
      if (lesson != null) break;
    }

    if (lesson == null) return;

    // Check if accessible
    bool isAccessible = false;

    if (lessonIndex == 0) {
      isAccessible = true;
    } else if (progress != null && progress.status != LessonStatus.locked) {
      isAccessible = true;
    } else if (parentLessons != null && lessonIndex > 0) {
      final prevLessonId = parentLessons[lessonIndex - 1].id;
      final prevProgress = progressState.progressMap[prevLessonId];
      if (prevProgress?.status == LessonStatus.completed) {
        isAccessible = true;
      }
    }

    // Show snackbar for locked lessons
    if (!isAccessible) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('이전 레슨을 먼저 완료해주세요!'),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    // Find parent unit info
    String? unitTitle;
    int? stepNumber;
    int? totalSteps;
    for (final unit in units) {
      for (int i = 0; i < unit.lessons.length; i++) {
        if (unit.lessons[i].id == lessonId) {
          unitTitle = unit.title;
          stepNumber = i + 1;
          totalSteps = unit.lessons.length;
          break;
        }
      }
      if (unitTitle != null) break;
    }

    // Record lesson start
    ref
        .read(lessonProgressProvider(user.uid).notifier)
        .startLesson(lessonId);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProblemSolvingScreen(
          lessonId: lessonId,
          lessonTitle: lesson!.title,
          unitTitle: unitTitle,
          stepNumber: stepNumber,
          totalSteps: totalSteps,
        ),
      ),
    );
  }
}

enum _ZigzagAlign { left, center, right }
