import '../models/wrong_answer.dart';
import '../services/local_storage_service.dart';
import '../services/firestore_service.dart';
import '../../shared/utils/logger.dart';

/// 오답 노트 Repository
///
/// 역할:
/// - 오답 목록 관리
/// - 로컬 + Firebase 동기화
/// - 병합 전략: 양쪽 데이터 통합 (중복 제거)
///
/// Note: BaseRepository를 상속하지 않고 독립적으로 구현
/// (오답은 리스트로 관리하므로 단일 객체 Repository 패턴과 다름)
class WrongAnswerRepository {
  final LocalStorageService localStorageService;
  final FirestoreService firestoreService;

  WrongAnswerRepository({
    required this.localStorageService,
    required this.firestoreService,
  });

  // ==================== 로컬 스토리지 ====================

  /// 로컬에서 오답 목록 조회
  Future<List<WrongAnswer>> getFromLocal(String accountId) async {
    try {
      final storageKey = 'wrong_answers_$accountId';
      final json = await localStorageService.loadMap(storageKey);

      if (json == null || json.isEmpty) {
        Logger.debug('로컬에 오답 목록 없음: $accountId', tag: 'WrongAnswerRepository');
        return [];
      }

      final answersJson = json['answers'] as List<dynamic>? ?? [];
      return answersJson
          .map((item) => WrongAnswer.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      Logger.error(
        '로컬 오답 목록 조회 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'WrongAnswerRepository',
      );
      return [];
    }
  }

  /// 로컬에 오답 목록 저장
  Future<void> saveToLocal(String accountId, List<WrongAnswer> answers) async {
    try {
      final storageKey = 'wrong_answers_$accountId';
      final json = {
        'answers': answers.map((answer) => answer.toJson()).toList(),
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      await localStorageService.saveMap(storageKey, json);
      Logger.debug('로컬에 오답 목록 저장 완료: $accountId (${answers.length}개)', tag: 'WrongAnswerRepository');
    } catch (e, stackTrace) {
      Logger.error(
        '로컬 오답 목록 저장 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'WrongAnswerRepository',
      );
      throw Exception('로컬 오답 목록 저장 실패: $e');
    }
  }

  /// 로컬에 단일 오답 추가
  Future<void> addToLocal(String accountId, WrongAnswer answer) async {
    try {
      final existingAnswers = await getFromLocal(accountId);
      existingAnswers.add(answer);
      await saveToLocal(accountId, existingAnswers);

      Logger.debug('로컬에 오답 추가: ${answer.id}', tag: 'WrongAnswerRepository');
    } catch (e, stackTrace) {
      Logger.error(
        '로컬 오답 추가 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'WrongAnswerRepository',
      );
    }
  }

  // ==================== Firebase ====================

  /// Firebase에서 오답 목록 조회
  Future<List<WrongAnswer>> getFromFirebase(String uid) async {
    try {
      final wrongAnswersData = await firestoreService.getWrongAnswers(uid);

      // TODO: Firestore에서 받은 데이터를 WrongAnswer로 변환
      // 현재는 problemId만 있으므로 실제 Problem 객체를 가져와야 함
      Logger.warning(
        'Firebase 오답 목록 조회: ${wrongAnswersData.length}개 (Problem 객체 변환 필요)',
        tag: 'WrongAnswerRepository',
      );

      return [];
    } catch (e, stackTrace) {
      Logger.error(
        'Firebase 오답 목록 조회 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'WrongAnswerRepository',
      );
      return [];
    }
  }

  /// Firebase에 단일 오답 저장
  Future<void> saveToFirebase(String uid, WrongAnswer answer) async {
    try {
      await firestoreService.saveWrongAnswer(uid, answer);
      Logger.debug('Firebase에 오답 저장: ${answer.id}', tag: 'WrongAnswerRepository');
    } catch (e, stackTrace) {
      Logger.error(
        'Firebase 오답 저장 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'WrongAnswerRepository',
      );
      throw Exception('Firebase 오답 저장 실패: $e');
    }
  }

  // ==================== 통합 메서드 ====================

  /// 오답 목록 조회 (로컬 우선 + 백그라운드 동기화)
  Future<List<WrongAnswer>> get(String accountId, {bool forceRefresh = false}) async {
    try {
      // 강제 새로고침이 아니면 로컬 먼저
      if (!forceRefresh) {
        final local = await getFromLocal(accountId);
        if (local.isNotEmpty) {
          // 백그라운드로 Firebase 동기화 (비차단)
          _syncFromFirebase(accountId);
          return local;
        }
      }

      // 로컬에 없거나 강제 새로고침이면 Firebase에서 가져오기
      final remote = await getFromFirebase(accountId);
      if (remote.isNotEmpty) {
        await saveToLocal(accountId, remote);
        return remote;
      }

      return [];
    } catch (e, stackTrace) {
      Logger.error(
        '오답 목록 조회 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'WrongAnswerRepository',
      );
      return [];
    }
  }

  /// 오답 추가 (로컬 + Firebase 동기화)
  Future<bool> add(String accountId, WrongAnswer answer) async {
    try {
      // 1. 로컬에 즉시 추가
      await addToLocal(accountId, answer);

      // 2. Firebase에 비동기 업로드
      try {
        // TODO: Firebase UID 사용
        await saveToFirebase(accountId, answer);
      } catch (e) {
        Logger.warning(
          'Firebase 오답 저장 실패 (오프라인 큐에 추가)',
          tag: 'WrongAnswerRepository',
        );
        // TODO: 오프라인 큐에 추가
      }

      return true;
    } catch (e, stackTrace) {
      Logger.error(
        '오답 추가 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'WrongAnswerRepository',
      );
      return false;
    }
  }

  /// Firebase에서 데이터 동기화 (백그라운드)
  Future<void> _syncFromFirebase(String accountId) async {
    try {
      final remote = await getFromFirebase(accountId);
      if (remote.isNotEmpty) {
        final local = await getFromLocal(accountId);

        // 병합: 양쪽 데이터 통합 (중복 제거)
        final merged = _mergeWrongAnswers(local, remote);
        await saveToLocal(accountId, merged);

        Logger.debug('오답 목록 동기화 완료: ${merged.length}개', tag: 'WrongAnswerRepository');
      }
    } catch (e) {
      Logger.debug('Firebase 동기화 실패 (무시됨)', tag: 'WrongAnswerRepository');
    }
  }

  /// 오답 목록 병합 (중복 제거)
  List<WrongAnswer> _mergeWrongAnswers(List<WrongAnswer> local, List<WrongAnswer> remote) {
    final Map<String, WrongAnswer> merged = {};

    // 로컬 데이터 추가
    for (final answer in local) {
      merged[answer.id] = answer;
    }

    // 원격 데이터 추가 (중복 시 최신 것 사용)
    for (final answer in remote) {
      final existing = merged[answer.id];
      if (existing == null) {
        merged[answer.id] = answer;
      } else {
        // 복습 횟수가 많은 것 우선
        if (answer.reviewCount > existing.reviewCount) {
          merged[answer.id] = answer;
        }
      }
    }

    return merged.values.toList();
  }

  /// 오답 실시간 감지 (Firebase Stream)
  Stream<List<Map<String, dynamic>>> watchWrongAnswers(String uid) {
    return firestoreService.watchWrongAnswers(uid);
  }
}
