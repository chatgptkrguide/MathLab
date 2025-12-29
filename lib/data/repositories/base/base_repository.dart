import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/utils/logger.dart';
import '../../models/base/base_model.dart';

/// 저장소 작업의 결과를 나타내는 클래스
class RepositoryResult<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  const RepositoryResult._({
    this.data,
    this.error,
    this.isSuccess = true,
  });

  factory RepositoryResult.success(T data) {
    return RepositoryResult._(
      data: data,
      isSuccess: true,
    );
  }

  factory RepositoryResult.failure(String error) {
    return RepositoryResult._(
      error: error,
      isSuccess: false,
    );
  }

  bool get hasError => !isSuccess;
}

/// 모든 Repository의 베이스 클래스
///
/// **기능:**
/// - 표준화된 CRUD 작업
/// - 자동 에러 처리 및 로깅
/// - 캐싱 지원
/// - Firestore 통합
/// - 일괄 작업 지원
///
/// **사용 예:**
/// ```dart
/// class UserRepository extends BaseRepository<User> {
///   UserRepository() : super(
///     collectionPath: 'users',
///     fromFirestore: User.fromFirestore,
///     repositoryName: 'UserRepository',
///   );
/// }
/// ```
abstract class BaseRepository<T extends BaseModel> {
  BaseRepository({
    required this.collectionPath,
    required this.fromFirestore,
    required this.repositoryName,
    this.enableCache = true,
    this.cacheDuration = const Duration(minutes: 5),
  }) {
    _cache = <String, _CacheEntry<T>>{};
  }

  /// Firestore 컬렉션 경로
  final String collectionPath;

  /// Firestore 문서를 모델로 변환하는 함수
  final T Function(DocumentSnapshot<Map<String, dynamic>>) fromFirestore;

  /// 저장소 이름 (로깅용)
  final String repositoryName;

  /// 캐시 활성화 여부
  final bool enableCache;

  /// 캐시 유효 기간
  final Duration cacheDuration;

  /// Firestore 인스턴스
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  /// 컬렉션 레퍼런스
  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(collectionPath);

  /// 캐시 저장소
  late final Map<String, _CacheEntry<T>> _cache;

  // ==================== 로깅 메서드 ====================

  void _logInfo(String message) {
    Logger.info(message, tag: repositoryName);
  }

  void _logDebug(String message) {
    Logger.debug(message, tag: repositoryName);
  }

  void _logWarning(String message) {
    Logger.warning(message, tag: repositoryName);
  }

  void _logError(String message, {Object? error, StackTrace? stackTrace}) {
    Logger.error(
      message,
      error: error,
      stackTrace: stackTrace,
      tag: repositoryName,
    );
  }

  // ==================== 캐시 관리 ====================

  /// 캐시 키 생성
  String _getCacheKey(String id) => '${collectionPath}_$id';

  /// 캐시에서 데이터 조회
  T? _getFromCache(String id) {
    if (!enableCache) return null;

    final key = _getCacheKey(id);
    final entry = _cache[key];

    if (entry != null && !entry.isExpired) {
      _logDebug('Cache hit: $key');
      return entry.data;
    }

    if (entry != null && entry.isExpired) {
      _cache.remove(key);
      _logDebug('Cache expired: $key');
    }

    return null;
  }

  /// 캐시에 데이터 저장
  void _saveToCache(String id, T data) {
    if (!enableCache) return;

    final key = _getCacheKey(id);
    _cache[key] = _CacheEntry(
      data: data,
      expiresAt: DateTime.now().add(cacheDuration),
    );
    _logDebug('Cache saved: $key');
  }

  /// 캐시 무효화
  void invalidateCache([String? id]) {
    if (id != null) {
      final key = _getCacheKey(id);
      _cache.remove(key);
      _logDebug('Cache invalidated: $key');
    } else {
      _cache.clear();
      _logDebug('All cache cleared');
    }
  }

  // ==================== CRUD 작업 ====================

  /// ID로 단일 문서 조회
  Future<RepositoryResult<T>> getById(String id) async {
    try {
      // 캐시 확인
      final cached = _getFromCache(id);
      if (cached != null) {
        return RepositoryResult.success(cached);
      }

      _logDebug('Fetching document: $id');
      final doc = await _collection.doc(id).get();

      if (!doc.exists) {
        _logWarning('Document not found: $id');
        return RepositoryResult.failure('Document not found');
      }

      final data = fromFirestore(doc);
      _saveToCache(id, data);

      _logInfo('Document fetched: $id');
      return RepositoryResult.success(data);
    } catch (e, stackTrace) {
      _logError('Failed to fetch document: $id', error: e, stackTrace: stackTrace);
      return RepositoryResult.failure(e.toString());
    }
  }

  /// 모든 문서 조회
  Future<RepositoryResult<List<T>>> getAll({
    int? limit,
    Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>>)? queryBuilder,
  }) async {
    try {
      _logDebug('Fetching all documents');

      Query<Map<String, dynamic>> query = _collection;

      if (queryBuilder != null) {
        query = queryBuilder(query);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      final items = snapshot.docs.map((doc) => fromFirestore(doc)).toList();

      _logInfo('Fetched ${items.length} documents');
      return RepositoryResult.success(items);
    } catch (e, stackTrace) {
      _logError('Failed to fetch documents', error: e, stackTrace: stackTrace);
      return RepositoryResult.failure(e.toString());
    }
  }

  /// 조건부 쿼리
  Future<RepositoryResult<List<T>>> query(
    Query<Map<String, dynamic>> Function(CollectionReference<Map<String, dynamic>>) queryBuilder,
  ) async {
    try {
      _logDebug('Executing query');

      final query = queryBuilder(_collection);
      final snapshot = await query.get();
      final items = snapshot.docs.map((doc) => fromFirestore(doc)).toList();

      _logInfo('Query returned ${items.length} documents');
      return RepositoryResult.success(items);
    } catch (e, stackTrace) {
      _logError('Query failed', error: e, stackTrace: stackTrace);
      return RepositoryResult.failure(e.toString());
    }
  }

  /// 문서 생성
  Future<RepositoryResult<String>> create(T item) async {
    try {
      _logDebug('Creating document');

      final docRef = _collection.doc(item.id);
      await docRef.set(item.toFirestore());

      _saveToCache(item.id, item);
      _logInfo('Document created: ${item.id}');

      return RepositoryResult.success(item.id);
    } catch (e, stackTrace) {
      _logError('Failed to create document', error: e, stackTrace: stackTrace);
      return RepositoryResult.failure(e.toString());
    }
  }

  /// 문서 업데이트
  Future<RepositoryResult<void>> update(T item) async {
    try {
      _logDebug('Updating document: ${item.id}');

      await _collection.doc(item.id).update(item.toFirestore());

      invalidateCache(item.id);
      _logInfo('Document updated: ${item.id}');

      return RepositoryResult.success(null);
    } catch (e, stackTrace) {
      _logError('Failed to update document: ${item.id}', error: e, stackTrace: stackTrace);
      return RepositoryResult.failure(e.toString());
    }
  }

  /// 문서 삭제
  Future<RepositoryResult<void>> delete(String id) async {
    try {
      _logDebug('Deleting document: $id');

      await _collection.doc(id).delete();

      invalidateCache(id);
      _logInfo('Document deleted: $id');

      return RepositoryResult.success(null);
    } catch (e, stackTrace) {
      _logError('Failed to delete document: $id', error: e, stackTrace: stackTrace);
      return RepositoryResult.failure(e.toString());
    }
  }

  /// 문서 존재 여부 확인
  Future<bool> exists(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      return doc.exists;
    } catch (e, stackTrace) {
      _logError('Failed to check existence: $id', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  // ==================== 일괄 작업 ====================

  /// 일괄 생성
  Future<RepositoryResult<void>> createBatch(List<T> items) async {
    try {
      _logDebug('Creating ${items.length} documents in batch');

      final batch = _firestore.batch();

      for (final item in items) {
        final docRef = _collection.doc(item.id);
        batch.set(docRef, item.toFirestore());
      }

      await batch.commit();

      _logInfo('Batch created: ${items.length} documents');
      return RepositoryResult.success(null);
    } catch (e, stackTrace) {
      _logError('Batch create failed', error: e, stackTrace: stackTrace);
      return RepositoryResult.failure(e.toString());
    }
  }

  /// 일괄 업데이트
  Future<RepositoryResult<void>> updateBatch(List<T> items) async {
    try {
      _logDebug('Updating ${items.length} documents in batch');

      final batch = _firestore.batch();

      for (final item in items) {
        final docRef = _collection.doc(item.id);
        batch.update(docRef, item.toFirestore());
      }

      await batch.commit();

      // 캐시 무효화
      for (final item in items) {
        invalidateCache(item.id);
      }

      _logInfo('Batch updated: ${items.length} documents');
      return RepositoryResult.success(null);
    } catch (e, stackTrace) {
      _logError('Batch update failed', error: e, stackTrace: stackTrace);
      return RepositoryResult.failure(e.toString());
    }
  }

  /// 일괄 삭제
  Future<RepositoryResult<void>> deleteBatch(List<String> ids) async {
    try {
      _logDebug('Deleting ${ids.length} documents in batch');

      final batch = _firestore.batch();

      for (final id in ids) {
        final docRef = _collection.doc(id);
        batch.delete(docRef);
      }

      await batch.commit();

      // 캐시 무효화
      for (final id in ids) {
        invalidateCache(id);
      }

      _logInfo('Batch deleted: ${ids.length} documents');
      return RepositoryResult.success(null);
    } catch (e, stackTrace) {
      _logError('Batch delete failed', error: e, stackTrace: stackTrace);
      return RepositoryResult.failure(e.toString());
    }
  }

  // ==================== 실시간 스트림 ====================

  /// ID로 문서 실시간 스트림
  Stream<T?> watchById(String id) {
    return _collection.doc(id).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      final data = fromFirestore(snapshot);
      _saveToCache(id, data);
      return data;
    }).handleError((error, stackTrace) {
      _logError('Stream error for document: $id', error: error, stackTrace: stackTrace);
    });
  }

  /// 모든 문서 실시간 스트림
  Stream<List<T>> watchAll({
    Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>>)? queryBuilder,
  }) {
    Query<Map<String, dynamic>> query = _collection;

    if (queryBuilder != null) {
      query = queryBuilder(query);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => fromFirestore(doc)).toList();
    }).handleError((error, stackTrace) {
      _logError('Stream error for all documents', error: error, stackTrace: stackTrace);
    });
  }

  // ==================== 페이지네이션 ====================

  /// 페이지네이션 조회
  Future<RepositoryResult<PaginatedResult<T>>> getPaginated({
    int pageSize = 20,
    DocumentSnapshot? lastDocument,
    Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>>)? queryBuilder,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _collection;

      if (queryBuilder != null) {
        query = queryBuilder(query);
      }

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      query = query.limit(pageSize);

      final snapshot = await query.get();
      final items = snapshot.docs.map((doc) => fromFirestore(doc)).toList();

      final result = PaginatedResult<T>(
        items: items,
        lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
        hasMore: items.length >= pageSize,
      );

      _logInfo('Paginated query returned ${items.length} documents');
      return RepositoryResult.success(result);
    } catch (e, stackTrace) {
      _logError('Paginated query failed', error: e, stackTrace: stackTrace);
      return RepositoryResult.failure(e.toString());
    }
  }
}

/// 페이지네이션 결과
class PaginatedResult<T> {
  final List<T> items;
  final DocumentSnapshot? lastDocument;
  final bool hasMore;

  const PaginatedResult({
    required this.items,
    required this.lastDocument,
    required this.hasMore,
  });
}

/// 캐시 엔트리
class _CacheEntry<T> {
  final T data;
  final DateTime expiresAt;

  const _CacheEntry({
    required this.data,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
