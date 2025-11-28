import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt_pkg;
import 'package:crypto/crypto.dart';
import '../../shared/utils/logger.dart';

/// 데이터 암호화 서비스
///
/// AES-256 암호화를 사용하여 민감한 데이터를 안전하게 저장
/// 암호화 키는 디바이스 ID를 기반으로 생성되어 각 디바이스마다 고유
class EncryptionService {
  // Singleton 패턴
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal() {
    _initializeEncryption();
  }

  late encrypt_pkg.Encrypter _encrypter;
  late encrypt_pkg.IV _iv;

  /// 암호화 초기화
  ///
  /// 디바이스 ID를 기반으로 암호화 키와 IV 생성
  void _initializeEncryption() {
    try {
      // 앱 고유 키 (실제 배포 시에는 더 안전한 방법으로 관리)
      // TODO: 프로덕션 환경에서는 flutter_secure_storage 사용 고려
      const String appSecret = 'MathLab-App-2024-Secure-Key-v1';

      // 디바이스별 고유 키 생성 (실제로는 디바이스 ID 사용 필요)
      // TODO: device_info_plus 패키지로 실제 디바이스 ID 가져오기
      final String deviceId = 'default-device-id'; // 임시

      // 키와 IV 생성
      final keyString = '$appSecret:$deviceId';
      final keyBytes = sha256.convert(utf8.encode(keyString)).bytes;
      final key = encrypt_pkg.Key(Uint8List.fromList(keyBytes));

      final ivString = deviceId.padRight(16, '0').substring(0, 16);
      final iv = encrypt_pkg.IV.fromUtf8(ivString);

      _encrypter = encrypt_pkg.Encrypter(encrypt_pkg.AES(key, mode: encrypt_pkg.AESMode.cbc));
      _iv = iv;

      Logger.info('암호화 서비스 초기화 완료', tag: 'EncryptionService');
    } catch (e, stackTrace) {
      Logger.error(
        '암호화 서비스 초기화 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'EncryptionService',
      );
      rethrow;
    }
  }

  /// 문자열 암호화
  ///
  /// [plainText] 평문 문자열
  /// Returns Base64로 인코딩된 암호화된 문자열
  String encrypt(String plainText) {
    try {
      final encrypted = _encrypter.encrypt(plainText, iv: _iv);
      final encryptedText = encrypted.base64;

      Logger.debug('데이터 암호화 완료: ${plainText.length}자 → ${encryptedText.length}자', tag: 'EncryptionService');
      return encryptedText;
    } catch (e, stackTrace) {
      Logger.error(
        '데이터 암호화 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'EncryptionService',
      );
      rethrow;
    }
  }

  /// 문자열 복호화
  ///
  /// [encryptedText] Base64로 인코딩된 암호화된 문자열
  /// Returns 복호화된 평문 문자열
  String decrypt(String encryptedText) {
    try {
      final encrypted = encrypt_pkg.Encrypted.fromBase64(encryptedText);
      final decrypted = _encrypter.decrypt(encrypted, iv: _iv);

      Logger.debug('데이터 복호화 완료: ${encryptedText.length}자 → ${decrypted.length}자', tag: 'EncryptionService');
      return decrypted;
    } catch (e, stackTrace) {
      Logger.error(
        '데이터 복호화 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'EncryptionService',
      );
      rethrow;
    }
  }

  /// JSON 객체 암호화
  ///
  /// [jsonData] 암호화할 JSON Map
  /// Returns Base64로 인코딩된 암호화된 문자열
  String encryptJson(Map<String, dynamic> jsonData) {
    try {
      final jsonString = jsonEncode(jsonData);
      return encrypt(jsonString);
    } catch (e, stackTrace) {
      Logger.error(
        'JSON 암호화 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'EncryptionService',
      );
      rethrow;
    }
  }

  /// JSON 객체 복호화
  ///
  /// [encryptedText] Base64로 인코딩된 암호화된 문자열
  /// Returns 복호화된 JSON Map
  Map<String, dynamic> decryptJson(String encryptedText) {
    try {
      final jsonString = decrypt(encryptedText);
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e, stackTrace) {
      Logger.error(
        'JSON 복호화 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'EncryptionService',
      );
      rethrow;
    }
  }

  /// 문자열 해시 생성 (비밀번호 등)
  ///
  /// [text] 해시할 문자열
  /// Returns SHA-256 해시값 (Hex 문자열)
  String hash(String text) {
    try {
      final bytes = utf8.encode(text);
      final digest = sha256.convert(bytes);
      return digest.toString();
    } catch (e, stackTrace) {
      Logger.error(
        '해시 생성 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'EncryptionService',
      );
      rethrow;
    }
  }

  /// 데이터 무결성 검증용 체크섬 생성
  ///
  /// [data] 체크섬을 생성할 데이터
  /// Returns MD5 체크섬 (Hex 문자열)
  String generateChecksum(String data) {
    try {
      final bytes = utf8.encode(data);
      final digest = md5.convert(bytes);
      return digest.toString();
    } catch (e, stackTrace) {
      Logger.error(
        '체크섬 생성 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'EncryptionService',
      );
      rethrow;
    }
  }

  /// 체크섬 검증
  ///
  /// [data] 검증할 데이터
  /// [checksum] 비교할 체크섬
  /// Returns 체크섬이 일치하면 true
  bool verifyChecksum(String data, String checksum) {
    try {
      final calculatedChecksum = generateChecksum(data);
      return calculatedChecksum == checksum;
    } catch (e, stackTrace) {
      Logger.error(
        '체크섬 검증 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'EncryptionService',
      );
      return false;
    }
  }
}
