import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'local_storage_service.dart';

/// 임시 프로필 정보 저장 서비스
///
/// 로그인 전에 입력받은 프로필 정보를 임시로 저장하고,
/// 로그인 후 실제 계정에 연동하는 기능을 제공합니다.
class TempProfileStorage {
  static const String _tempProfileKey = 'temp_profile_data';

  final LocalStorageService _storage = LocalStorageService();

  /// 임시 프로필 정보 저장
  Future<void> saveTempProfile(TempProfileData data) async {
    await _storage.saveObject<TempProfileData>(
      key: _tempProfileKey,
      data: data,
      toJson: (profile) => profile.toJson(),
    );
  }

  /// 임시 프로필 정보 불러오기
  Future<TempProfileData?> loadTempProfile() async {
    return await _storage.loadObject<TempProfileData>(
      key: _tempProfileKey,
      fromJson: TempProfileData.fromJson,
    );
  }

  /// 임시 프로필 정보 삭제
  Future<void> clearTempProfile() async {
    await _storage.remove(_tempProfileKey);
  }

  /// 임시 프로필이 존재하는지 확인
  Future<bool> hasTempProfile() async {
    return await _storage.containsKey(_tempProfileKey);
  }
}

/// 임시 프로필 데이터 모델
class TempProfileData {
  final String name;
  final DateTime? birthDate;
  final String? gender;
  final String currentGrade;
  final String? schoolName;
  final String? bio;

  const TempProfileData({
    required this.name,
    this.birthDate,
    this.gender,
    required this.currentGrade,
    this.schoolName,
    this.bio,
  });

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'birthDate': birthDate?.toIso8601String(),
      'gender': gender,
      'currentGrade': currentGrade,
      'schoolName': schoolName,
      'bio': bio,
    };
  }

  /// JSON에서 생성
  factory TempProfileData.fromJson(Map<String, dynamic> json) {
    return TempProfileData(
      name: json['name'] as String? ?? '',
      birthDate: json['birthDate'] != null && json['birthDate'] != 'null'
          ? DateTime.tryParse(json['birthDate'] as String)
          : null,
      gender: json['gender'] as String?,
      currentGrade: json['currentGrade'] as String? ?? '중1',
      schoolName: json['schoolName'] as String?,
      bio: json['bio'] as String?,
    );
  }

  /// 비어있는지 확인
  bool get isEmpty => name.isEmpty;

  /// 유효한 데이터인지 확인
  bool get isValid => name.length >= 2;

  @override
  String toString() {
    return 'TempProfileData{name: $name, birthDate: $birthDate, gender: $gender, grade: $currentGrade}';
  }
}

/// Provider
final tempProfileStorageProvider = Provider<TempProfileStorage>((ref) {
  return TempProfileStorage();
});
