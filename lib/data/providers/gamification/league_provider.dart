import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/gamification/league.dart';
import '../../repositories/league_repository.dart';
import '../user/user_provider.dart';
import '../infrastructure/firebase_providers.dart';
import '../base/base_notifier.dart';

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

/// 리그 상태 관리 Provider (Firestore 연동 버전)
///
/// **개선사항:**
/// - LeagueRepository 연결로 Firestore 실시간 동기화
/// - 로컬 + Firebase 자동 동기화
/// - 실시간 리그 업데이트 스트림
class LeagueNotifier extends BaseNotifier<LeagueState> {
  LeagueNotifier(this._ref, this._repository)
      : super(const LeagueState(), 'LeagueProvider') {
    logInfo('LeagueNotifier 초기화 (Firestore 연동)');
    _initialize();
  }

  final Ref _ref;
  final LeagueRepository _repository;
  String get _storageKey => 'league_${_getCurrentUserId()}';

  /// 현재 사용자 ID 가져오기
  String _getCurrentUserId() {
    final user = _ref.read(userProvider);
    return user?.id ?? 'default';
  }

  /// 초기화 및 실시간 동기화 설정
  Future<void> _initialize() async {
    await _loadCurrentLeague();
    _setupRealtimeSync();
  }

  /// 실시간 동기화 설정
  void _setupRealtimeSync() {
    // Firestore 실시간 스트림 감지
    _repository.watchCurrentLeague().listen((league) {
      if (league != null) {
        state = state.copyWith(
          currentLeague: league,
          isLoading: false,
          error: null,
        );
        logInfo('실시간 리그 업데이트: ${league.tier}');
      }
    });
  }

  /// 현재 리그 정보 로드 (로컬 → Firebase → 병합)
  Future<void> _loadCurrentLeague() async {
    logInfo('리그 데이터 로드 시작 (Firestore 연동)');
    state = state.copyWith(isLoading: true);

    await executeWithErrorHandling(
      () async {
        final userId = _getCurrentUserId();

        // 1. 로컬 데이터 먼저 로드 (빠른 UI 표시)
        final localLeague = await _repository.getFromLocal(_storageKey);
        if (localLeague != null) {
          state = state.copyWith(
            currentLeague: localLeague,
            isLoading: false,
            error: null,
          );
          logInfo('로컬 리그 데이터 로드 완료');
        }

        // 2. Firebase에서 현재 주간 리그 로드
        final remoteLeague = await _repository.getFromFirebase();

        if (remoteLeague != null) {
          // 3. Firebase 데이터로 업데이트
          state = state.copyWith(
            currentLeague: remoteLeague,
            isLoading: false,
            error: null,
          );
          await _repository.saveToLocal(_storageKey, remoteLeague);
          logInfo('Firebase 리그 데이터 로드 완료');

          // 4. 사용자가 참가하지 않았다면 자동 참가
          if (!remoteLeague.isUserParticipant(userId)) {
            await joinCurrentLeague();
          }
        } else if (localLeague == null) {
          // 5. Firebase에도 없고 로컬에도 없으면 새 리그 생성
          logInfo('리그 데이터 없음, 새 리그 생성 필요');
          state = state.copyWith(
            currentLeague: null,
            isLoading: false,
            error: null,
          );
        }

        logInfo('리그 로드 완료');
      },
      errorMessage: '리그 로드 실패',
      fallback: () => state = state.copyWith(isLoading: false),
    );
  }

  /// 리그 새로고침
  Future<void> refreshLeague() async {
    await _loadCurrentLeague();
  }

  /// 현재 리그 참가
  Future<void> joinCurrentLeague() async {
    await executeWithErrorHandling(
      () async {
        final userId = _getCurrentUserId();
        final user = _ref.read(userProvider);

        if (user == null) {
          logWarning('사용자 정보 없음');
          return;
        }

        await _repository.joinLeague(
          userId: userId,
          userName: user.name,
          avatarUrl: user.photoUrl,
        );

        logInfo('리그 참가 완료');
        await refreshLeague();
      },
      errorMessage: '리그 참가 실패',
    );
  }

  /// XP 업데이트 (Firestore 동기화)
  Future<void> updateUserXP(int xpGained) async {
    await executeWithErrorHandling(
      () async {
        final userId = _getCurrentUserId();
        final currentLeague = state.currentLeague;

        if (currentLeague == null) {
          logWarning('리그 정보 없음 - XP 업데이트 불가');
          return;
        }

        // 현재 사용자의 주간 XP 계산
        final participant = currentLeague.participants.firstWhere(
          (p) => p.userId == userId,
          orElse: () => const LeagueParticipant(
            userId: '',
            userName: '',
            weeklyXp: 0,
            rank: 0,
            badges: [],
          ),
        );

        final newWeeklyXp = participant.weeklyXp + xpGained;

        // Firestore 업데이트
        await _repository.updateUserXP(
          userId: userId,
          weeklyXp: newWeeklyXp,
          tier: currentLeague.tier,
        );

        logInfo('리그 XP 업데이트 완료: +$xpGained (총: $newWeeklyXp)');
        // 실시간 스트림이 자동으로 state 업데이트
      },
      errorMessage: 'XP 업데이트 실패',
    );
  }

  /// 뱃지 추가
  Future<void> addBadge(LeagueBadge badge) async {
    await executeWithErrorHandling(
      () async {
        final userId = _getCurrentUserId();
        final currentLeague = state.currentLeague;

        if (currentLeague == null) {
          logWarning('리그 정보 없음 - 뱃지 추가 불가');
          return;
        }

        await _repository.addBadge(
          userId: userId,
          badge: badge,
          tier: currentLeague.tier,
        );

        logInfo('뱃지 추가 완료: $badge');
      },
      errorMessage: '뱃지 추가 실패',
    );
  }
}

/// 리그 Provider 정의
final leagueProvider =
    StateNotifierProvider<LeagueNotifier, LeagueState>((ref) {
  final leagueRepository = ref.watch(leagueRepositoryProvider);
  return LeagueNotifier(ref, leagueRepository);
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
