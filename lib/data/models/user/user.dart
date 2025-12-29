import 'package:cloud_firestore/cloud_firestore.dart';
import '../learning/school_level.dart';
import '../subscription/premium_tier.dart';

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
  final DateTime? lastHeartUpdateTime; // 마지막 하트 업데이트 시간 (재생 계산용)

  // ====== 프리미엄 관련 필드 ======
  final bool isPremium; // 프리미엄 사용자 여부
  final PremiumTier premiumTier; // 프리미엄 등급 (free/monthly/yearly/lifetime)
  final DateTime? premiumExpiryDate; // 프리미엄 만료일 (평생 구독은 null)
  final bool hasHadTrial; // 무료 체험 사용 이력 (체험은 1회만 가능)

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
    this.lastHeartUpdateTime, // 마지막 하트 업데이트 시간 (nullable)
    this.isPremium = false, // 기본값: 무료 사용자
    this.premiumTier = PremiumTier.free, // 기본값: 무료 등급
    this.premiumExpiryDate, // 기본값: null (무료 사용자는 만료일 없음)
    this.hasHadTrial = false, // 기본값: 체험 사용 안 함
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
      lastHeartUpdateTime: json['lastHeartUpdateTime'] != null
          ? DateTime.parse(json['lastHeartUpdateTime'] as String)
          : null,
      isPremium: json['isPremium'] as bool? ?? false,
      premiumTier: json['premiumTier'] != null
          ? PremiumTier.fromString(json['premiumTier'] as String)
          : PremiumTier.free,
      premiumExpiryDate: json['premiumExpiryDate'] != null
          ? DateTime.parse(json['premiumExpiryDate'] as String)
          : null,
      hasHadTrial: json['hasHadTrial'] as bool? ?? false,
    );
  }

  /// Firestore DocumentSnapshot으로부터 User 객체 생성
  factory User.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

    return User(
      id: doc.id,
      name: data['displayName'] as String? ?? data['name'] as String? ?? '',
      email: data['email'] as String,
      joinDate: createdAt,
      level: data['level'] as int? ?? 1,
      xp: data['totalXP'] as int? ?? 0,
      streakDays: data['streak'] as int? ?? 0,
      currentGrade: data['currentGrade'] as String? ?? '중1',
      avatarUrl: data['photoURL'] as String? ?? data['avatarUrl'] as String? ?? '',
      hearts: data['hearts'] as int? ?? 5,
      dailyXP: data['dailyXP'] as int? ?? 0,
      lastXPResetDate: (data['lastXPResetDate'] as Timestamp?)?.toDate() ?? createdAt,
      lastStudyDate: (data['lastStudyDate'] as Timestamp?)?.toDate(),
      lastHeartUpdateTime: (data['lastHeartUpdateTime'] as Timestamp?)?.toDate(),
      isPremium: data['isPremium'] as bool? ?? false,
      premiumTier: data['premiumTier'] != null
          ? PremiumTier.fromString(data['premiumTier'] as String)
          : PremiumTier.free,
      premiumExpiryDate: (data['premiumExpiryDate'] as Timestamp?)?.toDate(),
      hasHadTrial: data['hasHadTrial'] as bool? ?? false,
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
      'lastHeartUpdateTime': lastHeartUpdateTime?.toIso8601String(),
      'isPremium': isPremium,
      'premiumTier': premiumTier.value,
      'premiumExpiryDate': premiumExpiryDate?.toIso8601String(),
      'hasHadTrial': hasHadTrial,
    };
  }

  /// Firestore에 저장할 데이터로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': name,
      'name': name,
      'photoURL': avatarUrl,
      'avatarUrl': avatarUrl,
      'currentGrade': currentGrade,
      'totalXP': xp,
      'level': level,
      'streak': streakDays,
      'streakDays': streakDays,
      'hearts': hearts,
      'dailyXP': dailyXP,
      'lastStudyDate': lastStudyDate != null ? Timestamp.fromDate(lastStudyDate!) : null,
      'lastXPResetDate': Timestamp.fromDate(lastXPResetDate),
      'lastHeartUpdateTime': lastHeartUpdateTime != null ? Timestamp.fromDate(lastHeartUpdateTime!) : null,
      'isPremium': isPremium,
      'premiumTier': premiumTier.value,
      'premiumExpiryDate': premiumExpiryDate != null ? Timestamp.fromDate(premiumExpiryDate!) : null,
      'hasHadTrial': hasHadTrial,
      'createdAt': Timestamp.fromDate(joinDate),
      'updatedAt': Timestamp.now(),
    };
  }

  /// toFirestore의 alias (backward compatibility)
  Map<String, dynamic> toFirestoreMap() => toFirestore();

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
    DateTime? lastHeartUpdateTime,
    bool? isPremium,
    PremiumTier? premiumTier,
    DateTime? premiumExpiryDate,
    bool? hasHadTrial,
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
      lastHeartUpdateTime: lastHeartUpdateTime ?? this.lastHeartUpdateTime,
      isPremium: isPremium ?? this.isPremium,
      premiumTier: premiumTier ?? this.premiumTier,
      premiumExpiryDate: premiumExpiryDate ?? this.premiumExpiryDate,
      hasHadTrial: hasHadTrial ?? this.hasHadTrial,
    );
  }

  // ========================================
  // 프리미엄 Helper Methods
  // ========================================

  /// 프리미엄이 활성 상태인지 확인
  ///
  /// 활성 조건:
  /// 1. isPremium이 true
  /// 2. 평생 구독이거나, 만료일이 미래인 경우
  bool get isPremiumActive {
    if (!isPremium) return false;
    if (premiumTier == PremiumTier.lifetime) return true;
    if (premiumExpiryDate == null) return false;
    return DateTime.now().isBefore(premiumExpiryDate!);
  }

  /// 무료 체험을 시작할 수 있는지 확인
  ///
  /// 조건:
  /// 1. 체험 이력이 없어야 함 (hasHadTrial이 false)
  /// 2. 현재 프리미엄이 아니어야 함
  bool get canStartTrial => !hasHadTrial && !isPremium;

  /// 프리미엄 만료까지 남은 일수
  ///
  /// - 평생 구독: -1 반환
  /// - 만료일 없음: -1 반환
  /// - 만료일 있음: 남은 일수 반환 (음수면 이미 만료)
  int get premiumDaysRemaining {
    if (premiumTier == PremiumTier.lifetime) return -1;
    if (premiumExpiryDate == null) return -1;
    return premiumExpiryDate!.difference(DateTime.now()).inDays;
  }

  /// 프리미엄이 곧 만료 예정인지 확인 (7일 이내)
  bool get isPremiumExpiringSoon {
    if (premiumTier == PremiumTier.lifetime) return false;
    final days = premiumDaysRemaining;
    return days >= 0 && days <= 7;
  }

  // ========================================
  // 기존 Helper Methods
  // ========================================

  /// 레벨 계산 (XP 기반) - Firestore 호환성을 위한 static 메서드
  static int calculateLevel(int xp) {
    // 레벨 = sqrt(XP / 100) + 1
    return (xp / 100).floor() + 1;
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

  /// 현재 학년의 학교급 (초등/중등/고등) 추출
  SchoolLevel get schoolLevel => SchoolLevel.fromGrade(currentGrade);

  /// 학년 번호 (1-6 또는 1-3)
  int get gradeNumber => SchoolLevel.getGradeNumber(currentGrade);

  /// photoUrl getter (avatarUrl의 alias)
  String? get photoUrl => avatarUrl.isEmpty ? null : avatarUrl;

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