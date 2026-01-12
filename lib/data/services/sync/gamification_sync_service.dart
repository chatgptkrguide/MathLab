import '../../../shared/utils/logger.dart';
import '../../models/gamification/league.dart';
import '../../repositories/league_repository.dart';

/// 게이미피케이션 데이터 동기화 서비스
///
/// 역할:
/// - 리그 데이터 업로드/다운로드
/// - 리그 데이터 병합
class GamificationSyncService {
  final LeagueRepository _leagueRepository;

  GamificationSyncService({
    required LeagueRepository leagueRepository,
  }) : _leagueRepository = leagueRepository;

  /// 리그 데이터 업로드
  Future<void> uploadLeague(String accountId, League league) async {
    try {
      Logger.info('리그 데이터 업로드 시작: ${league.tier}', tag: 'GamificationSyncService');

      await _leagueRepository.saveToFirebase(accountId, league);

      Logger.info('리그 데이터 업로드 완료', tag: 'GamificationSyncService');
    } catch (e, stackTrace) {
      Logger.error(
        '리그 데이터 업로드 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'GamificationSyncService',
      );
      rethrow;
    }
  }

  /// 리그 데이터 다운로드
  Future<void> downloadLeague(String accountId) async {
    try {
      Logger.info('리그 데이터 다운로드 시작', tag: 'GamificationSyncService');

      final remoteLeague = await _leagueRepository.getFromFirebase(accountId);

      if (remoteLeague != null) {
        final localLeague = await _leagueRepository.getFromLocal('league_$accountId');

        // 병합: 리그 데이터는 Firebase 우선 (서버 데이터가 항상 최신)
        if (localLeague != null) {
          final mergedLeague = await _leagueRepository.mergeData(localLeague, remoteLeague);
          if (mergedLeague != null) {
            await _leagueRepository.saveToLocal('league_$accountId', mergedLeague);
          }
        } else {
          await _leagueRepository.saveToLocal('league_$accountId', remoteLeague);
        }

        Logger.info('리그 데이터 다운로드 완료: ${remoteLeague.tier}', tag: 'GamificationSyncService');
      } else {
        Logger.debug('Firebase에 리그 데이터 없음: $accountId', tag: 'GamificationSyncService');
      }
    } catch (e, stackTrace) {
      Logger.error(
        '리그 데이터 다운로드 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'GamificationSyncService',
      );
      rethrow;
    }
  }

  /// 양방향 동기화 (업로드 + 다운로드)
  Future<void> bidirectionalSync(String accountId) async {
    try {
      Logger.info('리그 데이터 양방향 동기화 시작: $accountId', tag: 'GamificationSyncService');

      // 1. 로컬 리그 데이터 가져오기
      final localLeague = await _leagueRepository.getFromLocal('league_$accountId');

      if (localLeague != null) {
        // 2. 로컬 → Firebase 업로드
        await uploadLeague(accountId, localLeague);
      }

      // 3. Firebase → 로컬 다운로드 (병합)
      await downloadLeague(accountId);

      Logger.info('리그 데이터 양방향 동기화 완료', tag: 'GamificationSyncService');
    } catch (e, stackTrace) {
      Logger.error(
        '리그 데이터 양방향 동기화 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'GamificationSyncService',
      );
      rethrow;
    }
  }
}
