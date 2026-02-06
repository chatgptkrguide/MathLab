// 🎁 Daily Reward Model
//
// 일일 보상 시스템 데이터 모델.
// 7일 주기로 반복되는 보상 사이클을 정의합니다.

/// 보상 유형 열거형
enum RewardType {
  gems,
  xp,
  hearts,
}

/// 일일 보상 모델
class DailyRewardModel {
  final int day; // 1~7
  final RewardType rewardType;
  final int amount;
  final bool isClaimed;

  const DailyRewardModel({
    required this.day,
    required this.rewardType,
    required this.amount,
    this.isClaimed = false,
  });

  /// 보상 타입에 맞는 이모지 반환
  String get emoji {
    switch (rewardType) {
      case RewardType.gems:
        return '💎';
      case RewardType.xp:
        return '⭐';
      case RewardType.hearts:
        return '❤️';
    }
  }

  /// 한국어 표시용 라벨 반환
  String get label {
    switch (rewardType) {
      case RewardType.gems:
        return '$amount 젬';
      case RewardType.xp:
        return '$amount XP';
      case RewardType.hearts:
        return '$amount 하트';
    }
  }

  /// copyWith 메서드
  DailyRewardModel copyWith({
    int? day,
    RewardType? rewardType,
    int? amount,
    bool? isClaimed,
  }) {
    return DailyRewardModel(
      day: day ?? this.day,
      rewardType: rewardType ?? this.rewardType,
      amount: amount ?? this.amount,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }

  /// 7일 주기 보상 사이클 반환
  static List<DailyRewardModel> getWeeklyRewards() {
    return const [
      DailyRewardModel(day: 1, rewardType: RewardType.gems, amount: 5),
      DailyRewardModel(day: 2, rewardType: RewardType.xp, amount: 20),
      DailyRewardModel(day: 3, rewardType: RewardType.gems, amount: 10),
      DailyRewardModel(day: 4, rewardType: RewardType.hearts, amount: 1),
      DailyRewardModel(day: 5, rewardType: RewardType.xp, amount: 30),
      DailyRewardModel(day: 6, rewardType: RewardType.gems, amount: 15),
      DailyRewardModel(day: 7, rewardType: RewardType.xp, amount: 50),
    ];
  }
}
