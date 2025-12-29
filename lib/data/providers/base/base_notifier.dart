import 'dart:convert';
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
  void logInfo(String message) {
    Logger.info(
      message,
      tag: providerName,
    );
  }

  /// 디버그 로그
  void logDebug(String message) {
    Logger.debug(
      message,
      tag: providerName,
    );
  }

  /// 경고 로그
  void logWarning(String message) {
    Logger.warning(
      message,
      tag: providerName,
    );
  }

  /// 에러 로그
  void logError(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    Logger.error(
      message,
      error: error,
      stackTrace: stackTrace,
      tag: providerName,
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
  R? executeSync<R>(
    R Function() operation, {
    required String errorMessage,
    R Function()? fallback,
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

  // ==================== 저장/로드 메서드 ====================

  /// 로컬 스토리지에 JSON 데이터 저장
  Future<void> saveToStorage(String key, Map<String, dynamic> data) async {
    await executeWithErrorHandling(
      () async {
        await storage.saveJson(key, data);
        logInfo('데이터 저장 완료: $key');
      },
      errorMessage: '데이터 저장 실패',
    );
  }

  /// 로컬 스토리지에서 JSON 데이터 로드
  Future<Map<String, dynamic>?> loadFromStorage(String key) async {
    return await executeWithErrorHandling<Map<String, dynamic>?>(
      () async {
        final data = await storage.getJson(key);
        if (data != null) {
          logInfo('데이터 로드 완료: $key');
        }
        return data;
      },
      errorMessage: '데이터 로드 실패',
      fallback: () => null,
    );
  }

  /// 로컬 스토리지에 List 데이터 저장
  Future<void> saveListToStorage(String key, List<Map<String, dynamic>> data) async {
    await executeWithErrorHandling(
      () async {
        final jsonString = jsonEncode(data);
        await storage.setString(key, jsonString);
        logInfo('리스트 데이터 저장 완료: $key (${data.length}개 항목)');
      },
      errorMessage: '리스트 데이터 저장 실패',
    );
  }

  /// 로컬 스토리지에서 List 데이터 로드
  Future<List<dynamic>?> loadListFromStorage(String key) async {
    return await executeWithErrorHandling<List<dynamic>?>(
      () async {
        final jsonString = await storage.getString(key);
        if (jsonString != null && jsonString.isNotEmpty) {
          final data = jsonDecode(jsonString);
          if (data is List) {
            logInfo('리스트 데이터 로드 완료: $key (${data.length}개 항목)');
            return data;
          }
        }
        return null;
      },
      errorMessage: '리스트 데이터 로드 실패',
      fallback: () => null,
    );
  }

  /// 로컬 스토리지에서 데이터 삭제
  Future<void> deleteFromStorage(String key) async {
    await executeWithErrorHandling(
      () async {
        await storage.remove(key);
        logInfo('데이터 삭제 완료: $key');
      },
      errorMessage: '데이터 삭제 실패',
    );
  }

  /// 제네릭 리스트 로드 헬퍼 메서드
  Future<List<E>> loadList<E>({
    required String key,
    required E Function(Map<String, dynamic>) fromJson,
  }) async {
    final data = await loadListFromStorage(key);
    if (data == null) return [];

    return data
        .map((item) => fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// 제네릭 리스트 저장 헬퍼 메서드
  Future<void> saveList<E>({
    required String key,
    required List<E> items,
    required Map<String, dynamic> Function(E) toJson,
  }) async {
    final data = items.map((item) => toJson(item)).toList();
    await saveListToStorage(key, data);
  }

  /// 스토리지에서 데이터 제거 (deleteFromStorage의 별칭)
  Future<void> removeFromStorage(String key) async {
    await deleteFromStorage(key);
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
