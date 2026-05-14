// 📚 Sample Problems Data
//
// Mock problem data for MVP demonstration.

import 'problem_model.dart';
import 'cm1_problems_extended.dart';

class SampleProblems {
  /// Get sample problems for a lesson
  static List<ProblemModel> getProblemsForLesson(String lessonId) {
    switch (lessonId) {
      // 기초 산술
      case 'lesson_1_1':
        return _additionBasics();
      case 'lesson_1_2':
        return _subtractionBasics();
      case 'lesson_1_3':
        return _multiplicationBasics();

      // === 공통수학1 ===
      // Unit 1.1 다항식의 연산
      case 'cm1_1_1_1':
        return _cm1PolynomialOps();
      case 'cm1_1_1_2':
        return _cm1PolynomialDiv();
      case 'cm1_1_1_3':
        return _cm1MultiplicationFormulas();
      case 'cm1_1_1_4':
        return Cm1ProblemsExtended.mult4Variation();
      // Unit 1.2 항등식·나머지정리
      case 'cm1_1_2_1':
        return _cm1Identity();
      case 'cm1_1_2_2':
        return _cm1RemainderTheorem();
      // Unit 1.3 인수분해
      case 'cm1_1_3_1':
        return _cm1Factorization();
      case 'cm1_1_3_2':
        return Cm1ProblemsExtended.factorizationVarious();
      // Unit 2.1 복소수
      case 'cm1_2_1_1':
        return Cm1ProblemsExtended.complexUnit();
      case 'cm1_2_1_2':
        return Cm1ProblemsExtended.complexOps();
      case 'cm1_2_1_3':
        return Cm1ProblemsExtended.negativeRoot();
      // Unit 2.2 이차방정식
      case 'cm1_2_2_1':
        return Cm1ProblemsExtended.quadraticDiscriminant();
      case 'cm1_2_2_2':
        return Cm1ProblemsExtended.quadraticRootCoeff();
      // Unit 2.3 이차함수
      case 'cm1_2_3_1':
        return Cm1ProblemsExtended.quadFunctionRelation();
      case 'cm1_2_3_2':
        return Cm1ProblemsExtended.quadMinMax();
      // Unit 2.4 고차방정식
      case 'cm1_2_4_1':
        return Cm1ProblemsExtended.higherDegreeEqn();
      case 'cm1_2_4_2':
        return Cm1ProblemsExtended.cubicRootCoeff();
      case 'cm1_2_4_3':
        return Cm1ProblemsExtended.omegaProperties();
      // Unit 2.5 연립방정식
      case 'cm1_2_5_1':
        return Cm1ProblemsExtended.simultaneousQuad();
      case 'cm1_2_5_2':
        return Cm1ProblemsExtended.indeterminateEqn();
      // Unit 2.6 부등식
      case 'cm1_2_6_1':
        return Cm1ProblemsExtended.linearInequality();
      case 'cm1_2_6_2':
        return Cm1ProblemsExtended.simulLinearIneq();
      case 'cm1_2_6_3':
        return Cm1ProblemsExtended.absLinearIneq();
      // Unit 2.7 이차부등식
      case 'cm1_2_7_1':
        return Cm1ProblemsExtended.quadInequality();
      case 'cm1_2_7_2':
        return Cm1ProblemsExtended.simulQuadIneq();
      case 'cm1_2_7_3':
        return Cm1ProblemsExtended.realRootCondition();
      // Unit 3.1 경우의 수
      case 'cm1_3_1_1':
        return Cm1ProblemsExtended.countingBasics();
      case 'cm1_3_1_2':
        return Cm1ProblemsExtended.permutation();
      case 'cm1_3_1_3':
        return Cm1ProblemsExtended.combination();
      // Unit 4.1 행렬
      case 'cm1_4_1_1':
        return Cm1ProblemsExtended.matrixBasics();
      case 'cm1_4_1_2':
        return Cm1ProblemsExtended.matrixOps();
      case 'cm1_4_1_3':
        return Cm1ProblemsExtended.matrixMultiply();

      // === 공통수학2 ===
      case 'lesson_set_1':
        return _cm2SetBasics();
      case 'lesson_set_2':
        return _cm2SetOperations();
      case 'lesson_set_3':
        return _cm2SetLaws();
      case 'lesson_set_4':
        return _cm2Proposition();

      // === 수학I ===
      case 'lesson_exp_1':
        return _math1Exponent();
      case 'lesson_exp_2':
        return _math1ExponentExtended();
      case 'lesson_exp_4':
        return _math1Logarithm();

      default:
        return _defaultProblems(lessonId);
    }
  }

  // ============================================================
  // 기초 산술
  // ============================================================

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
        hints: [
          '손가락을 사용해서 세어보세요!',
          r'먼저 손가락 2개를 펴고, 그 다음 3개를 더 펴보세요.',
          r'$2 + 3$은 2에서 시작해서 3을 세면 됩니다: 3, 4, 5',
        ],
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
        hints: [
          '5에서 시작해서 세어보세요.',
          r'5 다음에 4개를 더 세어보세요: 6, 7, 8, 9',
          r'또는 $5 + 5 = 10$이니까, $5 + 4$는 10보다 1 작아요!',
        ],
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
        hints: [
          '7 다음 숫자부터 2개를 세어보세요.',
          r'$7 + 1 = 8$, 그러면 $7 + 2 = ?$',
          '7에서 2만 더하면 되니까: 8, 9!',
        ],
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
        hints: [
          '더 큰 수에서 시작하면 더 쉬워요!',
          r'$3 + 6 = 6 + 3$과 같아요 (교환 법칙)',
          r'6에서 3을 더해보세요: 7, 8, 9',
        ],
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
        hints: [
          '1을 더하면 바로 다음 숫자가 돼요!',
          r'$8 + 1$은 8 바로 다음 숫자예요.',
          '8 다음 숫자는? 9!',
        ],
        points: 10,
      ),
      ProblemModel(
        id: 'add_6',
        lessonId: 'lesson_1_1',
        question: r'$? + ? = 7$에 알맞은 수를 드래그하세요.',
        type: ProblemType.dragAndDrop,
        difficulty: ProblemDifficulty.easy,
        options: ['2', '3', '4', '5'],
        correctAnswer: 'zone_1=3,zone_2=4',
        explanation: r'$3 + 4 = 7$입니다.',
        hints: [
          '두 수를 더해서 7이 되어야 해요.',
          '3과 4를 더하면 얼마인지 생각해보세요.',
        ],
        points: 15,
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
        hints: ['5개에서 2개를 빼보세요.'],
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
        hints: [r'$9$에서 하나씩 빼보세요: $9, 8, 7, 6, 5$'],
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
        hints: [r'$10$을 $6 + ?$로 나눠보세요!'],
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
        hints: [r'$2 + 2 + 2$는 얼마일까요?'],
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
        hints: ['구구단 3단을 기억하세요!'],
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
        hints: [r'$5$를 두 번 더해보세요!'],
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
        hints: [r'$4$를 세 번 더해보세요: $4 + 4 + 4$'],
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

  // ============================================================
  // 공통수학1 - 다항식
  // ============================================================

  static List<ProblemModel> _cm1PolynomialOps() {
    return [
      ProblemModel(
        id: 'cm1_poly_1',
        lessonId: 'cm1_1_1_1',
        question: r'$(2x + 3) + (4x - 1)$을 계산하세요.',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: [r'$6x + 2$', r'$6x + 4$', r'$6x - 2$', r'$2x + 4$'],
        correctAnswer: r'$6x + 2$',
        explanation: r'동류항끼리 모으면 $(2x + 4x) + (3 + (-1)) = 6x + 2$입니다.',
        hints: [
          r'$x$가 포함된 항끼리, 상수항끼리 모아보세요.',
          r'$2x + 4x = 6x$이고, $3 + (-1) = 2$입니다.',
        ],
        points: 15,
      ),
      ProblemModel(
        id: 'cm1_poly_2',
        lessonId: 'cm1_1_1_1',
        question: r'$(3x^2 + 2x - 1) - (x^2 - 3x + 2)$를 계산하세요.',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: [r'$2x^2 + 5x - 3$', r'$2x^2 - x + 1$', r'$4x^2 + 5x - 3$', r'$2x^2 + 5x + 1$'],
        correctAnswer: r'$2x^2 + 5x - 3$',
        explanation: r'빼는 다항식의 부호를 바꾸면 $3x^2 + 2x - 1 - x^2 + 3x - 2$이고, 동류항끼리 정리하면 $2x^2 + 5x - 3$입니다.',
        hints: [
          '뺄셈은 뒤 다항식의 부호를 모두 바꿔서 더하는 것과 같아요.',
          r'$3x^2 - x^2 = 2x^2$, $2x - (-3x) = 2x + 3x = 5x$',
          r'$-1 - 2 = -3$이므로 답은 $2x^2 + 5x - 3$',
        ],
        points: 20,
      ),
      ProblemModel(
        id: 'cm1_poly_3',
        lessonId: 'cm1_1_1_1',
        question: r'$2x(3x - 4)$를 전개하세요.',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: [r'$6x^2 - 8x$', r'$6x^2 - 4x$', r'$5x^2 - 8x$', r'$6x - 8$'],
        correctAnswer: r'$6x^2 - 8x$',
        explanation: r'분배법칙을 적용하면 $2x \cdot 3x - 2x \cdot 4 = 6x^2 - 8x$입니다.',
        hints: [
          '분배법칙을 사용하세요: 앞의 항을 괄호 안의 각 항에 곱합니다.',
          r'$2x \times 3x = 6x^2$, $2x \times (-4) = -8x$',
        ],
        points: 15,
      ),
      ProblemModel(
        id: 'cm1_poly_4',
        lessonId: 'cm1_1_1_1',
        question: r'$(x + 2)(x + 3)$을 전개하세요.',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: [r'$x^2 + 5x + 6$', r'$x^2 + 5x + 5$', r'$x^2 + 6x + 6$', r'$2x + 5$'],
        correctAnswer: r'$x^2 + 5x + 6$',
        explanation: r'$(x + 2)(x + 3) = x^2 + 3x + 2x + 6 = x^2 + 5x + 6$입니다.',
        hints: [
          'FOIL 방법을 사용하세요: First, Outer, Inner, Last',
          r'$x \cdot x = x^2$, $x \cdot 3 = 3x$, $2 \cdot x = 2x$, $2 \cdot 3 = 6$',
          r'$3x + 2x = 5x$이므로 $x^2 + 5x + 6$',
        ],
        points: 20,
      ),
      ProblemModel(
        id: 'cm1_poly_5',
        lessonId: 'cm1_1_1_1',
        question: r'다항식 $3x^2 - 2x + 5$에서 $x^2$의 계수는?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: ['1', '2', '3', '5'],
        correctAnswer: '3',
        explanation: r'$3x^2$에서 $x^2$ 앞의 수가 계수이므로 3입니다.',
        hints: ['계수는 변수 앞에 붙은 숫자예요.'],
        points: 10,
      ),
    ];
  }

  static List<ProblemModel> _cm1PolynomialDiv() {
    return [
      ProblemModel(
        id: 'cm1_div_1',
        lessonId: 'cm1_1_1_2',
        question: r'$(6x^2 + 4x) \div 2x$를 계산하세요.',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: [r'$3x + 2$', r'$3x + 4$', r'$6x + 2$', r'$3x^2 + 2$'],
        correctAnswer: r'$3x + 2$',
        explanation: r'각 항을 $2x$로 나누면 $\frac{6x^2}{2x} + \frac{4x}{2x} = 3x + 2$입니다.',
        hints: [
          '각 항을 따로 나눠보세요.',
          r'$6x^2 \div 2x = 3x$, $4x \div 2x = 2$',
        ],
        points: 15,
      ),
      ProblemModel(
        id: 'cm1_div_2',
        lessonId: 'cm1_1_1_2',
        question: r'$x^2 + 5x + 6$을 $x + 2$로 나눈 몫은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: [r'$x + 3$', r'$x + 2$', r'$x - 3$', r'$x + 6$'],
        correctAnswer: r'$x + 3$',
        explanation: r'$x^2 + 5x + 6 = (x + 2)(x + 3)$이므로 $(x + 2)$로 나누면 몫은 $x + 3$입니다.',
        hints: [
          r'$x^2 + 5x + 6$을 인수분해해 보세요.',
          '곱해서 6, 더해서 5가 되는 두 수를 찾아보세요: 2와 3',
        ],
        points: 20,
      ),
      ProblemModel(
        id: 'cm1_div_3',
        lessonId: 'cm1_1_1_2',
        question: r'다항식 $A$를 $x - 1$로 나누었을 때 나머지가 3이면, $A$에 $x = 1$을 대입한 값은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: ['1', '2', '3', '4'],
        correctAnswer: '3',
        explanation: '나머지정리에 의해 다항식 A를 (x-1)로 나눈 나머지는 A(1)과 같습니다. 따라서 A(1) = 3입니다.',
        hints: [
          '나머지정리: f(x)를 (x-a)로 나눈 나머지는 f(a)입니다.',
          'x = 1을 대입한 값이 곧 나머지예요.',
        ],
        points: 20,
      ),
      ProblemModel(
        id: 'cm1_div_4',
        lessonId: 'cm1_1_1_2',
        question: r'조립제법을 이용하여 $2x^3 - 3x^2 + x - 5$를 $x - 1$로 나눈 나머지를 구하세요.',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.hard,
        options: ['-3', '-5', '-7', '-1'],
        correctAnswer: '-5',
        explanation: r'$f(1) = 2(1)^3 - 3(1)^2 + 1 - 5 = 2 - 3 + 1 - 5 = -5$입니다.',
        hints: [
          '나머지정리를 활용하세요: x = 1을 대입합니다.',
          r'$2 - 3 + 1 - 5$를 차례로 계산하세요.',
        ],
        points: 25,
      ),
    ];
  }

  static List<ProblemModel> _cm1MultiplicationFormulas() {
    return [
      ProblemModel(
        id: 'cm1_mul_1',
        lessonId: 'cm1_1_1_3',
        question: r'$(x + 3)^2$을 전개하세요.',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: [r'$x^2 + 6x + 9$', r'$x^2 + 3x + 9$', r'$x^2 + 9$', r'$x^2 + 6x + 3$'],
        correctAnswer: r'$x^2 + 6x + 9$',
        explanation: r'완전제곱식 $(a+b)^2 = a^2 + 2ab + b^2$에서 $a=x, b=3$이므로 $x^2 + 6x + 9$입니다.',
        hints: [
          r'$(a+b)^2 = a^2 + 2ab + b^2$ 공식을 사용하세요.',
          r'$a=x, b=3$을 대입하면 $x^2 + 2 \cdot x \cdot 3 + 3^2$',
        ],
        points: 15,
      ),
      ProblemModel(
        id: 'cm1_mul_2',
        lessonId: 'cm1_1_1_3',
        question: r'$(x + 5)(x - 5)$를 계산하세요.',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: [r'$x^2 - 25$', r'$x^2 + 25$', r'$x^2 - 10x + 25$', r'$x^2 - 5$'],
        correctAnswer: r'$x^2 - 25$',
        explanation: r'합차공식 $(a+b)(a-b) = a^2 - b^2$에 의해 $x^2 - 25$입니다.',
        hints: [
          r'$(a+b)(a-b) = a^2 - b^2$ 합차공식을 사용하세요.',
          r'$5^2 = 25$이므로 답은 $x^2 - 25$',
        ],
        points: 15,
      ),
      ProblemModel(
        id: 'cm1_mul_3',
        lessonId: 'cm1_1_1_3',
        question: r'$(2x - 1)^2$을 전개하세요.',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: [r'$4x^2 - 4x + 1$', r'$4x^2 - 2x + 1$', r'$4x^2 - 1$', r'$2x^2 - 4x + 1$'],
        correctAnswer: r'$4x^2 - 4x + 1$',
        explanation: r'$(a-b)^2 = a^2 - 2ab + b^2$에서 $a=2x, b=1$이므로 $4x^2 - 4x + 1$입니다.',
        hints: [
          r'$(a-b)^2 = a^2 - 2ab + b^2$를 사용하세요.',
          r'$(2x)^2 = 4x^2$, $2 \cdot 2x \cdot 1 = 4x$, $1^2 = 1$',
        ],
        points: 20,
      ),
      ProblemModel(
        id: 'cm1_mul_4',
        lessonId: 'cm1_1_1_3',
        question: r'$(a + b + c)^2$을 전개하면 $a^2 + b^2 + c^2$에 무엇을 더해야 할까요?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.hard,
        options: [r'$2ab + 2bc + 2ca$', r'$ab + bc + ca$', r'$2abc$', r'$a + b + c$'],
        correctAnswer: r'$2ab + 2bc + 2ca$',
        explanation: r'$(a+b+c)^2 = a^2 + b^2 + c^2 + 2ab + 2bc + 2ca$입니다.',
        hints: [
          r'$(a+b+c)^2 = ((a+b)+c)^2$로 생각해보세요.',
          '두 항씩 짝지어 곱한 것의 2배를 더하면 됩니다.',
        ],
        points: 25,
      ),
    ];
  }

  static List<ProblemModel> _cm1Identity() {
    return [
      ProblemModel(
        id: 'cm1_id_1',
        lessonId: 'cm1_1_2_1',
        question: r'$ax + b = 0$이 $x$에 대한 항등식이 되려면 $a$와 $b$의 값은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: [r'$a=0, b=0$', r'$a=1, b=0$', r'$a=0, b=1$', r'$a=1, b=1$'],
        correctAnswer: r'$a=0, b=0$',
        explanation: '항등식은 모든 x에 대해 성립하므로 x의 계수와 상수항이 모두 0이어야 합니다.',
        hints: [
          '항등식이란 모든 x 값에 대해 등식이 성립하는 것이에요.',
          'x에 아무 값이나 넣어도 0이 되려면 a와 b가 어떤 값이어야 할까요?',
        ],
        points: 20,
      ),
      ProblemModel(
        id: 'cm1_id_2',
        lessonId: 'cm1_1_2_1',
        question: r'$2x^2 + ax + 3 = 2x^2 + 5x + b$가 항등식일 때, $a + b$의 값은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: ['6', '7', '8', '9'],
        correctAnswer: '8',
        explanation: r'양변의 계수를 비교하면 $a = 5$, $b = 3$이므로 $a + b = 8$입니다.',
        hints: [
          '항등식이면 양변의 같은 차수의 계수가 같아야 해요.',
          r'$x$의 계수: $a = 5$, 상수항: $3 = b$',
        ],
        points: 20,
      ),
      ProblemModel(
        id: 'cm1_id_3',
        lessonId: 'cm1_1_2_1',
        question: r'$(a-2)x + (b+1) = 0$이 항등식일 때, $a \cdot b$의 값은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: ['-2', '-1', '0', '2'],
        correctAnswer: '-2',
        explanation: r'$a - 2 = 0$이면 $a = 2$, $b + 1 = 0$이면 $b = -1$이므로 $a \cdot b = -2$',
        hints: [
          '각 계수가 모두 0이어야 합니다.',
          r'$a - 2 = 0$, $b + 1 = 0$을 풀어보세요.',
        ],
        points: 20,
      ),
    ];
  }

  static List<ProblemModel> _cm1RemainderTheorem() {
    return [
      ProblemModel(
        id: 'cm1_rem_1',
        lessonId: 'cm1_1_2_2',
        question: r'$f(x) = x^2 + 3x + 2$를 $x - 1$로 나눈 나머지는?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: ['4', '5', '6', '7'],
        correctAnswer: '6',
        explanation: r'나머지정리에 의해 $f(1) = 1 + 3 + 2 = 6$입니다.',
        hints: [
          '나머지정리: f(x)를 (x-a)로 나눈 나머지는 f(a)',
          'x = 1을 대입하면 됩니다.',
        ],
        points: 15,
      ),
      ProblemModel(
        id: 'cm1_rem_2',
        lessonId: 'cm1_1_2_2',
        question: r'$f(x) = x^3 - 2x + 1$에서 $f(-1)$의 값은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: ['0', '1', '2', '4'],
        correctAnswer: '2',
        explanation: r'$f(-1) = (-1)^3 - 2(-1) + 1 = -1 + 2 + 1 = 2$입니다.',
        hints: [
          r'$(-1)^3 = -1$임을 기억하세요.',
          r'$-1 - 2 \times (-1) + 1 = -1 + 2 + 1$',
        ],
        points: 20,
      ),
      ProblemModel(
        id: 'cm1_rem_3',
        lessonId: 'cm1_1_2_2',
        question: r'$x^2 - 5x + 6 = 0$의 두 근은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: [r'$2, 3$', r'$1, 6$', r'$-2, -3$', r'$-1, 6$'],
        correctAnswer: r'$2, 3$',
        explanation: r'인수분해하면 $(x-2)(x-3) = 0$이므로 $x = 2$ 또는 $x = 3$입니다.',
        hints: [
          '곱해서 6, 더해서 -5가 되는 두 수를 찾으세요.',
          '부호에 주의하세요: -2와 -3의 합은 -5, 곱은 6',
        ],
        points: 20,
      ),
    ];
  }

  static List<ProblemModel> _cm1Factorization() {
    return [
      ProblemModel(
        id: 'cm1_fac_1',
        lessonId: 'cm1_1_3_1',
        question: r'$x^2 + 7x + 12$를 인수분해하세요.',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: [r'$(x+3)(x+4)$', r'$(x+2)(x+6)$', r'$(x+1)(x+12)$', r'$(x+4)(x+4)$'],
        correctAnswer: r'$(x+3)(x+4)$',
        explanation: r'곱해서 12, 더해서 7인 두 수는 3과 4이므로 $(x+3)(x+4)$입니다.',
        hints: [
          '곱해서 12가 되는 두 자연수 쌍을 찾아보세요: (1,12), (2,6), (3,4)',
          '이 중 더해서 7이 되는 쌍은 (3,4)입니다.',
        ],
        points: 15,
      ),
      ProblemModel(
        id: 'cm1_fac_2',
        lessonId: 'cm1_1_3_1',
        question: r'$x^2 - 9$를 인수분해하세요.',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: [r'$(x+3)(x-3)$', r'$(x-9)(x+1)$', r'$(x+3)^2$', r'$(x-3)^2$'],
        correctAnswer: r'$(x+3)(x-3)$',
        explanation: r'$a^2 - b^2 = (a+b)(a-b)$이므로 $x^2 - 9 = (x+3)(x-3)$입니다.',
        hints: [
          r'$9 = 3^2$이므로 $x^2 - 3^2$ 형태입니다.',
          r'합차공식 $a^2 - b^2 = (a+b)(a-b)$를 사용하세요.',
        ],
        points: 15,
      ),
      ProblemModel(
        id: 'cm1_fac_3',
        lessonId: 'cm1_1_3_1',
        question: r'$2x^2 + 6x$를 인수분해하세요.',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: [r'$2x(x+3)$', r'$2(x^2+3x)$', r'$x(2x+6)$', r'$6x(x+1)$'],
        correctAnswer: r'$2x(x+3)$',
        explanation: r'공통인수 $2x$를 뽑으면 $2x(x + 3)$입니다.',
        hints: [
          '두 항에서 공통으로 들어있는 인수를 찾아보세요.',
          r'$2x^2$와 $6x$ 모두 $2x$를 포함하고 있어요.',
        ],
        points: 10,
      ),
      ProblemModel(
        id: 'cm1_fac_4',
        lessonId: 'cm1_1_3_1',
        question: r'$x^2 - 6x + 9$를 인수분해하세요.',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: [r'$(x-3)^2$', r'$(x+3)^2$', r'$(x-3)(x+3)$', r'$(x-9)(x-1)$'],
        correctAnswer: r'$(x-3)^2$',
        explanation: r'$x^2 - 6x + 9 = x^2 - 2 \cdot 3 \cdot x + 3^2 = (x-3)^2$입니다.',
        hints: [
          r'$9 = 3^2$이고 $6 = 2 \times 3$임을 확인하세요.',
          r'완전제곱식 $(a-b)^2 = a^2 - 2ab + b^2$에 해당합니다.',
        ],
        points: 20,
      ),
    ];
  }

  // ============================================================
  // 공통수학2 - 집합과 명제
  // ============================================================

  static List<ProblemModel> _cm2SetBasics() {
    return [
      ProblemModel(
        id: 'cm2_set_1',
        lessonId: 'lesson_set_1',
        question: r'$A = \{1, 2, 3, 4, 5\}$일 때, $n(A)$의 값은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: ['3', '4', '5', '6'],
        correctAnswer: '5',
        explanation: r'$n(A)$는 집합 A의 원소의 개수입니다. A에는 1, 2, 3, 4, 5로 5개의 원소가 있습니다.',
        hints: [
          r'$n(A)$는 집합 A의 원소의 수를 나타내요.',
          '중괄호 안의 원소를 세어보세요.',
        ],
        points: 10,
      ),
      ProblemModel(
        id: 'cm2_set_2',
        lessonId: 'lesson_set_1',
        question: r'다음 중 집합 $\{x | x$는 10 이하의 짝수$\}$의 원소가 아닌 것은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: ['2', '6', '9', '10'],
        correctAnswer: '9',
        explanation: '10 이하의 짝수는 {2, 4, 6, 8, 10}이므로 9는 홀수라 원소가 아닙니다.',
        hints: [
          '짝수는 2로 나누어떨어지는 수예요.',
          '각 보기가 짝수인지 확인해보세요.',
        ],
        points: 10,
      ),
      ProblemModel(
        id: 'cm2_set_3',
        lessonId: 'lesson_set_1',
        question: r'$A = \{1, 2\}$의 부분집합의 개수는?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: ['2', '3', '4', '5'],
        correctAnswer: '4',
        explanation: r'원소가 n개인 집합의 부분집합의 수는 $2^n$개입니다. $2^2 = 4$개: $\emptyset, \{1\}, \{2\}, \{1,2\}$',
        hints: [
          r'부분집합의 수 = $2^{원소의\ 개수}$',
          '공집합도 부분집합에 포함됩니다.',
        ],
        points: 15,
      ),
      ProblemModel(
        id: 'cm2_set_4',
        lessonId: 'lesson_set_1',
        question: r'$\{1, 2, 3\} \subset \{1, 2, 3, 4\}$는 참인가요?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: ['참', '거짓'],
        correctAnswer: '참',
        explanation: r'$\{1, 2, 3\}$의 모든 원소가 $\{1, 2, 3, 4\}$에 포함되므로 부분집합입니다.',
        hints: ['왼쪽 집합의 모든 원소가 오른쪽 집합에 들어있는지 확인하세요.'],
        points: 10,
      ),
    ];
  }

  static List<ProblemModel> _cm2SetOperations() {
    return [
      ProblemModel(
        id: 'cm2_op_1',
        lessonId: 'lesson_set_2',
        question: r'$A = \{1, 2, 3\}$, $B = \{2, 3, 4\}$일 때 $A \cup B$는?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: [r'$\{1, 2, 3, 4\}$', r'$\{2, 3\}$', r'$\{1, 4\}$', r'$\{1, 2, 3\}$'],
        correctAnswer: r'$\{1, 2, 3, 4\}$',
        explanation: r'합집합 $A \cup B$는 A 또는 B에 속하는 모든 원소의 집합입니다.',
        hints: [
          '합집합은 두 집합의 원소를 모두 모은 것이에요.',
          '중복 원소는 한 번만 적어요.',
        ],
        points: 15,
      ),
      ProblemModel(
        id: 'cm2_op_2',
        lessonId: 'lesson_set_2',
        question: r'$A = \{1, 2, 3, 4\}$, $B = \{3, 4, 5\}$일 때 $A \cap B$는?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: [r'$\{3, 4\}$', r'$\{1, 2, 5\}$', r'$\{1, 2, 3, 4, 5\}$', r'$\{3\}$'],
        correctAnswer: r'$\{3, 4\}$',
        explanation: r'교집합 $A \cap B$는 A와 B 모두에 속하는 원소의 집합입니다.',
        hints: ['두 집합에 공통으로 들어있는 원소를 찾으세요.'],
        points: 15,
      ),
      ProblemModel(
        id: 'cm2_op_3',
        lessonId: 'lesson_set_2',
        question: r'$A = \{1, 2, 3, 4\}$, $B = \{2, 4\}$일 때 $A - B$는?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: [r'$\{1, 3\}$', r'$\{2, 4\}$', r'$\{1, 2, 3\}$', r'$\emptyset$'],
        correctAnswer: r'$\{1, 3\}$',
        explanation: r'차집합 $A - B$는 A에는 속하지만 B에는 속하지 않는 원소의 집합입니다.',
        hints: [
          'A에서 B에 있는 원소를 빼면 됩니다.',
          'A에서 2와 4를 빼면 1과 3이 남아요.',
        ],
        points: 20,
      ),
      ProblemModel(
        id: 'cm2_op_4',
        lessonId: 'lesson_set_2',
        question: r'$n(A) = 10$, $n(B) = 7$, $n(A \cap B) = 3$일 때 $n(A \cup B)$는?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: ['12', '13', '14', '17'],
        correctAnswer: '14',
        explanation: r'$n(A \cup B) = n(A) + n(B) - n(A \cap B) = 10 + 7 - 3 = 14$입니다.',
        hints: [
          r'합집합의 원소 수 공식: $n(A \cup B) = n(A) + n(B) - n(A \cap B)$',
          '교집합이 중복 계산되므로 한 번 빼줘야 해요.',
        ],
        points: 20,
      ),
    ];
  }

  static List<ProblemModel> _cm2SetLaws() {
    return [
      ProblemModel(
        id: 'cm2_law_1',
        lessonId: 'lesson_set_3',
        question: r'드모르간 법칙에 의해 $(A \cup B)^c$은 무엇과 같은가요?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: [r'$A^c \cap B^c$', r'$A^c \cup B^c$', r'$(A \cap B)^c$', r'$A \cup B^c$'],
        correctAnswer: r'$A^c \cap B^c$',
        explanation: r'드모르간 법칙: $(A \cup B)^c = A^c \cap B^c$입니다. 합집합의 여집합은 각 여집합의 교집합입니다.',
        hints: [
          '드모르간 법칙에서 합집합의 여집합을 떠올려보세요.',
          '합(∪)은 교(∩)로 바뀝니다.',
        ],
        points: 20,
      ),
      ProblemModel(
        id: 'cm2_law_2',
        lessonId: 'lesson_set_3',
        question: r'$A \cap (B \cup C) = ?$',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.hard,
        options: [
          r'$(A \cap B) \cup (A \cap C)$',
          r'$(A \cup B) \cap (A \cup C)$',
          r'$A \cap B \cap C$',
          r'$(A \cap B) \cup C$',
        ],
        correctAnswer: r'$(A \cap B) \cup (A \cap C)$',
        explanation: '교집합에 대한 분배법칙입니다. 교집합을 합집합 안으로 분배할 수 있습니다.',
        hints: [
          '분배법칙을 떠올려보세요: 교집합이 합집합 위로 분배됩니다.',
        ],
        points: 25,
      ),
      ProblemModel(
        id: 'cm2_law_3',
        lessonId: 'lesson_set_3',
        question: r'$(A^c)^c$은 무엇과 같은가요?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: [r'$A$', r'$A^c$', r'$U$', r'$\emptyset$'],
        correctAnswer: r'$A$',
        explanation: r'여집합의 여집합은 원래 집합으로 돌아옵니다. $(A^c)^c = A$',
        hints: ['여집합을 두 번 취하면 원래 집합이 됩니다.'],
        points: 10,
      ),
    ];
  }

  static List<ProblemModel> _cm2Proposition() {
    return [
      ProblemModel(
        id: 'cm2_prop_1',
        lessonId: 'lesson_set_4',
        question: '다음 중 명제인 것은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: ['수학은 재미있다', '3은 홀수이다', 'x + 1 = 3', '공부하세요'],
        correctAnswer: '3은 홀수이다',
        explanation: '명제는 참 또는 거짓을 분명히 판별할 수 있는 문장입니다. "3은 홀수이다"는 참인 명제입니다.',
        hints: [
          '명제란 참/거짓을 판단할 수 있는 문장이에요.',
          '"수학은 재미있다"는 사람마다 다르고, "공부하세요"는 명령문이에요.',
        ],
        points: 10,
      ),
      ProblemModel(
        id: 'cm2_prop_2',
        lessonId: 'lesson_set_4',
        question: '"x가 4의 배수이면 x는 2의 배수이다"의 진위는?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: ['참', '거짓'],
        correctAnswer: '참',
        explanation: '4의 배수는 항상 2의 배수입니다. 4 = 2×2이므로 4의 배수는 2로도 나누어 떨어집니다.',
        hints: ['4의 배수 예시: 4, 8, 12, 16... 이것들이 모두 2의 배수인지 확인해보세요.'],
        points: 15,
      ),
      ProblemModel(
        id: 'cm2_prop_3',
        lessonId: 'lesson_set_4',
        question: '"p이면 q이다"의 대우는?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: ['"~q이면 ~p이다"', '"q이면 p이다"', '"~p이면 ~q이다"', '"~q이면 p이다"'],
        correctAnswer: '"~q이면 ~p이다"',
        explanation: '대우는 가정과 결론을 바꾸고 각각 부정한 것입니다. p→q의 대우는 ~q→~p',
        hints: [
          '대우: 가정과 결론을 바꾸고, 각각 부정하기',
          '역: 바꾸기만, 이: 부정만, 대우: 바꾸고 부정',
        ],
        points: 20,
      ),
      ProblemModel(
        id: 'cm2_prop_4',
        lessonId: 'lesson_set_4',
        question: '명제와 그 대우의 진위 관계는?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: ['항상 같다', '항상 다르다', '관계없다', '때에 따라 다르다'],
        correctAnswer: '항상 같다',
        explanation: '명제가 참이면 대우도 참이고, 명제가 거짓이면 대우도 거짓입니다. 이것을 대우의 성질이라 합니다.',
        hints: ['명제의 대우는 원래 명제와 같은 진리값을 가져요.'],
        points: 15,
      ),
    ];
  }

  // ============================================================
  // 수학I - 지수와 로그
  // ============================================================

  static List<ProblemModel> _math1Exponent() {
    return [
      ProblemModel(
        id: 'm1_exp_1',
        lessonId: 'lesson_exp_1',
        question: r'$2^3 \times 2^4$의 값은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: ['64', '128', '256', '512'],
        correctAnswer: '128',
        explanation: r'같은 밑의 곱은 지수를 더합니다: $2^3 \times 2^4 = 2^{3+4} = 2^7 = 128$',
        hints: [
          r'$a^m \times a^n = a^{m+n}$',
          r'$2^7 = 128$',
        ],
        points: 15,
      ),
      ProblemModel(
        id: 'm1_exp_2',
        lessonId: 'lesson_exp_1',
        question: r'$\sqrt[3]{8}$의 값은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: ['2', '3', '4', '8'],
        correctAnswer: '2',
        explanation: r'$\sqrt[3]{8} = 8^{1/3} = (2^3)^{1/3} = 2$입니다. 즉, 세제곱해서 8이 되는 수는 2입니다.',
        hints: [
          '세제곱근은 세제곱해서 그 수가 되는 값이에요.',
          r'$2^3 = 8$이므로 $\sqrt[3]{8} = 2$',
        ],
        points: 15,
      ),
      ProblemModel(
        id: 'm1_exp_3',
        lessonId: 'lesson_exp_1',
        question: r'$(3^2)^3$의 값은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: ['243', '512', '729', '81'],
        correctAnswer: '729',
        explanation: r'거듭제곱의 거듭제곱은 지수를 곱합니다: $(3^2)^3 = 3^{2 \times 3} = 3^6 = 729$',
        hints: [
          r'$(a^m)^n = a^{mn}$',
          r'$3^6$을 계산해보세요: $729$',
        ],
        points: 20,
      ),
      ProblemModel(
        id: 'm1_exp_4',
        lessonId: 'lesson_exp_1',
        question: r'$5^0$의 값은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: ['0', '1', '5', '없음'],
        correctAnswer: '1',
        explanation: r'0이 아닌 모든 수의 0승은 1입니다. $a^0 = 1$ (단, $a \neq 0$)',
        hints: ['0이 아닌 수의 0제곱은 항상 1이에요.'],
        points: 10,
      ),
    ];
  }

  static List<ProblemModel> _math1ExponentExtended() {
    return [
      ProblemModel(
        id: 'm1_expx_1',
        lessonId: 'lesson_exp_2',
        question: r'$8^{2/3}$의 값은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: ['2', '4', '8', '16'],
        correctAnswer: '4',
        explanation: r'$8^{2/3} = (8^{1/3})^2 = 2^2 = 4$입니다. 먼저 세제곱근을 구한 뒤 제곱합니다.',
        hints: [
          r'$a^{m/n} = (\sqrt[n]{a})^m$으로 변환하세요.',
          r'$8^{1/3} = 2$이므로 $2^2 = 4$',
        ],
        points: 20,
      ),
      ProblemModel(
        id: 'm1_expx_2',
        lessonId: 'lesson_exp_2',
        question: r'$4^{-1/2}$의 값은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: [r'$\frac{1}{2}$', r'$-2$', r'$2$', r'$\frac{1}{4}$'],
        correctAnswer: r'$\frac{1}{2}$',
        explanation: r'$4^{-1/2} = \frac{1}{4^{1/2}} = \frac{1}{\sqrt{4}} = \frac{1}{2}$입니다.',
        hints: [
          '음수 지수는 역수를 의미해요.',
          r'$4^{1/2} = \sqrt{4} = 2$이므로 역수는 $\frac{1}{2}$',
        ],
        points: 20,
      ),
      ProblemModel(
        id: 'm1_expx_3',
        lessonId: 'lesson_exp_2',
        question: r'$27^{1/3} \times 9^{1/2}$의 값은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.hard,
        options: ['6', '9', '12', '18'],
        correctAnswer: '9',
        explanation: r'$27^{1/3} = 3$, $9^{1/2} = 3$이므로 $3 \times 3 = 9$입니다.',
        hints: [
          '각각 따로 계산하세요.',
          r'$27 = 3^3$이므로 $27^{1/3} = 3$, $9 = 3^2$이므로 $9^{1/2} = 3$',
        ],
        points: 25,
      ),
    ];
  }

  static List<ProblemModel> _math1Logarithm() {
    return [
      ProblemModel(
        id: 'm1_log_1',
        lessonId: 'lesson_exp_4',
        question: r'$\log_2 8$의 값은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: ['2', '3', '4', '8'],
        correctAnswer: '3',
        explanation: r'$\log_2 8 = 3$입니다. 왜냐하면 $2^3 = 8$이기 때문입니다.',
        hints: [
          r'$\log_a b = c$는 $a^c = b$와 같은 뜻이에요.',
          r'2를 몇 번 곱해야 8이 될까요? $2 \times 2 \times 2 = 8$, 즉 3번!',
        ],
        points: 15,
      ),
      ProblemModel(
        id: 'm1_log_2',
        lessonId: 'lesson_exp_4',
        question: r'$\log_{10} 100$의 값은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: ['1', '2', '10', '100'],
        correctAnswer: '2',
        explanation: r'$\log_{10} 100 = 2$입니다. $10^2 = 100$이기 때문입니다. 이것을 상용로그라고 합니다.',
        hints: [
          '10을 몇 제곱하면 100이 될까요?',
          r'$10^2 = 100$이므로 답은 2입니다.',
        ],
        points: 15,
      ),
      ProblemModel(
        id: 'm1_log_3',
        lessonId: 'lesson_exp_4',
        question: r'$\log_3 27 + \log_3 9$의 값은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: ['3', '4', '5', '6'],
        correctAnswer: '5',
        explanation: r'$\log_3 27 = 3$ ($3^3 = 27$), $\log_3 9 = 2$ ($3^2 = 9$)이므로 $3 + 2 = 5$입니다.',
        hints: [
          '각 로그 값을 따로 계산하세요.',
          r'$3^3 = 27$이므로 $\log_3 27 = 3$',
          r'$3^2 = 9$이므로 $\log_3 9 = 2$',
        ],
        points: 20,
      ),
      ProblemModel(
        id: 'm1_log_4',
        lessonId: 'lesson_exp_4',
        question: r'$\log_2 16 - \log_2 4$의 값은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: ['1', '2', '3', '4'],
        correctAnswer: '2',
        explanation: r'$\log_2 16 = 4$, $\log_2 4 = 2$이므로 $4 - 2 = 2$입니다. 또는 로그 법칙으로 $\log_2 \frac{16}{4} = \log_2 4 = 2$입니다.',
        hints: [
          '각각 계산하거나 로그 성질을 사용하세요.',
          r'$\log_a m - \log_a n = \log_a \frac{m}{n}$',
        ],
        points: 20,
      ),
      ProblemModel(
        id: 'm1_log_5',
        lessonId: 'lesson_exp_4',
        question: r'$\log_5 1$의 값은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: ['0', '1', '5', '없음'],
        correctAnswer: '0',
        explanation: r'$\log_a 1 = 0$입니다. 어떤 양수 a라도 $a^0 = 1$이기 때문입니다.',
        hints: [
          '5를 몇 제곱하면 1이 될까요?',
          r'$a^0 = 1$이므로 $\log_a 1 = 0$',
        ],
        points: 10,
      ),
    ];
  }

  // ============================================================
  // 기본 문제 (커리큘럼에 맞는 문제가 없을 때)
  // ============================================================

  /// 정식 문제가 아직 매핑되지 않은 lesson 의 임시 placeholder.
  /// 사용자가 학습 흐름에서 막히지 않도록 '테스트 문제' 라고 명시 + 통과 가능한
  /// 단순 답안 1개를 제공한다.
  static List<ProblemModel> _defaultProblems(String lessonId) {
    return [
      ProblemModel(
        id: 'test_$lessonId',
        lessonId: lessonId,
        question: '🧪 테스트 문제\n\n이 레슨의 정식 문제는 준비 중입니다. '
            '아래 "확인" 을 눌러 다음으로 진행하세요.',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: ['확인'],
        correctAnswer: '확인',
        explanation: '테스트 문제입니다. 곧 정식 학습 콘텐츠가 추가됩니다.',
        points: 0,
      ),
    ];
  }
}
