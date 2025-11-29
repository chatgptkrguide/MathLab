import 'base_repository.dart';
import '../models/user.dart';
import '../services/local_storage_service.dart';
import '../services/firestore_service.dart';
import '../../shared/utils/logger.dart';

/// 사용자 프로필 Repository
///
/// 역할:
/// - 사용자 프로필 CRUD
/// - 로컬 + Firebase 동기화
/// - 충돌 해결 (Last-Write-Wins)
class UserRepository extends BaseRepository<User> {
  UserRepository({
    required LocalStorageService localStorageService,
    required FirestoreService firestoreService,
  }) : super(
          localStorageService: localStorageService,
          firestoreService: firestoreService,
        );

  // ==================== 로컬 스토리지 ====================

  @override
  Future<User?> getFromLocal(String storageKey) async {
    try {
      final json = await localStorageService.loadMap(storageKey);

      if (json == null || json.isEmpty) {
        Logger.debug('로컬에 사용자 프로필 없음: $storageKey', tag: 'UserRepository');
        return null;
      }

      return User.fromJson(json);
    } catch (e, stackTrace) {
      Logger.error(
        '로컬 사용자 프로필 조회 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'UserRepository',
      );
      return null;
    }
  }

  @override
  Future<void> saveToLocal(String storageKey, User data) async {
    try {
      await localStorageService.saveMap(storageKey, data.toJson());
      Logger.debug('로컬에 사용자 프로필 저장 완료: $storageKey', tag: 'UserRepository');
    } catch (e, stackTrace) {
      Logger.error(
        '로컬 사용자 프로필 저장 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'UserRepository',
      );
      throw Exception('로컬 사용자 프로필 저장 실패: $e');
    }
  }

  @override
  Future<void> deleteFromLocal(String storageKey) async {
    try {
      await localStorageService.delete(storageKey);
      Logger.debug('로컬 사용자 프로필 삭제 완료: $storageKey', tag: 'UserRepository');
    } catch (e, stackTrace) {
      Logger.error(
        '로컬 사용자 프로필 삭제 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'UserRepository',
      );
    }
  }

  // ==================== Firebase ====================

  @override
  Future<User?> getFromFirebase(String accountId) async {
    try {
      // TODO: Firebase 연결 시 User ↔ UserModel 변환 또는 모델 통합 필요
      Logger.warning('Firebase 연결 미구현 - 로컬만 사용', tag: 'UserRepository');
      return null;
    } catch (e, stackTrace) {
      Logger.error(
        'Firebase 사용자 프로필 조회 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'UserRepository',
      );
      return null;
    }
  }

  @override
  Future<void> saveToFirebase(String accountId, User data) async {
    try {
      // TODO: Firebase 연결 시 User ↔ UserModel 변환 또는 모델 통합 필요
      Logger.warning('Firebase 연결 미구현 - 로컬만 사용', tag: 'UserRepository');
    } catch (e, stackTrace) {
      Logger.error(
        'Firebase 사용자 프로필 저장 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'UserRepository',
      );
      throw Exception('Firebase 사용자 프로필 저장 실패: $e');
    }
  }

  @override
  Future<void> deleteFromFirebase(String accountId) async {
    try {
      // Firestore에는 사용자 프로필 삭제 메서드가 없으므로
      // 필요 시 구현
      Logger.warning(
        'Firebase 사용자 프로필 삭제는 구현되지 않음',
        tag: 'UserRepository',
      );
    } catch (e, stackTrace) {
      Logger.error(
        'Firebase 사용자 프로필 삭제 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'UserRepository',
      );
    }
  }

  // ==================== 충돌 해결 ====================

  @override
  Future<User?> mergeData(User local, User remote) async {
    // Last-Write-Wins 전략
    // lastStudyDate 필드로 비교해서 최신 것 사용

    final localDate = local.lastStudyDate ?? local.joinDate;
    final remoteDate = remote.lastStudyDate ?? remote.joinDate;

    if (remoteDate.isAfter(localDate)) {
      Logger.debug('사용자 프로필 충돌 해결: remote 우선', tag: 'UserRepository');
      return remote;
    } else {
      Logger.debug('사용자 프로필 충돌 해결: local 우선', tag: 'UserRepository');
      return local;
    }
  }

  // ==================== 추가 메서드 ====================

  /// 사용자 프로필 실시간 감지 (Firebase Stream)
  /// TODO: Firebase 연결 시 User 타입으로 변환 필요
  Stream<User?> watchUserProfile(String uid) {
    // 현재는 로컬만 사용하므로 빈 스트림 반환
    return Stream.value(null);
  }
}
