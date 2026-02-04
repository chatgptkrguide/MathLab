/// 🏆 Leaderboard Provider
///
/// Manages leaderboard state across different time periods (weekly, monthly, all-time).

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/league_model.dart';

/// 리더보드 기간 enum
enum LeaderboardPeriod {
  weekly,
  monthly,
  allTime;

  /// 기간별 표시 이름
  String get displayName {
    switch (this) {
      case LeaderboardPeriod.weekly:
        return '주간';
      case LeaderboardPeriod.monthly:
        return '월간';
      case LeaderboardPeriod.allTime:
        return '전체';
    }
  }
}

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

/// 리더보드 Notifier
class LeaderboardNotifier extends StateNotifier<LeaderboardState> {
  LeaderboardNotifier() : super(const LeaderboardState()) {
    _loadSampleData();
  }

  /// 샘플 데이터 로드 (MVP용)
  void _loadSampleData() {
    state = state.copyWith(isLoading: true);

    final sampleEntries = _generateSampleEntries();

    state = state.copyWith(
      weeklyEntries: sampleEntries,
      monthlyEntries: _shuffleAndRerank(sampleEntries),
      allTimeEntries: _shuffleAndRerank(sampleEntries),
      isLoading: false,
    );
  }

  /// 샘플 리더보드 엔트리 생성
  List<LeaderboardEntry> _generateSampleEntries() {
    return [
      const LeaderboardEntry(
        userId: 'user_1',
        username: '수학천재',
        rank: 1,
        xp: 2850,
        problemsSolved: 342,
        accuracy: 0.95,
        tier: 'Diamond',
        level: 15,
        userName: '수학천재',
        grade: '중학교 2학년',
        streakDays: 45,
      ),
      const LeaderboardEntry(
        userId: 'user_2',
        username: '공부왕',
        rank: 2,
        xp: 2340,
        problemsSolved: 298,
        accuracy: 0.91,
        tier: 'Diamond',
        level: 13,
        userName: '공부왕',
        grade: '고등학교 1학년',
        streakDays: 30,
      ),
      const LeaderboardEntry(
        userId: 'user_3',
        username: '열공학생',
        rank: 3,
        xp: 2100,
        problemsSolved: 267,
        accuracy: 0.88,
        tier: 'Gold',
        level: 12,
        userName: '열공학생',
        grade: '중학교 3학년',
        streakDays: 21,
      ),
      const LeaderboardEntry(
        userId: 'current_user',
        username: '나',
        rank: 5,
        xp: 1650,
        problemsSolved: 189,
        accuracy: 0.85,
        tier: 'Gold',
        isCurrentUser: true,
        level: 10,
        userName: '나',
        grade: '중학교 1학년',
        streakDays: 14,
      ),
      const LeaderboardEntry(
        userId: 'user_4',
        username: '수학러버',
        rank: 4,
        xp: 1800,
        problemsSolved: 220,
        accuracy: 0.87,
        tier: 'Gold',
        level: 11,
        userName: '수학러버',
        grade: '초등학교 6학년',
        streakDays: 18,
      ),
      const LeaderboardEntry(
        userId: 'user_5',
        username: '풀이마스터',
        rank: 6,
        xp: 1500,
        problemsSolved: 175,
        accuracy: 0.82,
        tier: 'Silver',
        level: 9,
        userName: '풀이마스터',
        grade: '중학교 2학년',
        streakDays: 10,
      ),
      const LeaderboardEntry(
        userId: 'user_6',
        username: '도전자',
        rank: 7,
        xp: 1200,
        problemsSolved: 145,
        accuracy: 0.80,
        tier: 'Silver',
        level: 8,
        userName: '도전자',
        grade: '초등학교 5학년',
        streakDays: 7,
      ),
      const LeaderboardEntry(
        userId: 'user_7',
        username: '수학새싹',
        rank: 8,
        xp: 900,
        problemsSolved: 110,
        accuracy: 0.78,
        tier: 'Bronze',
        level: 6,
        userName: '수학새싹',
        grade: '초등학교 4학년',
        streakDays: 5,
      ),
    ];
  }

  /// 엔트리 재배치 (월간/전체 데이터 시뮬레이션)
  List<LeaderboardEntry> _shuffleAndRerank(List<LeaderboardEntry> entries) {
    final shuffled = List<LeaderboardEntry>.from(entries);
    shuffled.sort((a, b) => (b.xp * 3 + b.problemsSolved)
        .compareTo(a.xp * 3 + a.problemsSolved));

    return shuffled.asMap().entries.map((entry) {
      return LeaderboardEntry(
        userId: entry.value.userId,
        username: entry.value.username,
        rank: entry.key + 1,
        xp: entry.value.xp,
        problemsSolved: entry.value.problemsSolved,
        accuracy: entry.value.accuracy,
        tier: entry.value.tier,
        isCurrentUser: entry.value.isCurrentUser,
        level: entry.value.level,
        userName: entry.value.userName,
        grade: entry.value.grade,
        streakDays: entry.value.streakDays,
      );
    }).toList();
  }

  /// 리더보드 새로고침
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);

    // TODO: API 호출로 교체
    await Future.delayed(const Duration(milliseconds: 500));

    _loadSampleData();
  }
}

/// 리더보드 Provider
final leaderboardProvider =
    StateNotifierProvider<LeaderboardNotifier, LeaderboardState>(
  (ref) => LeaderboardNotifier(),
);
