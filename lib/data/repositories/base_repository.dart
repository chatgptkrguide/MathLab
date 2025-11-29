import '../services/local_storage_service.dart';
import '../services/firestore_service.dart';
import '../../shared/utils/logger.dart';

/// Repository 기본 클래스
///
/// Phase 2 아키텍처:
/// Provider → Repository → {LocalStorageService, FirestoreService}
///
/// 역할:
/// - 로컬 우선 데이터 접근 (빠른 응답)
/// - Firebase 백그라운드 동기화
/// - 충돌 해결
abstract class BaseRepository<T> {
  final LocalStorageService localStorageService;
  final FirestoreService firestoreService;

  BaseRepository({
    required this.localStorageService,
    required this.firestoreService,
  });

  // ==================== 로컬 우선 전략 ====================

  /// 데이터 조회 (로컬 우선)
  ///
  /// 1. 로컬에서 먼저 조회 (빠른 응답)
  /// 2. 백그라운드로 Firebase에서 최신 데이터 가져오기
  /// 3. 충돌 해결 후 로컬 업데이트
  Future<T?> get(String accountId, {bool forceRefresh = false}) async {
    try {
      // 강제 새로고침이 아니면 로컬 먼저
      if (!forceRefresh) {
        final local = await getFromLocal(accountId);
        if (local != null) {
          // 백그라운드로 Firebase 동기화
          _syncFromFirebase(accountId);
          return local;
        }
      }

      // 로컬에 없거나 강제 새로고침이면 Firebase에서 가져오기
      final remote = await getFromFirebase(accountId);
      if (remote != null) {
        await saveToLocal(accountId, remote);
        return remote;
      }

      return null;
    } catch (e, stackTrace) {
      Logger.error(
        '데이터 조회 실패 (Repository)',
        error: e,
        stackTrace: stackTrace,
        tag: runtimeType.toString(),
      );
      return null;
    }
  }

  /// 데이터 저장 (로컬 + Firebase 동기화)
  ///
  /// 1. 로컬에 즉시 저장 (빠른 응답)
  /// 2. Firebase에 비동기 업로드
  Future<bool> save(String accountId, T data) async {
    try {
      // 1. 로컬에 먼저 저장
      await saveToLocal(accountId, data);

      // 2. Firebase에 비동기 업로드
      try {
        await saveToFirebase(accountId, data);
      } catch (e) {
        Logger.warning(
          'Firebase 저장 실패 (오프라인 큐에 추가)',
          tag: runtimeType.toString(),
        );
        // TODO: 오프라인 큐에 추가
      }

      return true;
    } catch (e, stackTrace) {
      Logger.error(
        '데이터 저장 실패 (Repository)',
        error: e,
        stackTrace: stackTrace,
        tag: runtimeType.toString(),
      );
      return false;
    }
  }

  /// 데이터 삭제 (로컬 + Firebase)
  Future<bool> delete(String accountId) async {
    try {
      await deleteFromLocal(accountId);

      try {
        await deleteFromFirebase(accountId);
      } catch (e) {
        Logger.warning(
          'Firebase 삭제 실패',
          tag: runtimeType.toString(),
        );
      }

      return true;
    } catch (e, stackTrace) {
      Logger.error(
        '데이터 삭제 실패 (Repository)',
        error: e,
        stackTrace: stackTrace,
        tag: runtimeType.toString(),
      );
      return false;
    }
  }

  // ==================== 동기화 ====================

  /// Firebase에서 데이터 동기화 (백그라운드)
  Future<void> _syncFromFirebase(String accountId) async {
    try {
      final remote = await getFromFirebase(accountId);
      if (remote != null) {
        final local = await getFromLocal(accountId);

        // 충돌 해결
        final merged = await resolveConflict(local, remote);
        if (merged != null) {
          await saveToLocal(accountId, merged);
        }
      }
    } catch (e) {
      Logger.debug(
        'Firebase 동기화 실패 (무시됨)',
        tag: runtimeType.toString(),
      );
    }
  }

  /// 충돌 해결
  ///
  /// 기본 전략: Last-Write-Wins (최신 데이터 우선)
  /// 서브클래스에서 오버라이드 가능
  Future<T?> resolveConflict(T? local, T? remote) async {
    // 둘 중 하나만 있으면 그것 사용
    if (local == null) return remote;
    if (remote == null) return local;

    // 둘 다 있으면 최신 것 사용 (서브클래스에서 구현)
    return mergeData(local, remote);
  }

  // ==================== 추상 메서드 (서브클래스에서 구현) ====================

  /// 로컬 스토리지에서 데이터 조회
  Future<T?> getFromLocal(String accountId);

  /// 로컬 스토리지에 데이터 저장
  Future<void> saveToLocal(String accountId, T data);

  /// 로컬 스토리지에서 데이터 삭제
  Future<void> deleteFromLocal(String accountId);

  /// Firebase에서 데이터 조회
  Future<T?> getFromFirebase(String accountId);

  /// Firebase에 데이터 저장
  Future<void> saveToFirebase(String accountId, T data);

  /// Firebase에서 데이터 삭제
  Future<void> deleteFromFirebase(String accountId);

  /// 데이터 병합 (충돌 해결 시)
  Future<T?> mergeData(T local, T remote);
}
