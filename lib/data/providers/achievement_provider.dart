import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/achievement.dart';
import '../models/user.dart';
import 'user_provider.dart';
import '../../shared/utils/logger.dart';
import '../../data/services/local_storage_service.dart';

/// 업적 상태
class AchievementState {
  final List<Achievement> achievements;
  final List<String> unlockedIds;
  final Achievement? recentlyUnlocked;

  const AchievementState({
    required this.achievements,
    required this.unlockedIds,
    this.recentlyUnlocked,
  });

  AchievementState copyWith({
    List<Achievement>? achievements,
    List<String>? unlockedIds,
    Achievement? recentlyUnlocked,
    bool clearRecent = false,
  }) {
    return AchievementState(
      achievements: achievements ?? this.achievements,
      unlockedIds: unlockedIds ?? this.unlockedIds,
      recentlyUnlocked: clearRecent ? null : (recentlyUnlocked ?? this.recentlyUnlocked),
    );
  }

  /// 언락된 업적 수
  int get unlockedCount => achievements.where((a) => a.isUnlocked).length;

  /// 전체 업적 수
  int get totalCount => achievements.length;

  /// 달성률 (0.0 ~ 1.0)
  double get completionRate => totalCount > 0 ? unlockedCount / totalCount : 0.0;

  /// Iterable 지원을 위한 firstWhere 메서드
  Achievement firstWhere(bool Function(Achievement) test, {Achievement Function()? orElse}) {
    return achievements.firstWhere(test, orElse: orElse);
  }

  /// Iterable 지원을 위한 first getter
  Achievement get first => achievements.first;
}

/// 업적 Provider
class AchievementProvider extends StateNotifier<AchievementState> {
  final Ref _ref;
  final LocalStorageService _storage = LocalStorageService();

  static const String _storageKey = 'achievements_state';

  AchievementProvider(this._ref)
      : super(const AchievementState(
          achievements: [],
          unlockedIds: [],
        )) {
    _initializeAchievements();
    _loadState();
  }

  /// 업적 초기화
  void _initializeAchievements() {
    final achievements = [
      // 문제 풀이 업적
      Achievement(
        id: 'first_problem',
        title: '첫 걸음',
        description: '첫 문제를 풀어보세요',
        icon: '🎯',
        type: AchievementType.problems,
        requiredValue: 1,
        rarity: AchievementRarity.common,
        xpReward: 10,
        currentValue: 0,
        isUnlocked: false,
      ),
      Achievement(
        id: 'problems_10',
        title: '탐험가',
        description: '문제 10개 해결',
        icon: '🌟',
        type: AchievementType.problems,
        requiredValue: 10,
        rarity: AchievementRarity.common,
        xpReward: 20,
        currentValue: 0,
        isUnlocked: false,
      ),
      Achievement(
        id: 'problems_50',
        title: '수학 전사',
        description: '문제 50개 해결',
        icon: '⚔️',
        type: AchievementType.problems,
        requiredValue: 50,
        rarity: AchievementRarity.rare,
        xpReward: 50,
        currentValue: 0,
        isUnlocked: false,
      ),
      Achievement(
        id: 'problems_100',
        title: '수학 마스터',
        description: '문제 100개 해결',
        icon: '👑',
        type: AchievementType.problems,
        requiredValue: 100,
        rarity: AchievementRarity.epic,
        xpReward: 100,
        currentValue: 0,
        isUnlocked: false,
      ),
      Achievement(
        id: 'problems_500',
        title: '전설의 수학자',
        description: '문제 500개 해결',
        icon: '🏆',
        type: AchievementType.problems,
        requiredValue: 500,
        rarity: AchievementRarity.legendary,
        xpReward: 300,
        currentValue: 0,
        isUnlocked: false,
      ),

      // 스트릭 업적
      Achievement(
        id: 'streak_3',
        title: '꾸준함의 시작',
        description: '3일 연속 학습',
        icon: '🔥',
        type: AchievementType.streak,
        requiredValue: 3,
        rarity: AchievementRarity.common,
        xpReward: 15,
        currentValue: 0,
        isUnlocked: false,
      ),
      Achievement(
        id: 'streak_7',
        title: '일주일의 힘',
        description: '7일 연속 학습',
        icon: '💪',
        type: AchievementType.streak,
        requiredValue: 7,
        rarity: AchievementRarity.rare,
        xpReward: 40,
        currentValue: 0,
        isUnlocked: false,
      ),
      Achievement(
        id: 'streak_30',
        title: '한 달의 기적',
        description: '30일 연속 학습',
        icon: '🌈',
        type: AchievementType.streak,
        requiredValue: 30,
        rarity: AchievementRarity.epic,
        xpReward: 150,
        currentValue: 0,
        isUnlocked: false,
      ),
      Achievement(
        id: 'streak_100',
        title: '불굴의 의지',
        description: '100일 연속 학습',
        icon: '💎',
        type: AchievementType.streak,
        requiredValue: 100,
        rarity: AchievementRarity.legendary,
        xpReward: 500,
        currentValue: 0,
        isUnlocked: false,
      ),

      // 레벨 업적
      Achievement(
        id: 'level_5',
        title: '초보 탈출',
        description: '레벨 5 달성',
        icon: '📚',
        type: AchievementType.level,
        requiredValue: 5,
        rarity: AchievementRarity.common,
        xpReward: 25,
        currentValue: 0,
        isUnlocked: false,
      ),
      Achievement(
        id: 'level_10',
        title: '중급자',
        description: '레벨 10 달성',
        icon: '📖',
        type: AchievementType.level,
        requiredValue: 10,
        rarity: AchievementRarity.rare,
        xpReward: 50,
        currentValue: 0,
        isUnlocked: false,
      ),
      Achievement(
        id: 'level_25',
        title: '고급 학습자',
        description: '레벨 25 달성',
        icon: '🎓',
        type: AchievementType.level,
        requiredValue: 25,
        rarity: AchievementRarity.epic,
        xpReward: 100,
        currentValue: 0,
        isUnlocked: false,
      ),
      Achievement(
        id: 'level_50',
        title: '수학 천재',
        description: '레벨 50 달성',
        icon: '🧠',
        type: AchievementType.level,
        requiredValue: 50,
        rarity: AchievementRarity.legendary,
        xpReward: 250,
        currentValue: 0,
        isUnlocked: false,
      ),

      // XP 업적
      Achievement(
        id: 'xp_1000',
        title: 'XP 수집가',
        description: '총 1,000 XP 획득',
        icon: '⭐',
        type: AchievementType.xp,
        requiredValue: 1000,
        rarity: AchievementRarity.rare,
        xpReward: 30,
        currentValue: 0,
        isUnlocked: false,
      ),
      Achievement(
        id: 'xp_5000',
        title: 'XP 전문가',
        description: '총 5,000 XP 획득',
        icon: '✨',
        type: AchievementType.xp,
        requiredValue: 5000,
        rarity: AchievementRarity.epic,
        xpReward: 100,
        currentValue: 0,
        isUnlocked: false,
      ),
      Achievement(
        id: 'xp_10000',
        title: 'XP 마스터',
        description: '총 10,000 XP 획득',
        icon: '💫',
        type: AchievementType.xp,
        requiredValue: 10000,
        rarity: AchievementRarity.legendary,
        xpReward: 300,
        currentValue: 0,
        isUnlocked: false,
      ),

      // 퍼펙트 업적
      Achievement(
        id: 'perfect_5',
        title: '완벽주의자',
        description: '5번 연속 정답',
        icon: '✅',
        type: AchievementType.perfect,
        requiredValue: 5,
        rarity: AchievementRarity.rare,
        xpReward: 35,
        currentValue: 0,
        isUnlocked: false,
      ),
      Achievement(
        id: 'perfect_10',
        title: '무결점',
        description: '10번 연속 정답',
        icon: '💯',
        type: AchievementType.perfect,
        requiredValue: 10,
        rarity: AchievementRarity.epic,
        xpReward: 80,
        currentValue: 0,
        isUnlocked: false,
      ),

      // 시간 업적
      Achievement(
        id: 'speed_demon',
        title: '스피드 데몬',
        description: '10초 안에 문제 해결',
        icon: '⚡',
        type: AchievementType.time,
        requiredValue: 10,
        rarity: AchievementRarity.rare,
        xpReward: 40,
        currentValue: 0,
        isUnlocked: false,
      ),
      Achievement(
        id: 'lightning_fast',
        title: '번개처럼 빠르게',
        description: '5초 안에 문제 해결',
        icon: '🚀',
        type: AchievementType.time,
        requiredValue: 5,
        rarity: AchievementRarity.epic,
        xpReward: 75,
        currentValue: 0,
        isUnlocked: false,
      ),
    ];

    state = state.copyWith(achievements: achievements);
    Logger.info('Achievements initialized: ${achievements.length} achievements');
  }

  /// 상태 로드
  Future<void> _loadState() async {
    try {
      final data = await _storage.loadMap(_storageKey);
      if (data != null) {
        final unlockedIds = List<String>.from(data['unlockedIds'] ?? []);
        final progressMap = Map<String, int>.from(data['progressMap'] ?? {});
        final unlockedDatesData = data['unlockedDates'];

        // 달성 날짜 맵 생성
        final unlockedDates = <String, DateTime>{};
        if (unlockedDatesData != null) {
          final datesMap = Map<String, String>.from(unlockedDatesData);
          for (final entry in datesMap.entries) {
            try {
              unlockedDates[entry.key] = DateTime.parse(entry.value);
            } catch (e) {
              Logger.warning('Failed to parse unlock date for ${entry.key}');
            }
          }
        }

        // 업적 상태 복원
        final updatedAchievements = state.achievements.map((achievement) {
          final isUnlocked = unlockedIds.contains(achievement.id);
          final progress = progressMap[achievement.id] ?? 0;
          final unlockDate = unlockedDates[achievement.id];

          return Achievement(
            id: achievement.id,
            title: achievement.title,
            description: achievement.description,
            icon: achievement.icon,
            type: achievement.type,
            requiredValue: achievement.requiredValue,
            currentValue: progress,
            isUnlocked: isUnlocked,
            unlockedAt: unlockDate,
            rarity: achievement.rarity,
            xpReward: achievement.xpReward,
          );
        }).toList();

        state = state.copyWith(
          achievements: updatedAchievements,
          unlockedIds: unlockedIds,
        );

        Logger.info('Achievement state loaded: ${unlockedIds.length} unlocked');
      }
    } catch (e) {
      Logger.error('Failed to load achievement state', error: e);
    }
  }

  /// 상태 저장
  Future<void> _saveState() async {
    try {
      final progressMap = <String, int>{};
      final unlockedDates = <String, String>{};

      for (final achievement in state.achievements) {
        progressMap[achievement.id] = achievement.currentValue;

        // 달성 날짜 저장
        if (achievement.isUnlocked && achievement.unlockedAt != null) {
          unlockedDates[achievement.id] = achievement.unlockedAt!.toIso8601String();
        }
      }

      await _storage.saveMap(_storageKey, {
        'unlockedIds': state.unlockedIds,
        'progressMap': progressMap,
        'unlockedDates': unlockedDates,
      });

      Logger.info('Achievement state saved');
    } catch (e) {
      Logger.error('Failed to save achievement state', error: e);
    }
  }

  /// 업적 조건 체크
  Future<void> checkAchievements(User user, {Map<String, dynamic>? stats}) async {
    final newlyUnlocked = <Achievement>[];

    for (final achievement in state.achievements) {
      if (achievement.isUnlocked) continue;

      bool shouldUnlock = false;
      int progress = 0;

      switch (achievement.type) {
        case AchievementType.problems:
          // TODO: 실제 문제 풀이 수를 추적하는 시스템 필요
          progress = stats?['problemsSolved'] ?? 0;
          shouldUnlock = progress >= achievement.requiredValue;
          break;

        case AchievementType.streak:
          progress = user.streakDays;
          shouldUnlock = progress >= achievement.requiredValue;
          break;

        case AchievementType.level:
          progress = user.level;
          shouldUnlock = progress >= achievement.requiredValue;
          break;

        case AchievementType.xp:
          progress = user.xp;
          shouldUnlock = progress >= achievement.requiredValue;
          break;

        case AchievementType.perfect:
          progress = stats?['perfectStreak'] ?? 0;
          shouldUnlock = progress >= achievement.requiredValue;
          break;

        case AchievementType.time:
          final bestTime = stats?['bestTime'] ?? double.infinity;
          progress = (achievement.requiredValue - bestTime).clamp(0, achievement.requiredValue).toInt();
          shouldUnlock = bestTime <= achievement.requiredValue;
          break;

        default:
          // 기타 타입은 스킵
          continue;
      }

      // 진행률 업데이트
      await _updateProgress(achievement.id, progress);

      // 업적 언락
      if (shouldUnlock) {
        final unlocked = await unlockAchievement(achievement.id);
        if (unlocked != null) {
          newlyUnlocked.add(unlocked);
        }
      }
    }

    if (newlyUnlocked.isNotEmpty) {
      Logger.info('Unlocked ${newlyUnlocked.length} new achievements');
    }
  }

  /// 진행률 업데이트
  Future<void> _updateProgress(String achievementId, int progress) async {
    final updatedAchievements = state.achievements.map((achievement) {
      if (achievement.id == achievementId) {
        return Achievement(
          id: achievement.id,
          title: achievement.title,
          description: achievement.description,
          icon: achievement.icon,
          type: achievement.type,
          requiredValue: achievement.requiredValue,
          currentValue: progress,
          isUnlocked: achievement.isUnlocked,
          unlockedAt: achievement.unlockedAt,
          rarity: achievement.rarity,
          xpReward: achievement.xpReward,
        );
      }
      return achievement;
    }).toList();

    state = state.copyWith(achievements: updatedAchievements);
  }

  /// 업적 언락
  Future<Achievement?> unlockAchievement(String achievementId) async {
    final achievement = state.achievements.firstWhere(
      (a) => a.id == achievementId,
      orElse: () => state.achievements.first,
    );

    if (achievement.id != achievementId || achievement.isUnlocked) {
      return null;
    }

    try {
      // 업적 언락 처리
      final now = DateTime.now();
      final unlockedAchievement = Achievement(
        id: achievement.id,
        title: achievement.title,
        description: achievement.description,
        icon: achievement.icon,
        type: achievement.type,
        requiredValue: achievement.requiredValue,
        currentValue: achievement.requiredValue,
        isUnlocked: true,
        unlockedAt: now,
        rarity: achievement.rarity,
        xpReward: achievement.xpReward,
      );

      // 상태 업데이트
      final updatedAchievements = state.achievements.map((a) {
        return a.id == achievementId ? unlockedAchievement : a;
      }).toList();

      state = state.copyWith(
        achievements: updatedAchievements,
        unlockedIds: [...state.unlockedIds, achievementId],
        recentlyUnlocked: unlockedAchievement,
      );

      await _saveState();

      // XP 보상 지급
      _ref.read(userProvider.notifier).addXP(achievement.xpReward);

      Logger.info(
        'Achievement unlocked: ${achievement.title} (+${achievement.xpReward} XP)',
      );

      return unlockedAchievement;
    } catch (e) {
      Logger.error('Failed to unlock achievement', error: e);
      return null;
    }
  }

  /// 최근 언락된 업적 클리어
  void clearRecentlyUnlocked() {
    state = state.copyWith(clearRecent: true);
  }

  /// 진행률 계산
  double getProgress(String achievementId) {
    final achievement = state.achievements.firstWhere(
      (a) => a.id == achievementId,
      orElse: () => state.achievements.first,
    );

    if (achievement.id != achievementId) return 0.0;

    return (achievement.currentValue / achievement.requiredValue).clamp(0.0, 1.0);
  }

  /// 언락된 업적 수
  int get unlockedCount => state.unlockedIds.length;

  /// 전체 업적 수
  int get totalCount => state.achievements.length;

  /// 완료율
  double get completionRate => totalCount > 0 ? unlockedCount / totalCount : 0.0;
}

/// Provider 정의
final achievementProvider =
    StateNotifierProvider<AchievementProvider, AchievementState>((ref) {
  return AchievementProvider(ref);
});
