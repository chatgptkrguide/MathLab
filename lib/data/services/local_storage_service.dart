import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/app_logger.dart';

/// 로컬 스토리지 서비스
/// SharedPreferences를 사용하여 간단한 데이터를 로컬에 저장/로드합니다
class LocalStorageService {
  /// Map 데이터를 저장
  Future<void> saveMap(String key, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(data);
      await prefs.setString(key, jsonString);
    } catch (e) {
      AppLogger.error('Failed to save map data for key: $key', error: e);
      rethrow;
    }
  }

  /// Map 데이터를 로드
  Future<Map<String, dynamic>?> loadMap(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(key);
      if (jsonString == null) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      AppLogger.error('Failed to load map data for key: $key', error: e);
      return null;
    }
  }

  /// 문자열 데이터를 저장
  Future<void> saveString(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } catch (e) {
      AppLogger.error('Failed to save string for key: $key', error: e);
      rethrow;
    }
  }

  /// 문자열 데이터를 로드
  Future<String?> loadString(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } catch (e) {
      AppLogger.error('Failed to load string for key: $key', error: e);
      return null;
    }
  }

  /// bool 데이터를 저장
  Future<void> saveBool(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (e) {
      AppLogger.error('Failed to save bool for key: $key', error: e);
      rethrow;
    }
  }

  /// bool 데이터를 로드
  Future<bool?> loadBool(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(key);
    } catch (e) {
      AppLogger.error('Failed to load bool for key: $key', error: e);
      return null;
    }
  }

  /// int 데이터를 저장
  Future<void> saveInt(String key, int value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(key, value);
    } catch (e) {
      AppLogger.error('Failed to save int for key: $key', error: e);
      rethrow;
    }
  }

  /// int 데이터를 로드
  Future<int?> loadInt(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(key);
    } catch (e) {
      AppLogger.error('Failed to load int for key: $key', error: e);
      return null;
    }
  }

  /// 키에 해당하는 데이터 삭제
  Future<void> remove(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } catch (e) {
      AppLogger.error('Failed to remove data for key: $key', error: e);
      rethrow;
    }
  }

  /// 모든 데이터 삭제
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      AppLogger.error('Failed to clear all data', error: e);
      rethrow;
    }
  }

  /// 키 존재 여부 확인
  Future<bool> containsKey(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(key);
    } catch (e) {
      AppLogger.error('Failed to check key: $key', error: e);
      return false;
    }
  }
}
