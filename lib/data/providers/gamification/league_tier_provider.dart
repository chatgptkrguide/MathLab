import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../../services/league_service.dart';
import '../user/user_provider.dart';
import '../../../shared/utils/logger.dart';

/// 리그 티어 서비스 프로바이더
final leagueTierServiceProvider = Provider<LeagueService>((ref) {
  return LeagueService();
});

/// 사용자의 리그 티어 정보 프로바이더
final userTierLevelInfoProvider =
    FutureProvider.autoDispose<TierInfo?>((ref) async {
  final user = ref.watch(userProvider);
  if (user == null) return null;

  final service = ref.read(leagueTierServiceProvider);
  TierInfo? league = await service.getTierInfo(user.id);

  // 리그 정보가 없으면 초기화
  league ??= await service.initializeLeague(user.id);

  return league;
});

/// 모든 리그 티어 정보 프로바이더 (리더보드용)
final allTierLevelInfosProvider =
    FutureProvider.autoDispose<List<TierInfo>>((ref) async {
  final service = ref.read(leagueTierServiceProvider);
  return await service.getAllTierInfos();
});

/// 티어별 사용자 프로바이더
final usersByTierLevelProvider = FutureProvider.autoDispose
    .family<List<TierInfo>, TierLevel>((ref, tier) async {
  final service = ref.read(leagueTierServiceProvider);
  return await service.getUsersByTier(tier);
});

/// 강등 대상 사용자 프로바이더
final demotionTargetsProvider =
    FutureProvider.autoDispose<List<TierInfo>>((ref) async {
  final service = ref.read(leagueTierServiceProvider);
  return await service.getDemotionTargets();
});

/// 리그 티어 액션 프로바이더
final leagueTierActionsProvider = Provider((ref) {
  return TierLevelActions(ref);
});

/// 리그 티어 액션 클래스
class TierLevelActions {
  final Ref _ref;

  TierLevelActions(this._ref);

  /// 문제 풀이 기록 (활동 기록 + 자동 복구)
  Future<TierInfo?> recordProblemSolved({
    required int points,
  }) async {
    try {
      final user = _ref.read(userProvider);
      if (user == null) {
        Logger.warning('사용자 정보 없음', tag: 'TierLevel');
        return null;
      }

      final service = _ref.read(leagueTierServiceProvider);
      final updatedLeague = await service.recordProblemSolved(
        userId: user.id,
        points: points,
      );

      if (updatedLeague != null) {
        // 관련 프로바이더 새로고침
        _ref.invalidate(userTierLevelInfoProvider);
        _ref.invalidate(allTierLevelInfosProvider);

        Logger.info(
          '문제 풀이 기록 완료: +$points 포인트',
          tag: 'TierLevel',
        );
      }

      return updatedLeague;
    } catch (e, stackTrace) {
      Logger.error(
        '문제 풀이 기록 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'TierLevel',
      );
      return null;
    }
  }

  /// 비활동 체크 (매일 실행)
  Future<void> checkInactivity() async {
    try {
      final user = _ref.read(userProvider);
      if (user == null) {
        Logger.warning('사용자 정보 없음', tag: 'TierLevel');
        return;
      }

      final service = _ref.read(leagueTierServiceProvider);
      await service.checkInactivity(user.id);

      // 리그 정보 새로고침
      _ref.invalidate(userTierLevelInfoProvider);
    } catch (e, stackTrace) {
      Logger.error(
        '비활동 체크 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'TierLevel',
      );
    }
  }

  /// 강등 처리
  Future<TierInfo?> demoteUser() async {
    try {
      final user = _ref.read(userProvider);
      if (user == null) {
        Logger.warning('사용자 정보 없음', tag: 'TierLevel');
        return null;
      }

      final service = _ref.read(leagueTierServiceProvider);
      final demotedLeague = await service.demoteUser(user.id);

      if (demotedLeague != null) {
        // 관련 프로바이더 새로고침
        _ref.invalidate(userTierLevelInfoProvider);
        _ref.invalidate(allTierLevelInfosProvider);

        Logger.info('강등 처리 완료', tag: 'TierLevel');
      }

      return demotedLeague;
    } catch (e, stackTrace) {
      Logger.error(
        '강등 처리 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'TierLevel',
      );
      return null;
    }
  }

  /// 승급 처리
  Future<TierInfo?> promoteUser() async {
    try {
      final user = _ref.read(userProvider);
      if (user == null) {
        Logger.warning('사용자 정보 없음', tag: 'TierLevel');
        return null;
      }

      final service = _ref.read(leagueTierServiceProvider);
      final promotedLeague = await service.promoteUser(user.id);

      if (promotedLeague != null) {
        // 관련 프로바이더 새로고침
        _ref.invalidate(userTierLevelInfoProvider);
        _ref.invalidate(allTierLevelInfosProvider);

        Logger.info('승급 처리 완료', tag: 'TierLevel');
      }

      return promotedLeague;
    } catch (e, stackTrace) {
      Logger.error(
        '승급 처리 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'TierLevel',
      );
      return null;
    }
  }

  /// 순위 업데이트
  Future<void> updateRank(int rank) async {
    try {
      final user = _ref.read(userProvider);
      if (user == null) {
        Logger.warning('사용자 정보 없음', tag: 'TierLevel');
        return;
      }

      final service = _ref.read(leagueTierServiceProvider);
      await service.updateRank(userId: user.id, rank: rank);

      // 리그 정보 새로고침
      _ref.invalidate(userTierLevelInfoProvider);
    } catch (e, stackTrace) {
      Logger.error(
        '순위 업데이트 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'TierLevel',
      );
    }
  }

  /// 데이터 초기화
  Future<void> clearAllData() async {
    try {
      final user = _ref.read(userProvider);
      if (user == null) {
        Logger.warning('사용자 정보 없음', tag: 'TierLevel');
        return;
      }

      final service = _ref.read(leagueTierServiceProvider);
      await service.clearAllData();

      // 모든 프로바이더 새로고침
      _ref.invalidate(userTierLevelInfoProvider);
      _ref.invalidate(allTierLevelInfosProvider);

      Logger.info('리그 티어 데이터 초기화 완료', tag: 'TierLevel');
    } catch (e, stackTrace) {
      Logger.error(
        '데이터 초기화 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'TierLevel',
      );
      rethrow;
    }
  }

  /// 매일 자동 체크 (앱 시작 시 실행)
  Future<void> performDailyCheck() async {
    try {
      final user = _ref.read(userProvider);
      if (user == null) return;

      // 비활동 체크
      await checkInactivity();

      // 현재 리그 정보 조회
      final league = await _ref.read(userTierLevelInfoProvider.future);
      if (league == null) return;

      // 강등 대상인지 확인 후 자동 강등
      if (league.isDemotionTarget) {
        Logger.warning(
          '${league.consecutiveInactiveDays}일 비활동으로 자동 강등 실행',
          tag: 'TierLevel',
        );
        await demoteUser();
      }
    } catch (e, stackTrace) {
      Logger.error(
        '매일 자동 체크 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'TierLevel',
      );
    }
  }
}
