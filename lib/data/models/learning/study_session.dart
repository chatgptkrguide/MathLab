/// 학습 세션 데이터 모델
/// 사용자의 학습 시간을 추적하고 기록합니다.
class StudySession {
  final String id;
  final String userId;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationSeconds;
  final StudyActivityType activityType;

  StudySession({
    required this.id,
    required this.userId,
    required this.startTime,
    this.endTime,
    required this.durationSeconds,
    required this.activityType,
  });

  /// 세션이 진행 중인지 여부
  bool get isActive => endTime == null;

  /// 세션 시작부터 현재까지의 시간 (초)
  int get currentDuration {
    if (endTime != null) {
      return durationSeconds;
    }
    return DateTime.now().difference(startTime).inSeconds;
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationSeconds': durationSeconds,
      'activityType': activityType.name,
    };
  }

  /// JSON에서 생성
  factory StudySession.fromJson(Map<String, dynamic> json) {
    return StudySession(
      id: json['id'] as String,
      userId: json['userId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      durationSeconds: json['durationSeconds'] as int,
      activityType: StudyActivityType.values.firstWhere(
        (e) => e.name == json['activityType'],
        orElse: () => StudyActivityType.other,
      ),
    );
  }

  /// 세션 복사 (업데이트용)
  StudySession copyWith({
    String? id,
    String? userId,
    DateTime? startTime,
    DateTime? endTime,
    int? durationSeconds,
    StudyActivityType? activityType,
  }) {
    return StudySession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      activityType: activityType ?? this.activityType,
    );
  }
}

/// 학습 활동 유형
enum StudyActivityType {
  problemSolving('문제 풀이'),
  lesson('강의 시청'),
  review('복습'),
  wrongAnswerReview('오답 복습'),
  other('기타');

  final String label;
  const StudyActivityType(this.label);
}

/// 일일 학습 통계
class DailyStudyStats {
  final DateTime date;
  final int totalSeconds;
  final Map<StudyActivityType, int> activityDurations;
  final int sessionCount;

  DailyStudyStats({
    required this.date,
    required this.totalSeconds,
    required this.activityDurations,
    required this.sessionCount,
  });

  /// 시간 형식으로 변환 (예: "1시간 30분")
  String get formattedDuration {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;

    if (hours > 0) {
      return '$hours시간 $minutes분';
    }
    return '$minutes분';
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'totalSeconds': totalSeconds,
      'activityDurations': activityDurations.map(
        (key, value) => MapEntry(key.name, value),
      ),
      'sessionCount': sessionCount,
    };
  }

  /// JSON에서 생성
  factory DailyStudyStats.fromJson(Map<String, dynamic> json) {
    return DailyStudyStats(
      date: DateTime.parse(json['date'] as String),
      totalSeconds: json['totalSeconds'] as int,
      activityDurations:
          (json['activityDurations'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          StudyActivityType.values.firstWhere((e) => e.name == key),
          value as int,
        ),
      ),
      sessionCount: json['sessionCount'] as int,
    );
  }
}

/// 주간 학습 통계
class WeeklyStudyStats {
  final DateTime weekStartDate;
  final List<DailyStudyStats> dailyStats;

  WeeklyStudyStats({
    required this.weekStartDate,
    required this.dailyStats,
  });

  /// 주간 총 학습 시간 (초)
  int get totalSeconds {
    return dailyStats.fold(0, (sum, day) => sum + day.totalSeconds);
  }

  /// 일평균 학습 시간 (초)
  int get averageSecondsPerDay {
    if (dailyStats.isEmpty) return 0;
    return totalSeconds ~/ dailyStats.length;
  }

  /// 시간 형식으로 변환
  String get formattedTotalDuration {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    return '$hours시간 $minutes분';
  }
}
