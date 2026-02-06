// 👥 All Users Provider
//
// Provides access to the list of all users in the system.
// Used by the leaderboard to look up user details for friend requests.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/error/app_error.dart';
import '../../../core/utils/app_logger.dart';
import '../infrastructure/firebase_providers.dart';

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

  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      name: data['displayName'] as String? ?? '사용자',
      email: data['email'] as String? ?? '',
      joinDate: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      level: data['level'] as int? ?? 1,
      xp: data['totalXp'] as int? ?? data['xp'] as int? ?? 0,
      streakDays: data['streak'] as int? ?? 0,
      currentGrade: data['league'] as String? ?? 'Bronze',
      avatarUrl: data['photoUrl'] as String? ?? '',
      hearts: data['hearts'] as int? ?? 5,
      dailyXP: data['dailyXP'] as int? ?? 0,
    );
  }

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

/// 전체 사용자 목록 Provider (Firestore + 페이지네이션)
///
/// 리더보드에서 친구 요청 시 사용자 정보를 조회하기 위해 사용됩니다.
final allUsersProvider = FutureProvider<List<User>>((ref) async {
  final firestore = ref.read(firestoreProvider);

  try {
    final snapshot = await firestore
        .collection('users')
        .orderBy('totalXp', descending: true)
        .limit(100)
        .get();

    if (snapshot.docs.isEmpty) {
      AppLogger.info('Firestore에 사용자 없음', tag: 'AllUsers');
      return [];
    }

    final users = snapshot.docs.map((doc) => User.fromFirestore(doc)).toList();

    AppLogger.info(
      '${users.length}명 사용자 로드',
      tag: 'AllUsers',
    );
    return users;
  } catch (e, stackTrace) {
    AppErrorHandler.handle(e, stackTrace);
    AppLogger.warning(
      'Firestore 사용자 목록 로드 실패',
      tag: 'AllUsers',
    );
    return [];
  }
});
