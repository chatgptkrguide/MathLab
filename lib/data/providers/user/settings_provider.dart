import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../base/base_notifier.dart';

/// 앱 설정 상태 관리 (BaseNotifier 최적화 버전)
///
/// **개선사항:**
/// - BaseNotifier 상속으로 중복 로깅 제거
/// - updateAndSave로 상태 업데이트 + 저장 단순화
/// - 자동 에러 처리로 try-catch 제거
class SettingsNotifier extends BaseNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings(), 'SettingsProvider') {
    _loadSettings();
  }

  static const String _settingsKey = 'app_settings';

  /// 앱 시작 시 설정 로드
  Future<void> _loadSettings() async {
    final data = await loadFromStorage(_settingsKey);
    if (data != null) {
      state = AppSettings.fromJson(data);
      logInfo('설정 로드 성공: ${state.toString()}');
    } else {
      logInfo('기본 설정 사용');
    }
  }

  /// 알림 설정 변경
  Future<void> setNotificationsEnabled(bool enabled) async {
    await updateAndSave(
      state.copyWith(notificationsEnabled: enabled),
      saveKey: _settingsKey,
      toJson: (s) => s.toJson(),
    );
    logInfo('알림 설정 변경: $enabled');
  }

  /// 사운드 설정 변경
  Future<void> setSoundEnabled(bool enabled) async {
    await updateAndSave(
      state.copyWith(soundEnabled: enabled),
      saveKey: _settingsKey,
      toJson: (s) => s.toJson(),
    );
    logInfo('사운드 설정 변경: $enabled');
  }

  /// 진동 설정 변경
  Future<void> setVibrationEnabled(bool enabled) async {
    await updateAndSave(
      state.copyWith(vibrationEnabled: enabled),
      saveKey: _settingsKey,
      toJson: (s) => s.toJson(),
    );
    logInfo('진동 설정 변경: $enabled');
  }

  /// 언어 설정 변경
  Future<void> setLanguage(String language) async {
    await updateAndSave(
      state.copyWith(language: language),
      saveKey: _settingsKey,
      toJson: (s) => s.toJson(),
    );
    logInfo('언어 설정 변경: $language');
  }

  /// 일일 목표 XP 변경
  Future<void> setDailyGoalXP(int xp) async {
    await updateAndSave(
      state.copyWith(dailyGoalXP: xp),
      saveKey: _settingsKey,
      toJson: (s) => s.toJson(),
    );
    logInfo('일일 목표 변경: $xp XP');
  }

  /// 리마인더 설정 변경
  Future<void> setReminderEnabled(bool enabled) async {
    await updateAndSave(
      state.copyWith(reminderEnabled: enabled),
      saveKey: _settingsKey,
      toJson: (s) => s.toJson(),
    );
    logInfo('리마인더 설정 변경: $enabled');
  }

  /// 리마인더 시간 설정
  Future<void> setReminderTime(String time) async {
    await updateAndSave(
      state.copyWith(reminderTime: time),
      saveKey: _settingsKey,
      toJson: (s) => s.toJson(),
    );
    logInfo('리마인더 시간 설정: $time');
  }

  /// 다크모드 설정 변경
  Future<void> setDarkModeEnabled(bool enabled) async {
    await updateAndSave(
      state.copyWith(darkModeEnabled: enabled),
      saveKey: _settingsKey,
      toJson: (s) => s.toJson(),
    );
    logInfo('다크모드 설정 변경: $enabled');
  }

  /// 설정 초기화
  Future<void> resetSettings() async {
    logWarning('설정 초기화 시작');

    await updateAndSave(
      const AppSettings(),
      saveKey: _settingsKey,
      toJson: (s) => s.toJson(),
    );

    logInfo('설정 초기화 완료');
  }
}

/// 설정 프로바이더
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});

/// 개별 설정 감시 프로바이더들
final notificationsEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.notificationsEnabled;
});

final soundEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.soundEnabled;
});

final vibrationEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.vibrationEnabled;
});

final languageProvider = Provider<String>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.language;
});

final dailyGoalXPProvider = Provider<int>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.dailyGoalXP;
});

final reminderEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.reminderEnabled;
});

final darkModeEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.darkModeEnabled;
});
