/// 🎯 Problem Solving Screen
///
/// Main screen for solving problems in a lesson with:
/// - Progress tracking
/// - Hearts system
/// - Immediate feedback
/// - Answer validation

import 'package:flutter/material.dart';
import '../../data/models/problem/problem_model.dart';
import '../../data/models/problem/problem_session_model.dart';
import '../../data/models/problem/sample_problems.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_dimensions.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../shared/widgets/math/math_renderer.dart';
import '../../shared/widgets/input/math_input_field.dart';
import '../../shared/widgets/input/drag_and_drop_widget.dart';
import '../../shared/utils/answer_validator.dart';

class ProblemSolvingScreen extends StatefulWidget {
  final String lessonId;
  final String lessonTitle;

  const ProblemSolvingScreen({
    super.key,
    required this.lessonId,
    required this.lessonTitle,
  });

  @override
  State<ProblemSolvingScreen> createState() => _ProblemSolvingScreenState();
}

class _ProblemSolvingScreenState extends State<ProblemSolvingScreen> {
  late ProblemSessionModel session;
  String? selectedAnswer;
  bool isAnswerChecked = false;
  bool isCorrect = false;
  ValidationResult? validationResult;

  // For fillInBlank type
  final TextEditingController _textController = TextEditingController();

  // For dragAndDrop type
  Map<String, String> _dragDropPlacements = {};

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

                    // Hint (if available and not answered correctly)
                    if (currentProblem.hint != null && !isCorrect)
                      _buildHintCard(currentProblem.hint!),
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.lessonTitle,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${session.currentProblemIndex + 1}/${session.totalProblems}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.borderLight,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.mathGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeartsIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          5,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              index < session.hearts ? Icons.favorite : Icons.favorite_border,
              color: index < session.hearts
                  ? AppColors.mathRed
                  : AppColors.borderDark,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(ProblemModel problem) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
    return Column(
      children: problem.options.map((option) {
        final isSelected = selectedAnswer == option;
        final isThisCorrect = option == problem.correctAnswer;

        Color borderColor = AppColors.borderLight;
        Color backgroundColor = Colors.white;

        if (isAnswerChecked) {
          if (isThisCorrect) {
            borderColor = AppColors.mathGreen;
            backgroundColor = AppColors.mathGreen.withOpacity(0.1);
          } else if (isSelected && !isCorrect) {
            borderColor = AppColors.mathRed;
            backgroundColor = AppColors.mathRed.withOpacity(0.1);
          }
        } else if (isSelected) {
          borderColor = AppColors.mathBlue;
          backgroundColor = AppColors.mathBlue.withOpacity(0.05);
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => _selectAnswer(option),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: backgroundColor,
                border: Border.all(
                  color: borderColor,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: borderColor,
                        width: 2,
                      ),
                      color: isSelected ? borderColor : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (isAnswerChecked && isThisCorrect)
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.mathGreen,
                    ),
                  if (isAnswerChecked && isSelected && !isCorrect)
                    const Icon(
                      Icons.cancel,
                      color: AppColors.mathRed,
                    ),
                ],
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

  Widget _buildHintCard(String hint) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.mathYellow.withOpacity(0.1),
        border: Border.all(color: AppColors.mathYellow),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb, color: AppColors.mathYellow),
          const SizedBox(width: 12),
          Expanded(
            child: MathRichText(
              text: hint,
              textStyle: AppTextStyles.bodyMedium,
              mathFontSize: 16.0,
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: canCheck
              ? _checkAnswer
              : canContinue
                  ? _nextProblem
                  : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: canCheck || canContinue
                ? AppColors.mathGreen
                : AppColors.borderLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Text(
            canContinue ? '계속' : buttonText,
            style: AppTextStyles.button.copyWith(
              color: canCheck || canContinue ? Colors.white : AppColors.textSecondary,
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
      backgroundColor = AppColors.mathGreen.withOpacity(0.95);
      title = result?.feedback ?? '정답입니다!';
      icon = Icons.check_circle;
    } else if (isPartialCredit) {
      backgroundColor = AppColors.mathYellow.withOpacity(0.95);
      title = result?.feedback ?? '거의 맞았어요!';
      icon = Icons.star_half;
    } else {
      backgroundColor = AppColors.mathRed.withOpacity(0.95);
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
                    '${(result!.score * 100).toStringAsFixed(0)}% 정확도',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (!isCorrect && problem.explanation != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
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
                      color: Colors.white.withOpacity(0.15),
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
                                  color: Colors.white.withOpacity(0.9),
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
class ProblemCompletionScreen extends StatelessWidget {
  final ProblemSessionModel session;
  final String lessonTitle;

  const ProblemCompletionScreen({
    super.key,
    required this.session,
    required this.lessonTitle,
  });

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
                lessonTitle,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.white.withOpacity(0.9),
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
                      index < session.starsEarned
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
              _buildStatCard('정답률', '${(session.accuracy * 100).toStringAsFixed(0)}%'),
              const SizedBox(height: 16),
              _buildStatCard('점수', '${session.score}점'),
              const SizedBox(height: 16),
              _buildStatCard('남은 하트', '${session.hearts}/5'),

              const Spacer(),

              // Continue button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Update lesson progress in database
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
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
        color: Colors.white.withOpacity(0.2),
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
