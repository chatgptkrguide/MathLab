import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/league.dart';
import 'auth_provider.dart';
import 'base/base_notifier.dart';

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

/// 리그 상태 관리 Provider (BaseNotifier 최적화 버전)
///
/// **개선사항:**
/// - BaseNotifier 상속으로 중복 로깅 제거
/// - executeWithErrorHandling로 try-catch 자동화
/// - LocalStorageService 상속으로 필드 제거
class LeagueNotifier extends BaseNotifier<LeagueState> {
  final Ref ref;

  LeagueNotifier(this.ref) : super(const LeagueState(), 'LeagueProvider') {
    _initialize();
  }

  /// 현재 계정 ID 기반 저장소 키
  String? get _storageKey {
    final currentAccount = ref.read(currentAccountProvider);
    if (currentAccount == null) {
      logWarning('계정 정보 없음');
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

    await executeWithErrorHandling(
      () async {
        final key = _storageKey;
        if (key == null) {
          state = state.copyWith(
            currentLeague: null,
            isLoading: false,
            error: null,
          );
          return;
        }

        final data = await loadFromStorage(key);

        if (data != null) {
          final league = League.fromJson(data);
          state = state.copyWith(
            currentLeague: league,
            isLoading: false,
            error: null,
          );
          logInfo('리그 데이터 로드 완료');
        } else {
          final mockLeague = _generateMockLeague();
          await _saveLeague(mockLeague);

          state = state.copyWith(
            currentLeague: mockLeague,
            isLoading: false,
            error: null,
          );
          logInfo('Mock 리그 데이터 생성 및 저장');
        }
      },
      errorMessage: '리그 로드 실패',
      fallback: () => state = state.copyWith(isLoading: false),
    );
  }

  /// 리그 데이터 저장
  Future<void> _saveLeague(League league) async {
    await executeWithErrorHandling(
      () async {
        final key = _storageKey;
        if (key == null) {
          logWarning('리그 저장 불가 - 계정 없음');
          return;
        }

        await saveToStorage(key, league.toJson());
        logInfo('리그 데이터 저장 완료');
      },
      errorMessage: '리그 저장 실패',
    );
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
