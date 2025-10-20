/// 업적 정보 모델
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final AchievementType type;
  final int requiredValue; // 달성에 필요한 값
  final int currentValue; // 현재 진행 값
  final bool isUnlocked; // 잠금 해제 여부
  final DateTime? unlockedAt; // 달성 날짜
  final int xpReward; // 달성 시 획득 XP
  final AchievementRarity rarity; // 희귀도

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    required this.requiredValue,
    required this.currentValue,
    required this.isUnlocked,
    this.unlockedAt,
    required this.xpReward,
    required this.rarity,
  });

  /// JSON으로부터 Achievement 객체 생성
  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      type: AchievementType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      requiredValue: json['requiredValue'] as int,
      currentValue: json['currentValue'] as int,
      isUnlocked: json['isUnlocked'] as bool,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
      xpReward: json['xpReward'] as int,
      rarity: AchievementRarity.values.firstWhere(
        (e) => e.toString().split('.').last == json['rarity'],
      ),
    );
  }

  /// Achievement 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'type': type.toString().split('.').last,
      'requiredValue': requiredValue,
      'currentValue': currentValue,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'xpReward': xpReward,
      'rarity': rarity.toString().split('.').last,
    };
  }

  /// Achievement 객체 복사 (일부 값 변경)
  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    AchievementType? type,
    int? requiredValue,
    int? currentValue,
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? xpReward,
    AchievementRarity? rarity,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      requiredValue: requiredValue ?? this.requiredValue,
      currentValue: currentValue ?? this.currentValue,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      xpReward: xpReward ?? this.xpReward,
      rarity: rarity ?? this.rarity,
    );
  }

  /// 진행률 계산 (0.0 ~ 1.0)
  double get progress {
    if (requiredValue == 0) return isUnlocked ? 1.0 : 0.0;
    return (currentValue / requiredValue).clamp(0.0, 1.0);
  }

  /// 달성 가능 여부
  bool get canUnlock => currentValue >= requiredValue && !isUnlocked;

  /// 진행 상태 텍스트
  String get progressText {
    if (isUnlocked) return '달성 완료';
    if (requiredValue == 1) {
      return canUnlock ? '달성 가능' : '미달성';
    }
    return '$currentValue / $requiredValue';
  }

  @override
  String toString() {
    return 'Achievement{id: $id, title: $title, isUnlocked: $isUnlocked}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Achievement && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 업적 타입
enum AchievementType {
  streak, // 연속 학습
  xp, // XP 누적
  problems, // 문제 해결
  lessons, // 레슨 완료
  perfect, // 완벽한 성취
  time, // 시간 관련
  special, // 특별 업적
}

/// 업적 희귀도
enum AchievementRarity {
  common, // 일반 (모든 유저가 쉽게 달성)
  uncommon, // 일반적이지 않은 (적극적인 유저가 달성)
  rare, // 희귀 (열심히 하는 유저만 달성)
  epic, // 영웅적 (매우 열심히 하는 유저만 달성)
  legendary, // 전설적 (극소수만 달성)
}