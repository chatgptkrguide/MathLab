// 📊 Lesson Progress Provider
//
// Manages lesson progress state with Firestore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/error/app_error.dart';
import '../../../core/utils/app_logger.dart';
import '../../models/lesson/lesson_progress_model.dart';

/// Lesson Progress State
class LessonProgressState {
  final Map<String, LessonProgressModel> progressMap;
  final bool isLoading;
  final String? error;

  const LessonProgressState({
    this.progressMap = const {},
    this.isLoading = false,
    this.error,
  });

  LessonProgressState copyWith({
    Map<String, LessonProgressModel>? progressMap,
    bool? isLoading,
    String? error,
  }) {
    return LessonProgressState(
      progressMap: progressMap ?? this.progressMap,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// 완료된 레슨 수
  int get completedCount =>
      progressMap.values.where((p) => p.isCompleted).length;

  /// 총 획득 XP
  int get totalXpEarned =>
      progressMap.values.fold(0, (acc, p) => acc + p.xpEarned);

  /// 총 획득 별 수
  int get totalStars => progressMap.values.fold(0, (acc, p) => acc + p.stars);
}

/// Lesson Progress Notifier - Firestore 직접 연동
class LessonProgressNotifier extends StateNotifier<LessonProgressState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;

  LessonProgressNotifier(this.userId) : super(const LessonProgressState()) {
    loadProgress();
  }

  /// Firestore 컬렉션 참조
  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('users').doc(userId).collection('lessonProgress');

  /// 모든 레슨 진행 상황 로드
  Future<void> loadProgress() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final snapshot = await _collection.get();

      final progressMap = <String, LessonProgressModel>{};
      for (final doc in snapshot.docs) {
        final progress = LessonProgressModel.fromFirestore(doc);
        progressMap[progress.lessonId] = progress;
      }

      state = state.copyWith(
        progressMap: progressMap,
        isLoading: false,
      );

      AppLogger.info('Loaded ${progressMap.length} lesson progress records');
    } catch (e, stackTrace) {
      final appError = AppErrorHandler.handle(e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: appError.userMessage,
      );
    }
  }

  /// 특정 레슨의 진행 상황 가져오기
  LessonProgressModel? getProgress(String lessonId) {
    return state.progressMap[lessonId];
  }

  /// 레슨 시작 (unlocked → inProgress)
  Future<void> startLesson(String lessonId) async {
    try {
      final existing = state.progressMap[lessonId];
      final now = DateTime.now();

      final progress = LessonProgressModel(
        lessonId: lessonId,
        userId: userId,
        status: LessonStatus.inProgress,
        attemptsCount: (existing?.attemptsCount ?? 0) + 1,
        lastAttemptedAt: now,
        stars: existing?.stars ?? 0,
        correctAnswers: existing?.correctAnswers ?? 0,
        totalQuestions: existing?.totalQuestions ?? 0,
        xpEarned: existing?.xpEarned ?? 0,
        completedAt: existing?.completedAt,
      );

      await _collection.doc(lessonId).set(progress.toFirestore());

      final updatedMap = Map<String, LessonProgressModel>.from(state.progressMap);
      updatedMap[lessonId] = progress;
      state = state.copyWith(progressMap: updatedMap);

      AppLogger.info('Started lesson: $lessonId');
    } catch (e, stackTrace) {
      final appError = AppErrorHandler.handle(e, stackTrace);
      state = state.copyWith(error: appError.userMessage);
    }
  }

  /// 레슨 완료
  Future<void> completeLesson({
    required String lessonId,
    required int correctAnswers,
    required int totalQuestions,
    required int xpEarned,
  }) async {
    try {
      final existing = state.progressMap[lessonId];
      final now = DateTime.now();

      // 별 계산: 정답률 기준
      final accuracy = totalQuestions > 0 ? correctAnswers / totalQuestions : 0.0;
      int stars;
      if (accuracy >= 1.0) {
        stars = 3;
      } else if (accuracy >= 0.8) {
        stars = 2;
      } else if (accuracy >= 0.6) {
        stars = 1;
      } else {
        stars = 0;
      }

      // 이전 기록보다 좋으면 업데이트
      final bestStars = (existing?.stars ?? 0) > stars ? existing!.stars : stars;
      final bestXp =
          (existing?.xpEarned ?? 0) > xpEarned ? existing!.xpEarned : xpEarned;

      final progress = LessonProgressModel(
        lessonId: lessonId,
        userId: userId,
        status: LessonStatus.completed,
        stars: bestStars,
        attemptsCount: existing?.attemptsCount ?? 1,
        correctAnswers: correctAnswers,
        totalQuestions: totalQuestions,
        xpEarned: bestXp,
        completedAt: now,
        lastAttemptedAt: now,
      );

      await _collection.doc(lessonId).set(progress.toFirestore());

      final updatedMap = Map<String, LessonProgressModel>.from(state.progressMap);
      updatedMap[lessonId] = progress;
      state = state.copyWith(progressMap: updatedMap);

      AppLogger.info('Completed lesson: $lessonId with $stars stars');
    } catch (e, stackTrace) {
      final appError = AppErrorHandler.handle(e, stackTrace);
      state = state.copyWith(error: appError.userMessage);
    }
  }

  /// 다음 레슨 언락
  Future<void> unlockLesson(String lessonId) async {
    try {
      // 이미 진행 중이거나 완료된 경우 스킵
      final existing = state.progressMap[lessonId];
      if (existing != null && existing.status != LessonStatus.locked) {
        return;
      }

      final progress = LessonProgressModel(
        lessonId: lessonId,
        userId: userId,
        status: LessonStatus.unlocked,
      );

      await _collection.doc(lessonId).set(progress.toFirestore());

      final updatedMap = Map<String, LessonProgressModel>.from(state.progressMap);
      updatedMap[lessonId] = progress;
      state = state.copyWith(progressMap: updatedMap);

      AppLogger.info('Unlocked lesson: $lessonId');
    } catch (e, stackTrace) {
      final appError = AppErrorHandler.handle(e, stackTrace);
      state = state.copyWith(error: appError.userMessage);
    }
  }

  /// 첫 번째 레슨들 초기화 (신규 사용자용)
  Future<void> initializeFirstLessons(List<String> firstLessonIds) async {
    try {
      final batch = _firestore.batch();

      for (final lessonId in firstLessonIds) {
        if (!state.progressMap.containsKey(lessonId)) {
          final progress = LessonProgressModel(
            lessonId: lessonId,
            userId: userId,
            status: LessonStatus.unlocked,
          );
          batch.set(_collection.doc(lessonId), progress.toFirestore());
        }
      }

      await batch.commit();
      await loadProgress(); // 전체 리로드

      AppLogger.info('Initialized ${firstLessonIds.length} first lessons');
    } catch (e, stackTrace) {
      final appError = AppErrorHandler.handle(e, stackTrace);
      state = state.copyWith(error: appError.userMessage);
    }
  }
}

/// Lesson Progress Provider - Firestore 직접 연동
final lessonProgressProvider = StateNotifierProvider.family<
    LessonProgressNotifier, LessonProgressState, String>(
  (ref, userId) => LessonProgressNotifier(userId),
);
