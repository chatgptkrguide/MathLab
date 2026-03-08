// Offline Provider
//
// Riverpod provider that manages offline/online state and
// coordinates caching between Firestore and local Hive storage.

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_logger.dart';
import '../../services/connectivity_service.dart';
import '../../services/offline_cache_service.dart';
import '../sync_provider.dart';

/// Offline cache service singleton provider
final offlineCacheServiceProvider = Provider<OfflineCacheService>((ref) {
  return OfflineCacheService();
});

/// Offline state
class OfflineState {
  final bool isOffline;
  final bool isSyncing;
  final DateTime? lastSyncTime;
  final String? error;

  const OfflineState({
    this.isOffline = false,
    this.isSyncing = false,
    this.lastSyncTime,
    this.error,
  });

  OfflineState copyWith({
    bool? isOffline,
    bool? isSyncing,
    DateTime? lastSyncTime,
    String? error,
  }) {
    return OfflineState(
      isOffline: isOffline ?? this.isOffline,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      error: error,
    );
  }
}

/// Offline notifier that monitors connectivity and manages caching
class OfflineNotifier extends StateNotifier<OfflineState> {
  final OfflineCacheService _cacheService;
  final ConnectivityService _connectivityService;
  final FirebaseFirestore _firestore;
  StreamSubscription<bool>? _connectivitySub;

  OfflineNotifier({
    required OfflineCacheService cacheService,
    required ConnectivityService connectivityService,
    FirebaseFirestore? firestore,
  })  : _cacheService = cacheService,
        _connectivityService = connectivityService,
        _firestore = firestore ?? FirebaseFirestore.instance,
        super(const OfflineState()) {
    _init();
  }

  Future<void> _init() async {
    // Initialize cache
    await _cacheService.init();

    // Set initial connectivity state
    state = state.copyWith(
      isOffline: !_connectivityService.isOnline,
      lastSyncTime: _cacheService.lastSyncTime,
    );

    // Listen to connectivity changes
    _connectivitySub =
        _connectivityService.connectivityStream.listen((isOnline) {
      state = state.copyWith(isOffline: !isOnline);

      if (isOnline) {
        AppLogger.info('Back online - syncing data', tag: 'Offline');
        syncFromFirestore();
      } else {
        AppLogger.info('Gone offline - using cached data', tag: 'Offline');
      }
    });

    // If online at startup, sync
    if (_connectivityService.isOnline) {
      await syncFromFirestore();
    }
  }

  /// Whether we are currently offline
  bool get isOffline => state.isOffline;

  /// Sync data from Firestore and update local cache
  Future<void> syncFromFirestore() async {
    if (state.isSyncing) return;
    state = state.copyWith(isSyncing: true, error: null);

    try {
      // Fetch units
      final unitsSnapshot = await _firestore.collection('units').get();
      final units = unitsSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      await _cacheService.cacheUnits(units);

      // Fetch lessons
      final lessonsSnapshot = await _firestore.collection('lessons').get();
      final lessons = lessonsSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      await _cacheService.cacheLessons(lessons);

      // Fetch problems for each lesson (batch)
      for (final lesson in lessons) {
        final lessonId = lesson['id'] as String;
        final problemsSnapshot = await _firestore
            .collection('lessons')
            .doc(lessonId)
            .collection('problems')
            .get();
        final problems = problemsSnapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();

        if (problems.isNotEmpty) {
          await _cacheService.cacheProblems(lessonId, problems);
        }
      }

      state = state.copyWith(
        isSyncing: false,
        lastSyncTime: _cacheService.lastSyncTime,
      );

      AppLogger.info(
        'Firestore sync complete: ${units.length} units, ${lessons.length} lessons',
        tag: 'Offline',
      );
    } catch (e, st) {
      AppLogger.error(
        'Firestore sync failed',
        tag: 'Offline',
        error: e,
        stackTrace: st,
      );
      state = state.copyWith(
        isSyncing: false,
        error: 'Sync failed: ${e.toString()}',
      );
    }
  }

  /// Get units - from cache if offline, from Firestore if online
  Future<List<Map<String, dynamic>>> getUnits() async {
    if (state.isOffline) {
      final cached = _cacheService.getCachedUnits();
      return cached ?? [];
    }

    try {
      final snapshot = await _firestore.collection('units').get();
      final units = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      // Update cache in background
      _cacheService.cacheUnits(units);
      return units;
    } catch (e) {
      // Fallback to cache on error
      AppLogger.warning(
        'Falling back to cached units',
        tag: 'Offline',
        error: e,
      );
      return _cacheService.getCachedUnits() ?? [];
    }
  }

  /// Get lessons - from cache if offline, from Firestore if online
  Future<List<Map<String, dynamic>>> getLessons() async {
    if (state.isOffline) {
      final cached = _cacheService.getCachedLessons();
      return cached ?? [];
    }

    try {
      final snapshot = await _firestore.collection('lessons').get();
      final lessons = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      _cacheService.cacheLessons(lessons);
      return lessons;
    } catch (e) {
      AppLogger.warning(
        'Falling back to cached lessons',
        tag: 'Offline',
        error: e,
      );
      return _cacheService.getCachedLessons() ?? [];
    }
  }

  /// Get problems for a lesson - from cache if offline
  Future<List<Map<String, dynamic>>> getProblems(String lessonId) async {
    if (state.isOffline) {
      final cached = _cacheService.getCachedProblems(lessonId);
      return cached ?? [];
    }

    try {
      final snapshot = await _firestore
          .collection('lessons')
          .doc(lessonId)
          .collection('problems')
          .get();
      final problems = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      _cacheService.cacheProblems(lessonId, problems);
      return problems;
    } catch (e) {
      AppLogger.warning(
        'Falling back to cached problems for $lessonId',
        tag: 'Offline',
        error: e,
      );
      return _cacheService.getCachedProblems(lessonId) ?? [];
    }
  }

  /// Check if cache has data available
  bool get hasCachedData => _cacheService.hasCache;

  /// Clear all cached data
  Future<void> clearCache() async {
    await _cacheService.clearCache();
    state = state.copyWith(lastSyncTime: null);
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    _cacheService.dispose();
    super.dispose();
  }
}

/// Main offline provider
final offlineProvider =
    StateNotifierProvider<OfflineNotifier, OfflineState>((ref) {
  final cacheService = ref.watch(offlineCacheServiceProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);

  return OfflineNotifier(
    cacheService: cacheService,
    connectivityService: connectivityService,
  );
});

/// Convenience provider for checking offline status
final isOfflineProvider = Provider<bool>((ref) {
  return ref.watch(offlineProvider).isOffline;
});
