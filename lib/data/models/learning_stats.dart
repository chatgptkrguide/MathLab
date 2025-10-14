/// 학습 통계 모델
class LearningStats {
  final String userId;
  final int totalXP;
  final int completedEpisodes; // 완료한 에피소드 수
  final int maxStreak; // 최고 연속 기록
  final int currentStreak; // 현재 연속 기록
  final int totalStudyTime; // 총 학습 시간 (분)
  final int totalProblems; // 총 푼 문제 수
  final int correctAnswers; // 정답 수
  final int totalSessions; // 총 학습 세션 수
  final DateTime lastStudyDate; // 마지막 학습 날짜
  final Map<String, int> categoryStats; // 카테고리별 통계

  const LearningStats({
    required this.userId,
    required this.totalXP,
    required this.completedEpisodes,
    required this.maxStreak,
    required this.currentStreak,
    required this.totalStudyTime,
    required this.totalProblems,
    required this.correctAnswers,
    required this.totalSessions,
    required this.lastStudyDate,
    required this.categoryStats,
  });

  /// JSON으로부터 LearningStats 객체 생성
  factory LearningStats.fromJson(Map<String, dynamic> json) {
    return LearningStats(
      userId: json['userId'] as String,
      totalXP: json['totalXP'] as int,
      completedEpisodes: json['completedEpisodes'] as int,
      maxStreak: json['maxStreak'] as int,
      currentStreak: json['currentStreak'] as int,
      totalStudyTime: json['totalStudyTime'] as int,
      totalProblems: json['totalProblems'] as int,
      correctAnswers: json['correctAnswers'] as int,
      totalSessions: json['totalSessions'] as int,
      lastStudyDate: DateTime.parse(json['lastStudyDate'] as String),
      categoryStats: Map<String, int>.from(json['categoryStats'] as Map),
    );
  }

  /// LearningStats 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'totalXP': totalXP,
      'completedEpisodes': completedEpisodes,
      'maxStreak': maxStreak,
      'currentStreak': currentStreak,
      'totalStudyTime': totalStudyTime,
      'totalProblems': totalProblems,
      'correctAnswers': correctAnswers,
      'totalSessions': totalSessions,
      'lastStudyDate': lastStudyDate.toIso8601String(),
      'categoryStats': categoryStats,
    };
  }

  /// LearningStats 객체 복사 (일부 값 변경)
  LearningStats copyWith({
    String? userId,
    int? totalXP,
    int? completedEpisodes,
    int? maxStreak,
    int? currentStreak,
    int? totalStudyTime,
    int? totalProblems,
    int? correctAnswers,
    int? totalSessions,
    DateTime? lastStudyDate,
    Map<String, int>? categoryStats,
  }) {
    return LearningStats(
      userId: userId ?? this.userId,
      totalXP: totalXP ?? this.totalXP,
      completedEpisodes: completedEpisodes ?? this.completedEpisodes,
      maxStreak: maxStreak ?? this.maxStreak,
      currentStreak: currentStreak ?? this.currentStreak,
      totalStudyTime: totalStudyTime ?? this.totalStudyTime,
      totalProblems: totalProblems ?? this.totalProblems,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalSessions: totalSessions ?? this.totalSessions,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
      categoryStats: categoryStats ?? this.categoryStats,
    );
  }

  /// 정답률 계산 (0.0 ~ 1.0)
  double get accuracy {
    if (totalProblems == 0) return 0.0;
    return correctAnswers / totalProblems;
  }

  /// 정답률 퍼센트 (0 ~ 100)
  int get accuracyPercentage => (accuracy * 100).round();

  /// 평균 학습 시간 (분/일)
  double get averageDailyStudyTime {
    if (totalSessions == 0) return 0.0;
    return totalStudyTime / totalSessions;
  }

  /// 시간 형태로 변환된 총 학습 시간
  String get formattedTotalStudyTime {
    final hours = totalStudyTime ~/ 60;
    final minutes = totalStudyTime % 60;

    if (hours == 0) {
      return '${minutes}분';
    } else {
      return '${hours}시간 ${minutes}분';
    }
  }

  /// 평균 세션 시간
  String get formattedAverageSessionTime {
    final avgMinutes = averageDailyStudyTime.round();
    return '${avgMinutes}분';
  }

  /// 학습 레벨 (총 XP 기준)
  int get level {
    // 레벨 공식: √(totalXP / 100)
    return (totalXP / 100).round() + 1;
  }

  /// 연속 학습 상태
  StreakStatus get streakStatus {
    final now = DateTime.now();
    final daysSinceLastStudy = now.difference(lastStudyDate).inDays;

    if (daysSinceLastStudy == 0) return StreakStatus.active;
    if (daysSinceLastStudy == 1) return StreakStatus.grace;
    return StreakStatus.broken;
  }

  /// 가장 강한 카테고리
  String? get strongestCategory {
    if (categoryStats.isEmpty) return null;

    var maxEntry = categoryStats.entries.first;
    for (final entry in categoryStats.entries) {
      if (entry.value > maxEntry.value) {
        maxEntry = entry;
      }
    }
    return maxEntry.key;
  }

  /// 가장 약한 카테고리
  String? get weakestCategory {
    if (categoryStats.isEmpty) return null;

    var minEntry = categoryStats.entries.first;
    for (final entry in categoryStats.entries) {
      if (entry.value < minEntry.value) {
        minEntry = entry;
      }
    }
    return minEntry.key;
  }

  @override
  String toString() {
    return 'LearningStats{userId: $userId, totalXP: $totalXP, accuracy: ${accuracyPercentage}%}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LearningStats && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;
}

/// 연속 학습 상태
enum StreakStatus {
  active, // 활성 (오늘 학습함)
  grace, // 유예 (어제 마지막 학습, 오늘 학습하면 연속 유지)
  broken, // 끊김 (2일 이상 학습 안함)
}