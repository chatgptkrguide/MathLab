import 'base_repository.dart';
import '../models/user_model.dart';
import '../services/local_storage_service.dart';
import '../services/firestore_service.dart';
import '../../shared/utils/logger.dart';

/// 사용자 프로필 Repository
///
/// 역할:
/// - 사용자 프로필 CRUD
/// - 로컬 + Firebase 동기화
/// - 충돌 해결 (Last-Write-Wins)
class UserRepository extends BaseRepository<UserModel> {
  UserRepository({
    required LocalStorageService localStorageService,
    required FirestoreService firestoreService,
  }) : super(
          localStorageService: localStorageService,
          firestoreService: firestoreService,
        );

  // ==================== 로컬 스토리지 ====================

  @override
  Future<UserModel?> getFromLocal(String accountId) async {
    try {
      final storageKey = 'user_$accountId';
      final json = await localStorageService.loadMap(storageKey);

      if (json == null || json.isEmpty) {
        Logger.debug('로컬에 사용자 프로필 없음: $accountId', tag: 'UserRepository');
        return null;
      }

      return UserModel.fromJson(json);
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
  Future<void> saveToLocal(String accountId, UserModel data) async {
    try {
      final storageKey = 'user_$accountId';
      await localStorageService.saveMap(storageKey, data.toJson());
      Logger.debug('로컬에 사용자 프로필 저장 완료: $accountId', tag: 'UserRepository');
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
  Future<void> deleteFromLocal(String accountId) async {
    try {
      final storageKey = 'user_$accountId';
      await localStorageService.delete(storageKey);
      Logger.debug('로컬 사용자 프로필 삭제 완료: $accountId', tag: 'UserRepository');
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
  Future<UserModel?> getFromFirebase(String accountId) async {
    try {
      // accountId는 로컬 식별자이고, Firebase UID가 필요함
      // 실제로는 AuthProvider에서 UID를 가져와야 함
      // 현재는 accountId를 UID로 사용 (향후 수정 필요)

      return await firestoreService.getUserProfile(accountId);
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
  Future<void> saveToFirebase(String accountId, UserModel data) async {
    try {
      // TODO: 실제 Firebase UID 사용
      await firestoreService.saveUserProfile(accountId, data);
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
  Future<UserModel?> mergeData(UserModel local, UserModel remote) async {
    // Last-Write-Wins 전략
    // updatedAt 필드가 있다면 비교해서 최신 것 사용
    // 현재 UserModel에 updatedAt 필드가 없으므로 remote 우선

    Logger.debug('사용자 프로필 충돌 해결: remote 우선', tag: 'UserRepository');
    return remote;
  }

  // ==================== 추가 메서드 ====================

  /// 사용자 프로필 실시간 감지 (Firebase Stream)
  Stream<UserModel?> watchUserProfile(String uid) {
    return firestoreService.watchUserProfile(uid);
  }
}
