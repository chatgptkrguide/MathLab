// Problem Solving Screen
//
// Main screen for solving problems in a lesson.
// Orchestrates widgets and delegates logic to ProblemSolvingController.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/problem/problem_model.dart';
import '../../data/models/problem/problem_session_model.dart';
import '../../data/providers/problem/problem_provider.dart';
import '../../data/providers/user/user_provider.dart';
import '../../data/providers/learning/hint_provider.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_dimensions.dart';
import '../../shared/utils/answer_validator.dart';
import 'problem_solving_controller.dart';
import 'problem_completion_screen.dart';
import 'widgets/problem_header.dart';
import 'widgets/hearts_indicator.dart';
import 'widgets/problem_content.dart';
import 'widgets/answer_input.dart';
import 'widgets/answer_feedback.dart';
import 'widgets/problem_action_button.dart';
import 'widgets/hint_popup.dart';
import '../shop/shop_screen.dart';

class ProblemSolvingScreen extends ConsumerStatefulWidget {
  final String lessonId;
  final String lessonTitle;
  final String? unitTitle;
  final int? stepNumber;
  final int? totalSteps;

  const ProblemSolvingScreen({
    super.key,
    required this.lessonId,
    required this.lessonTitle,
    this.unitTitle,
    this.stepNumber,
    this.totalSteps,
  });

  @override
  ConsumerState<ProblemSolvingScreen> createState() =>
      _ProblemSolvingScreenState();
}

class _ProblemSolvingScreenState extends ConsumerState<ProblemSolvingScreen>
    with TickerProviderStateMixin {
  ProblemSessionModel? session;
  String? selectedAnswer;
  bool isAnswerChecked = false;
  bool isCorrect = false;
  ValidationResult? validationResult;

  final TextEditingController _textController = TextEditingController();
  Map<String, String> _dragDropPlacements = {};

  late ProblemSolvingController _controller;

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
    // 캐시 무효화하지 않음 — 같은 레슨을 다시 풀어도 같은 문제 세트라
    // Firestore 라운드트립을 매번 발생시킬 이유가 없다.
    // 강제 새로고침이 필요하면 명시적으로 invalidate를 호출할 것.

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

  void _initController() {
    _controller = ProblemSolvingController(
      ref: ref,
      lessonId: widget.lessonId,
      lessonTitle: widget.lessonTitle,
    );
  }

  void _selectAnswer(String answer) {
    if (isAnswerChecked) return;
    setState(() {
      selectedAnswer = answer;
    });
  }

  void _checkAnswer() {
    _initController();
    final currentProblem = session!.currentProblem;
    if (currentProblem == null) return;

    _previousHearts = session!.hearts;

    final result = _controller.checkAnswer(
      session: session!,
      currentProblem: currentProblem,
      selectedAnswer: selectedAnswer,
      textController: _textController,
      dragDropPlacements: _dragDropPlacements,
    );

    if (result == null) return;

    setState(() {
      isAnswerChecked = true;
      isCorrect = result.isCorrect;
      validationResult = result.validationResult;
      session = result.session;
    });

    if (!result.isCorrect) {
      _heartAnimController.forward(from: 0);
    }
    _feedbackAnimController.forward(from: 0);
  }

  void _nextProblem() {
    if (session == null) return;

    if (session!.hearts <= 0) {
      _showFailureScreen();
      return;
    }

    if (session!.currentProblemIndex + 1 >= session!.totalProblems) {
      _showCompletionScreen();
      return;
    }

    _feedbackAnimController.reset();
    _heartAnimController.reset();

    setState(() {
      _previousHearts = session!.hearts;
      session = session!.copyWith(
        currentProblemIndex: session!.currentProblemIndex + 1,
      );
      selectedAnswer = null;
      isAnswerChecked = false;
      isCorrect = false;
      validationResult = null;
      _textController.clear();
      _dragDropPlacements = {};
    });
  }

  void _showCompletionScreen() {
    _initController();
    _controller.syncHeartsToFirestore(session!);
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
    _initController();
    _controller.syncHeartsToFirestore(session!);
    final user = ref.read(userProvider);
    final gems = user?.gems ?? 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.favorite, color: Color(0xFFFF4B6E), size: 24),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                '하트가 모두 소진되었습니다',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '하트가 없으면 문제를 풀 수 없어요.\n상점에서 젬으로 충전하거나 30분 후 자동 회복을 기다려보세요.',
              style: TextStyle(
                  fontSize: 14, color: Color(0xFF777777), height: 1.5),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.diamond_rounded,
                    color: Color(0xFFFFB800), size: 16),
                const SizedBox(width: 4),
                Text(
                  '보유 젬: $gems',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF555555),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop();
            },
            child: const Text(
              '기다리기',
              style: TextStyle(color: Color(0xFF777777)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ShopScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B5CE7),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text(
              '상점에서 충전하기',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  void _showHintPopup(ProblemModel problem) {
    _initController();
    final hints = problem.allHints;
    if (hints.isEmpty) return;

    final hintState = ref.read(hintProvider);
    final unlockedSet =
        _controller.buildUnlockedSet(hintState, problem.id, hints.length);

    HintPopup.show(
      context: context,
      hints: hints,
      unlockedHints: unlockedSet,
      onUnlockHint: (index) => _unlockHint(problem, index),
    );
  }

  Future<void> _unlockHint(ProblemModel problem, int hintIndex) async {
    _initController();
    final success = await _controller.unlockHint(problem, hintIndex);

    if (!success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('힌트를 해제할 수 없습니다.'),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    if (mounted) {
      Navigator.of(context).pop();
      _showHintPopup(problem);
    }
  }

  @override
  Widget build(BuildContext context) {
    final problemsAsync =
        ref.watch(problemsForLessonProvider(widget.lessonId));

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
          _initController();
          session = _controller.initializeSession(problems);
        }
        return _buildContent();
      },
    );
  }

  Widget _buildContent() {
    _initController();
    final currentProblem = session!.currentProblem;
    if (currentProblem == null) {
      return const Scaffold(
        body: Center(child: Text('문제를 불러올 수 없습니다.')),
      );
    }

    final progress =
        (session!.currentProblemIndex + 1) / session!.totalProblems;
    final problemNumber =
        '${session!.currentProblemIndex + 1}'.padLeft(2, '0');

    final hintState = ref.watch(hintProvider);
    final hints = currentProblem.allHints;
    final unlockedCount = _controller.getUnlockedCount(
        hintState, currentProblem.id, hints.length);
    final unlockedSet = _controller.buildUnlockedSet(
        hintState, currentProblem.id, hints.length);

    final hasUserAnswer = _controller.hasAnswer(
      problem: currentProblem,
      selectedAnswer: selectedAnswer,
      textController: _textController,
      dragDropPlacements: _dragDropPlacements,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          Container(color: const Color(0xFFFAFAFA)),
          SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    // Progress bar header
                    ProblemHeader(
                      progress: progress,
                      problemNumber: problemNumber,
                      lessonTitle: widget.lessonTitle,
                      unitTitle: widget.unitTitle,
                      stepNumber: widget.stepNumber,
                      totalSteps: widget.totalSteps,
                      onBack: () => Navigator.of(context).pop(),
                    ),

                    // Hearts indicator
                    HeartsIndicator(
                      currentHearts: session!.hearts,
                      previousHearts: _previousHearts,
                      isAnswerChecked: isAnswerChecked,
                      heartAnimController: _heartAnimController,
                      heartScaleAnim: _heartScaleAnim,
                      currentProblem: currentProblem,
                      unlockedHintCount: unlockedCount,
                      totalHints: hints.length,
                      onHintTap: () =>
                          _showHintPopup(currentProblem),
                    ),

                    // Question + answer area
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
                            ProblemQuestionCard(problem: currentProblem),
                            const SizedBox(height: AppDimensions.spacing20),
                            AnswerInput(
                              problem: currentProblem,
                              selectedAnswer: selectedAnswer,
                              isAnswerChecked: isAnswerChecked,
                              isCorrect: isCorrect,
                              textController: _textController,
                              dragDropPlacements: _dragDropPlacements,
                              onSelectAnswer: _selectAnswer,
                              onCheckAnswer: _checkAnswer,
                              onDragDropChanged: (placements) {
                                setState(() {
                                  _dragDropPlacements = placements;
                                });
                              },
                              parseDragDropAnswer:
                                  _controller.parseDragDropAnswer,
                            ),
                            const SizedBox(height: AppDimensions.spacing18),
                            UnlockedHintsSection(
                              hints: hints,
                              unlockedIndices: unlockedSet,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Bottom action button
                    ProblemActionButton(
                      hasAnswer: hasUserAnswer,
                      isAnswerChecked: isAnswerChecked,
                      onCheck: _checkAnswer,
                      onNext: _nextProblem,
                    ),
                  ],
                ),

                // Feedback overlay
                if (isAnswerChecked)
                  AnswerFeedbackOverlay(
                    problem: currentProblem,
                    isCorrect: isCorrect,
                    validationResult: validationResult,
                    animationController: _feedbackAnimController,
                    slideAnimation: _feedbackSlideAnim,
                    fadeAnimation: _feedbackFadeAnim,
                    onContinue: _nextProblem,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
