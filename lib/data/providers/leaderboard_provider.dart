import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';

/// 리더보드 Provider
/// 주간/월간/전체 순위 데이터를 관리합니다
final leaderboardProvider =
    StateNotifierProvider<LeaderboardNotifier, LeaderboardState>((ref) {
  return LeaderboardNotifier(ref);
});

/// 리더보드 상태
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
      error: error,
    );
  }
}

/// 리더보드 Notifier
class LeaderboardNotifier extends StateNotifier<LeaderboardState> {
  final Ref ref;

  LeaderboardNotifier(this.ref) : super(const LeaderboardState()) {
    _initializeLeaderboard();
  }

  /// 리더보드 초기화 (샘플 데이터)
  void _initializeLeaderboard() {
    // 실제로는 서버에서 가져와야 하지만, 지금은 샘플 데이터 생성
    final now = DateTime.now();

    // 주간 리더보드 샘플 데이터
    final weeklyData = List.generate(20, (index) {
      final rank = index + 1;
      return LeaderboardEntry(
        userId: 'user_$rank',
        userName: _generateUserName(rank),
        rank: rank,
        xp: 5000 - (rank * 200), // 순위에 따라 XP 감소
        level: 30 - rank,
        streakDays: 15 - (rank ~/ 3),
        grade: _generateGrade(rank),
        isCurrentUser: rank == 7, // 7위를 현재 사용자로 설정
        lastActiveAt: now.subtract(Duration(hours: rank)),
      );
    });

    // 월간 리더보드 (약간 다른 순위)
    final monthlyData = List.generate(20, (index) {
      final rank = index + 1;
      return LeaderboardEntry(
        userId: 'user_m_$rank',
        userName: _generateUserName(rank),
        rank: rank,
        xp: 15000 - (rank * 500),
        level: 28 - (rank ~/ 2),
        streakDays: 25 - (rank ~/ 2),
        grade: _generateGrade(rank),
        isCurrentUser: rank == 12,
        lastActiveAt: now.subtract(Duration(days: rank ~/ 2)),
      );
    });

    // 전체 리더보드 (최고 XP)
    final allTimeData = List.generate(20, (index) {
      final rank = index + 1;
      return LeaderboardEntry(
        userId: 'user_all_$rank',
        userName: _generateUserName(rank),
        rank: rank,
        xp: 50000 - (rank * 2000),
        level: 35 - rank,
        streakDays: 100 - (rank * 3),
        grade: _generateGrade(rank),
        isCurrentUser: rank == 15,
        lastActiveAt: now.subtract(Duration(days: rank)),
      );
    });

    state = state.copyWith(
      weeklyEntries: weeklyData,
      monthlyEntries: monthlyData,
      allTimeEntries: allTimeData,
    );
  }

  /// 기간별 리더보드 가져오기
  List<LeaderboardEntry> getLeaderboard(LeaderboardPeriod period) {
    switch (period) {
      case LeaderboardPeriod.weekly:
        return state.weeklyEntries;
      case LeaderboardPeriod.monthly:
        return state.monthlyEntries;
      case LeaderboardPeriod.allTime:
        return state.allTimeEntries;
    }
  }

  /// 현재 사용자의 순위 찾기
  LeaderboardEntry? getCurrentUserEntry(LeaderboardPeriod period) {
    final entries = getLeaderboard(period);
    try {
      return entries.firstWhere((entry) => entry.isCurrentUser);
    } catch (e) {
      return null;
    }
  }

  /// 리더보드 새로고침
  Future<void> refreshLeaderboard(LeaderboardPeriod period) async {
    state = state.copyWith(isLoading: true);

    try {
      // 실제로는 서버 API 호출
      await Future.delayed(const Duration(seconds: 1));

      // 성공
      state = state.copyWith(isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '리더보드를 불러오는데 실패했습니다',
      );
    }
  }

  // === 헬퍼 메소드 ===

  /// 사용자 이름 생성 (샘플)
  String _generateUserName(int rank) {
    final names = [
      '수학왕',
      '천재소년',
      '열공러',
      '수포자탈출',
      '미적분마스터',
      '기하학신동',
      '대수의달인',
      '수학올림픽',
      '공식암기왕',
      '문제풀이고수',
      '수학러버',
      '계산왕',
      '정답맞히기',
      '수학천재',
      '열심히공부',
      '노력파학생',
      '수학고수',
      '빠른계산',
      '정확한풀이',
      '꾸준한학습'
    ];

    if (rank <= names.length) {
      return names[rank - 1];
    }
    return '학습자$rank';
  }

  /// 학년 생성 (샘플)
  String _generateGrade(int rank) {
    final grades = ['중1', '중2', '중3', '고1', '고2', '고3'];
    return grades[rank % grades.length];
  }
}
