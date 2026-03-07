import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/lesson/lesson_model.dart';
import '../../../data/models/lesson/lesson_progress_model.dart';
import '../../../data/models/lesson/unit_model.dart';
import '../../../data/providers/curriculum/curriculum_provider.dart';
import '../../../data/providers/lesson/lesson_progress_provider.dart';
import '../../../data/providers/user/user_provider.dart';
import '../../../shared/constants/app_colors.dart';
import '../../problems/problem_solving_screen.dart';

class LessonsScreenFigma extends ConsumerStatefulWidget {
  const LessonsScreenFigma({super.key});

  @override
  ConsumerState<LessonsScreenFigma> createState() => _LessonsScreenFigmaState();
}

class _LessonsScreenFigmaState extends ConsumerState<LessonsScreenFigma>
    with SingleTickerProviderStateMixin {
  // Subject selection state
  int _selectedSubjectIndex = 0;
  final List<String> _subjects = [
    '공통수학 1',
    '공통수학 2',
    '수학 I',
    '수학 II',
    '확률과 통계',
    '미적분',
    '기하',
  ];

  // Grade/level selection state
  int _selectedGradeIndex = 0;
  final List<String> _grades = ['중1-1', '중1-2'];

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

    final progressState = ref.read(lessonProgressProvider(user.id));

    if (progressState.progressMap.isEmpty) {
      final firstLessonIds = <String>[];
      for (final unit in units) {
        if (unit.lessons.isNotEmpty) {
          firstLessonIds.add(unit.lessons.first.id);
        }
      }

      if (firstLessonIds.isNotEmpty) {
        ref
            .read(lessonProgressProvider(user.id).notifier)
            .initializeFirstLessons(firstLessonIds);
      }
    }
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  String get _currentSubject {
    const subjectKeys = [
      '공통수학1',
      '공통수학2',
      '수학I',
      '수학II',
      '확률과통계',
      '미적분',
      '기하',
    ];
    return subjectKeys[_selectedSubjectIndex];
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final progressState = user != null
        ? ref.watch(lessonProgressProvider(user.id))
        : const LessonProgressState();
    final curriculumAsync = ref.watch(curriculumProvider);

    final streak = user?.streak ?? 0;
    final xp = user?.xp ?? 0;
    final level = user?.level ?? 1;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          // Blue rounded header
          _buildBlueHeader(),

          // Grade/level selector row
          _buildGradeSelector(),

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
              error: (_, __) => const Expanded(
                child: Center(
                  child: Text(
                    '커리큘럼을 불러오는데 실패했습니다',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              data: (allUnits) {
                final units = allUnits
                    .where((u) => u.subject == _currentSubject)
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
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
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
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBlueHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF61A1D8),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top row: hamburger menu + "Home" title + GoMath logo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.menu, color: Colors.white, size: 24),
                  const Spacer(),
                  const Text(
                    'Home',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(),
                  Image.asset(
                    'assets/icons/gomath_logo_small.png',
                    width: 60,
                    height: 28,
                    errorBuilder: (_, __, ___) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'GoMath',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Subject selector row (scrollable)
            SizedBox(
              height: 44,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: List.generate(_subjects.length, (index) {
                    final isSelected = _selectedSubjectIndex == index;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          if (_selectedSubjectIndex != index) {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedSubjectIndex = index);
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _subjects[index],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? const Color(0xFF61A1D8)
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // === Grade / Level Selector ===
  // ============================================================

  Widget _buildGradeSelector() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Grade cards
            ...List.generate(_grades.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _buildGradeCard(
                  label: _grades[index],
                  index: index,
                  isSelected: _selectedGradeIndex == index,
                ),
              );
            }),
            // Add button
            _buildAddGradeCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeCard({
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        if (_selectedGradeIndex != index) {
          HapticFeedback.selectionClick();
          setState(() => _selectedGradeIndex = index);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 119,
        height: 104,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : AppColors.nodeLockedBg,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
          border: isSelected
              ? Border.all(
                  color: AppColors.skyBlue.withValues(alpha: 0.3),
                  width: 1.5,
                )
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon placeholder area
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.skyBlue.withValues(alpha: 0.12)
                    : const Color(0xFFD1D6D5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.menu_book_rounded,
                size: 24,
                color: isSelected
                    ? AppColors.skyBlue
                    : const Color(0xFF7E8381),
              ),
            ),
            const SizedBox(height: 8),
            // Grade label
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.textPrimary
                    : const Color(0xFF7E8381),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddGradeCard() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('새 학년을 추가하려면 설정에서 추가하세요'),
            backgroundColor: AppColors.skyBlue,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
      child: Container(
        width: 119,
        height: 104,
        decoration: BoxDecoration(
          color: const Color(0xFFEFF3F2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFD9DFDE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 28,
                color: Color(0xFF7E8381),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF7E8381),
              ),
            ),
          ],
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
    String unitName = '소인수분해';
    final units = curriculumAsync.valueOrNull;
    if (units != null) {
      final filteredUnits =
          units.where((u) => u.subject == _currentSubject).toList();
      if (filteredUnits.isNotEmpty) {
        unitName = filteredUnits.first.title;
      }
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
            color: Color(0xFFFF9600),
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
          ),

          const SizedBox(width: 12),

          // XP (graphene icon + number)
          Image.asset(
            'assets/icons/xp_icon.png',
            width: 23,
            height: 23,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.bolt_rounded,
              color: Color(0xFFFFC800),
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
          ),

          const Spacer(),

          // Level (shield icon + text)
          Image.asset(
            'assets/icons/level_icon.png',
            width: 20,
            height: 20,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.shield_rounded,
              color: Color(0xFF61A1D8),
              size: 20,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'HLv$level',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: 1,
            ),
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
    const activeColor = Color(0xFF2B59FF);
    const completedColor = Color(0xFF58CC02);
    const lockedBgColor = Color(0xFFE4F5FF);

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
                  colors: [Color(0xFF2B59FF), Color(0xFF1A3CF7)],
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
                'START!',
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
                      color: const Color(0xFFE4F5FF),
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
                      ? const Color(0xFF61A1D8)
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

    // Record lesson start
    ref
        .read(lessonProgressProvider(user.id).notifier)
        .startLesson(lessonId);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProblemSolvingScreen(
          lessonId: lessonId,
          lessonTitle: lesson!.title,
        ),
      ),
    );
  }
}

enum _ZigzagAlign { left, center, right }
