// 전학년 placeholder 레슨 채우기 — 진척도 100% 달성용 문제 세트.
//
// cm1 외 모든 placeholder lesson 에 대해 lesson 당 2문제 (easy + medium).
// 정답·해설·힌트 포함. LaTeX 수식은 raw string r'$...$'.
//
// 학년·과목 그룹별로 정리:
//  - 초등 기초수학 (bm_)
//  - 중학 중학수학 (ms_)
//  - 고1 공통수학2 (lesson_set_, lesson_func_, lesson_geo_)
//  - 고2 수학I (lesson_exp_, lesson_trig_, lesson_seq_)
//  - 고2 수학II (lesson_lim_, lesson_diff_, lesson_integ_)
//  - 고3 확률과통계 (lesson_perm_, lesson_prob_, lesson_stat_)
//  - 고3 미적분 (lesson_seqlim_, lesson_adiff_, lesson_ainteg_)
//  - 고3 기하 (lesson_conic_, lesson_vec_, lesson_space_)

import 'problem_model.dart';

class AllSubjectsProblems {
  AllSubjectsProblems._();

  // 빠른 ProblemModel 생성 헬퍼 — 반복 코드 제거.
  static ProblemModel _q({
    required String id,
    required String lessonId,
    required String question,
    required List<String> options,
    required String correctAnswer,
    required String explanation,
    required List<String> hints,
    required ProblemDifficulty difficulty,
    int points = 10,
  }) =>
      ProblemModel(
        id: id,
        lessonId: lessonId,
        question: question,
        type: ProblemType.multipleChoice,
        difficulty: difficulty,
        options: options,
        correctAnswer: correctAnswer,
        explanation: explanation,
        hints: hints,
        points: points,
      );

  // ============================================================
  // 초등 — 기초수학
  // ============================================================

  static List<ProblemModel> bmDiv1() => [
        _q(
          id: 'bm_div_1_1',
          lessonId: 'bm_div_1',
          question: r'$12 \div 4 = ?$',
          options: ['2', '3', '4', '5'],
          correctAnswer: '3',
          explanation: r'$4 \times 3 = 12$ 이므로 $12 \div 4 = 3$.',
          hints: ['4의 단을 외워보세요.', r'$4 \times \square = 12$ 의 □.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'bm_div_1_2',
          lessonId: 'bm_div_1',
          question: r'$25 \div 7$ 의 몫과 나머지는?',
          options: ['몫 3, 나머지 4', '몫 4, 나머지 3', '몫 3, 나머지 5', '몫 2, 나머지 11'],
          correctAnswer: '몫 3, 나머지 4',
          explanation: r'$7 \times 3 = 21, 25 - 21 = 4$. 몫 3, 나머지 4.',
          hints: ['7 곱하기 몇 = 25 이하로 가장 큰 수?', '21 까지가 가능. 25 - 21 = 4.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  static List<ProblemModel> bmFrac1() => [
        _q(
          id: 'bm_frac_1_1',
          lessonId: 'bm_frac_1',
          question: r'$\dfrac{3}{5}$ 에서 분자는?',
          options: ['3', '5', '8', '2'],
          correctAnswer: '3',
          explanation: '분수에서 위의 수가 분자, 아래의 수가 분모. 분자 = 3.',
          hints: ['위쪽 숫자.', '분자·분모를 잘 구분.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'bm_frac_1_2',
          lessonId: 'bm_frac_1',
          question: r'전체 8조각 중 3조각을 분수로 나타내면?',
          options: [r'$\dfrac{8}{3}$', r'$\dfrac{3}{8}$', r'$\dfrac{3}{11}$', r'$\dfrac{5}{8}$'],
          correctAnswer: r'$\dfrac{3}{8}$',
          explanation: '전체가 분모, 부분이 분자. 8조각 중 3 → 3/8.',
          hints: ['전체 = 분모.', '부분 = 분자.'],
          difficulty: ProblemDifficulty.easy,
        ),
      ];

  static List<ProblemModel> bmFrac2() => [
        _q(
          id: 'bm_frac_2_1',
          lessonId: 'bm_frac_2',
          question: r'$\dfrac{1}{4} + \dfrac{2}{4} = ?$',
          options: [r'$\dfrac{1}{4}$', r'$\dfrac{3}{4}$', r'$\dfrac{2}{8}$', r'$\dfrac{3}{8}$'],
          correctAnswer: r'$\dfrac{3}{4}$',
          explanation: '같은 분모 분수의 덧셈은 분자끼리 더한다. 1+2 = 3.',
          hints: ['분모가 같으면 분자만 계산.', r'$1+2=3$.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'bm_frac_2_2',
          lessonId: 'bm_frac_2',
          question: r'$\dfrac{5}{6} - \dfrac{2}{6} = ?$',
          options: [r'$\dfrac{3}{12}$', r'$\dfrac{3}{6}$', r'$\dfrac{7}{6}$', r'$\dfrac{3}{0}$'],
          correctAnswer: r'$\dfrac{3}{6}$',
          explanation: '같은 분모끼리 빼기. 5-2=3, 분모 유지.',
          hints: ['분모는 그대로.', '분자만 5-2.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  static List<ProblemModel> bmDec1() => [
        _q(
          id: 'bm_dec_1_1',
          lessonId: 'bm_dec_1',
          question: r'$0.5$ 를 분수로 나타내면?',
          options: [r'$\dfrac{1}{5}$', r'$\dfrac{1}{2}$', r'$\dfrac{5}{1}$', r'$\dfrac{1}{10}$'],
          correctAnswer: r'$\dfrac{1}{2}$',
          explanation: r'$0.5 = \dfrac{5}{10} = \dfrac{1}{2}$.',
          hints: ['소수점 첫째자리 = 10분의.', r'$\dfrac{5}{10}$ 약분.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'bm_dec_1_2',
          lessonId: 'bm_dec_1',
          question: r'$2.34$ 에서 소수 둘째자리 숫자는?',
          options: ['2', '3', '4', '0'],
          correctAnswer: '4',
          explanation: '소수점 이후 첫째자리=3 (10분의), 둘째자리=4 (100분의).',
          hints: ['소수점 오른쪽 둘째.', r'$0.04$ 의 자리.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  // ============================================================
  // 중학 — 중학수학
  // ============================================================

  static List<ProblemModel> msInt1() => [
        _q(
          id: 'ms_int_1_1',
          lessonId: 'ms_int_1',
          question: r'$(-3) + (+7) = ?$',
          options: ['-10', '-4', '4', '10'],
          correctAnswer: '4',
          explanation: r'부호가 다른 두 정수의 합: 큰 절댓값에서 작은 절댓값 빼고 큰 쪽 부호. $7-3=4$, 양수.',
          hints: ['절댓값 비교.', '큰 쪽 부호로.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'ms_int_1_2',
          lessonId: 'ms_int_1',
          question: r'$(-2) \times (-5) = ?$',
          options: ['-10', '-7', '7', '10'],
          correctAnswer: '10',
          explanation: '음수×음수=양수. 2×5=10, 부호는 양수.',
          hints: ['음수 두 개 곱은 양수.', r'$2 \times 5$ 의 절댓값.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  static List<ProblemModel> msInt2() => [
        _q(
          id: 'ms_int_2_1',
          lessonId: 'ms_int_2',
          question: r'$\dfrac{1}{2} + \dfrac{1}{3} = ?$',
          options: [r'$\dfrac{1}{5}$', r'$\dfrac{2}{5}$', r'$\dfrac{5}{6}$', r'$\dfrac{2}{6}$'],
          correctAnswer: r'$\dfrac{5}{6}$',
          explanation: r'통분: $\dfrac{3}{6} + \dfrac{2}{6} = \dfrac{5}{6}$.',
          hints: ['분모를 같게 — 최소공배수 6.', r'$\dfrac{3}{6} + \dfrac{2}{6}$.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'ms_int_2_2',
          lessonId: 'ms_int_2',
          question: r'$0.25 \times \dfrac{4}{5} = ?$',
          options: ['0.1', '0.2', '0.5', '1.0'],
          correctAnswer: '0.2',
          explanation: r'$0.25 = \dfrac{1}{4}$. $\dfrac{1}{4} \times \dfrac{4}{5} = \dfrac{1}{5} = 0.2$.',
          hints: ['0.25 = 1/4.', '1/4 × 4/5 = 1/5.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  static List<ProblemModel> msLinear1() => [
        _q(
          id: 'ms_linear_1_1',
          lessonId: 'ms_linear_1',
          question: r'$2x + 3 = 11$ 의 해는?',
          options: ['x=2', 'x=3', 'x=4', 'x=5'],
          correctAnswer: 'x=4',
          explanation: r'$2x = 8 \Rightarrow x = 4$.',
          hints: ['상수항을 우변으로.', '계수로 나누기.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'ms_linear_1_2',
          lessonId: 'ms_linear_1',
          question: r'$3(x-2) = x + 4$ 의 해는?',
          options: ['x=2', 'x=3', 'x=5', 'x=7'],
          correctAnswer: 'x=5',
          explanation: r'전개: $3x-6 = x+4 \Rightarrow 2x=10 \Rightarrow x=5$.',
          hints: ['괄호 전개.', 'x항·상수항 정리.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  static List<ProblemModel> msLinear2() => [
        _q(
          id: 'ms_linear_2_1',
          lessonId: 'ms_linear_2',
          question: r'$\begin{cases} x+y=5 \\ x-y=1 \end{cases}$ 의 해 $(x,y)$ 는?',
          options: ['(2,3)', '(3,2)', '(4,1)', '(1,4)'],
          correctAnswer: '(3,2)',
          explanation: '가감법: 더하면 2x=6, x=3. y=2.',
          hints: ['두 식을 더하면 y 가 소거.', '2x=6.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
        _q(
          id: 'ms_linear_2_2',
          lessonId: 'ms_linear_2',
          question: r'$\begin{cases} 2x + y = 7 \\ x - y = 2 \end{cases}$ 의 해는?',
          options: ['(1,5)', '(2,3)', '(3,1)', '(4,-1)'],
          correctAnswer: '(3,1)',
          explanation: '가감법: 더하면 3x=9, x=3. 대입: y=1.',
          hints: ['두 식 더하기 → y 소거.', '3x=9.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  static List<ProblemModel> msFunc1() => [
        _q(
          id: 'ms_func_1_1',
          lessonId: 'ms_func_1',
          question: r'$y = 2x + 1$ 의 기울기는?',
          options: ['0', '1', '2', '-1'],
          correctAnswer: '2',
          explanation: r'$y = ax + b$ 에서 a 가 기울기. a=2.',
          hints: ['ax+b 형태의 a.', 'x 의 계수.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'ms_func_1_2',
          lessonId: 'ms_func_1',
          question: r'$y = -3x + 6$ 의 $x$ 절편은?',
          options: ['6', '-2', '2', '-6'],
          correctAnswer: '2',
          explanation: r'$y=0$ 대입: $-3x+6=0 \Rightarrow x=2$.',
          hints: ['x 절편은 y=0 일 때.', r'$-3x = -6$.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  static List<ProblemModel> msFunc2() => [
        _q(
          id: 'ms_func_2_1',
          lessonId: 'ms_func_2',
          question: r'$y = 2x^2$ 의 꼭짓점 좌표는?',
          options: ['(0,0)', '(0,2)', '(2,0)', '(1,2)'],
          correctAnswer: '(0,0)',
          explanation: r'$y=ax^2$ 의 꼭짓점은 원점 $(0,0)$.',
          hints: ['ax² 형태.', '원점 통과.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'ms_func_2_2',
          lessonId: 'ms_func_2',
          question: r'$y = -x^2$ 그래프는 위·아래 어느 방향으로 열리나?',
          options: ['위', '아래', '왼쪽', '오른쪽'],
          correctAnswer: '아래',
          explanation: r'$y = ax^2$ 에서 $a < 0$ 이면 아래로 열린다.',
          hints: ['a 의 부호.', 'a<0 → 아래로.'],
          difficulty: ProblemDifficulty.easy,
        ),
      ];

  // ============================================================
  // 고1 — 공통수학 2 (기존 4 lesson 외 15 lesson)
  // ============================================================

  static List<ProblemModel> lessonSet5() => [
        _q(
          id: 'lesson_set_5_1',
          lessonId: 'lesson_set_5',
          question: r'명제 "p → q" 의 역은?',
          options: ['p → q', 'q → p', '~p → ~q', '~q → ~p'],
          correctAnswer: 'q → p',
          explanation: '역: 가정·결론을 바꿈. p→q 의 역은 q→p.',
          hints: ['역 = 화살표 뒤집기.', '가정·결론 교환.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_set_5_2',
          lessonId: 'lesson_set_5',
          question: r'명제 "p → q" 의 대우는?',
          options: ['q → p', '~p → ~q', '~q → ~p', 'p ∧ q'],
          correctAnswer: '~q → ~p',
          explanation: '대우: 부정 + 역. p→q 의 대우는 ~q→~p. 원명제와 진리값 같음.',
          hints: ['대우 = 역의 부정.', '항상 원 명제와 같은 진리값.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  static List<ProblemModel> lessonSet6() => [
        _q(
          id: 'lesson_set_6_1',
          lessonId: 'lesson_set_6',
          question: r'$A = \{1,2,3\}, B = \{2,3,4\}$ 일 때 $A \cup B$ 는?',
          options: [
            r'$\{2,3\}$',
            r'$\{1,2,3,4\}$',
            r'$\{1,4\}$',
            r'$\{1,2,3\}$',
          ],
          correctAnswer: r'$\{1,2,3,4\}$',
          explanation: '합집합은 두 집합의 모든 원소를 중복 없이 모음.',
          hints: ['∪ = 합집합.', '중복 제거.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_set_6_2',
          lessonId: 'lesson_set_6',
          question: r'명제 "모든 자연수는 2의 배수이다" 의 부정은?',
          options: [
            '어떤 자연수도 2의 배수가 아니다',
            '모든 자연수는 2의 배수가 아니다',
            '어떤 자연수는 2의 배수가 아니다',
            '2 만 자연수이다',
          ],
          correctAnswer: '어떤 자연수는 2의 배수가 아니다',
          explanation: '"모든 x 가 P" 의 부정은 "어떤 x 는 ~P".',
          hints: ['전칭 → 존재 부정.', '모든의 부정 = 어떤 ~.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  static List<ProblemModel> lessonFunc1() => [
        _q(
          id: 'lesson_func_1_1',
          lessonId: 'lesson_func_1',
          question: r'함수 $f(x) = 2x+1$ 일 때 $f(3)$ 의 값은?',
          options: ['5', '6', '7', '8'],
          correctAnswer: '7',
          explanation: r'$f(3) = 2 \cdot 3 + 1 = 7$.',
          hints: ['x 자리에 3 대입.', r'$2 \cdot 3 + 1$.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_func_1_2',
          lessonId: 'lesson_func_1',
          question: r'$f(x) = x^2 - 1$ 일 때 $f(-2)$ 의 값은?',
          options: ['-3', '0', '3', '5'],
          correctAnswer: '3',
          explanation: r'$f(-2) = (-2)^2 - 1 = 4-1 = 3$.',
          hints: ['음수 제곱은 양수.', r'$(-2)^2 = 4$.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  static List<ProblemModel> lessonFunc2() => [
        _q(
          id: 'lesson_func_2_1',
          lessonId: 'lesson_func_2',
          question:
              r'$f(x) = 2x, g(x) = x+1$ 일 때 $(g \circ f)(2)$ 의 값은?',
          options: ['3', '4', '5', '6'],
          correctAnswer: '5',
          explanation: r'$f(2)=4$, $g(4)=5$.',
          hints: ['먼저 f, 다음 g.', r'$g(f(2))$.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
        _q(
          id: 'lesson_func_2_2',
          lessonId: 'lesson_func_2',
          question: r'$f(x) = 3x-2$ 의 역함수 $f^{-1}(x)$ 는?',
          options: [
            r'$\dfrac{x+2}{3}$',
            r'$\dfrac{x-2}{3}$',
            r'$3x+2$',
            r'$\dfrac{1}{3x-2}$',
          ],
          correctAnswer: r'$\dfrac{x+2}{3}$',
          explanation: r'$y=3x-2$ 에서 $x = \dfrac{y+2}{3}$. x·y 교환.',
          hints: ['y 에 대해 x 표현.', '그 후 x·y 교환.'],
          difficulty: ProblemDifficulty.hard,
          points: 20,
        ),
      ];

  static List<ProblemModel> lessonFunc3() => [
        _q(
          id: 'lesson_func_3_1',
          lessonId: 'lesson_func_3',
          question: r'$y = \dfrac{1}{x}$ 의 정의역은?',
          options: [
            r'모든 실수',
            r'$x \neq 0$ 인 실수',
            r'$x > 0$ 인 실수',
            r'$x \geq 0$ 인 실수',
          ],
          correctAnswer: r'$x \neq 0$ 인 실수',
          explanation: '유리함수는 분모≠0. 따라서 x≠0.',
          hints: ['분모가 0 이면 정의 안 됨.', 'x=0 제외.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_func_3_2',
          lessonId: 'lesson_func_3',
          question: r'$y = \dfrac{2}{x-1}$ 의 점근선 중 수직 점근선의 식은?',
          options: ['x=0', 'x=1', 'x=2', 'x=-1'],
          correctAnswer: 'x=1',
          explanation: '분모 = 0 인 x: x-1=0, x=1.',
          hints: ['수직 점근선 = 분모 0 되는 x.', 'x-1=0.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  static List<ProblemModel> lessonFunc4() => [
        _q(
          id: 'lesson_func_4_1',
          lessonId: 'lesson_func_4',
          question: r'$y = \sqrt{x}$ 의 정의역은?',
          options: [
            r'모든 실수',
            r'$x \geq 0$',
            r'$x > 0$',
            r'$x \neq 0$',
          ],
          correctAnswer: r'$x \geq 0$',
          explanation: '실수 범위 제곱근은 음수 안에서 정의 안 됨.',
          hints: ['근호 안은 0 이상.', 'x ≥ 0.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_func_4_2',
          lessonId: 'lesson_func_4',
          question: r'$y = \sqrt{x-3}$ 의 정의역은?',
          options: [
            r'$x \geq 3$',
            r'$x > 3$',
            r'$x \leq 3$',
            r'$x \geq -3$',
          ],
          correctAnswer: r'$x \geq 3$',
          explanation: r'근호 안 $\geq 0 \Rightarrow x-3 \geq 0 \Rightarrow x \geq 3$.',
          hints: ['근호 안이 0 이상.', 'x-3 ≥ 0.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  static List<ProblemModel> lessonFunc5() => [
        _q(
          id: 'lesson_func_5_1',
          lessonId: 'lesson_func_5',
          question: r'$f(x) = x+2$ 의 $f(0) + f(1) + f(2)$ 의 값은?',
          options: ['6', '7', '8', '9'],
          correctAnswer: '9',
          explanation: r'$f(0)+f(1)+f(2) = 2+3+4 = 9$.',
          hints: ['각각 대입.', '2,3,4 합.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_func_5_2',
          lessonId: 'lesson_func_5',
          question: r'$f(x) = 2x, g(x) = x-3$ 일 때 $f(g(5))$ 의 값은?',
          options: ['2', '4', '6', '8'],
          correctAnswer: '4',
          explanation: r'$g(5)=2$, $f(2)=4$.',
          hints: ['내부 먼저: g(5).', r'$f(2)$.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  static List<ProblemModel> lessonFunc6() => [
        _q(
          id: 'lesson_func_6_1',
          lessonId: 'lesson_func_6',
          question:
              r'두 함수 $f, g$ 가 서로 역함수 관계이면 $f(g(x))$ 는?',
          options: ['1', '0', 'x', 'x+1'],
          correctAnswer: 'x',
          explanation: '역함수 관계의 합성은 항등함수. f(g(x))=x.',
          hints: ['역함수의 정의.', '서로 되돌림.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
        _q(
          id: 'lesson_func_6_2',
          lessonId: 'lesson_func_6',
          question:
              r'함수 $f(x) = \dfrac{1}{x-2}$ 의 점근선 두 개는 $x=a, y=b$ 일 때 $a+b$ 의 값은?',
          options: ['0', '1', '2', '3'],
          correctAnswer: '2',
          explanation: r'수직 점근선 $x=2$, 수평 점근선 $y=0$. $a+b=2$.',
          hints: ['분모 0: x=2.', '분자 상수, 분모 일차 → y=0.'],
          difficulty: ProblemDifficulty.hard,
          points: 20,
        ),
      ];

  static List<ProblemModel> lessonGeo1() => [
        _q(
          id: 'lesson_geo_1_1',
          lessonId: 'lesson_geo_1',
          question: r'두 점 $A(1, 2), B(4, 6)$ 사이의 거리는?',
          options: ['3', '4', '5', '6'],
          correctAnswer: '5',
          explanation: r'$\sqrt{(4-1)^2+(6-2)^2} = \sqrt{9+16} = \sqrt{25} = 5$.',
          hints: ['거리 공식.', r'$\sqrt{3^2+4^2}$.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_geo_1_2',
          lessonId: 'lesson_geo_1',
          question: r'$A(0,0), B(6,8)$ 의 중점 좌표는?',
          options: ['(3,4)', '(6,8)', '(3,8)', '(6,4)'],
          correctAnswer: '(3,4)',
          explanation: '중점: 좌표 평균. ((0+6)/2, (0+8)/2) = (3,4).',
          hints: ['좌표 평균.', '두 점 각 평균.'],
          difficulty: ProblemDifficulty.easy,
        ),
      ];

  static List<ProblemModel> lessonGeo2() => [
        _q(
          id: 'lesson_geo_2_1',
          lessonId: 'lesson_geo_2',
          question: r'기울기가 2 이고 점 $(1, 3)$ 을 지나는 직선의 방정식은?',
          options: [
            r'$y = 2x + 1$',
            r'$y = 2x - 1$',
            r'$y = 2x + 3$',
            r'$y = 2x + 5$',
          ],
          correctAnswer: r'$y = 2x + 1$',
          explanation: r'$y - 3 = 2(x-1) \Rightarrow y = 2x+1$.',
          hints: ['점-기울기 형태.', r'$y - y_1 = m(x-x_1)$.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
        _q(
          id: 'lesson_geo_2_2',
          lessonId: 'lesson_geo_2',
          question: r'두 점 $(0,1), (2,5)$ 를 지나는 직선의 기울기는?',
          options: ['1', '2', '3', '4'],
          correctAnswer: '2',
          explanation: r'기울기 $= \dfrac{5-1}{2-0} = 2$.',
          hints: ['y 변화량 / x 변화량.', '(5-1)/(2-0).'],
          difficulty: ProblemDifficulty.easy,
        ),
      ];

  static List<ProblemModel> lessonGeo3() => [
        _q(
          id: 'lesson_geo_3_1',
          lessonId: 'lesson_geo_3',
          question: r'점 $(0,0)$ 에서 직선 $3x + 4y - 5 = 0$ 까지의 거리는?',
          options: ['0', '1', '2', '3'],
          correctAnswer: '1',
          explanation:
              r'거리 $= \dfrac{|3\cdot 0+4\cdot 0-5|}{\sqrt{9+16}} = \dfrac{5}{5} = 1$.',
          hints: ['점·직선 거리 공식.', r'$\dfrac{|ax_0+by_0+c|}{\sqrt{a^2+b^2}}$.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
        _q(
          id: 'lesson_geo_3_2',
          lessonId: 'lesson_geo_3',
          question:
              r'점 $(1,2)$ 에서 직선 $y = x$ (즉 $x-y=0$) 까지의 거리는?',
          options: [
            r'$\dfrac{1}{\sqrt{2}}$',
            r'$\dfrac{\sqrt{2}}{2}$',
            r'$\sqrt{2}$',
            r'1',
          ],
          correctAnswer: r'$\dfrac{\sqrt{2}}{2}$',
          explanation:
              r'$\dfrac{|1-2|}{\sqrt{1+1}} = \dfrac{1}{\sqrt{2}} = \dfrac{\sqrt{2}}{2}$.',
          hints: ['x-y=0 형태.', '분모 √2.'],
          difficulty: ProblemDifficulty.hard,
          points: 20,
        ),
      ];

  static List<ProblemModel> lessonGeo4() => [
        _q(
          id: 'lesson_geo_4_1',
          lessonId: 'lesson_geo_4',
          question: r'중심 $(0,0)$, 반지름 3 인 원의 방정식은?',
          options: [
            r'$x^2 + y^2 = 3$',
            r'$x^2 + y^2 = 9$',
            r'$(x-3)^2 + y^2 = 0$',
            r'$x + y = 3$',
          ],
          correctAnswer: r'$x^2 + y^2 = 9$',
          explanation: r'표준형 $x^2+y^2 = r^2$ 에서 $r=3 \Rightarrow r^2=9$.',
          hints: ['중심 원점.', '반지름 제곱.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_geo_4_2',
          lessonId: 'lesson_geo_4',
          question: r'$(x-1)^2 + (y+2)^2 = 16$ 의 중심과 반지름은?',
          options: [
            '중심 (1,-2), 반지름 4',
            '중심 (-1,2), 반지름 16',
            '중심 (1,2), 반지름 4',
            '중심 (-1,-2), 반지름 16',
          ],
          correctAnswer: '중심 (1,-2), 반지름 4',
          explanation: r'표준형 $(x-a)^2+(y-b)^2=r^2$. a=1, b=-2, r=4.',
          hints: ['표준형 부호 주의.', 'r² = 16 → r = 4.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  static List<ProblemModel> lessonGeo5() => [
        _q(
          id: 'lesson_geo_5_1',
          lessonId: 'lesson_geo_5',
          question:
              r'중심 $(0,0)$, 반지름 5 인 원과 직선 $y=3$ 이 만나는 점의 개수는?',
          options: ['0', '1', '2', '3'],
          correctAnswer: '2',
          explanation: r'중심·직선 거리 $=3 < 5=r$. 두 점에서 만남.',
          hints: ['중심에서 직선까지 거리.', '거리 < 반지름 → 2점.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
        _q(
          id: 'lesson_geo_5_2',
          lessonId: 'lesson_geo_5',
          question:
              r'원 $x^2+y^2=4$ 와 직선 $y=2$ 의 관계는?',
          options: ['두 점 만남', '한 점에서 접함', '만나지 않음', '직선이 지나가지 않음'],
          correctAnswer: '한 점에서 접함',
          explanation: r'중심 (0,0) 에서 $y=2$ 까지 거리 $=2$, 반지름 $=2$. 거리=반지름 → 접함.',
          hints: ['거리 = 반지름 → 접함.', '|2| = √4.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  static List<ProblemModel> lessonGeo6() => [
        _q(
          id: 'lesson_geo_6_1',
          lessonId: 'lesson_geo_6',
          question:
              r'점 $(3, 4)$ 를 $x$ 축의 방향으로 $2$, $y$ 축의 방향으로 $-1$ 평행이동한 점은?',
          options: ['(5,3)', '(1,5)', '(5,5)', '(1,3)'],
          correctAnswer: '(5,3)',
          explanation: r'$(3+2, 4-1) = (5,3)$.',
          hints: ['x 에 +2.', 'y 에 -1.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_geo_6_2',
          lessonId: 'lesson_geo_6',
          question: r'점 $(2, 5)$ 를 $x$ 축에 대해 대칭이동한 점의 좌표는?',
          options: ['(2,-5)', '(-2,5)', '(-2,-5)', '(5,2)'],
          correctAnswer: '(2,-5)',
          explanation: 'x 축 대칭: y 부호만 바뀜.',
          hints: ['x 축 대칭 → y 부호 변경.', 'x 는 그대로.'],
          difficulty: ProblemDifficulty.easy,
        ),
      ];

  static List<ProblemModel> lessonGeo7() => [
        _q(
          id: 'lesson_geo_7_1',
          lessonId: 'lesson_geo_7',
          question:
              r'두 점 $A(-1, 0), B(3, 0)$ 을 지름의 양 끝점으로 하는 원의 방정식은?',
          options: [
            r'$(x-1)^2 + y^2 = 4$',
            r'$(x+1)^2 + y^2 = 4$',
            r'$x^2 + y^2 = 4$',
            r'$(x-1)^2 + y^2 = 16$',
          ],
          correctAnswer: r'$(x-1)^2 + y^2 = 4$',
          explanation: r'중점 $(1,0)$ 이 중심. 반지름 $= \dfrac{1}{2}|AB| = 2$.',
          hints: ['지름의 중점이 원의 중심.', '반지름 = 거리/2.'],
          difficulty: ProblemDifficulty.hard,
          points: 20,
        ),
        _q(
          id: 'lesson_geo_7_2',
          lessonId: 'lesson_geo_7',
          question:
              r'직선 $y = x$ 에 대한 점 $(2, 0)$ 의 대칭점은?',
          options: ['(0,2)', '(2,2)', '(-2,0)', '(0,-2)'],
          correctAnswer: '(0,2)',
          explanation: 'y=x 대칭은 x·y 좌표 교환.',
          hints: ['y=x 대칭 = 좌표 교환.', '(a,b) → (b,a).'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  // ============================================================
  // 고2 — 수학 1
  // ============================================================

  static List<ProblemModel> lessonExp3() => [
        _q(
          id: 'lesson_exp_3_1',
          lessonId: 'lesson_exp_3',
          question: r'함수 $y = 2^x$ 의 $y$ 절편은?',
          options: ['0', '1', '2', 'e'],
          correctAnswer: '1',
          explanation: r'$x=0$ 대입: $2^0 = 1$.',
          hints: ['x=0 대입.', '0제곱 = 1.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_exp_3_2',
          lessonId: 'lesson_exp_3',
          question:
              r'$y = 2^x$ 와 $y = \left(\dfrac{1}{2}\right)^x$ 의 그래프 관계는?',
          options: [
            'x 축에 대해 대칭',
            'y 축에 대해 대칭',
            '원점 대칭',
            '같은 그래프',
          ],
          correctAnswer: 'y 축에 대해 대칭',
          explanation: r'$(1/2)^x = 2^{-x}$ — x → -x 변환은 y 축 대칭.',
          hints: ['(1/2)^x = 2^(-x).', 'x 부호 반전 = y축 대칭.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  static List<ProblemModel> lessonExp5() => [
        _q(
          id: 'lesson_exp_5_1',
          lessonId: 'lesson_exp_5',
          question: r'$y = \log_2 x$ 의 $x$ 절편은?',
          options: ['0', '1', '2', 'e'],
          correctAnswer: '1',
          explanation: r'$\log_2 1 = 0$, 즉 (1,0).',
          hints: ['log_2 1 = ?', '0 되는 x.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_exp_5_2',
          lessonId: 'lesson_exp_5',
          question: r'$y = \log_2 x$ 의 정의역은?',
          options: [
            '모든 실수',
            r'$x > 0$',
            r'$x \geq 0$',
            r'$x \neq 0$',
          ],
          correctAnswer: r'$x > 0$',
          explanation: '로그함수 진수 조건: x > 0.',
          hints: ['로그 진수 > 0.', '음수·0 안 됨.'],
          difficulty: ProblemDifficulty.easy,
        ),
      ];

  static List<ProblemModel> lessonExp6() => [
        _q(
          id: 'lesson_exp_6_1',
          lessonId: 'lesson_exp_6',
          question: r'$\log_2 8 + \log_2 4$ 의 값은?',
          options: ['3', '4', '5', '6'],
          correctAnswer: '5',
          explanation: r'$\log_2 8 = 3, \log_2 4 = 2 \Rightarrow 5$.',
          hints: ['각각 계산: 8=2³, 4=2².', '3+2.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
        _q(
          id: 'lesson_exp_6_2',
          lessonId: 'lesson_exp_6',
          question: r'$2^x = 16$ 일 때 $x$ 의 값은?',
          options: ['2', '3', '4', '5'],
          correctAnswer: '4',
          explanation: r'$16 = 2^4$ 이므로 $x = 4$.',
          hints: ['16 을 2의 거듭제곱으로.', '2^? = 16.'],
          difficulty: ProblemDifficulty.easy,
        ),
      ];

  static List<ProblemModel> lessonExp7() => [
        _q(
          id: 'lesson_exp_7_1',
          lessonId: 'lesson_exp_7',
          question: r'$\log_{10} 100$ 의 값은?',
          options: ['1', '2', '10', '100'],
          correctAnswer: '2',
          explanation: r'$10^2 = 100 \Rightarrow \log_{10} 100 = 2$.',
          hints: ['100 = 10^?.', '지수가 답.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_exp_7_2',
          lessonId: 'lesson_exp_7',
          question: r'$3^{x+1} = 27$ 일 때 $x$ 의 값은?',
          options: ['0', '1', '2', '3'],
          correctAnswer: '2',
          explanation: r'$27 = 3^3 \Rightarrow x+1 = 3 \Rightarrow x = 2$.',
          hints: ['27 = 3^3.', 'x+1 = 3.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  static List<ProblemModel> lessonTrig1() => [
        _q(
          id: 'lesson_trig_1_1',
          lessonId: 'lesson_trig_1',
          question: r'$90°$ 를 호도법으로 나타내면?',
          options: [
            r'$\dfrac{\pi}{4}$',
            r'$\dfrac{\pi}{3}$',
            r'$\dfrac{\pi}{2}$',
            r'$\pi$',
          ],
          correctAnswer: r'$\dfrac{\pi}{2}$',
          explanation: r'$180° = \pi$ 이므로 $90° = \dfrac{\pi}{2}$.',
          hints: ['180° = π.', '비례식.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_trig_1_2',
          lessonId: 'lesson_trig_1',
          question: r'$\dfrac{\pi}{3}$ 를 도수법으로 나타내면?',
          options: ['30°', '45°', '60°', '90°'],
          correctAnswer: '60°',
          explanation: r'$\pi = 180°$ 이므로 $\dfrac{\pi}{3} = 60°$.',
          hints: ['π → 180°.', '180/3.'],
          difficulty: ProblemDifficulty.easy,
        ),
      ];

  static List<ProblemModel> lessonTrig2() => [
        _q(
          id: 'lesson_trig_2_1',
          lessonId: 'lesson_trig_2',
          question: r'$\sin 30°$ 의 값은?',
          options: [r'$\dfrac{1}{2}$', r'$\dfrac{\sqrt{2}}{2}$', r'$\dfrac{\sqrt{3}}{2}$', '1'],
          correctAnswer: r'$\dfrac{1}{2}$',
          explanation: r'특수각: $\sin 30° = \dfrac{1}{2}$.',
          hints: ['특수각 표.', '30°·45°·60° 외우기.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_trig_2_2',
          lessonId: 'lesson_trig_2',
          question: r'$\cos 60°$ 의 값은?',
          options: [r'$\dfrac{1}{2}$', r'$\dfrac{\sqrt{2}}{2}$', r'$\dfrac{\sqrt{3}}{2}$', '1'],
          correctAnswer: r'$\dfrac{1}{2}$',
          explanation: r'$\cos 60° = \dfrac{1}{2}$.',
          hints: ['cos 60° = sin 30°.', '1/2.'],
          difficulty: ProblemDifficulty.easy,
        ),
      ];

  static List<ProblemModel> lessonTrig3() => [
        _q(
          id: 'lesson_trig_3_1',
          lessonId: 'lesson_trig_3',
          question: r'$y = \sin x$ 의 주기는?',
          options: [r'$\pi$', r'$2\pi$', r'$\dfrac{\pi}{2}$', '1'],
          correctAnswer: r'$2\pi$',
          explanation: r'$\sin x$ 는 $2\pi$ 마다 반복.',
          hints: ['삼각함수 기본 주기.', '한 바퀴 = 2π.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_trig_3_2',
          lessonId: 'lesson_trig_3',
          question: r'$y = 2\sin x$ 의 최댓값은?',
          options: ['1', '2', '3', '4'],
          correctAnswer: '2',
          explanation: r'$\sin x$ 최댓값 1, 진폭 2배 → 최댓값 2.',
          hints: ['sin x 최댓값 1.', '계수 2.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  static List<ProblemModel> lessonTrig4() => [
        _q(
          id: 'lesson_trig_4_1',
          lessonId: 'lesson_trig_4',
          question: r'$\sin^2 x + \cos^2 x$ 의 값은?',
          options: ['0', r'$\dfrac{1}{2}$', '1', '2'],
          correctAnswer: '1',
          explanation: '삼각함수 기본 항등식.',
          hints: ['피타고라스 항등식.', 'sin²+cos²=1.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_trig_4_2',
          lessonId: 'lesson_trig_4',
          question:
              r'$\sin x = \dfrac{3}{5}$ 이고 $x$ 가 1사분면일 때 $\cos x$ 의 값은?',
          options: [
            r'$\dfrac{4}{5}$',
            r'$-\dfrac{4}{5}$',
            r'$\dfrac{3}{5}$',
            r'$\dfrac{5}{4}$',
          ],
          correctAnswer: r'$\dfrac{4}{5}$',
          explanation:
              r'$\cos^2 x = 1 - \dfrac{9}{25} = \dfrac{16}{25} \Rightarrow \cos x = \dfrac{4}{5}$ (양수).',
          hints: ['sin²+cos²=1.', '1사분면 → cos 양수.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  static List<ProblemModel> lessonTrig5() => [
        _q(
          id: 'lesson_trig_5_1',
          lessonId: 'lesson_trig_5',
          question:
              r'삼각형의 두 변 $a=3, b=4$ 의 사잇각이 $60°$ 일 때 다른 변 $c$ 의 길이는?',
          options: [r'$\sqrt{7}$', r'$\sqrt{13}$', '5', '6'],
          correctAnswer: r'$\sqrt{13}$',
          explanation:
              r'코사인법칙: $c^2 = a^2+b^2-2ab\cos C = 9+16-12 = 13 \Rightarrow c = \sqrt{13}$.',
          hints: ['코사인법칙.', r'$c^2 = a^2+b^2-2ab\cos C$.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
        _q(
          id: 'lesson_trig_5_2',
          lessonId: 'lesson_trig_5',
          question:
              r'삼각형에서 $\dfrac{a}{\sin A} = ?$ (외접원 반지름 R)',
          options: ['R', '2R', r'$\dfrac{R}{2}$', '4R'],
          correctAnswer: '2R',
          explanation: '사인법칙.',
          hints: ['사인법칙.', '2R 형태.'],
          difficulty: ProblemDifficulty.easy,
        ),
      ];

  static List<ProblemModel> lessonTrig6() => [
        _q(
          id: 'lesson_trig_6_1',
          lessonId: 'lesson_trig_6',
          question: r'$\sin(\pi - x) = ?$',
          options: [r'$\sin x$', r'$-\sin x$', r'$\cos x$', r'$-\cos x$'],
          correctAnswer: r'$\sin x$',
          explanation: r'보각 공식: $\sin(\pi - x) = \sin x$.',
          hints: ['보각 공식.', 'π-x 변환.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
        _q(
          id: 'lesson_trig_6_2',
          lessonId: 'lesson_trig_6',
          question: r'$\cos(-x) = ?$',
          options: [r'$\cos x$', r'$-\cos x$', r'$\sin x$', r'$-\sin x$'],
          correctAnswer: r'$\cos x$',
          explanation: 'cos 는 우함수 — cos(-x) = cos x.',
          hints: ['우함수 vs 기함수.', 'cos 는 우함수.'],
          difficulty: ProblemDifficulty.easy,
        ),
      ];

  static List<ProblemModel> lessonSeq1() => [
        _q(
          id: 'lesson_seq_1_1',
          lessonId: 'lesson_seq_1',
          question: r'첫째항 2, 공차 3 인 등차수열의 제5항은?',
          options: ['11', '12', '14', '15'],
          correctAnswer: '14',
          explanation: r'$a_5 = a_1 + 4d = 2 + 12 = 14$.',
          hints: [r'$a_n = a_1 + (n-1)d$.', '2 + 4·3.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_seq_1_2',
          lessonId: 'lesson_seq_1',
          question: r'등차수열 $3, 7, 11, \cdots$ 의 공차는?',
          options: ['2', '3', '4', '5'],
          correctAnswer: '4',
          explanation: '두 항의 차이.',
          hints: ['뒤 - 앞.', '7-3.'],
          difficulty: ProblemDifficulty.easy,
        ),
      ];

  static List<ProblemModel> lessonSeq2() => [
        _q(
          id: 'lesson_seq_2_1',
          lessonId: 'lesson_seq_2',
          question:
              r'첫째항 1, 공차 2 인 등차수열의 처음 10 항의 합은?',
          options: ['90', '100', '110', '120'],
          correctAnswer: '100',
          explanation:
              r'$S_n = \dfrac{n(2a_1+(n-1)d)}{2} = \dfrac{10(2+18)}{2} = 100$.',
          hints: [r'$S_n$ 공식.', '10·(2+18)/2.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
        _q(
          id: 'lesson_seq_2_2',
          lessonId: 'lesson_seq_2',
          question: r'$1+2+3+\cdots+100$ 의 값은?',
          options: ['4950', '5000', '5050', '5100'],
          correctAnswer: '5050',
          explanation: r'$\dfrac{n(n+1)}{2} = \dfrac{100 \cdot 101}{2} = 5050$.',
          hints: ['1부터 n까지 합 공식.', 'n(n+1)/2.'],
          difficulty: ProblemDifficulty.easy,
        ),
      ];

  static List<ProblemModel> lessonSeq3() => [
        _q(
          id: 'lesson_seq_3_1',
          lessonId: 'lesson_seq_3',
          question: r'첫째항 3, 공비 2 인 등비수열의 제4항은?',
          options: ['12', '18', '24', '30'],
          correctAnswer: '24',
          explanation: r'$a_4 = 3 \cdot 2^3 = 24$.',
          hints: [r'$a_n = a_1 r^{n-1}$.', '3·2³.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_seq_3_2',
          lessonId: 'lesson_seq_3',
          question: r'등비수열 $2, 6, 18, \cdots$ 의 공비는?',
          options: ['2', '3', '4', '6'],
          correctAnswer: '3',
          explanation: '뒤/앞 비율.',
          hints: ['후항/전항.', '6/2.'],
          difficulty: ProblemDifficulty.easy,
        ),
      ];

  static List<ProblemModel> lessonSeq4() => [
        _q(
          id: 'lesson_seq_4_1',
          lessonId: 'lesson_seq_4',
          question:
              r'첫째항 1, 공비 2 인 등비수열의 처음 5 항의 합은?',
          options: ['15', '21', '31', '63'],
          correctAnswer: '31',
          explanation:
              r'$S_n = \dfrac{a_1(r^n-1)}{r-1} = \dfrac{1\cdot 31}{1} = 31$.',
          hints: ['등비수열 합 공식.', '2^5 - 1 = 31.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
        _q(
          id: 'lesson_seq_4_2',
          lessonId: 'lesson_seq_4',
          question: r'$2 + 4 + 8 + 16 + 32 = ?$',
          options: ['58', '60', '62', '64'],
          correctAnswer: '62',
          explanation: r'$2(2^5-1)/(2-1) = 2 \cdot 31 = 62$.',
          hints: ['공비 2.', '2(2^5-1).'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  static List<ProblemModel> lessonSeq5() => [
        _q(
          id: 'lesson_seq_5_1',
          lessonId: 'lesson_seq_5',
          question: r'$\sum_{k=1}^{5} k$ 의 값은?',
          options: ['10', '15', '20', '25'],
          correctAnswer: '15',
          explanation: r'$1+2+3+4+5 = 15$.',
          hints: ['k=1부터 5까지 더하기.', '5·6/2.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_seq_5_2',
          lessonId: 'lesson_seq_5',
          question: r'$\sum_{k=1}^{n} 1$ 의 값은?',
          options: ['0', '1', 'n', 'n+1'],
          correctAnswer: 'n',
          explanation: '1 을 n 번 더하면 n.',
          hints: ['상수 합.', '항의 개수.'],
          difficulty: ProblemDifficulty.easy,
        ),
      ];

  static List<ProblemModel> lessonSeq6() => [
        _q(
          id: 'lesson_seq_6_1',
          lessonId: 'lesson_seq_6',
          question: r'수학적 귀납법의 두 단계 중 첫째 단계는?',
          options: [
            'P(1) 이 참임을 보임',
            'P(k) → P(k+1) 을 보임',
            'P(n) 가정',
            'P(0) 정의',
          ],
          correctAnswer: 'P(1) 이 참임을 보임',
          explanation: '첫째 단계 = 기초단계 (base case).',
          hints: ['귀납법 단계.', '시작점 검증.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_seq_6_2',
          lessonId: 'lesson_seq_6',
          question:
              r'$1+2+\cdots+n = \dfrac{n(n+1)}{2}$ 를 증명할 때 P(1) 의 좌우변은?',
          options: ['1, 1', '0, 0', '1, 0', '2, 1'],
          correctAnswer: '1, 1',
          explanation: r'좌변=1, 우변=$\dfrac{1\cdot 2}{2}=1$.',
          hints: ['n=1 대입.', '1·2/2.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  static List<ProblemModel> lessonSeq7() => [
        _q(
          id: 'lesson_seq_7_1',
          lessonId: 'lesson_seq_7',
          question:
              r'점화식 $a_{n+1} = a_n + 3, a_1 = 2$ 를 만족하는 수열의 $a_4$ 는?',
          options: ['8', '11', '14', '17'],
          correctAnswer: '11',
          explanation:
              r'$a_2=5, a_3=8, a_4=11$. 또는 공차 3 등차수열: $2+3(n-1)$.',
          hints: ['공차 3 등차수열.', 'a_n = 2+3(n-1).'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
        _q(
          id: 'lesson_seq_7_2',
          lessonId: 'lesson_seq_7',
          question: r'$\sum_{k=1}^{10} (2k+1) = ?$',
          options: ['100', '110', '120', '130'],
          correctAnswer: '120',
          explanation:
              r'$2\sum k + \sum 1 = 2\cdot 55 + 10 = 120$.',
          hints: ['시그마 분배.', '2·(1+...+10) + 10.'],
          difficulty: ProblemDifficulty.hard,
          points: 20,
        ),
      ];

  // ============================================================
  // 고2 — 수학 2
  // ============================================================

  static List<ProblemModel> lessonLim1() => [
        _q(
          id: 'lesson_lim_1_1',
          lessonId: 'lesson_lim_1',
          question: r'$\lim_{x \to 2} (x+3)$ 의 값은?',
          options: ['3', '4', '5', '6'],
          correctAnswer: '5',
          explanation: '연속함수는 직접 대입. 2+3=5.',
          hints: ['직접 대입.', '2+3.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_lim_1_2',
          lessonId: 'lesson_lim_1',
          question: r'$\lim_{x \to 1} \dfrac{x^2-1}{x-1}$ 의 값은?',
          options: ['0', '1', '2', '정의 안 됨'],
          correctAnswer: '2',
          explanation: r'$\dfrac{(x-1)(x+1)}{x-1} = x+1 \to 2$.',
          hints: ['분자 인수분해.', '(x+1) 로 단순화.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  static List<ProblemModel> lessonLim2() => [
        _q(
          id: 'lesson_lim_2_1',
          lessonId: 'lesson_lim_2',
          question: r'$\lim_{x \to \infty} \dfrac{1}{x}$ 의 값은?',
          options: ['0', '1', '∞', '-1'],
          correctAnswer: '0',
          explanation: 'x 가 무한대로 가면 1/x 은 0 으로 수렴.',
          hints: ['x 가 커지면 1/x 작아짐.', '분모 무한대.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_lim_2_2',
          lessonId: 'lesson_lim_2',
          question: r'$\lim_{x \to \infty} \dfrac{2x+1}{x-3}$ 의 값은?',
          options: ['0', '1', '2', '∞'],
          correctAnswer: '2',
          explanation: 'x 의 최고차항만 비교: 2x/x = 2.',
          hints: ['최고차항 비교.', '계수 비율.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  static List<ProblemModel> lessonLim3() => [
        _q(
          id: 'lesson_lim_3_1',
          lessonId: 'lesson_lim_3',
          question: r'함수 $f$ 가 $x=a$ 에서 연속이려면? (필요충분)',
          options: [
            r'$f(a)$ 정의',
            r'$\lim_{x\to a} f(x) = f(a)$',
            r'$\lim_{x\to a} f(x)$ 존재',
            r'$f$ 가 다항함수',
          ],
          correctAnswer: r'$\lim_{x\to a} f(x) = f(a)$',
          explanation: '연속 정의: 함숫값과 극한값이 같음.',
          hints: ['연속 정의 3가지.', '극한값 = 함숫값.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
        _q(
          id: 'lesson_lim_3_2',
          lessonId: 'lesson_lim_3',
          question:
              r'$f(x) = \begin{cases} x+1, & x < 1 \\ 2x, & x \geq 1 \end{cases}$ 는 $x=1$ 에서 연속인가?',
          options: ['예', '아니오', '판단 불가', 'x=1 에서 정의 안 됨'],
          correctAnswer: '예',
          explanation: '좌극한 = 1+1 = 2, 우극한 = 2·1 = 2, f(1)=2 — 모두 같으므로 연속.',
          hints: ['양쪽 극한 비교.', 'f(1) 도 확인.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  static List<ProblemModel> lessonLim4() => [
        _q(
          id: 'lesson_lim_4_1',
          lessonId: 'lesson_lim_4',
          question:
              r'$f(x) = x^2$ 는 $[-1, 2]$ 에서 최댓값과 최솟값을 갖는가?',
          options: ['둘 다 갖는다', '최댓값만', '최솟값만', '둘 다 없다'],
          correctAnswer: '둘 다 갖는다',
          explanation: '연속함수는 닫힌구간에서 최대·최소 존재 (최대최소정리).',
          hints: ['연속함수 정리.', '닫힌 구간 → 둘 다.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_lim_4_2',
          lessonId: 'lesson_lim_4',
          question:
              r'사잇값정리: $f$ 가 $[a,b]$ 에서 연속이고 $f(a)<k<f(b)$ 이면 $f(c)=k$ 인 $c$ 는?',
          options: ['반드시 존재', '존재 안 함', '여러 개 존재', '판단 불가'],
          correctAnswer: '반드시 존재',
          explanation: '사잇값 정리: 연속 + 양 끝 값 사이 → c 존재.',
          hints: ['사잇값 정리.', 'IVT.'],
          difficulty: ProblemDifficulty.easy,
        ),
      ];

  static List<ProblemModel> lessonLim5() => [
        _q(
          id: 'lesson_lim_5_1',
          lessonId: 'lesson_lim_5',
          question: r'$\lim_{x \to 0} \dfrac{\sin x}{x}$ 의 값은?',
          options: ['0', r'$\dfrac{1}{2}$', '1', r'$\infty$'],
          correctAnswer: '1',
          explanation: '유명한 극한: 1.',
          hints: ['삼각함수 기본 극한.', 'sin x / x → 1.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
        _q(
          id: 'lesson_lim_5_2',
          lessonId: 'lesson_lim_5',
          question:
              r'$\lim_{x \to 3} \dfrac{x^2 - 9}{x - 3}$ 의 값은?',
          options: ['0', '3', '6', '9'],
          correctAnswer: '6',
          explanation: r'$\dfrac{(x-3)(x+3)}{x-3} = x+3 \to 6$.',
          hints: ['인수분해.', 'x+3 에 3 대입.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  static List<ProblemModel> lessonDiff1() => [
        _q(
          id: 'lesson_diff_1_1',
          lessonId: 'lesson_diff_1',
          question: r'$f(x) = x^2$ 의 $x=1$ 에서의 미분계수는?',
          options: ['1', '2', '3', '4'],
          correctAnswer: '2',
          explanation: r"$f'(x) = 2x$, $f'(1)=2$.",
          hints: ["f'(x) = 2x.", 'x=1 대입.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_diff_1_2',
          lessonId: 'lesson_diff_1',
          question:
              r"미분계수의 정의: $f'(a) = \lim_{h \to 0} \dfrac{f(a+h)-f(a)}{?}$",
          options: ['a', 'h', '1', 'a+h'],
          correctAnswer: 'h',
          explanation: '미분계수 정의식의 분모는 h.',
          hints: ['미분계수 정의.', '변화량 / h.'],
          difficulty: ProblemDifficulty.easy,
        ),
      ];

  static List<ProblemModel> lessonDiff2() => [
        _q(
          id: 'lesson_diff_2_1',
          lessonId: 'lesson_diff_2',
          question: r'$f(x) = 3x^2 + 2x$ 의 도함수는?',
          options: [r'$6x+2$', r'$6x$', r'$3x+2$', r'$3x^2+2$'],
          correctAnswer: r'$6x+2$',
          explanation: r"$\dfrac{d}{dx}(3x^2) = 6x$, $\dfrac{d}{dx}(2x) = 2$.",
          hints: ['거듭제곱 미분.', '상수배·합 미분.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_diff_2_2',
          lessonId: 'lesson_diff_2',
          question: r'$f(x) = x^3$ 의 $x=2$ 에서 도함수 값은?',
          options: ['6', '8', '10', '12'],
          correctAnswer: '12',
          explanation: r"$f'(x) = 3x^2$, $f'(2)=12$.",
          hints: ["f'(x)=3x².", '3·4.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  static List<ProblemModel> lessonDiff3() => [
        _q(
          id: 'lesson_diff_3_1',
          lessonId: 'lesson_diff_3',
          question:
              r'$f(x)=x^2$ 의 점 $(1,1)$ 에서 접선의 기울기는?',
          options: ['1', '2', '3', '4'],
          correctAnswer: '2',
          explanation: r"$f'(x)=2x, f'(1)=2$. 접선 기울기.",
          hints: ['접선 기울기 = f′(a).', "f'(1)."],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_diff_3_2',
          lessonId: 'lesson_diff_3',
          question:
              r'$y = x^2 + 1$ 의 $x=2$ 에서 접선의 방정식은?',
          options: [
            r'$y = 4x - 3$',
            r'$y = 4x + 1$',
            r'$y = 2x + 3$',
            r'$y = 4x + 5$',
          ],
          correctAnswer: r'$y = 4x - 3$',
          explanation:
              r"$f'(2)=4$, 접점 $(2,5)$. $y-5 = 4(x-2) \Rightarrow y = 4x-3$.",
          hints: ['기울기 4, 점 (2,5).', '점-기울기 형태.'],
          difficulty: ProblemDifficulty.hard,
          points: 20,
        ),
      ];

  static List<ProblemModel> lessonDiff4() => [
        _q(
          id: 'lesson_diff_4_1',
          lessonId: 'lesson_diff_4',
          question:
              r"$f'(x) > 0$ 인 구간에서 $f(x)$ 는?",
          options: ['감소', '증가', '일정', '판단 불가'],
          correctAnswer: '증가',
          explanation: '도함수 양수 → 함수 증가.',
          hints: ["f'>0 → 증가.", "f'<0 → 감소."],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_diff_4_2',
          lessonId: 'lesson_diff_4',
          question:
              r"$f(x) = x^2 - 4x$ 가 감소하는 구간은?",
          options: [r'$x < 2$', r'$x > 2$', r'$x < -2$', '모든 실수'],
          correctAnswer: r'$x < 2$',
          explanation: r"$f'(x) = 2x-4 < 0 \Rightarrow x < 2$.",
          hints: ["f'(x) 부호 분석.", '2x-4<0.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  static List<ProblemModel> lessonDiff5() => [
        _q(
          id: 'lesson_diff_5_1',
          lessonId: 'lesson_diff_5',
          question:
              r'$f(x) = x^2 - 2x$ 의 극솟값은?',
          options: ['-2', '-1', '0', '1'],
          correctAnswer: '-1',
          explanation:
              r"$f'(x)=2x-2=0 \Rightarrow x=1$. $f(1) = 1-2 = -1$.",
          hints: ["f'=0 풀이.", 'f(1).'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
        _q(
          id: 'lesson_diff_5_2',
          lessonId: 'lesson_diff_5',
          question:
              r"$f'(a)=0$ 이고 $f''(a)<0$ 이면 $x=a$ 에서?",
          options: ['극대', '극소', '변곡', '판단 불가'],
          correctAnswer: '극대',
          explanation: "이계도함수 음수 → 위로 볼록 → 극대.",
          hints: ["2차 도함수 부호.", "음수 → 위로 볼록."],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  static List<ProblemModel> lessonDiff6() => [
        _q(
          id: 'lesson_diff_6_1',
          lessonId: 'lesson_diff_6',
          question:
              r'$f(x) = x^2$ 의 $[-1, 2]$ 에서 최솟값은?',
          options: ['-1', '0', '1', '4'],
          correctAnswer: '0',
          explanation:
              r"$f'(x)=2x=0 \Rightarrow x=0 \in [-1,2]$. $f(0)=0$. 양 끝 비교: $f(-1)=1, f(2)=4$. 최소 0.",
          hints: ['임계점 + 끝점 비교.', '0, 1, 4 중 최소.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
        _q(
          id: 'lesson_diff_6_2',
          lessonId: 'lesson_diff_6',
          question:
              r'$f(x) = -x^2+4x$ 의 최댓값은?',
          options: ['2', '3', '4', '5'],
          correctAnswer: '4',
          explanation: r'$f(x) = -(x-2)^2 + 4$. 최대 4 (x=2).',
          hints: ['완전제곱.', '꼭짓점 좌표.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  static List<ProblemModel> lessonDiff7() => [
        _q(
          id: 'lesson_diff_7_1',
          lessonId: 'lesson_diff_7',
          question:
              r'$f(x) = x^3 - 3x$ 의 극댓값과 극솟값의 차는?',
          options: ['2', '4', '6', '8'],
          correctAnswer: '4',
          explanation:
              r"$f'(x)=3x^2-3=0 \Rightarrow x=\pm 1$. $f(1)=-2$ (극소), $f(-1)=2$ (극대). 차 = 4.",
          hints: ["f' = 0: x = ±1.", 'f(-1) - f(1).'],
          difficulty: ProblemDifficulty.hard,
          points: 20,
        ),
        _q(
          id: 'lesson_diff_7_2',
          lessonId: 'lesson_diff_7',
          question:
              r"$y=x^3$ 그래프에서 $x=0$ 의 접선의 기울기는?",
          options: ['0', '1', '2', '3'],
          correctAnswer: '0',
          explanation: r"$y'=3x^2$, $y'(0)=0$.",
          hints: ["y'=3x².", 'x=0 대입.'],
          difficulty: ProblemDifficulty.easy,
        ),
      ];

  static List<ProblemModel> lessonInteg1() => [
        _q(
          id: 'lesson_integ_1_1',
          lessonId: 'lesson_integ_1',
          question: r'$\int 2x \, dx$ 는?',
          options: [r'$x^2$', r'$x^2 + C$', r'$2$', r'$x + C$'],
          correctAnswer: r'$x^2 + C$',
          explanation: '적분상수 C 포함.',
          hints: ['거듭제곱 적분.', '상수 C 잊지 말기.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_integ_1_2',
          lessonId: 'lesson_integ_1',
          question: r'$\int 1 \, dx$ 는?',
          options: [r'$0$', r'$x$', r'$x + C$', r'$1 + C$'],
          correctAnswer: r'$x + C$',
          explanation: '1 의 부정적분은 x + C.',
          hints: ['상수 적분.', 'x + C.'],
          difficulty: ProblemDifficulty.easy,
        ),
      ];

  static List<ProblemModel> lessonInteg2() => [
        _q(
          id: 'lesson_integ_2_1',
          lessonId: 'lesson_integ_2',
          question: r'$\int (3x^2 + 2) \, dx$ 는?',
          options: [
            r'$x^3 + 2x + C$',
            r'$x^3 + 2 + C$',
            r'$3x^3 + 2x + C$',
            r'$x^2 + 2x + C$',
          ],
          correctAnswer: r'$x^3 + 2x + C$',
          explanation: r'$\int 3x^2 dx = x^3$, $\int 2 dx = 2x$.',
          hints: ['항별 적분.', '계수 잘 처리.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
        _q(
          id: 'lesson_integ_2_2',
          lessonId: 'lesson_integ_2',
          question: r'$\int x^3 \, dx$ 는?',
          options: [
            r'$\dfrac{x^4}{4} + C$',
            r'$x^4 + C$',
            r'$4x^4 + C$',
            r'$\dfrac{x^4}{3} + C$',
          ],
          correctAnswer: r'$\dfrac{x^4}{4} + C$',
          explanation: r'$\int x^n dx = \dfrac{x^{n+1}}{n+1} + C$ ($n \neq -1$).',
          hints: ['지수 +1, 나누기.', 'n=3.'],
          difficulty: ProblemDifficulty.easy,
        ),
      ];

  static List<ProblemModel> lessonInteg3() => [
        _q(
          id: 'lesson_integ_3_1',
          lessonId: 'lesson_integ_3',
          question: r'$\int_0^2 2x \, dx$ 는?',
          options: ['2', '4', '6', '8'],
          correctAnswer: '4',
          explanation: r'$[x^2]_0^2 = 4 - 0 = 4$.',
          hints: ['부정적분 후 대입.', '2² - 0².'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_integ_3_2',
          lessonId: 'lesson_integ_3',
          question: r'$\int_0^1 (3x^2) \, dx$ 는?',
          options: ['0', '1', '2', '3'],
          correctAnswer: '1',
          explanation: r'$[x^3]_0^1 = 1$.',
          hints: ['x³ 의 0~1.', '1-0.'],
          difficulty: ProblemDifficulty.easy,
        ),
      ];

  static List<ProblemModel> lessonInteg4() => [
        _q(
          id: 'lesson_integ_4_1',
          lessonId: 'lesson_integ_4',
          question:
              r'$\int_a^b f(x) dx + \int_b^c f(x) dx = ?$',
          options: [
            r'$\int_a^c f(x) dx$',
            r'$0$',
            r'$\int_a^b f(x) dx$',
            r'$2 \int_a^c f(x) dx$',
          ],
          correctAnswer: r'$\int_a^c f(x) dx$',
          explanation: '구간 분할 성질.',
          hints: ['구간 잇기.', '구간 분할 정리.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_integ_4_2',
          lessonId: 'lesson_integ_4',
          question: r'$\int_a^a f(x) dx = ?$',
          options: ['0', '1', 'a', 'f(a)'],
          correctAnswer: '0',
          explanation: '구간 길이 0 → 적분값 0.',
          hints: ['구간이 한 점.', '0.'],
          difficulty: ProblemDifficulty.easy,
        ),
      ];

  static List<ProblemModel> lessonInteg5() => [
        _q(
          id: 'lesson_integ_5_1',
          lessonId: 'lesson_integ_5',
          question:
              r'$y = x^2, x$ 축, $x=0, x=2$ 로 둘러싸인 영역의 넓이는?',
          options: [
            r'$\dfrac{4}{3}$',
            r'$\dfrac{8}{3}$',
            '4',
            '8',
          ],
          correctAnswer: r'$\dfrac{8}{3}$',
          explanation: r'$\int_0^2 x^2 dx = \left[\dfrac{x^3}{3}\right]_0^2 = \dfrac{8}{3}$.',
          hints: ['적분으로 넓이.', '0~2 적분.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
        _q(
          id: 'lesson_integ_5_2',
          lessonId: 'lesson_integ_5',
          question:
              r'$y=2x, x$ 축, $x=0, x=3$ 로 둘러싸인 영역의 넓이는?',
          options: ['3', '6', '9', '12'],
          correctAnswer: '9',
          explanation: r'$\int_0^3 2x dx = [x^2]_0^3 = 9$.',
          hints: ['적분 계산.', '삼각형 넓이로도 확인 가능.'],
          difficulty: ProblemDifficulty.easy,
        ),
      ];

  static List<ProblemModel> lessonInteg6() => [
        _q(
          id: 'lesson_integ_6_1',
          lessonId: 'lesson_integ_6',
          question:
              r'$\int_{-1}^{1} (x^3) dx$ 의 값은? (홀함수 성질)',
          options: ['-1', '0', '1', '2'],
          correctAnswer: '0',
          explanation: 'x³ 은 기함수. 대칭구간 적분 = 0.',
          hints: ['홀함수 대칭구간.', '0.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
        _q(
          id: 'lesson_integ_6_2',
          lessonId: 'lesson_integ_6',
          question: r'$\int_0^1 (2x+1) dx$ 는?',
          options: ['1', '2', '3', '4'],
          correctAnswer: '2',
          explanation: r'$[x^2+x]_0^1 = 2$.',
          hints: ['부정적분.', '1+1.'],
          difficulty: ProblemDifficulty.easy,
        ),
      ];

  // ============================================================
  // 고3 — 확률과 통계
  // ============================================================

  static List<ProblemModel> lessonPerm1() => [
        _q(
          id: 'lesson_perm_1_1',
          lessonId: 'lesson_perm_1',
          question: r'서로 다른 6 개에서 4 개를 골라 일렬로 세우는 방법은?',
          options: ['24', '120', '360', '720'],
          correctAnswer: '360',
          explanation: r'${}_6P_4 = 6 \cdot 5 \cdot 4 \cdot 3 = 360$.',
          hints: ['_6P_4.', '6·5·4·3.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
        _q(
          id: 'lesson_perm_1_2',
          lessonId: 'lesson_perm_1',
          question: r'5 명을 원탁에 둘러앉히는 방법의 수는? (원순열)',
          options: ['12', '24', '60', '120'],
          correctAnswer: '24',
          explanation: r'원순열 $(n-1)! = 4! = 24$.',
          hints: ['원순열.', '(n-1)!.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  static List<ProblemModel> lessonPerm2() => [
        _q(
          id: 'lesson_perm_2_1',
          lessonId: 'lesson_perm_2',
          question: r'서로 다른 8 개에서 3 개를 뽑는 방법의 수는?',
          options: ['24', '56', '120', '336'],
          correctAnswer: '56',
          explanation: r'${}_8C_3 = \dfrac{8 \cdot 7 \cdot 6}{6} = 56$.',
          hints: ['_8C_3.', '8·7·6/6.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
        _q(
          id: 'lesson_perm_2_2',
          lessonId: 'lesson_perm_2',
          question: r'$_n C_r = {}_n C_{n-r}$ 인 성질을 무엇이라 하는가?',
          options: ['덧셈정리', '대칭성', '곱셈정리', '파스칼 항등'],
          correctAnswer: '대칭성',
          explanation: '뽑는 것과 안 뽑는 것의 수 같음 — 대칭성.',
          hints: ['nCr 대칭.', 'r 과 n-r.'],
          difficulty: ProblemDifficulty.easy,
        ),
      ];

  static List<ProblemModel> lessonPerm3() => [
        _q(
          id: 'lesson_perm_3_1',
          lessonId: 'lesson_perm_3',
          question: r'$(1+x)^4$ 전개식에서 $x^2$ 의 계수는?',
          options: ['4', '6', '8', '10'],
          correctAnswer: '6',
          explanation: r'${}_4C_2 = 6$.',
          hints: ['이항정리.', '_4C_2.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
        _q(
          id: 'lesson_perm_3_2',
          lessonId: 'lesson_perm_3',
          question: r'$\sum_{k=0}^{n} {}_n C_k = ?$',
          options: ['n', r'$2^n$', r'$n!$', r'$n^2$'],
          correctAnswer: r'$2^n$',
          explanation: r'이항정리: $(1+1)^n = 2^n$.',
          hints: ['이항 합.', '(1+1)^n.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  static List<ProblemModel> lessonPerm4() => [
        _q(
          id: 'lesson_perm_4_1',
          lessonId: 'lesson_perm_4',
          question:
              r'남자 3, 여자 4 명에서 남자 2, 여자 2 명을 뽑는 방법은?',
          options: ['12', '18', '20', '24'],
          correctAnswer: '18',
          explanation: r'${}_3C_2 \cdot {}_4C_2 = 3 \cdot 6 = 18$.',
          hints: ['남·여 따로 곱.', '_3C_2 · _4C_2.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
        _q(
          id: 'lesson_perm_4_2',
          lessonId: 'lesson_perm_4',
          question: r'$_5 P_2$ 의 값은?',
          options: ['10', '20', '25', '60'],
          correctAnswer: '20',
          explanation: r'$5 \cdot 4 = 20$.',
          hints: ['nPr 정의.', '5·4.'],
          difficulty: ProblemDifficulty.easy,
        ),
      ];

  static List<ProblemModel> lessonPerm5() => [
        _q(
          id: 'lesson_perm_5_1',
          lessonId: 'lesson_perm_5',
          question:
              r'5 자리 비밀번호 (0-9, 중복 허용) 의 경우의 수는?',
          options: [r'$10^4$', r'$10^5$', r'$5!$', r'$5^{10}$'],
          correctAnswer: r'$10^5$',
          explanation: r'각 자리 10 가지 × 5 자리 = $10^5$.',
          hints: ['중복 가능 → 곱.', '각 자리 10 × 5번.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_perm_5_2',
          lessonId: 'lesson_perm_5',
          question:
              r'서로 다른 4 색을 4 칸 깃발에 칠하는 방법은?',
          options: ['12', '16', '24', '256'],
          correctAnswer: '24',
          explanation: r'$4! = 24$.',
          hints: ['전체 순열.', '4!.'],
          difficulty: ProblemDifficulty.easy,
        ),
      ];

  static List<ProblemModel> lessonProb1() => [
        _q(
          id: 'lesson_prob_1_1',
          lessonId: 'lesson_prob_1',
          question: r'주사위 1 개를 던질 때 짝수가 나올 확률은?',
          options: [r'$\dfrac{1}{6}$', r'$\dfrac{1}{3}$', r'$\dfrac{1}{2}$', r'$\dfrac{2}{3}$'],
          correctAnswer: r'$\dfrac{1}{2}$',
          explanation: r'짝수 3가지 / 전체 6가지 $= \dfrac{1}{2}$.',
          hints: ['짝수 = 2,4,6.', '3/6.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_prob_1_2',
          lessonId: 'lesson_prob_1',
          question:
              r'동전을 2번 던질 때 모두 앞면이 나올 확률은?',
          options: [r'$\dfrac{1}{4}$', r'$\dfrac{1}{2}$', r'$\dfrac{1}{3}$', r'$\dfrac{3}{4}$'],
          correctAnswer: r'$\dfrac{1}{4}$',
          explanation: r'$\dfrac{1}{2} \times \dfrac{1}{2} = \dfrac{1}{4}$.',
          hints: ['독립시행 곱.', '1/2 × 1/2.'],
          difficulty: ProblemDifficulty.easy,
        ),
      ];

  static List<ProblemModel> lessonProb2() => [
        _q(
          id: 'lesson_prob_2_1',
          lessonId: 'lesson_prob_2',
          question:
              r'조건부확률 $P(B|A)$ 의 정의식은?',
          options: [
            r'$\dfrac{P(A \cap B)}{P(A)}$',
            r'$\dfrac{P(A \cap B)}{P(B)}$',
            r'$P(A) \cdot P(B)$',
            r'$P(A) + P(B)$',
          ],
          correctAnswer: r'$\dfrac{P(A \cap B)}{P(A)}$',
          explanation: '조건부확률 정의.',
          hints: ['A 가 일어났다는 조건.', '교집합 / P(A).'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
        _q(
          id: 'lesson_prob_2_2',
          lessonId: 'lesson_prob_2',
          question:
              r'주사위 두 개의 합이 6 이라는 조건에서 첫 주사위가 2 일 확률은?',
          options: [r'$\dfrac{1}{5}$', r'$\dfrac{1}{6}$', r'$\dfrac{1}{4}$', r'$\dfrac{1}{3}$'],
          correctAnswer: r'$\dfrac{1}{5}$',
          explanation:
              r'합 6 인 경우 5 가지 ((1,5),(2,4),(3,3),(4,2),(5,1)) 중 첫 2 인 경우 1 가지.',
          hints: ['합 6 가능한 경우.', '5가지 중 1.'],
          difficulty: ProblemDifficulty.hard,
          points: 20,
        ),
      ];

  static List<ProblemModel> lessonProb3() => [
        _q(
          id: 'lesson_prob_3_1',
          lessonId: 'lesson_prob_3',
          question:
              r'독립사건 A, B 에 대해 $P(A \cap B) = ?$',
          options: [
            r'$P(A) + P(B)$',
            r'$P(A) \cdot P(B)$',
            r'$P(A) - P(B)$',
            r'$\dfrac{P(A)}{P(B)}$',
          ],
          correctAnswer: r'$P(A) \cdot P(B)$',
          explanation: '독립 정의: 곱의 법칙.',
          hints: ['독립사건.', '곱.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_prob_3_2',
          lessonId: 'lesson_prob_3',
          question:
              r'$P(A) = 0.5, P(B) = 0.4$ 이고 A, B 독립일 때 $P(A \cap B)$ 는?',
          options: ['0.1', '0.2', '0.3', '0.9'],
          correctAnswer: '0.2',
          explanation: r'$0.5 \times 0.4 = 0.2$.',
          hints: ['독립 → 곱.', '0.5·0.4.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  static List<ProblemModel> lessonProb4() => [
        _q(
          id: 'lesson_prob_4_1',
          lessonId: 'lesson_prob_4',
          question:
              r'동전 3번 던질 때 정확히 2번 앞면 나올 확률은?',
          options: [r'$\dfrac{1}{8}$', r'$\dfrac{3}{8}$', r'$\dfrac{1}{2}$', r'$\dfrac{3}{4}$'],
          correctAnswer: r'$\dfrac{3}{8}$',
          explanation: r'${}_3 C_2 \left(\dfrac{1}{2}\right)^3 = 3 \cdot \dfrac{1}{8} = \dfrac{3}{8}$.',
          hints: ['이항분포.', '_3C_2 · (1/2)³.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
        _q(
          id: 'lesson_prob_4_2',
          lessonId: 'lesson_prob_4',
          question:
              r'주사위 4번 던져서 6 이 0번 나올 확률은?',
          options: [r'$\left(\dfrac{1}{6}\right)^4$', r'$\left(\dfrac{5}{6}\right)^4$', r'$\dfrac{1}{4}$', r'$\dfrac{4}{6}$'],
          correctAnswer: r'$\left(\dfrac{5}{6}\right)^4$',
          explanation: r'각 던지기 5/6, 독립 4번 → $(5/6)^4$.',
          hints: ['6 안 나옴 = 5/6.', '4번 독립.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  static List<ProblemModel> lessonProb5() => [
        _q(
          id: 'lesson_prob_5_1',
          lessonId: 'lesson_prob_5',
          question:
              r'전체 사건의 확률은 항상 얼마인가?',
          options: ['0', '0.5', '1', '∞'],
          correctAnswer: '1',
          explanation: 'P(S) = 1 (표본공간 전체).',
          hints: ['표본공간 확률.', '확률 합 = 1.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_prob_5_2',
          lessonId: 'lesson_prob_5',
          question: r'$P(A^c) = ?$',
          options: [r'$P(A)$', r'$1 - P(A)$', r'$0$', r'$2P(A)$'],
          correctAnswer: r'$1 - P(A)$',
          explanation: '여사건 확률.',
          hints: ['A 가 안 일어남.', '1 - P(A).'],
          difficulty: ProblemDifficulty.easy,
        ),
      ];

  static List<ProblemModel> lessonStat1() => [
        _q(
          id: 'lesson_stat_1_1',
          lessonId: 'lesson_stat_1',
          question: r'확률변수 $X$ 가 $\{0,1,2\}$ 값을 각각 확률 $\dfrac{1}{4}, \dfrac{1}{2}, \dfrac{1}{4}$ 로 가질 때 $E(X)$ 는?',
          options: ['0.5', '1', '1.5', '2'],
          correctAnswer: '1',
          explanation: r'$0 \cdot \dfrac{1}{4} + 1 \cdot \dfrac{1}{2} + 2 \cdot \dfrac{1}{4} = 1$.',
          hints: ['기댓값 정의.', '값 × 확률 합.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
        _q(
          id: 'lesson_stat_1_2',
          lessonId: 'lesson_stat_1',
          question:
              r'확률분포에서 모든 확률의 합은?',
          options: ['0', '0.5', '1', 'n'],
          correctAnswer: '1',
          explanation: '확률분포 정의: 합 = 1.',
          hints: ['확률 정의.', '전체 = 1.'],
          difficulty: ProblemDifficulty.easy,
        ),
      ];

  static List<ProblemModel> lessonStat2() => [
        _q(
          id: 'lesson_stat_2_1',
          lessonId: 'lesson_stat_2',
          question:
              r'이항분포 $B(n, p)$ 의 평균은?',
          options: ['n', 'p', 'np', r'$np(1-p)$'],
          correctAnswer: 'np',
          explanation: '이항분포 평균: E(X) = np.',
          hints: ['이항분포 평균 공식.', 'np.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_stat_2_2',
          lessonId: 'lesson_stat_2',
          question:
              r'$B(10, 0.5)$ 의 평균과 분산은?',
          options: ['5, 2.5', '5, 5', '10, 5', '5, 10'],
          correctAnswer: '5, 2.5',
          explanation: r'$\mu = np = 5$, $\sigma^2 = np(1-p) = 2.5$.',
          hints: ['평균 = np.', '분산 = np(1-p).'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  static List<ProblemModel> lessonStat3() => [
        _q(
          id: 'lesson_stat_3_1',
          lessonId: 'lesson_stat_3',
          question:
              r'연속확률변수의 확률은 확률밀도함수의 무엇과 같은가?',
          options: ['값', '미분', '적분', '평균'],
          correctAnswer: '적분',
          explanation: '구간 적분 = 확률.',
          hints: ['연속분포 정의.', '적분으로.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_stat_3_2',
          lessonId: 'lesson_stat_3',
          question:
              r'확률밀도함수 $f(x) \geq 0$ 이고 $\int_{-\infty}^{\infty} f(x) dx = ?$',
          options: ['0', '0.5', '1', '∞'],
          correctAnswer: '1',
          explanation: '전체 확률.',
          hints: ['전체 면적.', '1.'],
          difficulty: ProblemDifficulty.easy,
        ),
      ];

  static List<ProblemModel> lessonStat4() => [
        _q(
          id: 'lesson_stat_4_1',
          lessonId: 'lesson_stat_4',
          question:
              r'표준정규분포의 평균과 분산은?',
          options: ['0, 1', '1, 1', '0, 0', '1, 0'],
          correctAnswer: '0, 1',
          explanation: r'$Z \sim N(0, 1)$.',
          hints: ['표준화.', '평균 0, 분산 1.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_stat_4_2',
          lessonId: 'lesson_stat_4',
          question:
              r'정규분포 $N(\mu, \sigma^2)$ 의 표준화 변환은?',
          options: [
            r'$Z = X - \mu$',
            r'$Z = \dfrac{X-\mu}{\sigma}$',
            r'$Z = \dfrac{X}{\sigma}$',
            r'$Z = X\sigma + \mu$',
          ],
          correctAnswer: r'$Z = \dfrac{X-\mu}{\sigma}$',
          explanation: '표준화 공식.',
          hints: ['평균 빼고 표준편차로.', 'Z = (X-μ)/σ.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  static List<ProblemModel> lessonStat5() => [
        _q(
          id: 'lesson_stat_5_1',
          lessonId: 'lesson_stat_5',
          question:
              r'표본평균의 분포에서 모평균에 대한 95% 신뢰구간 형태는?',
          options: [
            r'$\bar{X} \pm 1.96 \dfrac{\sigma}{\sqrt{n}}$',
            r'$\bar{X} \pm \sigma$',
            r'$\bar{X} \pm \mu$',
            r'$\bar{X} \pm n$',
          ],
          correctAnswer: r'$\bar{X} \pm 1.96 \dfrac{\sigma}{\sqrt{n}}$',
          explanation: '95% 신뢰구간 — z=1.96.',
          hints: ['95% → z = 1.96.', 'σ/√n.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
        _q(
          id: 'lesson_stat_5_2',
          lessonId: 'lesson_stat_5',
          question:
              r'표본 크기가 커지면 표본평균의 표준편차는?',
          options: ['증가', '감소', '불변', '0 이 됨'],
          correctAnswer: '감소',
          explanation: r'$\sigma_{\bar{X}} = \sigma / \sqrt{n}$ — n 증가 시 감소.',
          hints: ['표준오차 공식.', 'n 분모.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  static List<ProblemModel> lessonStat6() => [
        _q(
          id: 'lesson_stat_6_1',
          lessonId: 'lesson_stat_6',
          question:
              r'$P(Z < 0) = ?$ (Z 는 표준정규)',
          options: ['0', '0.25', '0.5', '1'],
          correctAnswer: '0.5',
          explanation: '대칭분포 — 평균 미만 = 0.5.',
          hints: ['표준정규 대칭.', '평균 0.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_stat_6_2',
          lessonId: 'lesson_stat_6',
          question: r'$P(-1.96 < Z < 1.96) \approx ?$',
          options: ['0.90', '0.95', '0.99', '1'],
          correctAnswer: '0.95',
          explanation: '95% 신뢰구간 기본값.',
          hints: ['95% 구간.', '0.95.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  // ============================================================
  // 고3 — 미적분
  // ============================================================

  static List<ProblemModel> lessonSeqlim1() => [
        _q(
          id: 'lesson_seqlim_1_1',
          lessonId: 'lesson_seqlim_1',
          question: r'$\lim_{n \to \infty} \dfrac{1}{n}$ 의 값은?',
          options: ['0', '1', '∞', '-1'],
          correctAnswer: '0',
          explanation: 'n 무한대 → 1/n → 0.',
          hints: ['분모 무한.', '0.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_seqlim_1_2',
          lessonId: 'lesson_seqlim_1',
          question: r'$\lim_{n \to \infty} \dfrac{3n+1}{n}$ 의 값은?',
          options: ['0', '1', '3', '∞'],
          correctAnswer: '3',
          explanation: r'$3 + \dfrac{1}{n} \to 3$.',
          hints: ['3+1/n.', '1/n → 0.'],
          difficulty: ProblemDifficulty.easy,
        ),
      ];

  static List<ProblemModel> lessonSeqlim2() => [
        _q(
          id: 'lesson_seqlim_2_1',
          lessonId: 'lesson_seqlim_2',
          question: r'$\lim_{n \to \infty} \dfrac{n^2+1}{2n^2-3}$ 의 값은?',
          options: ['0', r'$\dfrac{1}{2}$', '1', '∞'],
          correctAnswer: r'$\dfrac{1}{2}$',
          explanation: '최고차항 계수 비.',
          hints: ['최고차항.', '1/2.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
        _q(
          id: 'lesson_seqlim_2_2',
          lessonId: 'lesson_seqlim_2',
          question: r'$\lim_{n \to \infty} 2^{-n}$ 의 값은?',
          options: ['0', '1', '2', '∞'],
          correctAnswer: '0',
          explanation: r'$2^{-n} = \dfrac{1}{2^n} \to 0$.',
          hints: ['지수 음수.', '0.'],
          difficulty: ProblemDifficulty.easy,
        ),
      ];

  static List<ProblemModel> lessonSeqlim3() => [
        _q(
          id: 'lesson_seqlim_3_1',
          lessonId: 'lesson_seqlim_3',
          question:
              r'급수 $\sum_{n=1}^{\infty} \dfrac{1}{n}$ 은?',
          options: ['수렴', '발산', '주기', '0'],
          correctAnswer: '발산',
          explanation: '조화급수 — 발산.',
          hints: ['조화급수.', '발산.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
        _q(
          id: 'lesson_seqlim_3_2',
          lessonId: 'lesson_seqlim_3',
          question:
              r'급수 $\sum_{n=1}^{\infty} \dfrac{1}{2^n}$ 의 합은?',
          options: ['0', r'$\dfrac{1}{2}$', '1', '∞'],
          correctAnswer: '1',
          explanation: r'등비급수, 첫항 1/2, 공비 1/2: $\dfrac{1/2}{1-1/2} = 1$.',
          hints: ['등비급수 합 공식.', 'a/(1-r).'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  static List<ProblemModel> lessonSeqlim4() => [
        _q(
          id: 'lesson_seqlim_4_1',
          lessonId: 'lesson_seqlim_4',
          question:
              r'등비급수 $\sum ar^{n-1}$ 가 수렴할 조건은?',
          options: [r'$|r| < 1$', r'$r > 0$', r'$r = 1$', '항상 수렴'],
          correctAnswer: r'$|r| < 1$',
          explanation: '공비 절댓값 < 1.',
          hints: ['공비 조건.', '|r|<1.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_seqlim_4_2',
          lessonId: 'lesson_seqlim_4',
          question:
              r'등비급수 $1 + \dfrac{1}{3} + \dfrac{1}{9} + \cdots$ 의 합은?',
          options: ['1', r'$\dfrac{3}{2}$', '2', '3'],
          correctAnswer: r'$\dfrac{3}{2}$',
          explanation: r'$\dfrac{1}{1-1/3} = \dfrac{3}{2}$.',
          hints: ['a/(1-r).', 'r=1/3.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  static List<ProblemModel> lessonSeqlim5() => [
        _q(
          id: 'lesson_seqlim_5_1',
          lessonId: 'lesson_seqlim_5',
          question:
              r'$\lim_{n \to \infty} (1+1/n)^n$ 의 값은?',
          options: ['1', '2', 'e', '∞'],
          correctAnswer: 'e',
          explanation: '자연상수 e 의 정의.',
          hints: ['e 정의.', '약 2.718.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
        _q(
          id: 'lesson_seqlim_5_2',
          lessonId: 'lesson_seqlim_5',
          question:
              r'급수 $\sum (-1)^n$ 은?',
          options: ['수렴', '발산', '0', '1'],
          correctAnswer: '발산',
          explanation: '진동 — 수렴 안 함.',
          hints: ['교대 ±1.', '극한 없음.'],
          difficulty: ProblemDifficulty.easy,
        ),
      ];

  static List<ProblemModel> lessonAdiff1() => [
        _q(
          id: 'lesson_adiff_1_1',
          lessonId: 'lesson_adiff_1',
          question: r'$\dfrac{d}{dx} e^x = ?$',
          options: [r'$e^x$', r'$xe^{x-1}$', r'$\ln x$', '1'],
          correctAnswer: r'$e^x$',
          explanation: '지수함수 미분 — 자기 자신.',
          hints: ['e^x 특성.', '자기 미분 = 자기.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_adiff_1_2',
          lessonId: 'lesson_adiff_1',
          question: r'$\dfrac{d}{dx} \ln x = ?$',
          options: [r'$\dfrac{1}{x}$', r'$\ln x$', r'$x$', r'$e^x$'],
          correctAnswer: r'$\dfrac{1}{x}$',
          explanation: '로그함수 미분.',
          hints: ['ln x 미분.', '1/x.'],
          difficulty: ProblemDifficulty.easy,
        ),
      ];

  static List<ProblemModel> lessonAdiff2() => [
        _q(
          id: 'lesson_adiff_2_1',
          lessonId: 'lesson_adiff_2',
          question: r'$\dfrac{d}{dx} \sin x = ?$',
          options: [r'$\cos x$', r'$-\cos x$', r'$\sin x$', r'$-\sin x$'],
          correctAnswer: r'$\cos x$',
          explanation: '삼각함수 기본 미분.',
          hints: ['sin → cos.', '기본 공식.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_adiff_2_2',
          lessonId: 'lesson_adiff_2',
          question: r'$\dfrac{d}{dx} \cos x = ?$',
          options: [r'$\sin x$', r'$-\sin x$', r'$\cos x$', r'$-\cos x$'],
          correctAnswer: r'$-\sin x$',
          explanation: 'cos 미분 → -sin.',
          hints: ['cos → -sin.', '부호 주의.'],
          difficulty: ProblemDifficulty.easy,
        ),
      ];

  static List<ProblemModel> lessonAdiff3() => [
        _q(
          id: 'lesson_adiff_3_1',
          lessonId: 'lesson_adiff_3',
          question:
              r'합성함수의 미분: $\dfrac{d}{dx} f(g(x)) = ?$',
          options: [
            r"$f'(g(x))$",
            r"$f'(g(x)) \cdot g'(x)$",
            r"$f(g'(x))$",
            r"$f(x) \cdot g'(x)$",
          ],
          correctAnswer: r"$f'(g(x)) \cdot g'(x)$",
          explanation: '연쇄법칙.',
          hints: ['연쇄법칙.', '외부 미분·내부 미분.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
        _q(
          id: 'lesson_adiff_3_2',
          lessonId: 'lesson_adiff_3',
          question: r'$y = (2x+1)^3$ 의 도함수는?',
          options: [
            r'$3(2x+1)^2$',
            r'$6(2x+1)^2$',
            r'$2(2x+1)^2$',
            r'$3(2x+1)^3$',
          ],
          correctAnswer: r'$6(2x+1)^2$',
          explanation: r'연쇄법칙: $3(2x+1)^2 \cdot 2 = 6(2x+1)^2$.',
          hints: ['외부: 3u².', '내부 미분 2.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  static List<ProblemModel> lessonAdiff4() => [
        _q(
          id: 'lesson_adiff_4_1',
          lessonId: 'lesson_adiff_4',
          question: r'곡선 $y = \ln x$ 에서 $x = 1$ 의 접선의 기울기는?',
          options: ['0', '1', 'e', '1/e'],
          correctAnswer: '1',
          explanation: r"$y' = 1/x, y'(1) = 1$.",
          hints: ['1/x.', 'x=1.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_adiff_4_2',
          lessonId: 'lesson_adiff_4',
          question: r'$y = e^{2x}$ 의 도함수는?',
          options: [r'$e^{2x}$', r'$2e^{2x}$', r'$2xe^{2x}$', r'$e^{2}$'],
          correctAnswer: r'$2e^{2x}$',
          explanation: '연쇄법칙.',
          hints: ['외부 e^u.', '내부 미분 2.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  static List<ProblemModel> lessonAdiff5() => [
        _q(
          id: 'lesson_adiff_5_1',
          lessonId: 'lesson_adiff_5',
          question:
              r"$f(x) = e^x$ 가 증가하는 구간은?",
          options: [r'$x > 0$', r'$x < 0$', '모든 실수', '없음'],
          correctAnswer: '모든 실수',
          explanation: r"$f'(x) = e^x > 0$ 항상.",
          hints: ['e^x > 0.', '항상 증가.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_adiff_5_2',
          lessonId: 'lesson_adiff_5',
          question:
              r'$y = \sin x$ 의 $[0, \pi]$ 에서 최댓값은?',
          options: ['0', r'$\dfrac{1}{2}$', '1', r'$\pi$'],
          correctAnswer: '1',
          explanation: r'$\sin(\pi/2) = 1$.',
          hints: ['sin 최댓값.', 'π/2.'],
          difficulty: ProblemDifficulty.easy,
        ),
      ];

  static List<ProblemModel> lessonAdiff6() => [
        _q(
          id: 'lesson_adiff_6_1',
          lessonId: 'lesson_adiff_6',
          question:
              r"몫의 미분: $\left(\dfrac{f}{g}\right)' = ?$",
          options: [
            r"$\dfrac{f'g - fg'}{g^2}$",
            r"$\dfrac{f'g + fg'}{g^2}$",
            r"$\dfrac{f'}{g'}$",
            r"$f'/g$",
          ],
          correctAnswer: r"$\dfrac{f'g - fg'}{g^2}$",
          explanation: '몫의 미분 공식.',
          hints: ['quotient rule.', '분자 미분 차이.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
        _q(
          id: 'lesson_adiff_6_2',
          lessonId: 'lesson_adiff_6',
          question: r'$\dfrac{d}{dx}\tan x = ?$',
          options: [r'$\sec^2 x$', r'$-\sec^2 x$', r'$\cos x$', r'$\sin x$'],
          correctAnswer: r'$\sec^2 x$',
          explanation: 'tan 미분.',
          hints: ['tan 미분 공식.', 'sec².'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  static List<ProblemModel> lessonAinteg1() => [
        _q(
          id: 'lesson_ainteg_1_1',
          lessonId: 'lesson_ainteg_1',
          question: r'$\int e^x dx = ?$',
          options: [r'$e^x + C$', r'$xe^x + C$', r'$\ln x + C$', r'$1 + C$'],
          correctAnswer: r'$e^x + C$',
          explanation: 'e^x 부정적분 = e^x + C.',
          hints: ['e^x 자기 적분.', '자기 + C.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_ainteg_1_2',
          lessonId: 'lesson_ainteg_1',
          question: r'$\int \dfrac{1}{x} dx = ?$',
          options: [r'$\ln|x| + C$', r'$\dfrac{1}{x^2} + C$', r'$-\dfrac{1}{x^2} + C$', r'$x + C$'],
          correctAnswer: r'$\ln|x| + C$',
          explanation: '1/x 부정적분.',
          hints: ['1/x → ln|x|.', '절댓값.'],
          difficulty: ProblemDifficulty.easy,
        ),
      ];

  static List<ProblemModel> lessonAinteg2() => [
        _q(
          id: 'lesson_ainteg_2_1',
          lessonId: 'lesson_ainteg_2',
          question: r'$\int \sin x \, dx = ?$',
          options: [r'$\cos x + C$', r'$-\cos x + C$', r'$\sin x + C$', r'$-\sin x + C$'],
          correctAnswer: r'$-\cos x + C$',
          explanation: 'sin 적분 = -cos.',
          hints: ['sin 적분 부호.', '-cos.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_ainteg_2_2',
          lessonId: 'lesson_ainteg_2',
          question: r'$\int \cos x \, dx = ?$',
          options: [r'$\sin x + C$', r'$-\sin x + C$', r'$\cos x + C$', r'$\tan x + C$'],
          correctAnswer: r'$\sin x + C$',
          explanation: 'cos 적분 = sin.',
          hints: ['cos 적분.', 'sin.'],
          difficulty: ProblemDifficulty.easy,
        ),
      ];

  static List<ProblemModel> lessonAinteg3() => [
        _q(
          id: 'lesson_ainteg_3_1',
          lessonId: 'lesson_ainteg_3',
          question:
              r'$y = e^x, x=0, x=1, x$ 축 으로 둘러싸인 영역의 넓이는?',
          options: ['1', 'e', 'e-1', '2e'],
          correctAnswer: 'e-1',
          explanation: r'$\int_0^1 e^x dx = [e^x]_0^1 = e - 1$.',
          hints: ['e^x 적분.', 'e-1.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
        _q(
          id: 'lesson_ainteg_3_2',
          lessonId: 'lesson_ainteg_3',
          question: r'$\int_0^{\pi} \sin x \, dx = ?$',
          options: ['0', '1', '2', r'$\pi$'],
          correctAnswer: '2',
          explanation: r'$[-\cos x]_0^{\pi} = -(-1) - (-1) = 2$.',
          hints: ['sin 적분.', '-cos π = 1, -cos 0 = -1.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  static List<ProblemModel> lessonAinteg4() => [
        _q(
          id: 'lesson_ainteg_4_1',
          lessonId: 'lesson_ainteg_4',
          question:
              r'곡선 $y=\sqrt{x}$, 직선 $y=0, x=4$ 로 둘러싸인 영역의 넓이는?',
          options: [r'$\dfrac{8}{3}$', r'$\dfrac{16}{3}$', '4', '8'],
          correctAnswer: r'$\dfrac{16}{3}$',
          explanation:
              r'$\int_0^4 \sqrt{x} dx = \left[\dfrac{2}{3}x^{3/2}\right]_0^4 = \dfrac{2}{3}\cdot 8 = \dfrac{16}{3}$.',
          hints: ['x^(1/2) 적분.', '2/3 · x^(3/2).'],
          difficulty: ProblemDifficulty.hard,
          points: 20,
        ),
        _q(
          id: 'lesson_ainteg_4_2',
          lessonId: 'lesson_ainteg_4',
          question:
              r'$y = x, y = 0, x=0, x=2$ 회전체 (x축 회전) 부피는?',
          options: [r'$\dfrac{8\pi}{3}$', r'$\dfrac{4\pi}{3}$', r'$\dfrac{2\pi}{3}$', '8π'],
          correctAnswer: r'$\dfrac{8\pi}{3}$',
          explanation:
              r'$V = \pi \int_0^2 x^2 dx = \pi \cdot \dfrac{8}{3} = \dfrac{8\pi}{3}$.',
          hints: ['회전체 부피.', 'π ∫ y² dx.'],
          difficulty: ProblemDifficulty.hard,
          points: 20,
        ),
      ];

  static List<ProblemModel> lessonAinteg5() => [
        _q(
          id: 'lesson_ainteg_5_1',
          lessonId: 'lesson_ainteg_5',
          question:
              r'$\int_0^1 (e^x + 1) dx$ 의 값은?',
          options: ['e', 'e-1', 'e+1', 'e+2'],
          correctAnswer: 'e',
          explanation: r'$[e^x + x]_0^1 = (e+1) - (1+0) = e$.',
          hints: ['항별 적분.', 'e+1-1.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
        _q(
          id: 'lesson_ainteg_5_2',
          lessonId: 'lesson_ainteg_5',
          question: r'$\int_1^e \dfrac{1}{x} dx = ?$',
          options: ['0', '1', 'e', 'e-1'],
          correctAnswer: '1',
          explanation: r'$[\ln x]_1^e = 1 - 0 = 1$.',
          hints: ['ln x 적분.', 'ln e - ln 1.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  // ============================================================
  // 고3 — 기하
  // ============================================================

  static List<ProblemModel> lessonConic1() => [
        _q(
          id: 'lesson_conic_1_1',
          lessonId: 'lesson_conic_1',
          question:
              r'포물선 $y^2 = 4px$ 의 초점 좌표는? (p>0)',
          options: ['(p, 0)', '(-p, 0)', '(0, p)', '(0, -p)'],
          correctAnswer: '(p, 0)',
          explanation: '표준형 포물선 초점.',
          hints: ['표준형 포물선.', '(p, 0).'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_conic_1_2',
          lessonId: 'lesson_conic_1',
          question:
              r'$y^2 = 8x$ 의 초점 좌표는?',
          options: ['(2,0)', '(4,0)', '(8,0)', '(0,2)'],
          correctAnswer: '(2,0)',
          explanation: r'$4p = 8 \Rightarrow p = 2$.',
          hints: ['4p=8.', 'p=2.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  static List<ProblemModel> lessonConic2() => [
        _q(
          id: 'lesson_conic_2_1',
          lessonId: 'lesson_conic_2',
          question:
              r'타원 $\dfrac{x^2}{9} + \dfrac{y^2}{4} = 1$ 의 장축 길이는?',
          options: ['2', '3', '4', '6'],
          correctAnswer: '6',
          explanation: r'$a^2=9, a=3$. 장축 = 2a = 6.',
          hints: ['a² = 9.', '2a.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
        _q(
          id: 'lesson_conic_2_2',
          lessonId: 'lesson_conic_2',
          question:
              r'타원의 두 초점 사이의 거리를 무엇이라 하는가?',
          options: ['장축', '단축', '2c', '이심률'],
          correctAnswer: '2c',
          explanation: '초점 거리 = 2c.',
          hints: ['초점 거리.', '2c.'],
          difficulty: ProblemDifficulty.easy,
        ),
      ];

  static List<ProblemModel> lessonConic3() => [
        _q(
          id: 'lesson_conic_3_1',
          lessonId: 'lesson_conic_3',
          question:
              r'쌍곡선 $\dfrac{x^2}{16} - \dfrac{y^2}{9} = 1$ 의 점근선 기울기는?',
          options: [r'$\pm \dfrac{3}{4}$', r'$\pm \dfrac{4}{3}$', r'$\pm 1$', r'$\pm \dfrac{1}{2}$'],
          correctAnswer: r'$\pm \dfrac{3}{4}$',
          explanation: r'점근선 $y = \pm \dfrac{b}{a}x = \pm \dfrac{3}{4}x$.',
          hints: ['b/a.', '3/4.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
        _q(
          id: 'lesson_conic_3_2',
          lessonId: 'lesson_conic_3',
          question:
              r'$x^2 - y^2 = 1$ 의 두 초점 사이의 거리는?',
          options: ['1', r'$\sqrt{2}$', '2', r'$2\sqrt{2}$'],
          correctAnswer: r'$2\sqrt{2}$',
          explanation: r'$c^2 = a^2 + b^2 = 1+1 = 2 \Rightarrow c=\sqrt{2}$. 거리 $=2c = 2\sqrt{2}$.',
          hints: ['c² = a²+b².', '2c.'],
          difficulty: ProblemDifficulty.hard,
          points: 20,
        ),
      ];

  static List<ProblemModel> lessonConic4() => [
        _q(
          id: 'lesson_conic_4_1',
          lessonId: 'lesson_conic_4',
          question:
              r'$y^2 = 4x$ 와 직선 $y = x$ 의 교점의 개수는?',
          options: ['0', '1', '2', '3'],
          correctAnswer: '2',
          explanation: r'대입: $x^2 = 4x \Rightarrow x(x-4)=0 \Rightarrow x=0, 4$. 두 점.',
          hints: ['대입.', 'x²=4x.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
        _q(
          id: 'lesson_conic_4_2',
          lessonId: 'lesson_conic_4',
          question:
              r'타원 $\dfrac{x^2}{4} + y^2 = 1$ 과 $x$ 축이 만나는 점의 개수는?',
          options: ['0', '1', '2', '4'],
          correctAnswer: '2',
          explanation: r'$y=0$ 대입: $x = \pm 2$. 두 점.',
          hints: ['y=0 대입.', 'x²=4.'],
          difficulty: ProblemDifficulty.easy,
        ),
      ];

  static List<ProblemModel> lessonConic5() => [
        _q(
          id: 'lesson_conic_5_1',
          lessonId: 'lesson_conic_5',
          question:
              r'이심률이 0 인 이차곡선은?',
          options: ['포물선', '타원', '원', '쌍곡선'],
          correctAnswer: '원',
          explanation: '원: e = 0. 타원: 0<e<1. 포물선: e=1. 쌍곡선: e>1.',
          hints: ['이심률 0.', '원.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
        _q(
          id: 'lesson_conic_5_2',
          lessonId: 'lesson_conic_5',
          question:
              r'포물선 $y^2 = 4x$ 위의 점 $(1, 2)$ 와 초점 $(1, 0)$ 사이 거리는?',
          options: ['1', '2', '3', '4'],
          correctAnswer: '2',
          explanation: r'$\sqrt{0 + 4} = 2$.',
          hints: ['두 점 거리.', '√4.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  static List<ProblemModel> lessonVec1() => [
        _q(
          id: 'lesson_vec_1_1',
          lessonId: 'lesson_vec_1',
          question:
              r'벡터 $\vec{a} = (1,2), \vec{b} = (3,4)$ 의 합 $\vec{a}+\vec{b}$ 는?',
          options: ['(4,6)', '(2,2)', '(3,8)', '(4,4)'],
          correctAnswer: '(4,6)',
          explanation: '성분끼리 합.',
          hints: ['성분 덧셈.', '(1+3, 2+4).'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_vec_1_2',
          lessonId: 'lesson_vec_1',
          question:
              r'$|\vec{a}|$ 가 $\vec{a} = (3,4)$ 일 때 값은?',
          options: ['3', '4', '5', '7'],
          correctAnswer: '5',
          explanation: r'$\sqrt{9+16} = 5$.',
          hints: ['크기 공식.', '√(3²+4²).'],
          difficulty: ProblemDifficulty.easy,
        ),
      ];

  static List<ProblemModel> lessonVec2() => [
        _q(
          id: 'lesson_vec_2_1',
          lessonId: 'lesson_vec_2',
          question:
              r'$\vec{a} = (2,3), \vec{b} = (1,-1)$ 일 때 $2\vec{a} - \vec{b}$ 는?',
          options: ['(3,7)', '(3,4)', '(5,5)', '(3,5)'],
          correctAnswer: '(3,7)',
          explanation:
              r'$2(2,3) - (1,-1) = (4,6) - (1,-1) = (3, 7)$.',
          hints: ['스칼라 곱.', '성분 빼기.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
        _q(
          id: 'lesson_vec_2_2',
          lessonId: 'lesson_vec_2',
          question:
              r'영벡터의 성분 표현은?',
          options: ['(1,0)', '(0,1)', '(0,0)', '(1,1)'],
          correctAnswer: '(0,0)',
          explanation: '영벡터 = 모든 성분 0.',
          hints: ['영벡터.', '(0,0).'],
          difficulty: ProblemDifficulty.easy,
        ),
      ];

  static List<ProblemModel> lessonVec3() => [
        _q(
          id: 'lesson_vec_3_1',
          lessonId: 'lesson_vec_3',
          question:
              r'$\vec{a} = (1,2), \vec{b} = (3,4)$ 의 내적 $\vec{a} \cdot \vec{b}$ 는?',
          options: ['7', '10', '11', '14'],
          correctAnswer: '11',
          explanation: r'$1\cdot 3 + 2\cdot 4 = 11$.',
          hints: ['성분곱 합.', '3+8.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_vec_3_2',
          lessonId: 'lesson_vec_3',
          question:
              r'두 벡터가 수직일 조건은?',
          options: [
            '크기 같음',
            '내적 = 0',
            '평행',
            '합 = 영벡터',
          ],
          correctAnswer: '내적 = 0',
          explanation: '수직 ⇔ 내적 0.',
          hints: ['수직 조건.', '내적 0.'],
          difficulty: ProblemDifficulty.easy,
        ),
      ];

  static List<ProblemModel> lessonVec4() => [
        _q(
          id: 'lesson_vec_4_1',
          lessonId: 'lesson_vec_4',
          question:
              r'점 $A(1,2)$ 를 지나고 방향벡터 $(3,4)$ 인 직선의 매개변수 방정식은?',
          options: [
            r'$x = 1+3t, y = 2+4t$',
            r'$x = 3+t, y = 4+2t$',
            r'$x = 1-3t, y = 2-4t$',
            r'$x = 3t, y = 4t$',
          ],
          correctAnswer: r'$x = 1+3t, y = 2+4t$',
          explanation: '점 + 방향벡터 × 매개변수.',
          hints: ['매개변수 형식.', '점 + tv.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
        _q(
          id: 'lesson_vec_4_2',
          lessonId: 'lesson_vec_4',
          question:
              r'두 직선 $\vec{r}_1 = \vec{a}_1 + t\vec{v}_1, \vec{r}_2 = \vec{a}_2 + s\vec{v}_2$ 가 평행이 되는 조건은?',
          options: [
            r'$\vec{v}_1 = \vec{v}_2$',
            r'$\vec{v}_1$ 과 $\vec{v}_2$ 가 평행',
            r'$\vec{a}_1 = \vec{a}_2$',
            r'$\vec{v}_1 \cdot \vec{v}_2 = 0$',
          ],
          correctAnswer: r'$\vec{v}_1$ 과 $\vec{v}_2$ 가 평행',
          explanation: '방향벡터가 평행 → 직선 평행.',
          hints: ['방향벡터.', '평행 = 스칼라배.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  static List<ProblemModel> lessonVec5() => [
        _q(
          id: 'lesson_vec_5_1',
          lessonId: 'lesson_vec_5',
          question:
              r'$\vec{a} = (1,0), \vec{b} = (0,1)$ 의 사잇각은?',
          options: ['0°', '45°', '90°', '180°'],
          correctAnswer: '90°',
          explanation: '내적 0 → 직교.',
          hints: ['내적 = 1·0+0·1 = 0.', '직교.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_vec_5_2',
          lessonId: 'lesson_vec_5',
          question:
              r'$\vec{a} \cdot \vec{b} = |\vec{a}||\vec{b}|\cos\theta$ 에서 $\cos\theta$ 의 값이 $\vec{a}=(1,1), \vec{b}=(2,0)$ 일 때?',
          options: [
            r'$\dfrac{1}{\sqrt{2}}$',
            r'$\dfrac{\sqrt{2}}{2}$',
            '1',
            '0',
          ],
          correctAnswer: r'$\dfrac{1}{\sqrt{2}}$',
          explanation:
              r'$\vec{a}\cdot\vec{b}=2, |\vec{a}|=\sqrt{2}, |\vec{b}|=2$. $\cos\theta = \dfrac{2}{2\sqrt{2}} = \dfrac{1}{\sqrt{2}}$.',
          hints: ['내적·크기.', '2/(√2·2).'],
          difficulty: ProblemDifficulty.hard,
          points: 20,
        ),
      ];

  static List<ProblemModel> lessonSpace1() => [
        _q(
          id: 'lesson_space_1_1',
          lessonId: 'lesson_space_1',
          question:
              r'공간에서 두 직선이 평행이 아니고 만나지도 않을 때 두 직선은?',
          options: ['평행', '직교', '꼬인 위치', '같은 직선'],
          correctAnswer: '꼬인 위치',
          explanation: '꼬인 위치 (skew lines).',
          hints: ['평행 X, 만나지 않음.', '꼬인 위치.'],
          difficulty: ProblemDifficulty.easy,
        ),
        _q(
          id: 'lesson_space_1_2',
          lessonId: 'lesson_space_1',
          question:
              r'두 평면이 한 직선에서 만날 때 두 평면의 위치 관계는?',
          options: ['평행', '직교', '교차', '일치'],
          correctAnswer: '교차',
          explanation: '한 직선에서 만남 = 교차.',
          hints: ['만나면 교차.', '교차.'],
          difficulty: ProblemDifficulty.easy,
        ),
      ];

  static List<ProblemModel> lessonSpace2() => [
        _q(
          id: 'lesson_space_2_1',
          lessonId: 'lesson_space_2',
          question:
              r'정사영의 길이가 원래 길이의 $\cos\theta$ 배일 때 $\theta$ 는?',
          options: [
            '평면과 직선의 각',
            '두 직선의 각',
            '평면 위 각',
            '없는 개념',
          ],
          correctAnswer: '평면과 직선의 각',
          explanation: '정사영 길이 = 원래 × cos(평면-직선 각).',
          hints: ['정사영 공식.', '평면-직선 각.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
        _q(
          id: 'lesson_space_2_2',
          lessonId: 'lesson_space_2',
          question:
              r'직선과 평면이 이루는 각이 30°, 직선의 길이가 4 일 때 정사영의 길이는?',
          options: [r'$2$', r'$2\sqrt{3}$', '4', r'$4\sqrt{3}$'],
          correctAnswer: r'$2\sqrt{3}$',
          explanation: r'$4 \cos 30° = 4 \cdot \dfrac{\sqrt{3}}{2} = 2\sqrt{3}$.',
          hints: ['정사영 = 원래·cos.', 'cos 30° = √3/2.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];

  static List<ProblemModel> lessonSpace3() => [
        _q(
          id: 'lesson_space_3_1',
          lessonId: 'lesson_space_3',
          question:
              r'두 점 $A(1,2,3), B(4,6,3)$ 사이의 거리는?',
          options: ['3', '4', '5', '6'],
          correctAnswer: '5',
          explanation: r'$\sqrt{9+16+0} = 5$.',
          hints: ['3차원 거리.', '√(Δx²+Δy²+Δz²).'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
        _q(
          id: 'lesson_space_3_2',
          lessonId: 'lesson_space_3',
          question: r'원점에서 점 $(1, 2, 2)$ 까지의 거리는?',
          options: ['2', '3', '4', '5'],
          correctAnswer: '3',
          explanation: r'$\sqrt{1+4+4} = 3$.',
          hints: ['공간 거리.', '√9.'],
          difficulty: ProblemDifficulty.easy,
        ),
      ];

  static List<ProblemModel> lessonSpace4() => [
        _q(
          id: 'lesson_space_4_1',
          lessonId: 'lesson_space_4',
          question:
              r'중심 $(1,2,3)$, 반지름 4 인 구의 방정식은?',
          options: [
            r'$(x-1)^2+(y-2)^2+(z-3)^2 = 16$',
            r'$(x-1)^2+(y-2)^2+(z-3)^2 = 4$',
            r'$x^2+y^2+z^2 = 16$',
            r'$(x+1)^2+(y+2)^2+(z+3)^2 = 16$',
          ],
          correctAnswer: r'$(x-1)^2+(y-2)^2+(z-3)^2 = 16$',
          explanation: '구 표준형. r=4 → r²=16.',
          hints: ['구의 표준형.', '반지름 제곱.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
        _q(
          id: 'lesson_space_4_2',
          lessonId: 'lesson_space_4',
          question:
              r'구 $x^2+y^2+z^2 = 25$ 의 반지름은?',
          options: ['1', '5', '25', '√25'],
          correctAnswer: '5',
          explanation: r'$r^2 = 25 \Rightarrow r = 5$.',
          hints: ['r² 식별.', '√25=5.'],
          difficulty: ProblemDifficulty.easy,
        ),
      ];

  static List<ProblemModel> lessonSpace5() => [
        _q(
          id: 'lesson_space_5_1',
          lessonId: 'lesson_space_5',
          question:
              r'두 평면이 수직이 될 조건은 두 평면의 법선벡터가?',
          options: ['평행', '수직', '같음', '영벡터'],
          correctAnswer: '수직',
          explanation: '법선벡터 수직 ⇔ 평면 수직.',
          hints: ['법선벡터.', '평면 수직 ↔ 법선 수직.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
        _q(
          id: 'lesson_space_5_2',
          lessonId: 'lesson_space_5',
          question:
              r'정육면체 한 모서리의 길이가 1 일 때 대각선의 길이는?',
          options: [r'$1$', r'$\sqrt{2}$', r'$\sqrt{3}$', '2'],
          correctAnswer: r'$\sqrt{3}$',
          explanation: r'대각선 $= \sqrt{1+1+1} = \sqrt{3}$.',
          hints: ['공간 대각선.', '√3.'],
          difficulty: ProblemDifficulty.medium,
          points: 15,
        ),
      ];
}
