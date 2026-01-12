import '../../../shared/utils/logger.dart';
import '../../models/user/user.dart';
import '../../repositories/user_repository.dart';
import '../conflict_resolution_service.dart';

/// 사용자 데이터 동기화 서비스
///
/// 역할:
/// - 사용자 프로필 업로드/다운로드
/// - 사용자 데이터 충돌 해결
class UserSyncService {
  final UserRepository _userRepository;
  final ConflictResolutionService _conflictResolver;

  UserSyncService({
    required UserRepository userRepository,
    required ConflictResolutionService conflictResolver,
  })  : _userRepository = userRepository,
        _conflictResolver = conflictResolver;

  /// 사용자 프로필 업로드
  Future<void> uploadUserProfile(String accountId, User user) async {
    try {
      Logger.info('사용자 프로필 업로드 시작: $accountId', tag: 'UserSyncService');

      await _userRepository.saveToFirebase(accountId, user);

      Logger.info('사용자 프로필 업로드 완료', tag: 'UserSyncService');
    } catch (e, stackTrace) {
      Logger.error(
        '사용자 프로필 업로드 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'UserSyncService',
      );
      rethrow;
    }
  }

  /// 사용자 프로필 다운로드
  Future<void> downloadUserProfile(String accountId) async {
    try {
      Logger.info('사용자 프로필 다운로드 시작: $accountId', tag: 'UserSyncService');

      final remoteUser = await _userRepository.getFromFirebase(accountId);

      if (remoteUser != null) {
        final localUser = await _userRepository.getFromLocal(accountId);

        // 충돌 해결 - ConflictResolutionService 사용
        if (localUser != null) {
          final resolvedData = _conflictResolver.resolveConflict(
            'user',
            accountId,
            localUser.toJson(),
            remoteUser.toJson(),
          );
          final resolvedUser = User.fromJson(resolvedData);
          await _userRepository.saveToLocal(accountId, resolvedUser);
          Logger.debug('사용자 프로필 충돌 해결 및 병합 완료', tag: 'UserSyncService');
        } else {
          await _userRepository.saveToLocal(accountId, remoteUser);
        }

        Logger.info('사용자 프로필 다운로드 완료', tag: 'UserSyncService');
      } else {
        Logger.warning('Firebase에 사용자 프로필 없음: $accountId', tag: 'UserSyncService');
      }
    } catch (e, stackTrace) {
      Logger.error(
        '사용자 프로필 다운로드 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'UserSyncService',
      );
      rethrow;
    }
  }

  /// 양방향 동기화 (업로드 + 다운로드)
  Future<void> bidirectionalSync(String accountId) async {
    try {
      Logger.info('사용자 데이터 양방향 동기화 시작: $accountId', tag: 'UserSyncService');

      // 1. 로컬 데이터 가져오기
      final localUser = await _userRepository.getFromLocal(accountId);

      if (localUser != null) {
        // 2. 로컬 → Firebase 업로드
        await uploadUserProfile(accountId, localUser);
      }

      // 3. Firebase → 로컬 다운로드 (충돌 해결 포함)
      await downloadUserProfile(accountId);

      Logger.info('사용자 데이터 양방향 동기화 완료', tag: 'UserSyncService');
    } catch (e, stackTrace) {
      Logger.error(
        '사용자 데이터 양방향 동기화 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'UserSyncService',
      );
      rethrow;
    }
  }
}
