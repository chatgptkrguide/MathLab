/// 온보딩 과정에서 임시로 저장하는 프로필 데이터
class TempProfileData {
  final String name;
  final DateTime? birthDate;
  final String? gender;
  final String currentGrade;
  final String? schoolName;
  final String? bio;

  TempProfileData({
    required this.name,
    this.birthDate,
    this.gender,
    required this.currentGrade,
    this.schoolName,
    this.bio,
  });

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

  factory TempProfileData.fromJson(Map<String, dynamic> json) {
    return TempProfileData(
      name: json['name'] as String,
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'] as String)
          : null,
      gender: json['gender'] as String?,
      currentGrade: json['currentGrade'] as String,
      schoolName: json['schoolName'] as String?,
      bio: json['bio'] as String?,
    );
  }
}
