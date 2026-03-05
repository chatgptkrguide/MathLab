// Firebase Remote Config Service
//
// Provides centralized access to Firebase Remote Config values.
// Initializes with default values and fetches remote values on startup.

import 'package:firebase_remote_config/firebase_remote_config.dart';

import '../../core/config/env_config.dart';
import '../../core/config/remote_config_defaults.dart';
import '../../core/utils/app_logger.dart';

class RemoteConfigService {
  RemoteConfigService._();

  static final _remoteConfig = FirebaseRemoteConfig.instance;

  /// Initialize Remote Config with defaults and fetch latest values.
  static Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: EnvConfig.isProduction
            ? const Duration(hours: 1)
            : Duration.zero,
      ));

      await _remoteConfig.setDefaults(remoteConfigDefaults);
      await _remoteConfig.fetchAndActivate();

      AppLogger.info('Remote Config initialized', tag: 'RemoteConfig');
    } catch (e) {
      AppLogger.warning(
        'Remote Config initialization failed, using defaults',
        tag: 'RemoteConfig',
        error: e,
      );
    }
  }

  /// Get a boolean value by key.
  static bool getBool(String key) => _remoteConfig.getBool(key);

  /// Get an integer value by key.
  static int getInt(String key) => _remoteConfig.getInt(key);

  /// Get a string value by key.
  static String getString(String key) => _remoteConfig.getString(key);

  /// Get a double value by key.
  static double getDouble(String key) => _remoteConfig.getDouble(key);

  /// Force fetch and activate, bypassing minimum fetch interval.
  static Future<void> forceFetch() async {
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero,
      ));
      await _remoteConfig.fetchAndActivate();

      // Restore production fetch interval after force fetch
      if (EnvConfig.isProduction) {
        await _remoteConfig.setConfigSettings(RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(hours: 1),
        ));
      }

      AppLogger.info('Remote Config force fetched', tag: 'RemoteConfig');
    } catch (e) {
      AppLogger.error(
        'Remote Config force fetch failed',
        tag: 'RemoteConfig',
        error: e,
      );
    }
  }
}
