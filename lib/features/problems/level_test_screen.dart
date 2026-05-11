import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/problem/problem_session_model.dart';
import '../../data/models/problem/sample_problems.dart';
import '../../data/providers/user/user_provider.dart';
import '../../shared/constants/app_dimensions.dart';
import '../../shared/widgets/effects/noise_texture.dart';
import '../../shared/utils/answer_validator.dart';
import 'widgets/level_test_bottom_section.dart';
import 'widgets/level_test_header.dart';
import 'widgets/level_test_progress_bar.dart';
import 'widgets/level_test_question_area.dart';
import 'widgets/level_test_result_view.dart';

/// 레벨 테스트 화면 (피그마 08 프레임)
/// 문제 풀이 화면과 유사하지만 헤더가 "레벨테스트"이고
/// 결과에 따라 랭크가 결정됨
class LevelTestScreen extends ConsumerStatefulWidget {
  const LevelTestScreen({super.key});

  @override
  ConsumerState<LevelTestScreen> createState() => _LevelTestScreenState();
}

class _LevelTestScreenState extends ConsumerState<LevelTestScreen> {
  late ProblemSessionModel session;
  String? selectedAnswer;
  bool isAnswerChecked = false;
  bool isCorrect = false;
  bool isComplete = false;

  @override
  void initState() {
    super.initState();
    final problems = SampleProblems.getProblemsForLesson('lesson_1_1');
    final user = ref.read(userProvider);
    session = ProblemSessionModel(
      sessionId: 'level_test_${DateTime.now().millisecondsSinceEpoch}',
      lessonId: 'level_test',
      userId: user?.uid ?? 'anonymous',
      problems: problems,
      startedAt: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isComplete) {
      return LevelTestResultView(
        correctCount: session.correctCount,
        total: session.totalProblems,
        onClose: () => Navigator.of(context).pop(),
      );
    }

    final problem = session.currentProblem;

    return Scaffold(
      body: Stack(
        children: [
          // Anti-AI: subtle background gradient instead of pure white
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF8F9FA), Colors.white],
              ),
            ),
          ),
          // Anti-AI: noise texture overlay
          const NoiseTexture(opacity: 0.02),
          SafeArea(
            child: Column(
              children: [
                LevelTestHeader(
                  hearts: session.hearts,
                  onClose: _showExitDialog,
                ),
                LevelTestProgressBar(
                  currentIndex: session.currentProblemIndex,
                  total: session.totalProblems,
                  progress: session.progress,
                ),
                Expanded(
                  child: problem == null
                      ? const SizedBox.shrink()
                      : LevelTestQuestionArea(
                          problem: problem,
                          problemIndex: session.currentProblemIndex,
                          selectedAnswer: selectedAnswer,
                          isAnswerChecked: isAnswerChecked,
                          isCorrect: isCorrect,
                          onSelectAnswer: (option) =>
                              setState(() => selectedAnswer = option),
                        ),
                ),
                LevelTestBottomSection(
                  isAnswerChecked: isAnswerChecked,
                  isCorrect: isCorrect,
                  hasSelection: selectedAnswer != null,
                  onCheckAnswer: _checkAnswer,
                  onNextProblem: _nextProblem,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _checkAnswer() {
    final problem = session.currentProblem;
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
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radius16)),
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
