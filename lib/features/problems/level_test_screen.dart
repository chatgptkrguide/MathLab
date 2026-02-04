import 'package:flutter/material.dart';
import '../../data/models/problem/problem_model.dart';
import '../../data/models/problem/problem_session_model.dart';
import '../../data/models/problem/sample_problems.dart';
import '../../shared/constants/figma_colors.dart';
import '../../shared/widgets/math/math_renderer.dart';
import '../../shared/utils/answer_validator.dart';

/// 레벨 테스트 화면 (피그마 08 프레임)
/// 문제 풀이 화면과 유사하지만 헤더가 "레벨테스트"이고
/// 결과에 따라 랭크가 결정됨
class LevelTestScreen extends StatefulWidget {
  const LevelTestScreen({super.key});

  @override
  State<LevelTestScreen> createState() => _LevelTestScreenState();
}

class _LevelTestScreenState extends State<LevelTestScreen> {
  late ProblemSessionModel session;
  String? selectedAnswer;
  bool isAnswerChecked = false;
  bool isCorrect = false;
  bool isComplete = false;

  @override
  void initState() {
    super.initState();
    final problems = SampleProblems.getProblemsForLesson('lesson_1_1');
    session = ProblemSessionModel(
      sessionId: 'level_test_${DateTime.now().millisecondsSinceEpoch}',
      lessonId: 'level_test',
      userId: 'demo_user',
      problems: problems,
      startedAt: DateTime.now(),
    );
  }

  ProblemModel? get currentProblem => session.currentProblem;

  @override
  Widget build(BuildContext context) {
    if (isComplete) {
      return _buildResultScreen();
    }

    return Scaffold(
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildProgressBar(),
              Expanded(child: _buildQuestionArea()),
              _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        gradient: FigmaColors.skyBlueGradient,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showExitDialog(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              '레벨테스트',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // 하트
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.favorite_rounded, color: Colors.red, size: 18),
                const SizedBox(width: 4),
                Text(
                  '${session.hearts}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = session.progress;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${session.currentProblemIndex + 1} / ${session.totalProblems}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: FigmaColors.textSecondary,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: FigmaColors.skyBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: const Color(0xFFE4E9EA),
              valueColor: const AlwaysStoppedAnimation<Color>(FigmaColors.skyBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionArea() {
    final problem = currentProblem;
    if (problem == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 문제 카드
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '문제 ${session.currentProblemIndex + 1}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: FigmaColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                MathRenderer(
                  latex: problem.question,
                  fontSize: 20,
                  color: FigmaColors.textDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 선택지 (chip 스타일)
          if (problem.type == ProblemType.multipleChoice &&
              problem.options != null)
            ...problem.options!.map((option) {
              final isSelected = selectedAnswer == option;
              Color bgColor = FigmaColors.chipBg;
              Color textColor = FigmaColors.textDark;
              Color borderColor = Colors.transparent;

              if (isAnswerChecked && isSelected) {
                if (isCorrect) {
                  bgColor = const Color(0xFF58CC02).withOpacity(0.15);
                  textColor = const Color(0xFF58CC02);
                  borderColor = const Color(0xFF58CC02);
                } else {
                  bgColor = Colors.red.withOpacity(0.1);
                  textColor = Colors.red;
                  borderColor = Colors.red;
                }
              } else if (isSelected) {
                bgColor = FigmaColors.skyBlue.withOpacity(0.12);
                textColor = FigmaColors.skyBlue;
                borderColor = FigmaColors.skyBlue;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: isAnswerChecked
                      ? null
                      : () => setState(() => selectedAnswer = option),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: borderColor,
                        width: isSelected ? 2 : 0,
                      ),
                    ),
                    child: MathRenderer(
                      latex: option,
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    if (isAnswerChecked) {
      return _buildFeedbackBar();
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: selectedAnswer != null
                ? FigmaColors.deepBlueCTA
                : null,
            color: selectedAnswer != null ? null : const Color(0xFFE4E9EA),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ElevatedButton(
            onPressed: selectedAnswer != null ? _checkAnswer : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              '정답 확인',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: selectedAnswer != null ? Colors.white : FigmaColors.textLight,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: isCorrect
            ? const Color(0xFF58CC02).withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: isCorrect ? const Color(0xFF58CC02) : Colors.red,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isCorrect ? '정답입니다!' : '틀렸습니다',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isCorrect ? const Color(0xFF58CC02) : Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _nextProblem,
              style: ElevatedButton.styleFrom(
                backgroundColor: isCorrect ? const Color(0xFF58CC02) : Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                '계속하기',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    final correctCount = session.correctCount;
    final total = session.totalProblems;
    final percentage = total > 0 ? (correctCount / total * 100).toInt() : 0;

    String rankResult;
    Color rankColor;
    if (percentage >= 90) {
      rankResult = 'GT Lv1';
      rankColor = const Color(0xFF9C27B0);
    } else if (percentage >= 70) {
      rankResult = 'H Lv1';
      rankColor = const Color(0xFF2196F3);
    } else {
      rankResult = 'A Lv1';
      rankColor = const Color(0xFF4CAF50);
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: FigmaColors.skyBlueGradient,
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emoji_events_rounded, size: 80, color: Colors.white),
                const SizedBox(height: 24),
                const Text(
                  '레벨테스트 완료!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '$correctCount / $total 정답 ($percentage%)',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '당신의 랭크',
                        style: TextStyle(
                          fontSize: 14,
                          color: FigmaColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        rankResult,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: rankColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: FigmaColors.skyBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        '홈으로 돌아가기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _checkAnswer() {
    final problem = currentProblem;
    if (problem == null || selectedAnswer == null) return;

    final result = AnswerValidator.validateMultipleChoice(
      selectedAnswer!,
      problem.correctAnswer,
    );

    setState(() {
      isAnswerChecked = true;
      isCorrect = result.isCorrect;

      final updatedAnswers = Map<String, String>.from(session.userAnswers);
      updatedAnswers[problem.id] = selectedAnswer!;

      final updatedCorrectness = Map<String, bool>.from(session.correctness);
      updatedCorrectness[problem.id] = result.isCorrect;

      session = session.copyWith(
        userAnswers: updatedAnswers,
        correctness: updatedCorrectness,
        hearts: result.isCorrect ? session.hearts : session.hearts - 1,
        score: session.score + (result.isCorrect ? problem.points : 0),
      );
    });
  }

  void _nextProblem() {
    if (session.hearts <= 0 ||
        session.currentProblemIndex + 1 >= session.totalProblems) {
      setState(() {
        isComplete = true;
      });
      return;
    }

    setState(() {
      session = session.copyWith(
        currentProblemIndex: session.currentProblemIndex + 1,
      );
      selectedAnswer = null;
      isAnswerChecked = false;
      isCorrect = false;
    });
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('레벨테스트 종료'),
        content: const Text('테스트를 종료하시겠습니까?\n진행 상황이 저장되지 않습니다.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('계속하기'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('종료', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
