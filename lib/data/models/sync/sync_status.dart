/// 동기화 상태
enum SyncState {
  /// 동기화 안 함
  idle,

  /// 동기화 중
  syncing,

  /// 동기화 성공
  success,

  /// 동기화 실패
  error,

  /// 오프라인 (대기 중)
  offline,
}

/// 동기화 상태 정보
class SyncStatus {
  final SyncState state;
  final String? message;
  final DateTime? lastSyncAt;
  final int pendingTasks;

  const SyncStatus({
    required this.state,
    this.message,
    this.lastSyncAt,
    this.pendingTasks = 0,
  });

  /// 동기화 중인지 확인
  bool get isSyncing => state == SyncState.syncing;

  /// 오프라인인지 확인
  bool get isOffline => state == SyncState.offline;

  /// 에러 상태인지 확인
  bool get hasError => state == SyncState.error;

  SyncStatus copyWith({
    SyncState? state,
    String? message,
    DateTime? lastSyncAt,
    int? pendingTasks,
  }) {
    return SyncStatus(
      state: state ?? this.state,
      message: message ?? this.message,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      pendingTasks: pendingTasks ?? this.pendingTasks,
    );
  }

  @override
  String toString() {
    return 'SyncStatus(state: $state, message: $message, lastSyncAt: $lastSyncAt, pendingTasks: $pendingTasks)';
  }
}
