import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/league.dart';
import '../../shared/utils/logger.dart';
import '../../data/services/local_storage_service.dart';
import 'auth_provider.dart';

/// 리그 상태
class LeagueState {
  final League? currentLeague;
  final bool isLoading;
  final String? error;

  const LeagueState({
    this.currentLeague,
    this.isLoading = false,
    this.error,
  });

  LeagueState copyWith({
    League? currentLeague,
    bool? isLoading,
    String? error,
  }) {
    return LeagueState(
      currentLeague: currentLeague ?? this.currentLeague,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 리그 상태 관리 Provider
class LeagueNotifier extends StateNotifier<LeagueState> {
  final Ref ref; // Riverpod Ref for accessing current account
  final LocalStorageService _storage = LocalStorageService();

  LeagueNotifier(this.ref) : super(const LeagueState()) {
    _initialize();
  }

  /// 현재 계정 ID 기반 저장소 키
  String? get _storageKey {
    final currentAccount = ref.read(currentAccountProvider);
    if (currentAccount == null) {
      Logger.warning('No logged in account', tag: 'LeagueProvider');
      return null;
    }
    return 'league_${currentAccount.id}';
  }

  /// 초기화 및 데이터 로드
  Future<void> _initialize() async {
    await _loadCurrentLeague();
  }

  /// 현재 리그 정보 로드
  Future<void> _loadCurrentLeague() async {
    state = state.copyWith(isLoading: true);

    try {
      final key = _storageKey;
      if (key == null) {
        // 로그인된 계정 없음 - 빈 상태로 초기화
        state = state.copyWith(
          currentLeague: null,
          isLoading: false,
          error: null,
        );
        return;
      }

      // 로컬 저장소에서 리그 데이터 로드
      final data = await _storage.loadMap(key);

      if (data != null) {
        final league = League.fromJson(data);
        state = state.copyWith(
          currentLeague: league,
          isLoading: false,
          error: null,
        );
        Logger.info('Loaded league data for account', tag: 'LeagueProvider');
      } else {
        // 저장된 데이터가 없으면 Mock 데이터 생성 및 저장
        final mockLeague = _generateMockLeague();
        await _saveLeague(mockLeague);

        state = state.copyWith(
          currentLeague: mockLeague,
          isLoading: false,
          error: null,
        );
        Logger.info('Generated and saved mock league data', tag: 'LeagueProvider');
      }
    } catch (e) {
      Logger.error('Failed to load league', error: e, tag: 'LeagueProvider');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 리그 데이터 저장
  Future<void> _saveLeague(League league) async {
    try {
      final key = _storageKey;
      if (key == null) {
        Logger.warning('Cannot save league - no logged in account', tag: 'LeagueProvider');
        return;
      }

      await _storage.saveMap(key, league.toJson());
      Logger.info('Saved league data for account', tag: 'LeagueProvider');
    } catch (e) {
      Logger.error('Failed to save league', error: e, tag: 'LeagueProvider');
    }
  }

  /// 리그 새로고침
  Future<void> refreshLeague() async {
    await _loadCurrentLeague();
  }

  /// Mock 데이터 생성 (개발용)
  League _generateMockLeague() {
    final now = DateTime.now();
    // 7일 주기로 변경 (듀오링고 스타일)
    final daysIntoCurrentCycle = now.difference(DateTime(2024, 1, 1)).inDays % 7;
    final cycleStart = now.subtract(Duration(days: daysIntoCurrentCycle));
    final cycleEnd = cycleStart.add(const Duration(days: 7));

    final participants = [
      const LeagueParticipant(
        userId: 'user1',
        userName: '수학천재',
        weeklyXp: 2450,
        rank: 1,
        badges: [LeagueBadge.topScorer, LeagueBadge.perfect, LeagueBadge.veteran],
      ),
      const LeagueParticipant(
        userId: 'user2',
        userName: '열공러',
        weeklyXp: 2180,
        rank: 2,
        badges: [LeagueBadge.streak, LeagueBadge.veteran],
      ),
      const LeagueParticipant(
        userId: 'user3',
        userName: '문제풀이왕',
        weeklyXp: 1980,
        rank: 3,
        badges: [LeagueBadge.perfect],
      ),
      const LeagueParticipant(
        userId: 'current_user',
        userName: '나',
        weeklyXp: 1750,
        rank: 4,
        badges: [LeagueBadge.rising, LeagueBadge.streak],
      ),
      const LeagueParticipant(
        userId: 'user5',
        userName: '수포자탈출',
        weeklyXp: 1650,
        rank: 5,
        badges: [LeagueBadge.rising],
      ),
      const LeagueParticipant(
        userId: 'user6',
        userName: '매일학습',
        weeklyXp: 1450,
        rank: 6,
        badges: [LeagueBadge.streak],
      ),
      const LeagueParticipant(
        userId: 'user7',
        userName: '꾸준이',
        weeklyXp: 1350,
        rank: 7,
        badges: [LeagueBadge.veteran],
      ),
      const LeagueParticipant(
        userId: 'user8',
        userName: '열심히',
        weeklyXp: 1250,
        rank: 8,
        badges: [],
      ),
      const LeagueParticipant(
        userId: 'user9',
        userName: '노력파',
        weeklyXp: 1150,
        rank: 9,
        badges: [LeagueBadge.rising],
      ),
      const LeagueParticipant(
        userId: 'user10',
        userName: '성실함',
        weeklyXp: 1050,
        rank: 10,
        badges: [LeagueBadge.streak],
      ),
      const LeagueParticipant(
        userId: 'user11',
        userName: '시작이반',
        weeklyXp: 950,
        rank: 11,
        badges: [],
      ),
      const LeagueParticipant(
        userId: 'user12',
        userName: '도전자',
        weeklyXp: 850,
        rank: 12,
        badges: [],
      ),
      const LeagueParticipant(
        userId: 'user13',
        userName: '초보학습',
        weeklyXp: 750,
        rank: 13,
        badges: [],
      ),
      const LeagueParticipant(
        userId: 'user14',
        userName: '새싹',
        weeklyXp: 650,
        rank: 14,
        badges: [],
      ),
      const LeagueParticipant(
        userId: 'user15',
        userName: '파이팅',
        weeklyXp: 550,
        rank: 15,
        badges: [],
      ),
    ];

    return League(
      // 🎮 듀오링고 스타일 티어 시스템
      // 티어 변경 테스트: bronze, silver, gold, platinum, diamond, champion
      tier: LeagueTier.silver, // <- 여기서 티어 변경 가능
      participants: participants,
      weekStartDate: cycleStart,
      weekEndDate: cycleEnd,
    );
  }
}

/// 리그 Provider 정의
final leagueProvider = StateNotifierProvider<LeagueNotifier, LeagueState>((ref) {
  return LeagueNotifier(ref);
});

/// 현재 사용자의 리그 순위 Provider
final currentUserRankProvider = Provider<int?>((ref) {
  final leagueState = ref.watch(leagueProvider);
  final league = leagueState.currentLeague;
  
  if (league == null) return null;
  return league.getUserRank('current_user');
});

/// 승급 가능 여부 Provider
final canPromoteProvider = Provider<bool>((ref) {
  final leagueState = ref.watch(leagueProvider);
  final league = leagueState.currentLeague;
  
  if (league == null) return false;
  return league.canPromote('current_user');
});

/// 강등 위험 여부 Provider
final isRelegationZoneProvider = Provider<bool>((ref) {
  final leagueState = ref.watch(leagueProvider);
  final league = leagueState.currentLeague;
  
  if (league == null) return false;
  return league.isRelegationZone('current_user');
});
