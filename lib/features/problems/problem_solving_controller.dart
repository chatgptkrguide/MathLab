// Problem Solving Controller
//
// Business logic for the problem solving screen:
// - Answer checking and validation
// - Session management (hearts, progress)
// - Wrong answer saving
// - Hint management

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/app_logger.dart';
import '../../data/models/problem/problem_model.dart';
import '../../data/models/problem/problem_session_model.dart';
import '../../data/models/wrong_answer_model.dart';
import '../../data/providers/user/user_provider.dart';
import '../../data/providers/wrong_answer/wrong_answer_provider.dart';
import '../../data/providers/learning/hint_provider.dart';
import '../../shared/utils/answer_validator.dart';

class ProblemSolvingController {
  final WidgetRef ref;
  final String lessonId;
  final String lessonTitle;

  ProblemSolvingController({
    required this.ref,
    required this.lessonId,
    required this.lessonTitle,
  });

  ProblemSessionModel initializeSession(List<ProblemModel> problems) {
    final user = ref.read(userProvider);
    return ProblemSessionModel(
      sessionId: 'session_${DateTime.now().millisecondsSinceEpoch}',
      lessonId: lessonId,
      userId: user?.uid ?? 'anonymous',
      problems: problems,
      startedAt: DateTime.now(),
    );
  }

  /// Check the user's answer and return updated state.
  /// Returns null if no valid answer provided.
  AnswerCheckResult? checkAnswer({
    required ProblemSessionModel session,
    required ProblemModel currentProblem,
    required String? selectedAnswer,
    required TextEditingController textController,
    required Map<String, String> dragDropPlacements,
  }) {
    String? userAnswer;
    late ValidationResult result;

    switch (currentProblem.type) {
      case ProblemType.multipleChoice:
      case ProblemType.trueFalse:
        if (selectedAnswer == null) return null;
        userAnswer = selectedAnswer;
        result = AnswerValidator.validateMultipleChoice(
          selectedAnswer,
          currentProblem.correctAnswer,
        );
        break;

      case ProblemType.shortAnswer:
      case ProblemType.fillInBlank:
        userAnswer = textController.text.trim();
        if (userAnswer.isEmpty) return null;

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
        if (dragDropPlacements.isEmpty) return null;
        userAnswer = dragDropPlacements.toString();

        final correctPlacements =
            parseDragDropAnswer(currentProblem.correctAnswer);
        result = AnswerValidator.validateDragAndDrop(
          dragDropPlacements,
          correctPlacements,
        );
        break;
    }

    // Update session
    final updatedAnswers = Map<String, String>.from(session.userAnswers);
    updatedAnswers[currentProblem.id] = userAnswer;

    final updatedCorrectness = Map<String, bool>.from(session.correctness);
    updatedCorrectness[currentProblem.id] = result.isCorrect;

    final earnedPoints = (currentProblem.points * result.score).round();

    final updatedSession = session.copyWith(
      userAnswers: updatedAnswers,
      correctness: updatedCorrectness,
      hearts: result.isCorrect ? session.hearts : session.hearts - 1,
      score: session.score + earnedPoints,
    );

    // Save wrong answer if incorrect — fire-and-forget으로 풀이 흐름 비차단.
    if (!result.isCorrect) {
      unawaited(_saveWrongAnswer(currentProblem, userAnswer));
    }

    return AnswerCheckResult(
      session: updatedSession,
      isCorrect: result.isCorrect,
      validationResult: result,
    );
  }

  /// Parse drag-and-drop correct answer string into a placement map.
  Map<String, String> parseDragDropAnswer(String correctAnswer) {
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
      result['zone_1'] = correctAnswer.trim();
    }
    return result;
  }

  /// Save wrong answer to Firestore
  Future<void> _saveWrongAnswer(
      ProblemModel problem, String userAnswer) async {
    final user = ref.read(userProvider);
    if (user == null) return;

    final wrongAnswer = WrongAnswerModel(
      id: '',
      lessonId: lessonId,
      lessonTitle: lessonTitle,
      problemId: problem.id,
      problemType: problem.type.name,
      question: problem.question,
      correctAnswer: problem.correctAnswer,
      userAnswer: userAnswer,
      hint: problem.allHints.isNotEmpty ? problem.allHints.first : null,
      explanation: problem.explanation,
      attemptDate: DateTime.now(),
      isResolved: false,
    );

    try {
      await ref
          .read(wrongAnswerProvider(user.id).notifier)
          .addWrongAnswer(wrongAnswer);
    } catch (e, stackTrace) {
      // 비치명적: 오답 노트 저장 실패해도 풀이 흐름은 계속.
      AppLogger.warning(
        'Failed to save wrong answer',
        tag: 'Problem',
        error: e,
        stackTrace: stackTrace,
        data: {'problemId': problem.id, 'userId': user.id},
      );
    }
  }

  /// Sync session heart losses to Firestore.
  /// 세션 동안 잃은 하트 수를 한 번의 Firestore 쓰기로 반영한다.
  void syncHeartsToFirestore(ProblemSessionModel session) {
    final user = ref.read(userProvider);
    if (user == null) return;

    final heartsLost = 5 - session.hearts;
    if (heartsLost <= 0) return;

    final newHearts = (user.hearts - heartsLost).clamp(0, user.maxHearts);
    if (newHearts == user.hearts) return;

    unawaited(ref.read(userProvider.notifier).updateHearts(newHearts));
  }

  /// Check if user has provided an answer
  bool hasAnswer({
    required ProblemModel problem,
    required String? selectedAnswer,
    required TextEditingController textController,
    required Map<String, String> dragDropPlacements,
  }) {
    switch (problem.type) {
      case ProblemType.multipleChoice:
      case ProblemType.trueFalse:
        return selectedAnswer != null;
      case ProblemType.shortAnswer:
      case ProblemType.fillInBlank:
        return textController.text.trim().isNotEmpty;
      case ProblemType.matching:
      case ProblemType.dragAndDrop:
        return dragDropPlacements.isNotEmpty;
    }
  }

  // -- Hint helpers --

  int getUnlockedCount(HintState hintState, String problemId, int totalHints) {
    int count = 0;
    for (int i = 0; i < totalHints; i++) {
      if (hintState.unlockedHints.contains('${problemId}_$i')) {
        count++;
      }
    }
    return count;
  }

  Set<int> buildUnlockedSet(
      HintState hintState, String problemId, int totalHints) {
    final result = <int>{};
    for (int i = 0; i < totalHints; i++) {
      if (hintState.unlockedHints.contains('${problemId}_$i')) {
        result.add(i);
      }
    }
    return result;
  }

  /// Unlock a hint (currently free)
  Future<bool> unlockHint(ProblemModel problem, int hintIndex) async {
    return await ref.read(hintProvider.notifier).unlockHint(problem, hintIndex);
  }
}

/// Result of checking an answer
class AnswerCheckResult {
  final ProblemSessionModel session;
  final bool isCorrect;
  final ValidationResult validationResult;

  const AnswerCheckResult({
    required this.session,
    required this.isCorrect,
    required this.validationResult,
  });
}
