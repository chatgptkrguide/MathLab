import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/lesson/lesson_model.dart';
import '../../../data/models/lesson/lesson_progress_model.dart';
import '../../../data/models/lesson/unit_model.dart';
import '../../../data/providers/curriculum/curriculum_provider.dart';
import '../../../data/providers/lesson/lesson_progress_provider.dart';
import '../../../data/providers/user/user_provider.dart';
import '../../../shared/constants/figma_colors.dart';
import '../widgets/lesson_path_widget.dart';
import '../../problems/problem_solving_screen.dart';

class LessonsScreenFigma extends ConsumerStatefulWidget {
  const LessonsScreenFigma({super.key});

  @override
  ConsumerState<LessonsScreenFigma> createState() => _LessonsScreenFigmaState();
}

class _LessonsScreenFigmaState extends ConsumerState<LessonsScreenFigma>
    with SingleTickerProviderStateMixin {
  // 과목 선택 상태
  int _selectedSubjectIndex = 0;
  final List<String> _subjects = ['공통수학 1', '공통수학 2'];

  // 배너 슬라이드업 애니메이션
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

    // 살짝 딜레이 후 배너 등장
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _bannerController.forward();
    });

    // 첫 번째 레슨들 초기화 (신규 사용자용) - 커리큘럼 로드 후 실행
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

    // 진행 기록이 없으면 첫 레슨들 언락
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

  String get _currentSubject =>
      _selectedSubjectIndex == 0 ? '공통수학1' : '공통수학2';

  LinearGradient get _currentGradient {
    return _selectedSubjectIndex == 0
        ? FigmaColors.skyBlueGradient
        : FigmaColors.tealGradient;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final progressState = user != null
        ? ref.watch(lessonProgressProvider(user.id))
        : const LessonProgressState();
    final curriculumAsync = ref.watch(curriculumProvider);

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: _currentGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 헤더: 과목 선택기 + 스트릭/XP/레벨
              _buildHeader(user),

              // 로딩 상태
              if (progressState.isLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                )
              else
                curriculumAsync.when(
                  loading: () => const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                  error: (_, __) => const Expanded(
                    child: Center(
                      child: Text(
                        '커리큘럼을 불러오는데 실패했습니다',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  data: (allUnits) {
                    final units = allUnits
                        .where((u) => u.subject == _currentSubject)
                        .toList();
                    return Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 40),
                        child: Column(
                          children: [
                            for (int i = 0; i < units.length; i++) ...[
                              SlideTransition(
                                position: _bannerSlideAnimation,
                                child: FadeTransition(
                                  opacity: _bannerFadeAnimation,
                                  child: _buildUnitBanner(
                                    units[i].emoji,
                                    units[i].title,
                                    units[i].description,
                                  ),
                                ),
                              ),
                              LessonPathWidget(
                                lessons: units[i].lessons,
                                progressMap: progressState.progressMap,
                                onLessonTap: (lessonId) =>
                                    _handleLessonTap(lessonId, allUnits, progressState),
                              ),
                              if (i < units.length - 1) const SizedBox(height: 16),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(user) {
    final streak = user?.streak ?? 0;
    final xp = user?.xp ?? 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        children: [
          // 상단: 과목 선택 탭 + 정보 배지
          Row(
            children: [
              // 과목 선택 탭
              Expanded(
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
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            style: TextStyle(
                              color: isSelected
                                  ? (_selectedSubjectIndex == 0
                                      ? FigmaColors.skyBlue
                                      : FigmaColors.tealGreen)
                                  : Colors.white,
                              fontSize: 13,
                              fontWeight:
                                  isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                            child: Text(_subjects[index]),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // 스트릭 (실제 데이터)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_fire_department_rounded,
                        color: Color(0xFFFF9600), size: 18),
                    const SizedBox(width: 4),
                    Text('$streak',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // XP (실제 데이터)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded,
                        color: Color(0xFFFFC800), size: 18),
                    const SizedBox(width: 4),
                    Text('$xp',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUnitBanner(String emoji, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: FigmaColors.glassBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: FigmaColors.glassBorder),
            ),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleLessonTap(String lessonId, List<UnitModel> units, LessonProgressState progressState) {
    final user = ref.read(userProvider);
    if (user == null) return;

    final progress = progressState.progressMap[lessonId];

    // 레슨 모델 찾기 및 인덱스 확인
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

    // 첫 번째 레슨인지 또는 이전 레슨이 완료되었는지 확인
    bool isAccessible = false;

    if (lessonIndex == 0) {
      // 첫 번째 레슨은 항상 접근 가능
      isAccessible = true;
    } else if (progress != null && progress.status != LessonStatus.locked) {
      // 이미 잠금 해제된 경우
      isAccessible = true;
    } else if (parentLessons != null && lessonIndex > 0) {
      // 이전 레슨이 완료되었는지 확인
      final prevLessonId = parentLessons[lessonIndex - 1].id;
      final prevProgress = progressState.progressMap[prevLessonId];
      if (prevProgress?.status == LessonStatus.completed) {
        isAccessible = true;
      }
    }

    // 잠긴 레슨인 경우
    if (!isAccessible) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('이전 레슨을 먼저 완료해주세요!'),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    // 레슨 시작 기록
    ref.read(lessonProgressProvider(user.id).notifier).startLesson(lessonId);

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
