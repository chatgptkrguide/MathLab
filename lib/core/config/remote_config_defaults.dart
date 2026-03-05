// Default values for Firebase Remote Config parameters.
// These values are used when Remote Config has not been fetched yet
// or when the fetch fails.

const remoteConfigDefaults = <String, dynamic>{
  'hearts_enabled': true,
  'srs_enabled': true,
  'league_enabled': true,
  'daily_challenge_enabled': true,
  'premium_enabled': false,
  'max_hearts': 5,
  'heart_regen_minutes': 30,
  'daily_goal_xp': 50,
  'maintenance_message': '',
  'min_app_version': '1.0.0',
  'onboarding_v2_enabled': false,
};
