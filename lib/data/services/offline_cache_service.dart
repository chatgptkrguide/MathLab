// Offline Cache Service
//
// Caches lessons, problems, and units from Firestore to Hive
// for offline access when network is unavailable.

import 'dart:convert';
import 'package:hive/hive.dart';
import '../../core/utils/app_logger.dart';

class OfflineCacheService {
  static const String _unitsBoxName = 'cached_units';
  static const String _lessonsBoxName = 'cached_lessons';
  static const String _problemsBoxName = 'cached_problems';
  static const String _metaBoxName = 'cache_meta';
  static const String _lastSyncKey = 'last_sync_time';

  Box? _unitsBox;
  Box? _lessonsBox;
  Box? _problemsBox;
  Box? _metaBox;

  bool _isInitialized = false;

  /// Initialize Hive boxes for caching
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      _unitsBox = await Hive.openBox(_unitsBoxName);
      _lessonsBox = await Hive.openBox(_lessonsBoxName);
      _problemsBox = await Hive.openBox(_problemsBoxName);
      _metaBox = await Hive.openBox(_metaBoxName);
      _isInitialized = true;
      AppLogger.info('Offline cache initialized', tag: 'OfflineCache');
    } catch (e, st) {
      AppLogger.error(
        'Failed to initialize offline cache',
        tag: 'OfflineCache',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Ensure boxes are open before operations
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'OfflineCacheService not initialized. Call init() first.',
      );
    }
  }

  // ========================================
  // Units
  // ========================================

  /// Cache a list of units
  Future<void> cacheUnits(List<Map<String, dynamic>> units) async {
    _ensureInitialized();
    try {
      await _unitsBox!.clear();
      for (int i = 0; i < units.length; i++) {
        await _unitsBox!.put('unit_$i', jsonEncode(units[i]));
      }
      await _unitsBox!.put('_count', units.length);
      await _updateSyncTime();
      AppLogger.info(
        'Cached ${units.length} units',
        tag: 'OfflineCache',
      );
    } catch (e, st) {
      AppLogger.error(
        'Failed to cache units',
        tag: 'OfflineCache',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Get cached units
  List<Map<String, dynamic>>? getCachedUnits() {
    _ensureInitialized();
    try {
      final count = _unitsBox!.get('_count') as int?;
      if (count == null || count == 0) return null;

      final units = <Map<String, dynamic>>[];
      for (int i = 0; i < count; i++) {
        final raw = _unitsBox!.get('unit_$i') as String?;
        if (raw != null) {
          units.add(
            Map<String, dynamic>.from(jsonDecode(raw) as Map),
          );
        }
      }
      return units.isEmpty ? null : units;
    } catch (e, st) {
      AppLogger.error(
        'Failed to read cached units',
        tag: 'OfflineCache',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  // ========================================
  // Lessons
  // ========================================

  /// Cache a list of lessons
  Future<void> cacheLessons(List<Map<String, dynamic>> lessons) async {
    _ensureInitialized();
    try {
      await _lessonsBox!.clear();
      for (int i = 0; i < lessons.length; i++) {
        await _lessonsBox!.put('lesson_$i', jsonEncode(lessons[i]));
      }
      await _lessonsBox!.put('_count', lessons.length);
      await _updateSyncTime();
      AppLogger.info(
        'Cached ${lessons.length} lessons',
        tag: 'OfflineCache',
      );
    } catch (e, st) {
      AppLogger.error(
        'Failed to cache lessons',
        tag: 'OfflineCache',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Get cached lessons
  List<Map<String, dynamic>>? getCachedLessons() {
    _ensureInitialized();
    try {
      final count = _lessonsBox!.get('_count') as int?;
      if (count == null || count == 0) return null;

      final lessons = <Map<String, dynamic>>[];
      for (int i = 0; i < count; i++) {
        final raw = _lessonsBox!.get('lesson_$i') as String?;
        if (raw != null) {
          lessons.add(
            Map<String, dynamic>.from(jsonDecode(raw) as Map),
          );
        }
      }
      return lessons.isEmpty ? null : lessons;
    } catch (e, st) {
      AppLogger.error(
        'Failed to read cached lessons',
        tag: 'OfflineCache',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  // ========================================
  // Problems (keyed by lessonId)
  // ========================================

  /// Cache problems for a specific lesson
  Future<void> cacheProblems(
    String lessonId,
    List<Map<String, dynamic>> problems,
  ) async {
    _ensureInitialized();
    try {
      // Store problems as a JSON-encoded list under the lessonId key
      await _problemsBox!.put(lessonId, jsonEncode(problems));
      await _updateSyncTime();
      AppLogger.info(
        'Cached ${problems.length} problems for lesson $lessonId',
        tag: 'OfflineCache',
      );
    } catch (e, st) {
      AppLogger.error(
        'Failed to cache problems for lesson $lessonId',
        tag: 'OfflineCache',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Get cached problems for a specific lesson
  List<Map<String, dynamic>>? getCachedProblems(String lessonId) {
    _ensureInitialized();
    try {
      final raw = _problemsBox!.get(lessonId) as String?;
      if (raw == null) return null;

      final decoded = jsonDecode(raw) as List;
      return decoded
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    } catch (e, st) {
      AppLogger.error(
        'Failed to read cached problems for lesson $lessonId',
        tag: 'OfflineCache',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  // ========================================
  // Cache metadata
  // ========================================

  /// Get the last time data was synced from Firestore
  DateTime? get lastSyncTime {
    _ensureInitialized();
    try {
      final raw = _metaBox!.get(_lastSyncKey) as String?;
      if (raw == null) return null;
      return DateTime.parse(raw);
    } catch (e) {
      return null;
    }
  }

  /// Update the sync timestamp
  Future<void> _updateSyncTime() async {
    await _metaBox!.put(
      _lastSyncKey,
      DateTime.now().toIso8601String(),
    );
  }

  /// Check if the cache has any data
  bool get hasCache {
    _ensureInitialized();
    final unitCount = _unitsBox!.get('_count') as int?;
    final lessonCount = _lessonsBox!.get('_count') as int?;
    return (unitCount != null && unitCount > 0) ||
        (lessonCount != null && lessonCount > 0);
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    _ensureInitialized();
    try {
      await _unitsBox!.clear();
      await _lessonsBox!.clear();
      await _problemsBox!.clear();
      await _metaBox!.clear();
      AppLogger.info('Offline cache cleared', tag: 'OfflineCache');
    } catch (e, st) {
      AppLogger.error(
        'Failed to clear offline cache',
        tag: 'OfflineCache',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Close all boxes (call on app dispose)
  Future<void> dispose() async {
    try {
      await _unitsBox?.close();
      await _lessonsBox?.close();
      await _problemsBox?.close();
      await _metaBox?.close();
      _isInitialized = false;
    } catch (e) {
      AppLogger.error(
        'Failed to close cache boxes',
        tag: 'OfflineCache',
        error: e,
      );
    }
  }
}
