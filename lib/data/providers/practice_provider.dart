import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/local_storage_service.dart';
import '../services/mock_data_service.dart';
import 'error_note_provider.dart';
import 'user_provider.dart';
import '../../shared/utils/logger.dart';

/// 연습 모드 상태
class PracticeState {
  final PracticeSession? currentSession;
  final bool isSessionActive;
  final Map<String, int> categoryStats; // 카테고리별 연습 통계

  const PracticeState({
    this.currentSession,
    this.isSessionActive = false,
    this.categoryStats = const {},
  });

  PracticeState copyWith({
    PracticeSession? currentSession,
    bool? isSessionActive,
    Map<String, int>? categoryStats,
  }) {
    return PracticeState(
      currentSession: currentSession ?? this.currentSession,
      isSessionActive: isSessionActive ?? this.isSessionActive,
      categoryStats: categoryStats ?? this.categoryStats,
    );
  }

  /// 진행률 (0.0 ~ 1.0)
  double get progress => currentSession?.progress ?? 0.0;

  /// 현재 문제
  Problem? get currentProblem => currentSession?.currentProblem;

  /// 정답률
  double get accuracy => currentSession?.accuracy ?? 0.0;
}

/// 연습 모드 Provider
class PracticeProvider extends StateNotifier<PracticeState> {
  final Ref _ref;
  final LocalStorageService _storage = LocalStorageService();
  final MockDataService _dataService = MockDataService();

  static const String _storageKey = 'practice_state';
  static const String _statsKey = 'practice_stats';

  PracticeProvider(this._ref) : super(const PracticeState()) {
    _loadState();
    _loadStats();
  }

  /// 상태 로드
  Future<void> _loadState() async {
    try {
      final data = await _storage.loadMap(_storageKey);
      if (data != null && data['currentSession'] != null) {
        final session = PracticeSession.fromJson(
          data['currentSession'] as Map<String, dynamic>,
        );

        state = state.copyWith(
          currentSession: session,
          isSessionActive: !session.isCompleted,
        );

        Logger.info('Practice state loaded', tag: 'PracticeProvider');
      }
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to load practice state',
        error: e,
        stackTrace: stackTrace,
        tag: 'PracticeProvider',
      );
    }
  }

  /// 통계 로드
  Future<void> _loadStats() async {
    try {
      final data = await _storage.loadMap(_statsKey);
      if (data != null) {
        state = state.copyWith(
          categoryStats: Map<String, int>.from(data),
        );
        Logger.info('Practice stats loaded', tag: 'PracticeProvider');
      }
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to load practice stats',
        error: e,
        stackTrace: stackTrace,
        tag: 'PracticeProvider',
      );
    }
  }

  /// 상태 저장
  Future<void> _saveState() async {
    try {
      await _storage.saveMap(_storageKey, {
        'currentSession': state.currentSession?.toJson(),
      });
      Logger.debug('Practice state saved', tag: 'PracticeProvider');
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to save practice state',
        error: e,
        stackTrace: stackTrace,
        tag: 'PracticeProvider',
      );
    }
  }

  /// 통계 저장
  Future<void> _saveStats() async {
    try {
      await _storage.saveMap(_statsKey, state.categoryStats);
      Logger.debug('Practice stats saved', tag: 'PracticeProvider');
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to save practice stats',
        error: e,
        stackTrace: stackTrace,
        tag: 'PracticeProvider',
      );
    }
  }

  /// 새 연습 세션 시작 (카테고리별)
  Future<void> startCategoryPractice(PracticeCategory category) async {
    final problems = _generateProblemsForCategory(category);

    final session = PracticeSession(
      id: 'practice_${DateTime.now().millisecondsSinceEpoch}',
      category: category.displayName,
      problems: problems,
      startedAt: DateTime.now(),
    );

    state = state.copyWith(
      currentSession: session,
      isSessionActive: true,
    );

    await _saveState();

    Logger.info(
      'Started ${category.displayName} practice with ${problems.length} problems',
      tag: 'PracticeProvider',
    );
  }

  /// 오답 노트 연습 시작
  Future<void> startErrorNotePractice() async {
    final errorNotes = _ref.read(errorNoteProvider);

    if (errorNotes.isEmpty) {
      Logger.warning('No error notes available', tag: 'PracticeProvider');
      return;
    }

    // 오답 노트에서 문제 재구성
    final problems = errorNotes.map((note) => Problem(
      id: note.problemId,
      lessonId: note.lessonId,
      question: note.question,
      type: ProblemType.multipleChoice, // 기본 타입
      explanation: note.explanation,
      category: note.category,
      difficulty: note.difficulty,
      tags: note.tags,
      xpReward: note.difficulty * 5, // 난이도 기반 XP
      correctAnswer: note.correctAnswer,
    )).toList();

    final session = PracticeSession(
      id: 'practice_error_${DateTime.now().millisecondsSinceEpoch}',
      category: '오답 노트',
      problems: problems,
      startedAt: DateTime.now(),
    );

    state = state.copyWith(
      currentSession: session,
      isSessionActive: true,
    );

    await _saveState();

    Logger.info(
      'Started error note practice with ${problems.length} problems',
      tag: 'PracticeProvider',
    );
  }

  /// 카테고리별 문제 생성
  List<Problem> _generateProblemsForCategory(PracticeCategory category) {
    switch (category) {
      case PracticeCategory.basicArithmetic:
        return _dataService.generateBasicArithmeticProblems(10);
      case PracticeCategory.algebra:
        return _dataService.generateAlgebraProblems(10);
      case PracticeCategory.geometry:
        return _dataService.generateGeometryProblems(10);
      case PracticeCategory.statistics:
        return _dataService.generateStatisticsProblems(10);
      case PracticeCategory.errorNote:
        return []; // 오답 노트는 별도 처리
    }
  }

  /// 답변 제출
  Future<void> submitAnswer(String answer) async {
    if (state.currentSession == null || state.currentProblem == null) {
      return;
    }

    final session = state.currentSession!;
    final problem = state.currentProblem!;

    // Null-safety 처리: correctAnswer가 null이면 오답 처리
    final isCorrect = problem.correctAnswer != null &&
                      answer.trim().toLowerCase() ==
                      problem.correctAnswer!.trim().toLowerCase();

    // 정답 시 경험치 부여
    if (isCorrect && problem.xpReward > 0) {
      await _ref.read(userProvider.notifier).addXP(problem.xpReward);
      Logger.info('XP +${problem.xpReward} 획득 (연습 모드)', tag: 'PracticeProvider');
    }

    // 통계 업데이트
    final newSession = session.copyWith(
      currentProblemIndex: session.currentProblemIndex + 1,
      correctCount: isCorrect
          ? session.correctCount + 1
          : session.correctCount,
      incorrectCount: !isCorrect
          ? session.incorrectCount + 1
          : session.incorrectCount,
    );

    // 세션 완료 확인
    final isLastProblem = newSession.currentProblemIndex >= session.problems.length;
    final completedSession = isLastProblem
        ? newSession.copyWith(
            isCompleted: true,
            completedAt: DateTime.now(),
          )
        : newSession;

    state = state.copyWith(
      currentSession: completedSession,
      isSessionActive: !isLastProblem,
    );

    await _saveState();

    // 세션 완료 시 통계 업데이트
    if (isLastProblem) {
      await _updateCategoryStats(session.category);
    }

    Logger.info(
      'Answer submitted: ${isCorrect ? "Correct" : "Incorrect"}, '
      'Progress: ${newSession.currentProblemIndex}/${session.problems.length}',
      tag: 'PracticeProvider',
    );
  }

  /// 문제 건너뛰기
  Future<void> skipProblem() async {
    if (state.currentSession == null) return;

    final session = state.currentSession!;
    final newSession = session.copyWith(
      currentProblemIndex: session.currentProblemIndex + 1,
      skippedCount: session.skippedCount + 1,
    );

    // 세션 완료 확인
    final isLastProblem = newSession.currentProblemIndex >= session.problems.length;
    final completedSession = isLastProblem
        ? newSession.copyWith(
            isCompleted: true,
            completedAt: DateTime.now(),
          )
        : newSession;

    state = state.copyWith(
      currentSession: completedSession,
      isSessionActive: !isLastProblem,
    );

    await _saveState();

    if (isLastProblem) {
      await _updateCategoryStats(session.category);
    }

    Logger.info('Problem skipped', tag: 'PracticeProvider');
  }

  /// 카테고리별 통계 업데이트
  Future<void> _updateCategoryStats(String category) async {
    final newStats = Map<String, int>.from(state.categoryStats);
    newStats[category] = (newStats[category] ?? 0) + 1;

    state = state.copyWith(categoryStats: newStats);
    await _saveStats();

    Logger.info(
      'Category stats updated: $category completed ${newStats[category]} times',
      tag: 'PracticeProvider',
    );
  }

  /// 세션 종료
  Future<void> endSession() async {
    if (state.currentSession != null) {
      final session = state.currentSession!;
      await _updateCategoryStats(session.category);
    }

    state = state.copyWith(
      currentSession: null,
      isSessionActive: false,
    );

    await _saveState();
    Logger.info('Practice session ended', tag: 'PracticeProvider');
  }

  /// 세션 재시작
  Future<void> resetSession() async {
    state = const PracticeState();
    await _storage.remove(_storageKey);
    Logger.info('Practice session reset', tag: 'PracticeProvider');
  }

  /// 특정 카테고리 통계 조회
  int getCategoryCount(String category) {
    return state.categoryStats[category] ?? 0;
  }
}

/// Provider 정의
final practiceProvider =
    StateNotifierProvider<PracticeProvider, PracticeState>((ref) {
  return PracticeProvider(ref);
});

/// 편의 프로바이더
final isPracticingProvider = Provider<bool>((ref) {
  final state = ref.watch(practiceProvider);
  return state.isSessionActive;
});

final currentPracticeProblemProvider = Provider<Problem?>((ref) {
  final state = ref.watch(practiceProvider);
  return state.currentProblem;
});

final practiceProgressProvider = Provider<double>((ref) {
  final state = ref.watch(practiceProvider);
  return state.progress;
});
