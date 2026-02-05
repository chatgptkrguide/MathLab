// 📚 Sample Problems Data
//
// Mock problem data for MVP demonstration.

import 'problem_model.dart';

class SampleProblems {
  /// Get sample problems for a lesson
  static List<ProblemModel> getProblemsForLesson(String lessonId) {
    switch (lessonId) {
      case 'lesson_1_1': // 덧셈 기초
        return _additionBasics();
      case 'lesson_1_2': // 뺄셈 기초
        return _subtractionBasics();
      case 'lesson_1_3': // 곱셈 기초
        return _multiplicationBasics();
      default:
        return _defaultProblems(lessonId);
    }
  }

  static List<ProblemModel> _additionBasics() {
    return [
      ProblemModel(
        id: 'add_1',
        lessonId: 'lesson_1_1',
        question: r'$2 + 3 = ?$',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: ['3', '4', '5', '6'],
        correctAnswer: '5',
        explanation: r'$2 + 3 = 5$입니다. 2개에 3개를 더하면 5개가 됩니다.',
        hint: '손가락으로 세어보세요!',
        points: 10,
      ),
      ProblemModel(
        id: 'add_2',
        lessonId: 'lesson_1_1',
        question: r'$5 + 4$는 얼마일까요?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: ['7', '8', '9', '10'],
        correctAnswer: '9',
        explanation: r'$5 + 4 = 9$입니다.',
        hint: r'5에서 시작해서 4개를 더 세어보세요: $5, 6, 7, 8, 9$',
        points: 10,
      ),
      ProblemModel(
        id: 'add_3',
        lessonId: 'lesson_1_1',
        question: r'다음 식을 계산하세요: $7 + 2 = ?$',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: ['8', '9', '10', '11'],
        correctAnswer: '9',
        explanation: r'$7 + 2 = 9$입니다. 7에 2를 더하면 9가 됩니다.',
        points: 10,
      ),
      ProblemModel(
        id: 'add_4',
        lessonId: 'lesson_1_1',
        question: r'$3 + 6$의 값을 구하세요.',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: ['7', '8', '9', '10'],
        correctAnswer: '9',
        explanation: r'$3 + 6 = 9$입니다. 이는 $3 + 3 + 3$과 같습니다.',
        hint: r'$3 + 6$은 $3$을 두 번 더한 것과 같아요!',
        points: 15,
      ),
      ProblemModel(
        id: 'add_5',
        lessonId: 'lesson_1_1',
        question: r'$8 + 1 = ?$',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: ['7', '8', '9', '10'],
        correctAnswer: '9',
        explanation: r'$8 + 1 = 9$입니다. 8에 1을 더하면 9가 됩니다.',
        points: 10,
      ),
    ];
  }

  static List<ProblemModel> _subtractionBasics() {
    return [
      ProblemModel(
        id: 'sub_1',
        lessonId: 'lesson_1_2',
        question: r'$5 - 2 = ?$',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: ['1', '2', '3', '4'],
        correctAnswer: '3',
        explanation: r'$5 - 2 = 3$입니다. 5에서 2를 빼면 3이 남습니다.',
        hint: '5개에서 2개를 빼보세요.',
        points: 10,
      ),
      ProblemModel(
        id: 'sub_2',
        lessonId: 'lesson_1_2',
        question: r'$9 - 4$는 얼마일까요?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: ['3', '4', '5', '6'],
        correctAnswer: '5',
        explanation: r'$9 - 4 = 5$입니다. 9에서 4를 빼면 5가 남습니다.',
        hint: r'$9$에서 하나씩 빼보세요: $9, 8, 7, 6, 5$',
        points: 10,
      ),
      ProblemModel(
        id: 'sub_3',
        lessonId: 'lesson_1_2',
        question: r'다음 식을 계산하세요: $7 - 3 = ?$',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: ['2', '3', '4', '5'],
        correctAnswer: '4',
        explanation: r'$7 - 3 = 4$입니다. 7에서 3을 빼면 4가 남습니다.',
        points: 10,
      ),
      ProblemModel(
        id: 'sub_4',
        lessonId: 'lesson_1_2',
        question: r'$10 - 6$의 값은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: ['2', '3', '4', '5'],
        correctAnswer: '4',
        explanation: r'$10 - 6 = 4$입니다. 10에서 6을 빼면 4가 남습니다.',
        hint: r'$10$을 $6 + ?$로 나눠보세요!',
        points: 15,
      ),
      ProblemModel(
        id: 'sub_5',
        lessonId: 'lesson_1_2',
        question: r'$8 - 5 = ?$',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: ['1', '2', '3', '4'],
        correctAnswer: '3',
        explanation: r'$8 - 5 = 3$입니다. 8에서 5를 빼면 3이 남습니다.',
        points: 15,
      ),
    ];
  }

  static List<ProblemModel> _multiplicationBasics() {
    return [
      ProblemModel(
        id: 'mul_1',
        lessonId: 'lesson_1_3',
        question: r'$2 \times 3 = ?$',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: ['4', '5', '6', '7'],
        correctAnswer: '6',
        explanation: r'$2 \times 3 = 6$입니다. 2를 3번 더하면 됩니다: $2 + 2 + 2 = 6$',
        hint: r'$2 + 2 + 2$는 얼마일까요?',
        points: 15,
      ),
      ProblemModel(
        id: 'mul_2',
        lessonId: 'lesson_1_3',
        question: r'$3 \times 4$는 얼마일까요?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: ['10', '11', '12', '13'],
        correctAnswer: '12',
        explanation: r'$3 \times 4 = 12$입니다. 구구단 3단: $3, 6, 9, 12$',
        hint: '구구단 3단을 기억하세요!',
        points: 15,
      ),
      ProblemModel(
        id: 'mul_3',
        lessonId: 'lesson_1_3',
        question: r'다음을 계산하세요: $5 \times 2 = ?$',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: ['7', '8', '9', '10'],
        correctAnswer: '10',
        explanation: r'$5 \times 2 = 10$입니다. $5 + 5 = 10$과 같습니다.',
        hint: r'$5$를 두 번 더해보세요!',
        points: 15,
      ),
      ProblemModel(
        id: 'mul_4',
        lessonId: 'lesson_1_3',
        question: r'$4 \times 3$의 값을 구하세요.',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: ['10', '11', '12', '13'],
        correctAnswer: '12',
        explanation: r'$4 \times 3 = 12$입니다. $4 + 4 + 4 = 12$로 계산할 수 있어요.',
        hint: r'$4$를 세 번 더해보세요: $4 + 4 + 4$',
        points: 20,
      ),
      ProblemModel(
        id: 'mul_5',
        lessonId: 'lesson_1_3',
        question: r'$2 \times 5 = ?$',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: ['8', '9', '10', '11'],
        correctAnswer: '10',
        explanation: r'$2 \times 5 = 10$입니다. 2씩 5번 더하면: $2, 4, 6, 8, 10$',
        points: 15,
      ),
    ];
  }

  static List<ProblemModel> _defaultProblems(String lessonId) {
    return [
      ProblemModel(
        id: 'default_1',
        lessonId: lessonId,
        question: '이 레슨의 문제는 준비 중입니다.',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: ['확인'],
        correctAnswer: '확인',
        explanation: '곧 추가될 예정입니다!',
        points: 0,
      ),
    ];
  }
}
