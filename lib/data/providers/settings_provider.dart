import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/local_storage_service.dart';
import '../../shared/utils/logger.dart';

/// 앱 설정 상태 관리
class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings()) {
    _loadSettings();
  }

  final LocalStorageService _storage = LocalStorageService();
  static const String _settingsKey = 'app_settings';

  /// 앱 시작 시 설정 로드
  Future<void> _loadSettings() async {
    try {
      Logger.info('설정 로드 시작', tag: 'SettingsProvider');

      final settings = await _storage.loadObject<AppSettings>(
        key: _settingsKey,
        fromJson: AppSettings.fromJson,
      );

      if (settings != null) {
        state = settings;
        Logger.info('설정 로드 성공: ${settings.toString()}', tag: 'SettingsProvider');
      } else {
        // 기본 설정 사용
        Logger.info('기본 설정 사용', tag: 'SettingsProvider');
      }
    } catch (e, stackTrace) {
      Logger.error(
        '설정 로드 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'SettingsProvider',
      );
    }
  }

  /// 설정 저장
  Future<void> _saveSettings() async {
    try {
      await _storage.saveObject<AppSettings>(
        key: _settingsKey,
        data: state,
        toJson: (settings) => settings.toJson(),
      );
      Logger.debug('설정 저장 완료', tag: 'SettingsProvider');
    } catch (e, stackTrace) {
      Logger.error(
        '설정 저장 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'SettingsProvider',
      );
    }
  }

  /// 알림 설정 변경
  Future<void> setNotificationsEnabled(bool enabled) async {
    state = state.copyWith(notificationsEnabled: enabled);
    await _saveSettings();
    Logger.info('알림 설정 변경: $enabled', tag: 'SettingsProvider');
  }

  /// 사운드 설정 변경
  Future<void> setSoundEnabled(bool enabled) async {
    state = state.copyWith(soundEnabled: enabled);
    await _saveSettings();
    Logger.info('사운드 설정 변경: $enabled', tag: 'SettingsProvider');
  }

  /// 진동 설정 변경
  Future<void> setVibrationEnabled(bool enabled) async {
    state = state.copyWith(vibrationEnabled: enabled);
    await _saveSettings();
    Logger.info('진동 설정 변경: $enabled', tag: 'SettingsProvider');
  }

  /// 언어 설정 변경
  Future<void> setLanguage(String language) async {
    state = state.copyWith(language: language);
    await _saveSettings();
    Logger.info('언어 설정 변경: $language', tag: 'SettingsProvider');
  }

  /// 일일 목표 XP 변경
  Future<void> setDailyGoalXP(int xp) async {
    state = state.copyWith(dailyGoalXP: xp);
    await _saveSettings();
    Logger.info('일일 목표 변경: $xp XP', tag: 'SettingsProvider');
  }

  /// 리마인더 설정 변경
  Future<void> setReminderEnabled(bool enabled) async {
    state = state.copyWith(reminderEnabled: enabled);
    await _saveSettings();
    Logger.info('리마인더 설정 변경: $enabled', tag: 'SettingsProvider');
  }

  /// 리마인더 시간 설정
  Future<void> setReminderTime(String time) async {
    state = state.copyWith(reminderTime: time);
    await _saveSettings();
    Logger.info('리마인더 시간 설정: $time', tag: 'SettingsProvider');
  }

  /// 다크모드 설정 변경
  Future<void> setDarkModeEnabled(bool enabled) async {
    state = state.copyWith(darkModeEnabled: enabled);
    await _saveSettings();
    Logger.info('다크모드 설정 변경: $enabled', tag: 'SettingsProvider');
  }

  /// 설정 초기화
  Future<void> resetSettings() async {
    Logger.warning('설정 초기화 시작', tag: 'SettingsProvider');

    state = const AppSettings();
    await _saveSettings();

    Logger.info('설정 초기화 완료', tag: 'SettingsProvider');
  }
}

/// 설정 프로바이더
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
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
