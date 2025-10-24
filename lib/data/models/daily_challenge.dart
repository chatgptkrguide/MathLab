/// 일일 챌린지 모델
class DailyChallenge {
  final String id;
  final ChallengeType type;
  final String title;
  final String description;
  final int targetValue;
  final int currentValue;
  final int xpReward;
  final DateTime date;
  final bool isCompleted;

  const DailyChallenge({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.targetValue,
    required this.currentValue,
    required this.xpReward,
    required this.date,
    this.isCompleted = false,
  });

  /// 진행률 (0.0 ~ 1.0)
  double get progress {
    if (targetValue == 0) return 0.0;
    return (currentValue / targetValue).clamp(0.0, 1.0);
  }

  /// 진행률 퍼센트 (0 ~ 100)
  int get progressPercent => (progress * 100).round();

  /// 완료 여부
  bool get completed => currentValue >= targetValue;

  DailyChallenge copyWith({
    String? id,
    ChallengeType? type,
    String? title,
    String? description,
    int? targetValue,
    int? currentValue,
    int? xpReward,
    DateTime? date,
    bool? isCompleted,
  }) {
    return DailyChallenge(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      xpReward: xpReward ?? this.xpReward,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'description': description,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'xpReward': xpReward,
      'date': date.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory DailyChallenge.fromJson(Map<String, dynamic> json) {
    return DailyChallenge(
      id: json['id'],
      type: ChallengeType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ChallengeType.solveProblems,
      ),
      title: json['title'],
      description: json['description'],
      targetValue: json['targetValue'],
      currentValue: json['currentValue'] ?? 0,
      xpReward: json['xpReward'],
      date: DateTime.parse(json['date']),
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

/// 챌린지 타입
enum ChallengeType {
  solveProblems, // 문제 풀기
  earnXP, // XP 획득
  perfectStreak, // 연속 정답
  categoryFocus, // 특정 카테고리
  accuracy, // 정확도 달성
  fastSolver, // 빠른 풀이
}

extension ChallengeTypeExtension on ChallengeType {
  String get emoji {
    switch (this) {
      case ChallengeType.solveProblems:
        return '📝';
      case ChallengeType.earnXP:
        return '⭐';
      case ChallengeType.perfectStreak:
        return '🔥';
      case ChallengeType.categoryFocus:
        return '🎯';
      case ChallengeType.accuracy:
        return '🎯';
      case ChallengeType.fastSolver:
        return '⚡';
    }
  }

  String get displayName {
    switch (this) {
      case ChallengeType.solveProblems:
        return '문제 풀이';
      case ChallengeType.earnXP:
        return 'XP 획득';
      case ChallengeType.perfectStreak:
        return '연속 정답';
      case ChallengeType.categoryFocus:
        return '카테고리 집중';
      case ChallengeType.accuracy:
        return '정확도 달성';
      case ChallengeType.fastSolver:
        return '스피드 챌린지';
    }
  }
}
