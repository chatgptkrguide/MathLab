/// 📚 Lesson API
///
/// Handles lesson and problem-related API calls

import 'package:dio/dio.dart';
import '../dio_client.dart';

class LessonAPI {
  final DioClient _client;

  LessonAPI({required DioClient client}) : _client = client;

  /// Get all units
  Future<List<dynamic>> getUnits() async {
    final response = await _client.get('/lessons/units');
    return response.data as List<dynamic>;
  }

  /// Get lessons for a unit
  Future<List<dynamic>> getLessons({
    required String unitId,
  }) async {
    final response = await _client.get('/lessons/units/$unitId/lessons');
    return response.data as List<dynamic>;
  }

  /// Get lesson details
  Future<Map<String, dynamic>> getLesson({
    required String lessonId,
  }) async {
    final response = await _client.get('/lessons/$lessonId');
    return response.data as Map<String, dynamic>;
  }

  /// Get problems for a lesson
  Future<List<dynamic>> getProblems({
    required String lessonId,
  }) async {
    final response = await _client.get('/lessons/$lessonId/problems');
    return response.data as List<dynamic>;
  }

  /// Submit problem answer
  Future<Map<String, dynamic>> submitAnswer({
    required String lessonId,
    required String problemId,
    required String answer,
    required bool isCorrect,
    required int timeTaken,
  }) async {
    final response = await _client.post(
      '/lessons/$lessonId/problems/$problemId/submit',
      data: {
        'answer': answer,
        'isCorrect': isCorrect,
        'timeTaken': timeTaken,
      },
    );

    return response.data as Map<String, dynamic>;
  }

  /// Complete lesson
  Future<Map<String, dynamic>> completeLesson({
    required String userId,
    required String lessonId,
    required int score,
    required int stars,
    required double accuracy,
  }) async {
    final response = await _client.post(
      '/lessons/$lessonId/complete',
      data: {
        'userId': userId,
        'score': score,
        'stars': stars,
        'accuracy': accuracy,
      },
    );

    return response.data as Map<String, dynamic>;
  }

  /// Get user progress for a lesson
  Future<Map<String, dynamic>> getLessonProgress({
    required String userId,
    required String lessonId,
  }) async {
    final response = await _client.get(
      '/users/$userId/lessons/$lessonId/progress',
    );

    return response.data as Map<String, dynamic>;
  }

  /// Get daily challenge
  Future<Map<String, dynamic>> getDailyChallenge({
    required String userId,
  }) async {
    final response = await _client.get('/users/$userId/daily-challenge');
    return response.data as Map<String, dynamic>;
  }

  /// Submit daily challenge
  Future<Map<String, dynamic>> submitDailyChallenge({
    required String userId,
    required List<Map<String, dynamic>> answers,
  }) async {
    final response = await _client.post(
      '/users/$userId/daily-challenge/submit',
      data: {
        'answers': answers,
      },
    );

    return response.data as Map<String, dynamic>;
  }

  /// Get wrong answers (오답 노트)
  Future<List<dynamic>> getWrongAnswers({
    required String userId,
    int? limit,
  }) async {
    final response = await _client.get(
      '/users/$userId/wrong-answers',
      queryParameters: {
        if (limit != null) 'limit': limit,
      },
    );

    return response.data as List<dynamic>;
  }
}
