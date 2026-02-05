// 📚 Sample Curriculum Data
//
// Mock data for curriculum (MVP version).

import 'lesson_model.dart';
import 'unit_model.dart';

class CurriculumData {
  /// Get sample units for MVP
  static List<UnitModel> getSampleUnits() {
    return [
      // Unit 1: 기초 산술
      UnitModel(
        id: 'unit_1',
        title: '기초 산술',
        description: '덧셈, 뺄셈, 곱셈, 나눗셈의 기초를 배워요',
        order: 1,
        emoji: '🔢',
        theme: UnitTheme.blue,
        lessons: [
          LessonModel(
            id: 'lesson_1_1',
            title: '덧셈 기초',
            description: '한 자리 수 덧셈을 배워요',
            order: 1,
            xpReward: 10,
            type: LessonType.standard,
            difficulty: LessonDifficulty.beginner,
            concepts: ['덧셈', '한 자리 수'],
            estimatedMinutes: 5,
          ),
          LessonModel(
            id: 'lesson_1_2',
            title: '뺄셈 기초',
            description: '한 자리 수 뺄셈을 배워요',
            order: 2,
            xpReward: 10,
            type: LessonType.standard,
            difficulty: LessonDifficulty.beginner,
            concepts: ['뺄셈', '한 자리 수'],
            estimatedMinutes: 5,
          ),
          LessonModel(
            id: 'lesson_1_3',
            title: '곱셈 기초',
            description: '곱셈의 개념을 배워요',
            order: 3,
            xpReward: 15,
            type: LessonType.standard,
            difficulty: LessonDifficulty.beginner,
            concepts: ['곱셈', '구구단'],
            estimatedMinutes: 7,
          ),
          LessonModel(
            id: 'lesson_1_4',
            title: '나눗셈 기초',
            description: '나눗셈의 개념을 배워요',
            order: 4,
            xpReward: 15,
            type: LessonType.standard,
            difficulty: LessonDifficulty.beginner,
            concepts: ['나눗셈'],
            estimatedMinutes: 7,
          ),
          LessonModel(
            id: 'lesson_1_5',
            title: 'Unit 1 복습',
            description: '배운 내용을 복습해요',
            order: 5,
            xpReward: 20,
            type: LessonType.review,
            difficulty: LessonDifficulty.beginner,
            concepts: ['덧셈', '뺄셈', '곱셈', '나눗셈'],
            estimatedMinutes: 10,
          ),
        ],
      ),

      // Unit 2: 분수와 소수
      UnitModel(
        id: 'unit_2',
        title: '분수와 소수',
        description: '분수와 소수의 개념을 배워요',
        order: 2,
        emoji: '🍰',
        theme: UnitTheme.green,
        lessons: [
          LessonModel(
            id: 'lesson_2_1',
            title: '분수의 이해',
            description: '분수가 무엇인지 배워요',
            order: 1,
            xpReward: 15,
            type: LessonType.story,
            difficulty: LessonDifficulty.beginner,
            concepts: ['분수', '분자', '분모'],
            estimatedMinutes: 8,
          ),
          LessonModel(
            id: 'lesson_2_2',
            title: '분수의 덧셈',
            description: '같은 분모를 가진 분수를 더해요',
            order: 2,
            xpReward: 15,
            type: LessonType.standard,
            difficulty: LessonDifficulty.intermediate,
            concepts: ['분수 덧셈'],
            estimatedMinutes: 8,
          ),
          LessonModel(
            id: 'lesson_2_3',
            title: '소수의 이해',
            description: '소수가 무엇인지 배워요',
            order: 3,
            xpReward: 15,
            type: LessonType.story,
            difficulty: LessonDifficulty.beginner,
            concepts: ['소수', '소수점'],
            estimatedMinutes: 7,
          ),
          LessonModel(
            id: 'lesson_2_4',
            title: '소수의 덧셈과 뺄셈',
            description: '소수의 덧셈과 뺄셈을 배워요',
            order: 4,
            xpReward: 20,
            type: LessonType.standard,
            difficulty: LessonDifficulty.intermediate,
            concepts: ['소수 덧셈', '소수 뺄셈'],
            estimatedMinutes: 10,
          ),
          LessonModel(
            id: 'lesson_2_5',
            title: 'Unit 2 챌린지',
            description: '분수와 소수 문제에 도전해요',
            order: 5,
            xpReward: 25,
            type: LessonType.challenge,
            difficulty: LessonDifficulty.intermediate,
            concepts: ['분수', '소수', '종합'],
            estimatedMinutes: 12,
          ),
        ],
      ),

      // Unit 3: 방정식
      UnitModel(
        id: 'unit_3',
        title: '방정식',
        description: '일차방정식을 배워요',
        order: 3,
        emoji: '🎯',
        theme: UnitTheme.orange,
        lessons: [
          LessonModel(
            id: 'lesson_3_1',
            title: '방정식의 이해',
            description: '방정식이 무엇인지 배워요',
            order: 1,
            xpReward: 20,
            type: LessonType.story,
            difficulty: LessonDifficulty.intermediate,
            concepts: ['방정식', '등호'],
            estimatedMinutes: 10,
          ),
          LessonModel(
            id: 'lesson_3_2',
            title: '일차방정식 풀기',
            description: '간단한 일차방정식을 풀어요',
            order: 2,
            xpReward: 25,
            type: LessonType.standard,
            difficulty: LessonDifficulty.intermediate,
            concepts: ['일차방정식', '이항'],
            estimatedMinutes: 12,
          ),
          LessonModel(
            id: 'lesson_3_3',
            title: '방정식 활용',
            description: '실생활 문제를 방정식으로 풀어요',
            order: 3,
            xpReward: 30,
            type: LessonType.practice,
            difficulty: LessonDifficulty.advanced,
            concepts: ['방정식 활용', '문장제'],
            estimatedMinutes: 15,
          ),
          LessonModel(
            id: 'lesson_3_4',
            title: 'Unit 3 보스',
            description: '방정식 마스터에 도전해요',
            order: 4,
            xpReward: 50,
            type: LessonType.boss,
            difficulty: LessonDifficulty.advanced,
            concepts: ['방정식', '종합'],
            estimatedMinutes: 20,
          ),
        ],
      ),

      // Unit 4: 기하학 기초
      UnitModel(
        id: 'unit_4',
        title: '기하학 기초',
        description: '도형과 각도를 배워요',
        order: 4,
        emoji: '📐',
        theme: UnitTheme.purple,
        lessons: [
          LessonModel(
            id: 'lesson_4_1',
            title: '도형의 이해',
            description: '여러 가지 도형을 배워요',
            order: 1,
            xpReward: 15,
            type: LessonType.story,
            difficulty: LessonDifficulty.beginner,
            concepts: ['도형', '삼각형', '사각형'],
            estimatedMinutes: 8,
          ),
          LessonModel(
            id: 'lesson_4_2',
            title: '각도 측정',
            description: '각도를 재는 방법을 배워요',
            order: 2,
            xpReward: 20,
            type: LessonType.standard,
            difficulty: LessonDifficulty.intermediate,
            concepts: ['각도', '도', '분도기'],
            estimatedMinutes: 10,
          ),
          LessonModel(
            id: 'lesson_4_3',
            title: '넓이 구하기',
            description: '도형의 넓이를 구해요',
            order: 3,
            xpReward: 25,
            type: LessonType.standard,
            difficulty: LessonDifficulty.intermediate,
            concepts: ['넓이', '면적'],
            estimatedMinutes: 12,
          ),
        ],
      ),
    ];
  }

  /// Get initial progress for a user (first lesson unlocked)
  static Map<String, String> getInitialLessonStatuses() {
    return {
      'lesson_1_1': 'unlocked', // First lesson is unlocked
    };
  }
}
