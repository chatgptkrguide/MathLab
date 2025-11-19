import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/constants/figma_colors.dart';
import '../../../shared/figma_components/figma_top_bar.dart';
import '../../../shared/figma_components/figma_user_info_bar.dart';
import '../../../data/providers/user_provider.dart';
import '../../../data/models/problem.dart';
import '../../practice/practice_screen.dart';
import '../../level_test/level_test_screen.dart';
// import '../../problem/problem_screen.dart'; // TODO: 문제 화면 구현 필요

/// Figma 디자인 "01" 학습 페이지 100% 재현
/// 레퍼런스: assets/images/figma_01_lessons_reference.png
class LessonsScreenFigma extends ConsumerWidget {
  const LessonsScreenFigma({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFF5F5F5), // 밝은 회색 배경
      child: Column(
        children: [
          // 상단 바 (Home 제목)
          FigmaTopBar(
            title: 'Home',
            showBackButton: false,
          ),

          // 사용자 정보 바 (소인수분해, 스트릭, XP, 레벨)
          FigmaUserInfoBar(
            userName: '소인수분해',
            streakDays: user?.streakDays ?? 6,
            xp: user?.xp ?? 549,
            level: 'HLv${user?.level ?? 1}',
          ),

          // Quick Action Buttons (Practice & Level Test)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PracticeCategoryScreen(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4CAF50).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              '연습 모드',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LevelTestScreen(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF9800).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.assignment, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              '레벨 테스트',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 레슨 카드 그리드
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // 1행: START! 카드 + 노트/연필 카드
                  Row(
                    children: [
                      Expanded(
                        child: _buildLessonCard(context, 
                          image: 'assets/images/book_pencil.png',
                          label: 'START!',
                          isLocked: false,
                          height: 180,
                          lessonId: 'lesson001',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildLessonCard(context, 
                          image: 'assets/images/book.png',
                          label: '',
                          isLocked: false,
                          height: 180,
                          lessonId: 'lesson001',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 2행: 자 + 빈 카드
                  Row(
                    children: [
                      Expanded(
                        child: _buildLessonCard(context, 
                          image: 'assets/images/rulers.png',
                          label: '',
                          isLocked: false,
                          height: 140,
                          lessonId: 'lesson001',
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: SizedBox(height: 140),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 3행: 가방 카드 (센터)
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: _buildLessonCard(context, 
                        image: 'assets/images/bag.png',
                        label: '',
                        isLocked: true,
                        height: 140,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 4행: 시계 + 트로피 + 노트북
                  Row(
                    children: [
                      Expanded(
                        child: _buildLessonCard(context, 
                          image: 'assets/images/clock.png',
                          label: '',
                          isLocked: true,
                          height: 140,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildLessonCard(context, 
                          image: 'assets/images/winner.png',
                          label: '',
                          isLocked: true,
                          height: 140,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildLessonCard(context, 
                          image: 'assets/images/laptop.png',
                          label: '',
                          isLocked: true,
                          height: 140,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 5행: 지구본 (센터)
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: _buildLessonCard(context, 
                        image: 'assets/images/globe.png',
                        label: '',
                        isLocked: true,
                        height: 140,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 6행: 칠판 + 현미경
                  Row(
                    children: [
                      Expanded(
                        child: _buildLessonCard(context, 
                          image: 'assets/images/blackboard.png',
                          label: '',
                          isLocked: true,
                          height: 140,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildLessonCard(context, 
                          image: 'assets/images/microscope.png',
                          label: '',
                          isLocked: true,
                          height: 140,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 100), // 네비게이션 바 공간
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 레슨 카드
  Widget _buildLessonCard(
    BuildContext context, {
    required String image,
    required String label,
    required bool isLocked,
    required double height,
    String? lessonId,
  }) {
    return GestureDetector(
      onTap: !isLocked && lessonId != null ? () => _navigateToProblems(context, lessonId) : null,
      child: Container(
      height: height,
      decoration: BoxDecoration(
        color: isLocked
            ? const Color(0xFFD8E7F3) // 잠긴 카드는 밝은 파란색
            : const Color(0xFF4A90E2), // 활성 카드는 진한 파란색
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 이미지
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Image.asset(
                image,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.book,
                    size: 60,
                    color: isLocked
                        ? Colors.grey.shade400
                        : Colors.white.withOpacity(0.7),
                  );
                },
              ),
            ),
          ),

          // 라벨
          if (label.isNotEmpty)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

          // 잠금 오버레이
          if (isLocked)
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Icon(
                  Icons.lock,
                  size: 36,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    ),
    );
  }

  /// 문제 풀이 화면으로 네비게이션 (임시 비활성화)
  Future<void> _navigateToProblems(BuildContext context, String lessonId) async {
    // TODO: 문제 화면 구현 필요
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('문제 화면을 준비 중입니다')),
      );
    }
    /*
    try {
      // JSON 파일에서 문제 데이터 로드
      final String response = await rootBundle.loadString('assets/data/problems.json');
      final Map<String, dynamic> data = json.decode(response);
      final List<dynamic> problemsJson = data['problems'];

      // lessonId에 해당하는 문제만 필터링
      final List<Problem> lessonProblems = problemsJson
          .where((p) => p['lessonId'] == lessonId)
          .map((p) => Problem.fromJson(p))
          .toList();

      if (lessonProblems.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('아직 준비된 문제가 없습니다.')),
          );
        }
        return;
      }

      // 문제 풀이 화면으로 이동
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProblemScreen(
              lessonId: lessonId,
              problems: lessonProblems,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('문제를 불러오는 중 오류가 발생했습니다: $e')),
        );
      }
    }
    */
  }
}
