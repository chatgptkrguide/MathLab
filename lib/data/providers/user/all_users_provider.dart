/// 👥 All Users Provider
///
/// Provides access to the list of all users in the system.
/// Used by the leaderboard to look up user details for friend requests.

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 간소화된 사용자 모델 (리더보드/친구 기능용)
class User {
  final String id;
  final String name;
  final String email;
  final DateTime joinDate;
  final int level;
  final int xp;
  final int streakDays;
  final String currentGrade;
  final String avatarUrl;
  final int hearts;
  final int dailyXP;
  final DateTime lastXPResetDate;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.joinDate,
    this.level = 1,
    this.xp = 0,
    this.streakDays = 0,
    this.currentGrade = '',
    this.avatarUrl = '',
    this.hearts = 5,
    this.dailyXP = 0,
    DateTime? lastXPResetDate,
  }) : lastXPResetDate = lastXPResetDate ?? DateTime.now();

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
    );
  }
}

/// 전체 사용자 목록 Provider
///
/// 리더보드에서 친구 요청 시 사용자 정보를 조회하기 위해 사용됩니다.
/// TODO: 실제 API/Firestore 연동 시 구현
final allUsersProvider = Provider<List<User>>((ref) {
  // MVP 단계에서는 빈 리스트 반환
  // 실제 구현 시 Firestore에서 사용자 목록을 가져옵니다
  return [];
});
