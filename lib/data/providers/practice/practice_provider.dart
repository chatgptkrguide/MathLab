/// 🎯 Practice Provider
///
/// Manages practice sessions and problem attempts

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../models/practice_session_model.dart';
import '../../models/problem/problem_model.dart';
import '../api_provider.dart';

final logger = Logger();

/// Practice State
class PracticeState {
  final PracticeSessionModel? currentSession;
  final List<ProblemModel> problems;
  final int currentProblemIndex;
  final bool isLoading;
  final String? error;

  const PracticeState({
    this.currentSession,
    this.problems = const [],
    this.currentProblemIndex = 0,
    this.isLoading = false,
    this.error,
  });

  PracticeState copyWith({
    PracticeSessionModel? currentSession,
    List<ProblemModel>? problems,
    int? currentProblemIndex,
    bool? isLoading,
    String? error,
  }) {
    return PracticeState(
      currentSession: currentSession ?? this.currentSession,
      problems: problems ?? this.problems,
      currentProblemIndex: currentProblemIndex ?? this.currentProblemIndex,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  /// Get current problem
  ProblemModel? get currentProblem {
    if (currentProblemIndex < 0 || currentProblemIndex >= problems.length) {
      return null;
    }
    return problems[currentProblemIndex];
  }

  /// Check if this is the last problem
  bool get isLastProblem => currentProblemIndex >= problems.length - 1;

  /// Get progress
  double get progress {
    if (problems.isEmpty) return 0.0;
    return (currentProblemIndex + 1) / problems.length;
  }

  /// Check if session is active
  bool get hasActiveSession =>
      currentSession != null && currentSession!.isActive;
}

/// Practice Notifier
class PracticeNotifier extends StateNotifier<PracticeState> {
  final Ref _ref;
  final String userId;

  PracticeNotifier(this._ref, this.userId) : super(const PracticeState());

  /// Start a new practice session
  Future<void> startSession({
    required PracticeMode mode,
    String? lessonId,
    String? unitId,
    int? problemCount,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final lessonAPI = _ref.read(lessonAPIProvider);

      // Start session via API
      final sessionData = await lessonAPI.startPracticeSession(
        userId: userId,
        mode: mode.name,
        lessonId: lessonId,
        unitId: unitId,
        problemCount: problemCount,
      );

      final session =
          PracticeSessionModel.fromJson(sessionData['session']);
      final problemsData = sessionData['problems'] as List;
      final problems = problemsData
          .map((data) => ProblemModel.fromJson(data))
          .toList();

      state = state.copyWith(
        currentSession: session,
        problems: problems,
        currentProblemIndex: 0,
        isLoading: false,
      );

      logger.i(
          'Started practice session: ${session.id} with ${problems.length} problems');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      logger.e('Failed to start practice session: $e');
    }
  }

  /// Submit answer for current problem
  Future<bool> submitAnswer({
    required String answer,
    required int timeTaken,
    int hintUsed = 0,
  }) async {
    if (state.currentSession == null || state.currentProblem == null) {
      return false;
    }

    try {
      final lessonAPI = _ref.read(lessonAPIProvider);

      // Submit answer via API
      final result = await lessonAPI.submitPracticeAnswer(
        sessionId: state.currentSession!.id,
        problemId: state.currentProblem!.id,
        answer: answer,
        timeTaken: timeTaken,
        hintUsed: hintUsed,
      );

      final isCorrect = result['isCorrect'] as bool;

      // Create attempt
      final attempt = PracticeProblemAttempt(
        problemId: state.currentProblem!.id,
        userAnswer: answer,
        isCorrect: isCorrect,
        timeTaken: timeTaken,
        attemptTime: DateTime.now(),
        hintUsed: hintUsed,
      );

      // Update session with new attempt
      final updatedAttempts = [...state.currentSession!.attempts, attempt];
      final updatedStats =
          PracticeSessionStats.fromAttempts(updatedAttempts);

      final updatedSession = state.currentSession!.copyWith(
        attempts: updatedAttempts,
        stats: updatedStats,
      );

      state = state.copyWith(currentSession: updatedSession);

      logger.i('Submitted practice answer: ${isCorrect ? "correct" : "incorrect"}');

      return isCorrect;
    } catch (e) {
      logger.e('Failed to submit practice answer: $e');
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Move to next problem
  void nextProblem() {
    if (!state.isLastProblem) {
      state = state.copyWith(
        currentProblemIndex: state.currentProblemIndex + 1,
      );
    }
  }

  /// End current session
  Future<void> endSession() async {
    if (state.currentSession == null) return;

    try {
      final lessonAPI = _ref.read(lessonAPIProvider);

      // End session via API
      await lessonAPI.endPracticeSession(
        sessionId: state.currentSession!.id,
      );

      final updatedSession = state.currentSession!.copyWith(
        endTime: DateTime.now(),
      );

      state = state.copyWith(currentSession: updatedSession);

      logger.i('Ended practice session: ${state.currentSession!.id}');
    } catch (e) {
      logger.e('Failed to end practice session: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  /// Reset practice state
  void reset() {
    state = const PracticeState();
  }

  /// Go to specific problem
  void goToProblem(int index) {
    if (index >= 0 && index < state.problems.length) {
      state = state.copyWith(currentProblemIndex: index);
    }
  }
}

/// Practice Provider
final practiceProvider =
    StateNotifierProvider.family<PracticeNotifier, PracticeState, String>(
  (ref, userId) => PracticeNotifier(ref, userId),
);

/// Practice History Provider
final practiceHistoryProvider =
    FutureProvider.family<List<PracticeSessionModel>, String>(
  (ref, userId) async {
    final lessonAPI = ref.watch(lessonAPIProvider);

    try {
      final historyData =
          await lessonAPI.getPracticeHistory(userId: userId);

      return (historyData as List)
          .map((data) => PracticeSessionModel.fromJson(data))
          .toList();
    } catch (e) {
      logger.e('Failed to load practice history: $e');
      return [];
    }
  },
);
