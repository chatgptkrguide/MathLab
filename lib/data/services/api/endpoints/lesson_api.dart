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

  /// Retry wrong answer
  Future<Map<String, dynamic>> retryWrongAnswer({
    required String userId,
    required String wrongAnswerId,
  }) async {
    final response = await _client.post(
      '/users/$userId/wrong-answers/$wrongAnswerId/retry',
    );

    return response.data as Map<String, dynamic>;
  }

  /// Mark wrong answer as resolved
  Future<Map<String, dynamic>> resolveWrongAnswer({
    required String userId,
    required String wrongAnswerId,
  }) async {
    final response = await _client.post(
      '/users/$userId/wrong-answers/$wrongAnswerId/resolve',
    );

    return response.data as Map<String, dynamic>;
  }

  /// Get hints for a problem
  Future<List<dynamic>> getHints({
    required String problemId,
  }) async {
    final response = await _client.get(
      '/problems/$problemId/hints',
    );

    return response.data as List<dynamic>;
  }

  /// Unlock a hint
  Future<Map<String, dynamic>> unlockHint({
    required String userId,
    required String problemId,
    required String hintId,
  }) async {
    final response = await _client.post(
      '/users/$userId/problems/$problemId/hints/$hintId/unlock',
    );

    return response.data as Map<String, dynamic>;
  }

  /// Get hint usage history
  Future<List<dynamic>> getHintUsageHistory({
    required String userId,
    int? limit,
  }) async {
    final response = await _client.get(
      '/users/$userId/hints/history',
      queryParameters: {
        if (limit != null) 'limit': limit,
      },
    );

    return response.data as List<dynamic>;
  }

  /// Get all concept cards
  Future<List<dynamic>> getConceptCards() async {
    final response = await _client.get('/concept-cards');
    return response.data as List<dynamic>;
  }

  /// Get user's concept card progress
  Future<List<dynamic>> getConceptCardProgress({
    required String userId,
  }) async {
    final response = await _client.get(
      '/users/$userId/concept-cards/progress',
    );

    return response.data as List<dynamic>;
  }

  /// Mark concept card as viewed
  Future<Map<String, dynamic>> markConceptCardViewed({
    required String userId,
    required String conceptCardId,
  }) async {
    final response = await _client.post(
      '/users/$userId/concept-cards/$conceptCardId/view',
    );

    return response.data as Map<String, dynamic>;
  }

  /// Toggle concept card bookmark
  Future<Map<String, dynamic>> toggleConceptCardBookmark({
    required String userId,
    required String conceptCardId,
    required bool isBookmarked,
  }) async {
    final response = await _client.post(
      '/users/$userId/concept-cards/$conceptCardId/bookmark',
      data: {
        'isBookmarked': isBookmarked,
      },
    );

    return response.data as Map<String, dynamic>;
  }

  /// Get related concepts
  Future<List<dynamic>> getRelatedConcepts({
    required String conceptCardId,
  }) async {
    final response = await _client.get(
      '/concept-cards/$conceptCardId/related',
    );

    return response.data as List<dynamic>;
  }

  /// Start practice session
  Future<Map<String, dynamic>> startPracticeSession({
    required String userId,
    required String mode,
    String? lessonId,
    String? unitId,
    int? problemCount,
  }) async {
    final response = await _client.post(
      '/users/$userId/practice/start',
      data: {
        'mode': mode,
        if (lessonId != null) 'lessonId': lessonId,
        if (unitId != null) 'unitId': unitId,
        if (problemCount != null) 'problemCount': problemCount,
      },
    );

    return response.data as Map<String, dynamic>;
  }

  /// Submit practice answer
  Future<Map<String, dynamic>> submitPracticeAnswer({
    required String sessionId,
    required String problemId,
    required String answer,
    required int timeTaken,
    int hintUsed = 0,
  }) async {
    final response = await _client.post(
      '/practice/sessions/$sessionId/submit',
      data: {
        'problemId': problemId,
        'answer': answer,
        'timeTaken': timeTaken,
        'hintUsed': hintUsed,
      },
    );

    return response.data as Map<String, dynamic>;
  }

  /// End practice session
  Future<Map<String, dynamic>> endPracticeSession({
    required String sessionId,
  }) async {
    final response = await _client.post(
      '/practice/sessions/$sessionId/end',
    );

    return response.data as Map<String, dynamic>;
  }

  /// Get practice history
  Future<List<dynamic>> getPracticeHistory({
    required String userId,
    int? limit,
  }) async {
    final response = await _client.get(
      '/users/$userId/practice/history',
      queryParameters: {
        if (limit != null) 'limit': limit,
      },
    );

    return response.data as List<dynamic>;
  }
}
