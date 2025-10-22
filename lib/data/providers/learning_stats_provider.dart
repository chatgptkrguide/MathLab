import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

/// 학습 통계 상태 관리
class LearningStatsNotifier extends StateNotifier<LearningStats?> {
  LearningStatsNotifier() : super(null) {
    _loadStats();
  }

  /// 통계 데이터 로드
  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString('learningStats');

    if (statsJson != null) {
      final statsData = jsonDecode(statsJson);
      state = LearningStats.fromJson(statsData);
    } else {
      // 초기 통계 생성
      state = LearningStats(
        userId: 'user001',
        totalXP: 0,
        completedEpisodes: 0,
        maxStreak: 0,
        currentStreak: 0,
        totalStudyTime: 0,
        totalProblems: 0,
        correctAnswers: 0,
        totalSessions: 0,
        lastStudyDate: DateTime.now(),
        categoryStats: {
          '기초산술': 0,
          '대수': 0,
          '기하': 0,
          '통계': 0,
        },
      );
      await _saveStats();
    }
  }

  /// 통계 데이터 저장
  Future<void> _saveStats() async {
    if (state == null) return;

    final prefs = await SharedPreferences.getInstance();
    final statsJson = jsonEncode(state!.toJson());
    await prefs.setString('learningStats', statsJson);
  }

  /// 학습 세션 완료 시 통계 업데이트
  Future<void> updateAfterSession({
    required int totalXPEarned,
    required int totalProblems,
    required int correctAnswers,
    required Duration totalTimeSpent,
    required List<Problem> problems,
  }) async {
    if (state == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 카테고리별 통계 업데이트
    final newCategoryStats = Map<String, int>.from(state!.categoryStats);
    final newCategoryCorrect = Map<String, int>.from(state!.categoryCorrect);
    final newCategoryTime = Map<String, int>.from(state!.categoryTime);

    // 각 문제의 카테고리별 통계 추적
    final categoryTimePerProblem = totalTimeSpent.inSeconds ~/ (totalProblems > 0 ? totalProblems : 1);
    for (final problem in problems) {
      final category = problem.category;

      // 문제 수 증가
      newCategoryStats[category] = (newCategoryStats[category] ?? 0) + 1;

      // 시간 추가 (대략적인 분배)
      newCategoryTime[category] = (newCategoryTime[category] ?? 0) + categoryTimePerProblem;
    }

    // 정답 처리된 문제의 카테고리별 정답 수 증가
    // 참고: 이 메서드에서 정확한 정답 여부를 알 수 없으므로,
    // recordProblemResult 메서드를 통해 개별적으로 추적하는 것이 더 정확

    // 세션 타임스탬프 추가 (최근 50개만 유지)
    final newTimestamps = [...state!.sessionTimestamps, now];
    if (newTimestamps.length > 50) {
      newTimestamps.removeRange(0, newTimestamps.length - 50);
    }

    state = state!.copyWith(
      totalXP: state!.totalXP + totalXPEarned,
      totalProblems: state!.totalProblems + totalProblems,
      correctAnswers: state!.correctAnswers + correctAnswers,
      totalSessions: state!.totalSessions + 1,
      totalStudyTime: state!.totalStudyTime + totalTimeSpent.inMinutes,
      lastStudyDate: today,
      categoryStats: newCategoryStats,
      categoryCorrect: newCategoryCorrect,
      categoryTime: newCategoryTime,
      sessionTimestamps: newTimestamps,
    );

    await _saveStats();
  }

  /// 개별 문제 결과 기록 (카테고리별 정답률 추적용)
  Future<void> recordProblemResult({
    required String category,
    required bool isCorrect,
    required int timeSpentSeconds,
  }) async {
    if (state == null) return;

    final newCategoryCorrect = Map<String, int>.from(state!.categoryCorrect);
    final newCategoryTime = Map<String, int>.from(state!.categoryTime);

    // 정답이면 카테고리별 정답 수 증가
    if (isCorrect) {
      newCategoryCorrect[category] = (newCategoryCorrect[category] ?? 0) + 1;
    }

    // 카테고리별 시간 추가
    newCategoryTime[category] = (newCategoryTime[category] ?? 0) + timeSpentSeconds;

    state = state!.copyWith(
      categoryCorrect: newCategoryCorrect,
      categoryTime: newCategoryTime,
    );

    await _saveStats();
  }

  /// 스트릭 업데이트
  Future<void> updateStreak(int newCurrentStreak) async {
    if (state == null) return;

    final newMaxStreak = newCurrentStreak > state!.maxStreak
        ? newCurrentStreak
        : state!.maxStreak;

    state = state!.copyWith(
      currentStreak: newCurrentStreak,
      maxStreak: newMaxStreak,
    );

    await _saveStats();
  }

  /// 레슨 완료 시 업데이트
  Future<void> completeEpisode() async {
    if (state == null) return;

    state = state!.copyWith(
      completedEpisodes: state!.completedEpisodes + 1,
    );

    await _saveStats();
  }

  /// 일일 통계 조회
  DailyStats getDailyStats() {
    if (state == null) {
      return DailyStats(
        date: DateTime.now(),
        problemsSolved: 0,
        correctAnswers: 0,
        xpEarned: 0,
        studyTimeMinutes: 0,
        sessions: 0,
      );
    }

    // 임시로 전체 통계의 일부를 일일 통계로 사용
    // 실제로는 날짜별 세분화된 데이터가 필요
    return DailyStats(
      date: DateTime.now(),
      problemsSolved: state!.totalProblems,
      correctAnswers: state!.correctAnswers,
      xpEarned: state!.totalXP,
      studyTimeMinutes: state!.totalStudyTime,
      sessions: state!.totalSessions,
    );
  }

  /// 주간 통계 조회
  WeeklyStats getWeeklyStats() {
    if (state == null) {
      return WeeklyStats(
        weekStartDate: _getWeekStart(DateTime.now()),
        totalProblems: 0,
        totalXP: 0,
        averageAccuracy: 0.0,
        studyDays: 0,
        longestStreak: 0,
      );
    }

    return WeeklyStats(
      weekStartDate: _getWeekStart(DateTime.now()),
      totalProblems: state!.totalProblems,
      totalXP: state!.totalXP,
      averageAccuracy: state!.accuracy,
      studyDays: state!.currentStreak.clamp(0, 7),
      longestStreak: state!.maxStreak,
    );
  }

  /// 카테고리별 성과 분석
  Map<String, CategoryPerformance> getCategoryPerformance() {
    if (state == null) return {};

    final performance = <String, CategoryPerformance>{};

    for (final entry in state!.categoryStats.entries) {
      final category = entry.key;
      final problemCount = entry.value;

      // 카테고리별 정답 수
      final correctCount = state!.categoryCorrect[category] ?? 0;
      final categoryAccuracy = problemCount > 0 ? correctCount / problemCount : 0.0;

      // 카테고리별 평균 시간 (초 단위)
      final totalTime = state!.categoryTime[category] ?? 0;
      final avgTimeSeconds = problemCount > 0 ? totalTime ~/ problemCount : 0;

      // 개선도 계산 (간단하게: 정답률이 0.7 이상이면 양수)
      final improvementRate = categoryAccuracy >= 0.7 ? 0.1 : -0.05;

      performance[category] = CategoryPerformance(
        category: category,
        problemsSolved: problemCount,
        accuracy: categoryAccuracy,
        averageTime: avgTimeSeconds,
        improvement: improvementRate,
      );
    }

    return performance;
  }

  /// 학습 패턴 분석
  LearningPattern analyzeLearningPattern() {
    if (state == null) {
      return LearningPattern(
        preferredStudyTime: 'unknown',
        strongCategories: [],
        weakCategories: [],
        recommendedFocus: 'balanced',
      );
    }

    // 강한/약한 카테고리 식별
    final sortedCategories = state!.categoryStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final strongCategories = sortedCategories
        .take(2)
        .map((e) => e.key)
        .toList();

    final weakCategories = sortedCategories
        .skip(sortedCategories.length - 2)
        .map((e) => e.key)
        .toList();

    // 선호하는 학습 시간대 분석
    String preferredStudyTime = 'unknown';
    if (state!.sessionTimestamps.isNotEmpty) {
      final timeOfDayCounts = <String, int>{
        'morning': 0, // 6-12시
        'afternoon': 0, // 12-18시
        'evening': 0, // 18-22시
        'night': 0, // 22-6시
      };

      for (final timestamp in state!.sessionTimestamps) {
        final hour = timestamp.hour;
        if (hour >= 6 && hour < 12) {
          timeOfDayCounts['morning'] = (timeOfDayCounts['morning'] ?? 0) + 1;
        } else if (hour >= 12 && hour < 18) {
          timeOfDayCounts['afternoon'] = (timeOfDayCounts['afternoon'] ?? 0) + 1;
        } else if (hour >= 18 && hour < 22) {
          timeOfDayCounts['evening'] = (timeOfDayCounts['evening'] ?? 0) + 1;
        } else {
          timeOfDayCounts['night'] = (timeOfDayCounts['night'] ?? 0) + 1;
        }
      }

      // 가장 많이 학습한 시간대 찾기
      var maxCount = 0;
      for (final entry in timeOfDayCounts.entries) {
        if (entry.value > maxCount) {
          maxCount = entry.value;
          preferredStudyTime = entry.key;
        }
      }
    }

    return LearningPattern(
      preferredStudyTime: preferredStudyTime,
      strongCategories: strongCategories,
      weakCategories: weakCategories,
      recommendedFocus: weakCategories.isNotEmpty ? weakCategories.first : 'balanced',
    );
  }

  /// 주의 시작일 계산
  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  /// 통계 초기화 (테스트용)
  Future<void> resetStats() async {
    state = LearningStats(
      userId: state?.userId ?? 'user001',
      totalXP: 0,
      completedEpisodes: 0,
      maxStreak: 0,
      currentStreak: 0,
      totalStudyTime: 0,
      totalProblems: 0,
      correctAnswers: 0,
      totalSessions: 0,
      lastStudyDate: DateTime.now(),
      categoryStats: {
        '기초산술': 0,
        '대수': 0,
        '기하': 0,
        '통계': 0,
      },
    );
    await _saveStats();
  }
}

/// 보조 데이터 클래스들

class DailyStats {
  final DateTime date;
  final int problemsSolved;
  final int correctAnswers;
  final int xpEarned;
  final int studyTimeMinutes;
  final int sessions;

  const DailyStats({
    required this.date,
    required this.problemsSolved,
    required this.correctAnswers,
    required this.xpEarned,
    required this.studyTimeMinutes,
    required this.sessions,
  });

  double get accuracy => problemsSolved > 0 ? correctAnswers / problemsSolved : 0.0;
}

class WeeklyStats {
  final DateTime weekStartDate;
  final int totalProblems;
  final int totalXP;
  final double averageAccuracy;
  final int studyDays;
  final int longestStreak;

  const WeeklyStats({
    required this.weekStartDate,
    required this.totalProblems,
    required this.totalXP,
    required this.averageAccuracy,
    required this.studyDays,
    required this.longestStreak,
  });
}

class CategoryPerformance {
  final String category;
  final int problemsSolved;
  final double accuracy;
  final int averageTime;
  final double improvement;

  const CategoryPerformance({
    required this.category,
    required this.problemsSolved,
    required this.accuracy,
    required this.averageTime,
    required this.improvement,
  });
}

class LearningPattern {
  final String preferredStudyTime;
  final List<String> strongCategories;
  final List<String> weakCategories;
  final String recommendedFocus;

  const LearningPattern({
    required this.preferredStudyTime,
    required this.strongCategories,
    required this.weakCategories,
    required this.recommendedFocus,
  });
}

/// 프로바이더들
final learningStatsProvider = StateNotifierProvider<LearningStatsNotifier, LearningStats?>((ref) {
  return LearningStatsNotifier();
});

// achievementTrackerProvider2 제거 (중복)

/// 편의 프로바이더들
final dailyStatsProvider = Provider<DailyStats>((ref) {
  final statsNotifier = ref.watch(learningStatsProvider.notifier);
  return statsNotifier.getDailyStats();
});

final weeklyStatsProvider = Provider<WeeklyStats>((ref) {
  final statsNotifier = ref.watch(learningStatsProvider.notifier);
  return statsNotifier.getWeeklyStats();
});