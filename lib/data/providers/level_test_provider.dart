import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/level_test.dart';
import '../models/user.dart';
import 'user_provider.dart';
import '../../shared/utils/logger.dart';
import '../services/local_storage_service.dart';

/// 레벨 테스트 상태
class LevelTestState {
  final LevelTest? currentTest;
  final int currentQuestionIndex;
  final bool isCompleted;
  final LevelTestResult? result;

  const LevelTestState({
    this.currentTest,
    this.currentQuestionIndex = 0,
    this.isCompleted = false,
    this.result,
  });

  LevelTestState copyWith({
    LevelTest? currentTest,
    int? currentQuestionIndex,
    bool? isCompleted,
    LevelTestResult? result,
  }) {
    return LevelTestState(
      currentTest: currentTest ?? this.currentTest,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      isCompleted: isCompleted ?? this.isCompleted,
      result: result ?? this.result,
    );
  }

  /// 진행률 (0.0 ~ 1.0)
  double get progress {
    if (currentTest == null || currentTest!.questions.isEmpty) return 0.0;
    return currentQuestionIndex / currentTest!.questions.length;
  }

  /// 현재 문제
  LevelTestQuestion? get currentQuestion {
    if (currentTest == null ||
        currentQuestionIndex >= currentTest!.questions.length) {
      return null;
    }
    return currentTest!.questions[currentQuestionIndex];
  }

  /// 답변한 문제 수
  int get answeredCount {
    if (currentTest == null) return 0;
    return currentTest!.questions.where((q) => q.userAnswerIndex != null).length;
  }
}

/// 레벨 테스트 Provider
class LevelTestProvider extends StateNotifier<LevelTestState> {
  final Ref _ref;
  final LocalStorageService _storage = LocalStorageService();

  static const String _storageKey = 'level_test_state';

  LevelTestProvider(this._ref) : super(const LevelTestState()) {
    _loadState();
  }

  /// 상태 로드
  Future<void> _loadState() async {
    try {
      final data = await _storage.loadMap(_storageKey);
      if (data != null) {
        final testData = data['currentTest'] as Map<String, dynamic>?;
        if (testData != null) {
          final test = LevelTest.fromJson(testData);
          state = state.copyWith(
            currentTest: test,
            currentQuestionIndex: data['currentQuestionIndex'] ?? 0,
            isCompleted: data['isCompleted'] ?? false,
          );

          Logger.info(
            'Level test state loaded',
            tag: 'LevelTestProvider',
          );
        }
      }
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to load level test state',
        error: e,
        stackTrace: stackTrace,
        tag: 'LevelTestProvider',
      );
    }
  }

  /// 상태 저장
  Future<void> _saveState() async {
    try {
      await _storage.saveMap(_storageKey, {
        'currentTest': state.currentTest?.toJson(),
        'currentQuestionIndex': state.currentQuestionIndex,
        'isCompleted': state.isCompleted,
      });

      Logger.debug('Level test state saved', tag: 'LevelTestProvider');
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to save level test state',
        error: e,
        stackTrace: stackTrace,
        tag: 'LevelTestProvider',
      );
    }
  }

  /// 새 레벨 테스트 시작
  Future<void> startNewTest() async {
    final questions = _generateTestQuestions();
    final test = LevelTest(
      id: 'level_test_${DateTime.now().millisecondsSinceEpoch}',
      questions: questions,
      createdAt: DateTime.now(),
    );

    state = LevelTestState(
      currentTest: test,
      currentQuestionIndex: 0,
      isCompleted: false,
    );

    await _saveState();
    Logger.info('New level test started', tag: 'LevelTestProvider');
  }

  /// 테스트 문제 생성 (10문제)
  List<LevelTestQuestion> _generateTestQuestions() {
    return [
      // 쉬운 문제 (난이도 1-2)
      LevelTestQuestion(
        id: 'q1',
        question: '3 + 5 = ?',
        options: ['6', '7', '8', '9'],
        correctAnswerIndex: 2,
        difficulty: 1,
        category: '기초산술',
      ),
      LevelTestQuestion(
        id: 'q2',
        question: '12 - 7 = ?',
        options: ['3', '4', '5', '6'],
        correctAnswerIndex: 2,
        difficulty: 1,
        category: '기초산술',
      ),
      LevelTestQuestion(
        id: 'q3',
        question: '6 × 4 = ?',
        options: ['20', '22', '24', '26'],
        correctAnswerIndex: 2,
        difficulty: 2,
        category: '기초산술',
      ),
      LevelTestQuestion(
        id: 'q4',
        question: '15 ÷ 3 = ?',
        options: ['3', '4', '5', '6'],
        correctAnswerIndex: 2,
        difficulty: 2,
        category: '기초산술',
      ),
      // 보통 문제 (난이도 3)
      LevelTestQuestion(
        id: 'q5',
        question: '2 × (5 + 3) = ?',
        options: ['13', '14', '15', '16'],
        correctAnswerIndex: 3,
        difficulty: 3,
        category: '기초산술',
      ),
      LevelTestQuestion(
        id: 'q6',
        question: '1/2 + 1/4 = ?',
        options: ['1/4', '2/4', '3/4', '4/4'],
        correctAnswerIndex: 2,
        difficulty: 3,
        category: '분수',
      ),
      LevelTestQuestion(
        id: 'q7',
        question: 'x + 5 = 12일 때, x = ?',
        options: ['5', '6', '7', '8'],
        correctAnswerIndex: 2,
        difficulty: 3,
        category: '대수',
      ),
      // 어려운 문제 (난이도 4-5)
      LevelTestQuestion(
        id: 'q8',
        question: '3x - 7 = 11일 때, x = ?',
        options: ['4', '5', '6', '7'],
        correctAnswerIndex: 2,
        difficulty: 4,
        category: '대수',
      ),
      LevelTestQuestion(
        id: 'q9',
        question: '(2 + 3) × 4 - 6 = ?',
        options: ['12', '14', '16', '18'],
        correctAnswerIndex: 1,
        difficulty: 4,
        category: '기초산술',
      ),
      LevelTestQuestion(
        id: 'q10',
        question: '√16 + √9 = ?',
        options: ['5', '6', '7', '8'],
        correctAnswerIndex: 2,
        difficulty: 5,
        category: '기하',
      ),
    ];
  }

  /// 답변 제출
  Future<void> submitAnswer(int answerIndex) async {
    if (state.currentTest == null || state.currentQuestion == null) {
      return;
    }

    final currentQ = state.currentQuestion!;
    final isCorrect = answerIndex == currentQ.correctAnswerIndex;

    // 현재 문제 업데이트
    final updatedQuestions = List<LevelTestQuestion>.from(state.currentTest!.questions);
    updatedQuestions[state.currentQuestionIndex] = currentQ.copyWith(
      userAnswerIndex: answerIndex,
      isCorrect: isCorrect,
    );

    final updatedTest = state.currentTest!.copyWith(questions: updatedQuestions);

    // 다음 문제로 이동 or 완료
    final nextIndex = state.currentQuestionIndex + 1;
    final isLastQuestion = nextIndex >= updatedTest.questions.length;

    if (isLastQuestion) {
      // 테스트 완료
      await _completeTest(updatedTest);
    } else {
      // 다음 문제로
      state = state.copyWith(
        currentTest: updatedTest,
        currentQuestionIndex: nextIndex,
      );
      await _saveState();
    }

    Logger.info(
      'Answer submitted: Q${state.currentQuestionIndex + 1}, correct: $isCorrect',
      tag: 'LevelTestProvider',
    );
  }

  /// 테스트 완료 처리
  Future<void> _completeTest(LevelTest test) async {
    final result = _calculateResult(test);

    // UserProvider에 레벨 업데이트
    await _ref.read(userProvider.notifier).setLevel(result.recommendedLevel);

    state = state.copyWith(
      currentTest: test.copyWith(
        isCompleted: true,
        finalLevel: result.recommendedLevel,
        accuracy: result.accuracy,
      ),
      isCompleted: true,
      result: result,
    );

    await _saveState();

    Logger.info(
      'Level test completed: Level ${result.recommendedLevel}, Accuracy: ${(result.accuracy * 100).toStringAsFixed(1)}%',
      tag: 'LevelTestProvider',
    );
  }

  /// 결과 계산
  LevelTestResult _calculateResult(LevelTest test) {
    final totalQuestions = test.questions.length;
    final correctAnswers = test.questions.where((q) => q.isCorrect == true).length;
    final accuracy = correctAnswers / totalQuestions;

    // 카테고리별 점수
    final categoryScores = <String, int>{};
    for (final question in test.questions) {
      if (question.category != null && question.isCorrect == true) {
        categoryScores[question.category!] =
            (categoryScores[question.category!] ?? 0) + 1;
      }
    }

    // 레벨 결정 (정답률 기반)
    int recommendedLevel;
    if (accuracy >= 0.9) {
      recommendedLevel = 10; // 완벽
    } else if (accuracy >= 0.8) {
      recommendedLevel = 8;
    } else if (accuracy >= 0.7) {
      recommendedLevel = 7;
    } else if (accuracy >= 0.6) {
      recommendedLevel = 6;
    } else if (accuracy >= 0.5) {
      recommendedLevel = 5;
    } else if (accuracy >= 0.4) {
      recommendedLevel = 4;
    } else if (accuracy >= 0.3) {
      recommendedLevel = 3;
    } else if (accuracy >= 0.2) {
      recommendedLevel = 2;
    } else {
      recommendedLevel = 1;
    }

    return LevelTestResult(
      totalQuestions: totalQuestions,
      correctAnswers: correctAnswers,
      accuracy: accuracy,
      recommendedLevel: recommendedLevel,
      categoryScores: categoryScores,
    );
  }

  /// 테스트 재시작
  Future<void> resetTest() async {
    state = const LevelTestState();
    await _storage.remove(_storageKey);
    Logger.info('Level test reset', tag: 'LevelTestProvider');
  }
}

/// Provider 정의
final levelTestProvider =
    StateNotifierProvider<LevelTestProvider, LevelTestState>((ref) {
  return LevelTestProvider(ref);
});

/// 편의 프로바이더
final hasCompletedLevelTestProvider = Provider<bool>((ref) {
  final state = ref.watch(levelTestProvider);
  return state.isCompleted;
});

final currentLevelTestQuestionProvider = Provider<LevelTestQuestion?>((ref) {
  final state = ref.watch(levelTestProvider);
  return state.currentQuestion;
});
