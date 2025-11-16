import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 네트워크 연결 상태
enum NetworkStatus {
  /// 온라인 (Wi-Fi 또는 모바일 데이터)
  online,

  /// 오프라인 (연결 없음)
  offline,
}

/// 네트워크 연결 상태를 관리하는 서비스
class NetworkService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<NetworkStatus> _statusController =
      StreamController<NetworkStatus>.broadcast();

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  NetworkStatus _currentStatus = NetworkStatus.offline;

  /// 현재 네트워크 상태
  NetworkStatus get currentStatus => _currentStatus;

  /// 네트워크 상태 스트림
  Stream<NetworkStatus> get statusStream => _statusController.stream;

  /// 현재 온라인 여부
  bool get isOnline => _currentStatus == NetworkStatus.online;

  /// 현재 오프라인 여부
  bool get isOffline => _currentStatus == NetworkStatus.offline;

  NetworkService() {
    _initialize();
  }

  /// 네트워크 모니터링 초기화
  Future<void> _initialize() async {
    // 현재 상태 확인
    await _checkConnectivity();

    // 연결 상태 변경 감지
    _subscription = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
    );
  }

  /// 현재 연결 상태 확인
  Future<void> _checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _onConnectivityChanged(results);
    } catch (e) {
      // 연결 확인 실패 시 오프라인으로 처리
      _updateStatus(NetworkStatus.offline);
    }
  }

  /// 연결 상태 변경 처리
  void _onConnectivityChanged(List<ConnectivityResult> results) {
    if (results.isEmpty) {
      _updateStatus(NetworkStatus.offline);
      return;
    }

    final hasConnection = results.any((result) =>
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet);

    _updateStatus(hasConnection ? NetworkStatus.online : NetworkStatus.offline);
  }

  /// 상태 업데이트 및 스트림 방출
  void _updateStatus(NetworkStatus status) {
    if (_currentStatus != status) {
      _currentStatus = status;
      _statusController.add(status);
    }
  }

  /// 수동으로 연결 상태 재확인
  Future<void> refresh() async {
    await _checkConnectivity();
  }

  /// 리소스 정리
  void dispose() {
    _subscription?.cancel();
    _statusController.close();
  }
}

/// NetworkService Provider
final networkServiceProvider = Provider<NetworkService>((ref) {
  final service = NetworkService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// 네트워크 상태 StreamProvider
final networkStatusProvider = StreamProvider<NetworkStatus>((ref) {
  final service = ref.watch(networkServiceProvider);
  return service.statusStream;
});

/// 현재 네트워크 상태 Provider (동기적 접근)
final currentNetworkStatusProvider = Provider<NetworkStatus>((ref) {
  final service = ref.watch(networkServiceProvider);
  return service.currentStatus;
});
