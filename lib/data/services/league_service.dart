import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../../shared/utils/logger.dart';

/// 리그 시스템 관리 서비스
class LeagueService {
  static const String _leagueInfoKey = 'league_info';
  static const int _demotionDays = 7; // 강등 기준 일수
  static const int _recoveryProblems = 10; // 복구 기준 문제 수

  /// 리그 정보 조회
  Future<TierInfo?> getTierInfo(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final leagueJson = prefs.getString(_leagueInfoKey);

      if (leagueJson == null) return null;

      final Map<String, dynamic> allLeagues = jsonDecode(leagueJson);
      if (!allLeagues.containsKey(userId)) return null;

      return TierInfo.fromJson(allLeagues[userId]);
    } catch (e, stackTrace) {
      Logger.error(
        '리그 정보 조회 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'LeagueService',
      );
      return null;
    }
  }

  /// 리그 정보 초기화 (새 사용자)
  Future<TierInfo> initializeLeague(String userId) async {
    try {
      final initialLeague = TierInfo(
        userId: userId,
        currentTier: TierLevel.bronze,
        points: 0,
        rank: 0,
        lastActiveDate: DateTime.now(),
        consecutiveInactiveDays: 0,
        canRecover: false,
        problemsSolvedSinceDemotion: 0,
      );

      await _saveTierInfo(initialLeague);
      Logger.info('리그 정보 초기화 완료: Bronze', tag: 'LeagueService');
      return initialLeague;
    } catch (e, stackTrace) {
      Logger.error(
        '리그 정보 초기화 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'LeagueService',
      );
      rethrow;
    }
  }

  /// 문제 풀이 기록 (활동 기록 + 복구 체크)
  Future<TierInfo?> recordProblemSolved({
    required String userId,
    required int points,
  }) async {
    try {
      TierInfo? league = await getTierInfo(userId);

      // 리그 정보가 없으면 초기화
      league ??= await initializeLeague(userId);

      // 복구 중인 경우 문제 수 증가
      int problemsSolvedSinceDemotion = league.problemsSolvedSinceDemotion;
      bool canRecover = league.canRecover;

      if (canRecover) {
        problemsSolvedSinceDemotion++;

        // 10문제 이상 풀면 자동 복구
        if (problemsSolvedSinceDemotion >= _recoveryProblems) {
          final previousTier = league.currentTier.previous;
          if (previousTier != null) {
            league = league.copyWith(
              currentTier: previousTier,
              canRecover: false,
              problemsSolvedSinceDemotion: 0,
              consecutiveInactiveDays: 0,
              lastActiveDate: DateTime.now(),
              points: league.points + points,
            );

            Logger.info(
              '티어 복구 완료: ${league.currentTier.label}',
              tag: 'LeagueService',
            );
          }
        } else {
          league = league.copyWith(
            problemsSolvedSinceDemotion: problemsSolvedSinceDemotion,
            lastActiveDate: DateTime.now(),
            consecutiveInactiveDays: 0,
            points: league.points + points,
          );
        }
      } else {
        // 일반 포인트 획득
        league = league.copyWith(
          lastActiveDate: DateTime.now(),
          consecutiveInactiveDays: 0,
          points: league.points + points,
        );
      }

      await _saveTierInfo(league);
      return league;
    } catch (e, stackTrace) {
      Logger.error(
        '문제 풀이 기록 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'LeagueService',
      );
      return null;
    }
  }

  /// 비활동 일수 체크 (매일 실행)
  Future<void> checkInactivity(String userId) async {
    try {
      final league = await getTierInfo(userId);
      if (league == null) return;

      final now = DateTime.now();
      final daysSinceLastActive = now.difference(league.lastActiveDate).inDays;

      if (daysSinceLastActive > 0) {
        final updatedLeague = league.copyWith(
          consecutiveInactiveDays: daysSinceLastActive,
        );

        await _saveTierInfo(updatedLeague);

        // 7일 이상 비활동 시 강등 경고 로그
        if (daysSinceLastActive >= _demotionDays) {
          Logger.warning(
            '강등 대상: $daysSinceLastActive일 비활동',
            tag: 'LeagueService',
          );
        }
      }
    } catch (e, stackTrace) {
      Logger.error(
        '비활동 체크 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'LeagueService',
      );
    }
  }

  /// 강등 처리
  Future<TierInfo?> demoteUser(String userId) async {
    try {
      final league = await getTierInfo(userId);
      if (league == null) return null;

      // 이미 브론즈면 강등 불가
      if (league.currentTier == TierLevel.bronze) {
        Logger.warning('브론즈 티어는 강등 불가', tag: 'LeagueService');
        return league;
      }

      // 강등 대상인지 확인
      if (!league.isDemotionTarget) {
        Logger.warning('강등 대상 아님', tag: 'LeagueService');
        return league;
      }

      final nextTier = league.currentTier.previous;
      if (nextTier == null) return league;

      final demotedLeague = league.copyWith(
        currentTier: nextTier,
        canRecover: true,
        problemsSolvedSinceDemotion: 0,
        consecutiveInactiveDays: 0,
      );

      await _saveTierInfo(demotedLeague);

      Logger.info(
        '강등 완료: ${league.currentTier.label} → ${nextTier.label}',
        tag: 'LeagueService',
      );

      return demotedLeague;
    } catch (e, stackTrace) {
      Logger.error(
        '강등 처리 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'LeagueService',
      );
      return null;
    }
  }

  /// 승급 처리 (포인트 기준)
  Future<TierInfo?> promoteUser(String userId) async {
    try {
      final league = await getTierInfo(userId);
      if (league == null) return null;

      // 이미 다이아몬드면 승급 불가
      if (league.currentTier == TierLevel.diamond) {
        Logger.warning('다이아몬드 티어는 승급 불가', tag: 'LeagueService');
        return league;
      }

      final nextTier = league.currentTier.next;
      if (nextTier == null) return league;

      final promotedLeague = league.copyWith(
        currentTier: nextTier,
        canRecover: false,
        problemsSolvedSinceDemotion: 0,
      );

      await _saveTierInfo(promotedLeague);

      Logger.info(
        '승급 완료: ${league.currentTier.label} → ${nextTier.label}',
        tag: 'LeagueService',
      );

      return promotedLeague;
    } catch (e, stackTrace) {
      Logger.error(
        '승급 처리 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'LeagueService',
      );
      return null;
    }
  }

  /// 순위 업데이트
  Future<void> updateRank({
    required String userId,
    required int rank,
  }) async {
    try {
      final league = await getTierInfo(userId);
      if (league == null) return;

      final updatedLeague = league.copyWith(rank: rank);
      await _saveTierInfo(updatedLeague);
    } catch (e, stackTrace) {
      Logger.error(
        '순위 업데이트 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'LeagueService',
      );
    }
  }

  /// 모든 사용자의 리그 정보 조회 (리더보드용)
  Future<List<TierInfo>> getAllTierInfos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final leagueJson = prefs.getString(_leagueInfoKey);

      if (leagueJson == null) return [];

      final Map<String, dynamic> allLeagues = jsonDecode(leagueJson);
      final leagues =
          allLeagues.values.map((json) => TierInfo.fromJson(json)).toList();

      // 포인트 기준 내림차순 정렬
      leagues.sort((a, b) => b.points.compareTo(a.points));
      return leagues;
    } catch (e, stackTrace) {
      Logger.error(
        '리더보드 조회 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'LeagueService',
      );
      return [];
    }
  }

  /// 티어별 사용자 조회
  Future<List<TierInfo>> getUsersByTier(TierLevel tier) async {
    final allLeagues = await getAllTierInfos();
    return allLeagues.where((league) => league.currentTier == tier).toList();
  }

  /// 강등 대상 사용자 조회
  Future<List<TierInfo>> getDemotionTargets() async {
    final allLeagues = await getAllTierInfos();
    return allLeagues.where((league) => league.isDemotionTarget).toList();
  }

  /// 리그 정보 저장
  Future<void> _saveTierInfo(TierInfo league) async {
    final prefs = await SharedPreferences.getInstance();
    final leagueJson = prefs.getString(_leagueInfoKey);

    Map<String, dynamic> allLeagues = {};
    if (leagueJson != null) {
      allLeagues = jsonDecode(leagueJson);
    }

    allLeagues[league.userId] = league.toJson();
    await prefs.setString(_leagueInfoKey, jsonEncode(allLeagues));
  }

  /// 모든 데이터 초기화
  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_leagueInfoKey);
      Logger.info('리그 데이터 초기화 완료', tag: 'LeagueService');
    } catch (e, stackTrace) {
      Logger.error(
        '데이터 초기화 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'LeagueService',
      );
      rethrow;
    }
  }

  /// 강등 기준 일수
  static int get demotionDays => _demotionDays;

  /// 복구 기준 문제 수
  static int get recoveryProblems => _recoveryProblems;
}
