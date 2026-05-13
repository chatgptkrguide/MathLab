import 'package:flutter/material.dart';
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
import '../problems/problem_solving_screen.dart';
import 'widgets/lessons_blue_header.dart';
import 'widgets/lessons_path.dart';
import 'widgets/lessons_stats_bar.dart';

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

    final streak = user?.streak ?? 0;
    final xp = user?.xp ?? 0;
    final level = user?.level ?? 1;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          // Blue rounded header with dropdown
          LessonsBlueHeader(
            curriculumAsync: curriculumAsync,
            selectedSubject: _selectedSubject,
            getFilteredSubjects: _getFilteredSubjects,
            onSubjectChanged: (v) {
              setState(() => _selectedSubject = v);
            },
          ),

          // Stats bar
          LessonsStatsBar(
            streak: streak,
            xp: xp,
            level: level,
            curriculumAsync: curriculumAsync,
            selectedSubject: _selectedSubject,
          ),

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
                final isTimeout = msg.contains('timeout') ||
                    msg.contains('deadline');
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
                            onPressed: () =>
                                ref.invalidate(curriculumProvider),
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('다시 시도'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.skyBlue,
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
                final units = _selectedSubject == null
                    ? allUnits
                    : allUnits
                        .where((u) => u.subject == _selectedSubject)
                        .toList();

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
                          child: LessonsPath(
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
      final sameSubjectUnits = units
          .where((u) => u.subject == parentUnit!.subject)
          .toList();
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
    ref
        .read(lessonProgressProvider(user.uid).notifier)
        .startLesson(lessonId);

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
