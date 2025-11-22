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
  final int dailyXP; // 오늘 획득한 XP
  final DateTime lastXPResetDate; // 마지막 XP 리셋 날짜
  final DateTime? lastStudyDate; // 마지막 학습 날짜 (스트릭 계산용)

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
    this.dailyXP = 0, // 기본 일일 XP 0
    DateTime? lastXPResetDate,
    this.lastStudyDate, // 마지막 학습 날짜 (nullable)
  }) : lastXPResetDate = lastXPResetDate ?? joinDate;

  /// JSON으로부터 User 객체 생성
  factory User.fromJson(Map<String, dynamic> json) {
    final joinDate = DateTime.parse(json['joinDate'] as String);
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      joinDate: joinDate,
      level: json['level'] as int,
      xp: json['xp'] as int,
      streakDays: json['streakDays'] as int,
      currentGrade: json['currentGrade'] as String,
      avatarUrl: json['avatarUrl'] as String,
      hearts: json['hearts'] as int? ?? 5,
      dailyXP: json['dailyXP'] as int? ?? 0,
      lastXPResetDate: json['lastXPResetDate'] != null
          ? DateTime.parse(json['lastXPResetDate'] as String)
          : joinDate,
      lastStudyDate: json['lastStudyDate'] != null
          ? DateTime.parse(json['lastStudyDate'] as String)
          : null,
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
      'dailyXP': dailyXP,
      'lastXPResetDate': lastXPResetDate.toIso8601String(),
      'lastStudyDate': lastStudyDate?.toIso8601String(),
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
    int? dailyXP,
    DateTime? lastXPResetDate,
    DateTime? lastStudyDate,
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
      dailyXP: dailyXP ?? this.dailyXP,
      lastXPResetDate: lastXPResetDate ?? this.lastXPResetDate,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
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