import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../shared/utils/logger.dart';

/// 보안 저장소 서비스
/// iOS Keychain 및 Android KeyStore를 사용하여 민감한 데이터를 안전하게 저장
class SecureStorageService {
  static final SecureStorageService _instance =
      SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  // ==========================================
  // 저장소 키 상수
  // ==========================================

  static const String _keyAuthToken = 'auth_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyFcmToken = 'fcm_token';
  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keyPremiumStatus = 'premium_status';
  static const String _keyLastSyncTime = 'last_sync_time';

  // ==========================================
  // 인증 토큰 관리
  // ==========================================

  /// 인증 토큰 저장
  Future<void> saveAuthToken(String token) async {
    try {
      await _storage.write(key: _keyAuthToken, value: token);
      Logger.info('인증 토큰 저장 완료', tag: 'SecureStorage');
    } catch (e, stackTrace) {
      Logger.error('인증 토큰 저장 실패',
          error: e, stackTrace: stackTrace, tag: 'SecureStorage');
      rethrow;
    }
  }

  /// 인증 토큰 조회
  Future<String?> getAuthToken() async {
    try {
      final token = await _storage.read(key: _keyAuthToken);
      if (token != null) {
        Logger.debug('인증 토큰 조회 완료', tag: 'SecureStorage');
      }
      return token;
    } catch (e, stackTrace) {
      Logger.error('인증 토큰 조회 실패',
          error: e, stackTrace: stackTrace, tag: 'SecureStorage');
      return null;
    }
  }

  /// 리프레시 토큰 저장
  Future<void> saveRefreshToken(String token) async {
    try {
      await _storage.write(key: _keyRefreshToken, value: token);
      Logger.info('리프레시 토큰 저장 완료', tag: 'SecureStorage');
    } catch (e, stackTrace) {
      Logger.error('리프레시 토큰 저장 실패',
          error: e, stackTrace: stackTrace, tag: 'SecureStorage');
      rethrow;
    }
  }

  /// 리프레시 토큰 조회
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _keyRefreshToken);
    } catch (e, stackTrace) {
      Logger.error('리프레시 토큰 조회 실패',
          error: e, stackTrace: stackTrace, tag: 'SecureStorage');
      return null;
    }
  }

  /// 모든 인증 토큰 삭제
  Future<void> deleteAuthTokens() async {
    try {
      await _storage.delete(key: _keyAuthToken);
      await _storage.delete(key: _keyRefreshToken);
      Logger.info('모든 인증 토큰 삭제 완료', tag: 'SecureStorage');
    } catch (e, stackTrace) {
      Logger.error('인증 토큰 삭제 실패',
          error: e, stackTrace: stackTrace, tag: 'SecureStorage');
    }
  }

  // ==========================================
  // 사용자 정보 관리
  // ==========================================

  /// 사용자 ID 저장
  Future<void> saveUserId(String userId) async {
    try {
      await _storage.write(key: _keyUserId, value: userId);
      Logger.info('사용자 ID 저장 완료', tag: 'SecureStorage');
    } catch (e, stackTrace) {
      Logger.error('사용자 ID 저장 실패',
          error: e, stackTrace: stackTrace, tag: 'SecureStorage');
    }
  }

  /// 사용자 ID 조회
  Future<String?> getUserId() async {
    try {
      return await _storage.read(key: _keyUserId);
    } catch (e, stackTrace) {
      Logger.error('사용자 ID 조회 실패',
          error: e, stackTrace: stackTrace, tag: 'SecureStorage');
      return null;
    }
  }

  /// 사용자 이메일 저장
  Future<void> saveUserEmail(String email) async {
    try {
      await _storage.write(key: _keyUserEmail, value: email);
      Logger.info('사용자 이메일 저장 완료', tag: 'SecureStorage');
    } catch (e, stackTrace) {
      Logger.error('사용자 이메일 저장 실패',
          error: e, stackTrace: stackTrace, tag: 'SecureStorage');
    }
  }

  /// 사용자 이메일 조회
  Future<String?> getUserEmail() async {
    try {
      return await _storage.read(key: _keyUserEmail);
    } catch (e, stackTrace) {
      Logger.error('사용자 이메일 조회 실패',
          error: e, stackTrace: stackTrace, tag: 'SecureStorage');
      return null;
    }
  }

  // ==========================================
  // FCM 토큰 관리
  // ==========================================

  /// FCM 토큰 저장
  Future<void> saveFcmToken(String token) async {
    try {
      await _storage.write(key: _keyFcmToken, value: token);
      Logger.info('FCM 토큰 저장 완료', tag: 'SecureStorage');
    } catch (e, stackTrace) {
      Logger.error('FCM 토큰 저장 실패',
          error: e, stackTrace: stackTrace, tag: 'SecureStorage');
    }
  }

  /// FCM 토큰 조회
  Future<String?> getFcmToken() async {
    try {
      return await _storage.read(key: _keyFcmToken);
    } catch (e, stackTrace) {
      Logger.error('FCM 토큰 조회 실패',
          error: e, stackTrace: stackTrace, tag: 'SecureStorage');
      return null;
    }
  }

  // ==========================================
  // 앱 설정 관리
  // ==========================================

  /// 생체 인증 활성화 상태 저장
  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      await _storage.write(
        key: _keyBiometricEnabled,
        value: enabled.toString(),
      );
      Logger.info('생체 인증 설정 저장: $enabled', tag: 'SecureStorage');
    } catch (e, stackTrace) {
      Logger.error('생체 인증 설정 저장 실패',
          error: e, stackTrace: stackTrace, tag: 'SecureStorage');
    }
  }

  /// 생체 인증 활성화 상태 조회
  Future<bool> getBiometricEnabled() async {
    try {
      final value = await _storage.read(key: _keyBiometricEnabled);
      return value == 'true';
    } catch (e, stackTrace) {
      Logger.error('생체 인증 설정 조회 실패',
          error: e, stackTrace: stackTrace, tag: 'SecureStorage');
      return false;
    }
  }

  /// 프리미엄 상태 저장
  Future<void> setPremiumStatus(bool isPremium) async {
    try {
      await _storage.write(
        key: _keyPremiumStatus,
        value: isPremium.toString(),
      );
      Logger.info('프리미엄 상태 저장: $isPremium', tag: 'SecureStorage');
    } catch (e, stackTrace) {
      Logger.error('프리미엄 상태 저장 실패',
          error: e, stackTrace: stackTrace, tag: 'SecureStorage');
    }
  }

  /// 프리미엄 상태 조회
  Future<bool> getPremiumStatus() async {
    try {
      final value = await _storage.read(key: _keyPremiumStatus);
      return value == 'true';
    } catch (e, stackTrace) {
      Logger.error('프리미엄 상태 조회 실패',
          error: e, stackTrace: stackTrace, tag: 'SecureStorage');
      return false;
    }
  }

  // ==========================================
  // 동기화 관리
  // ==========================================

  /// 마지막 동기화 시간 저장
  Future<void> setLastSyncTime(DateTime time) async {
    try {
      await _storage.write(
        key: _keyLastSyncTime,
        value: time.toIso8601String(),
      );
      Logger.info('마지막 동기화 시간 저장: $time', tag: 'SecureStorage');
    } catch (e, stackTrace) {
      Logger.error('마지막 동기화 시간 저장 실패',
          error: e, stackTrace: stackTrace, tag: 'SecureStorage');
    }
  }

  /// 마지막 동기화 시간 조회
  Future<DateTime?> getLastSyncTime() async {
    try {
      final value = await _storage.read(key: _keyLastSyncTime);
      if (value != null) {
        return DateTime.parse(value);
      }
      return null;
    } catch (e, stackTrace) {
      Logger.error('마지막 동기화 시간 조회 실패',
          error: e, stackTrace: stackTrace, tag: 'SecureStorage');
      return null;
    }
  }

  // ==========================================
  // 범용 메서드
  // ==========================================

  /// 보안 저장소에 데이터 저장
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
      Logger.debug('데이터 저장: $key', tag: 'SecureStorage');
    } catch (e, stackTrace) {
      Logger.error('데이터 저장 실패: $key',
          error: e, stackTrace: stackTrace, tag: 'SecureStorage');
      rethrow;
    }
  }

  /// 보안 저장소에서 데이터 조회
  Future<String?> read(String key) async {
    try {
      final value = await _storage.read(key: key);
      if (value != null) {
        Logger.debug('데이터 조회: $key', tag: 'SecureStorage');
      }
      return value;
    } catch (e, stackTrace) {
      Logger.error('데이터 조회 실패: $key',
          error: e, stackTrace: stackTrace, tag: 'SecureStorage');
      return null;
    }
  }

  /// 보안 저장소에서 데이터 삭제
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
      Logger.info('데이터 삭제: $key', tag: 'SecureStorage');
    } catch (e, stackTrace) {
      Logger.error('데이터 삭제 실패: $key',
          error: e, stackTrace: stackTrace, tag: 'SecureStorage');
    }
  }

  /// 보안 저장소 전체 삭제
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
      Logger.warning('보안 저장소 전체 삭제 완료', tag: 'SecureStorage');
    } catch (e, stackTrace) {
      Logger.error('보안 저장소 전체 삭제 실패',
          error: e, stackTrace: stackTrace, tag: 'SecureStorage');
    }
  }

  /// 모든 키 조회
  Future<Map<String, String>> readAll() async {
    try {
      final all = await _storage.readAll();
      Logger.debug('전체 데이터 조회 (${all.length}개)', tag: 'SecureStorage');
      return all;
    } catch (e, stackTrace) {
      Logger.error('전체 데이터 조회 실패',
          error: e, stackTrace: stackTrace, tag: 'SecureStorage');
      return {};
    }
  }

  /// 특정 키 존재 여부 확인
  Future<bool> containsKey(String key) async {
    try {
      final value = await _storage.read(key: key);
      return value != null;
    } catch (e, stackTrace) {
      Logger.error('키 존재 확인 실패: $key',
          error: e, stackTrace: stackTrace, tag: 'SecureStorage');
      return false;
    }
  }
}
