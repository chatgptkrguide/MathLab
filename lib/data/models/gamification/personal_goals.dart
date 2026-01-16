import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../base/base_model.dart';

/// 개인화된 학습 목표 모델
/// Duolingo 스타일의 일일 목표 설정
class PersonalGoals implements BaseModel {
  @override
  final String id;

  /// 사용자 ID
  final String userId;

  /// 일일 XP 목표
  final int dailyXpGoal;

  /// 일일 문제 수 목표
  final int dailyProblemGoal;

  /// 일일 학습 시간 목표 (분 단위)
  final int dailyStudyMinutesGoal;

  /// 주간 학습 일수 목표
  final int weeklyStudyDaysGoal;

  /// 알림 시간 (사용자 설정)
  final TimeOfDay reminderTime;

  /// 알림 활성화 여부
  final bool reminderEnabled;

  /// 목표 난이도 레벨 (1-5)
  final int difficultyLevel;

  /// 마지막 업데이트 시간
  final DateTime lastUpdated;

  /// 생성 시간
  final DateTime createdAt;

  const PersonalGoals({
    required this.id,
    required this.userId,
    this.dailyXpGoal = 50, // 기본값: 50 XP
    this.dailyProblemGoal = 10, // 기본값: 10 문제
    this.dailyStudyMinutesGoal = 15, // 기본값: 15분
    this.weeklyStudyDaysGoal = 5, // 기본값: 주 5일
    this.reminderTime = const TimeOfDay(hour: 21, minute: 0), // 기본값: 21:00
    this.reminderEnabled = true,
    this.difficultyLevel = 2, // 기본값: 중간 난이도
    required this.lastUpdated,
    required this.createdAt,
  });

  /// 기본 목표 생성 (신규 사용자용)
  factory PersonalGoals.create(String userId) {
    final now = DateTime.now();
    return PersonalGoals(
      id: userId, // 사용자당 하나의 목표만 존재
      userId: userId,
      lastUpdated: now,
      createdAt: now,
    );
  }

  /// JSON에서 생성
  factory PersonalGoals.fromJson(Map<String, dynamic> json) {
    return PersonalGoals(
      id: json['id'] as String,
      userId: json['userId'] as String,
      dailyXpGoal: json['dailyXpGoal'] as int? ?? 50,
      dailyProblemGoal: json['dailyProblemGoal'] as int? ?? 10,
      dailyStudyMinutesGoal: json['dailyStudyMinutesGoal'] as int? ?? 15,
      weeklyStudyDaysGoal: json['weeklyStudyDaysGoal'] as int? ?? 5,
      reminderTime: json['reminderTime'] != null
          ? _timeOfDayFromString(json['reminderTime'] as String)
          : const TimeOfDay(hour: 21, minute: 0),
      reminderEnabled: json['reminderEnabled'] as bool? ?? true,
      difficultyLevel: json['difficultyLevel'] as int? ?? 2,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// JSON으로 변환
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'dailyXpGoal': dailyXpGoal,
      'dailyProblemGoal': dailyProblemGoal,
      'dailyStudyMinutesGoal': dailyStudyMinutesGoal,
      'weeklyStudyDaysGoal': weeklyStudyDaysGoal,
      'reminderTime': _timeOfDayToString(reminderTime),
      'reminderEnabled': reminderEnabled,
      'difficultyLevel': difficultyLevel,
      'lastUpdated': lastUpdated.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Firestore 형식으로 변환
  @override
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'dailyXpGoal': dailyXpGoal,
      'dailyProblemGoal': dailyProblemGoal,
      'dailyStudyMinutesGoal': dailyStudyMinutesGoal,
      'weeklyStudyDaysGoal': weeklyStudyDaysGoal,
      'reminderTime': _timeOfDayToString(reminderTime),
      'reminderEnabled': reminderEnabled,
      'difficultyLevel': difficultyLevel,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Firestore 문서에서 생성
  factory PersonalGoals.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return PersonalGoals(
      id: doc.id,
      userId: data['userId'] as String,
      dailyXpGoal: data['dailyXpGoal'] as int? ?? 50,
      dailyProblemGoal: data['dailyProblemGoal'] as int? ?? 10,
      dailyStudyMinutesGoal: data['dailyStudyMinutesGoal'] as int? ?? 15,
      weeklyStudyDaysGoal: data['weeklyStudyDaysGoal'] as int? ?? 5,
      reminderTime: data['reminderTime'] != null
          ? _timeOfDayFromString(data['reminderTime'] as String)
          : const TimeOfDay(hour: 21, minute: 0),
      reminderEnabled: data['reminderEnabled'] as bool? ?? true,
      difficultyLevel: data['difficultyLevel'] as int? ?? 2,
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  /// 복사 (업데이트용)
  PersonalGoals copyWith({
    String? id,
    String? userId,
    int? dailyXpGoal,
    int? dailyProblemGoal,
    int? dailyStudyMinutesGoal,
    int? weeklyStudyDaysGoal,
    TimeOfDay? reminderTime,
    bool? reminderEnabled,
    int? difficultyLevel,
    DateTime? lastUpdated,
    DateTime? createdAt,
  }) {
    return PersonalGoals(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      dailyXpGoal: dailyXpGoal ?? this.dailyXpGoal,
      dailyProblemGoal: dailyProblemGoal ?? this.dailyProblemGoal,
      dailyStudyMinutesGoal:
          dailyStudyMinutesGoal ?? this.dailyStudyMinutesGoal,
      weeklyStudyDaysGoal: weeklyStudyDaysGoal ?? this.weeklyStudyDaysGoal,
      reminderTime: reminderTime ?? this.reminderTime,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// TimeOfDay를 문자열로 변환 (HH:mm 형식)
  static String _timeOfDayToString(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// 문자열을 TimeOfDay로 변환
  static TimeOfDay _timeOfDayFromString(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  /// 목표 달성 여부 계산
  bool isGoalAchieved({
    required int earnedXp,
    required int solvedProblems,
    required int studyMinutes,
  }) {
    return earnedXp >= dailyXpGoal &&
        solvedProblems >= dailyProblemGoal &&
        studyMinutes >= dailyStudyMinutesGoal;
  }

  /// 목표 진행률 계산 (0.0 ~ 1.0)
  double getProgress({
    required int earnedXp,
    required int solvedProblems,
    required int studyMinutes,
  }) {
    final xpProgress = dailyXpGoal > 0 ? (earnedXp / dailyXpGoal) : 1.0;
    final problemProgress =
        dailyProblemGoal > 0 ? (solvedProblems / dailyProblemGoal) : 1.0;
    final timeProgress = dailyStudyMinutesGoal > 0
        ? (studyMinutes / dailyStudyMinutesGoal)
        : 1.0;

    return ((xpProgress + problemProgress + timeProgress) / 3).clamp(0.0, 1.0);
  }
}

/// 목표 프리셋 (Duolingo 스타일)
enum GoalPreset {
  casual(
    name: '여유롭게',
    description: '매일 5분, 편안한 학습',
    dailyXpGoal: 20,
    dailyProblemGoal: 5,
    dailyStudyMinutesGoal: 5,
    weeklyStudyDaysGoal: 3,
    difficultyLevel: 1,
  ),
  regular(
    name: '꾸준히',
    description: '매일 15분, 균형잡힌 학습',
    dailyXpGoal: 50,
    dailyProblemGoal: 10,
    dailyStudyMinutesGoal: 15,
    weeklyStudyDaysGoal: 5,
    difficultyLevel: 2,
  ),
  serious(
    name: '열심히',
    description: '매일 30분, 집중 학습',
    dailyXpGoal: 100,
    dailyProblemGoal: 20,
    dailyStudyMinutesGoal: 30,
    weeklyStudyDaysGoal: 6,
    difficultyLevel: 3,
  ),
  intense(
    name: '강도높게',
    description: '매일 1시간, 도전적 학습',
    dailyXpGoal: 200,
    dailyProblemGoal: 40,
    dailyStudyMinutesGoal: 60,
    weeklyStudyDaysGoal: 7,
    difficultyLevel: 4,
  ),
  insane(
    name: '미친듯이',
    description: '매일 2시간+, 전문가 목표',
    dailyXpGoal: 500,
    dailyProblemGoal: 100,
    dailyStudyMinutesGoal: 120,
    weeklyStudyDaysGoal: 7,
    difficultyLevel: 5,
  );

  const GoalPreset({
    required this.name,
    required this.description,
    required this.dailyXpGoal,
    required this.dailyProblemGoal,
    required this.dailyStudyMinutesGoal,
    required this.weeklyStudyDaysGoal,
    required this.difficultyLevel,
  });

  final String name;
  final String description;
  final int dailyXpGoal;
  final int dailyProblemGoal;
  final int dailyStudyMinutesGoal;
  final int weeklyStudyDaysGoal;
  final int difficultyLevel;

  /// PersonalGoals로 변환
  PersonalGoals toPersonalGoals(String userId) {
    final now = DateTime.now();
    return PersonalGoals(
      id: userId,
      userId: userId,
      dailyXpGoal: dailyXpGoal,
      dailyProblemGoal: dailyProblemGoal,
      dailyStudyMinutesGoal: dailyStudyMinutesGoal,
      weeklyStudyDaysGoal: weeklyStudyDaysGoal,
      difficultyLevel: difficultyLevel,
      lastUpdated: now,
      createdAt: now,
    );
  }
}
