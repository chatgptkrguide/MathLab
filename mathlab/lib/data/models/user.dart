/// 사용자 정보 모델
class User {
  final String id;
  final String name;
  final String email;
  final DateTime joinDate;
  final int level;
  final int xp;
  final int streakDays;
  final String currentGrade; // 중1, 중2, 고1 등
  final String avatarUrl;
  final int hearts; // 하트 (생명) 수

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.joinDate,
    required this.level,
    required this.xp,
    required this.streakDays,
    required this.currentGrade,
    required this.avatarUrl,
    this.hearts = 5, // 기본 하트 5개
  });

  /// JSON으로부터 User 객체 생성
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      joinDate: DateTime.parse(json['joinDate'] as String),
      level: json['level'] as int,
      xp: json['xp'] as int,
      streakDays: json['streakDays'] as int,
      currentGrade: json['currentGrade'] as String,
      avatarUrl: json['avatarUrl'] as String,
      hearts: json['hearts'] as int? ?? 5,
    );
  }

  /// User 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'joinDate': joinDate.toIso8601String(),
      'level': level,
      'xp': xp,
      'streakDays': streakDays,
      'currentGrade': currentGrade,
      'avatarUrl': avatarUrl,
      'hearts': hearts,
    };
  }

  /// User 객체 복사 (일부 값 변경)
  User copyWith({
    String? id,
    String? name,
    String? email,
    DateTime? joinDate,
    int? level,
    int? xp,
    int? streakDays,
    String? currentGrade,
    String? avatarUrl,
    int? hearts,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      joinDate: joinDate ?? this.joinDate,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      streakDays: streakDays ?? this.streakDays,
      currentGrade: currentGrade ?? this.currentGrade,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      hearts: hearts ?? this.hearts,
    );
  }

  /// 다음 레벨까지 필요한 XP 계산
  int get xpToNextLevel {
    // 레벨당 필요한 XP = 현재레벨 * 100
    return (level * 100) - (xp % (level * 100));
  }

  /// 현재 레벨에서의 진행률 (0.0 ~ 1.0)
  double get levelProgress {
    final currentLevelXP = level * 100;
    final currentProgress = xp % currentLevelXP;
    return currentProgress / currentLevelXP;
  }

  /// 사용자 등급 (초보자, 중급자, 고급자 등)
  String get userGrade {
    if (level <= 5) return '초보자';
    if (level <= 15) return '중급자';
    if (level <= 30) return '고급자';
    return '전문가';
  }

  /// streak 접근자 (streakDays의 별칭)
  int get streak => streakDays;

  @override
  String toString() {
    return 'User{id: $id, name: $name, level: $level, xp: $xp}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}