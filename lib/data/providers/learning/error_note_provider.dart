import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../base/base_notifier.dart';

/// 오답 노트 상태 관리 (BaseNotifier 최적화 버전)
///
/// **개선사항:**
/// - BaseNotifier 상속으로 중복 로깅 제거
/// - executeWithErrorHandling로 try-catch 자동화
/// - LocalStorageService 상속으로 SharedPreferences 제거
class ErrorNoteNotifier extends BaseNotifier<List<ErrorNote>> {
  static const String _storageKey = 'errorNotes';

  ErrorNoteNotifier() : super([], 'ErrorNoteProvider') {
    _loadErrorNotes();
  }

  /// 오답 노트 데이터 로드
  Future<void> _loadErrorNotes() async {
    await executeWithErrorHandling(
      () async {
        final data = await loadListFromStorage(_storageKey);
        if (data != null) {
          final errorNotes = data
              .map((json) => ErrorNote.fromJson(json as Map<String, dynamic>))
              .toList();
          state = errorNotes;
          if (errorNotes.isNotEmpty) {
            logInfo('오답 노트 ${errorNotes.length}개 로드 완료');
          }
        } else {
          state = [];
        }
      },
      errorMessage: '오답 노트 로드 실패',
      fallback: () => state = [],
    );
  }

  /// 오답 노트 데이터 저장
  Future<void> _saveErrorNotes() async {
    await executeWithErrorHandling(
      () async {
        await saveListToStorage(
          _storageKey,
          state.map((note) => note.toJson()).toList(),
        );
        logDebug('오답 노트 ${state.length}개 저장 완료');
      },
      errorMessage: '오답 노트 저장 실패',
    );
  }

  /// 새 오답 추가 (문제를 틀렸을 때)
  Future<void> addErrorNote({
    required String userId,
    required Problem problem,
    required String userAnswer,
  }) async {
    await executeWithErrorHandling(
      () async {
        final errorNote = ErrorNote(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: userId,
          problemId: problem.id,
          lessonId: problem.lessonId ?? 'unknown',
          question: problem.question,
          userAnswer: userAnswer,
          correctAnswer: problem.correctAnswer ?? '',
          explanation: problem.explanation ?? '',
          category: problem.category,
          createdAt: DateTime.now(),
          reviewDates: [],
          status: ErrorStatus.newError,
          difficulty: problem.difficulty,
          tags: problem.tags,
        );

        state = [...state, errorNote];
        await _saveErrorNotes();
        logInfo('오답 노트 추가: ${problem.category}');
      },
      errorMessage: '오답 노트 추가 실패',
    );
  }

  /// 오답 복습 (복습할 때마다 호출)
  Future<void> reviewErrorNote(String errorNoteId) async {
    await executeWithErrorHandling(
      () async {
        final index = state.indexWhere((note) => note.id == errorNoteId);
        if (index == -1) {
          logWarning('오답 노트를 찾을 수 없음: $errorNoteId');
          return;
        }

        final errorNote = state[index];
        final newReviewDates = [...errorNote.reviewDates, DateTime.now()];

        // 복습 횟수에 따른 상태 변경
        final newStatus = _determineReviewStatus(newReviewDates.length);

        final updatedNote = errorNote.copyWith(
          reviewDates: newReviewDates,
          status: newStatus,
        );

        state = [
          ...state.take(index),
          updatedNote,
          ...state.skip(index + 1),
        ];

        await _saveErrorNotes();
        logInfo('오답 복습 완료: $errorNoteId (${newReviewDates.length}회)');
      },
      errorMessage: '오답 복습 실패',
    );
  }

  /// 복습 횟수에 따른 상태 결정
  ErrorStatus _determineReviewStatus(int reviewCount) {
    switch (reviewCount) {
      case 1:
        return ErrorStatus.reviewing;
      case 2:
        return ErrorStatus.improving;
      case 3:
      default:
        return ErrorStatus.mastered;
    }
  }

  /// 사용자별 오답 노트 조회
  List<ErrorNote> getErrorNotesByUser(String userId) {
    return state.where((note) => note.userId == userId).toList();
  }

  /// 상태별 오답 노트 조회
  List<ErrorNote> getErrorNotesByStatus(String userId, ErrorStatus status) {
    return getErrorNotesByUser(userId)
        .where((note) => note.status == status)
        .toList();
  }

  /// 복습이 필요한 오답 노트들
  List<ErrorNote> getErrorNotesNeedingReview(String userId) {
    return getErrorNotesByUser(userId)
        .where((note) => note.needsReview)
        .toList();
  }

  /// 카테고리별 오답 노트 조회
  List<ErrorNote> getErrorNotesByCategory(String userId, String category) {
    return getErrorNotesByUser(userId)
        .where((note) => note.category == category)
        .toList();
  }

  /// 복습 횟수별 오답 노트 조회
  List<ErrorNote> getErrorNotesByReviewCount(String userId, int reviewCount) {
    if (reviewCount == 0) {
      return getErrorNotesByUser(userId)
          .where((note) => note.reviewCount == 0)
          .toList();
    } else if (reviewCount == 1) {
      return getErrorNotesByUser(userId)
          .where((note) => note.reviewCount == 1)
          .toList();
    } else {
      return getErrorNotesByUser(userId)
          .where((note) => note.reviewCount >= 2)
          .toList();
    }
  }

  /// 오답 노트 통계
  ErrorNoteStats getErrorNoteStats(String userId) {
    final userNotes = getErrorNotesByUser(userId);

    return ErrorNoteStats(
      totalErrors: userNotes.length,
      unreviewed: userNotes.where((note) => note.reviewCount == 0).length,
      reviewedOnce: userNotes.where((note) => note.reviewCount == 1).length,
      reviewedTwice: userNotes.where((note) => note.reviewCount >= 2).length,
      mastered:
          userNotes.where((note) => note.status == ErrorStatus.mastered).length,
      needingReview: userNotes.where((note) => note.needsReview).length,
    );
  }

  /// 맞춤 복습 세트 생성
  List<ErrorNote> createCustomReviewSet({
    required String userId,
    String? category,
    int? maxDifficulty,
    ErrorStatus? status,
    int maxCount = 10,
  }) {
    var filteredNotes = getErrorNotesByUser(userId);

    // 필터 적용
    if (category != null) {
      filteredNotes =
          filteredNotes.where((note) => note.category == category).toList();
    }

    if (maxDifficulty != null) {
      filteredNotes = filteredNotes
          .where((note) => note.difficulty <= maxDifficulty)
          .toList();
    }

    if (status != null) {
      filteredNotes =
          filteredNotes.where((note) => note.status == status).toList();
    }

    // 복습이 필요한 순서대로 정렬
    filteredNotes.sort((a, b) {
      // 복습 필요 여부 우선
      if (a.needsReview && !b.needsReview) return -1;
      if (!a.needsReview && b.needsReview) return 1;

      // 복습 횟수 적은 순
      final reviewDiff = a.reviewCount.compareTo(b.reviewCount);
      if (reviewDiff != 0) return reviewDiff;

      // 생성 날짜 오래된 순
      return a.createdAt.compareTo(b.createdAt);
    });

    return filteredNotes.take(maxCount).toList();
  }

  /// 망각 곡선 기반 복습 스케줄 생성
  List<ErrorNote> getScheduledReviewNotes(String userId) {
    final userNotes = getErrorNotesByUser(userId);
    final now = DateTime.now();

    // 복습 스케줄에 따라 필터링
    final scheduledNotes = userNotes.where((note) {
      return now.isAfter(note.nextReviewDate);
    }).toList();

    // 우선순위 정렬 (오래된 것, 복습 횟수 적은 것 우선)
    scheduledNotes.sort((a, b) {
      final urgencyA = now.difference(a.nextReviewDate).inDays;
      final urgencyB = now.difference(b.nextReviewDate).inDays;

      if (urgencyA != urgencyB) {
        return urgencyB.compareTo(urgencyA); // 더 긴급한 것 우선
      }

      return a.reviewCount.compareTo(b.reviewCount); // 복습 적은 것 우선
    });

    return scheduledNotes;
  }

  /// 오답 노트 삭제
  Future<void> deleteErrorNote(String errorNoteId) async {
    await executeWithErrorHandling(
      () async {
        state = state.where((note) => note.id != errorNoteId).toList();
        await _saveErrorNotes();
        logInfo('오답 노트 삭제: $errorNoteId');
      },
      errorMessage: '오답 노트 삭제 실패',
    );
  }

  /// 완전히 이해한 문제 처리 (마스터 상태로 변경)
  Future<void> markAsMastered(String errorNoteId) async {
    await executeWithErrorHandling(
      () async {
        final index = state.indexWhere((note) => note.id == errorNoteId);
        if (index == -1) {
          logWarning('오답 노트를 찾을 수 없음: $errorNoteId');
          return;
        }

        final updatedNote = state[index].copyWith(
          status: ErrorStatus.mastered,
        );

        state = [
          ...state.take(index),
          updatedNote,
          ...state.skip(index + 1),
        ];

        await _saveErrorNotes();
        logInfo('오답 노트 마스터 처리: $errorNoteId');
      },
      errorMessage: '마스터 처리 실패',
    );
  }

  /// 오답 노트 초기화 (테스트용)
  Future<void> clearErrorNotes() async {
    await executeWithErrorHandling(
      () async {
        state = [];
        await _saveErrorNotes();
        logInfo('오답 노트 초기화');
      },
      errorMessage: '오답 노트 초기화 실패',
    );
  }
}

/// 오답 노트 통계 클래스
class ErrorNoteStats {
  final int totalErrors;
  final int unreviewed;
  final int reviewedOnce;
  final int reviewedTwice;
  final int mastered;
  final int needingReview;

  const ErrorNoteStats({
    required this.totalErrors,
    required this.unreviewed,
    required this.reviewedOnce,
    required this.reviewedTwice,
    required this.mastered,
    required this.needingReview,
  });
}

/// 프로바이더들
final errorNoteProvider =
    StateNotifierProvider<ErrorNoteNotifier, List<ErrorNote>>((ref) {
  return ErrorNoteNotifier();
});

/// 편의 프로바이더들
final errorNoteStatsProvider =
    Provider.family<ErrorNoteStats, String>((ref, userId) {
  final errorNotes = ref.watch(errorNoteProvider);
  final userNotes = errorNotes.where((note) => note.userId == userId).toList();

  return ErrorNoteStats(
    totalErrors: userNotes.length,
    unreviewed: userNotes.where((note) => note.reviewCount == 0).length,
    reviewedOnce: userNotes.where((note) => note.reviewCount == 1).length,
    reviewedTwice: userNotes.where((note) => note.reviewCount >= 2).length,
    mastered:
        userNotes.where((note) => note.status == ErrorStatus.mastered).length,
    needingReview: userNotes.where((note) => note.needsReview).length,
  );
});

final reviewNeededNotesProvider =
    Provider.family<List<ErrorNote>, String>((ref, userId) {
  final errorNotes = ref.watch(errorNoteProvider);
  return errorNotes
      .where((note) => note.userId == userId && note.needsReview)
      .toList();
});

final scheduledReviewNotesProvider =
    Provider.family<List<ErrorNote>, String>((ref, userId) {
  final errorNotes = ref.watch(errorNoteProvider);
  final now = DateTime.now();

  // 복습 스케줄에 따라 필터링
  final scheduledNotes = errorNotes.where((note) {
    return note.userId == userId && now.isAfter(note.nextReviewDate);
  }).toList();

  // 우선순위 정렬 (오래된 것, 복습 횟수 적은 것 우선)
  scheduledNotes.sort((a, b) {
    final urgencyA = now.difference(a.nextReviewDate).inDays;
    final urgencyB = now.difference(b.nextReviewDate).inDays;

    if (urgencyA != urgencyB) {
      return urgencyB.compareTo(urgencyA); // 더 긴급한 것 우선
    }

    return a.reviewCount.compareTo(b.reviewCount); // 복습 적은 것 우선
  });

  return scheduledNotes;
});
