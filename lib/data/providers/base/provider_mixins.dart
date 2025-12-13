import '../../../shared/utils/logger.dart';

/// 데이터 검증 믹스인
///
/// **기능:**
/// - 입력 데이터 검증
/// - Null 안전성 체크
/// - 범위 검증
mixin ValidationMixin {
  /// Null이 아닌지 검증
  T requireNonNull<T>(T? value, String fieldName) {
    if (value == null) {
      throw ArgumentError('$fieldName은(는) null일 수 없습니다');
    }
    return value;
  }

  /// 범위 내 값인지 검증
  num requireInRange(num value, num min, num max, String fieldName) {
    if (value < min || value > max) {
      throw ArgumentError('$fieldName은(는) $min~$max 범위여야 합니다 (현재: $value)');
    }
    return value;
  }

  /// 비어있지 않은 문자열인지 검증
  String requireNonEmpty(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      throw ArgumentError('$fieldName은(는) 비어있을 수 없습니다');
    }
    return value;
  }

  /// 비어있지 않은 리스트인지 검증
  List<T> requireNonEmptyList<T>(List<T>? value, String fieldName) {
    if (value == null || value.isEmpty) {
      throw ArgumentError('$fieldName 리스트는 비어있을 수 없습니다');
    }
    return value;
  }
}

/// 상태 변환 믹스인
///
/// **기능:**
/// - 로딩 상태 관리
/// - 에러 상태 관리
/// - 성공/실패 상태 전환
mixin StateTransitionMixin {
  /// 로딩 상태 플래그
  bool get isLoading;

  /// 로딩 시작
  void startLoading();

  /// 로딩 완료
  void stopLoading();

  /// 에러 상태 설정
  void setError(String message);

  /// 성공 상태 설정
  void setSuccess();
}

/// 캐싱 믹스인
///
/// **기능:**
/// - 메모리 캐시 관리
/// - 만료 시간 기반 캐시 무효화
/// - 캐시 키 관리
mixin CachingMixin {
  final Map<String, _CacheEntry> _cache = {};

  /// 캐시에 데이터 저장
  void cacheData<T>(String key, T data, {Duration? ttl}) {
    _cache[key] = _CacheEntry(
      data: data,
      expiresAt: ttl != null ? DateTime.now().add(ttl) : null,
    );
  }

  /// 캐시에서 데이터 조회
  T? getCachedData<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    // 만료 확인
    if (entry.expiresAt != null && DateTime.now().isAfter(entry.expiresAt!)) {
      _cache.remove(key);
      return null;
    }

    return entry.data as T?;
  }

  /// 캐시 무효화
  void invalidateCache(String key) {
    _cache.remove(key);
  }

  /// 전체 캐시 삭제
  void clearCache() {
    _cache.clear();
  }

  /// 캐시 통계
  Map<String, dynamic> getCacheStats() {
    final total = _cache.length;
    final expired = _cache.values.where((entry) {
      return entry.expiresAt != null && DateTime.now().isAfter(entry.expiresAt!);
    }).length;

    return {
      'total': total,
      'active': total - expired,
      'expired': expired,
    };
  }
}

/// 캐시 엔트리 (내부 사용)
class _CacheEntry {
  final dynamic data;
  final DateTime? expiresAt;

  _CacheEntry({
    required this.data,
    this.expiresAt,
  });
}

/// 배치 작업 믹스인
///
/// **기능:**
/// - 여러 작업을 그룹화하여 실행
/// - 부분 성공/실패 처리
/// - 진행률 추적
mixin BatchOperationMixin {
  /// 배치 작업 실행
  ///
  /// **반환값:** (성공 개수, 실패 개수, 에러 목록)
  Future<BatchResult> executeBatch<T>(
    List<T> items,
    Future<void> Function(T item) operation, {
    void Function(int current, int total)? onProgress,
  }) async {
    int successCount = 0;
    int failureCount = 0;
    final List<BatchError> errors = [];

    for (int i = 0; i < items.length; i++) {
      try {
        await operation(items[i]);
        successCount++;
      } catch (e, stackTrace) {
        failureCount++;
        errors.add(BatchError(
          index: i,
          item: items[i],
          error: e,
          stackTrace: stackTrace,
        ));
      }

      onProgress?.call(i + 1, items.length);
    }

    return BatchResult(
      successCount: successCount,
      failureCount: failureCount,
      errors: errors,
    );
  }
}

/// 배치 작업 결과
class BatchResult {
  final int successCount;
  final int failureCount;
  final List<BatchError> errors;

  BatchResult({
    required this.successCount,
    required this.failureCount,
    required this.errors,
  });

  bool get hasErrors => errors.isNotEmpty;
  bool get isFullSuccess => failureCount == 0;
  int get totalCount => successCount + failureCount;
  double get successRate => totalCount > 0 ? successCount / totalCount : 0.0;
}

/// 배치 에러 정보
class BatchError {
  final int index;
  final dynamic item;
  final Object error;
  final StackTrace stackTrace;

  BatchError({
    required this.index,
    required this.item,
    required this.error,
    required this.stackTrace,
  });
}
