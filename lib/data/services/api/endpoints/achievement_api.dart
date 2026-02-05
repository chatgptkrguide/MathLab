// 🏅 Achievement API
//
// Handles achievement and badge-related API calls

import '../dio_client.dart';

class AchievementAPI {
  final DioClient _client;

  AchievementAPI({required DioClient client}) : _client = client;

  /// Get all achievements
  Future<List<dynamic>> getAchievements() async {
    final response = await _client.get('/achievements');
    return response.data as List<dynamic>;
  }

  /// Get user's achievement progress
  Future<List<dynamic>> getUserAchievementProgress({
    required String userId,
  }) async {
    final response = await _client.get('/users/$userId/achievements/progress');
    return response.data as List<dynamic>;
  }

  /// Check for newly unlocked achievements
  Future<List<dynamic>> checkAchievements({
    required String userId,
  }) async {
    final response = await _client.post('/users/$userId/achievements/check');
    return response.data as List<dynamic>;
  }

  /// Get recent achievements
  Future<List<dynamic>> getRecentAchievements({
    required String userId,
    int limit = 5,
  }) async {
    final response = await _client.get(
      '/users/$userId/achievements/recent',
      queryParameters: {
        'limit': limit,
      },
    );
    return response.data as List<dynamic>;
  }

  /// Get achievements by category
  Future<List<dynamic>> getAchievementsByCategory({
    required String category,
  }) async {
    final response = await _client.get(
      '/achievements/category/$category',
    );
    return response.data as List<dynamic>;
  }

  /// Get achievements by rarity
  Future<List<dynamic>> getAchievementsByRarity({
    required String rarity,
  }) async {
    final response = await _client.get(
      '/achievements/rarity/$rarity',
    );
    return response.data as List<dynamic>;
  }

  /// Get achievement statistics
  Future<Map<String, dynamic>> getAchievementStats({
    required String userId,
  }) async {
    final response = await _client.get('/users/$userId/achievements/stats');
    return response.data as Map<String, dynamic>;
  }
}
