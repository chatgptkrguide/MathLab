import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/mock_data_service.dart';
import 'base/base_notifier.dart';
import 'user_provider.dart';
import 'problem_provider.dart';

/// 레슨 상태 관리 (BaseNotifier 최적화 버전)
///
/// **개선사항:**
/// - BaseNotifier 상속으로 중복 로깅 제거
/// - SharedPreferences → LocalStorageService로 통일
/// - executeWithErrorHandling로 try-catch 자동화
class LessonNotifier extends BaseNotifier<List<Lesson>> {
  LessonNotifier(this._ref) : super([], 'LessonProvider') {
    logInfo('LessonNotifier 초기화');
    _loadLessons();
  }

  final Ref _ref;
  static final MockDataService _dataService = MockDataService();
  static const String _storageKey = 'lessons';

  /// 레슨 데이터 로드
  Future<void> _loadLessons() async {
    logInfo('레슨 데이터 로드 시작');

    final data = await loadFromStorage(_storageKey);

    if (data != null && data['lessons'] != null) {
      // 저장된 레슨이 있으면 로드
      final lessonsList = data['lessons'] as List;
      logInfo('저장된 레슨 ${lessonsList.length}개 발견');

      final lessons = lessonsList
          .map((json) => Lesson.fromJson(json as Map<String, dynamic>))
          .toList();
      state = lessons;
      logInfo('레슨 ${lessons.length}개 로드 완료');
    } else {
      // JSON 파일에서 레슨 로드
      logInfo('저장된 레슨 없음, JSON 파일에서 로드');

      final lessons = await executeWithErrorHandling(
        () async => await _dataService.loadLessons(),
        errorMessage: 'JSON 로드 실패, 샘플 데이터 사용',
        fallback: () => _dataService.getSampleLessons(),
      );

      if (lessons != null) {
        state = lessons;
        logInfo('JSON 파일에서 ${lessons.length}개 레슨 로드 완료');
        await _saveLessons();
      }
    }

    // 첫 번째 레슨은 항상 잠금 해제
    await _unlockFirstLesson();
    logInfo('레슨 로드 완료');
  }

  /// 레슨 데이터 저장
  Future<void> _saveLessons() async {
    await saveToStorage(_storageKey, {
      'lessons': state.map((lesson) => lesson.toJson()).toList(),
    });
  }

  /// 첫 번째 레슨 잠금 해제
  Future<void> _unlockFirstLesson() async {
    if (state.isEmpty) return;

    final firstLesson = state.first;
    if (!firstLesson.isUnlocked) {
      await updateLessonProgress(firstLesson.id, 0, unlock: true);
    }
  }

  /// 레슨 진행률 업데이트
  Future<void> updateLessonProgress(
    String lessonId,
    int completedProblems, {
    bool unlock = false,
  }) async {
    final index = state.indexWhere((lesson) => lesson.id == lessonId);
    if (index == -1) return;

    final lesson = state[index];
    final updatedLesson = lesson.copyWith(
      completedProblems: completedProblems,
      isUnlocked: lesson.isUnlocked || unlock,
      completedAt: lesson.isCompleted ? DateTime.now() : lesson.completedAt,
    );

    state = [
      ...state.take(index),
      updatedLesson,
      ...state.skip(index + 1),
    ];

    await _saveLessons();

    // 레슨 완료 시 다음 레슨 잠금 해제
    if (updatedLesson.isCompleted && !lesson.isCompleted) {
      await _unlockNextLesson(lessonId);
    }
  }

  /// 다음 레슨 잠금 해제
  Future<void> _unlockNextLesson(String completedLessonId) async {
    final currentIndex = state.indexWhere((lesson) => lesson.id == completedLessonId);
    if (currentIndex == -1 || currentIndex >= state.length - 1) return;

    final nextLesson = state[currentIndex + 1];
    if (!nextLesson.isUnlocked) {
      await updateLessonProgress(nextLesson.id, 0, unlock: true);
    }
  }

  /// 사용자가 문제를 풀었을 때 호출
  Future<void> onProblemSolved(String problemId, bool isCorrect) async {
    // 문제가 속한 레슨 찾기
    final problems = _ref.read(problemProvider);
    final problem = problems.firstWhere(
      (p) => p.id == problemId,
      orElse: () => throw Exception('문제를 찾을 수 없습니다: $problemId'),
    );

    // 해당 레슨의 완료된 문제 수 계산
    final lessonProblems = problems.where((p) => p.lessonId == problem.lessonId).toList();
    final results = _ref.read(problemResultsProvider);
    final user = _ref.read(userProvider);

    if (user == null) return;

    final userResults = results.where((r) => r.userId == user.id).toList();
    final solvedLessonProblems = userResults
        .where((r) => lessonProblems.any((p) => p.id == r.problemId && r.isCorrect))
        .length;

    // 레슨 진행률 업데이트
    if (problem.lessonId != null) {
      await updateLessonProgress(problem.lessonId!, solvedLessonProblems);
    }
  }

  /// 학년별 레슨 조회
  List<Lesson> getLessonsByGrade(String grade) {
    return state.where((lesson) => lesson.grade == grade).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  /// 카테고리별 레슨 조회
  List<Lesson> getLessonsByCategory(String category) {
    return state.where((lesson) => lesson.category == category).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  /// 잠금 해제된 레슨들
  List<Lesson> get unlockedLessons {
    return state.where((lesson) => lesson.isUnlocked).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  /// 완료된 레슨들
  List<Lesson> get completedLessons {
    return state.where((lesson) => lesson.isCompleted).toList();
  }

  /// 다음에 할 수 있는 레슨 (잠금 해제되었지만 미완료)
  Lesson? get nextAvailableLesson {
    final availableLessons = state
        .where((lesson) => lesson.isUnlocked && !lesson.isCompleted)
        .toList();

    if (availableLessons.isEmpty) return null;

    availableLessons.sort((a, b) => a.order.compareTo(b.order));
    return availableLessons.first;
  }

  /// 전체 학습 진행률
  double get overallProgress {
    if (state.isEmpty) return 0.0;

    final totalProblems = state.fold(0, (sum, lesson) => sum + lesson.totalProblems);
    final completedProblems = state.fold(0, (sum, lesson) => sum + lesson.completedProblems);

    return totalProblems > 0 ? completedProblems / totalProblems : 0.0;
  }

  /// 특정 학년의 진행률
  double getGradeProgress(String grade) {
    final gradeLessons = getLessonsByGrade(grade);
    if (gradeLessons.isEmpty) return 0.0;

    final totalProblems = gradeLessons.fold(0, (sum, lesson) => sum + lesson.totalProblems);
    final completedProblems = gradeLessons.fold(0, (sum, lesson) => sum + lesson.completedProblems);

    return totalProblems > 0 ? completedProblems / totalProblems : 0.0;
  }

  /// 레슨 초기화 (테스트용)
  Future<void> resetLessons() async {
    state = _dataService.getSampleLessons();
    await _saveLessons();
    await _unlockFirstLesson();
  }

  /// 특정 레슨 강제 잠금 해제 (관리자용)
  Future<void> forceUnlockLesson(String lessonId) async {
    await updateLessonProgress(lessonId, 0, unlock: true);
  }

  /// 레슨 완료 체크
  bool isLessonCompleted(String lessonId) {
    final lesson = state.firstWhere(
      (l) => l.id == lessonId,
      orElse: () => throw Exception('레슨을 찾을 수 없습니다: $lessonId'),
    );
    return lesson.isCompleted;
  }

  /// 레슨 잠금 상태 체크
  bool isLessonUnlocked(String lessonId) {
    final lesson = state.firstWhere(
      (l) => l.id == lessonId,
      orElse: () => throw Exception('레슨을 찾을 수 없습니다: $lessonId'),
    );
    return lesson.isUnlocked;
  }
}

/// 프로바이더들
final lessonProvider = StateNotifierProvider<LessonNotifier, List<Lesson>>((ref) {
  return LessonNotifier(ref);
});

/// 편의 프로바이더들
final lessonsByGradeProvider = Provider.family<List<Lesson>, String>((ref, grade) {
  final lessons = ref.watch(lessonProvider);
  return lessons.where((lesson) => lesson.grade == grade).toList()
    ..sort((a, b) => a.order.compareTo(b.order));
});

final unlockedLessonsProvider = Provider<List<Lesson>>((ref) {
  final lessons = ref.watch(lessonProvider);
  return lessons.where((lesson) => lesson.isUnlocked).toList()
    ..sort((a, b) => a.order.compareTo(b.order));
});

final completedLessonsProvider = Provider<List<Lesson>>((ref) {
  final lessons = ref.watch(lessonProvider);
  return lessons.where((lesson) => lesson.isCompleted).toList();
});

final nextAvailableLessonProvider = Provider<Lesson?>((ref) {
  final lessons = ref.watch(lessonProvider);
  final availableLessons = lessons
      .where((lesson) => lesson.isUnlocked && !lesson.isCompleted)
      .toList();

  if (availableLessons.isEmpty) return null;

  availableLessons.sort((a, b) => a.order.compareTo(b.order));
  return availableLessons.first;
});

final overallProgressProvider = Provider<double>((ref) {
  final lessons = ref.watch(lessonProvider);
  if (lessons.isEmpty) return 0.0;

  final totalProblems = lessons.fold(0, (sum, lesson) => sum + lesson.totalProblems);
  final completedProblems = lessons.fold(0, (sum, lesson) => sum + lesson.completedProblems);

  return totalProblems > 0 ? completedProblems / totalProblems : 0.0;
});

final gradeProgressProvider = Provider.family<double, String>((ref, grade) {
  final gradeLessons = ref.watch(lessonsByGradeProvider(grade));
  if (gradeLessons.isEmpty) return 0.0;

  final totalProblems = gradeLessons.fold(0, (sum, lesson) => sum + lesson.totalProblems);
  final completedProblems = gradeLessons.fold(0, (sum, lesson) => sum + lesson.completedProblems);

  return totalProblems > 0 ? completedProblems / totalProblems : 0.0;
});
