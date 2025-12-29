import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/gamification/achievement.dart';
import '../../models/user/user.dart';
import '../user/user_provider.dart';
import '../auth/auth_provider.dart';
import '../base/base_notifier.dart';

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

  Map<String, dynamic> toJson() {
    final progressMap = <String, int>{};
    final unlockedDates = <String, String>{};

    for (final achievement in achievements) {
      progressMap[achievement.id] = achievement.currentValue;
      if (achievement.isUnlocked && achievement.unlockedAt != null) {
        unlockedDates[achievement.id] = achievement.unlockedAt!.toIso8601String();
      }
    }

    return {
      'unlockedIds': unlockedIds,
      'progressMap': progressMap,
      'unlockedDates': unlockedDates,
    };
  }

  factory AchievementState.fromJson(
    Map<String, dynamic> json,
    List<Achievement> baseAchievements,
  ) {
    final unlockedIds = List<String>.from(json['unlockedIds'] ?? []);
    final progressMap = Map<String, int>.from(json['progressMap'] ?? {});
    final unlockedDatesData = json['unlockedDates'];

    final unlockedDates = <String, DateTime>{};
    if (unlockedDatesData != null) {
      final datesMap = Map<String, String>.from(unlockedDatesData);
      for (final entry in datesMap.entries) {
        try {
          unlockedDates[entry.key] = DateTime.parse(entry.value);
        } catch (e) {
          // Skip invalid dates
        }
      }
    }

    final updatedAchievements = baseAchievements.map((achievement) {
      return achievement.copyWith(
        currentValue: progressMap[achievement.id] ?? 0,
        isUnlocked: unlockedIds.contains(achievement.id),
        unlockedAt: unlockedDates[achievement.id],
      );
    }).toList();

    return AchievementState(
      achievements: updatedAchievements,
      unlockedIds: unlockedIds,
    );
  }

  int get unlockedCount => achievements.where((a) => a.isUnlocked).length;
  int get totalCount => achievements.length;
  double get completionRate => totalCount > 0 ? unlockedCount / totalCount : 0.0;

  Achievement firstWhere(bool Function(Achievement) test, {Achievement Function()? orElse}) {
    return achievements.firstWhere(test, orElse: orElse);
  }

  Achievement get first => achievements.first;
}

/// 업적 Provider (BaseNotifier 최적화 버전)
///
/// **개선사항:**
/// - BaseNotifier 상속으로 중복 로깅 제거
/// - executeWithErrorHandling로 try-catch 자동화
/// - toJson/fromJson으로 직렬화 표준화
class AchievementProvider extends BaseNotifier<AchievementState> {
  final Ref _ref;

  String? get _storageKey {
    final currentAccount = _ref.read(currentAccountProvider);
    if (currentAccount == null) {
      logWarning('계정 정보 없음');
      return null;
    }
    return 'achievements_${currentAccount.id}';
  }

  AchievementProvider(this._ref)
      : super(
          const AchievementState(achievements: [], unlockedIds: []),
          'AchievementProvider',
        ) {
    _initializeAchievements();
    _loadState();
  }

  /// 업적 초기화
  void _initializeAchievements() {
    state = state.copyWith(achievements: _createAchievements());
    logInfo('업적 초기화 완료: ${state.achievements.length}개');
  }

  /// 업적 목록 생성
  List<Achievement> _createAchievements() {
    return [
      // 문제 풀이 업적
      Achievement.create('first_problem', '첫 걸음', '첫 문제를 풀어보세요', '🎯',
          AchievementType.problems, 1, AchievementRarity.common, 10),
      Achievement.create('problems_10', '탐험가', '문제 10개 해결', '🌟',
          AchievementType.problems, 10, AchievementRarity.common, 20),
      Achievement.create('problems_50', '수학 전사', '문제 50개 해결', '⚔️',
          AchievementType.problems, 50, AchievementRarity.rare, 50),
      Achievement.create('problems_100', '수학 마스터', '문제 100개 해결', '👑',
          AchievementType.problems, 100, AchievementRarity.epic, 100),
      Achievement.create('problems_500', '전설의 수학자', '문제 500개 해결', '🏆',
          AchievementType.problems, 500, AchievementRarity.legendary, 300),

      // 스트릭 업적
      Achievement.create('streak_3', '꾸준함의 시작', '3일 연속 학습', '🔥',
          AchievementType.streak, 3, AchievementRarity.common, 15),
      Achievement.create('streak_7', '일주일의 힘', '7일 연속 학습', '💪',
          AchievementType.streak, 7, AchievementRarity.rare, 40),
      Achievement.create('streak_30', '한 달의 기적', '30일 연속 학습', '🌈',
          AchievementType.streak, 30, AchievementRarity.epic, 150),
      Achievement.create('streak_100', '불굴의 의지', '100일 연속 학습', '💎',
          AchievementType.streak, 100, AchievementRarity.legendary, 500),

      // 레벨 업적
      Achievement.create('level_5', '초보 탈출', '레벨 5 달성', '📚',
          AchievementType.level, 5, AchievementRarity.common, 25),
      Achievement.create('level_10', '중급자', '레벨 10 달성', '📖',
          AchievementType.level, 10, AchievementRarity.rare, 50),
      Achievement.create('level_25', '고급 학습자', '레벨 25 달성', '🎓',
          AchievementType.level, 25, AchievementRarity.epic, 100),
      Achievement.create('level_50', '수학 천재', '레벨 50 달성', '🧠',
          AchievementType.level, 50, AchievementRarity.legendary, 250),

      // XP 업적
      Achievement.create('xp_1000', 'XP 수집가', '총 1,000 XP 획득', '⭐',
          AchievementType.xp, 1000, AchievementRarity.rare, 30),
      Achievement.create('xp_5000', 'XP 전문가', '총 5,000 XP 획득', '✨',
          AchievementType.xp, 5000, AchievementRarity.epic, 100),
      Achievement.create('xp_10000', 'XP 마스터', '총 10,000 XP 획득', '💫',
          AchievementType.xp, 10000, AchievementRarity.legendary, 300),

      // 퍼펙트 업적
      Achievement.create('perfect_5', '완벽주의자', '5번 연속 정답', '✅',
          AchievementType.perfect, 5, AchievementRarity.rare, 35),
      Achievement.create('perfect_10', '무결점', '10번 연속 정답', '💯',
          AchievementType.perfect, 10, AchievementRarity.epic, 80),

      // 시간 업적
      Achievement.create('speed_demon', '스피드 데몬', '10초 안에 문제 해결', '⚡',
          AchievementType.time, 10, AchievementRarity.rare, 40),
      Achievement.create('lightning_fast', '번개처럼 빠르게', '5초 안에 문제 해결', '🚀',
          AchievementType.time, 5, AchievementRarity.epic, 75),
    ];
  }

  /// 상태 로드
  Future<void> _loadState() async {
    await executeWithErrorHandling(
      () async {
        final key = _storageKey;
        if (key == null) {
          logInfo('계정 없음, 업적 로드 스킵');
          return;
        }

        final data = await loadFromStorage(key);
        if (data != null) {
          state = AchievementState.fromJson(data, state.achievements);
          logInfo('업적 상태 로드 완료: ${state.unlockedIds.length}개 언락');
        }
      },
      errorMessage: '업적 상태 로드 실패',
    );
  }

  /// 상태 저장
  Future<void> _saveState() async {
    await executeWithErrorHandling(
      () async {
        final key = _storageKey;
        if (key == null) {
          logWarning('계정 없음, 업적 저장 불가');
          return;
        }

        await saveToStorage(key, state.toJson());
        logInfo('업적 상태 저장 완료');
      },
      errorMessage: '업적 상태 저장 실패',
    );
  }

  /// 업적 조건 체크
  Future<void> checkAchievements(User user, {Map<String, dynamic>? stats}) async {
    final newlyUnlocked = <Achievement>[];

    for (final achievement in state.achievements) {
      if (achievement.isUnlocked) continue;

      final (shouldUnlock, progress) = _evaluateAchievement(achievement, user, stats);

      await _updateProgress(achievement.id, progress);

      if (shouldUnlock) {
        final unlocked = await unlockAchievement(achievement.id);
        if (unlocked != null) {
          newlyUnlocked.add(unlocked);
        }
      }
    }

    if (newlyUnlocked.isNotEmpty) {
      logInfo('${newlyUnlocked.length}개 업적 언락됨');
    }
  }

  /// 업적 평가
  (bool shouldUnlock, int progress) _evaluateAchievement(
    Achievement achievement,
    User user,
    Map<String, dynamic>? stats,
  ) {
    int progress = 0;
    bool shouldUnlock = false;

    switch (achievement.type) {
      case AchievementType.problems:
        progress = stats?['problemsSolved'] ?? 0;
      case AchievementType.streak:
        progress = user.streakDays;
      case AchievementType.level:
        progress = user.level;
      case AchievementType.xp:
        progress = user.xp;
      case AchievementType.perfect:
        progress = stats?['perfectStreak'] ?? 0;
      case AchievementType.time:
        final bestTime = stats?['bestTime'] ?? double.infinity;
        progress = (achievement.requiredValue - bestTime).clamp(0, achievement.requiredValue).toInt();
        shouldUnlock = bestTime <= achievement.requiredValue;
        return (shouldUnlock, progress);
      default:
        return (false, 0);
    }

    shouldUnlock = progress >= achievement.requiredValue;
    return (shouldUnlock, progress);
  }

  /// 진행률 업데이트
  Future<void> _updateProgress(String achievementId, int progress) async {
    final updatedAchievements = state.achievements.map((achievement) {
      if (achievement.id == achievementId) {
        return achievement.copyWith(currentValue: progress);
      }
      return achievement;
    }).toList();

    state = state.copyWith(achievements: updatedAchievements);
  }

  /// 업적 언락
  Future<Achievement?> unlockAchievement(String achievementId) async {
    return await executeWithErrorHandling<Achievement?>(
      () async {
        final achievement = state.achievements.firstWhere(
          (a) => a.id == achievementId,
          orElse: () => state.achievements.first,
        );

        if (achievement.id != achievementId || achievement.isUnlocked) {
          return null;
        }

        final unlockedAchievement = achievement.copyWith(
          currentValue: achievement.requiredValue,
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        );

        final updatedAchievements = state.achievements.map((a) {
          return a.id == achievementId ? unlockedAchievement : a;
        }).toList();

        state = state.copyWith(
          achievements: updatedAchievements,
          unlockedIds: [...state.unlockedIds, achievementId],
          recentlyUnlocked: unlockedAchievement,
        );

        await _saveState();

        _ref.read(userProvider.notifier).addXP(achievement.xpReward);

        logInfo('업적 언락: ${achievement.title} (+${achievement.xpReward} XP)');

        return unlockedAchievement;
      },
      errorMessage: '업적 언락 실패',
      fallback: () => null,
    );
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

  int get unlockedCount => state.unlockedIds.length;
  int get totalCount => state.achievements.length;
  double get completionRate => totalCount > 0 ? unlockedCount / totalCount : 0.0;
}

/// Achievement 확장 메서드
extension AchievementExtension on Achievement {
  static Achievement create(
    String id,
    String title,
    String description,
    String icon,
    AchievementType type,
    int requiredValue,
    AchievementRarity rarity,
    int xpReward,
  ) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      icon: icon,
      type: type,
      requiredValue: requiredValue,
      rarity: rarity,
      xpReward: xpReward,
      currentValue: 0,
      isUnlocked: false,
    );
  }

  Achievement copyWith({
    int? currentValue,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      icon: icon,
      type: type,
      requiredValue: requiredValue,
      currentValue: currentValue ?? this.currentValue,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      rarity: rarity,
      xpReward: xpReward,
    );
  }
}

/// Provider 정의
final achievementProvider =
    StateNotifierProvider<AchievementProvider, AchievementState>((ref) {
  return AchievementProvider(ref);
});
