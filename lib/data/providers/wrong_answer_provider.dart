import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wrong_answer.dart';
import '../models/problem.dart';
import '../../shared/utils/logger.dart';
import '../../data/services/local_storage_service.dart';
import 'auth_provider.dart';

/// 오답 노트 상태
class WrongAnswerState {
  final List<WrongAnswer> wrongAnswers;
  final int totalCount;
  final int masteredCount;
  final int needsReviewCount;
  final String? selectedCategory; // 선택된 카테고리 필터
  final int? selectedDifficulty; // 선택된 난이도 필터 (1-5)

  const WrongAnswerState({
    required this.wrongAnswers,
    required this.totalCount,
    required this.masteredCount,
    required this.needsReviewCount,
    this.selectedCategory,
    this.selectedDifficulty,
  });

  WrongAnswerState copyWith({
    List<WrongAnswer>? wrongAnswers,
    int? totalCount,
    int? masteredCount,
    int? needsReviewCount,
    String? selectedCategory,
    int? selectedDifficulty,
    bool clearCategory = false,
    bool clearDifficulty = false,
  }) {
    return WrongAnswerState(
      wrongAnswers: wrongAnswers ?? this.wrongAnswers,
      totalCount: totalCount ?? this.totalCount,
      masteredCount: masteredCount ?? this.masteredCount,
      needsReviewCount: needsReviewCount ?? this.needsReviewCount,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      selectedDifficulty: clearDifficulty ? null : (selectedDifficulty ?? this.selectedDifficulty),
    );
  }

  /// 완료율
  double get completionRate {
    if (totalCount == 0) return 0.0;
    return masteredCount / totalCount;
  }

  /// 필터링된 오답 목록
  List<WrongAnswer> get filteredWrongAnswers {
    var filtered = wrongAnswers;

    // 카테고리 필터
    if (selectedCategory != null) {
      filtered = filtered.where((wa) => wa.problem.category == selectedCategory).toList();
    }

    // 난이도 필터
    if (selectedDifficulty != null) {
      filtered = filtered.where((wa) => wa.problem.difficulty == selectedDifficulty).toList();
    }

    return filtered;
  }
}

/// 오답 노트 Provider
class WrongAnswerProvider extends StateNotifier<WrongAnswerState> {
  final Ref ref; // Riverpod Ref for accessing current account
  final LocalStorageService _storage = LocalStorageService();

  WrongAnswerProvider(this.ref)
      : super(const WrongAnswerState(
          wrongAnswers: [],
          totalCount: 0,
          masteredCount: 0,
          needsReviewCount: 0,
        )) {
    _initialize();
  }

  /// 현재 계정 ID 기반 저장소 키
  String? get _storageKey {
    final currentAccount = ref.read(currentAccountProvider);
    if (currentAccount == null) {
      Logger.warning('No logged in account', tag: 'WrongAnswerProvider');
      return null;
    }
    return 'wrong_answers_${currentAccount.id}';
  }

  /// 초기화 및 데이터 로드
  Future<void> _initialize() async {
    await _loadWrongAnswers();
  }

  /// 오답 로드
  Future<void> _loadWrongAnswers() async {
    try {
      final key = _storageKey;
      if (key == null) {
        // 로그인된 계정 없음 - 빈 상태로 초기화
        _updateState([]);
        return;
      }

      final data = await _storage.loadMap(key);
      if (data != null) {
        final wrongAnswers = (data['wrongAnswers'] as List?)
            ?.map((json) => WrongAnswer.fromJson(json))
            .toList() ?? [];

        _updateState(wrongAnswers);
        Logger.info('Loaded ${wrongAnswers.length} wrong answers for account', tag: 'WrongAnswerProvider');
      } else {
        _updateState([]);
      }
    } catch (e) {
      Logger.error('Failed to load wrong answers', error: e, tag: 'WrongAnswerProvider');
      _updateState([]);
    }
  }

  /// 오답 저장
  Future<void> _saveWrongAnswers() async {
    try {
      final key = _storageKey;
      if (key == null) {
        Logger.warning('Cannot save wrong answers - no logged in account', tag: 'WrongAnswerProvider');
        return;
      }

      await _storage.saveMap(key, {
        'wrongAnswers': state.wrongAnswers.map((wa) => wa.toJson()).toList(),
      });

      Logger.info('Saved ${state.wrongAnswers.length} wrong answers for account', tag: 'WrongAnswerProvider');
    } catch (e) {
      Logger.error('Failed to save wrong answers', error: e, tag: 'WrongAnswerProvider');
    }
  }

  /// 상태 업데이트
  void _updateState(List<WrongAnswer> wrongAnswers) {
    final totalCount = wrongAnswers.length;
    final masteredCount = wrongAnswers.where((wa) => wa.isMastered).length;
    final needsReviewCount = wrongAnswers.where((wa) => wa.needsReview).length;

    state = WrongAnswerState(
      wrongAnswers: wrongAnswers,
      totalCount: totalCount,
      masteredCount: masteredCount,
      needsReviewCount: needsReviewCount,
    );
  }

  /// 오답 추가
  /// [selectedAnswerIndex]는 객관식 문제의 경우에만 필요 (주관식은 null)
  Future<void> addWrongAnswer({
    required Problem problem,
    int? selectedAnswerIndex, // 주관식 지원을 위해 optional로 변경
  }) async {
    // 이미 존재하는지 확인
    final existingIndex = state.wrongAnswers.indexWhere(
      (wa) => wa.problem.id == problem.id,
    );

    List<WrongAnswer> updatedList;

    if (existingIndex != -1) {
      // 이미 존재하면 업데이트
      final existing = state.wrongAnswers[existingIndex];
      final updated = existing.copyWith(
        selectedAnswerIndex: selectedAnswerIndex,
        timestamp: DateTime.now(),
        isMastered: false, // 다시 틀렸으므로 미완료 처리
      );

      updatedList = [...state.wrongAnswers];
      updatedList[existingIndex] = updated;

      Logger.info('Updated existing wrong answer: ${problem.id}');
    } else {
      // 새로 추가
      final wrongAnswer = WrongAnswer(
        id: 'wa_${DateTime.now().millisecondsSinceEpoch}',
        problem: problem,
        selectedAnswerIndex: selectedAnswerIndex, // nullable 허용
        timestamp: DateTime.now(),
      );

      updatedList = [...state.wrongAnswers, wrongAnswer];

      Logger.info('Added new wrong answer: ${problem.id}');
    }

    _updateState(updatedList);
    await _saveWrongAnswers();
  }

  /// 복습 완료 (정답 처리)
  Future<void> markAsReviewed(String wrongAnswerId, bool isCorrect) async {
    final index = state.wrongAnswers.indexWhere((wa) => wa.id == wrongAnswerId);
    if (index == -1) return;

    final wrongAnswer = state.wrongAnswers[index];
    final newReviewCount = wrongAnswer.reviewCount + 1;

    // 3번 연속 정답이면 완전 학습 처리
    final isMastered = isCorrect && newReviewCount >= 3;

    final updated = wrongAnswer.copyWith(
      reviewCount: isCorrect ? newReviewCount : 0, // 오답이면 카운트 리셋
      lastReviewDate: DateTime.now(),
      isMastered: isMastered,
    );

    final updatedList = [...state.wrongAnswers];
    updatedList[index] = updated;

    _updateState(updatedList);
    await _saveWrongAnswers();

    if (isMastered) {
      Logger.info('🎉 Mastered wrong answer: ${wrongAnswer.problem.id}');
    } else if (isCorrect) {
      Logger.info('✅ Reviewed correctly: ${wrongAnswer.problem.id} ($newReviewCount/3)');
    } else {
      Logger.info('❌ Reviewed incorrectly: ${wrongAnswer.problem.id} - reset count');
    }
  }

  /// 오답 삭제
  Future<void> deleteWrongAnswer(String wrongAnswerId) async {
    final updatedList = state.wrongAnswers.where((wa) => wa.id != wrongAnswerId).toList();

    _updateState(updatedList);
    await _saveWrongAnswers();

    Logger.info('Deleted wrong answer: $wrongAnswerId');
  }

  /// 필터 설정 - 카테고리
  void setCategory(String? category) {
    state = state.copyWith(
      selectedCategory: category,
      clearCategory: category == null,
    );
  }

  /// 필터 설정 - 난이도
  void setDifficulty(int? difficulty) {
    state = state.copyWith(
      selectedDifficulty: difficulty,
      clearDifficulty: difficulty == null,
    );
  }

  /// 모든 필터 초기화
  void clearFilters() {
    state = state.copyWith(
      clearCategory: true,
      clearDifficulty: true,
    );
  }

  /// 사용 가능한 카테고리 목록
  List<String> get availableCategories {
    return state.wrongAnswers
        .map((wa) => wa.problem.category)
        .toSet()
        .toList()
      ..sort();
  }

  /// 사용 가능한 난이도 목록
  List<int> get availableDifficulties {
    return state.wrongAnswers
        .map((wa) => wa.problem.difficulty)
        .toSet()
        .toList()
      ..sort();
  }

  /// 복습 필요 목록 (필터 적용)
  List<WrongAnswer> get reviewList {
    return state.filteredWrongAnswers
        .where((wa) => wa.needsReview)
        .toList()
      ..sort((a, b) {
        // 긴급도 높은 순, 같으면 오래된 순
        final urgencyCompare = b.urgency.compareTo(a.urgency);
        if (urgencyCompare != 0) return urgencyCompare;
        return a.timestamp.compareTo(b.timestamp);
      });
  }

  /// 최근 오답 목록 (최신순, 필터 적용)
  List<WrongAnswer> get recentList {
    return [...state.filteredWrongAnswers]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// 완료 목록 (필터 적용)
  List<WrongAnswer> get masteredList {
    return state.filteredWrongAnswers
        .where((wa) => wa.isMastered)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// 미완료 목록
  List<WrongAnswer> get unfinishedList {
    return state.wrongAnswers
        .where((wa) => !wa.isMastered)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  /// 카테고리별 통계
  Map<String, int> getCategoryStats() {
    final stats = <String, int>{};

    for (final wa in state.wrongAnswers) {
      final category = wa.problem.category;
      stats[category] = (stats[category] ?? 0) + 1;
    }

    return stats;
  }

  /// 난이도별 통계
  Map<String, int> getDifficultyStats() {
    final stats = <String, int>{};

    for (final wa in state.wrongAnswers) {
      final difficulty = wa.problem.difficulty.toString();
      stats[difficulty] = (stats[difficulty] ?? 0) + 1;
    }

    return stats;
  }

  /// 오답 노트 초기화 (테스트용)
  Future<void> clearAll() async {
    _updateState([]);
    await _saveWrongAnswers();

    Logger.info('Cleared all wrong answers');
  }
}

/// Provider 정의
final wrongAnswerProvider =
    StateNotifierProvider<WrongAnswerProvider, WrongAnswerState>((ref) {
  return WrongAnswerProvider(ref);
});
