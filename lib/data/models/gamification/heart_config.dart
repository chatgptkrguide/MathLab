/// 하트 시스템 설정 및 상태 관리
class HeartConfig {
  /// 최대 하트 개수
  final int maxHearts;

  /// 현재 하트 개수
  final int currentHearts;

  /// 하트 1개 복구 시간 (분)
  final int heartRecoveryMinutes;

  /// 마지막으로 하트를 잃은 시간
  final DateTime? lastHeartLostAt;

  /// 다음 하트 복구까지 남은 시간 (초)
  final int? secondsUntilNextHeart;

  const HeartConfig({
    this.maxHearts = 5,
    this.currentHearts = 5,
    this.heartRecoveryMinutes = 30,
    this.lastHeartLostAt,
    this.secondsUntilNextHeart,
  });

  /// 하트가 모두 있는지 확인
  bool get isFull => currentHearts >= maxHearts;

  /// 하트가 하나도 없는지 확인
  bool get isEmpty => currentHearts <= 0;

  /// 하트가 있는지 확인
  bool get hasHearts => currentHearts > 0;

  /// 하트 복구 중인지 확인
  bool get isRecovering => !isFull && lastHeartLostAt != null;

  /// 다음 하트 복구 시간 계산
  DateTime? get nextHeartRecoveryTime {
    if (lastHeartLostAt == null || isFull) return null;

    final heartsMissing = maxHearts - currentHearts;
    final minutesToRecover = heartRecoveryMinutes * (heartsMissing - 1);

    return lastHeartLostAt!.add(Duration(minutes: minutesToRecover));
  }

  /// 복구 진행률 (0.0 ~ 1.0)
  double get recoveryProgress {
    if (secondsUntilNextHeart == null || secondsUntilNextHeart! <= 0) {
      return 1.0;
    }

    final totalSeconds = heartRecoveryMinutes * 60;
    final elapsed = totalSeconds - secondsUntilNextHeart!;

    return elapsed / totalSeconds;
  }

  HeartConfig copyWith({
    int? maxHearts,
    int? currentHearts,
    int? heartRecoveryMinutes,
    DateTime? lastHeartLostAt,
    int? secondsUntilNextHeart,
    bool clearLastHeartLostAt = false,
  }) {
    return HeartConfig(
      maxHearts: maxHearts ?? this.maxHearts,
      currentHearts: currentHearts ?? this.currentHearts,
      heartRecoveryMinutes: heartRecoveryMinutes ?? this.heartRecoveryMinutes,
      lastHeartLostAt: clearLastHeartLostAt ? null : (lastHeartLostAt ?? this.lastHeartLostAt),
      secondsUntilNextHeart: secondsUntilNextHeart ?? this.secondsUntilNextHeart,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maxHearts': maxHearts,
      'currentHearts': currentHearts,
      'heartRecoveryMinutes': heartRecoveryMinutes,
      'lastHeartLostAt': lastHeartLostAt?.toIso8601String(),
      'secondsUntilNextHeart': secondsUntilNextHeart,
    };
  }

  factory HeartConfig.fromJson(Map<String, dynamic> json) {
    return HeartConfig(
      maxHearts: json['maxHearts'] as int? ?? 5,
      currentHearts: json['currentHearts'] as int? ?? 5,
      heartRecoveryMinutes: json['heartRecoveryMinutes'] as int? ?? 30,
      lastHeartLostAt: json['lastHeartLostAt'] != null
          ? DateTime.parse(json['lastHeartLostAt'] as String)
          : null,
      secondsUntilNextHeart: json['secondsUntilNextHeart'] as int?,
    );
  }
}
