import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../../services/mock_data_service.dart';
import '../../repositories/lesson_repository.dart';
import '../base/base_notifier.dart';
import '../user/user_provider.dart';
import 'problem_provider.dart';
import '../infrastructure/firebase_providers.dart';

/// 레슨 상태 관리 (Firestore 연동 버전)
///
/// **개선사항:**
/// - LessonRepository 연결로 Firestore 실시간 동기화
/// - 로컬 + Firebase 자동 동기화
/// - 실시간 레슨 업데이트 스트림
class LessonNotifier extends BaseNotifier<List<Lesson>> {
  LessonNotifier(this._ref, this._repository) : super([], 'LessonProvider') {
    logInfo('LessonNotifier 초기화 (Firestore 연동)');
    _loadLessons();
    _setupRealtimeSync();
  }

  final Ref _ref;
  final LessonRepository _repository;
  static final MockDataService _dataService = MockDataService();
  String get _storageKey => 'lessons_${_getCurrentUserId()}';

  /// 현재 사용자 ID 가져오기
  String _getCurrentUserId() {
    final user = _ref.read(userProvider);
    return user?.id ?? 'default';
  }

  /// 실시간 동기화 설정
  void _setupRealtimeSync() {
    // Firestore 실시간 스트림 감지
    _repository.watchLessons().listen((lessons) {
      if (lessons.isNotEmpty) {
        state = lessons;
        logInfo('실시간 레슨 업데이트: ${lessons.length}개');
      }
    });
  }

  /// 레슨 데이터 로드 (로컬 → Firebase → 병합)
  Future<void> _loadLessons() async {
    logInfo('레슨 데이터 로드 시작 (Firestore 연동)');

    await executeWithErrorHandling(
      () async {
        final userId = _getCurrentUserId();

        // 1. 로컬 데이터 먼저 로드 (빠른 UI 표시)
        final localLessons = await _repository.getFromLocal(_storageKey);
        if (localLessons != null && localLessons.isNotEmpty) {
          state = localLessons;
          logInfo('로컬 레슨 ${localLessons.length}개 로드 완료');
        }

        // 2. Firebase 데이터 로드
        final remoteLessons = await _repository.getFromFirebase(userId);

        if (remoteLessons != null && remoteLessons.isNotEmpty) {
          // 3. 병합 (Firebase 기본 정보 + 로컬 진행률)
          if (localLessons != null) {
            final merged = await _repository.mergeData(localLessons, remoteLessons);
            if (merged != null) {
              state = merged;
              await _repository.saveToLocal(_storageKey, merged);
              logInfo('로컬-Firebase 병합 완료: ${merged.length}개');
            }
          } else {
            state = remoteLessons;
            await _repository.saveToLocal(_storageKey, remoteLessons);
            logInfo('Firebase 레슨 ${remoteLessons.length}개 로드 완료');
          }
        } else if (localLessons == null || localLessons.isEmpty) {
          // 4. Firebase에도 없으면 JSON에서 초기 로드
          logInfo('Firebase에 레슨 없음, JSON에서 초기 로드');
          final lessons = await _dataService.loadLessons();

          if (lessons.isNotEmpty) {
            state = lessons;
            await _repository.saveToLocal(_storageKey, lessons);
            await _repository.saveToFirebase(userId, lessons);
            logInfo('JSON에서 ${lessons.length}개 레슨 로드 및 Firebase 업로드');
          }
        }

        // 첫 번째 레슨 잠금 해제
        await _unlockFirstLesson();
        logInfo('레슨 로드 완료');
      },
      errorMessage: '레슨 로드 실패',
      fallback: () async {
        // 최후의 수단: 샘플 데이터
        state = _dataService.getSampleLessons();
        await _repository.saveToLocal(_storageKey, state);
      },
    );
  }

  /// 레슨 데이터 저장 (로컬 + Firebase 동시)
  Future<void> _saveLessons() async {
    await executeWithErrorHandling(
      () async {
        final userId = _getCurrentUserId();

        // 로컬 저장
        await _repository.saveToLocal(_storageKey, state);

        // Firebase 저장 (백그라운드)
        _repository.saveToFirebase(userId, state).catchError((error, stackTrace) {
          logError('Firebase 저장 실패 (백그라운드)', error: error, stackTrace: stackTrace);
        });

        logInfo('레슨 저장 완료 (로컬 + Firebase)');
      },
      errorMessage: '레슨 저장 실패',
    );
  }

  /// 첫 번째 레슨 잠금 해제
  Future<void> _unlockFirstLesson() async {
    if (state.isEmpty) return;

    final firstLesson = state.first;
    if (!firstLesson.isUnlocked) {
      await updateLessonProgress(firstLesson.id, 0, unlock: true);
    }
  }

  /// 레슨 진행률 업데이트 (Firestore 동기화)
  Future<void> updateLessonProgress(
    String lessonId,
    int completedProblems, {
    bool unlock = false,
  }) async {
    final index = state.indexWhere((lesson) => lesson.id == lessonId);
    if (index == -1) return;

    final lesson = state[index];
    final now = DateTime.now();
    final isCompleting = completedProblems >= lesson.totalProblems && !lesson.isCompleted;

    final updatedLesson = lesson.copyWith(
      completedProblems: completedProblems,
      isUnlocked: lesson.isUnlocked || unlock,
      completedAt: isCompleting ? now : lesson.completedAt,
    );

    // 로컬 state 업데이트
    state = [
      ...state.take(index),
      updatedLesson,
      ...state.skip(index + 1),
    ];

    // Firestore 업데이트 (백그라운드)
    _repository.updateLessonProgress(
      lessonId: lessonId,
      completedProblems: completedProblems,
      isUnlocked: unlock ? true : null,
      completedAt: isCompleting ? now : null,
    ).catchError((error, stackTrace) {
      logError('Firestore 진행률 업데이트 실패', error: error, stackTrace: stackTrace);
    });

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
  final lessonRepository = ref.watch(lessonRepositoryProvider);
  return LessonNotifier(ref, lessonRepository);
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
