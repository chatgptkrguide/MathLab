// 🏆 League API
//
// Handles league and leaderboard API calls

import '../dio_client.dart';

class LeagueAPI {
  final DioClient _client;

  LeagueAPI({required DioClient client}) : _client = client;

  /// Get user's current league
  Future<Map<String, dynamic>> getUserLeague({
    required String userId,
  }) async {
    final response = await _client.get('/users/$userId/league');
    return response.data as Map<String, dynamic>;
  }

  /// Get league leaderboard
  Future<List<dynamic>> getLeaderboard({
    required String leagueId,
    int? limit,
  }) async {
    final response = await _client.get(
      '/leagues/$leagueId/leaderboard',
      queryParameters: {
        if (limit != null) 'limit': limit,
      },
    );

    return response.data as List<dynamic>;
  }

  /// Get all league tiers
  Future<List<dynamic>> getLeagueTiers() async {
    final response = await _client.get('/leagues/tiers');
    return response.data as List<dynamic>;
  }

  /// Get league by ID
  Future<Map<String, dynamic>> getLeague({
    required String leagueId,
  }) async {
    final response = await _client.get('/leagues/$leagueId');
    return response.data as Map<String, dynamic>;
  }

  /// Join league
  Future<Map<String, dynamic>> joinLeague({
    required String userId,
    required String leagueId,
  }) async {
    final response = await _client.post(
      '/leagues/$leagueId/join',
      data: {
        'userId': userId,
      },
    );

    return response.data as Map<String, dynamic>;
  }

  /// Get league history
  Future<List<dynamic>> getLeagueHistory({
    required String userId,
  }) async {
    final response = await _client.get('/users/$userId/league-history');
    return response.data as List<dynamic>;
  }

  /// Get weekly league results
  Future<Map<String, dynamic>> getWeeklyResults({
    required String userId,
  }) async {
    final response = await _client.get('/users/$userId/weekly-results');
    return response.data as Map<String, dynamic>;
  }

  /// Claim league rewards
  Future<Map<String, dynamic>> claimRewards({
    required String userId,
    required String leagueId,
  }) async {
    final response = await _client.post(
      '/users/$userId/leagues/$leagueId/claim-rewards',
    );

    return response.data as Map<String, dynamic>;
  }
}
