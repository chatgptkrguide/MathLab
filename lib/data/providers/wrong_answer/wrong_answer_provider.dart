// 📝 Wrong Answer Provider
//
// Manages wrong answer state and operations with Firestore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/error/app_error.dart';
import '../../../core/utils/app_logger.dart';
import '../../models/wrong_answer_model.dart';

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

/// Wrong Answer Notifier - Firestore 직접 연동
class WrongAnswerNotifier extends StateNotifier<WrongAnswerState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;

  WrongAnswerNotifier(this.userId) : super(const WrongAnswerState()) {
    loadWrongAnswers();
  }

  /// Firestore 컬렉션 참조
  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('users').doc(userId).collection('wrongAnswers');

  /// Load all wrong answers for the user
  Future<void> loadWrongAnswers() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final snapshot = await _collection
          .orderBy('attemptDate', descending: true)
          .get();

      final wrongAnswers = snapshot.docs
          .map((doc) => WrongAnswerModel.fromFirestore(doc))
          .toList();

      state = state.copyWith(
        wrongAnswers: wrongAnswers,
        filteredAnswers: _applyFilter(wrongAnswers, state.currentFilter),
        isLoading: false,
      );

      AppLogger.info('Loaded ${wrongAnswers.length} wrong answers from Firestore');
    } catch (e, stackTrace) {
      final appError = AppErrorHandler.handle(e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: appError.userMessage,
      );
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

  /// Add a wrong answer to Firestore
  Future<void> addWrongAnswer(WrongAnswerModel wrongAnswer) async {
    try {
      final docRef = await _collection.add(wrongAnswer.toFirestore());

      final newWrongAnswer = wrongAnswer.copyWith(id: docRef.id);
      final updatedAnswers = [newWrongAnswer, ...state.wrongAnswers];

      state = state.copyWith(
        wrongAnswers: updatedAnswers,
        filteredAnswers: _applyFilter(updatedAnswers, state.currentFilter),
      );

      AppLogger.info('Added wrong answer: ${docRef.id}');
    } catch (e, stackTrace) {
      final appError = AppErrorHandler.handle(e, stackTrace);
      state = state.copyWith(error: appError.userMessage);
    }
  }

  /// Retry a wrong answer
  Future<void> retryWrongAnswer(String wrongAnswerId) async {
    try {
      await _collection.doc(wrongAnswerId).update({
        'isRetried': true,
        'attemptCount': FieldValue.increment(1),
      });

      // Update local state
      final updatedAnswers = state.wrongAnswers.map((w) {
        if (w.id == wrongAnswerId) {
          return w.copyWith(
            isRetried: true,
            attemptCount: w.attemptCount + 1,
          );
        }
        return w;
      }).toList();

      state = state.copyWith(
        wrongAnswers: updatedAnswers,
        filteredAnswers: _applyFilter(updatedAnswers, state.currentFilter),
      );

      AppLogger.info('Retried wrong answer: $wrongAnswerId');
    } catch (e, stackTrace) {
      final appError = AppErrorHandler.handle(e, stackTrace);
      state = state.copyWith(error: appError.userMessage);
    }
  }

  /// Mark wrong answer as resolved
  Future<void> markAsResolved(String wrongAnswerId) async {
    try {
      await _collection.doc(wrongAnswerId).update({
        'isResolved': true,
        'resolvedDate': Timestamp.now(),
      });

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

      AppLogger.info('Marked wrong answer as resolved: $wrongAnswerId');
    } catch (e, stackTrace) {
      final appError = AppErrorHandler.handle(e, stackTrace);
      state = state.copyWith(error: appError.userMessage);
    }
  }

  /// Delete a wrong answer
  Future<void> deleteWrongAnswer(String wrongAnswerId) async {
    try {
      await _collection.doc(wrongAnswerId).delete();

      final updatedAnswers =
          state.wrongAnswers.where((w) => w.id != wrongAnswerId).toList();

      state = state.copyWith(
        wrongAnswers: updatedAnswers,
        filteredAnswers: _applyFilter(updatedAnswers, state.currentFilter),
      );

      AppLogger.info('Deleted wrong answer: $wrongAnswerId');
    } catch (e, stackTrace) {
      final appError = AppErrorHandler.handle(e, stackTrace);
      state = state.copyWith(error: appError.userMessage);
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

/// Wrong Answer Provider - Firestore 직접 연동
final wrongAnswerProvider = StateNotifierProvider.family<
    WrongAnswerNotifier,
    WrongAnswerState,
    String>(
  (ref, userId) => WrongAnswerNotifier(userId),
);
