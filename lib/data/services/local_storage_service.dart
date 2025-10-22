import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/utils/logger.dart';

/// 로컬 저장소 서비스
/// SharedPreferences를 추상화하여 일관된 데이터 저장/로드 인터페이스 제공
class LocalStorageService {
  // Singleton 패턴
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  /// SharedPreferences 인스턴스 캐싱
  SharedPreferences? _prefs;

  /// SharedPreferences 인스턴스 가져오기
  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// JSON 객체 로드
  ///
  /// [key] 저장소 키
  /// [fromJson] JSON to Object 변환 함수
  ///
  /// Returns null if key doesn't exist or parsing fails
  Future<T?> loadObject<T>({
    required String key,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final preferences = await prefs;
      final jsonString = preferences.getString(key);

      if (jsonString == null) {
        Logger.debug('No data found for key: $key', tag: 'Storage');
        return null;
      }

      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      final object = fromJson(jsonData);

      Logger.debug('Loaded object for key: $key', tag: 'Storage');
      return object;
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to load object for key: $key',
        error: e,
        stackTrace: stackTrace,
        tag: 'Storage',
      );
      return null;
    }
  }

  /// JSON 객체 저장
  ///
  /// [key] 저장소 키
  /// [data] 저장할 객체
  /// [toJson] Object to JSON 변환 함수
  Future<bool> saveObject<T>({
    required String key,
    required T data,
    required Map<String, dynamic> Function(T) toJson,
  }) async {
    try {
      final preferences = await prefs;
      final jsonData = toJson(data);
      final jsonString = jsonEncode(jsonData);

      final success = await preferences.setString(key, jsonString);

      if (success) {
        Logger.debug('Saved object for key: $key', tag: 'Storage');
      } else {
        Logger.warning('Failed to save object for key: $key', tag: 'Storage');
      }

      return success;
    } catch (e, stackTrace) {
      Logger.error(
        'Error saving object for key: $key',
        error: e,
        stackTrace: stackTrace,
        tag: 'Storage',
      );
      return false;
    }
  }

  /// JSON 객체 리스트 로드
  Future<List<T>> loadList<T>({
    required String key,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final preferences = await prefs;
      final jsonStringList = preferences.getStringList(key);

      if (jsonStringList == null || jsonStringList.isEmpty) {
        Logger.debug('No list data found for key: $key', tag: 'Storage');
        return [];
      }

      final List<T> objects = jsonStringList.map((jsonString) {
        final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
        return fromJson(jsonData);
      }).toList();

      Logger.debug('Loaded ${objects.length} items for key: $key', tag: 'Storage');
      return objects;
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to load list for key: $key',
        error: e,
        stackTrace: stackTrace,
        tag: 'Storage',
      );
      return [];
    }
  }

  /// JSON 객체 리스트 저장
  Future<bool> saveList<T>({
    required String key,
    required List<T> data,
    required Map<String, dynamic> Function(T) toJson,
  }) async {
    try {
      final preferences = await prefs;
      final jsonStringList = data.map((item) {
        final jsonData = toJson(item);
        return jsonEncode(jsonData);
      }).toList();

      final success = await preferences.setStringList(key, jsonStringList);

      if (success) {
        Logger.debug('Saved ${data.length} items for key: $key', tag: 'Storage');
      } else {
        Logger.warning('Failed to save list for key: $key', tag: 'Storage');
      }

      return success;
    } catch (e, stackTrace) {
      Logger.error(
        'Error saving list for key: $key',
        error: e,
        stackTrace: stackTrace,
        tag: 'Storage',
      );
      return false;
    }
  }

  /// 문자열 로드
  Future<String?> getString(String key) async {
    try {
      final preferences = await prefs;
      return preferences.getString(key);
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to get string for key: $key',
        error: e,
        stackTrace: stackTrace,
        tag: 'Storage',
      );
      return null;
    }
  }

  /// 문자열 저장
  Future<bool> setString(String key, String value) async {
    try {
      final preferences = await prefs;
      return await preferences.setString(key, value);
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to set string for key: $key',
        error: e,
        stackTrace: stackTrace,
        tag: 'Storage',
      );
      return false;
    }
  }

  /// 정수 로드
  Future<int?> getInt(String key) async {
    try {
      final preferences = await prefs;
      return preferences.getInt(key);
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to get int for key: $key',
        error: e,
        stackTrace: stackTrace,
        tag: 'Storage',
      );
      return null;
    }
  }

  /// 정수 저장
  Future<bool> setInt(String key, int value) async {
    try {
      final preferences = await prefs;
      return await preferences.setString(key, value);
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to set int for key: $key',
        error: e,
        stackTrace: stackTrace,
        tag: 'Storage',
      );
      return false;
    }
  }

  /// 불리언 로드
  Future<bool?> getBool(String key) async {
    try {
      final preferences = await prefs;
      return preferences.getBool(key);
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to get bool for key: $key',
        error: e,
        stackTrace: stackTrace,
        tag: 'Storage',
      );
      return null;
    }
  }

  /// 불리언 저장
  Future<bool> setBool(String key, bool value) async {
    try {
      final preferences = await prefs;
      return await preferences.setBool(key, value);
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to set bool for key: $key',
        error: e,
        stackTrace: stackTrace,
        tag: 'Storage',
      );
      return false;
    }
  }

  /// 특정 키 삭제
  Future<bool> remove(String key) async {
    try {
      final preferences = await prefs;
      final success = await preferences.remove(key);

      if (success) {
        Logger.debug('Removed key: $key', tag: 'Storage');
      }

      return success;
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to remove key: $key',
        error: e,
        stackTrace: stackTrace,
        tag: 'Storage',
      );
      return false;
    }
  }

  /// 모든 데이터 삭제
  Future<bool> clear() async {
    try {
      final preferences = await prefs;
      final success = await preferences.clear();

      if (success) {
        Logger.warning('Cleared all storage data', tag: 'Storage');
      }

      return success;
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to clear storage',
        error: e,
        stackTrace: stackTrace,
        tag: 'Storage',
      );
      return false;
    }
  }

  /// 키 존재 여부 확인
  Future<bool> containsKey(String key) async {
    try {
      final preferences = await prefs;
      return preferences.containsKey(key);
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to check key existence: $key',
        error: e,
        stackTrace: stackTrace,
        tag: 'Storage',
      );
      return false;
    }
  }

  /// 모든 키 목록 가져오기
  Future<Set<String>> getKeys() async {
    try {
      final preferences = await prefs;
      return preferences.getKeys();
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to get all keys',
        error: e,
        stackTrace: stackTrace,
        tag: 'Storage',
      );
      return {};
    }
  }
}
