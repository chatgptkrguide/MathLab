import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/mock_data_service.dart';
import 'error_note_provider.dart';
import 'user_provider.dart';
import 'base/base_notifier.dart';

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

/// 연습 모드 Provider (BaseNotifier 최적화 버전)
///
/// **개선사항:**
/// - BaseNotifier 상속으로 중복 로깅 제거
/// - executeWithErrorHandling로 try-catch 자동화
/// - LocalStorageService 상속으로 필드 제거
class PracticeProvider extends BaseNotifier<PracticeState> {
  final Ref _ref;
  final MockDataService _dataService = MockDataService();

  static const String _storageKey = 'practice_state';
  static const String _statsKey = 'practice_stats';

  PracticeProvider(this._ref) : super(const PracticeState(), 'PracticeProvider') {
    _loadState();
    _loadStats();
  }

  /// 상태 로드
  Future<void> _loadState() async {
    await executeWithErrorHandling(
      () async {
        final data = await loadFromStorage(_storageKey);
        if (data != null && data['currentSession'] != null) {
          final session = PracticeSession.fromJson(
            data['currentSession'] as Map<String, dynamic>,
          );

          state = state.copyWith(
            currentSession: session,
            isSessionActive: !session.isCompleted,
          );

          logInfo('연습 모드 상태 로드 완료');
        }
      },
      errorMessage: '연습 모드 상태 로드 실패',
    );
  }

  /// 통계 로드
  Future<void> _loadStats() async {
    await executeWithErrorHandling(
      () async {
        final data = await loadFromStorage(_statsKey);
        if (data != null) {
          state = state.copyWith(
            categoryStats: Map<String, int>.from(data),
          );
          logInfo('연습 모드 통계 로드 완료');
        }
      },
      errorMessage: '연습 모드 통계 로드 실패',
    );
  }

  /// 상태 저장
  Future<void> _saveState() async {
    await executeWithErrorHandling(
      () async {
        await saveToStorage(_storageKey, {
          'currentSession': state.currentSession?.toJson(),
        });
        logDebug('연습 모드 상태 저장 완료');
      },
      errorMessage: '연습 모드 상태 저장 실패',
    );
  }

  /// 통계 저장
  Future<void> _saveStats() async {
    await executeWithErrorHandling(
      () async {
        await saveToStorage(_statsKey, state.categoryStats);
        logDebug('연습 모드 통계 저장 완료');
      },
      errorMessage: '연습 모드 통계 저장 실패',
    );
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

    logInfo('${category.displayName} 연습 시작: ${problems.length}문제');
  }

  /// 오답 노트 연습 시작
  Future<void> startErrorNotePractice() async {
    final errorNotes = _ref.read(errorNoteProvider);

    if (errorNotes.isEmpty) {
      logWarning('오답 노트 없음');
      return;
    }

    // 오답 노트에서 문제 재구성
    final problems = errorNotes.map((note) => Problem(
      id: note.problemId,
      title: note.category,
      question: note.question,
      type: ProblemType.multipleChoice, // 기본 타입
      explanation: note.explanation,
      category: note.category,
      difficulty: note.difficulty,
      answer: note.correctAnswer,
      metadata: {
        'lessonId': note.lessonId,
        'tags': note.tags,
        'xpReward': note.difficulty * 5, // 난이도 기반 XP
      },
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

    logInfo('오답 노트 연습 시작: ${problems.length}문제');
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
      logInfo('XP +${problem.xpReward} 획득 (연습 모드)');
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

    logInfo(
      '답변 제출: ${isCorrect ? "정답" : "오답"}, '
      '진행률: ${newSession.currentProblemIndex}/${session.problems.length}',
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

    logInfo('문제 건너뛰기');
  }

  /// 카테고리별 통계 업데이트
  Future<void> _updateCategoryStats(String category) async {
    final newStats = Map<String, int>.from(state.categoryStats);
    newStats[category] = (newStats[category] ?? 0) + 1;

    state = state.copyWith(categoryStats: newStats);
    await _saveStats();

    logInfo('카테고리 통계 업데이트: $category ${newStats[category]}회 완료');
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
    logInfo('연습 세션 종료');
  }

  /// 세션 재시작
  Future<void> resetSession() async {
    await executeWithErrorHandling(
      () async {
        state = const PracticeState();
        await removeFromStorage(_storageKey);
        logInfo('연습 세션 초기화');
      },
      errorMessage: '연습 세션 초기화 실패',
    );
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
