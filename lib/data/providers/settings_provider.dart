import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/services/local_storage_service.dart';
import '../../shared/utils/logger.dart';

/// 설정 상태
class SettingsState {
  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool hapticEnabled;
  final bool darkModeEnabled;
  final String language;

  const SettingsState({
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.hapticEnabled = true,
    this.darkModeEnabled = false,
    this.language = 'ko',
  });

  SettingsState copyWith({
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? hapticEnabled,
    bool? darkModeEnabled,
    String? language,
  }) {
    return SettingsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      language: language ?? this.language,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'soundEnabled': soundEnabled,
      'hapticEnabled': hapticEnabled,
      'darkModeEnabled': darkModeEnabled,
      'language': language,
    };
  }

  factory SettingsState.fromJson(Map<String, dynamic> json) {
    return SettingsState(
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      soundEnabled: json['soundEnabled'] ?? true,
      hapticEnabled: json['hapticEnabled'] ?? true,
      darkModeEnabled: json['darkModeEnabled'] ?? false,
      language: json['language'] ?? 'ko',
    );
  }
}

/// 설정 Provider
class SettingsProvider extends StateNotifier<SettingsState> {
  final LocalStorageService _storage = LocalStorageService();
  static const String _storageKey = 'settings';

  SettingsProvider() : super(const SettingsState()) {
    _loadSettings();
  }

  /// 설정 로드
  Future<void> _loadSettings() async {
    try {
      final data = await _storage.loadObject(_storageKey);
      if (data != null) {
        state = SettingsState.fromJson(data);
        Logger.info('Settings loaded successfully');
      }
    } catch (e) {
      Logger.error('Failed to load settings', error: e);
    }
  }

  /// 설정 저장
  Future<void> _saveSettings() async {
    try {
      await _storage.saveObject(_storageKey, state.toJson());
      Logger.info('Settings saved successfully');
    } catch (e) {
      Logger.error('Failed to save settings', error: e);
    }
  }

  /// 알림 토글
  Future<void> toggleNotifications() async {
    state = state.copyWith(notificationsEnabled: !state.notificationsEnabled);
    await _saveSettings();
  }

  /// 사운드 토글
  Future<void> toggleSound() async {
    state = state.copyWith(soundEnabled: !state.soundEnabled);
    await _saveSettings();
  }

  /// 햅틱 피드백 토글
  Future<void> toggleHaptic() async {
    state = state.copyWith(hapticEnabled: !state.hapticEnabled);
    await _saveSettings();
  }

  /// 다크모드 토글
  Future<void> toggleDarkMode() async {
    state = state.copyWith(darkModeEnabled: !state.darkModeEnabled);
    await _saveSettings();
  }

  /// 언어 변경
  Future<void> setLanguage(String language) async {
    state = state.copyWith(language: language);
    await _saveSettings();
  }
}

/// Provider 정의
final settingsProvider = StateNotifierProvider<SettingsProvider, SettingsState>((ref) {
  return SettingsProvider();
});
