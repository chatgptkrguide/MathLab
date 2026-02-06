// 📦 Sync Queue Service
//
// Manages offline operations queue and syncs when online

import 'dart:async';
import 'dart:convert';
import 'package:hive/hive.dart';
import '../../core/utils/app_logger.dart';

enum SyncOperationType {
  submitAnswer,
  completeLesson,
  updateProgress,
  claimReward,
}

class SyncOperation {
  final String id;
  final SyncOperationType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  int retryCount;
  String? error;

  SyncOperation({
    required this.id,
    required this.type,
    required this.data,
    required this.timestamp,
    this.retryCount = 0,
    this.error,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'data': data,
        'timestamp': timestamp.toIso8601String(),
        'retryCount': retryCount,
        'error': error,
      };

  factory SyncOperation.fromJson(Map<String, dynamic> json) {
    return SyncOperation(
      id: json['id'] as String,
      type: SyncOperationType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      data: json['data'] as Map<String, dynamic>,
      timestamp: DateTime.parse(json['timestamp'] as String),
      retryCount: json['retryCount'] as int? ?? 0,
      error: json['error'] as String?,
    );
  }
}

class SyncQueueService {
  static const String _boxName = 'sync_queue';
  static const int _maxRetries = 3;

  Box<String>? _box;
  final List<SyncOperation> _queue = [];
  bool _isSyncing = false;

  Future<void> init() async {
    _box = await Hive.openBox<String>(_boxName);
    await _loadQueue();
  }

  Future<void> _loadQueue() async {
    if (_box == null) return;

    _queue.clear();
    for (var key in _box!.keys) {
      try {
        final json = jsonDecode(_box!.get(key)!);
        _queue.add(SyncOperation.fromJson(json));
      } catch (e) {
        AppLogger.error('Failed to load sync operation: $e');
      }
    }

    AppLogger.info('Loaded ${_queue.length} pending sync operations');
  }

  Future<void> addOperation({
    required SyncOperationType type,
    required Map<String, dynamic> data,
  }) async {
    final operation = SyncOperation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      data: data,
      timestamp: DateTime.now(),
    );

    _queue.add(operation);
    await _saveOperation(operation);

    AppLogger.debug('Added sync operation: ${operation.type.name}');
  }

  Future<void> _saveOperation(SyncOperation operation) async {
    if (_box == null) return;
    await _box!.put(operation.id, jsonEncode(operation.toJson()));
  }

  Future<void> _removeOperation(String id) async {
    if (_box == null) return;
    await _box!.delete(id);
    _queue.removeWhere((op) => op.id == id);
  }

  Future<void> syncAll(Function(SyncOperation) syncFunction) async {
    if (_isSyncing || _queue.isEmpty) return;

    _isSyncing = true;
    AppLogger.info('Starting sync of ${_queue.length} operations');

    final operationsToSync = List<SyncOperation>.from(_queue);

    for (var operation in operationsToSync) {
      try {
        // Execute sync function
        await syncFunction(operation);

        // Remove from queue on success
        await _removeOperation(operation.id);
        AppLogger.debug('Synced operation: ${operation.id}');
      } catch (e) {
        // Increment retry count
        operation.retryCount++;
        operation.error = e.toString();

        if (operation.retryCount >= _maxRetries) {
          // Remove after max retries
          await _removeOperation(operation.id);
          AppLogger.error(
            'Removed operation after ${operation.retryCount} retries: ${operation.id}',
          );
        } else {
          // Save updated operation
          await _saveOperation(operation);
          AppLogger.warning(
            'Retry ${operation.retryCount}/$_maxRetries for operation: ${operation.id}',
          );
        }
      }
    }

    _isSyncing = false;
    AppLogger.info('Sync completed. ${_queue.length} operations remaining');
  }

  int get pendingCount => _queue.length;

  List<SyncOperation> get operations => List.unmodifiable(_queue);

  Future<void> clear() async {
    if (_box == null) return;
    await _box!.clear();
    _queue.clear();
    AppLogger.info('Cleared sync queue');
  }

  void dispose() {
    _box?.close();
  }
}
