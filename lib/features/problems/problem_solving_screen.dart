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
import '../../data/providers/problem/problem_provider.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_dimensions.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../shared/widgets/math/math_renderer.dart';
import '../../shared/widgets/input/math_input_field.dart';
import '../../shared/widgets/input/drag_and_drop_widget.dart';
import '../../shared/widgets/zoomable_image_viewer.dart';
import '../../shared/utils/answer_validator.dart';
import '../../data/models/learning/problem.dart' show Problem;
import '../../data/providers/learning/hint_provider_optimized.dart';
import '../../shared/widgets/effects/noise_texture.dart';
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

class _ProblemSolvingScreenState extends ConsumerState<ProblemSolvingScreen>
    with TickerProviderStateMixin {
  ProblemSessionModel? session;
  String? selectedAnswer;
  bool isAnswerChecked = false;
  bool isCorrect = false;
  ValidationResult? validationResult;

  // For fillInBlank type
  final TextEditingController _textController = TextEditingController();

  // For dragAndDrop type
  Map<String, String> _dragDropPlacements = {};

  // 힌트 XP 비용 (provider의 hintCost 사용)
  int get _hintXpCost => HintNotifier.hintCost;

  // Heart animation
  late AnimationController _heartAnimController;
  late Animation<double> _heartScaleAnim;
  int _previousHearts = 5;

  // Feedback slide-up animation
  late AnimationController _feedbackAnimController;
  late Animation<Offset> _feedbackSlideAnim;
  late Animation<double> _feedbackFadeAnim;

  @override
  void initState() {
    super.initState();
    _heartAnimController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _heartScaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.5), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.2), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(
      parent: _heartAnimController,
      curve: Curves.easeInOut,
    ));

    _feedbackAnimController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _feedbackSlideAnim = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _feedbackAnimController,
      curve: Curves.easeOutCubic,
    ));
    _feedbackFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _feedbackAnimController,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _heartAnimController.dispose();
    _feedbackAnimController.dispose();
    super.dispose();
  }

  void _initializeSession(List<ProblemModel> problems) {
    final user = ref.read(userProvider);
    session = ProblemSessionModel(
      sessionId: 'session_${DateTime.now().millisecondsSinceEpoch}',
      lessonId: widget.lessonId,
      userId: user?.uid ?? 'anonymous',
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
    final currentProblem = session!.currentProblem;
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

        // Parse correctAnswer as "zone_id=item_id,..." mapping
        final correctPlacements = _parseDragDropAnswer(currentProblem.correctAnswer);
        result = AnswerValidator.validateDragAndDrop(
          _dragDropPlacements,
          correctPlacements,
        );
        break;
    }

    _previousHearts = session!.hearts;

    setState(() {
      isAnswerChecked = true;
      isCorrect = result.isCorrect;
      validationResult = result;

      // Update session with answer
      final updatedAnswers = Map<String, String>.from(session!.userAnswers);
      updatedAnswers[currentProblem.id] = userAnswer!;

      final updatedCorrectness = Map<String, bool>.from(session!.correctness);
      updatedCorrectness[currentProblem.id] = result.isCorrect;

      // Calculate points based on score (for partial credit)
      final earnedPoints = (currentProblem.points * result.score).round();

      session = session!.copyWith(
        userAnswers: updatedAnswers,
        correctness: updatedCorrectness,
        hearts: result.isCorrect ? session!.hearts : session!.hearts - 1,
        score: session!.score + earnedPoints,
      );
    });

    // Trigger heart loss animation
    if (!result.isCorrect) {
      _heartAnimController.forward(from: 0);
    }

    // Trigger feedback slide-up animation
    _feedbackAnimController.forward(from: 0);

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
    if (session!.hearts <= 0) {
      _showFailureScreen();
      return;
    }

    // Check if all problems are completed
    if (session!.currentProblemIndex + 1 >= session!.totalProblems) {
      _showCompletionScreen();
      return;
    }

    // Reset animations
    _feedbackAnimController.reset();
    _heartAnimController.reset();

    setState(() {
      _previousHearts = session!.hearts;
      session = session!.copyWith(
        currentProblemIndex: session!.currentProblemIndex + 1,
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

  /// Sync session heart losses to Firestore.
  void _syncHeartsToFirestore() {
    if (session == null) return;
    final heartsLost = 5 - session!.hearts; // session starts with 5
    if (heartsLost <= 0) return;

    final userNotifier = ref.read(userProvider.notifier);
    for (int i = 0; i < heartsLost; i++) {
      userNotifier.useHeart();
    }
  }

  void _showCompletionScreen() {
    _syncHeartsToFirestore();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ProblemCompletionScreen(
          session: session!,
          lessonTitle: widget.lessonTitle,
          lessonId: widget.lessonId,
        ),
      ),
    );
  }

  void _showFailureScreen() {
    _syncHeartsToFirestore();
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
    final problemsAsync = ref.watch(problemsForLessonProvider(widget.lessonId));

    return problemsAsync.when(
      loading: () => Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Center(child: Text('문제를 불러올 수 없습니다: $error')),
      ),
      data: (problems) {
        if (session == null) {
          _initializeSession(problems);
        }
        return _buildContent();
      },
    );
  }

  Widget _buildContent() {
    final currentProblem = session!.currentProblem;
    if (currentProblem == null) {
      return const Scaffold(
        body: Center(child: Text('문제를 불러올 수 없습니다.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          // Anti-AI: subtle background gradient instead of flat color
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF8F9FA), Color(0xFFF3F4F6), Colors.white],
                stops: [0.0, 0.4, 1.0],
              ),
            ),
          ),
          // Anti-AI: noise texture overlay
          const NoiseTexture(opacity: 0.02),
          SafeArea(
        child: Stack(
          children: [
            // 메인 콘텐츠
            Column(
              children: [
                // Top progress bar
                _buildProgressBar(),

                // Hearts indicator
                _buildHeartsIndicator(),

                // Question area
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimensions.spacing18,
                      AppDimensions.spacing14,
                      AppDimensions.spacing18,
                      AppDimensions.paddingMedium,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Question card
                        _buildQuestionCard(currentProblem),

                        const SizedBox(height: AppDimensions.spacing20),

                        // Answer input (varies by problem type)
                        _buildAnswerInput(currentProblem),

                        const SizedBox(height: AppDimensions.spacing18),

                        // 잠금 해제된 힌트 표시
                        _buildUnlockedHintsSection(currentProblem),
                      ],
                    ),
                  ),
                ),

                // Bottom action button
                _buildActionButton(),
              ],
            ),

            // Feedback overlay (Stack 위에 올바르게 배치)
            if (isAnswerChecked) _buildFeedbackOverlay(currentProblem),
          ],
        ),
      ),
        ], // Close outer Stack
      ), // Close outer Stack
    );
  }

  Widget _buildProgressBar() {
    final progress = (session!.currentProblemIndex + 1) / session!.totalProblems;
    final percentText = '${(progress * 100).toInt()}%';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.spacing12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.skyBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppDimensions.radius16),
          bottomRight: Radius.circular(AppDimensions.radius16),
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
                    child: const Icon(Icons.close_rounded, color: Colors.white, size: AppDimensions.iconMedium),
                  ),
                  const SizedBox(width: AppDimensions.spacing12),
                  Text(
                    widget.lessonTitle,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // XP badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppDimensions.radius8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bolt_rounded, color: Colors.amber, size: AppDimensions.iconSmall),
                        const SizedBox(width: AppDimensions.spacing2),
                        Consumer(
                          builder: (context, ref, _) {
                            final user = ref.watch(userProvider);
                            return Text(
                              '${user?.xp ?? 0}',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacing8),
                  Text(
                    '${session!.currentProblemIndex + 1}/${session!.totalProblems}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing8),
          // Gradient progress bar with percentage label
          Stack(
            children: [
              Container(
                height: AppDimensions.spacing8,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(AppDimensions.radius4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  height: AppDimensions.spacing8,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.tealGreen, AppColors.mathGreen],
                    ),
                    borderRadius: BorderRadius.circular(AppDimensions.radius4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              percentText,
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeartsIndicator() {
    final currentProblem = session!.currentProblem;
    final hints = currentProblem?.allHints ?? [];
    final user = ref.watch(userProvider);
    final userXp = user?.xp ?? 0;
    final problemId = currentProblem?.id ?? '';
    final hintState = ref.watch(hintProvider);
    final unlockedCount = _getUnlockedCount(hintState, problemId, hints.length);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.spacing8,
      ),
      child: Row(
        children: [
          // Hint button (only shown when hints exist)
          if (hints.isNotEmpty)
            HintButton(
              unlockedCount: unlockedCount,
              totalHints: hints.length,
              xpCost: _hintXpCost,
              isEnabled: !isAnswerChecked,
              onTap: () => _showHintPopup(currentProblem!, userXp),
            )
          else
            const SizedBox(width: AppDimensions.spacing16),
          // Animated hearts display
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) {
                  final isFilled = index < session!.hearts;
                  final isLostHeart = !isFilled &&
                      index == session!.hearts &&
                      session!.hearts < _previousHearts;

                  Widget heartIcon = Icon(
                    isFilled ? Icons.favorite : Icons.favorite_border,
                    color: isFilled ? AppColors.mathRed : AppColors.borderDark,
                    size: AppDimensions.iconMedium,
                  );

                  // Wrap filled hearts with subtle shadow
                  if (isFilled) {
                    heartIcon = Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.mathRed.withValues(alpha: 0.3),
                            blurRadius: 6,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: heartIcon,
                    );
                  }

                  // Animate the heart that was just lost
                  if (isLostHeart) {
                    heartIcon = AnimatedBuilder(
                      animation: _heartAnimController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _heartScaleAnim.value,
                          child: Icon(
                            Icons.favorite_border,
                            color: Color.lerp(
                              AppColors.mathRed,
                              AppColors.borderDark,
                              _heartAnimController.value,
                            ),
                            size: AppDimensions.iconMedium,
                          ),
                        );
                      },
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: heartIcon,
                  );
                },
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

    final hintState = ref.read(hintProvider);
    final unlockedSet = _buildUnlockedSet(hintState, problem.id, hints.length);

    HintPopup.show(
      context: context,
      hints: hints,
      unlockedHints: unlockedSet,
      userXp: userXp,
      xpCost: _hintXpCost,
      onUnlockHint: (index) => _unlockHint(problem, index),
    );
  }

  /// 힌트 잠금 해제 (hintProvider 사용)
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

    // hintProvider를 통해 잠금 해제 (XP 차감 포함)
    final tempProblem = Problem(
      id: problem.id,
      lessonId: widget.lessonId,
      question: problem.question,
      correctAnswer: problem.correctAnswer,
      hints: problem.allHints,
    );
    await ref.read(hintProvider.notifier).unlockHint(tempProblem, hintIndex);

    // 팝업 닫고 다시 열기 (업데이트된 상태 반영)
    if (mounted) {
      Navigator.of(context).pop();
      final updatedUser = ref.read(userProvider);
      _showHintPopup(problem, updatedUser?.xp ?? 0);
    }
  }

  /// 특정 문제의 잠금 해제된 힌트 수 계산
  int _getUnlockedCount(HintState hintState, String problemId, int totalHints) {
    int count = 0;
    for (int i = 0; i < totalHints; i++) {
      if (hintState.unlockedHints.contains('${problemId}_$i')) {
        count++;
      }
    }
    return count;
  }

  /// 특정 문제의 잠금 해제된 인덱스 Set 생성
  Set<int> _buildUnlockedSet(HintState hintState, String problemId, int totalHints) {
    final result = <int>{};
    for (int i = 0; i < totalHints; i++) {
      if (hintState.unlockedHints.contains('${problemId}_$i')) {
        result.add(i);
      }
    }
    return result;
  }

  Widget _buildQuestionCard(ProblemModel problem) {
    return Container(
      // Anti-AI: asymmetric padding for organic feel
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacing20,
        AppDimensions.spacing24,
        AppDimensions.spacing24,
        AppDimensions.spacing20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
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
          const SizedBox(height: AppDimensions.spacing12),
          MathRichText(
            text: problem.question,
            textStyle: AppTextStyles.heading2.copyWith(
              fontSize: 24,
            ),
            mathFontSize: 28.0,
          ),
          if (problem.allImages.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacing16),
            ProblemImageGallery(
              imageUrls: problem.allImages,
              problemId: problem.id,
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
    // Anti-AI: index-based spacing variation for organic rhythm
    const optionSpacing = [12.0, 10.0, 14.0, 10.0, 12.0];
    // Anti-AI: slight radius variation per option
    const optionRadius = [
      AppDimensions.radius12,
      AppDimensions.radius10,
      AppDimensions.radius12,
      AppDimensions.radius10,
    ];

    return Column(
      children: problem.options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final isSelected = selectedAnswer == option;
        final isThisCorrect = option == problem.correctAnswer;
        final isFirst = index == 0;

        Color backgroundColor = Colors.white;
        Color borderColor = AppColors.borderLight;
        double borderWidth = 1.0;
        Color textColor = AppColors.textDark;
        IconData? trailingIcon;
        Color? trailingIconColor;

        if (isAnswerChecked) {
          if (isThisCorrect) {
            backgroundColor = AppColors.mathGreen.withValues(alpha: 0.1);
            borderColor = AppColors.mathGreen;
            borderWidth = 2.0;
            textColor = AppColors.mathGreen;
            trailingIcon = Icons.check_circle_rounded;
            trailingIconColor = AppColors.mathGreen;
          } else if (isSelected && !isCorrect) {
            backgroundColor = AppColors.mathRed.withValues(alpha: 0.1);
            borderColor = AppColors.mathRed;
            borderWidth = 2.0;
            textColor = AppColors.mathRed;
            trailingIcon = Icons.cancel_rounded;
            trailingIconColor = AppColors.mathRed;
          }
        } else if (isSelected) {
          backgroundColor = AppColors.primary.withValues(alpha: 0.08);
          borderColor = AppColors.primary;
          borderWidth = 2.0;
          textColor = AppColors.primary;
        }

        final radius = optionRadius[index % optionRadius.length];
        final bottomSpacing = optionSpacing[index % optionSpacing.length];

        return Padding(
          padding: EdgeInsets.only(bottom: bottomSpacing),
          child: GestureDetector(
            onTap: () => _selectAnswer(option),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing20, vertical: AppDimensions.spacing16),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(radius),
                border: isFirst && !isSelected && !isAnswerChecked
                    // Anti-AI: first option gets a left accent border
                    ? Border(
                        left: BorderSide(color: AppColors.skyBlue.withValues(alpha: 0.4), width: 3),
                        top: BorderSide(color: borderColor, width: borderWidth),
                        right: BorderSide(color: borderColor, width: borderWidth),
                        bottom: BorderSide(color: borderColor, width: borderWidth),
                      )
                    : Border.all(color: borderColor, width: borderWidth),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
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
                  if (trailingIcon != null)
                    Icon(trailingIcon, color: trailingIconColor, size: 22),
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
        const SizedBox(height: AppDimensions.spacing16),
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
    // Draggable items from problem options
    final items = problem.options.map((option) {
      return DraggableItem(
        id: option,
        content: option,
        isMath: true,
      );
    }).toList();

    // Create drop zones from correctAnswer mapping
    final correctPlacements = _parseDragDropAnswer(problem.correctAnswer);
    final dropZones = correctPlacements.keys.map((zoneId) {
      final zoneIndex = int.tryParse(zoneId.replaceAll('zone_', '')) ?? 1;
      return DropZone(
        id: zoneId,
        hint: '$zoneIndex번 위치에 드래그하세요',
      );
    }).toList();

    // Fallback: at least one drop zone
    if (dropZones.isEmpty) {
      dropZones.add(const DropZone(
        id: 'zone_1',
        hint: '여기에 답을 드래그하세요',
      ));
    }

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

  /// Parse drag-and-drop correct answer string into a placement map.
  /// Format: "zone_1=value1,zone_2=value2" or simple "value" for single zone.
  Map<String, String> _parseDragDropAnswer(String correctAnswer) {
    final result = <String, String>{};
    if (correctAnswer.contains('=')) {
      final pairs = correctAnswer.split(',');
      for (final pair in pairs) {
        final parts = pair.trim().split('=');
        if (parts.length == 2) {
          result[parts[0].trim()] = parts[1].trim();
        }
      }
    } else {
      // Single zone fallback
      result['zone_1'] = correctAnswer.trim();
    }
    return result;
  }

  /// 잠금 해제된 힌트들 표시
  Widget _buildUnlockedHintsSection(ProblemModel problem) {
    final hints = problem.allHints;
    final hintState = ref.watch(hintProvider);
    final unlockedSet = _buildUnlockedSet(hintState, problem.id, hints.length);

    if (hints.isEmpty || unlockedSet.isEmpty) {
      return const SizedBox.shrink();
    }

    // 잠금 해제된 힌트만 정렬하여 표시
    final sortedUnlocked = unlockedSet.toList()..sort();

    return Column(
      children: sortedUnlocked.map((index) {
        if (index >= hints.length) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.spacing12),
          child: _buildHintCard(hints[index], index + 1),
        );
      }).toList(),
    );
  }

  Widget _buildHintCard(String hint, int hintNumber) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
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
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
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
            width: AppDimensions.iconLarge,
            height: AppDimensions.iconLarge,
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
                style: AppTextStyles.titleSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '힌트 $hintNumber',
                  style: AppTextStyles.caption.copyWith(
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
    final currentProblem = session!.currentProblem;
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
        height: AppDimensions.buttonHeightLarge,
        child: canCheck || canContinue
            ? DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.deepBlueCTA,
                  borderRadius: BorderRadius.circular(AppDimensions.radius16),
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
                      borderRadius: BorderRadius.circular(AppDimensions.radius16),
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
                    borderRadius: BorderRadius.circular(AppDimensions.radius16),
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

    Color panelColor;
    Color accentColor;
    String title;
    IconData icon;

    if (isCorrect) {
      panelColor = AppColors.mathGreen;
      accentColor = AppColors.mathGreen;
      title = result?.feedback ?? '정답입니다!';
      icon = Icons.check_circle_rounded;
    } else if (isPartialCredit) {
      panelColor = AppColors.mathYellow;
      accentColor = AppColors.mathYellow;
      title = result.feedback ?? '거의 맞았어요!';
      icon = Icons.star_half_rounded;
    } else {
      panelColor = AppColors.mathRed;
      accentColor = AppColors.mathRed;
      title = result?.feedback ?? '틀렸습니다';
      icon = Icons.cancel_rounded;
    }

    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _feedbackAnimController,
        builder: (context, child) {
          return Stack(
            children: [
              // Semi-transparent background overlay
              GestureDetector(
                onTap: _nextProblem,
                child: Container(
                  color: Colors.black.withValues(
                    alpha: 0.3 * _feedbackFadeAnim.value,
                  ),
                ),
              ),
              // Slide-up result panel from bottom
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SlideTransition(
                  position: _feedbackSlideAnim,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppDimensions.radius24),
                        topRight: Radius.circular(AppDimensions.radius24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.all(AppDimensions.spacing24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Drag handle
                            Container(
                              width: AppDimensions.spacing40,
                              height: AppDimensions.spacing4,
                              decoration: BoxDecoration(
                                color: AppColors.borderLight,
                                borderRadius: BorderRadius.circular(AppDimensions.spacing2),
                              ),
                            ),
                            const SizedBox(height: AppDimensions.spacing20),
                            // Icon and title row
                            Row(
                              children: [
                                Container(
                                  width: AppDimensions.iconXLarge,
                                  height: AppDimensions.iconXLarge,
                                  decoration: BoxDecoration(
                                    color: panelColor.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(icon, color: panelColor, size: 28),
                                ),
                                const SizedBox(width: AppDimensions.spacing16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: AppTextStyles.headlineSmall.copyWith(
                                          color: panelColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (isPartialCredit)
                                        Text(
                                          '${(result.score * 100).toStringAsFixed(0)}% 정확도',
                                          style: AppTextStyles.bodyMedium.copyWith(
                                            color: accentColor.withValues(alpha: 0.8),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (!isCorrect && problem.explanation != null) ...[
                              const SizedBox(height: AppDimensions.spacing16),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(AppDimensions.spacing16),
                                decoration: BoxDecoration(
                                  color: accentColor.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(AppDimensions.radius12),
                                  border: Border.all(
                                    color: accentColor.withValues(alpha: 0.15),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '설명',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: accentColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    MathRichText(
                                      text: problem.explanation!,
                                      textStyle: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textPrimary,
                                        height: 1.5,
                                      ),
                                      mathFontSize: 16.0,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            if (result?.hints != null && result!.hints!.isNotEmpty) ...[
                              const SizedBox(height: AppDimensions.spacing12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(AppDimensions.spacing12),
                                decoration: BoxDecoration(
                                  color: AppColors.mathOrange.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(AppDimensions.radius12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '힌트',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.mathOrange,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: AppDimensions.spacing4),
                                    ...result.hints!.map((hint) => Padding(
                                          padding: const EdgeInsets.only(top: AppDimensions.spacing4),
                                          child: Text(
                                            hint,
                                            style: AppTextStyles.bodyMedium.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: AppDimensions.spacing20),
                            // Continue button
                            SizedBox(
                              width: double.infinity,
                              height: AppDimensions.buttonHeightLarge,
                              child: ElevatedButton(
                                onPressed: _nextProblem,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: panelColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppDimensions.radius16),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  '계속하기',
                                  style: AppTextStyles.button.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
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
          padding: const EdgeInsets.all(AppDimensions.spacing32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.celebration,
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: AppDimensions.spacing24),
              Text(
                '레슨 완료!',
                style: AppTextStyles.heading1.copyWith(
                  color: Colors.white,
                  fontSize: 32,
                ),
              ),
              const SizedBox(height: AppDimensions.spacing16),
              Text(
                widget.lessonTitle,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: AppDimensions.spacing48),

              // Stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing8),
                    child: Icon(
                      index < widget.session.starsEarned
                          ? Icons.star
                          : Icons.star_border,
                      size: AppDimensions.iconXLarge,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spacing48),

              // Stats
              _buildStatCard(
                  '정답률',
                  '${(widget.session.accuracy * 100).toStringAsFixed(0)}%'),
              const SizedBox(height: AppDimensions.spacing16),
              _buildStatCard('점수', '${widget.session.score}점'),
              const SizedBox(height: AppDimensions.spacing16),
              _buildStatCard('남은 하트', '${widget.session.hearts}/5'),

              const Spacer(),

              // Continue button
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeightLarge,
                child: ElevatedButton(
                  onPressed: _isSaving
                      ? null
                      : () {
                          Navigator.of(context).pop();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radius12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: AppDimensions.iconMedium,
                          height: AppDimensions.iconMedium,
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
      padding: const EdgeInsets.all(AppDimensions.spacing20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppDimensions.radius12),
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
