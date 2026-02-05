// 🌐 API Provider
//
// Provides API client instance throughout the app

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/api/api_client.dart';

/// API Client Provider (singleton)
final apiClientProvider = Provider<ApiClient>((ref) {
  final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';

  return ApiClient(baseUrl: baseUrl);
});

/// Auth API Provider
final authAPIProvider = Provider((ref) {
  return ref.watch(apiClientProvider).auth;
});

/// User API Provider
final userAPIProvider = Provider((ref) {
  return ref.watch(apiClientProvider).user;
});

/// Lesson API Provider
final lessonAPIProvider = Provider((ref) {
  return ref.watch(apiClientProvider).lesson;
});

/// League API Provider
final leagueAPIProvider = Provider((ref) {
  return ref.watch(apiClientProvider).league;
});

/// Achievement API Provider
final achievementAPIProvider = Provider((ref) {
  return ref.watch(apiClientProvider).achievement;
});
