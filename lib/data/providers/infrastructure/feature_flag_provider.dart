// Feature Flag Provider
//
// Riverpod StateNotifier that exposes feature flags from Firebase Remote Config.
// Provides typed access to all feature flags used throughout the app.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_logger.dart';
import '../../services/remote_config_service.dart';

class FeatureFlags {
  final bool heartsEnabled;
  final bool srsEnabled;
  final bool leagueEnabled;
  final bool dailyChallengeEnabled;
  final bool premiumEnabled;
  final int maxHearts;
  final int heartRegenMinutes;
  final int dailyGoalXP;
  final String maintenanceMessage;
  final String minAppVersion;
  final bool onboardingV2Enabled;

  const FeatureFlags({
    this.heartsEnabled = true,
    this.srsEnabled = true,
    this.leagueEnabled = true,
    this.dailyChallengeEnabled = true,
    this.premiumEnabled = false,
    this.maxHearts = 5,
    this.heartRegenMinutes = 30,
    this.dailyGoalXP = 50,
    this.maintenanceMessage = '',
    this.minAppVersion = '1.0.0',
    this.onboardingV2Enabled = false,
  });

  /// Whether the app is currently in maintenance mode.
  bool get isMaintenanceMode => maintenanceMessage.isNotEmpty;

  /// Create FeatureFlags from current Remote Config values.
  factory FeatureFlags.fromRemoteConfig() {
    return FeatureFlags(
      heartsEnabled: RemoteConfigService.getBool('hearts_enabled'),
      srsEnabled: RemoteConfigService.getBool('srs_enabled'),
      leagueEnabled: RemoteConfigService.getBool('league_enabled'),
      dailyChallengeEnabled:
          RemoteConfigService.getBool('daily_challenge_enabled'),
      premiumEnabled: RemoteConfigService.getBool('premium_enabled'),
      maxHearts: RemoteConfigService.getInt('max_hearts'),
      heartRegenMinutes: RemoteConfigService.getInt('heart_regen_minutes'),
      dailyGoalXP: RemoteConfigService.getInt('daily_goal_xp'),
      maintenanceMessage:
          RemoteConfigService.getString('maintenance_message'),
      minAppVersion: RemoteConfigService.getString('min_app_version'),
      onboardingV2Enabled:
          RemoteConfigService.getBool('onboarding_v2_enabled'),
    );
  }

  FeatureFlags copyWith({
    bool? heartsEnabled,
    bool? srsEnabled,
    bool? leagueEnabled,
    bool? dailyChallengeEnabled,
    bool? premiumEnabled,
    int? maxHearts,
    int? heartRegenMinutes,
    int? dailyGoalXP,
    String? maintenanceMessage,
    String? minAppVersion,
    bool? onboardingV2Enabled,
  }) {
    return FeatureFlags(
      heartsEnabled: heartsEnabled ?? this.heartsEnabled,
      srsEnabled: srsEnabled ?? this.srsEnabled,
      leagueEnabled: leagueEnabled ?? this.leagueEnabled,
      dailyChallengeEnabled:
          dailyChallengeEnabled ?? this.dailyChallengeEnabled,
      premiumEnabled: premiumEnabled ?? this.premiumEnabled,
      maxHearts: maxHearts ?? this.maxHearts,
      heartRegenMinutes: heartRegenMinutes ?? this.heartRegenMinutes,
      dailyGoalXP: dailyGoalXP ?? this.dailyGoalXP,
      maintenanceMessage: maintenanceMessage ?? this.maintenanceMessage,
      minAppVersion: minAppVersion ?? this.minAppVersion,
      onboardingV2Enabled: onboardingV2Enabled ?? this.onboardingV2Enabled,
    );
  }
}

class FeatureFlagNotifier extends StateNotifier<FeatureFlags> {
  FeatureFlagNotifier() : super(const FeatureFlags());

  /// Load feature flags from Remote Config.
  void initialize() {
    try {
      state = FeatureFlags.fromRemoteConfig();
      AppLogger.info('Feature flags loaded', tag: 'FeatureFlag');
    } catch (e) {
      AppLogger.warning(
        'Failed to load feature flags, using defaults',
        tag: 'FeatureFlag',
        error: e,
      );
    }
  }

  /// Force refresh from Remote Config.
  Future<void> refresh() async {
    try {
      await RemoteConfigService.forceFetch();
      state = FeatureFlags.fromRemoteConfig();
      AppLogger.info('Feature flags refreshed', tag: 'FeatureFlag');
    } catch (e) {
      AppLogger.error(
        'Failed to refresh feature flags',
        tag: 'FeatureFlag',
        error: e,
      );
    }
  }
}

final featureFlagProvider =
    StateNotifierProvider<FeatureFlagNotifier, FeatureFlags>((ref) {
  return FeatureFlagNotifier();
});
