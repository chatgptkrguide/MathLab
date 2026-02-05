// 🎯 Problem Solving Screen
//
// Main screen for solving problems in a lesson with:
// - Progress tracking
// - Hearts system
// - Immediate feedback
// - Answer validation

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/problem/problem_model.dart';
import '../../data/models/wrong_answer_model.dart';
import '../../data/providers/lesson/lesson_progress_provider.dart';
import '../../data/providers/user/user_provider.dart';
import '../../data/providers/wrong_answer/wrong_answer_provider.dart';
import '../../data/models/problem/problem_session_model.dart';
import '../../data/models/problem/sample_problems.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_dimensions.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../shared/constants/figma_colors.dart';
import '../../shared/widgets/math/math_renderer.dart';
import '../../shared/widgets/input/math_input_field.dart';
import '../../shared/widgets/input/drag_and_drop_widget.dart';
import '../../shared/utils/answer_validator.dart';
import 'widgets/hint_button.dart';
import 'widgets/hint_popup.dart';

class ProblemSolvingScreen extends ConsumerStatefulWidget {
  final String lessonId;
  final String lessonTitle;

  const ProblemSolvingScreen({
    super.key,
    required this.lessonId,
    required this.lessonTitle,
  });

  @override
  ConsumerState<ProblemSolvingScreen> createState() => _ProblemSolvingScreenState();
}

class _ProblemSolvingScreenState extends ConsumerState<ProblemSolvingScreen> {
  late ProblemSessionModel session;
  String? selectedAnswer;
  bool isAnswerChecked = false;
  bool isCorrect = false;
  ValidationResult? validationResult;

  // For fillInBlank type
  final TextEditingController _textController = TextEditingController();

  // For dragAndDrop type
  Map<String, String> _dragDropPlacements = {};

  // 힌트 시스템
  final Map<String, Set<int>> _unlockedHints = {}; // problemId -> Set of unlocked hint indices
  static const int _hintXpCost = 10;

  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _initializeSession() {
    final problems = SampleProblems.getProblemsForLesson(widget.lessonId);
    session = ProblemSessionModel(
      sessionId: 'session_${DateTime.now().millisecondsSinceEpoch}',
      lessonId: widget.lessonId,
      userId: 'demo_user',
      problems: problems,
      startedAt: DateTime.now(),
    );
  }

  void _selectAnswer(String answer) {
    if (isAnswerChecked) return; // Prevent changing answer after checking
    setState(() {
      selectedAnswer = answer;
    });
  }

  void _checkAnswer() {
    final currentProblem = session.currentProblem;
    if (currentProblem == null) return;

    String? userAnswer;
    ValidationResult result;

    // Validate answer based on problem type
    switch (currentProblem.type) {
      case ProblemType.multipleChoice:
      case ProblemType.trueFalse:
        if (selectedAnswer == null) return;
        userAnswer = selectedAnswer;
        result = AnswerValidator.validateMultipleChoice(
          selectedAnswer!,
          currentProblem.correctAnswer,
        );
        break;

      case ProblemType.fillInBlank:
        userAnswer = _textController.text.trim();
        if (userAnswer.isEmpty) return;

        // Try numerical validation first
        final userNum = double.tryParse(userAnswer);
        final correctNum = double.tryParse(currentProblem.correctAnswer);

        if (userNum != null && correctNum != null) {
          result = AnswerValidator.validateNumerical(
            userAnswer,
            currentProblem.correctAnswer,
            options: ValidationOptions.mathematical,
          );
        } else {
          result = AnswerValidator.validateText(
            userAnswer,
            currentProblem.correctAnswer,
            options: const ValidationOptions(
              ignoreCase: true,
              ignoreWhitespace: true,
              allowPartialCredit: true,
            ),
          );
        }
        break;

      case ProblemType.matching:
      case ProblemType.dragAndDrop:
        if (_dragDropPlacements.isEmpty) return;
        userAnswer = _dragDropPlacements.toString();

        // For now, use a simplified validation
        // In a real implementation, you would parse the correct answer structure
        result = _dragDropPlacements.isNotEmpty
            ? ValidationResult.correct(feedback: '잘했어요! 🎉')
            : ValidationResult.incorrect(feedback: '항목을 배치해주세요.');
        break;
    }

    setState(() {
      isAnswerChecked = true;
      isCorrect = result.isCorrect;
      validationResult = result;

      // Update session with answer
      final updatedAnswers = Map<String, String>.from(session.userAnswers);
      updatedAnswers[currentProblem.id] = userAnswer!;

      final updatedCorrectness = Map<String, bool>.from(session.correctness);
      updatedCorrectness[currentProblem.id] = result.isCorrect;

      // Calculate points based on score (for partial credit)
      final earnedPoints = (currentProblem.points * result.score).round();

      session = session.copyWith(
        userAnswers: updatedAnswers,
        correctness: updatedCorrectness,
        hearts: result.isCorrect ? session.hearts : session.hearts - 1,
        score: session.score + earnedPoints,
      );
    });

    // 오답일 경우 자동 저장
    if (!result.isCorrect) {
      _saveWrongAnswer(currentProblem, userAnswer!);
    }
  }

  /// 오답을 Firestore에 자동 저장
  Future<void> _saveWrongAnswer(ProblemModel problem, String userAnswer) async {
    final user = ref.read(userProvider);
    if (user == null) return;

    final wrongAnswer = WrongAnswerModel(
      id: '', // Firestore에서 자동 생성
      lessonId: widget.lessonId,
      lessonTitle: widget.lessonTitle,
      problemId: problem.id,
      problemType: problem.type.name,
      question: problem.question,
      correctAnswer: problem.correctAnswer,
      userAnswer: userAnswer,
      hint: problem.hint,
      explanation: problem.explanation,
      attemptDate: DateTime.now(),
      isResolved: false,
    );

    try {
      await ref
          .read(wrongAnswerProvider(user.id).notifier)
          .addWrongAnswer(wrongAnswer);
    } catch (e) {
      // 저장 실패 시 무시 (UX에 영향을 주지 않음)
      debugPrint('Failed to save wrong answer: $e');
    }
  }

  void _nextProblem() {
    // Check if hearts are depleted
    if (session.hearts <= 0) {
      _showFailureScreen();
      return;
    }

    // Check if all problems are completed
    if (session.currentProblemIndex + 1 >= session.totalProblems) {
      _showCompletionScreen();
      return;
    }

    setState(() {
      session = session.copyWith(
        currentProblemIndex: session.currentProblemIndex + 1,
      );
      // Reset all input states
      selectedAnswer = null;
      isAnswerChecked = false;
      isCorrect = false;
      validationResult = null;
      _textController.clear();
      _dragDropPlacements = {};
    });
  }

  void _showCompletionScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ProblemCompletionScreen(
          session: session,
          lessonTitle: widget.lessonTitle,
          lessonId: widget.lessonId,
        ),
      ),
    );
  }

  void _showFailureScreen() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('💔 하트가 모두 소진되었습니다'),
        content: const Text('레슨을 다시 시작해보세요!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Return to lessons screen
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentProblem = session.currentProblem;
    if (currentProblem == null) {
      return const Scaffold(
        body: Center(child: Text('문제를 불러올 수 없습니다.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Top progress bar
            _buildProgressBar(),

            // Hearts indicator
            _buildHeartsIndicator(),

            // Question area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Question card
                    _buildQuestionCard(currentProblem),

                    const SizedBox(height: 24),

                    // Answer input (varies by problem type)
                    _buildAnswerInput(currentProblem),

                    const SizedBox(height: 24),

                    // 잠금 해제된 힌트 표시
                    _buildUnlockedHintsSection(currentProblem),
                  ],
                ),
              ),
            ),

            // Bottom action button
            _buildActionButton(),

            // Feedback overlay
            if (isAnswerChecked) _buildFeedbackOverlay(currentProblem),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = (session.currentProblemIndex + 1) / session.totalProblems;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: FigmaColors.skyBlue,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.lessonTitle,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Text(
                '${session.currentProblemIndex + 1}/${session.totalProblems}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 14,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(7),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 14,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  FigmaColors.tealGreen,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeartsIndicator() {
    final currentProblem = session.currentProblem;
    final hints = currentProblem?.allHints ?? [];
    final user = ref.watch(userProvider);
    final userXp = user?.xp ?? 0;
    final problemId = currentProblem?.id ?? '';
    final unlockedCount = _unlockedHints[problemId]?.length ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: 8,
      ),
      child: Row(
        children: [
          // 힌트 버튼 (힌트가 있을 때만 표시)
          if (hints.isNotEmpty)
            HintButton(
              unlockedCount: unlockedCount,
              totalHints: hints.length,
              xpCost: _hintXpCost,
              isEnabled: !isAnswerChecked,
              onTap: () => _showHintPopup(currentProblem!, userXp),
            )
          else
            const SizedBox(width: 16),
          // 하트 표시 (가운데 정렬)
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Icon(
                    index < session.hearts ? Icons.favorite : Icons.favorite_border,
                    color: index < session.hearts
                        ? AppColors.mathRed
                        : AppColors.borderDark,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 힌트 팝업 표시
  void _showHintPopup(ProblemModel problem, int userXp) {
    final hints = problem.allHints;
    if (hints.isEmpty) return;

    final problemId = problem.id;
    final unlockedSet = _unlockedHints[problemId] ?? <int>{};

    HintPopup.show(
      context: context,
      hints: hints,
      unlockedHints: unlockedSet,
      userXp: userXp,
      xpCost: _hintXpCost,
      onUnlockHint: (index) => _unlockHint(problem, index),
    );
  }

  /// 힌트 잠금 해제
  Future<void> _unlockHint(ProblemModel problem, int hintIndex) async {
    final user = ref.read(userProvider);
    if (user == null) return;

    // XP 부족 확인
    if (user.xp < _hintXpCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('XP가 부족합니다. (필요: $_hintXpCost XP)'),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // XP 차감
    await ref.read(userProvider.notifier).addXp(-_hintXpCost);

    // 힌트 잠금 해제 상태 업데이트
    setState(() {
      if (_unlockedHints[problem.id] == null) {
        _unlockedHints[problem.id] = <int>{};
      }
      _unlockedHints[problem.id]!.add(hintIndex);
    });

    // 팝업 닫고 다시 열기 (업데이트된 상태 반영)
    if (mounted) {
      Navigator.of(context).pop();
      final updatedUser = ref.read(userProvider);
      _showHintPopup(problem, updatedUser?.xp ?? 0);
    }
  }

  Widget _buildQuestionCard(ProblemModel problem) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '문제',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          MathRichText(
            text: problem.question,
            textStyle: AppTextStyles.heading2.copyWith(
              fontSize: 24,
            ),
            mathFontSize: 28.0,
          ),
          if (problem.imageUrl != null) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                problem.imageUrl!,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
                    color: AppColors.backgroundLight,
                    child: const Center(
                      child: Icon(Icons.image_not_supported),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnswerInput(ProblemModel problem) {
    switch (problem.type) {
      case ProblemType.multipleChoice:
      case ProblemType.trueFalse:
        return _buildAnswerOptions(problem);

      case ProblemType.fillInBlank:
        return _buildFillInBlankInput(problem);

      case ProblemType.matching:
      case ProblemType.dragAndDrop:
        return _buildDragAndDropInput(problem);
    }
  }

  Widget _buildAnswerOptions(ProblemModel problem) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: problem.options.map((option) {
        final isSelected = selectedAnswer == option;
        final isThisCorrect = option == problem.correctAnswer;

        Color backgroundColor = const Color(0xFFE6EEEB);
        Color textColor = FigmaColors.textDark;

        if (isAnswerChecked) {
          if (isThisCorrect) {
            backgroundColor = AppColors.mathGreen;
            textColor = Colors.white;
          } else if (isSelected && !isCorrect) {
            backgroundColor = AppColors.mathRed;
            textColor = Colors.white;
          }
        } else if (isSelected) {
          backgroundColor = FigmaColors.skyBlue;
          textColor = Colors.white;
        }

        return GestureDetector(
          onTap: () => _selectAnswer(option),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              option,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: isSelected || (isAnswerChecked && isThisCorrect)
                    ? FontWeight.w600
                    : FontWeight.normal,
                color: textColor,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFillInBlankInput(ProblemModel problem) {
    return Column(
      children: [
        MathInputField(
          controller: _textController,
          hintText: '답을 입력하세요',
          autofocus: true,
          onSubmitted: (_) {
            if (!isAnswerChecked && _textController.text.trim().isNotEmpty) {
              _checkAnswer();
            }
          },
        ),
        const SizedBox(height: 16),
        MathKeyboard(
          controller: _textController,
          onDone: () {
            if (!isAnswerChecked && _textController.text.trim().isNotEmpty) {
              _checkAnswer();
            }
          },
        ),
      ],
    );
  }

  Widget _buildDragAndDropInput(ProblemModel problem) {
    // For now, we'll use a placeholder for drag and drop
    // In a real implementation, you would parse problem.options and problem.correctAnswer
    // to create draggable items and drop zones

    // Example draggable items
    final items = problem.options.map((option) {
      return DraggableItem(
        id: option,
        content: option,
        isMath: true,
      );
    }).toList();

    // Example drop zones
    final dropZones = [
      const DropZone(
        id: 'zone_1',
        hint: '여기에 답을 드래그하세요',
      ),
    ];

    return DragAndDropMathWidget(
      items: items,
      dropZones: dropZones,
      isEnabled: !isAnswerChecked,
      onChanged: (placements) {
        setState(() {
          _dragDropPlacements = placements;
        });
      },
    );
  }

  /// 잠금 해제된 힌트들 표시
  Widget _buildUnlockedHintsSection(ProblemModel problem) {
    final hints = problem.allHints;
    final unlockedSet = _unlockedHints[problem.id] ?? <int>{};

    if (hints.isEmpty || unlockedSet.isEmpty) {
      return const SizedBox.shrink();
    }

    // 잠금 해제된 힌트만 정렬하여 표시
    final sortedUnlocked = unlockedSet.toList()..sort();

    return Column(
      children: sortedUnlocked.map((index) {
        if (index >= hints.length) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildHintCard(hints[index], index + 1),
        );
      }).toList(),
    );
  }

  Widget _buildHintCard(String hint, int hintNumber) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.mathOrange.withValues(alpha: 0.12),
            AppColors.mathOrange.withValues(alpha: 0.06),
          ],
        ),
        border: Border.all(
          color: AppColors.mathOrange.withValues(alpha: 0.3),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.mathOrange.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 힌트 번호 배지
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.mathOrange, Color(0xFFE67E22)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.mathOrange.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$hintNumber',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '힌트 $hintNumber',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.mathOrange,
                  ),
                ),
                const SizedBox(height: 6),
                MathRichText(
                  text: hint,
                  textStyle: AppTextStyles.bodyMedium.copyWith(
                    height: 1.5,
                  ),
                  mathFontSize: 16.0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    final currentProblem = session.currentProblem;
    if (currentProblem == null) return const SizedBox();

    bool hasAnswer = false;
    String buttonText = '답을 입력하세요';

    // Check if user has provided an answer based on problem type
    switch (currentProblem.type) {
      case ProblemType.multipleChoice:
      case ProblemType.trueFalse:
        hasAnswer = selectedAnswer != null;
        buttonText = hasAnswer ? '확인' : '답을 선택하세요';
        break;

      case ProblemType.fillInBlank:
        hasAnswer = _textController.text.trim().isNotEmpty;
        buttonText = hasAnswer ? '확인' : '답을 입력하세요';
        break;

      case ProblemType.matching:
      case ProblemType.dragAndDrop:
        hasAnswer = _dragDropPlacements.isNotEmpty;
        buttonText = hasAnswer ? '확인' : '항목을 배치하세요';
        break;
    }

    final canCheck = hasAnswer && !isAnswerChecked;
    final canContinue = isAnswerChecked;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: canCheck || canContinue
            ? DecoratedBox(
                decoration: BoxDecoration(
                  gradient: FigmaColors.deepBlueCTA,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ElevatedButton(
                  onPressed: canCheck
                      ? _checkAnswer
                      : canContinue
                          ? _nextProblem
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    canContinue ? '계속' : '정답 확인',
                    style: AppTextStyles.button.copyWith(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )
            : ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.borderLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  buttonText,
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildFeedbackOverlay(ProblemModel problem) {
    final result = validationResult;
    final isPartialCredit = result != null && result.score > 0 && result.score < 1.0;

    Color backgroundColor;
    String title;
    IconData icon;

    if (isCorrect) {
      backgroundColor = AppColors.mathGreen.withValues(alpha: 0.95);
      title = result?.feedback ?? '정답입니다!';
      icon = Icons.check_circle;
    } else if (isPartialCredit) {
      backgroundColor = AppColors.mathYellow.withValues(alpha: 0.95);
      title = result.feedback ?? '거의 맞았어요!';
      icon = Icons.star_half;
    } else {
      backgroundColor = AppColors.mathRed.withValues(alpha: 0.95);
      title = result?.feedback ?? '틀렸습니다';
      icon = Icons.cancel;
    }

    return Positioned.fill(
      child: Container(
        color: backgroundColor,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: AppTextStyles.heading1.copyWith(
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (isPartialCredit) ...[
                  const SizedBox(height: 12),
                  Text(
                    '${(result.score * 100).toStringAsFixed(0)}% 정확도',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (!isCorrect && problem.explanation != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '설명',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        MathRichText(
                          text: problem.explanation!,
                          textStyle: AppTextStyles.bodyLarge.copyWith(
                            color: Colors.white,
                          ),
                          mathFontSize: 18.0,
                        ),
                      ],
                    ),
                  ),
                ],
                if (result?.hints != null && result!.hints!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '💡 힌트',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...result.hints!.map((hint) => Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                '• $hint',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 🎉 Problem Completion Screen
class ProblemCompletionScreen extends ConsumerStatefulWidget {
  final ProblemSessionModel session;
  final String lessonTitle;
  final String lessonId;

  const ProblemCompletionScreen({
    super.key,
    required this.session,
    required this.lessonTitle,
    required this.lessonId,
  });

  @override
  ConsumerState<ProblemCompletionScreen> createState() =>
      _ProblemCompletionScreenState();
}

class _ProblemCompletionScreenState
    extends ConsumerState<ProblemCompletionScreen> {
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // 레슨 완료 시 자동 저장
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _saveProgress();
    });
  }

  Future<void> _saveProgress() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final user = ref.read(userProvider);
      if (user == null) return;

      // 1. 레슨 진행 상황 저장
      await ref
          .read(lessonProgressProvider(user.id).notifier)
          .completeLesson(
            lessonId: widget.lessonId,
            correctAnswers: widget.session.correctCount,
            totalQuestions: widget.session.problems.length,
            xpEarned: widget.session.score,
          );

      // 2. 사용자 XP 추가
      await ref.read(userProvider.notifier).addXp(widget.session.score);

      // 3. 스트릭 업데이트
      await ref.read(userProvider.notifier).updateStreak();
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mathGreen,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.celebration,
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 24),
              Text(
                '레슨 완료!',
                style: AppTextStyles.heading1.copyWith(
                  color: Colors.white,
                  fontSize: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.lessonTitle,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 48),

              // Stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      index < widget.session.starsEarned
                          ? Icons.star
                          : Icons.star_border,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Stats
              _buildStatCard(
                  '정답률',
                  '${(widget.session.accuracy * 100).toStringAsFixed(0)}%'),
              const SizedBox(height: 16),
              _buildStatCard('점수', '${widget.session.score}점'),
              const SizedBox(height: 16),
              _buildStatCard('남은 하트', '${widget.session.hearts}/5'),

              const Spacer(),

              // Continue button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving
                      ? null
                      : () {
                          Navigator.of(context).pop();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(AppColors.mathGreen),
                          ),
                        )
                      : Text(
                          '계속하기',
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.mathGreen,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.white,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
