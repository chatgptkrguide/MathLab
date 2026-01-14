import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/utils/logger.dart';
import '../../models/user/user.dart' as user_model;

/// 리더보드 기간
enum LeaderboardPeriod {
  weekly, // 주간
  monthly, // 월간
  allTime, // 전체
}

/// 리더보드 항목
class LeaderboardEntry {
  final String userId;
  final String userName;
  final String photoUrl;
  final int rank;
  final int xp;
  final int level;
  final int streakDays;
  final String grade;
  final bool isCurrentUser;
  final DateTime lastActiveAt;

  LeaderboardEntry({
    required this.userId,
    required this.userName,
    required this.photoUrl,
    required this.rank,
    required this.xp,
    required this.level,
    required this.streakDays,
    required this.grade,
    required this.isCurrentUser,
    required this.lastActiveAt,
  });

  factory LeaderboardEntry.fromUserModel(
    user_model.User user,
    int rank,
    bool isCurrentUser,
  ) {
    return LeaderboardEntry(
      userId: user.id,
      userName: user.name,
      photoUrl: user.photoUrl ?? '',
      rank: rank,
      xp: user.xp,
      level: user.level,
      streakDays: user.streakDays,
      grade: user.currentGrade,
      isCurrentUser: isCurrentUser,
      lastActiveAt: user.lastStudyDate ?? DateTime.now(),
    );
  }
}

/// 실시간 리더보드 Provider
class RealtimeLeaderboardNotifier
    extends StateNotifier<AsyncValue<List<LeaderboardEntry>>> {
  final FirebaseFirestore _firestore;
  final firebase_auth.FirebaseAuth _auth;
  LeaderboardPeriod _period;
  StreamSubscription<QuerySnapshot>? _subscription;

  RealtimeLeaderboardNotifier({
    FirebaseFirestore? firestore,
    firebase_auth.FirebaseAuth? auth,
    LeaderboardPeriod period = LeaderboardPeriod.weekly,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? firebase_auth.FirebaseAuth.instance,
        _period = period,
        super(const AsyncValue.loading()) {
    _initialize();
  }

  String? get _currentUserId => _auth.currentUser?.uid;

  /// 초기화
  Future<void> _initialize() async {
    try {
      await _startListening();
    } catch (e, stack) {
      Logger.error('리더보드 초기화 실패', error: e, stackTrace: stack);
      state = AsyncValue.error(e, stack);
    }
  }

  /// 실시간 리스닝 시작
  Future<void> _startListening() async {
    // 기존 구독 취소
    await _subscription?.cancel();

    try {
      // 기간에 따른 쿼리 생성
      Query<Map<String, dynamic>> query = _firestore.collection('users');

      // 기간별 필터링
      switch (_period) {
        case LeaderboardPeriod.weekly:
          final weekStart = _getWeekStart();
          query = query
              .where('lastActive', isGreaterThanOrEqualTo: weekStart)
              .orderBy('lastActive')
              .orderBy('weeklyXp', descending: true);
          break;
        case LeaderboardPeriod.monthly:
          final monthStart = _getMonthStart();
          query = query
              .where('lastActive', isGreaterThanOrEqualTo: monthStart)
              .orderBy('lastActive')
              .orderBy('monthlyXp', descending: true);
          break;
        case LeaderboardPeriod.allTime:
          query = query.orderBy('xp', descending: true);
          break;
      }

      // 상위 100명만 가져오기
      query = query.limit(100);

      // 실시간 업데이트 리스닝
      _subscription = query.snapshots().listen(
        (snapshot) {
          _processLeaderboardUpdate(snapshot);
        },
        onError: (error, stack) {
          Logger.error('리더보드 스트림 에러', error: error, stackTrace: stack);
          state = AsyncValue.error(error, stack);
        },
      );
    } catch (e, stack) {
      Logger.error('리더보드 리스닝 시작 실패', error: e, stackTrace: stack);
      state = AsyncValue.error(e, stack);
    }
  }

  /// 리더보드 업데이트 처리
  void _processLeaderboardUpdate(QuerySnapshot snapshot) {
    try {
      final entries = <LeaderboardEntry>[];
      int rank = 1;

      for (var doc in snapshot.docs) {
        try {
          final user = user_model.User.fromFirestore(
            doc as DocumentSnapshot<Map<String, dynamic>>,
          );
          final isCurrentUser = user.id == _currentUserId;

          entries.add(
            LeaderboardEntry.fromUserModel(user, rank, isCurrentUser),
          );

          rank++;
        } catch (e) {
          Logger.warning('리더보드 항목 파싱 실패: ${doc.id}');
          continue;
        }
      }

      state = AsyncValue.data(entries);

      Logger.info('리더보드 업데이트: ${entries.length}명');
    } catch (e, stack) {
      Logger.error('리더보드 처리 실패', error: e, stackTrace: stack);
      state = AsyncValue.error(e, stack);
    }
  }

  /// 기간 변경
  Future<void> changePeriod(LeaderboardPeriod newPeriod) async {
    if (_period == newPeriod) return;

    _period = newPeriod;
    state = const AsyncValue.loading();

    await _startListening();

    Logger.analytics('leaderboard_period_changed', parameters: {
      'period': newPeriod.name,
    });
  }

  /// 새로고침
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _startListening();
  }

  /// 주 시작일 계산 (월요일 00:00)
  DateTime _getWeekStart() {
    final now = DateTime.now();
    final weekday = now.weekday; // 1 (월) ~ 7 (일)
    final daysToSubtract = weekday - 1; // 월요일까지 빼야할 일수

    return DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: daysToSubtract));
  }

  /// 월 시작일 계산 (1일 00:00)
  DateTime _getMonthStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  /// 내 순위 찾기
  int? get myRank {
    return state.when(
      data: (entries) {
        final myEntry = entries.firstWhere(
          (e) => e.isCurrentUser,
          orElse: () => entries.first,
        );
        return myEntry.rank;
      },
      loading: () => null,
      error: (_, __) => null,
    );
  }

  /// 내 정보 찾기
  LeaderboardEntry? get myEntry {
    return state.when(
      data: (entries) {
        try {
          return entries.firstWhere((e) => e.isCurrentUser);
        } catch (e) {
          return null;
        }
      },
      loading: () => null,
      error: (_, __) => null,
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// Provider 정의들

/// 주간 리더보드
final weeklyLeaderboardProvider = StateNotifierProvider<
    RealtimeLeaderboardNotifier, AsyncValue<List<LeaderboardEntry>>>((ref) {
  return RealtimeLeaderboardNotifier(
    period: LeaderboardPeriod.weekly,
  );
});

/// 월간 리더보드
final monthlyLeaderboardProvider = StateNotifierProvider<
    RealtimeLeaderboardNotifier, AsyncValue<List<LeaderboardEntry>>>((ref) {
  return RealtimeLeaderboardNotifier(
    period: LeaderboardPeriod.monthly,
  );
});

/// 전체 리더보드
final allTimeLeaderboardProvider = StateNotifierProvider<
    RealtimeLeaderboardNotifier, AsyncValue<List<LeaderboardEntry>>>((ref) {
  return RealtimeLeaderboardNotifier(
    period: LeaderboardPeriod.allTime,
  );
});

/// 현재 선택된 기간의 리더보드
final currentLeaderboardProvider = Provider.family<
    StateNotifierProvider<RealtimeLeaderboardNotifier,
        AsyncValue<List<LeaderboardEntry>>>,
    LeaderboardPeriod>((ref, period) {
  switch (period) {
    case LeaderboardPeriod.weekly:
      return weeklyLeaderboardProvider;
    case LeaderboardPeriod.monthly:
      return monthlyLeaderboardProvider;
    case LeaderboardPeriod.allTime:
      return allTimeLeaderboardProvider;
  }
});

/// 내 순위
final myRankProvider = Provider.family<int?, LeaderboardPeriod>((ref, period) {
  final provider = ref.watch(currentLeaderboardProvider(period));
  final leaderboard = ref.watch(provider.notifier);
  return leaderboard.myRank;
});

/// 자동 새로고침 Provider (30초마다)
final autoRefreshLeaderboardProvider = StreamProvider.family<void, LeaderboardPeriod>(
  (ref, period) {
    return Stream.periodic(const Duration(seconds: 30), (_) {
      final provider = ref.read(currentLeaderboardProvider(period));
      ref.read(provider.notifier).refresh();
    });
  },
);
