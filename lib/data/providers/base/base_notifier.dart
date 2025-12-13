import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/local_storage_service.dart';
import '../../../shared/utils/logger.dart';

/// Provider 공통 기능을 제공하는 베이스 클래스
///
/// **기능:**
/// - 자동 로깅 (정보, 경고, 에러)
/// - 통합 에러 처리
/// - 공통 저장/로드 패턴
///
/// **사용 예:**
/// ```dart
/// class MyNotifier extends BaseNotifier<MyState> {
///   MyNotifier() : super(MyState.initial(), 'MyNotifier');
///
///   Future<void> doSomething() async {
///     await executeWithErrorHandling(
///       () async {
///         // 비즈니스 로직
///         logInfo('작업 완료');
///       },
///       errorMessage: '작업 실패',
///     );
///   }
/// }
/// ```
abstract class BaseNotifier<T> extends StateNotifier<T> {
  BaseNotifier(super.initialState, this.providerName);

  /// Provider 이름 (로깅 태그용)
  final String providerName;

  /// 로컬 스토리지 서비스
  final LocalStorageService storage = LocalStorageService();

  // ==================== 로깅 메서드 ====================

  /// 정보 로그
  void logInfo(String message, {Map<String, dynamic>? data}) {
    Logger.info(
      message,
      tag: providerName,
      data: data,
    );
  }

  /// 경고 로그
  void logWarning(String message, {Map<String, dynamic>? data}) {
    Logger.warning(
      message,
      tag: providerName,
      data: data,
    );
  }

  /// 에러 로그
  void logError(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    Logger.error(
      message,
      error: error,
      stackTrace: stackTrace,
      tag: providerName,
      data: data,
    );
  }

  // ==================== 에러 처리 메서드 ====================

  /// 에러 처리가 포함된 비동기 작업 실행
  ///
  /// **기능:**
  /// - try-catch 자동 처리
  /// - 에러 로깅 자동화
  /// - 선택적 폴백 값 반환
  ///
  /// **사용 예:**
  /// ```dart
  /// await executeWithErrorHandling(
  ///   () async => await apiCall(),
  ///   errorMessage: 'API 호출 실패',
  ///   fallback: () => defaultValue,
  /// );
  /// ```
  Future<R?> executeWithErrorHandling<R>(
    Future<R> Function() operation, {
    required String errorMessage,
    R Function()? fallback,
    bool rethrow = false,
  }) async {
    try {
      return await operation();
    } catch (e, stackTrace) {
      logError(
        errorMessage,
        error: e,
        stackTrace: stackTrace,
      );

      if (rethrow) {
        rethrow;
      }

      return fallback?.call();
    }
  }

  /// 에러 처리가 포함된 동기 작업 실행
  R? executeSync<R>(
    R Function() operation, {
    required String errorMessage,
    R Function()? fallback,
    bool rethrow = false,
  }) {
    try {
      return operation();
    } catch (e, stackTrace) {
      logError(
        errorMessage,
        error: e,
        stackTrace: stackTrace,
      );

      if (rethrow) {
        rethrow;
      }

      return fallback?.call();
    }
  }

  // ==================== 저장/로드 메서드 ====================

  /// 로컬 스토리지에 JSON 데이터 저장
  Future<void> saveToStorage(String key, Map<String, dynamic> data) async {
    await executeWithErrorHandling(
      () async {
        await storage.saveJson(key, data);
        logInfo('데이터 저장 완료', data: {'key': key});
      },
      errorMessage: '데이터 저장 실패',
    );
  }

  /// 로컬 스토리지에서 JSON 데이터 로드
  Future<Map<String, dynamic>?> loadFromStorage(String key) async {
    return await executeWithErrorHandling(
      () async {
        final data = await storage.getJson(key);
        if (data != null) {
          logInfo('데이터 로드 완료', data: {'key': key});
        }
        return data;
      },
      errorMessage: '데이터 로드 실패',
      fallback: () => null,
    );
  }

  /// 로컬 스토리지에서 데이터 삭제
  Future<void> deleteFromStorage(String key) async {
    await executeWithErrorHandling(
      () async {
        await storage.remove(key);
        logInfo('데이터 삭제 완료', data: {'key': key});
      },
      errorMessage: '데이터 삭제 실패',
    );
  }

  // ==================== 유틸리티 메서드 ====================

  /// State 업데이트 + 자동 저장
  ///
  /// **사용 예:**
  /// ```dart
  /// updateAndSave(
  ///   newState,
  ///   saveKey: 'user_data',
  ///   toJson: (state) => state.toJson(),
  /// );
  /// ```
  Future<void> updateAndSave(
    T newState, {
    required String saveKey,
    required Map<String, dynamic> Function(T state) toJson,
  }) async {
    state = newState;
    await saveToStorage(saveKey, toJson(newState));
  }
}
