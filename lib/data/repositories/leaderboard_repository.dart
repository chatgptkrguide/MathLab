import '../models/gamification/leaderboard_entry.dart';
import 'base/base_repository.dart';

/// 리더보드 Repository
///
/// 리더보드 데이터 CRUD 및 관리
/// - 전체 순위 조회
/// - 친구 순위 조회
/// - 주간/월간 순위
class LeaderboardRepository extends BaseRepository<LeaderboardEntry> {
  LeaderboardRepository()
      : super(
          collectionPath: 'leaderboard',
          fromFirestore: LeaderboardEntry.fromFirestore,
          repositoryName: 'LeaderboardRepository',
          enableCache: true,
          cacheDuration: const Duration(minutes: 5),
        );

  /// 전체 리더보드 조회 (페이지네이션)
  Future<RepositoryResult<List<LeaderboardEntry>>> getGlobalLeaderboard({
    int limit = 50,
    LeaderboardEntry? startAfter,
  }) async {
    try {
      var queryRef = firestore
          .collection(collectionPath)
          .orderBy('xp', descending: true)
          .limit(limit);

      if (startAfter != null) {
        final docSnapshot = await firestore
            .collection(collectionPath)
            .doc(startAfter.id)
            .get();
        queryRef = queryRef.startAfterDocument(docSnapshot);
      }

      final snapshot = await queryRef.get();
      final entries = snapshot.docs
          .map((doc) => fromFirestore(doc.data(), doc.id))
          .toList();

      return RepositoryResult.success(data: entries);
    } catch (e) {
      return RepositoryResult.failure(
        error: 'Failed to fetch global leaderboard: $e',
      );
    }
  }

  /// 친구 리더보드 조회
  Future<RepositoryResult<List<LeaderboardEntry>>> getFriendsLeaderboard(
    List<String> friendIds,
  ) async {
    if (friendIds.isEmpty) {
      return RepositoryResult.success(data: []);
    }

    // Firestore 'in' query는 최대 10개까지만 지원
    final batches = <Future<RepositoryResult<List<LeaderboardEntry>>>>[];
    for (var i = 0; i < friendIds.length; i += 10) {
      final batchIds = friendIds.skip(i).take(10).toList();
      batches.add(
        query(
          (ref) => ref
              .where('userId', whereIn: batchIds)
              .orderBy('xp', descending: true),
        ),
      );
    }

    try {
      final results = await Future.wait(batches);
      final allEntries = <LeaderboardEntry>[];

      for (final result in results) {
        if (result.isSuccess && result.data != null) {
          allEntries.addAll(result.data!);
        }
      }

      // XP로 정렬
      allEntries.sort((a, b) => b.xp.compareTo(a.xp));

      return RepositoryResult.success(data: allEntries);
    } catch (e) {
      return RepositoryResult.failure(
        error: 'Failed to fetch friends leaderboard: $e',
      );
    }
  }

  /// 주간 리더보드 조회
  Future<RepositoryResult<List<LeaderboardEntry>>> getWeeklyLeaderboard({
    int limit = 50,
  }) async {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));

    return query(
      (ref) => ref
          .where('lastUpdated', isGreaterThanOrEqualTo: weekAgo)
          .orderBy('lastUpdated', descending: false)
          .orderBy('weeklyXp', descending: true)
          .limit(limit),
    );
  }

  /// 월간 리더보드 조회
  Future<RepositoryResult<List<LeaderboardEntry>>> getMonthlyLeaderboard({
    int limit = 50,
  }) async {
    final monthAgo = DateTime.now().subtract(const Duration(days: 30));

    return query(
      (ref) => ref
          .where('lastUpdated', isGreaterThanOrEqualTo: monthAgo)
          .orderBy('lastUpdated', descending: false)
          .orderBy('monthlyXp', descending: true)
          .limit(limit),
    );
  }

  /// 리그별 리더보드 조회
  Future<RepositoryResult<List<LeaderboardEntry>>> getLeagueLeaderboard(
    String leagueId, {
    int limit = 50,
  }) async {
    return query(
      (ref) => ref
          .where('leagueId', isEqualTo: leagueId)
          .orderBy('xp', descending: true)
          .limit(limit),
    );
  }

  /// 사용자 순위 조회
  Future<RepositoryResult<int>> getUserRank(String userId) async {
    try {
      final result = await getById(userId);
      if (!result.isSuccess || result.data == null) {
        return RepositoryResult.failure(
          error: result.error ?? 'User not found in leaderboard',
        );
      }

      final userEntry = result.data!;

      // 해당 사용자보다 XP가 높은 사용자 수를 세어서 순위 계산
      final higherScoresSnapshot = await firestore
          .collection(collectionPath)
          .where('xp', isGreaterThan: userEntry.xp)
          .count()
          .get();

      final rank = higherScoresSnapshot.count! + 1;

      return RepositoryResult.success(data: rank);
    } catch (e) {
      return RepositoryResult.failure(
        error: 'Failed to get user rank: $e',
      );
    }
  }

  /// 리더보드 항목 업데이트 또는 생성
  Future<RepositoryResult<LeaderboardEntry>> upsertEntry(
    String userId,
    int xp, {
    int? weeklyXp,
    int? monthlyXp,
    String? leagueId,
  }) async {
    try {
      final existingResult = await getById(userId);

      if (existingResult.isSuccess && existingResult.data != null) {
        // 기존 항목 업데이트
        final existing = existingResult.data!;
        final updated = existing.copyWith(
          xp: xp,
          weeklyXp: weeklyXp ?? existing.weeklyXp,
          monthlyXp: monthlyXp ?? existing.monthlyXp,
          leagueId: leagueId ?? existing.leagueId,
          lastUpdated: DateTime.now(),
        );
        return update(updated);
      } else {
        // 새 항목 생성
        final newEntry = LeaderboardEntry(
          id: userId,
          userId: userId,
          xp: xp,
          weeklyXp: weeklyXp ?? 0,
          monthlyXp: monthlyXp ?? 0,
          leagueId: leagueId,
          lastUpdated: DateTime.now(),
        );
        return create(newEntry);
      }
    } catch (e) {
      return RepositoryResult.failure(
        error: 'Failed to upsert leaderboard entry: $e',
      );
    }
  }
}
