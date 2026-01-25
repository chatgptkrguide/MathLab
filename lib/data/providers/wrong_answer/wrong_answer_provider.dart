/// 📝 Wrong Answer Provider
///
/// Manages wrong answer state and operations

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../models/wrong_answer_model.dart';
import '../api_provider.dart';

final logger = Logger();

/// Wrong Answer State
class WrongAnswerState {
  final List<WrongAnswerModel> wrongAnswers;
  final List<WrongAnswerModel> filteredAnswers;
  final WrongAnswerFilter currentFilter;
  final bool isLoading;
  final String? error;

  const WrongAnswerState({
    this.wrongAnswers = const [],
    this.filteredAnswers = const [],
    this.currentFilter = WrongAnswerFilter.all,
    this.isLoading = false,
    this.error,
  });

  WrongAnswerState copyWith({
    List<WrongAnswerModel>? wrongAnswers,
    List<WrongAnswerModel>? filteredAnswers,
    WrongAnswerFilter? currentFilter,
    bool? isLoading,
    String? error,
  }) {
    return WrongAnswerState(
      wrongAnswers: wrongAnswers ?? this.wrongAnswers,
      filteredAnswers: filteredAnswers ?? this.filteredAnswers,
      currentFilter: currentFilter ?? this.currentFilter,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  /// Get statistics
  Map<String, int> get statistics {
    return {
      'total': wrongAnswers.length,
      'unresolved': wrongAnswers.where((w) => !w.isResolved).length,
      'needsReview': wrongAnswers.where((w) => w.shouldReview()).length,
      'resolved': wrongAnswers.where((w) => w.isResolved).length,
    };
  }
}

/// Filter options for wrong answers
enum WrongAnswerFilter {
  all,
  unresolved,
  needsReview,
  resolved,
}

/// Wrong Answer Notifier
class WrongAnswerNotifier extends StateNotifier<WrongAnswerState> {
  final Ref _ref;
  final String userId;

  WrongAnswerNotifier(this._ref, this.userId)
      : super(const WrongAnswerState()) {
    loadWrongAnswers();
  }

  /// Load all wrong answers for the user
  Future<void> loadWrongAnswers() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final lessonAPI = _ref.read(lessonAPIProvider);

      final wrongAnswersData = await lessonAPI.getWrongAnswers(userId: userId);

      final wrongAnswers = (wrongAnswersData as List)
          .map((data) => WrongAnswerModel.fromJson(data))
          .toList();

      // Sort by date (most recent first)
      wrongAnswers.sort((a, b) => b.attemptDate.compareTo(a.attemptDate));

      state = state.copyWith(
        wrongAnswers: wrongAnswers,
        filteredAnswers: _applyFilter(wrongAnswers, state.currentFilter),
        isLoading: false,
      );

      logger.i('Loaded ${wrongAnswers.length} wrong answers');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      logger.e('Failed to load wrong answers: $e');
    }
  }

  /// Apply filter to wrong answers
  List<WrongAnswerModel> _applyFilter(
    List<WrongAnswerModel> answers,
    WrongAnswerFilter filter,
  ) {
    switch (filter) {
      case WrongAnswerFilter.all:
        return answers;
      case WrongAnswerFilter.unresolved:
        return answers.where((w) => !w.isResolved).toList();
      case WrongAnswerFilter.needsReview:
        return answers.where((w) => w.shouldReview()).toList();
      case WrongAnswerFilter.resolved:
        return answers.where((w) => w.isResolved).toList();
    }
  }

  /// Change filter
  void setFilter(WrongAnswerFilter filter) {
    state = state.copyWith(
      currentFilter: filter,
      filteredAnswers: _applyFilter(state.wrongAnswers, filter),
    );
  }

  /// Retry a wrong answer
  Future<void> retryWrongAnswer(String wrongAnswerId) async {
    try {
      final lessonAPI = _ref.read(lessonAPIProvider);

      await lessonAPI.retryWrongAnswer(
        userId: userId,
        wrongAnswerId: wrongAnswerId,
      );

      // Update local state
      final updatedAnswers = state.wrongAnswers.map((w) {
        if (w.id == wrongAnswerId) {
          return w.copyWith(isRetried: true);
        }
        return w;
      }).toList();

      state = state.copyWith(
        wrongAnswers: updatedAnswers,
        filteredAnswers: _applyFilter(updatedAnswers, state.currentFilter),
      );

      logger.i('Retried wrong answer: $wrongAnswerId');
    } catch (e) {
      logger.e('Failed to retry wrong answer: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  /// Mark wrong answer as resolved
  Future<void> markAsResolved(String wrongAnswerId) async {
    try {
      final lessonAPI = _ref.read(lessonAPIProvider);

      await lessonAPI.resolveWrongAnswer(
        userId: userId,
        wrongAnswerId: wrongAnswerId,
      );

      // Update local state
      final updatedAnswers = state.wrongAnswers.map((w) {
        if (w.id == wrongAnswerId) {
          return w.copyWith(
            isResolved: true,
            resolvedDate: DateTime.now(),
          );
        }
        return w;
      }).toList();

      state = state.copyWith(
        wrongAnswers: updatedAnswers,
        filteredAnswers: _applyFilter(updatedAnswers, state.currentFilter),
      );

      logger.i('Marked wrong answer as resolved: $wrongAnswerId');
    } catch (e) {
      logger.e('Failed to mark as resolved: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  /// Group wrong answers by lesson
  Map<String, List<WrongAnswerModel>> groupByLesson() {
    final grouped = <String, List<WrongAnswerModel>>{};

    for (var answer in state.filteredAnswers) {
      if (!grouped.containsKey(answer.lessonName)) {
        grouped[answer.lessonName] = [];
      }
      grouped[answer.lessonName]!.add(answer);
    }

    return grouped;
  }

  /// Group wrong answers by unit
  Map<String, List<WrongAnswerModel>> groupByUnit() {
    final grouped = <String, List<WrongAnswerModel>>{};

    for (var answer in state.filteredAnswers) {
      if (!grouped.containsKey(answer.unitName)) {
        grouped[answer.unitName] = [];
      }
      grouped[answer.unitName]!.add(answer);
    }

    return grouped;
  }
}

/// Wrong Answer Provider
final wrongAnswerProvider = StateNotifierProvider.family<
    WrongAnswerNotifier,
    WrongAnswerState,
    String>(
  (ref, userId) => WrongAnswerNotifier(ref, userId),
);
