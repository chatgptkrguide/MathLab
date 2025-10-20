import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/mock_data_service.dart';

/// 업적 시스템 상태 관리
class AchievementNotifier extends StateNotifier<List<Achievement>> {
  AchievementNotifier() : super([]) {
    _loadAchievements();
  }

  final MockDataService _dataService = MockDataService();

  /// 업적 데이터 로드
  Future<void> _loadAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsJson = prefs.getStringList('achievements');

    if (achievementsJson != null && achievementsJson.isNotEmpty) {
      // 저장된 업적이 있으면 로드
      final achievements = achievementsJson
          .map((json) => Achievement.fromJson(jsonDecode(json)))
          .toList();
      state = achievements;
    } else {
      // 없으면 기본 업적들 로드
      state = _dataService.getSampleAchievements();
      await _saveAchievements();
    }
  }

  /// 업적 데이터 저장
  Future<void> _saveAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsJson = state
        .map((achievement) => jsonEncode(achievement.toJson()))
        .toList();
    await prefs.setStringList('achievements', achievementsJson);
  }

  /// 업적 진행도 업데이트
  Future<List<Achievement>> updateProgress({
    required String userId,
    required int totalXP,
    required int streakDays,
    required int problemsSolved,
    required int correctAnswers,
    required bool isPerfectScore,
  }) async {
    final updatedAchievements = <Achievement>[];

    for (final achievement in state) {
      var currentValue = achievement.currentValue;

      // 업적 타입별로 현재 값 업데이트
      switch (achievement.type) {
        case AchievementType.xp:
          currentValue = totalXP;
          break;
        case AchievementType.streak:
          currentValue = streakDays;
          break;
        case AchievementType.problems:
          currentValue = problemsSolved;
          break;
        case AchievementType.perfect:
          if (isPerfectScore) {
            currentValue = achievement.currentValue + 1;
          }
          break;
        case AchievementType.lessons:
          // TODO: 완료된 레슨 수로 업데이트
          break;
        case AchievementType.time:
          // TODO: 학습 시간으로 업데이트
          break;
        case AchievementType.special:
          // 특별 업적은 별도 로직으로 처리
          break;
      }

      // 업적 달성 체크
      final shouldUnlock = currentValue >= achievement.requiredValue &&
                          !achievement.isUnlocked;

      final updatedAchievement = achievement.copyWith(
        currentValue: currentValue,
        isUnlocked: achievement.isUnlocked || shouldUnlock,
        unlockedAt: shouldUnlock ? DateTime.now() : achievement.unlockedAt,
      );

      // 새로 달성한 업적이면 리스트에 추가
      if (shouldUnlock) {
        updatedAchievements.add(updatedAchievement);
      }

      // 상태 업데이트
      final index = state.indexWhere((a) => a.id == achievement.id);
      if (index != -1) {
        state = [
          ...state.take(index),
          updatedAchievement,
          ...state.skip(index + 1),
        ];
      }
    }

    await _saveAchievements();
    return updatedAchievements; // 새로 달성한 업적들 반환
  }

  /// 특정 업적 잠금 해제
  Future<void> unlockAchievement(String achievementId) async {
    final index = state.indexWhere((a) => a.id == achievementId);
    if (index == -1) return;

    final achievement = state[index];
    if (achievement.isUnlocked) return;

    final unlockedAchievement = achievement.copyWith(
      isUnlocked: true,
      unlockedAt: DateTime.now(),
    );

    state = [
      ...state.take(index),
      unlockedAchievement,
      ...state.skip(index + 1),
    ];

    await _saveAchievements();
  }

  /// 달성한 업적들 조회
  List<Achievement> get unlockedAchievements {
    return state.where((achievement) => achievement.isUnlocked).toList();
  }

  /// 미달성 업적들 조회
  List<Achievement> get lockedAchievements {
    return state.where((achievement) => !achievement.isUnlocked).toList();
  }

  /// 달성 가능한 업적들 (조건 만족)
  List<Achievement> get achievableAchievements {
    return state.where((achievement) => achievement.canUnlock).toList();
  }

  /// 카테고리별 업적 조회
  List<Achievement> getAchievementsByType(AchievementType type) {
    return state.where((achievement) => achievement.type == type).toList();
  }

  /// 희귀도별 업적 조회
  List<Achievement> getAchievementsByRarity(AchievementRarity rarity) {
    return state.where((achievement) => achievement.rarity == rarity).toList();
  }

  /// 총 획득 XP (업적 보상)
  int get totalAchievementXP {
    return unlockedAchievements.fold(0, (total, achievement) => total + achievement.xpReward);
  }

  /// 업적 달성률
  double get completionRate {
    if (state.isEmpty) return 0.0;
    return unlockedAchievements.length / state.length;
  }

  /// 업적 초기화 (테스트용)
  Future<void> resetAchievements() async {
    state = _dataService.getSampleAchievements();
    await _saveAchievements();
  }

  /// 커스텀 업적 추가 (향후 확장용)
  Future<void> addCustomAchievement(Achievement achievement) async {
    state = [...state, achievement];
    await _saveAchievements();
  }

  /// 업적 삭제 (관리자용)
  Future<void> removeAchievement(String achievementId) async {
    state = state.where((achievement) => achievement.id != achievementId).toList();
    await _saveAchievements();
  }
}

/// 업적 진행률 트래커
class AchievementTrackerNotifier extends StateNotifier<Map<String, dynamic>> {
  AchievementTrackerNotifier() : super({});

  /// 학습 활동 추적
  void trackLearningActivity({
    required int problemsSolved,
    required int correctAnswers,
    required bool isPerfectSession,
    required int sessionXP,
    required int currentStreak,
    required int totalXP,
  }) {
    state = {
      ...state,
      'problemsSolved': problemsSolved,
      'correctAnswers': correctAnswers,
      'perfectSessions': (state['perfectSessions'] ?? 0) + (isPerfectSession ? 1 : 0),
      'sessionXP': sessionXP,
      'currentStreak': currentStreak,
      'totalXP': totalXP,
      'lastActivityAt': DateTime.now().toIso8601String(),
    };
  }

  /// 특별 이벤트 추적
  void trackSpecialEvent(String eventType, Map<String, dynamic> eventData) {
    final events = Map<String, dynamic>.from(state['specialEvents'] ?? {});
    events[eventType] = {
      ...eventData,
      'timestamp': DateTime.now().toIso8601String(),
    };

    state = {
      ...state,
      'specialEvents': events,
    };
  }

  /// 연속 정답 추적
  void trackConsecutiveCorrect(int consecutiveCount) {
    final currentMax = state['maxConsecutiveCorrect'] ?? 0;
    state = {
      ...state,
      'consecutiveCorrect': consecutiveCount,
      'maxConsecutiveCorrect': consecutiveCount > currentMax ? consecutiveCount : currentMax,
    };
  }

  /// 학습 시간 추적
  void trackStudyTime(int minutes) {
    final totalMinutes = (state['totalStudyTimeMinutes'] ?? 0) + minutes;
    state = {
      ...state,
      'totalStudyTimeMinutes': totalMinutes,
      'lastSessionMinutes': minutes,
    };
  }

  /// 데이터 초기화
  void reset() {
    state = {};
  }
}

/// 프로바이더들
final achievementProvider = StateNotifierProvider<AchievementNotifier, List<Achievement>>((ref) {
  return AchievementNotifier();
});

final achievementTrackerProvider = StateNotifierProvider<AchievementTrackerNotifier, Map<String, dynamic>>((ref) {
  return AchievementTrackerNotifier();
});

/// 편의 프로바이더들
final unlockedAchievementsProvider = Provider<List<Achievement>>((ref) {
  final achievements = ref.watch(achievementProvider);
  return achievements.where((achievement) => achievement.isUnlocked).toList();
});

final lockedAchievementsProvider = Provider<List<Achievement>>((ref) {
  final achievements = ref.watch(achievementProvider);
  return achievements.where((achievement) => !achievement.isUnlocked).toList();
});

final achievementCompletionRateProvider = Provider<double>((ref) {
  final achievements = ref.watch(achievementProvider);
  if (achievements.isEmpty) return 0.0;

  final unlockedCount = achievements.where((a) => a.isUnlocked).length;
  return unlockedCount / achievements.length;
});

final totalAchievementXPProvider = Provider<int>((ref) {
  final achievements = ref.watch(achievementProvider);
  return achievements
      .where((a) => a.isUnlocked)
      .fold(0, (total, a) => total + a.xpReward);
});