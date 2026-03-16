// 🔄 SyncManager Provider
//
// Manages offline data synchronization lifecycle.
// Wraps SyncNotifier with user-scoped initialization and cleanup.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_logger.dart';
import 'sync_provider.dart';

/// SyncManager - manages sync lifecycle per user session
class SyncManager {
  final Ref _ref;
  bool _isInitialized = false;
  String? _currentUserId;

  SyncManager(this._ref);

  bool get isInitialized => _isInitialized;

  /// Initialize sync for the given user
  Future<void> initialize(String userId) async {
    if (_isInitialized && _currentUserId == userId) return;

    // If switching users, reset first
    if (_isInitialized && _currentUserId != userId) {
      await reset();
    }

    _currentUserId = userId;
    _isInitialized = true;
    AppLogger.info(
      'SyncManager initialized for user: $userId',
      tag: 'Sync',
    );

    // Trigger initial sync of any pending offline changes
    await syncPendingChanges();
  }

  /// Sync any pending offline changes to the server
  Future<void> syncPendingChanges() async {
    if (!_isInitialized) {
      AppLogger.warning(
        'SyncManager not initialized, skipping sync',
        tag: 'Sync',
      );
      return;
    }

    try {
      final syncNotifier = _ref.read(syncProvider.notifier);
      await syncNotifier.syncAll();
      AppLogger.info('Pending changes synced successfully', tag: 'Sync');
    } catch (e) {
      AppLogger.error(
        'Failed to sync pending changes',
        error: e,
        tag: 'Sync',
      );
    }
  }

  /// Reset sync state (on logout or user switch)
  Future<void> reset() async {
    if (!_isInitialized) return;

    AppLogger.info(
      'SyncManager reset for user: $_currentUserId',
      tag: 'Sync',
    );
    _isInitialized = false;
    _currentUserId = null;
  }
}

/// SyncManager Provider
final syncManagerProvider = Provider<SyncManager>((ref) {
  final manager = SyncManager(ref);
  ref.onDispose(() => manager.reset());
  return manager;
});
