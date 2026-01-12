import '../../../shared/utils/logger.dart';
import '../../models/learning/wrong_answer.dart';
import '../../models/learning/lesson.dart';
import '../../repositories/wrong_answer_repository.dart';
import '../../repositories/lesson_repository.dart';
import '../conflict_resolution_service.dart';

/// 학습 데이터 동기화 서비스
///
/// 역할:
/// - 오답 노트 업로드/다운로드
/// - 레슨 진행률 업로드/다운로드
/// - 학습 데이터 충돌 해결
class LearningProgressSyncService {
  final WrongAnswerRepository _wrongAnswerRepository;
  final LessonRepository _lessonRepository;
  final ConflictResolutionService _conflictResolver;

  LearningProgressSyncService({
    required WrongAnswerRepository wrongAnswerRepository,
    required LessonRepository lessonRepository,
    required ConflictResolutionService conflictResolver,
  })  : _wrongAnswerRepository = wrongAnswerRepository,
        _lessonRepository = lessonRepository,
        _conflictResolver = conflictResolver;

  // ==================== 오답 노트 동기화 ====================

  /// 오답 업로드
  Future<void> uploadWrongAnswer(String accountId, WrongAnswer wrongAnswer) async {
    try {
      Logger.info('오답 업로드 시작: ${wrongAnswer.id}', tag: 'LearningProgressSyncService');

      await _wrongAnswerRepository.saveToFirebase(accountId, wrongAnswer);

      Logger.info('오답 업로드 완료', tag: 'LearningProgressSyncService');
    } catch (e, stackTrace) {
      Logger.error(
        '오답 업로드 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'LearningProgressSyncService',
      );
      rethrow;
    }
  }

  /// 모든 오답 업로드
  Future<void> uploadAllWrongAnswers(String accountId) async {
    try {
      Logger.info('모든 오답 업로드 시작', tag: 'LearningProgressSyncService');

      final wrongAnswers = await _wrongAnswerRepository.getFromLocal(accountId);

      for (final wrongAnswer in wrongAnswers) {
        try {
          await _wrongAnswerRepository.saveToFirebase(accountId, wrongAnswer);
        } catch (e) {
          Logger.warning('오답 업로드 실패: ${wrongAnswer.id} - $e',
              tag: 'LearningProgressSyncService');
        }
      }

      Logger.info('모든 오답 업로드 완료: ${wrongAnswers.length}개', tag: 'LearningProgressSyncService');
    } catch (e, stackTrace) {
      Logger.error(
        '모든 오답 업로드 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'LearningProgressSyncService',
      );
      rethrow;
    }
  }

  /// 오답 목록 다운로드
  Future<void> downloadWrongAnswers(String accountId) async {
    try {
      Logger.info('오답 목록 다운로드 시작', tag: 'LearningProgressSyncService');

      final remoteAnswers = await _wrongAnswerRepository.getFromFirebase(accountId);

      if (remoteAnswers.isNotEmpty) {
        final localAnswers = await _wrongAnswerRepository.getFromLocal(accountId);

        // 병합: 양쪽 데이터 통합 (중복 제거)
        final merged = _mergeWrongAnswers(accountId, localAnswers, remoteAnswers);
        await _wrongAnswerRepository.saveToLocal(accountId, merged);

        Logger.info('오답 목록 다운로드 완료: ${merged.length}개', tag: 'LearningProgressSyncService');
      } else {
        Logger.debug('Firebase에 오답 목록 없음: $accountId', tag: 'LearningProgressSyncService');
      }
    } catch (e, stackTrace) {
      Logger.error(
        '오답 목록 다운로드 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'LearningProgressSyncService',
      );
      rethrow;
    }
  }

  /// 오답 목록 병합 (ConflictResolutionService 사용)
  List<WrongAnswer> _mergeWrongAnswers(
      String accountId, List<WrongAnswer> local, List<WrongAnswer> remote) {
    final Map<String, WrongAnswer> merged = {};

    // 로컬 데이터를 맵으로 변환
    final localMap = <String, WrongAnswer>{};
    for (final answer in local) {
      localMap[answer.id] = answer;
    }

    // 원격 데이터를 맵으로 변환
    final remoteMap = <String, WrongAnswer>{};
    for (final answer in remote) {
      remoteMap[answer.id] = answer;
    }

    // 모든 고유 ID 수집
    final allIds = {...localMap.keys, ...remoteMap.keys};

    // 각 오답에 대해 충돌 해결
    for (final id in allIds) {
      final localAnswer = localMap[id];
      final remoteAnswer = remoteMap[id];

      if (localAnswer != null && remoteAnswer != null) {
        // 충돌 해결이 필요한 경우
        final resolvedData = _conflictResolver.resolveConflict(
          'wrongAnswer',
          id,
          localAnswer.toJson(),
          remoteAnswer.toJson(),
        );
        merged[id] = WrongAnswer.fromJson(resolvedData);
      } else if (localAnswer != null) {
        // 로컬에만 있는 경우
        merged[id] = localAnswer;
      } else if (remoteAnswer != null) {
        // 원격에만 있는 경우
        merged[id] = remoteAnswer;
      }
    }

    return merged.values.toList();
  }

  // ==================== 레슨 데이터 동기화 ====================

  /// 레슨 데이터 업로드
  Future<void> uploadLessons(String accountId, List<Lesson> lessons) async {
    try {
      Logger.info('레슨 데이터 업로드 시작: ${lessons.length}개', tag: 'LearningProgressSyncService');

      await _lessonRepository.saveToFirebase(accountId, lessons);

      Logger.info('레슨 데이터 업로드 완료', tag: 'LearningProgressSyncService');
    } catch (e, stackTrace) {
      Logger.error(
        '레슨 데이터 업로드 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'LearningProgressSyncService',
      );
      rethrow;
    }
  }

  /// 레슨 데이터 다운로드
  Future<void> downloadLessons(String accountId) async {
    try {
      Logger.info('레슨 데이터 다운로드 시작', tag: 'LearningProgressSyncService');

      final remoteLessons = await _lessonRepository.getFromFirebase(accountId);

      if (remoteLessons != null && remoteLessons.isNotEmpty) {
        final localLessons = await _lessonRepository.getFromLocal('lessons_$accountId');

        // 병합: 기본 정보는 Firebase, 진행률은 로컬 우선
        if (localLessons != null) {
          final mergedLessons = await _lessonRepository.mergeData(localLessons, remoteLessons);
          if (mergedLessons != null) {
            await _lessonRepository.saveToLocal('lessons_$accountId', mergedLessons);
          }
        } else {
          await _lessonRepository.saveToLocal('lessons_$accountId', remoteLessons);
        }

        Logger.info('레슨 데이터 다운로드 완료: ${remoteLessons.length}개', tag: 'LearningProgressSyncService');
      } else {
        Logger.debug('Firebase에 레슨 데이터 없음: $accountId', tag: 'LearningProgressSyncService');
      }
    } catch (e, stackTrace) {
      Logger.error(
        '레슨 데이터 다운로드 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'LearningProgressSyncService',
      );
      rethrow;
    }
  }

  /// 양방향 동기화 (업로드 + 다운로드)
  Future<void> bidirectionalSync(String accountId) async {
    try {
      Logger.info('학습 데이터 양방향 동기화 시작: $accountId', tag: 'LearningProgressSyncService');

      // 1. 오답 업로드
      await uploadAllWrongAnswers(accountId);

      // 2. 레슨 업로드
      final lessons = await _lessonRepository.getFromLocal('lessons_$accountId');
      if (lessons != null && lessons.isNotEmpty) {
        await uploadLessons(accountId, lessons);
      }

      // 3. 오답 다운로드 (병합)
      await downloadWrongAnswers(accountId);

      // 4. 레슨 다운로드 (병합)
      await downloadLessons(accountId);

      Logger.info('학습 데이터 양방향 동기화 완료', tag: 'LearningProgressSyncService');
    } catch (e, stackTrace) {
      Logger.error(
        '학습 데이터 양방향 동기화 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'LearningProgressSyncService',
      );
      rethrow;
    }
  }
}
