// 👤 User Model
//
// Represents a MathLab user with profile information, learning progress, and gamification data.

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final AuthProvider authProvider;
  final bool isGuest;
  final bool isEmailVerified;
  final String role;

  // Profile Information
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;

  // Learning Progress
  final int level;
  final int xp;
  final int totalXp;
  final int dailyXP; // XP earned today
  final int streak;
  final int longestStreak;
  final DateTime? lastStudyDate;

  // Gamification
  final int hearts;
  final int maxHearts;
  final DateTime? lastHeartLostAt;
  final int gems;
  final String league;
  final List<String> achievements;

  // Streak Protection
  final int streakFreezes;
  final DateTime? lastFreezeUsedAt;

  // Grade
  final String currentGrade;

  // Settings
  final String preferredLanguage;
  final bool notificationsEnabled;
  final bool soundEnabled;
  final int dailyGoalMinutes;

  // Notification Settings
  final bool dailyReminderEnabled;
  final int reminderHour;
  final int reminderMinute;
  final bool streakReminderEnabled;
  final bool achievementAlertEnabled;
  final bool weeklyReportEnabled;

  const UserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.phoneNumber,
    required this.authProvider,
    this.isGuest = false,
    this.isEmailVerified = false,
    this.role = 'user',
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
    this.level = 1,
    this.xp = 0,
    this.totalXp = 0,
    this.dailyXP = 0,
    this.streak = 0,
    this.longestStreak = 0,
    this.lastStudyDate,
    this.hearts = 5,
    this.maxHearts = 5,
    this.lastHeartLostAt,
    this.gems = 0,
    this.league = 'Bronze',
    this.achievements = const [],
    this.streakFreezes = 0,
    this.lastFreezeUsedAt,
    this.currentGrade = '중1',
    this.preferredLanguage = 'ko',
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.dailyGoalMinutes = 10,
    this.dailyReminderEnabled = true,
    this.reminderHour = 20,
    this.reminderMinute = 0,
    this.streakReminderEnabled = true,
    this.achievementAlertEnabled = true,
    this.weeklyReportEnabled = true,
  });

  // ========================================
  // Factory Constructors
  // ========================================

  /// Create user from Firebase Auth data
  factory UserModel.fromFirebase({
    required String uid,
    required AuthProvider provider,
    String? email,
    String? displayName,
    String? photoUrl,
    bool isEmailVerified = false,
  }) {
    final now = DateTime.now();
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      authProvider: provider,
      isEmailVerified: isEmailVerified,
      createdAt: now,
      updatedAt: now,
      lastLoginAt: now,
    );
  }

  /// Create guest user
  factory UserModel.guest(String uid) {
    final now = DateTime.now();
    return UserModel(
      uid: uid,
      authProvider: AuthProvider.guest,
      isGuest: true,
      displayName: '게스트',
      createdAt: now,
      updatedAt: now,
      lastLoginAt: now,
    );
  }

  /// Create user from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModel(
      uid: doc.id,
      email: data['email'],
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      phoneNumber: data['phoneNumber'],
      authProvider: AuthProvider.values.firstWhere(
        (e) => e.name == data['authProvider'],
        orElse: () => AuthProvider.email,
      ),
      isGuest: data['isGuest'] ?? false,
      isEmailVerified: data['isEmailVerified'] ?? false,
      role: data['role'] as String? ?? 'user',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      lastLoginAt: data['lastLoginAt'] != null
          ? (data['lastLoginAt'] as Timestamp).toDate()
          : null,
      level: data['level'] ?? 1,
      xp: data['xp'] ?? 0,
      totalXp: data['totalXp'] ?? 0,
      dailyXP: data['dailyXP'] ?? 0,
      streak: data['streak'] ?? 0,
      longestStreak: data['longestStreak'] ?? 0,
      lastStudyDate: data['lastStudyDate'] != null
          ? (data['lastStudyDate'] as Timestamp).toDate()
          : null,
      hearts: data['hearts'] ?? 5,
      maxHearts: data['maxHearts'] ?? 5,
      lastHeartLostAt: data['lastHeartLostAt'] != null
          ? (data['lastHeartLostAt'] as Timestamp).toDate()
          : null,
      gems: data['gems'] ?? 0,
      league: data['league'] ?? 'Bronze',
      achievements: List<String>.from(data['achievements'] ?? []),
      streakFreezes: data['streakFreezes'] ?? 0,
      lastFreezeUsedAt: data['lastFreezeUsedAt'] != null
          ? (data['lastFreezeUsedAt'] as Timestamp).toDate()
          : null,
      currentGrade: data['currentGrade'] as String? ?? '중1',
      preferredLanguage: data['preferredLanguage'] ?? 'ko',
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      soundEnabled: data['soundEnabled'] ?? true,
      dailyGoalMinutes: data['dailyGoalMinutes'] ?? 10,
      dailyReminderEnabled: data['dailyReminderEnabled'] ?? true,
      reminderHour: data['reminderHour'] ?? 20,
      reminderMinute: data['reminderMinute'] ?? 0,
      streakReminderEnabled: data['streakReminderEnabled'] ?? true,
      achievementAlertEnabled: data['achievementAlertEnabled'] ?? true,
      weeklyReportEnabled: data['weeklyReportEnabled'] ?? true,
    );
  }

  // ========================================
  // Serialization
  // ========================================

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'authProvider': authProvider.name,
      'isGuest': isGuest,
      'isEmailVerified': isEmailVerified,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'level': level,
      'xp': xp,
      'totalXp': totalXp,
      'dailyXP': dailyXP,
      'streak': streak,
      'longestStreak': longestStreak,
      'lastStudyDate': lastStudyDate != null ? Timestamp.fromDate(lastStudyDate!) : null,
      'hearts': hearts,
      'maxHearts': maxHearts,
      'lastHeartLostAt': lastHeartLostAt != null ? Timestamp.fromDate(lastHeartLostAt!) : null,
      'gems': gems,
      'league': league,
      'achievements': achievements,
      'streakFreezes': streakFreezes,
      'lastFreezeUsedAt': lastFreezeUsedAt != null ? Timestamp.fromDate(lastFreezeUsedAt!) : null,
      'currentGrade': currentGrade,
      'preferredLanguage': preferredLanguage,
      'notificationsEnabled': notificationsEnabled,
      'soundEnabled': soundEnabled,
      'dailyGoalMinutes': dailyGoalMinutes,
      'dailyReminderEnabled': dailyReminderEnabled,
      'reminderHour': reminderHour,
      'reminderMinute': reminderMinute,
      'streakReminderEnabled': streakReminderEnabled,
      'achievementAlertEnabled': achievementAlertEnabled,
      'weeklyReportEnabled': weeklyReportEnabled,
    };
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'authProvider': authProvider.name,
      'isGuest': isGuest,
      'isEmailVerified': isEmailVerified,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'level': level,
      'xp': xp,
      'totalXp': totalXp,
      'dailyXP': dailyXP,
      'streak': streak,
      'longestStreak': longestStreak,
      'lastStudyDate': lastStudyDate?.toIso8601String(),
      'hearts': hearts,
      'maxHearts': maxHearts,
      'lastHeartLostAt': lastHeartLostAt?.toIso8601String(),
      'gems': gems,
      'league': league,
      'achievements': achievements,
      'streakFreezes': streakFreezes,
      'lastFreezeUsedAt': lastFreezeUsedAt?.toIso8601String(),
      'currentGrade': currentGrade,
      'preferredLanguage': preferredLanguage,
      'notificationsEnabled': notificationsEnabled,
      'soundEnabled': soundEnabled,
      'dailyGoalMinutes': dailyGoalMinutes,
      'dailyReminderEnabled': dailyReminderEnabled,
      'reminderHour': reminderHour,
      'reminderMinute': reminderMinute,
      'streakReminderEnabled': streakReminderEnabled,
      'achievementAlertEnabled': achievementAlertEnabled,
      'weeklyReportEnabled': weeklyReportEnabled,
    };
  }

  // ========================================
  // Copy With
  // ========================================

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    AuthProvider? authProvider,
    bool? isGuest,
    bool? isEmailVerified,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    int? level,
    int? xp,
    int? totalXp,
    int? dailyXP,
    int? streak,
    int? longestStreak,
    DateTime? lastStudyDate,
    int? hearts,
    int? maxHearts,
    DateTime? lastHeartLostAt,
    int? gems,
    String? league,
    List<String>? achievements,
    int? streakFreezes,
    DateTime? lastFreezeUsedAt,
    String? currentGrade,
    String? preferredLanguage,
    bool? notificationsEnabled,
    bool? soundEnabled,
    int? dailyGoalMinutes,
    bool? dailyReminderEnabled,
    int? reminderHour,
    int? reminderMinute,
    bool? streakReminderEnabled,
    bool? achievementAlertEnabled,
    bool? weeklyReportEnabled,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      authProvider: authProvider ?? this.authProvider,
      isGuest: isGuest ?? this.isGuest,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      totalXp: totalXp ?? this.totalXp,
      dailyXP: dailyXP ?? this.dailyXP,
      streak: streak ?? this.streak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
      hearts: hearts ?? this.hearts,
      maxHearts: maxHearts ?? this.maxHearts,
      lastHeartLostAt: lastHeartLostAt ?? this.lastHeartLostAt,
      gems: gems ?? this.gems,
      league: league ?? this.league,
      achievements: achievements ?? this.achievements,
      streakFreezes: streakFreezes ?? this.streakFreezes,
      lastFreezeUsedAt: lastFreezeUsedAt ?? this.lastFreezeUsedAt,
      currentGrade: currentGrade ?? this.currentGrade,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      streakReminderEnabled: streakReminderEnabled ?? this.streakReminderEnabled,
      achievementAlertEnabled: achievementAlertEnabled ?? this.achievementAlertEnabled,
      weeklyReportEnabled: weeklyReportEnabled ?? this.weeklyReportEnabled,
    );
  }

  // ========================================
  // Business Logic Helpers
  // ========================================

  /// Check if user is admin
  bool get isAdmin => role == 'admin';

  /// Check if user needs to update streak
  bool get shouldUpdateStreak {
    if (lastStudyDate == null) return true;

    final now = DateTime.now();
    final difference = now.difference(lastStudyDate!);

    // If last study was today, no need to update
    if (difference.inHours < 24 && lastStudyDate!.day == now.day) {
      return false;
    }

    // If last study was yesterday, should update (continue streak)
    // If last study was more than 1 day ago, should update (break streak)
    return true;
  }

  /// Check if streak should be broken
  bool get shouldBreakStreak {
    if (lastStudyDate == null) return false;

    final now = DateTime.now();
    final daysSinceLastStudy = now.difference(lastStudyDate!).inDays;

    // Break streak if more than 1 day has passed
    return daysSinceLastStudy > 1;
  }

  /// Get XP needed for next level
  int get xpNeededForNextLevel {
    // Exponential XP requirement: 100, 150, 225, 337, 505...
    return (100 * (1.5 * level)).round();
  }

  /// Get progress percentage to next level
  double get levelProgress {
    final needed = xpNeededForNextLevel;
    if (needed == 0) return 0;
    return (xp / needed).clamp(0.0, 1.0);
  }

  /// Check if user has enough hearts
  bool get hasHearts => hearts > 0;

  /// Check if hearts are full
  bool get hasFullHearts => hearts >= maxHearts;

  /// Get league tier number (0-4)
  int get leagueTier {
    switch (league.toLowerCase()) {
      case 'bronze':
        return 0;
      case 'silver':
        return 1;
      case 'gold':
        return 2;
      case 'diamond':
        return 3;
      case 'master':
        return 4;
      default:
        return 0;
    }
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, displayName: $displayName, level: $level, xp: $xp, streak: $streak)';
  }

  /// Get user id (alias for uid)
  String get id => uid;

  /// Get user instance (for compatibility with nullable UserModel?)
  UserModel get user => this;

  /// Check if user profile is complete
  /// Profile is considered complete if user has a display name
  bool get isProfileComplete {
    return displayName != null && displayName!.isNotEmpty;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}

/// Authentication Provider Enum
enum AuthProvider {
  email,
  google,
  kakao,
  guest,
}
