/// 일일 보상 시스템
/// 매일 로그인 시 보상 제공
class DailyReward {
  final int day; // 연속 로그인 일수 (1~7일 반복)
  final RewardType type;
  final int amount;
  final String displayName;
  final String emoji;

  const DailyReward({
    required this.day,
    required this.type,
    required this.amount,
    required this.displayName,
    required this.emoji,
  });

  /// 7일 주기 보상
  static List<DailyReward> weeklyRewards = [
    const DailyReward(
      day: 1,
      type: RewardType.xp,
      amount: 10,
      displayName: '10 XP',
      emoji: '🔶',
    ),
    const DailyReward(
      day: 2,
      type: RewardType.xp,
      amount: 15,
      displayName: '15 XP',
      emoji: '🔶',
    ),
    const DailyReward(
      day: 3,
      type: RewardType.hearts,
      amount: 1,
      displayName: '하트 +1',
      emoji: '❤️',
    ),
    const DailyReward(
      day: 4,
      type: RewardType.xp,
      amount: 20,
      displayName: '20 XP',
      emoji: '🔶',
    ),
    const DailyReward(
      day: 5,
      type: RewardType.xp,
      amount: 25,
      displayName: '25 XP',
      emoji: '🔶',
    ),
    const DailyReward(
      day: 6,
      type: RewardType.hearts,
      amount: 2,
      displayName: '하트 +2',
      emoji: '❤️',
    ),
    const DailyReward(
      day: 7,
      type: RewardType.xp,
      amount: 50,
      displayName: '50 XP (보너스!)',
      emoji: '🎁',
    ),
  ];

  /// 연속 로그인 일수로부터 오늘의 보상 가져오기
  static DailyReward getTodayReward(int consecutiveDays) {
    // 1~7일 주기로 반복
    final dayIndex = ((consecutiveDays - 1) % 7);
    return weeklyRewards[dayIndex];
  }

  /// 보상 받기
  Future<void> claim() async {
    // TODO: 실제 구현에서는 서버 API 호출
    // 여기서는 로컬 처리
  }

  factory DailyReward.fromJson(Map<String, dynamic> json) {
    return DailyReward(
      day: json['day'] as int,
      type: RewardType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => RewardType.xp,
      ),
      amount: json['amount'] as int,
      displayName: json['displayName'] as String,
      emoji: json['emoji'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'type': type.name,
      'amount': amount,
      'displayName': displayName,
      'emoji': emoji,
    };
  }
}

/// 보상 타입
enum RewardType {
  xp,
  hearts,
  gems, // 미래 확장용
  unlock, // 특별 레슨 잠금 해제 등
}

/// 연속 학습 보너스
class StreakBonus {
  final int streak; // 연속 학습 일수
  final double multiplier; // XP 배율
  final String title;
  final String emoji;

  const StreakBonus({
    required this.streak,
    required this.multiplier,
    required this.title,
    required this.emoji,
  });

  /// 스트릭별 보너스 정의
  static List<StreakBonus> bonuses = [
    const StreakBonus(
      streak: 3,
      multiplier: 1.1,
      title: '3일 연속 🔥',
      emoji: '🔥',
    ),
    const StreakBonus(
      streak: 7,
      multiplier: 1.2,
      title: '7일 연속 ⭐',
      emoji: '⭐',
    ),
    const StreakBonus(
      streak: 14,
      multiplier: 1.3,
      title: '2주 연속 🚀',
      emoji: '🚀',
    ),
    const StreakBonus(
      streak: 30,
      multiplier: 1.5,
      title: '30일 연속 👑',
      emoji: '👑',
    ),
    const StreakBonus(
      streak: 100,
      multiplier: 2.0,
      title: '100일 연속 💎',
      emoji: '💎',
    ),
  ];

  /// 현재 스트릭으로부터 적용 가능한 최고 보너스
  static StreakBonus? getActiveBonus(int currentStreak) {
    StreakBonus? activeBonus;

    for (final bonus in bonuses) {
      if (currentStreak >= bonus.streak) {
        activeBonus = bonus;
      } else {
        break;
      }
    }

    return activeBonus;
  }

  /// XP에 보너스 적용
  static int applyBonus(int baseXP, int currentStreak) {
    final bonus = getActiveBonus(currentStreak);
    if (bonus == null) return baseXP;

    return (baseXP * bonus.multiplier).round();
  }

  /// 다음 보너스까지 남은 일수
  static int? daysToNextBonus(int currentStreak) {
    for (final bonus in bonuses) {
      if (currentStreak < bonus.streak) {
        return bonus.streak - currentStreak;
      }
    }
    return null; // 이미 최고 보너스 달성
  }
}

/// 완벽한 레슨 보너스
class PerfectLessonBonus {
  final int baseBonus; // 기본 보너스 XP
  final int comboBonus; // 콤보 보너스 XP (연속 정답 수에 비례)

  const PerfectLessonBonus({
    this.baseBonus = 20,
    this.comboBonus = 5,
  });

  /// 완벽한 레슨 XP 계산
  /// correctAnswers: 정답 수
  /// totalProblems: 전체 문제 수
  int calculate(int correctAnswers, int totalProblems) {
    // 완벽하게 풀었을 경우에만 보너스
    if (correctAnswers != totalProblems) return 0;

    // 기본 보너스 + (콤보 보너스 * 문제 수)
    return baseBonus + (comboBonus * totalProblems);
  }
}
