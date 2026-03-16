// 🏆 Leaderboard Provider
//
// Manages leaderboard state across different time periods with Firestore.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/error/app_error.dart';
import '../../../core/utils/app_logger.dart';
import '../../models/league_model.dart';

/// 리더보드 상태 클래스
class LeaderboardState {
  final List<LeaderboardEntry> weeklyEntries;
  final List<LeaderboardEntry> monthlyEntries;
  final List<LeaderboardEntry> allTimeEntries;
  final bool isLoading;
  final String? error;

  const LeaderboardState({
    this.weeklyEntries = const [],
    this.monthlyEntries = const [],
    this.allTimeEntries = const [],
    this.isLoading = false,
    this.error,
  });

  LeaderboardState copyWith({
    List<LeaderboardEntry>? weeklyEntries,
    List<LeaderboardEntry>? monthlyEntries,
    List<LeaderboardEntry>? allTimeEntries,
    bool? isLoading,
    String? error,
  }) {
    return LeaderboardState(
      weeklyEntries: weeklyEntries ?? this.weeklyEntries,
      monthlyEntries: monthlyEntries ?? this.monthlyEntries,
      allTimeEntries: allTimeEntries ?? this.allTimeEntries,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// 리더보드 Notifier - Firestore 연동
class LeaderboardNotifier extends StateNotifier<LeaderboardState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? currentUserId;

  LeaderboardNotifier(this.currentUserId) : super(const LeaderboardState()) {
    loadLeaderboard();
  }

  /// users 컬렉션 참조
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  /// 리더보드 로드 (Firestore에서 사용자 데이터 가져오기)
  Future<void> loadLeaderboard() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // 전체 기간 리더보드: XP 내림차순 정렬, 상위 50명
      final allTimeSnapshot = await _usersCollection
          .orderBy('xp', descending: true)
          .limit(50)
          .get();

      final allTimeEntries = _convertToEntries(allTimeSnapshot.docs);

      // 주간/월간은 별도 컬렉션이 없으면 전체 데이터 기반으로 계산
      // MVP에서는 전체 데이터를 기간별로 다르게 정렬하여 표시
      final weeklyEntries = _calculateWeeklyRanking(allTimeSnapshot.docs);
      final monthlyEntries = _calculateMonthlyRanking(allTimeSnapshot.docs);

      state = state.copyWith(
        weeklyEntries: weeklyEntries,
        monthlyEntries: monthlyEntries,
        allTimeEntries: allTimeEntries,
        isLoading: false,
      );

      AppLogger.info('Loaded ${allTimeEntries.length} leaderboard entries');
    } catch (e, stackTrace) {
      final appError = AppErrorHandler.handle(e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: appError.userMessage,
      );
    }
  }

  /// Firestore 문서를 LeaderboardEntry 리스트로 변환
  List<LeaderboardEntry> _convertToEntries(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final entries = <LeaderboardEntry>[];

    for (var i = 0; i < docs.length; i++) {
      final doc = docs[i];
      final data = doc.data();

      entries.add(LeaderboardEntry(
        userId: doc.id,
        username: data['displayName'] as String? ?? '익명',
        profileImageUrl: data['profileImageUrl'] as String?,
        rank: i + 1,
        xp: data['xp'] as int? ?? 0,
        problemsSolved: data['problemsSolved'] as int? ?? 0,
        accuracy: (data['accuracy'] as num?)?.toDouble() ?? 0.0,
        tier: _calculateTier(data['xp'] as int? ?? 0),
        isCurrentUser: doc.id == currentUserId,
        level: data['level'] as int? ?? 1,
        userName: data['displayName'] as String? ?? '익명',
        grade: data['grade'] as String? ?? '',
        streakDays: data['streak'] as int? ?? 0,
      ));
    }

    return entries;
  }

  /// 주간 랭킹 계산 (weeklyXp 기반)
  List<LeaderboardEntry> _calculateWeeklyRanking(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    // 주간 XP 기준 정렬
    final sortedDocs = List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(docs);
    sortedDocs.sort((a, b) {
      final aWeeklyXp = a.data()['weeklyXp'] as int? ?? a.data()['xp'] as int? ?? 0;
      final bWeeklyXp = b.data()['weeklyXp'] as int? ?? b.data()['xp'] as int? ?? 0;
      return bWeeklyXp.compareTo(aWeeklyXp);
    });

    final entries = <LeaderboardEntry>[];
    for (var i = 0; i < sortedDocs.length; i++) {
      final doc = sortedDocs[i];
      final data = doc.data();
      final weeklyXp = data['weeklyXp'] as int? ?? data['xp'] as int? ?? 0;

      entries.add(LeaderboardEntry(
        userId: doc.id,
        username: data['displayName'] as String? ?? '익명',
        profileImageUrl: data['profileImageUrl'] as String?,
        rank: i + 1,
        xp: weeklyXp,
        problemsSolved: data['weeklyProblemsSolved'] as int? ?? data['problemsSolved'] as int? ?? 0,
        accuracy: (data['accuracy'] as num?)?.toDouble() ?? 0.0,
        tier: _calculateTier(data['xp'] as int? ?? 0),
        isCurrentUser: doc.id == currentUserId,
        level: data['level'] as int? ?? 1,
        userName: data['displayName'] as String? ?? '익명',
        grade: data['grade'] as String? ?? '',
        streakDays: data['streak'] as int? ?? 0,
      ));
    }

    return entries;
  }

  /// 월간 랭킹 계산 (monthlyXp 기반)
  List<LeaderboardEntry> _calculateMonthlyRanking(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    // 월간 XP 기준 정렬
    final sortedDocs = List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(docs);
    sortedDocs.sort((a, b) {
      final aMonthlyXp = a.data()['monthlyXp'] as int? ?? a.data()['xp'] as int? ?? 0;
      final bMonthlyXp = b.data()['monthlyXp'] as int? ?? b.data()['xp'] as int? ?? 0;
      return bMonthlyXp.compareTo(aMonthlyXp);
    });

    final entries = <LeaderboardEntry>[];
    for (var i = 0; i < sortedDocs.length; i++) {
      final doc = sortedDocs[i];
      final data = doc.data();
      final monthlyXp = data['monthlyXp'] as int? ?? data['xp'] as int? ?? 0;

      entries.add(LeaderboardEntry(
        userId: doc.id,
        username: data['displayName'] as String? ?? '익명',
        profileImageUrl: data['profileImageUrl'] as String?,
        rank: i + 1,
        xp: monthlyXp,
        problemsSolved: data['monthlyProblemsSolved'] as int? ?? data['problemsSolved'] as int? ?? 0,
        accuracy: (data['accuracy'] as num?)?.toDouble() ?? 0.0,
        tier: _calculateTier(data['xp'] as int? ?? 0),
        isCurrentUser: doc.id == currentUserId,
        level: data['level'] as int? ?? 1,
        userName: data['displayName'] as String? ?? '익명',
        grade: data['grade'] as String? ?? '',
        streakDays: data['streak'] as int? ?? 0,
      ));
    }

    return entries;
  }

  /// XP 기반 티어 계산
  String _calculateTier(int xp) {
    if (xp >= 5000) return 'Master';
    if (xp >= 3000) return 'Diamond';
    if (xp >= 1500) return 'Gold';
    if (xp >= 500) return 'Silver';
    return 'Bronze';
  }

  /// 리더보드 새로고침
  Future<void> refresh() async {
    await loadLeaderboard();
  }

  /// 현재 사용자의 랭킹 가져오기
  LeaderboardEntry? getCurrentUserRank(LeaderboardPeriod period) {
    final entries = switch (period) {
      LeaderboardPeriod.weekly => state.weeklyEntries,
      LeaderboardPeriod.monthly => state.monthlyEntries,
      LeaderboardPeriod.allTime => state.allTimeEntries,
    };

    try {
      return entries.firstWhere((e) => e.isCurrentUser);
    } catch (_) {
      return null;
    }
  }
}

/// 리더보드 Provider - Firestore 연동
final leaderboardProvider =
    StateNotifierProvider.family<LeaderboardNotifier, LeaderboardState, String?>(
  (ref, currentUserId) => LeaderboardNotifier(currentUserId),
);
