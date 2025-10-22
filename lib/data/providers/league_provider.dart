import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/league.dart';
import '../models/user.dart';
import 'user_provider.dart';
import '../../shared/utils/logger.dart';
import '../../data/services/local_storage_service.dart';

/// 주간 리그 참가자 정보
class LeagueParticipant {
  final String id;
  final String name;
  final int weeklyXP;
  final int totalXP;
  final LeagueTier tier;
  final String? avatarUrl;

  const LeagueParticipant({
    required this.id,
    required this.name,
    required this.weeklyXP,
    required this.totalXP,
    required this.tier,
    this.avatarUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'weeklyXP': weeklyXP,
      'totalXP': totalXP,
      'tier': tier.name,
      'avatarUrl': avatarUrl,
    };
  }

  factory LeagueParticipant.fromJson(Map<String, dynamic> json) {
    return LeagueParticipant(
      id: json['id'] as String,
      name: json['name'] as String,
      weeklyXP: json['weeklyXP'] as int,
      totalXP: json['totalXP'] as int,
      tier: LeagueTier.values.firstWhere(
        (t) => t.name == json['tier'],
        orElse: () => LeagueTier.bronze,
      ),
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  LeagueParticipant copyWith({
    String? id,
    String? name,
    int? weeklyXP,
    int? totalXP,
    LeagueTier? tier,
    String? avatarUrl,
  }) {
    return LeagueParticipant(
      id: id ?? this.id,
      name: name ?? this.name,
      weeklyXP: weeklyXP ?? this.weeklyXP,
      totalXP: totalXP ?? this.totalXP,
      tier: tier ?? this.tier,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

/// 리그 상태
class LeagueState {
  final LeagueInfo myLeagueInfo;
  final List<LeagueParticipant> participants;
  final DateTime weekStartDate;
  final DateTime weekEndDate;
  final int myWeeklyXP;
  final bool isWeekEnded;

  const LeagueState({
    required this.myLeagueInfo,
    required this.participants,
    required this.weekStartDate,
    required this.weekEndDate,
    required this.myWeeklyXP,
    required this.isWeekEnded,
  });

  LeagueState copyWith({
    LeagueInfo? myLeagueInfo,
    List<LeagueParticipant>? participants,
    DateTime? weekStartDate,
    DateTime? weekEndDate,
    int? myWeeklyXP,
    bool? isWeekEnded,
  }) {
    return LeagueState(
      myLeagueInfo: myLeagueInfo ?? this.myLeagueInfo,
      participants: participants ?? this.participants,
      weekStartDate: weekStartDate ?? this.weekStartDate,
      weekEndDate: weekEndDate ?? this.weekEndDate,
      myWeeklyXP: myWeeklyXP ?? this.myWeeklyXP,
      isWeekEnded: isWeekEnded ?? this.isWeekEnded,
    );
  }

  /// 내 순위
  int get myRank {
    final sortedParticipants = [...participants]
      ..sort((a, b) => b.weeklyXP.compareTo(a.weeklyXP));

    final myIndex = sortedParticipants.indexWhere((p) => p.id == 'current_user');
    return myIndex + 1;
  }

  /// 남은 시간 (초)
  int get remainingSeconds {
    final now = DateTime.now();
    return weekEndDate.difference(now).inSeconds.clamp(0, double.infinity).toInt();
  }

  /// 남은 시간 문자열
  String get remainingTimeString {
    final duration = Duration(seconds: remainingSeconds);
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;

    if (days > 0) {
      return '$days일 ${hours}시간';
    } else if (hours > 0) {
      return '$hours시간 ${minutes}분';
    } else {
      return '$minutes분';
    }
  }
}

/// 리그 Provider
class LeagueProvider extends StateNotifier<LeagueState> {
  final Ref _ref;
  final LocalStorageService _storage = LocalStorageService();
  Timer? _weeklyResetTimer;

  static const String _storageKey = 'league_state';
  static const String _weeklyXPKey = 'weekly_xp';

  LeagueProvider(this._ref)
      : super(LeagueState(
          myLeagueInfo: const LeagueInfo(
            tier: LeagueTier.bronze,
            currentXP: 0,
            rank: 1,
            totalPlayers: 50,
          ),
          participants: [],
          weekStartDate: DateTime.now(),
          weekEndDate: DateTime.now().add(const Duration(days: 7)),
          myWeeklyXP: 0,
          isWeekEnded: false,
        )) {
    _loadState();
    _generateMockParticipants();
    _startWeeklyResetTimer();
  }

  @override
  void dispose() {
    _weeklyResetTimer?.cancel();
    super.dispose();
  }

  /// 상태 로드
  Future<void> _loadState() async {
    try {
      final data = await _storage.loadMap(_storageKey);
      if (data != null) {
        final weekStartDate = DateTime.parse(data['weekStartDate']);
        final weekEndDate = DateTime.parse(data['weekEndDate']);
        final myWeeklyXP = data['myWeeklyXP'] ?? 0;

        // 주가 끝났는지 확인
        final now = DateTime.now();
        final isWeekEnded = now.isAfter(weekEndDate);

        if (isWeekEnded) {
          // 주간 리셋
          await _performWeeklyReset();
        } else {
          // 기존 상태 복원
          final participants = (data['participants'] as List?)
              ?.map((p) => LeagueParticipant.fromJson(p))
              .toList() ?? [];

          final user = _ref.read(userProvider);
          final myLeagueInfo = LeagueInfo(
            tier: LeagueTier.fromXP(user?.xp ?? 0),
            currentXP: user?.xp ?? 0,
            rank: 1, // 순위는 동적으로 계산
            totalPlayers: participants.length,
          );

          state = state.copyWith(
            myLeagueInfo: myLeagueInfo,
            participants: participants,
            weekStartDate: weekStartDate,
            weekEndDate: weekEndDate,
            myWeeklyXP: myWeeklyXP,
            isWeekEnded: false,
          );

          Logger.info('League state loaded successfully');
        }
      }
    } catch (e) {
      Logger.error('Failed to load league state', error: e);
    }
  }

  /// 상태 저장
  Future<void> _saveState() async {
    try {
      await _storage.saveMap(_storageKey, {
        'weekStartDate': state.weekStartDate.toIso8601String(),
        'weekEndDate': state.weekEndDate.toIso8601String(),
        'myWeeklyXP': state.myWeeklyXP,
        'participants': state.participants.map((p) => p.toJson()).toList(),
      });

      Logger.info('League state saved successfully');
    } catch (e) {
      Logger.error('Failed to save league state', error: e);
    }
  }

  /// 주간 리셋 타이머 시작
  void _startWeeklyResetTimer() {
    _weeklyResetTimer?.cancel();

    // 매일 자정에 체크
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final timeUntilMidnight = tomorrow.difference(now);

    _weeklyResetTimer = Timer(timeUntilMidnight, () {
      _checkAndResetWeek();
      _startWeeklyResetTimer(); // 재귀적으로 다시 시작
    });

    Logger.info('Weekly reset timer started');
  }

  /// 주간 리셋 체크
  Future<void> _checkAndResetWeek() async {
    final now = DateTime.now();
    if (now.isAfter(state.weekEndDate)) {
      await _performWeeklyReset();
    }
  }

  /// 주간 리셋 실행
  Future<void> _performWeeklyReset() async {
    Logger.info('Performing weekly league reset');

    // 보상 지급 (상위 20% 승급, 하위 20% 강등)
    final myRank = state.myRank;
    final totalPlayers = state.participants.length;
    final topPercentage = (myRank / totalPlayers) * 100;

    final user = _ref.read(userProvider);
    LeagueTier newTier = LeagueTier.fromXP(user?.xp ?? 0);

    if (topPercentage <= 20) {
      // 승급
      final nextTier = newTier.nextTier;
      if (nextTier != null) {
        newTier = nextTier;
        Logger.info('🎉 Promoted to ${nextTier.displayName}!');

        // 승급 보상 지급
        await _givePromotionReward(nextTier);
      }
    } else if (topPercentage >= 80) {
      // 강등 (Bronze는 강등 없음)
      if (newTier != LeagueTier.bronze) {
        final tierIndex = LeagueTier.values.indexOf(newTier);
        if (tierIndex > 0) {
          newTier = LeagueTier.values[tierIndex - 1];
          Logger.info('⬇️ Relegated to ${newTier.displayName}');
        }
      }
    }

    // 새로운 주 시작
    final now = DateTime.now();
    final weekStart = _getWeekStart(now);
    final weekEnd = weekStart.add(const Duration(days: 7));

    state = LeagueState(
      myLeagueInfo: LeagueInfo(
        tier: newTier,
        currentXP: user?.xp ?? 0,
        rank: 1,
        totalPlayers: 50,
      ),
      participants: [],
      weekStartDate: weekStart,
      weekEndDate: weekEnd,
      myWeeklyXP: 0,
      isWeekEnded: false,
    );

    await _storage.setInt(_weeklyXPKey, 0);
    await _saveState();
    _generateMockParticipants();
  }

  /// 주 시작일 계산 (월요일 기준)
  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday;
    final diff = weekday - DateTime.monday;
    return DateTime(date.year, date.month, date.day - diff);
  }

  /// 승급 보상 지급
  Future<void> _givePromotionReward(LeagueTier promotedTier) async {
    // 티어별 보상 설정
    final Map<LeagueTier, Map<String, int>> rewards = {
      LeagueTier.silver: {'xp': 50, 'hearts': 1},
      LeagueTier.gold: {'xp': 100, 'hearts': 2},
      LeagueTier.diamond: {'xp': 200, 'hearts': 3},
    };

    final reward = rewards[promotedTier];
    if (reward != null) {
      // XP 보상
      final xpReward = reward['xp'] ?? 0;
      if (xpReward > 0) {
        await _ref.read(userProvider.notifier).addXP(xpReward);
        Logger.info('승급 보상 XP 지급: +$xpReward XP', tag: 'LeagueProvider');
      }

      // 하트 보상
      final heartsReward = reward['hearts'] ?? 0;
      if (heartsReward > 0) {
        await _ref.read(userProvider.notifier).addHearts(heartsReward);
        Logger.info('승급 보상 하트 지급: +$heartsReward 하트', tag: 'LeagueProvider');
      }
    }
  }

  /// 주간 XP 추가
  Future<void> addWeeklyXP(int xp) async {
    final newWeeklyXP = state.myWeeklyXP + xp;

    // 내 정보 업데이트
    final updatedParticipants = state.participants.map((p) {
      if (p.id == 'current_user') {
        return p.copyWith(weeklyXP: newWeeklyXP);
      }
      return p;
    }).toList();

    // 순위 재계산
    final sortedParticipants = [...updatedParticipants]
      ..sort((a, b) => b.weeklyXP.compareTo(a.weeklyXP));

    final myRank = sortedParticipants.indexWhere((p) => p.id == 'current_user') + 1;

    final user = _ref.read(userProvider);
    final updatedLeagueInfo = state.myLeagueInfo.copyWith(
      currentXP: user?.xp ?? 0,
      rank: myRank,
    );

    state = state.copyWith(
      myLeagueInfo: updatedLeagueInfo,
      participants: updatedParticipants,
      myWeeklyXP: newWeeklyXP,
    );

    await _storage.setInt(_weeklyXPKey, newWeeklyXP);
    await _saveState();

    Logger.info('Weekly XP added: +$xp (total: $newWeeklyXP, rank: $myRank)');
  }

  /// 모의 참가자 생성 (개발용)
  void _generateMockParticipants() {
    final user = _ref.read(userProvider);
    final myTier = LeagueTier.fromXP(user?.xp ?? 0);

    final participants = <LeagueParticipant>[
      // 현재 사용자
      LeagueParticipant(
        id: 'current_user',
        name: user?.name ?? '나',
        weeklyXP: state.myWeeklyXP,
        totalXP: user?.xp ?? 0,
        tier: myTier,
      ),
      // 모의 참가자들
      ...List.generate(49, (index) {
        final weeklyXP = 50 + (index * 10) + (index % 5) * 20;
        final totalXP = 200 + (index * 50);
        return LeagueParticipant(
          id: 'bot_$index',
          name: _generateBotName(index),
          weeklyXP: weeklyXP,
          totalXP: totalXP,
          tier: LeagueTier.fromXP(totalXP),
        );
      }),
    ];

    // 순위 계산
    final sortedParticipants = [...participants]
      ..sort((a, b) => b.weeklyXP.compareTo(a.weeklyXP));

    final myRank = sortedParticipants.indexWhere((p) => p.id == 'current_user') + 1;

    final updatedLeagueInfo = state.myLeagueInfo.copyWith(
      rank: myRank,
      totalPlayers: participants.length,
    );

    state = state.copyWith(
      myLeagueInfo: updatedLeagueInfo,
      participants: participants,
    );

    Logger.info('Generated ${participants.length} mock participants');
  }

  /// 봇 이름 생성
  String _generateBotName(int index) {
    final firstNames = ['수학왕', '천재', '학습러', '공부벌레', '열공맨', '수포자탈출', '계산왕'];
    final lastNames = ['김', '이', '박', '최', '정', '강', '조', '윤', '장', '임'];

    return '${lastNames[index % lastNames.length]}${firstNames[index % firstNames.length]}${index + 1}';
  }

  /// 리그 정보 새로고침
  void refresh() {
    final user = _ref.read(userProvider);
    final updatedLeagueInfo = state.myLeagueInfo.copyWith(
      currentXP: user?.xp ?? 0,
    );

    state = state.copyWith(myLeagueInfo: updatedLeagueInfo);
  }
}

/// Provider 정의
final leagueProvider = StateNotifierProvider<LeagueProvider, LeagueState>((ref) {
  return LeagueProvider(ref);
});
