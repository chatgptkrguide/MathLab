import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/utils/logger.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// 오프라인 동기화 큐 서비스
/// 오프라인 상태에서 발생한 작업을 큐에 저장하고, 온라인 상태로 전환되면 자동으로 동기화
class OfflineSyncService {
  static final OfflineSyncService _instance = OfflineSyncService._internal();
  factory OfflineSyncService() => _instance;
  OfflineSyncService._internal();

  static const String _queueKey = 'offline_sync_queue';
  static const int _maxQueueSize = 100; // 최대 큐 크기

  final Connectivity _connectivity = Connectivity();
  bool _isOnline = true;
  bool _isSyncing = false;

  /// 서비스 초기화
  Future<void> initialize() async {
    try {
      // 현재 네트워크 상태 확인
      final connectivityResult = await _connectivity.checkConnectivity();
      _isOnline = _isConnected(connectivityResult);

      // 네트워크 상태 변경 리스너
      _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);

      // 앱 시작 시 대기 중인 큐 동기화 시도
      if (_isOnline) {
        await sync();
      }

      Logger.info('오프라인 동기화 서비스 초기화 완료 (온라인: $_isOnline)', tag: 'OfflineSync');
    } catch (e, stackTrace) {
      Logger.error('오프라인 동기화 서비스 초기화 실패',
          error: e, stackTrace: stackTrace, tag: 'OfflineSync');
    }
  }

  /// 네트워크 연결 확인
  bool _isConnected(List<ConnectivityResult> results) {
    return results.any((result) =>
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet);
  }

  /// 네트워크 상태 변경 핸들러
  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final wasOnline = _isOnline;
    _isOnline = _isConnected(results);

    Logger.info(
        '네트워크 상태 변경: ${wasOnline ? "온라인" : "오프라인"} → ${_isOnline ? "온라인" : "오프라인"}',
        tag: 'OfflineSync');

    // 오프라인에서 온라인으로 전환되면 동기화 시도
    if (!wasOnline && _isOnline) {
      sync();
    }
  }

  /// 큐에 작업 추가
  Future<bool> addToQueue(SyncOperation operation) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getString(_queueKey) ?? '[]';
      final List<dynamic> queue = jsonDecode(queueJson);

      // 큐 크기 제한 확인
      if (queue.length >= _maxQueueSize) {
        Logger.warning('동기화 큐가 가득 찼습니다 (${queue.length}/$_maxQueueSize)',
            tag: 'OfflineSync');
        // 가장 오래된 항목 제거
        queue.removeAt(0);
      }

      // 새 작업 추가
      queue.add(operation.toJson());
      await prefs.setString(_queueKey, jsonEncode(queue));

      Logger.info('동기화 큐에 작업 추가: ${operation.type} (큐 크기: ${queue.length})',
          tag: 'OfflineSync');

      // 온라인 상태이면 즉시 동기화 시도
      if (_isOnline && !_isSyncing) {
        sync();
      }

      return true;
    } catch (e, stackTrace) {
      Logger.error('동기화 큐 추가 실패',
          error: e, stackTrace: stackTrace, tag: 'OfflineSync');
      return false;
    }
  }

  /// 큐 동기화 실행
  Future<void> sync() async {
    if (_isSyncing) {
      Logger.debug('이미 동기화 중입니다', tag: 'OfflineSync');
      return;
    }

    if (!_isOnline) {
      Logger.debug('오프라인 상태입니다. 동기화를 건너뜁니다', tag: 'OfflineSync');
      return;
    }

    _isSyncing = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getString(_queueKey) ?? '[]';
      final List<dynamic> queue = jsonDecode(queueJson);

      if (queue.isEmpty) {
        Logger.debug('동기화할 항목이 없습니다', tag: 'OfflineSync');
        return;
      }

      Logger.info('동기화 시작: ${queue.length}개 항목', tag: 'OfflineSync');

      final List<dynamic> failedOperations = [];
      int successCount = 0;

      // 각 작업을 순차적으로 처리
      for (final operationJson in queue) {
        try {
          final operation = SyncOperation.fromJson(operationJson);
          final success = await _executeOperation(operation);

          if (success) {
            successCount++;
          } else {
            failedOperations.add(operationJson);
          }
        } catch (e) {
          Logger.error('작업 처리 실패', error: e, tag: 'OfflineSync');
          failedOperations.add(operationJson);
        }
      }

      // 실패한 작업만 다시 큐에 저장
      await prefs.setString(_queueKey, jsonEncode(failedOperations));

      Logger.info('동기화 완료: 성공 $successCount개, 실패 ${failedOperations.length}개',
          tag: 'OfflineSync');
    } catch (e, stackTrace) {
      Logger.error('동기화 실패',
          error: e, stackTrace: stackTrace, tag: 'OfflineSync');
    } finally {
      _isSyncing = false;
    }
  }

  /// 개별 작업 실행
  Future<bool> _executeOperation(SyncOperation operation) async {
    try {
      Logger.debug('작업 실행: ${operation.type} - ${operation.endpoint}',
          tag: 'OfflineSync');

      // TODO: 실제 API 호출 로직 구현
      // final response = await dio.request(
      //   operation.endpoint,
      //   data: operation.data,
      //   options: Options(method: operation.method),
      // );
      //
      // if (response.statusCode == 200 || response.statusCode == 201) {
      //   return true;
      // }

      // 임시로 성공 처리 (실제로는 API 응답에 따라 결정)
      await Future.delayed(const Duration(milliseconds: 100));
      return true;
    } catch (e, stackTrace) {
      Logger.error('작업 실행 실패: ${operation.type}',
          error: e, stackTrace: stackTrace, tag: 'OfflineSync');
      return false;
    }
  }

  /// 큐 조회
  Future<List<SyncOperation>> getQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getString(_queueKey) ?? '[]';
      final List<dynamic> queue = jsonDecode(queueJson);

      return queue.map((json) => SyncOperation.fromJson(json)).toList();
    } catch (e, stackTrace) {
      Logger.error('큐 조회 실패',
          error: e, stackTrace: stackTrace, tag: 'OfflineSync');
      return [];
    }
  }

  /// 큐 크기 조회
  Future<int> getQueueSize() async {
    final queue = await getQueue();
    return queue.length;
  }

  /// 큐 전체 삭제
  Future<void> clearQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_queueKey);
      Logger.info('동기화 큐 전체 삭제', tag: 'OfflineSync');
    } catch (e, stackTrace) {
      Logger.error('큐 삭제 실패',
          error: e, stackTrace: stackTrace, tag: 'OfflineSync');
    }
  }

  /// 온라인 상태 확인
  bool get isOnline => _isOnline;

  /// 동기화 진행 중 확인
  bool get isSyncing => _isSyncing;
}

/// 동기화 작업 모델
class SyncOperation {
  final String id;
  final SyncOperationType type;
  final String endpoint;
  final String method; // GET, POST, PUT, DELETE
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final int retryCount;

  SyncOperation({
    required this.id,
    required this.type,
    required this.endpoint,
    required this.method,
    required this.data,
    required this.createdAt,
    this.retryCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'endpoint': endpoint,
      'method': method,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'retryCount': retryCount,
    };
  }

  factory SyncOperation.fromJson(Map<String, dynamic> json) {
    return SyncOperation(
      id: json['id'],
      type: SyncOperationType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => SyncOperationType.other,
      ),
      endpoint: json['endpoint'],
      method: json['method'],
      data: json['data'],
      createdAt: DateTime.parse(json['createdAt']),
      retryCount: json['retryCount'] ?? 0,
    );
  }

  SyncOperation copyWith({int? retryCount}) {
    return SyncOperation(
      id: id,
      type: type,
      endpoint: endpoint,
      method: method,
      data: data,
      createdAt: createdAt,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}

/// 동기화 작업 타입
enum SyncOperationType {
  problemAnswer, // 문제 답변 제출
  studySession, // 학습 세션 기록
  achievement, // 업적 달성
  userProgress, // 사용자 진행 상황
  wrongAnswer, // 오답 저장
  friendRequest, // 친구 요청
  message, // 메시지 전송
  settings, // 설정 변경
  other, // 기타
}
