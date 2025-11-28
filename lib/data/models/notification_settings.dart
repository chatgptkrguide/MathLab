/// 알림 설정 모델
/// 사용자별 알림 설정 관리

/// 알림 타입
enum NotificationType {
  dailyReminder('일일 학습 리마인더'),
  streakRisk('스트릭 위험 알림'),
  inactivity('비활동 알림'),
  achievement('성취 알림'),
  heartRecovery('하트 재생 알림'),
  leagueUpdate('리그 업데이트'),
  dailyChallenge('일일 챌린지');

  final String label;
  const NotificationType(this.label);
}

/// 알림 설정
class NotificationSettings {
  final String userId;
  final Map<NotificationType, bool> enabledTypes;
  final int dailyReminderHour; // 일일 리마인더 시간 (0-23)
  final int dailyReminderMinute; // 일일 리마인더 분 (0-59)
  final int inactivityDays; // 비활동 알림 발송 기준 일수 (기본 3일)
  final bool soundEnabled; // 소리 활성화
  final bool vibrationEnabled; // 진동 활성화

  NotificationSettings({
    required this.userId,
    Map<NotificationType, bool>? enabledTypes,
    this.dailyReminderHour = 20, // 기본값: 저녁 8시
    this.dailyReminderMinute = 0,
    this.inactivityDays = 3,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  }) : enabledTypes = enabledTypes ??
            {
              NotificationType.dailyReminder: true,
              NotificationType.streakRisk: true,
              NotificationType.inactivity: true,
              NotificationType.achievement: true,
              NotificationType.heartRecovery: true,
              NotificationType.leagueUpdate: true,
              NotificationType.dailyChallenge: true,
            };

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'enabledTypes': enabledTypes.map(
        (key, value) => MapEntry(key.name, value),
      ),
      'dailyReminderHour': dailyReminderHour,
      'dailyReminderMinute': dailyReminderMinute,
      'inactivityDays': inactivityDays,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
    };
  }

  /// JSON에서 생성
  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    final enabledTypesMap = <NotificationType, bool>{};
    final enabledTypesJson = json['enabledTypes'] as Map<String, dynamic>?;

    if (enabledTypesJson != null) {
      for (final type in NotificationType.values) {
        enabledTypesMap[type] = enabledTypesJson[type.name] as bool? ?? true;
      }
    }

    return NotificationSettings(
      userId: json['userId'] as String,
      enabledTypes: enabledTypesMap.isEmpty ? null : enabledTypesMap,
      dailyReminderHour: json['dailyReminderHour'] as int? ?? 20,
      dailyReminderMinute: json['dailyReminderMinute'] as int? ?? 0,
      inactivityDays: json['inactivityDays'] as int? ?? 3,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
    );
  }

  /// 복사 (업데이트용)
  NotificationSettings copyWith({
    String? userId,
    Map<NotificationType, bool>? enabledTypes,
    int? dailyReminderHour,
    int? dailyReminderMinute,
    int? inactivityDays,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return NotificationSettings(
      userId: userId ?? this.userId,
      enabledTypes: enabledTypes ?? this.enabledTypes,
      dailyReminderHour: dailyReminderHour ?? this.dailyReminderHour,
      dailyReminderMinute: dailyReminderMinute ?? this.dailyReminderMinute,
      inactivityDays: inactivityDays ?? this.inactivityDays,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }

  /// 특정 알림 타입 활성화 여부
  bool isEnabled(NotificationType type) {
    return enabledTypes[type] ?? true;
  }

  /// 특정 알림 타입 토글
  NotificationSettings toggleType(NotificationType type) {
    final newEnabledTypes = Map<NotificationType, bool>.from(enabledTypes);
    newEnabledTypes[type] = !(newEnabledTypes[type] ?? true);
    return copyWith(enabledTypes: newEnabledTypes);
  }
}

/// 알림 히스토리 (발송된 알림 기록)
class NotificationHistory {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime sentAt;
  final bool opened; // 사용자가 알림을 열었는지
  final DateTime? openedAt;

  NotificationHistory({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.sentAt,
    this.opened = false,
    this.openedAt,
  });

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.name,
      'title': title,
      'body': body,
      'sentAt': sentAt.toIso8601String(),
      'opened': opened,
      'openedAt': openedAt?.toIso8601String(),
    };
  }

  /// JSON에서 생성
  factory NotificationHistory.fromJson(Map<String, dynamic> json) {
    return NotificationHistory(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.dailyReminder,
      ),
      title: json['title'] as String,
      body: json['body'] as String,
      sentAt: DateTime.parse(json['sentAt'] as String),
      opened: json['opened'] as bool? ?? false,
      openedAt: json['openedAt'] != null
          ? DateTime.parse(json['openedAt'] as String)
          : null,
    );
  }

  /// 복사 (업데이트용)
  NotificationHistory copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? body,
    DateTime? sentAt,
    bool? opened,
    DateTime? openedAt,
  }) {
    return NotificationHistory(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      sentAt: sentAt ?? this.sentAt,
      opened: opened ?? this.opened,
      openedAt: openedAt ?? this.openedAt,
    );
  }
}
