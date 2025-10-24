import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/daily_challenge.dart';
import '../models/user.dart';
import 'user_provider.dart';
import '../../shared/utils/logger.dart';
import '../services/local_storage_service.dart';

/// 일일 챌린지 상태
class DailyChallengeState {
  final List<DailyChallenge> challenges;
  final DateTime lastGeneratedDate;
  final int completedCount;

  const DailyChallengeState({
    required this.challenges,
    required this.lastGeneratedDate,
    required this.completedCount,
  });

  DailyChallengeState copyWith({
    List<DailyChallenge>? challenges,
    DateTime? lastGeneratedDate,
    int? completedCount,
  }) {
    return DailyChallengeState(
      challenges: challenges ?? this.challenges,
      lastGeneratedDate: lastGeneratedDate ?? this.lastGeneratedDate,
      completedCount: completedCount ?? this.completedCount,
    );
  }

  /// 모든 챌린지 완료 여부
  bool get allCompleted =>
      challenges.isNotEmpty && challenges.every((c) => c.isCompleted);

  /// 진행률 (0.0 ~ 1.0)
  double get progress {
    if (challenges.isEmpty) return 0.0;
    return completedCount / challenges.length;
  }
}

/// 일일 챌린지 Provider
class DailyChallengeProvider extends StateNotifier<DailyChallengeState> {
  final Ref _ref;
  final LocalStorageService _storage = LocalStorageService();

  static const String _storageKey = 'daily_challenges_state';
  static const int challengeCount = 3; // 하루 3개 챌린지

  DailyChallengeProvider(this._ref)
      : super(DailyChallengeState(
          challenges: [],
          lastGeneratedDate: DateTime.now(),
          completedCount: 0,
        )) {
    _loadState();
  }

  /// 상태 로드
  Future<void> _loadState() async {
    try {
      final data = await _storage.loadMap(_storageKey);
      if (data != null) {
        final lastGeneratedDate = data['lastGeneratedDate'] != null
            ? DateTime.parse(data['lastGeneratedDate'])
            : DateTime.now();

        // 챌린지 리스트 복원
        final challengesData = data['challenges'] as List<dynamic>?;
        final challenges = challengesData
                ?.map((c) => DailyChallenge.fromJson(c as Map<String, dynamic>))
                .toList() ??
            [];

        state = state.copyWith(
          challenges: challenges,
          lastGeneratedDate: lastGeneratedDate,
          completedCount: challenges.where((c) => c.isCompleted).length,
        );

        Logger.info(
          'Daily challenges loaded: ${challenges.length} challenges',
          tag: 'DailyChallengeProvider',
        );

        // 날짜가 바뀌었으면 새 챌린지 생성
        await _checkAndGenerateNewChallenges();
      } else {
        // 최초 실행: 챌린지 생성
        await _generateDailyChallenges();
      }
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to load daily challenges',
        error: e,
        stackTrace: stackTrace,
        tag: 'DailyChallengeProvider',
      );
      await _generateDailyChallenges();
    }
  }

  /// 상태 저장
  Future<void> _saveState() async {
    try {
      await _storage.saveMap(_storageKey, {
        'lastGeneratedDate': state.lastGeneratedDate.toIso8601String(),
        'challenges': state.challenges.map((c) => c.toJson()).toList(),
      });

      Logger.debug('Daily challenges saved', tag: 'DailyChallengeProvider');
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to save daily challenges',
        error: e,
        stackTrace: stackTrace,
        tag: 'DailyChallengeProvider',
      );
    }
  }

  /// 날짜 체크 및 새 챌린지 생성
  Future<void> _checkAndGenerateNewChallenges() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastGenerated = DateTime(
      state.lastGeneratedDate.year,
      state.lastGeneratedDate.month,
      state.lastGeneratedDate.day,
    );

    // 날짜가 바뀌었으면 새 챌린지 생성
    if (today.isAfter(lastGenerated)) {
      await _generateDailyChallenges();
      Logger.info('New daily challenges generated', tag: 'DailyChallengeProvider');
    }
  }

  /// 일일 챌린지 생성
  Future<void> _generateDailyChallenges() async {
    final now = DateTime.now();
    final challenges = <DailyChallenge>[];

    // 챌린지 타입 풀 (6가지 중 3개 랜덤 선택)
    final allTypes = ChallengeType.values.toList();
    allTypes.shuffle();
    final selectedTypes = allTypes.take(challengeCount).toList();

    for (int i = 0; i < selectedTypes.length; i++) {
      final type = selectedTypes[i];
      challenges.add(_createChallenge(type, i + 1, now));
    }

    state = state.copyWith(
      challenges: challenges,
      lastGeneratedDate: now,
      completedCount: 0,
    );

    await _saveState();
    Logger.info(
      'Generated ${challenges.length} daily challenges',
      tag: 'DailyChallengeProvider',
    );
  }

  /// 챌린지 타입별 생성
  DailyChallenge _createChallenge(ChallengeType type, int index, DateTime date) {
    final id = 'challenge_${date.year}_${date.month}_${date.day}_$index';

    switch (type) {
      case ChallengeType.solveProblems:
        return DailyChallenge(
          id: id,
          type: type,
          title: '문제 풀이 마스터',
          description: '오늘 10개 문제 해결하기',
          targetValue: 10,
          currentValue: 0,
          xpReward: 50,
          date: date,
        );

      case ChallengeType.earnXP:
        return DailyChallenge(
          id: id,
          type: type,
          title: 'XP 수집가',
          description: '오늘 100 XP 획득하기',
          targetValue: 100,
          currentValue: 0,
          xpReward: 30,
          date: date,
        );

      case ChallengeType.perfectStreak:
        return DailyChallenge(
          id: id,
          type: type,
          title: '연속 정답 챌린지',
          description: '5번 연속 정답 달성하기',
          targetValue: 5,
          currentValue: 0,
          xpReward: 40,
          date: date,
        );

      case ChallengeType.categoryFocus:
        return DailyChallenge(
          id: id,
          type: type,
          title: '카테고리 집중',
          description: '기초산술 5문제 풀기',
          targetValue: 5,
          currentValue: 0,
          xpReward: 35,
          date: date,
        );

      case ChallengeType.accuracy:
        return DailyChallenge(
          id: id,
          type: type,
          title: '정확도 챌린지',
          description: '정답률 80% 이상 달성하기',
          targetValue: 80,
          currentValue: 0,
          xpReward: 45,
          date: date,
        );

      case ChallengeType.fastSolver:
        return DailyChallenge(
          id: id,
          type: type,
          title: '스피드 챌린지',
          description: '10초 안에 3문제 풀기',
          targetValue: 3,
          currentValue: 0,
          xpReward: 40,
          date: date,
        );
    }
  }

  /// 챌린지 진행률 업데이트
  Future<void> updateProgress(ChallengeType type, int value) async {
    final updatedChallenges = state.challenges.map((challenge) {
      if (challenge.type == type && !challenge.isCompleted) {
        final newValue = (challenge.currentValue + value)
            .clamp(0, challenge.targetValue);
        final newChallenge = challenge.copyWith(currentValue: newValue);

        // 완료되었으면 XP 지급
        if (newChallenge.completed && !challenge.completed) {
          _ref.read(userProvider.notifier).addXP(challenge.xpReward);
          Logger.info(
            'Challenge completed: ${challenge.title} (+${challenge.xpReward} XP)',
            tag: 'DailyChallengeProvider',
          );
        }

        return newChallenge.copyWith(isCompleted: newChallenge.completed);
      }
      return challenge;
    }).toList();

    final completedCount = updatedChallenges.where((c) => c.isCompleted).length;

    state = state.copyWith(
      challenges: updatedChallenges,
      completedCount: completedCount,
    );

    await _saveState();
  }

  /// 특정 챌린지 진행률 직접 설정 (테스트용)
  Future<void> setProgress(String challengeId, int value) async {
    final updatedChallenges = state.challenges.map((challenge) {
      if (challenge.id == challengeId && !challenge.isCompleted) {
        final newValue = value.clamp(0, challenge.targetValue);
        final newChallenge = challenge.copyWith(currentValue: newValue);

        // 완료되었으면 XP 지급
        if (newChallenge.completed && !challenge.completed) {
          _ref.read(userProvider.notifier).addXP(challenge.xpReward);
        }

        return newChallenge.copyWith(isCompleted: newChallenge.completed);
      }
      return challenge;
    }).toList();

    final completedCount = updatedChallenges.where((c) => c.isCompleted).length;

    state = state.copyWith(
      challenges: updatedChallenges,
      completedCount: completedCount,
    );

    await _saveState();
  }

  /// 상태 새로고침 (날짜 변경 체크)
  Future<void> refresh() async {
    await _checkAndGenerateNewChallenges();
  }

  /// 챌린지 강제 재생성 (테스트용)
  Future<void> regenerateChallenges() async {
    await _generateDailyChallenges();
  }
}

/// Provider 정의
final dailyChallengeProvider =
    StateNotifierProvider<DailyChallengeProvider, DailyChallengeState>((ref) {
  return DailyChallengeProvider(ref);
});

/// 편의 프로바이더
final completedChallengesProvider = Provider<int>((ref) {
  final state = ref.watch(dailyChallengeProvider);
  return state.completedCount;
});

final allChallengesCompletedProvider = Provider<bool>((ref) {
  final state = ref.watch(dailyChallengeProvider);
  return state.allCompleted;
});
