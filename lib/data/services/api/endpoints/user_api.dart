/// 👤 User API
///
/// Handles user profile and progress API calls

import 'package:dio/dio.dart';
import '../dio_client.dart';

class UserAPI {
  final DioClient _client;

  UserAPI({required DioClient client}) : _client = client;

  /// Get user profile
  Future<Map<String, dynamic>> getProfile({
    required String userId,
  }) async {
    final response = await _client.get('/users/$userId');
    return response.data as Map<String, dynamic>;
  }

  /// Update user profile
  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    String? name,
    String? photoUrl,
    Map<String, dynamic>? preferences,
  }) async {
    final response = await _client.patch(
      '/users/$userId',
      data: {
        if (name != null) 'name': name,
        if (photoUrl != null) 'photoUrl': photoUrl,
        if (preferences != null) 'preferences': preferences,
      },
    );

    return response.data as Map<String, dynamic>;
  }

  /// Get user stats
  Future<Map<String, dynamic>> getStats({
    required String userId,
  }) async {
    final response = await _client.get('/users/$userId/stats');
    return response.data as Map<String, dynamic>;
  }

  /// Get user progress
  Future<Map<String, dynamic>> getProgress({
    required String userId,
  }) async {
    final response = await _client.get('/users/$userId/progress');
    return response.data as Map<String, dynamic>;
  }

  /// Update daily streak
  Future<Map<String, dynamic>> updateStreak({
    required String userId,
  }) async {
    final response = await _client.post('/users/$userId/streak');
    return response.data as Map<String, dynamic>;
  }

  /// Add XP points
  Future<Map<String, dynamic>> addXP({
    required String userId,
    required int amount,
    required String source,
  }) async {
    final response = await _client.post(
      '/users/$userId/xp',
      data: {
        'amount': amount,
        'source': source,
      },
    );

    return response.data as Map<String, dynamic>;
  }

  /// Get user achievements
  Future<List<dynamic>> getAchievements({
    required String userId,
  }) async {
    final response = await _client.get('/users/$userId/achievements');
    return response.data as List<dynamic>;
  }

  /// Unlock achievement
  Future<Map<String, dynamic>> unlockAchievement({
    required String userId,
    required String achievementId,
  }) async {
    final response = await _client.post(
      '/users/$userId/achievements/$achievementId',
    );

    return response.data as Map<String, dynamic>;
  }

  /// Get friends list
  Future<List<dynamic>> getFriends({
    required String userId,
  }) async {
    final response = await _client.get('/users/$userId/friends');
    return response.data as List<dynamic>;
  }

  /// Add friend
  Future<Map<String, dynamic>> addFriend({
    required String userId,
    required String friendId,
  }) async {
    final response = await _client.post(
      '/users/$userId/friends',
      data: {
        'friendId': friendId,
      },
    );

    return response.data as Map<String, dynamic>;
  }

  /// Remove friend
  Future<void> removeFriend({
    required String userId,
    required String friendId,
  }) async {
    await _client.delete('/users/$userId/friends/$friendId');
  }
}
