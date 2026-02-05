// 🚀 API Client
//
// Centralized API client with all service endpoints

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dio_client.dart';
import 'endpoints/auth_api.dart';
import 'endpoints/user_api.dart';
import 'endpoints/lesson_api.dart';
import 'endpoints/league_api.dart';
import 'endpoints/achievement_api.dart';

class ApiClient {
  late final DioClient _dioClient;
  late final AuthAPI auth;
  late final UserAPI user;
  late final LessonAPI lesson;
  late final LeagueAPI league;
  late final AchievementAPI achievement;

  ApiClient({
    required String baseUrl,
    FlutterSecureStorage? storage,
  }) {
    _dioClient = DioClient(
      baseUrl: baseUrl,
      storage: storage,
    );

    // Initialize API services
    auth = AuthAPI(client: _dioClient);
    user = UserAPI(client: _dioClient);
    lesson = LessonAPI(client: _dioClient);
    league = LeagueAPI(client: _dioClient);
    achievement = AchievementAPI(client: _dioClient);
  }

  /// Factory for production environment
  factory ApiClient.production() {
    return ApiClient(
      baseUrl: const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'https://api.mathlab.com',
      ),
    );
  }

  /// Factory for development environment
  factory ApiClient.development() {
    return ApiClient(
      baseUrl: const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://localhost:3000',
      ),
    );
  }

  /// Factory for testing environment
  factory ApiClient.testing({
    required String baseUrl,
  }) {
    return ApiClient(
      baseUrl: baseUrl,
    );
  }
}
