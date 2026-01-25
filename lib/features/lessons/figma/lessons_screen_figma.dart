/// 📚 Lessons Screen (Figma Design)
///
/// Main learning screen with curriculum tree structure (Duolingo-style).

import 'package:flutter/material.dart';
import '../../../data/models/lesson/curriculum_data.dart';
import '../../../data/models/lesson/lesson_model.dart';
import '../../../data/models/lesson/lesson_progress_model.dart';
import '../../../shared/constants/app_colors.dart';
import '../widgets/unit_card.dart';
import '../../problems/problem_solving_screen.dart';

class LessonsScreenFigma extends StatefulWidget {
  const LessonsScreenFigma({super.key});

  @override
  State<LessonsScreenFigma> createState() => _LessonsScreenFigmaState();
}

class _LessonsScreenFigmaState extends State<LessonsScreenFigma> {
  // Sample curriculum data
  final units = CurriculumData.getSampleUnits();

  // Sample progress data (for demonstration)
  late Map<String, LessonProgressModel> progressMap;

  @override
  void initState() {
    super.initState();
    _initializeProgress();
  }

  void _initializeProgress() {
    // Initialize with sample progress data
    progressMap = {
      // Unit 1 - Some progress
      'lesson_1_1': LessonProgressModel(
        lessonId: 'lesson_1_1',
        userId: 'demo_user',
        status: LessonStatus.completed,
        stars: 3,
        correctAnswers: 10,
        totalQuestions: 10,
        xpEarned: 10,
        completedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      'lesson_1_2': LessonProgressModel(
        lessonId: 'lesson_1_2',
        userId: 'demo_user',
        status: LessonStatus.completed,
        stars: 2,
        correctAnswers: 8,
        totalQuestions: 10,
        xpEarned: 10,
        completedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      'lesson_1_3': LessonProgressModel(
        lessonId: 'lesson_1_3',
        userId: 'demo_user',
        status: LessonStatus.unlocked,
      ),

      // Other lessons remain locked
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.mathBlue,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                '학습',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.mathBlue,
                      Color(0xFF1899D6),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Header section
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.mathBlue, AppColors.mathButtonBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.mathBlue.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.school,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '당신의 수학 여정',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${units.length}개 유닛 · ${units.fold(0, (sum, unit) => sum + unit.lessonCount)}개 레슨',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.local_fire_department,
                          color: AppColors.mathOrange,
                          size: 18,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '3',
                          style: TextStyle(
                            color: AppColors.mathOrange,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Units list
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final unit = units[index];
                return UnitCard(
                  unit: unit,
                  progressMap: progressMap,
                  onLessonTap: (lessonId) => _handleLessonTap(lessonId),
                );
              },
              childCount: units.length,
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }

  void _handleLessonTap(String lessonId) {
    // Check if lesson is unlocked
    final progress = progressMap[lessonId];
    if (progress == null || progress.status == LessonStatus.locked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('이전 레슨을 먼저 완료해주세요!'),
          backgroundColor: AppColors.mathRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    // Find lesson to get title
    LessonModel? lesson;
    for (final unit in units) {
      for (final l in unit.lessons) {
        if (l.id == lessonId) {
          lesson = l;
          break;
        }
      }
      if (lesson != null) break;
    }

    if (lesson == null) return;

    // Navigate to problem solving screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProblemSolvingScreen(
          lessonId: lessonId,
          lessonTitle: lesson!.title,
        ),
      ),
    ).then((_) {
      // Refresh progress when returning
      setState(() {
        // TODO: Reload progress from database
      });
    });
  }
}
