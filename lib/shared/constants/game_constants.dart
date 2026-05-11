/// 게임 관련 상수
class GameConstants {
  GameConstants._();

  // 일일 목표 XP
  static const int dailyGoalXP = 20;

  // 하트 시스템
  static const int maxHearts = 5;
  static const int heartRegenMinutes = 30;

  // 스트릭
  static const int streakFreezeGemCost = 100;

  // XP 보상
  static const int xpPerCorrectAnswer = 10;
  static const int xpPerPerfectLesson = 20;
  static const int xpStreakBonus = 5;

  // 리그 XP 임계값 — [최소XP, 다음 리그 XP]
  // bronze 0~499, silver 500~1099, gold 1100~2499, diamond 2500~4999, master 5000~9999
  static const Map<String, List<int>> leagueXpThresholds = {
    'bronze': [0, 500],
    'silver': [500, 1100],
    'gold': [1100, 2500],
    'diamond': [2500, 5000],
    'master': [5000, 10000],
  };

  /// 주어진 리그의 [최소XP, 다음 리그 진입 XP]. 미정의 리그는 bronze fallback.
  static List<int> leagueRange(String league) =>
      leagueXpThresholds[league.toLowerCase()] ??
      leagueXpThresholds['bronze']!;
}
