import 'package:cloud_firestore/cloud_firestore.dart';
import '../base/base_model.dart';
import '../learning/school_level.dart';
import '../subscription/premium_tier.dart';

/// Refactored User model with improved structure and type safety
class User extends BaseDataModel with TimestampMixin, SerializableMixin, EquatableMixin {
  // Basic Information
  final String name;
  final String email;
  final String avatarUrl;
  final String currentGrade;

  // Progress & Stats
  final int level;
  final int xp;
  final int streakDays;
  final int hearts;
  final int dailyXP;

  // Timestamps
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;
  final DateTime lastXPResetDate;
  final DateTime? lastStudyDate;
  final DateTime? lastHeartUpdateTime;

  // Premium Features
  final bool isPremium;
  final PremiumTier premiumTier;
  final DateTime? premiumExpiryDate;
  final bool hasHadTrial;

  // Constants
  static const int defaultHearts = 5;
  static const int maxHearts = 5;
  static const int heartRegenMinutes = 30;
  static const int xpPerLevel = 100;
  static const int trialDays = 7;

  const User({
    required super.id,
    required this.name,
    required this.email,
    required this.createdAt,
    this.updatedAt,
    this.avatarUrl = '',
    this.currentGrade = '중1',
    this.level = 1,
    this.xp = 0,
    this.streakDays = 0,
    this.hearts = defaultHearts,
    this.dailyXP = 0,
    DateTime? lastXPResetDate,
    this.lastStudyDate,
    this.lastHeartUpdateTime,
    this.isPremium = false,
    this.premiumTier = PremiumTier.free,
    this.premiumExpiryDate,
    this.hasHadTrial = false,
  }) : lastXPResetDate = lastXPResetDate ?? createdAt;

  // ========================================
  // Factory Constructors
  // ========================================

  /// Create empty user for initial state
  factory User.empty() {
    final now = DateTime.now();
    return User(
      id: '',
      name: '',
      email: '',
      createdAt: now,
    );
  }

  /// Create guest user
  factory User.guest() {
    final now = DateTime.now();
    return User(
      id: 'guest',
      name: 'Guest User',
      email: 'guest@mathlab.app',
      createdAt: now,
    );
  }

  /// Create from JSON with type safety
  factory User.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    final createdAt = json.getDateTime('createdAt') ??
        json.getDateTime('joinDate') ??
        now;

    return User(
      id: json.getValue('id', ''),
      name: json.getValue('name', ''),
      email: json.getValue('email', ''),
      createdAt: createdAt,
      updatedAt: json.getDateTime('updatedAt'),
      avatarUrl: json.getValue('avatarUrl', ''),
      currentGrade: json.getValue('currentGrade', '중1'),
      level: json.getValue('level', 1),
      xp: json.getValue('xp', 0),
      streakDays: json.getValue('streakDays', 0),
      hearts: json.getValue('hearts', defaultHearts),
      dailyXP: json.getValue('dailyXP', 0),
      lastXPResetDate: json.getDateTime('lastXPResetDate') ?? createdAt,
      lastStudyDate: json.getDateTime('lastStudyDate'),
      lastHeartUpdateTime: json.getDateTime('lastHeartUpdateTime'),
      isPremium: json.getValue('isPremium', false),
      premiumTier: _parsePremiumTier(json['premiumTier']),
      premiumExpiryDate: json.getDateTime('premiumExpiryDate'),
      hasHadTrial: json.getValue('hasHadTrial', false),
    );
  }

  /// Create from Firestore document
  factory User.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    if (!doc.exists || doc.data() == null) {
      throw Exception('Document does not exist');
    }

    final data = doc.data()!;
    final now = DateTime.now();

    // Handle Firestore Timestamps
    DateTime? parseTimestamp(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    final createdAt = parseTimestamp(data['createdAt']) ??
        parseTimestamp(data['joinDate']) ??
        now;

    return User(
      id: doc.id,
      name: data['displayName'] ?? data['name'] ?? '',
      email: data['email'] ?? '',
      createdAt: createdAt,
      updatedAt: parseTimestamp(data['updatedAt']),
      avatarUrl: data['photoURL'] ?? data['avatarUrl'] ?? '',
      currentGrade: data['currentGrade'] ?? '중1',
      level: data['level'] ?? 1,
      xp: data['totalXP'] ?? data['xp'] ?? 0,
      streakDays: data['streak'] ?? data['streakDays'] ?? 0,
      hearts: data['hearts'] ?? defaultHearts,
      dailyXP: data['dailyXP'] ?? 0,
      lastXPResetDate: parseTimestamp(data['lastXPResetDate']) ?? createdAt,
      lastStudyDate: parseTimestamp(data['lastStudyDate']),
      lastHeartUpdateTime: parseTimestamp(data['lastHeartUpdateTime']),
      isPremium: data['isPremium'] ?? false,
      premiumTier: _parsePremiumTier(data['premiumTier']),
      premiumExpiryDate: parseTimestamp(data['premiumExpiryDate']),
      hasHadTrial: data['hasHadTrial'] ?? false,
    );
  }

  // ========================================
  // Serialization Methods
  // ========================================

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'avatarUrl': avatarUrl,
      'currentGrade': currentGrade,
      'level': level,
      'xp': xp,
      'streakDays': streakDays,
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

  @override
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': name,
      'photoURL': avatarUrl,
      'currentGrade': currentGrade,
      'level': level,
      'totalXP': xp,
      'streak': streakDays,
      'hearts': hearts,
      'dailyXP': dailyXP,
      'lastXPResetDate': Timestamp.fromDate(lastXPResetDate),
      'lastStudyDate': lastStudyDate != null ? Timestamp.fromDate(lastStudyDate!) : null,
      'lastHeartUpdateTime': lastHeartUpdateTime != null ? Timestamp.fromDate(lastHeartUpdateTime!) : null,
      'isPremium': isPremium,
      'premiumTier': premiumTier.value,
      'premiumExpiryDate': premiumExpiryDate != null ? Timestamp.fromDate(premiumExpiryDate!) : null,
      'hasHadTrial': hasHadTrial,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.now(),
    };
  }

  // ========================================
  // CopyWith Method
  // ========================================

  @override
  User copyWith({
    String? id,
    String? name,
    String? email,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? avatarUrl,
    String? currentGrade,
    int? level,
    int? xp,
    int? streakDays,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      currentGrade: currentGrade ?? this.currentGrade,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      streakDays: streakDays ?? this.streakDays,
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
  // Computed Properties
  // ========================================

  /// Check if user is authenticated
  bool get isAuthenticated => id.isNotEmpty && id != 'guest';

  /// Check if user is guest
  bool get isGuest => id == 'guest';

  /// Check if premium is currently active
  bool get isPremiumActive {
    if (!isPremium) return false;
    if (premiumTier == PremiumTier.lifetime) return true;
    if (premiumExpiryDate == null) return false;
    return DateTime.now().isBefore(premiumExpiryDate!);
  }

  /// Check if user can start trial
  bool get canStartTrial => !hasHadTrial && !isPremium;

  /// Days remaining for premium
  int get premiumDaysRemaining {
    if (premiumTier == PremiumTier.lifetime) return -1;
    if (premiumExpiryDate == null) return -1;
    return premiumExpiryDate!.difference(DateTime.now()).inDays;
  }

  /// Check if premium is expiring soon (within 7 days)
  bool get isPremiumExpiringSoon {
    if (premiumTier == PremiumTier.lifetime) return false;
    final days = premiumDaysRemaining;
    return days >= 0 && days <= 7;
  }

  /// Calculate current level from XP
  int get calculatedLevel => (xp / xpPerLevel).floor() + 1;

  /// XP needed for next level
  int get xpToNextLevel {
    final currentLevelXP = level * xpPerLevel;
    final progress = xp % currentLevelXP;
    return currentLevelXP - progress;
  }

  /// Progress in current level (0.0 to 1.0)
  double get levelProgress {
    final currentLevelXP = level * xpPerLevel;
    final progress = xp % currentLevelXP;
    return progress / currentLevelXP;
  }

  /// User rank based on level
  String get rank {
    if (level <= 5) return '초보자';
    if (level <= 15) return '중급자';
    if (level <= 30) return '고급자';
    if (level <= 50) return '전문가';
    if (level <= 75) return '마스터';
    if (level <= 100) return '그랜드마스터';
    return '레전드';
  }

  /// Get school level from grade
  SchoolLevel get schoolLevel => SchoolLevel.fromGrade(currentGrade);

  /// Get grade number
  int get gradeNumber => SchoolLevel.getGradeNumber(currentGrade);

  /// Check if hearts need regeneration
  bool get needsHeartRegen => hearts < maxHearts;

  /// Calculate hearts to regenerate
  int calculateHeartsToRegen() {
    if (!needsHeartRegen || lastHeartUpdateTime == null) return 0;

    final minutesSinceUpdate = DateTime.now().difference(lastHeartUpdateTime!).inMinutes;
    final heartsToRegen = (minutesSinceUpdate / heartRegenMinutes).floor();
    final maxRegen = maxHearts - hearts;

    return heartsToRegen > maxRegen ? maxRegen : heartsToRegen;
  }

  /// Time until next heart regeneration
  Duration? get timeUntilNextHeart {
    if (!needsHeartRegen || lastHeartUpdateTime == null) return null;

    final minutesSinceUpdate = DateTime.now().difference(lastHeartUpdateTime!).inMinutes;
    final remainingMinutes = heartRegenMinutes - (minutesSinceUpdate % heartRegenMinutes);

    return Duration(minutes: remainingMinutes);
  }

  /// Check if daily XP should be reset
  bool get shouldResetDailyXP {
    final now = DateTime.now();
    return now.day != lastXPResetDate.day ||
        now.month != lastXPResetDate.month ||
        now.year != lastXPResetDate.year;
  }

  /// Check if streak is maintained
  bool get isStreakMaintained {
    if (lastStudyDate == null) return false;

    final now = DateTime.now();
    final daysSinceLastStudy = now.difference(lastStudyDate!).inDays;

    return daysSinceLastStudy <= 1;
  }

  // ========================================
  // Equality Implementation
  // ========================================

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        createdAt,
        updatedAt,
        avatarUrl,
        currentGrade,
        level,
        xp,
        streakDays,
        hearts,
        dailyXP,
        lastXPResetDate,
        lastStudyDate,
        lastHeartUpdateTime,
        isPremium,
        premiumTier,
        premiumExpiryDate,
        hasHadTrial,
      ];

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, level: $level, xp: $xp, streak: $streakDays)';
  }

  // ========================================
  // Private Helper Methods
  // ========================================

  static PremiumTier _parsePremiumTier(dynamic value) {
    if (value == null) return PremiumTier.free;
    if (value is PremiumTier) return value;
    if (value is String) {
      try {
        return PremiumTier.fromString(value);
      } catch (_) {
        return PremiumTier.free;
      }
    }
    return PremiumTier.free;
  }
}