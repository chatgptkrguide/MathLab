import 'package:flutter/material.dart';

/// 온보딩 관련 상수
class OnboardingConstants {
  OnboardingConstants._();

  /// 학년 옵션
  static const List<String> gradeOptions = [
    '초4',
    '초5',
    '초6',
    '중1',
    '중2',
    '중3',
    '고1',
    '고2',
    '고3',
  ];

  /// 성별 옵션
  static const List<Map<String, String>> genderOptions = [
    {'value': 'male', 'label': '남성', 'icon': '👨'},
    {'value': 'female', 'label': '여성', 'icon': '👩'},
  ];

  /// 일일 목표 XP 옵션
  static const List<int> dailyGoalOptions = [
    10,
    20,
    30,
    50,
    100,
  ];

  /// 일일 목표 XP 설명
  static const Map<int, String> dailyGoalDescriptions = {
    10: '가볍게',
    20: '조금씩',
    30: '꾸준히',
    50: '열심히',
    100: '집중적으로',
  };

  /// 일일 목표 XP 예상 시간 (분)
  static const Map<int, int> dailyGoalDurations = {
    10: 3,
    20: 5,
    30: 10,
    50: 15,
    100: 30,
  };

  /// 학습 동기 옵션
  static const List<Map<String, String>> learningMotivations = [
    {'value': 'exam', 'label': '시험 준비', 'icon': '📝'},
    {'value': 'grade', 'label': '성적 향상', 'icon': '📈'},
    {'value': 'interest', 'label': '수학이 재미있어서', 'icon': '🎯'},
    {'value': 'basic', 'label': '기초 다지기', 'icon': '🏗️'},
    {'value': 'challenge', 'label': '도전하고 싶어서', 'icon': '🚀'},
    {'value': 'other', 'label': '기타', 'icon': '💡'},
  ];

  /// 페이지 전환 애니메이션 지속 시간
  static const Duration pageTransitionDuration = Duration(milliseconds: 400);

  /// 페이지 전환 애니메이션 곡선
  static const Curve pageTransitionCurve = Curves.easeOutCubic;

  /// 최소 이름 길이
  static const int minNameLength = 2;

  /// 최대 이름 길이
  static const int maxNameLength = 20;

  /// 최대 학교명 길이
  static const int maxSchoolLength = 50;

  /// 최대 자기소개 길이
  static const int maxBioLength = 150;
}
