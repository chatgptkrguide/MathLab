import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/app_logger.dart';
import '../../data/models/lesson/lesson_model.dart';
import '../../data/models/lesson/lesson_progress_model.dart';
import '../../data/models/lesson/unit_model.dart';
import '../../data/providers/curriculum/curriculum_provider.dart';
import '../../data/providers/lesson/lesson_progress_provider.dart';
import '../../data/providers/problem/problem_provider.dart';
import '../../data/providers/user/user_provider.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/grade_groups.dart';
import '../../shared/constants/subject_labels.dart';
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

  // 과목 표시 이름 변환은 SubjectLabels.displayOf 로 직접 호출.

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

  /// 학년 필터 해제 — 모든 과목 코드를 그대로 반환.
  /// (LessonsBlueHeader 의 callback signature 호환을 위해 메서드 유지)
  List<String> _getFilteredSubjects(List<UnitModel> units) {
    final subjects = <String>{};
    for (final u in units) {
      subjects.add(u.subject);
    }
    return subjects.toList();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final progressState = user != null
        ? ref.watch(lessonProgressProvider(user.uid))
        : const LessonProgressState();
    final curriculumAsync = ref.watch(curriculumProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFB51B),
      body: Column(
        children: [
          _LessonsOrangeHeader(
            curriculumAsync: curriculumAsync,
            selectedSubject: _selectedSubject,
            getFilteredSubjects: _getFilteredSubjects,
            onSubjectChanged: (v) {
              setState(() => _selectedSubject = v);
            },
          ),

          // Main content: lesson path
          if (progressState.isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            )
          else
            curriculumAsync.when(
              loading: () => const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
              error: (error, stack) {
                AppLogger.error(
                  'Curriculum load failed',
                  tag: 'Lessons',
                  error: error,
                  stackTrace: stack,
                );
                final msg = error.toString().toLowerCase();
                final isOffline = msg.contains('socket') ||
                    msg.contains('network') ||
                    msg.contains('unreachable') ||
                    msg.contains('failed host lookup');
                final isTimeout =
                    msg.contains('timeout') || msg.contains('deadline');
                final title = isOffline
                    ? '인터넷 연결을 확인해 주세요'
                    : isTimeout
                        ? '응답 시간이 초과되었어요'
                        : '커리큘럼을 불러오지 못했어요';
                final hint = isOffline
                    ? 'Wi-Fi 또는 모바일 데이터 상태를 확인하고\n다시 시도해 주세요.'
                    : '잠시 후 다시 시도해 주세요.';
                final icon = isOffline
                    ? Icons.wifi_off_rounded
                    : isTimeout
                        ? Icons.access_time_rounded
                        : Icons.error_outline_rounded;
                return Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            icon,
                            size: 48,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            hint,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => ref.invalidate(curriculumProvider),
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('다시 시도'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF8A00),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              data: (allUnits) {
                final selected = _selectedSubject;
                final units = selected == null
                    ? allUnits
                    : GradeGroups.isGradeSentinel(selected)
                        ? () {
                            final grade =
                                GradeGroups.gradeFromSentinel(selected)!;
                            final allowed = GradeGroups.subjectsOf(grade);
                            return allUnits
                                .where((u) => allowed.contains(u.subject))
                                .toList();
                          }()
                        : allUnits.where((u) => u.subject == selected).toList();

                // Flatten all lessons from all units for the path
                final allLessons = <LessonModel>[];
                for (final unit in units) {
                  for (final lesson in unit.lessons) {
                    allLessons.add(lesson);
                  }
                }

                return Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(curriculumProvider);
                    },
                    color: const Color(0xFFFF8A00),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.fromLTRB(0, 40, 0, 96),
                      child: SlideTransition(
                        position: _bannerSlideAnimation,
                        child: FadeTransition(
                          opacity: _bannerFadeAnimation,
                          child: _LessonBoard(
                            key: LessonsScreenFigma.lessonPathKey,
                            lessons: allLessons,
                            progressState: progressState,
                            allUnits: allUnits,
                            onLessonTap: _handleLessonTap,
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

    // 유닛 잠금 확인: 같은 과목 내에서 이전 유닛 완료 여부
    UnitModel? parentUnit;
    for (final unit in units) {
      if (unit.lessons.any((l) => l.id == lessonId)) {
        parentUnit = unit;
        break;
      }
    }

    bool unitUnlocked = true;
    if (parentUnit != null) {
      // 같은 과목의 유닛들만 필터링하여 순서 확인
      final sameSubjectUnits =
          units.where((u) => u.subject == parentUnit!.subject).toList();
      final unitIndex = sameSubjectUnits.indexOf(parentUnit);
      if (unitIndex > 0) {
        final prevUnit = sameSubjectUnits[unitIndex - 1];
        unitUnlocked = prevUnit.lessons.every((l) =>
            progressState.progressMap[l.id]?.status == LessonStatus.completed);
      }
    }

    // Check if accessible
    bool isAccessible = false;

    if (!unitUnlocked) {
      isAccessible = false;
    } else if (lessonIndex == 0) {
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
          content: Text(
            unitUnlocked ? '이전 레슨을 먼저 완료해주세요!' : '이전 단원을 먼저 완료해주세요!',
          ),
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
    ref.read(lessonProgressProvider(user.uid).notifier).startLesson(lessonId);

    // Preload: 화면 진입 전에 문제 fetch를 시작해 푸시 애니메이션 동안 캐시를 채운다.
    ref.read(problemsForLessonProvider(lessonId));

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

class _LessonsOrangeHeader extends StatelessWidget {
  final AsyncValue<List<UnitModel>> curriculumAsync;
  final String? selectedSubject;
  final List<String> Function(List<UnitModel> units) getFilteredSubjects;
  final ValueChanged<String?> onSubjectChanged;

  const _LessonsOrangeHeader({
    required this.curriculumAsync,
    required this.selectedSubject,
    required this.getFilteredSubjects,
    required this.onSubjectChanged,
  });

  @override
  Widget build(BuildContext context) {
    final allUnits = curriculumAsync.valueOrNull ?? [];
    final available = getFilteredSubjects(allUnits).toSet();

    return AspectRatio(
      aspectRatio: 692 / 260,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/lessons/lesson_reference_header.png',
                fit: BoxFit.fill,
                filterQuality: FilterQuality.high,
              ),
              Positioned(
                left: size.width * 0.068,
                top: size.height * 0.554,
                width: size.width * 0.487,
                height: size.height * 0.262,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: selectedSubject,
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(20),
                    dropdownColor: Colors.white,
                    icon: const SizedBox.shrink(),
                    selectedItemBuilder: (context) =>
                        _buildInvisibleLabels(available),
                    items: _buildGroupedItems(available),
                    onChanged: (v) {
                      HapticFeedback.selectionClick();
                      onSubjectChanged(v);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<DropdownMenuItem<String?>> _buildGroupedItems(Set<String> available) {
    final items = <DropdownMenuItem<String?>>[
      const DropdownMenuItem<String?>(
        value: null,
        child: Text('전체과목'),
      ),
    ];

    for (final entry in GradeGroups.map.entries) {
      final visibleSubjects = entry.value.where(available.contains).toList();
      if (visibleSubjects.isEmpty) continue;

      items.add(
        DropdownMenuItem<String?>(
          value: GradeGroups.sentinelFor(entry.key),
          child: Text('${entry.key} 전체'),
        ),
      );

      for (final code in visibleSubjects) {
        items.add(
          DropdownMenuItem<String?>(
            value: code,
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(SubjectLabels.displayOf(code)),
            ),
          ),
        );
      }
    }

    return items;
  }

  List<Widget> _buildInvisibleLabels(Set<String> available) {
    final labels = <Widget>[
      const SizedBox.expand(),
    ];
    for (final entry in GradeGroups.map.entries) {
      final visibleSubjects = entry.value.where(available.contains).toList();
      if (visibleSubjects.isEmpty) continue;
      labels.add(const SizedBox.expand());
      for (final _ in visibleSubjects) {
        labels.add(const SizedBox.expand());
      }
    }
    return labels;
  }
}

class _LessonBoard extends StatelessWidget {
  final List<LessonModel> lessons;
  final LessonProgressState progressState;
  final List<UnitModel> allUnits;
  final void Function(
    String lessonId,
    List<UnitModel> units,
    LessonProgressState progressState,
  ) onLessonTap;

  const _LessonBoard({
    super.key,
    required this.lessons,
    required this.progressState,
    required this.allUnits,
    required this.onLessonTap,
  });

  @override
  Widget build(BuildContext context) {
    if (lessons.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 80),
        child: Center(
          child: Text(
            '이 과목에는 아직 레슨이 없습니다',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
    }

    final cards = _buildCards();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 616),
        child: AspectRatio(
          aspectRatio: 616 / 907,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final boardSize = Size(
                constraints.maxWidth,
                constraints.maxHeight,
              );
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/lessons/lesson_reference_roadmap.png',
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.high,
                  ),
                  _LessonTapTarget(
                    card: cards[0],
                    rect: _LessonBoardRects.add,
                    boardSize: boardSize,
                  ),
                  _LessonTapTarget(
                    card: cards[1],
                    rect: _LessonBoardRects.subtract,
                    boardSize: boardSize,
                  ),
                  _LessonTapTarget(
                    card: cards[2],
                    rect: _LessonBoardRects.divide,
                    boardSize: boardSize,
                  ),
                  _LessonTapTarget(
                    card: cards[3],
                    rect: _LessonBoardRects.multiply,
                    boardSize: boardSize,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  List<_LessonCardData> _buildCards() {
    return List.generate(4, (index) {
      final lesson = index < lessons.length ? lessons[index] : null;
      return _LessonCardData(
        lesson: lesson,
        onTap: lesson == null
            ? null
            : () => onLessonTap(lesson.id, allUnits, progressState),
      );
    });
  }
}

class _LessonTapTarget extends StatelessWidget {
  final _LessonCardData card;
  final Rect rect;
  final Size boardSize;

  const _LessonTapTarget({
    required this.card,
    required this.rect,
    required this.boardSize,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: rect.left * boardSize.width,
      top: rect.top * boardSize.height,
      width: rect.width * boardSize.width,
      height: rect.height * boardSize.height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: card.onTap,
          borderRadius: BorderRadius.circular(22),
        ),
      ),
    );
  }
}

class _LessonCardData {
  final LessonModel? lesson;
  final VoidCallback? onTap;

  const _LessonCardData({
    required this.lesson,
    required this.onTap,
  });
}

class _LessonBoardRects {
  static const add = Rect.fromLTWH(0.157, 0.214, 0.312, 0.212);
  static const subtract = Rect.fromLTWH(0.527, 0.214, 0.312, 0.212);
  static const divide = Rect.fromLTWH(0.157, 0.465, 0.312, 0.212);
  static const multiply = Rect.fromLTWH(0.527, 0.465, 0.312, 0.212);
}
