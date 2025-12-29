import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/sync_manager.dart';
import '../../models/sync/sync_status.dart';
import '../../models/sync/sync_task.dart';
import '../../models/user/user.dart';
import '../../models/learning/lesson.dart';
import '../../models/gamification/league.dart';
import '../infrastructure/firebase_providers.dart';
import '../user/user_provider.dart';

/// SyncManager 싱글톤 인스턴스 Provider
final syncManagerProvider = Provider<SyncManager>((ref) {
  return SyncManager();
});

/// SyncManager 초기화 상태 Provider
final syncManagerInitializedProvider = FutureProvider<bool>((ref) async {
  final syncManager = ref.watch(syncManagerProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  final lessonRepository = ref.watch(lessonRepositoryProvider);
  final leagueRepository = ref.watch(leagueRepositoryProvider);

  await syncManager.initialize(
    userRepository: userRepository,
    lessonRepository: lessonRepository,
    leagueRepository: leagueRepository,
  );

  return true;
});

/// 동기화 상태 스트림 Provider
final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  final syncManager = ref.watch(syncManagerProvider);
  return syncManager.syncStatus;
});

/// 현재 동기화 상태 Provider
final currentSyncStatusProvider = Provider<SyncStatus>((ref) {
  final syncManager = ref.watch(syncManagerProvider);
  return syncManager.currentStatus;
});

/// 온라인 상태 Provider
final isOnlineProvider = Provider<bool>((ref) {
  final syncManager = ref.watch(syncManagerProvider);
  return syncManager.isOnline;
});

/// 실시간 사용자 프로필 스트림 Provider
final realtimeUserProfileProvider = StreamProvider.family<User?, String>((ref, userId) {
  final syncManager = ref.watch(syncManagerProvider);
  return syncManager.watchUserProfile(userId);
});

/// 실시간 레슨 스트림 Provider
final realtimeLessonsProvider = StreamProvider<List<Lesson>>((ref) {
  final syncManager = ref.watch(syncManagerProvider);
  return syncManager.watchLessons();
});

/// 실시간 리그 스트림 Provider
final realtimeLeagueProvider = StreamProvider.family<League?, String>((ref, userId) {
  final syncManager = ref.watch(syncManagerProvider);
  return syncManager.watchLeague(userId);
});

/// 동기화 액션 Provider (수동 동기화)
class SyncActions {
  SyncActions(this._ref);

  final Ref _ref;

  /// 초기 동기화 실행
  Future<void> initialSync() async {
    final syncManager = _ref.read(syncManagerProvider);
    final user = _ref.read(userProvider);

    if (user != null) {
      await syncManager.initialSync(user.id);
    }
  }

  /// 양방향 동기화 실행
  Future<void> bidirectionalSync() async {
    final syncManager = _ref.read(syncManagerProvider);
    final user = _ref.read(userProvider);

    if (user != null) {
      await syncManager.bidirectionalSync(user.id);
    }
  }

  /// 로컬 → Firebase 업로드
  Future<void> uploadChanges() async {
    final syncManager = _ref.read(syncManagerProvider);
    final user = _ref.read(userProvider);

    if (user != null) {
      await syncManager.uploadChanges(user.id);
    }
  }

  /// Firebase → 로컬 다운로드
  Future<void> downloadChanges() async {
    final syncManager = _ref.read(syncManagerProvider);
    final user = _ref.read(userProvider);

    if (user != null) {
      await syncManager.downloadChanges(user.id);
    }
  }

  /// 실시간 동기화 시작
  Future<void> startRealtimeSync() async {
    final syncManager = _ref.read(syncManagerProvider);
    final user = _ref.read(userProvider);

    if (user != null) {
      await syncManager.startRealtimeSync(user.id);
    }
  }

  /// 동기화 작업 큐에 추가
  Future<void> addTask(SyncTask task) async {
    final syncManager = _ref.read(syncManagerProvider);
    await syncManager.addTask(task);
  }
}

/// 동기화 액션 Provider
final syncActionsProvider = Provider<SyncActions>((ref) {
  return SyncActions(ref);
});
