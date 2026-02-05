// 🔄 Sync Provider
//
// Manages data synchronization and offline queue

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../services/connectivity_service.dart';
import '../services/sync_queue_service.dart';
import 'api_provider.dart';

final logger = Logger();

/// Connectivity Service Provider
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Connectivity Status Provider
final connectivityProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.connectivityStream;
});

/// Sync Queue Service Provider
final syncQueueServiceProvider = Provider<SyncQueueService>((ref) {
  final service = SyncQueueService();
  service.init();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Sync State
class SyncState {
  final bool isSyncing;
  final int pendingOperations;
  final DateTime? lastSyncTime;
  final String? error;

  const SyncState({
    this.isSyncing = false,
    this.pendingOperations = 0,
    this.lastSyncTime,
    this.error,
  });

  SyncState copyWith({
    bool? isSyncing,
    int? pendingOperations,
    DateTime? lastSyncTime,
    String? error,
  }) {
    return SyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      pendingOperations: pendingOperations ?? this.pendingOperations,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      error: error ?? this.error,
    );
  }
}

/// Sync State Notifier
class SyncNotifier extends StateNotifier<SyncState> {
  final SyncQueueService _queueService;
  final ConnectivityService _connectivityService;
  final Ref _ref;
  StreamSubscription<bool>? _connectivitySubscription;

  SyncNotifier(
    this._queueService,
    this._connectivityService,
    this._ref,
  ) : super(const SyncState()) {
    _init();
  }

  void _init() {
    // Listen to connectivity changes
    _connectivitySubscription =
        _connectivityService.connectivityStream.listen((isOnline) {
      if (isOnline) {
        logger.i('Device is online, starting sync...');
        syncAll();
      } else {
        logger.w('Device is offline');
      }
    });

    // Update pending count
    _updatePendingCount();

    // Initial sync if online
    if (_connectivityService.isOnline) {
      syncAll();
    }
  }

  void _updatePendingCount() {
    state = state.copyWith(
      pendingOperations: _queueService.pendingCount,
    );
  }

  Future<void> addOperation({
    required SyncOperationType type,
    required Map<String, dynamic> data,
  }) async {
    await _queueService.addOperation(type: type, data: data);
    _updatePendingCount();

    // Try to sync immediately if online
    if (_connectivityService.isOnline && !state.isSyncing) {
      syncAll();
    }
  }

  Future<void> syncAll() async {
    if (state.isSyncing) return;

    state = state.copyWith(isSyncing: true, error: null);

    try {
      await _queueService.syncAll((operation) async {
        await _executeSyncOperation(operation);
      });

      state = state.copyWith(
        isSyncing: false,
        lastSyncTime: DateTime.now(),
        pendingOperations: _queueService.pendingCount,
      );

      logger.i('Sync completed successfully');
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        error: e.toString(),
      );
      logger.e('Sync failed: $e');
    }
  }

  Future<void> _executeSyncOperation(SyncOperation operation) async {
    final lessonAPI = _ref.read(lessonAPIProvider);
    final userAPI = _ref.read(userAPIProvider);

    switch (operation.type) {
      case SyncOperationType.submitAnswer:
        await lessonAPI.submitAnswer(
          lessonId: operation.data['lessonId'] as String,
          problemId: operation.data['problemId'] as String,
          answer: operation.data['answer'] as String,
          isCorrect: operation.data['isCorrect'] as bool,
          timeTaken: operation.data['timeTaken'] as int,
        );
        break;

      case SyncOperationType.completeLesson:
        await lessonAPI.completeLesson(
          userId: operation.data['userId'] as String,
          lessonId: operation.data['lessonId'] as String,
          score: operation.data['score'] as int,
          stars: operation.data['stars'] as int,
          accuracy: operation.data['accuracy'] as double,
        );
        break;

      case SyncOperationType.updateProgress:
        await userAPI.addXP(
          userId: operation.data['userId'] as String,
          amount: operation.data['xp'] as int,
          source: 'sync',
        );
        break;

      case SyncOperationType.claimReward:
        // Implement reward claim logic
        break;
    }
  }

  Future<void> clearQueue() async {
    await _queueService.clear();
    _updatePendingCount();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}

/// Sync Provider
final syncProvider = StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  final queueService = ref.watch(syncQueueServiceProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);

  return SyncNotifier(queueService, connectivityService, ref);
});

/// Helper function to queue operation when offline
Future<T> executeWithSync<T>({
  required Ref ref,
  required Future<T> Function() onlineOperation,
  required SyncOperationType syncType,
  required Map<String, dynamic> syncData,
}) async {
  final connectivity = ref.read(connectivityServiceProvider);
  final syncNotifier = ref.read(syncProvider.notifier);

  if (connectivity.isOnline) {
    // Execute immediately if online
    try {
      return await onlineOperation();
    } catch (e) {
      // Queue if online operation fails
      await syncNotifier.addOperation(type: syncType, data: syncData);
      rethrow;
    }
  } else {
    // Queue for later if offline
    await syncNotifier.addOperation(type: syncType, data: syncData);
    throw Exception('Offline: Operation queued for sync');
  }
}
