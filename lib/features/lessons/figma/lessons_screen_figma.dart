/// 📚 Lessons Screen (Figma Design - Duolingo Style)
///
/// 듀오링고 스타일 S자 곡선 학습 경로 화면.
/// 스카이블루 배경 + 헤더 + 휘어지는 경로 맵.

import 'package:flutter/material.dart';
import '../../../data/models/lesson/curriculum_data.dart';
import '../../../data/models/lesson/lesson_model.dart';
import '../../../data/models/lesson/lesson_progress_model.dart';
import '../../../shared/constants/figma_colors.dart';
import '../widgets/lesson_path_widget.dart';
import '../../problems/problem_solving_screen.dart';

class LessonsScreenFigma extends StatefulWidget {
  const LessonsScreenFigma({super.key});

  @override
  State<LessonsScreenFigma> createState() => _LessonsScreenFigmaState();
}

class _LessonsScreenFigmaState extends State<LessonsScreenFigma> {
  final units = CurriculumData.getSampleUnits();
  late Map<String, LessonProgressModel> progressMap;

  @override
  void initState() {
    super.initState();
    _initializeProgress();
  }

  void _initializeProgress() {
    progressMap = {
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
    };
  }

  @override
  Widget build(BuildContext context) {
    // 모든 유닛의 레슨을 하나의 리스트로 합침
    final allLessons = <LessonModel>[];
    for (final unit in units) {
      allLessons.addAll(unit.lessons);
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: FigmaColors.skyBlueGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 헤더 영역
              _buildHeader(),

              // 스크롤 가능한 학습 경로
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Column(
                    children: [
                      // 유닛별로 학습 경로 표시
                      for (int i = 0; i < units.length; i++) ...[
                        // 유닛 제목 배너
                        _buildUnitBanner(units[i].emoji, units[i].title, units[i].description),

                        // 해당 유닛의 학습 경로
                        LessonPathWidget(
                          lessons: units[i].lessons,
                          progressMap: progressMap,
                          onLessonTap: _handleLessonTap,
                        ),

                        if (i < units.length - 1)
                          const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        children: [
          // 뒤로가기
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
            ),
          ),

          const SizedBox(width: 12),

          // 과목명
          const Expanded(
            child: Text(
              '수학 기초',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // 스트릭
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.local_fire_department_rounded, color: Color(0xFFFF9600), size: 18),
                SizedBox(width: 4),
                Text('3', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // XP
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star_rounded, color: Color(0xFFFFC800), size: 18),
                SizedBox(width: 4),
                Text('120', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitBanner(String emoji, String title, String description) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
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
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleLessonTap(String lessonId) {
    final progress = progressMap[lessonId];
    if (progress == null || progress.status == LessonStatus.locked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('이전 레슨을 먼저 완료해주세요!'),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

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

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProblemSolvingScreen(
          lessonId: lessonId,
          lessonTitle: lesson!.title,
        ),
      ),
    ).then((_) {
      setState(() {});
    });
  }
}
