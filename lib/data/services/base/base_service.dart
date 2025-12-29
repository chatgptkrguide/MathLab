import '../../../shared/utils/logger.dart';

/// 모든 서비스의 베이스 클래스
///
/// **기능:**
/// - 일관된 로깅
/// - 에러 처리 패턴
/// - 초기화 및 정리 라이프사이클
///
/// **사용 예:**
/// ```dart
/// class UserService extends BaseService {
///   UserService() : super('UserService');
///
///   @override
///   Future<void> initialize() async {
///     await super.initialize();
///     // 초기화 로직
///   }
/// }
/// ```
abstract class BaseService {
  BaseService(this.serviceName);

  /// 서비스 이름 (로깅용)
  final String serviceName;

  /// 초기화 여부
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  // ==================== 로깅 메서드 ====================

  void logInfo(String message) {
    Logger.info(message, tag: serviceName);
  }

  void logDebug(String message) {
    Logger.debug(message, tag: serviceName);
  }

  void logWarning(String message) {
    Logger.warning(message, tag: serviceName);
  }

  void logError(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    Logger.error(
      message,
      error: error,
      stackTrace: stackTrace,
      tag: serviceName,
    );
  }

  // ==================== 라이프사이클 메서드 ====================

  /// 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) {
      logWarning('Service already initialized');
      return;
    }

    logInfo('Initializing service...');
    _isInitialized = true;
  }

  /// 서비스 정리
  Future<void> dispose() async {
    if (!_isInitialized) {
      logWarning('Service not initialized');
      return;
    }

    logInfo('Disposing service...');
    _isInitialized = false;
  }

  // ==================== 에러 처리 메서드 ====================

  /// 에러 처리가 포함된 비동기 작업 실행
  Future<T?> executeWithErrorHandling<T>(
    Future<T> Function() operation, {
    required String errorMessage,
    T Function()? fallback,
    bool shouldRethrow = false,
  }) async {
    try {
      return await operation();
    } catch (e, stackTrace) {
      logError(
        errorMessage,
        error: e,
        stackTrace: stackTrace,
      );

      if (shouldRethrow) {
        rethrow;
      }

      return fallback?.call();
    }
  }

  /// 에러 처리가 포함된 동기 작업 실행
  T? executeSync<T>(
    T Function() operation, {
    required String errorMessage,
    T Function()? fallback,
    bool shouldRethrow = false,
  }) {
    try {
      return operation();
    } catch (e, stackTrace) {
      logError(
        errorMessage,
        error: e,
        stackTrace: stackTrace,
      );

      if (shouldRethrow) {
        rethrow;
      }

      return fallback?.call();
    }
  }
}

/// 싱글톤 서비스를 위한 믹스인
mixin SingletonMixin {
  static final Map<Type, dynamic> _instances = {};

  static T getInstance<T>(T Function() creator) {
    if (!_instances.containsKey(T)) {
      _instances[T] = creator();
    }
    return _instances[T] as T;
  }

  static void clearInstance<T>() {
    _instances.remove(T);
  }

  static void clearAll() {
    _instances.clear();
  }
}
