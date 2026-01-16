import 'package:cloud_firestore/cloud_firestore.dart';
import '../base/base_model.dart';

/// 앱 설정 모델
class AppSettings implements BaseModel {
  @override
  final String id;

  /// 알림 설정
  final bool notificationsEnabled;

  /// 사운드 설정
  final bool soundEnabled;

  /// 진동 설정
  final bool vibrationEnabled;

  /// 언어 설정 ('ko', 'en', 'ja' 등)
  final String language;

  /// 일일 학습 목표 (XP)
  final int dailyGoalXP;

  /// 학습 리마인더 시간 (HH:mm 형식)
  final String? reminderTime;

  /// 리마인더 활성화
  final bool reminderEnabled;

  /// 다크모드 설정
  final bool darkModeEnabled;

  const AppSettings({
    required this.id,
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.language = 'ko',
    this.dailyGoalXP = 20,
    this.reminderTime,
    this.reminderEnabled = false,
    this.darkModeEnabled = false,
  });

  AppSettings copyWith({
    String? id,
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? language,
    int? dailyGoalXP,
    String? reminderTime,
    bool? reminderEnabled,
    bool? darkModeEnabled,
  }) {
    return AppSettings(
      id: id ?? this.id,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      language: language ?? this.language,
      dailyGoalXP: dailyGoalXP ?? this.dailyGoalXP,
      reminderTime: reminderTime ?? this.reminderTime,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'notificationsEnabled': notificationsEnabled,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'language': language,
      'dailyGoalXP': dailyGoalXP,
      'reminderTime': reminderTime,
      'reminderEnabled': reminderEnabled,
      'darkModeEnabled': darkModeEnabled,
    };
  }

  /// Firestore 형식으로 변환
  @override
  Map<String, dynamic> toFirestore() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'language': language,
      'dailyGoalXP': dailyGoalXP,
      'reminderTime': reminderTime,
      'reminderEnabled': reminderEnabled,
      'darkModeEnabled': darkModeEnabled,
    };
  }

  /// Firestore 문서에서 생성
  factory AppSettings.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return AppSettings(
      id: doc.id,
      notificationsEnabled: data['notificationsEnabled'] as bool? ?? true,
      soundEnabled: data['soundEnabled'] as bool? ?? true,
      vibrationEnabled: data['vibrationEnabled'] as bool? ?? true,
      language: data['language'] as String? ?? 'ko',
      dailyGoalXP: data['dailyGoalXP'] as int? ?? 20,
      reminderTime: data['reminderTime'] as String?,
      reminderEnabled: data['reminderEnabled'] as bool? ?? false,
      darkModeEnabled: data['darkModeEnabled'] as bool? ?? false,
    );
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      id: json['id'] as String? ?? 'default',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      language: json['language'] as String? ?? 'ko',
      dailyGoalXP: json['dailyGoalXP'] as int? ?? 20,
      reminderTime: json['reminderTime'] as String?,
      reminderEnabled: json['reminderEnabled'] as bool? ?? false,
      darkModeEnabled: json['darkModeEnabled'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AppSettings &&
        other.notificationsEnabled == notificationsEnabled &&
        other.soundEnabled == soundEnabled &&
        other.vibrationEnabled == vibrationEnabled &&
        other.language == language &&
        other.dailyGoalXP == dailyGoalXP &&
        other.reminderTime == reminderTime &&
        other.reminderEnabled == reminderEnabled &&
        other.darkModeEnabled == darkModeEnabled;
  }

  @override
  int get hashCode {
    return Object.hash(
      notificationsEnabled,
      soundEnabled,
      vibrationEnabled,
      language,
      dailyGoalXP,
      reminderTime,
      reminderEnabled,
      darkModeEnabled,
    );
  }

  @override
  String toString() {
    return 'AppSettings(notifications: $notificationsEnabled, sound: $soundEnabled, vibration: $vibrationEnabled, language: $language, dailyGoal: $dailyGoalXP, reminder: $reminderEnabled, darkMode: $darkModeEnabled)';
  }
}
