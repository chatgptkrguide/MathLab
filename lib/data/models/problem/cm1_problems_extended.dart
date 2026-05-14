// 공통수학1 — 비어 있던 26개 레슨 문제 세트.
//
// sample_problems.dart 의 분량 폭증을 막기 위해 분리.
// 각 lesson 당 3문제 (easy → medium → hard 분포 기본),
// hints 3개, LaTeX 수식은 raw string r'$...$' 형태.

import 'problem_model.dart';

class Cm1ProblemsExtended {
  Cm1ProblemsExtended._();

  // ============================================================
  // Unit 1.1.4 — 곱셈공식의 변형
  // ============================================================
  static List<ProblemModel> mult4Variation() {
    return [
      ProblemModel(
        id: 'cm1_1_1_4_1',
        lessonId: 'cm1_1_1_4',
        question: r'$(a+b+c)^2$ 을 전개한 식으로 옳은 것은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: [
          r'$a^2+b^2+c^2$',
          r'$a^2+b^2+c^2+2ab+2bc+2ca$',
          r'$a^2+b^2+c^2+ab+bc+ca$',
          r'$a^2+b^2+c^2+abc$',
        ],
        correctAnswer: r'$a^2+b^2+c^2+2ab+2bc+2ca$',
        explanation:
            r'$(a+b+c)^2 = a^2+b^2+c^2+2(ab+bc+ca)$ — 모든 두 항의 곱에 2 가 붙는다.',
        hints: [
          r'$(a+b)^2 = a^2+2ab+b^2$ 를 떠올려보세요.',
          r'$(a+b+c)^2 = \{(a+b)+c\}^2$ 로 묶어 전개합니다.',
          r'서로 다른 두 항의 곱 ab, bc, ca 가 모두 2배로 나옵니다.',
        ],
        points: 10,
      ),
      ProblemModel(
        id: 'cm1_1_1_4_2',
        lessonId: 'cm1_1_1_4',
        question: r'$a+b = 3, ab = 2$ 일 때 $a^2+b^2$ 의 값은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: ['3', '5', '7', '9'],
        correctAnswer: '5',
        explanation:
            r'$a^2+b^2 = (a+b)^2 - 2ab = 3^2 - 2 \cdot 2 = 9-4 = 5$.',
        hints: [
          r'$(a+b)^2 = a^2+2ab+b^2$ 를 변형해 보세요.',
          r'$a^2+b^2 = (a+b)^2 - 2ab$ 가 핵심 변형식.',
          r'대입: $3^2 - 2 \cdot 2$.',
        ],
        points: 15,
      ),
      ProblemModel(
        id: 'cm1_1_1_4_3',
        lessonId: 'cm1_1_1_4',
        question: r'$a^3+b^3$ 을 $a+b, ab$ 로 나타낸 식은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.hard,
        options: [
          r'$(a+b)^3$',
          r'$(a+b)^3 - 3ab(a+b)$',
          r'$(a+b)^3 + 3ab(a+b)$',
          r'$(a+b)(a^2+b^2)$',
        ],
        correctAnswer: r'$(a+b)^3 - 3ab(a+b)$',
        explanation:
            r'$(a+b)^3 = a^3+3a^2b+3ab^2+b^3 = a^3+b^3+3ab(a+b)$ 이므로 $a^3+b^3 = (a+b)^3-3ab(a+b)$.',
        hints: [
          r'$(a+b)^3$ 전개식을 떠올려보세요.',
          r'전개에 $3a^2b+3ab^2 = 3ab(a+b)$ 가 포함됩니다.',
          r'양변에서 $3ab(a+b)$ 를 이항하세요.',
        ],
        points: 20,
      ),
    ];
  }

  // ============================================================
  // Unit 1.3.2 — 여러 가지 인수분해
  // ============================================================
  static List<ProblemModel> factorizationVarious() {
    return [
      ProblemModel(
        id: 'cm1_1_3_2_1',
        lessonId: 'cm1_1_3_2',
        question: r'$x^4 - 5x^2 + 4$ 를 인수분해 하시오.',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: [
          r'$(x^2-1)(x^2-4)$',
          r'$(x^2+1)(x^2-4)$',
          r'$(x-1)(x+1)(x-2)(x+2)$',
          r'A 와 C 둘 다 정답',
        ],
        correctAnswer: r'A 와 C 둘 다 정답',
        explanation:
            r'$x^2 = t$ 치환: $t^2-5t+4 = (t-1)(t-4) = (x^2-1)(x^2-4) = (x-1)(x+1)(x-2)(x+2)$. 모두 같은 식.',
        hints: [
          r'$x^2 = t$ 로 치환해 보세요 (복이차식).',
          r'치환 후 $t^2-5t+4$ 를 인수분해 — $(t-1)(t-4)$.',
          r'다시 $t = x^2$ 대입 후 합차공식으로 한 번 더.',
        ],
        points: 15,
      ),
      ProblemModel(
        id: 'cm1_1_3_2_2',
        lessonId: 'cm1_1_3_2',
        question: r'$x^3 - 2x^2 - x + 2$ 를 인수분해한 결과는?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: [
          r'$(x-1)(x+1)(x-2)$',
          r'$(x+1)(x-1)(x+2)$',
          r'$(x-2)(x^2+1)$',
          r'$(x+2)(x-1)^2$',
        ],
        correctAnswer: r'$(x-1)(x+1)(x-2)$',
        explanation:
            r'$x=1$ 대입 시 $0$ 이므로 $(x-1)$ 이 인수. 조립제법으로 $x^3-2x^2-x+2 = (x-1)(x^2-x-2) = (x-1)(x+1)(x-2)$.',
        hints: [
          r'인수정리: $f(a)=0$ 이면 $(x-a)$ 가 인수.',
          r'$x=1$ 을 대입해 보세요.',
          r'(x-1) 로 나눈 몫을 다시 인수분해.',
        ],
        points: 20,
      ),
      ProblemModel(
        id: 'cm1_1_3_2_3',
        lessonId: 'cm1_1_3_2',
        question: r'$x^2 + y^2 + 2xy - 4$ 를 인수분해 하시오.',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.hard,
        options: [
          r'$(x+y-2)(x+y+2)$',
          r'$(x-y+2)(x-y-2)$',
          r'$(x+y+4)(x+y-1)$',
          r'$(x+2y)(x-2y)$',
        ],
        correctAnswer: r'$(x+y-2)(x+y+2)$',
        explanation:
            r'$x^2+2xy+y^2 = (x+y)^2$. 따라서 $(x+y)^2 - 4 = (x+y)^2 - 2^2 = (x+y-2)(x+y+2)$.',
        hints: [
          r'앞 세 항이 완전제곱식 모양인지 확인하세요.',
          r'$x^2+2xy+y^2 = (x+y)^2$ 로 묶으면 형태가 단순해집니다.',
          r'그러면 $A^2 - 4$ 꼴 — 합차공식.',
        ],
        points: 20,
      ),
    ];
  }

  // ============================================================
  // Unit 2.1.1 — 허수단위와 복소수
  // ============================================================
  static List<ProblemModel> complexUnit() {
    return [
      ProblemModel(
        id: 'cm1_2_1_1_1',
        lessonId: 'cm1_2_1_1',
        question: r'허수단위 $i$ 의 정의로 옳은 것은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: [
          r'$i = \sqrt{1}$',
          r'$i^2 = -1$',
          r'$i = 0$',
          r'$i^2 = 1$',
        ],
        correctAnswer: r'$i^2 = -1$',
        explanation:
            r'허수단위 $i$ 는 $i^2 = -1$ 인 수로 정의된다. 실수 범위에서는 존재하지 않는 새로운 수.',
        hints: [
          '제곱하면 -1 이 되는 수가 무엇인지 생각해보세요.',
          r'실수에서는 $x^2 \geq 0$ 이므로 $x^2 = -1$ 의 해가 없습니다.',
          '이를 위해 새 단위 i 를 도입한 것이 복소수입니다.',
        ],
        points: 10,
      ),
      ProblemModel(
        id: 'cm1_2_1_1_2',
        lessonId: 'cm1_2_1_1',
        question: r'복소수 $z = 3 - 4i$ 의 실수부와 허수부를 차례로 나열한 것은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: ['3, -4', '3, 4', '-4, 3', '3i, -4'],
        correctAnswer: '3, -4',
        explanation:
            r'복소수 $a+bi$ 에서 실수부 $a$, 허수부 $b$. 따라서 $3-4i$ 의 실수부 3, 허수부 -4.',
        hints: [
          r'$z = a + bi$ 형태에서 a 가 실수부, b 가 허수부.',
          '허수부는 i 앞의 계수만, i 는 포함하지 않습니다.',
          r'$3-4i = 3 + (-4)i$ 로 쓰면 명확.',
        ],
        points: 10,
      ),
      ProblemModel(
        id: 'cm1_2_1_1_3',
        lessonId: 'cm1_2_1_1',
        question: r'$a, b$ 가 실수이고 $a + bi = 2 - 3i$ 일 때, $a+b$ 의 값은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: ['-5', '-1', '1', '5'],
        correctAnswer: '-1',
        explanation:
            r'복소수가 같으려면 실수부와 허수부가 각각 같아야 한다. $a=2, b=-3$. 따라서 $a+b=-1$.',
        hints: [
          '복소수 상등 조건을 떠올려보세요.',
          '실수부끼리, 허수부끼리 비교합니다.',
          r'$a = 2, b = -3$ 이 나옵니다.',
        ],
        points: 15,
      ),
    ];
  }

  // ============================================================
  // Unit 2.1.2 — 복소수의 사칙연산
  // ============================================================
  static List<ProblemModel> complexOps() {
    return [
      ProblemModel(
        id: 'cm1_2_1_2_1',
        lessonId: 'cm1_2_1_2',
        question: r'$(2+3i) + (4-i)$ 의 값은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: [r'$6+2i$', r'$6+4i$', r'$8+2i$', r'$6-2i$'],
        correctAnswer: r'$6+2i$',
        explanation: r'실수부끼리, 허수부끼리 더한다: $(2+4) + (3-1)i = 6+2i$.',
        hints: [
          '복소수 덧셈은 실수부·허수부를 각각 더합니다.',
          r'실수부: $2+4$. 허수부: $3+(-1)$.',
          '계산: 6, 2.',
        ],
        points: 10,
      ),
      ProblemModel(
        id: 'cm1_2_1_2_2',
        lessonId: 'cm1_2_1_2',
        question: r'$(1+i)(2-i)$ 를 계산한 값은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: [r'$2-i^2$', r'$3+i$', r'$1+i$', r'$3-i$'],
        correctAnswer: r'$3+i$',
        explanation:
            r'$(1+i)(2-i) = 2 - i + 2i - i^2 = 2 + i - (-1) = 3+i$ ($i^2=-1$).',
        hints: [
          '분배법칙으로 전개하세요.',
          r'$i^2 = -1$ 로 바꾸는 게 핵심.',
          r'$2 - i + 2i + 1$ 정리.',
        ],
        points: 15,
      ),
      ProblemModel(
        id: 'cm1_2_1_2_3',
        lessonId: 'cm1_2_1_2',
        question: r'$\dfrac{1}{1+i}$ 를 $a+bi$ 형태로 나타내면?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.hard,
        options: [
          r'$\dfrac{1}{2} + \dfrac{1}{2}i$',
          r'$\dfrac{1}{2} - \dfrac{1}{2}i$',
          r'$1 - i$',
          r'$1 + i$',
        ],
        correctAnswer: r'$\dfrac{1}{2} - \dfrac{1}{2}i$',
        explanation:
            r'분모의 켤레 $1-i$ 를 곱한다: $\dfrac{1}{1+i} \cdot \dfrac{1-i}{1-i} = \dfrac{1-i}{1-i^2} = \dfrac{1-i}{2}$.',
        hints: [
          '분모를 실수화하려면 켤레복소수를 곱합니다.',
          r'$1+i$ 의 켤레는 $1-i$.',
          r'분모: $(1+i)(1-i) = 1-i^2 = 2$.',
        ],
        points: 20,
      ),
    ];
  }

  // ============================================================
  // Unit 2.1.3 — 음수의 제곱근
  // ============================================================
  static List<ProblemModel> negativeRoot() {
    return [
      ProblemModel(
        id: 'cm1_2_1_3_1',
        lessonId: 'cm1_2_1_3',
        question: r'$\sqrt{-9}$ 의 값은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: [r'$3i$', r'$-3$', r'$9i$', r'$\pm 3i$'],
        correctAnswer: r'$3i$',
        explanation:
            r'$\sqrt{-a} = \sqrt{a}\,i$ ($a>0$). 따라서 $\sqrt{-9} = \sqrt{9}\,i = 3i$.',
        hints: [
          r'$\sqrt{-1} = i$ 이용.',
          r'$\sqrt{-9} = \sqrt{9 \cdot (-1)} = \sqrt{9}\sqrt{-1}$.',
          r'계산: $3 \cdot i$.',
        ],
        points: 10,
      ),
      ProblemModel(
        id: 'cm1_2_1_3_2',
        lessonId: 'cm1_2_1_3',
        question: r'$i^{2026}$ 의 값은? ($i$ 는 허수단위)',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: [r'$1$', r'$-1$', r'$i$', r'$-i$'],
        correctAnswer: r'$-1$',
        explanation:
            r'$i$ 의 거듭제곱은 4 주기 ($i^1=i, i^2=-1, i^3=-i, i^4=1$). $2026 = 4\cdot 506 + 2$ 이므로 $i^{2026} = i^2 = -1$.',
        hints: [
          r'$i$ 의 거듭제곱은 주기가 4 입니다.',
          '지수를 4로 나눈 나머지를 보세요.',
          r'$2026 \div 4$ 의 나머지는 2.',
        ],
        points: 15,
      ),
      ProblemModel(
        id: 'cm1_2_1_3_3',
        lessonId: 'cm1_2_1_3',
        question: r'$\sqrt{-2} \cdot \sqrt{-8}$ 의 값은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.hard,
        options: ['4', '-4', r'$4i$', r'$-4i$'],
        correctAnswer: '-4',
        explanation:
            r'음수의 제곱근 곱은 $\sqrt{-a}\sqrt{-b} = -\sqrt{ab}$ ($a,b>0$). 따라서 $\sqrt{-2}\sqrt{-8} = -\sqrt{16} = -4$.',
        hints: [
          r'$\sqrt{-2} = \sqrt{2}\,i$, $\sqrt{-8} = 2\sqrt{2}\,i$.',
          r'곱: $\sqrt{2}\,i \cdot 2\sqrt{2}\,i = 4i^2$.',
          r'$i^2 = -1$ 이므로 $-4$.',
        ],
        points: 20,
      ),
    ];
  }

  // ============================================================
  // Unit 2.2.1 — 이차방정식의 근의 판별
  // ============================================================
  static List<ProblemModel> quadraticDiscriminant() {
    return [
      ProblemModel(
        id: 'cm1_2_2_1_1',
        lessonId: 'cm1_2_2_1',
        question: r'$x^2 - 4x + 4 = 0$ 의 판별식 $D$ 의 값은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: ['0', '4', '8', '-4'],
        correctAnswer: '0',
        explanation:
            r'$D = b^2 - 4ac = (-4)^2 - 4 \cdot 1 \cdot 4 = 16 - 16 = 0$. 중근.',
        hints: [
          r'$ax^2+bx+c = 0$ 에서 $D = b^2-4ac$.',
          r'$a=1, b=-4, c=4$ 대입.',
          r'$16 - 16$.',
        ],
        points: 10,
      ),
      ProblemModel(
        id: 'cm1_2_2_1_2',
        lessonId: 'cm1_2_2_1',
        question:
            r'$x^2 - 2x + k = 0$ 이 서로 다른 두 실근을 가지려면 $k$ 의 범위는?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: [r'$k > 1$', r'$k < 1$', r'$k \geq 1$', r'$k \leq 1$'],
        correctAnswer: r'$k < 1$',
        explanation:
            r'서로 다른 두 실근 조건: $D>0$. $D = (-2)^2 - 4k = 4 - 4k > 0 \Rightarrow k < 1$.',
        hints: [
          r'서로 다른 두 실근 조건은 $D > 0$.',
          r'$D = 4 - 4k$.',
          r'$4 - 4k > 0$ 풀이.',
        ],
        points: 15,
      ),
      ProblemModel(
        id: 'cm1_2_2_1_3',
        lessonId: 'cm1_2_2_1',
        question: r'$x^2 + (m-1)x + 1 = 0$ 이 중근을 가질 때 $m$ 의 값의 합은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.hard,
        options: ['0', '2', '-2', '4'],
        correctAnswer: '2',
        explanation:
            r'중근 조건 $D=0$: $(m-1)^2 - 4 = 0 \Rightarrow m-1 = \pm 2 \Rightarrow m = 3$ 또는 $m=-1$. 합 $= 2$.',
        hints: [
          r'중근 조건은 $D = 0$.',
          r'$(m-1)^2 = 4$ 에서 두 값을 구하세요.',
          r'$m = 3$ 또는 $m = -1$.',
        ],
        points: 20,
      ),
    ];
  }

  // ============================================================
  // Unit 2.2.2 — 근과 계수의 관계
  // ============================================================
  static List<ProblemModel> quadraticRootCoeff() {
    return [
      ProblemModel(
        id: 'cm1_2_2_2_1',
        lessonId: 'cm1_2_2_2',
        question: r'$x^2 - 5x + 6 = 0$ 의 두 근의 합과 곱은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: ['합 5, 곱 6', '합 -5, 곱 6', '합 5, 곱 -6', '합 6, 곱 5'],
        correctAnswer: '합 5, 곱 6',
        explanation:
            r'$x^2+bx+c=0$ 에서 두 근의 합 $= -b$, 곱 $= c$. 합 $= 5$, 곱 $= 6$.',
        hints: [
          r'근과 계수의 관계: 합 $= -b/a$, 곱 $= c/a$.',
          r'$a = 1, b = -5, c = 6$.',
          '직접 인수분해로 확인: (x-2)(x-3)=0.',
        ],
        points: 10,
      ),
      ProblemModel(
        id: 'cm1_2_2_2_2',
        lessonId: 'cm1_2_2_2',
        question:
            r'$x^2 - 3x + 1 = 0$ 의 두 근을 $\alpha, \beta$ 라 할 때 $\alpha^2+\beta^2$ 의 값은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: ['7', '8', '9', '10'],
        correctAnswer: '7',
        explanation:
            r'$\alpha+\beta=3, \alpha\beta=1$. $\alpha^2+\beta^2 = (\alpha+\beta)^2 - 2\alpha\beta = 9-2 = 7$.',
        hints: [
          r'$\alpha^2+\beta^2$ 는 $\alpha+\beta, \alpha\beta$ 로 표현 가능.',
          r'$\alpha^2+\beta^2 = (\alpha+\beta)^2 - 2\alpha\beta$.',
          r'대입: $3^2 - 2 \cdot 1$.',
        ],
        points: 15,
      ),
      ProblemModel(
        id: 'cm1_2_2_2_3',
        lessonId: 'cm1_2_2_2',
        question:
            r'두 수 $2, -3$ 을 근으로 하고 $x^2$ 의 계수가 1 인 이차방정식은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: [
          r'$x^2 + x - 6 = 0$',
          r'$x^2 - x - 6 = 0$',
          r'$x^2 + x + 6 = 0$',
          r'$x^2 - x + 6 = 0$',
        ],
        correctAnswer: r'$x^2 + x - 6 = 0$',
        explanation:
            r'두 근 $\alpha, \beta$ 를 갖는 이차방정식: $x^2 - (\alpha+\beta)x + \alpha\beta = 0$. 합 $=-1$, 곱 $=-6$.',
        hints: [
          r'두 근을 갖는 이차방정식 공식.',
          r'합 $= 2+(-3)=-1$, 곱 $= 2\cdot(-3)=-6$.',
          r'$x^2 - (\text{합})x + (\text{곱}) = 0$.',
        ],
        points: 15,
      ),
    ];
  }

  // ============================================================
  // Unit 2.3.1 — 이차함수와 이차방정식의 관계
  // ============================================================
  static List<ProblemModel> quadFunctionRelation() {
    return [
      ProblemModel(
        id: 'cm1_2_3_1_1',
        lessonId: 'cm1_2_3_1',
        question: r'이차함수 $y = x^2 - 4$ 의 그래프가 $x$ 축과 만나는 점의 개수는?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: ['0개', '1개', '2개', '3개'],
        correctAnswer: '2개',
        explanation:
            r'$y=0$ 일 때 $x^2 = 4 \Rightarrow x = \pm 2$. 두 점에서 만난다.',
        hints: [
          r'$x$ 축과의 교점은 $y=0$ 으로 두고 푼다.',
          r'$x^2 - 4 = 0$.',
          r'판별식으로도 확인 가능 ($D = 16 > 0$).',
        ],
        points: 10,
      ),
      ProblemModel(
        id: 'cm1_2_3_1_2',
        lessonId: 'cm1_2_3_1',
        question:
            r'이차함수 $y = x^2 - 2x + k$ 의 그래프가 $x$ 축과 만나지 않으려면 $k$ 의 범위는?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: [r'$k > 1$', r'$k < 1$', r'$k \geq 1$', r'$k \leq 1$'],
        correctAnswer: r'$k > 1$',
        explanation:
            r'$x$ 축과 만나지 않으려면 $D < 0$. $D = 4 - 4k < 0 \Rightarrow k > 1$.',
        hints: [
          r'$x$ 축과 만나지 않음 = 실근 없음 = $D < 0$.',
          r'$D = (-2)^2 - 4k$.',
          r'$4 - 4k < 0$.',
        ],
        points: 15,
      ),
      ProblemModel(
        id: 'cm1_2_3_1_3',
        lessonId: 'cm1_2_3_1',
        question:
            r'$y = x^2 + ax + a$ 의 그래프가 $x$ 축에 접할 때 $a$ 의 값을 모두 구하면?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.hard,
        options: ['0, 4', '0, -4', '2, -2', '1, -1'],
        correctAnswer: '0, 4',
        explanation:
            r'접하려면 $D=0$. $a^2 - 4a = 0 \Rightarrow a(a-4)=0 \Rightarrow a=0$ 또는 $a=4$.',
        hints: [
          r'$x$ 축에 접함 = 중근 = $D=0$.',
          r'$D = a^2 - 4a$.',
          r'$a(a-4)=0$.',
        ],
        points: 20,
      ),
    ];
  }

  // ============================================================
  // Unit 2.3.2 — 이차함수의 최대·최소
  // ============================================================
  static List<ProblemModel> quadMinMax() {
    return [
      ProblemModel(
        id: 'cm1_2_3_2_1',
        lessonId: 'cm1_2_3_2',
        question: r'$y = (x-3)^2 + 2$ 의 최솟값은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: ['0', '2', '3', '5'],
        correctAnswer: '2',
        explanation: r'$(x-3)^2 \geq 0$ 이므로 최솟값은 $x=3$ 일 때 $2$.',
        hints: [
          r'$(x-3)^2$ 은 항상 0 이상입니다.',
          r'$x=3$ 일 때 $(x-3)^2 = 0$.',
          r'그때 $y = 0 + 2 = 2$.',
        ],
        points: 10,
      ),
      ProblemModel(
        id: 'cm1_2_3_2_2',
        lessonId: 'cm1_2_3_2',
        question: r'$y = -x^2 + 4x + 1$ 의 최댓값은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: ['1', '4', '5', '9'],
        correctAnswer: '5',
        explanation:
            r'완전제곱: $y = -(x^2-4x) + 1 = -(x-2)^2 + 4 + 1 = -(x-2)^2 + 5$. $x=2$ 에서 최댓값 5.',
        hints: [
          r'$-x^2+4x$ 를 완전제곱식으로 변형.',
          r'$-(x-2)^2 + 4$ 로 정리.',
          r'$-(x-2)^2 \leq 0$ 이므로 최댓값은 꼭짓점.',
        ],
        points: 15,
      ),
      ProblemModel(
        id: 'cm1_2_3_2_3',
        lessonId: 'cm1_2_3_2',
        question:
            r'$0 \leq x \leq 3$ 에서 $y = x^2 - 2x$ 의 최댓값과 최솟값은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.hard,
        options: [
          '최대 3, 최소 -1',
          '최대 0, 최소 -1',
          '최대 3, 최소 0',
          '최대 -1, 최소 0',
        ],
        correctAnswer: '최대 3, 최소 -1',
        explanation:
            r'$y = (x-1)^2 - 1$. 꼭짓점 $x=1$ 에서 최소 $-1$. 구간 끝 $x=3$ 에서 $y=3$ (꼭짓점에서 멀어 큼). 따라서 최대 3, 최소 -1.',
        hints: [
          '꼭짓점 좌표를 먼저 구하세요: x=1.',
          '꼭짓점이 구간 내에 있으면 최솟값은 꼭짓점.',
          '최댓값은 구간 양 끝점 중 꼭짓점에서 먼 쪽.',
        ],
        points: 20,
      ),
    ];
  }

  // ============================================================
  // Unit 2.4.1 — 고차방정식의 풀이
  // ============================================================
  static List<ProblemModel> higherDegreeEqn() {
    return [
      ProblemModel(
        id: 'cm1_2_4_1_1',
        lessonId: 'cm1_2_4_1',
        question: r'$x^3 - 1 = 0$ 의 실근의 개수는?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: ['1', '2', '3', '0'],
        correctAnswer: '1',
        explanation:
            r'$x^3-1 = (x-1)(x^2+x+1)$. 두 번째 인수의 판별식 $D=1-4=-3<0$ 이므로 실근은 $x=1$ 하나뿐.',
        hints: [
          r'$x^3 - 1$ 를 인수분해.',
          r'$a^3-b^3 = (a-b)(a^2+ab+b^2)$.',
          r'$(x-1)(x^2+x+1)=0$ 에서 두 번째 식은 실근 없음.',
        ],
        points: 10,
      ),
      ProblemModel(
        id: 'cm1_2_4_1_2',
        lessonId: 'cm1_2_4_1',
        question: r'$x^3 - 2x^2 - 5x + 6 = 0$ 의 한 실근을 구하면?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: ['1', '-1', '2', '-2'],
        correctAnswer: '1',
        explanation:
            r'인수정리: $x=1$ 대입 $1-2-5+6=0$. 따라서 $x=1$ 이 근.',
        hints: [
          '인수정리: f(a)=0 인 a 를 시험 대입.',
          r'상수항 6 의 약수 (±1, ±2, ±3, ±6) 시도.',
          r'$f(1) = 1 - 2 - 5 + 6$.',
        ],
        points: 15,
      ),
      ProblemModel(
        id: 'cm1_2_4_1_3',
        lessonId: 'cm1_2_4_1',
        question: r'$x^4 - 5x^2 + 4 = 0$ 의 모든 실근의 합은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.hard,
        options: ['0', '5', '-5', '10'],
        correctAnswer: '0',
        explanation:
            r'$x^2 = t$ 치환: $t^2-5t+4=0 \Rightarrow t=1, 4$. $x = \pm 1, \pm 2$. 합 $= 0$.',
        hints: [
          '복이차식 — 치환 사용.',
          r'$t = x^2$ 대입 후 인수분해.',
          r'$x = \pm 1, \pm 2$ 모두 더하면.',
        ],
        points: 20,
      ),
    ];
  }

  // ============================================================
  // Unit 2.4.2 — 삼차방정식의 근과 계수의 관계
  // ============================================================
  static List<ProblemModel> cubicRootCoeff() {
    return [
      ProblemModel(
        id: 'cm1_2_4_2_1',
        lessonId: 'cm1_2_4_2',
        question:
            r'$x^3 - 6x^2 + 11x - 6 = 0$ 의 세 근의 합과 곱을 차례로 나열하면?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: ['6, 6', '-6, 6', '6, -6', '-6, -6'],
        correctAnswer: '6, 6',
        explanation:
            r'$x^3+bx^2+cx+d=0$ 에서 세 근의 합 $=-b$, 두 근씩의 곱의 합 $=c$, 세 근의 곱 $=-d$. 따라서 합 $=6$, 곱 $=6$.',
        hints: [
          r'삼차방정식의 근과 계수: 합 $-b/a$, 두근곱합 $c/a$, 세근곱 $-d/a$.',
          r'$a=1, b=-6, d=-6$.',
          r'합 $=6$, 곱 $=6$.',
        ],
        points: 10,
      ),
      ProblemModel(
        id: 'cm1_2_4_2_2',
        lessonId: 'cm1_2_4_2',
        question:
            r'$x^3+x^2-2x-2=0$ 의 세 근을 $\alpha, \beta, \gamma$ 라 할 때 $\alpha\beta+\beta\gamma+\gamma\alpha$ 의 값은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: ['-2', '-1', '1', '2'],
        correctAnswer: '-2',
        explanation:
            r'$\alpha\beta+\beta\gamma+\gamma\alpha = c/a = -2/1 = -2$.',
        hints: [
          r'두 근씩의 곱의 합 $= c/a$.',
          r'$x^3+x^2-2x-2$ 에서 $c=-2$.',
          r'직접 대입.',
        ],
        points: 15,
      ),
      ProblemModel(
        id: 'cm1_2_4_2_3',
        lessonId: 'cm1_2_4_2',
        question:
            r'세 근의 합이 $2$, 두 근씩의 곱의 합이 $-1$, 세 근의 곱이 $-2$ 인 삼차방정식 ($x^3$ 계수 1) 은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.hard,
        options: [
          r'$x^3 - 2x^2 - x + 2 = 0$',
          r'$x^3 + 2x^2 - x - 2 = 0$',
          r'$x^3 - 2x^2 - x - 2 = 0$',
          r'$x^3 - 2x^2 + x - 2 = 0$',
        ],
        correctAnswer: r'$x^3 - 2x^2 - x + 2 = 0$',
        explanation:
            r'$x^3 - (\text{합})x^2 + (\text{두근곱합})x - (\text{세근곱}) = x^3 - 2x^2 - x + 2 = 0$.',
        hints: [
          r'삼차 일반형: $x^3 - s_1 x^2 + s_2 x - s_3 = 0$.',
          r'$s_1=2, s_2=-1, s_3=-2$.',
          '부호 주의 — 마지막 항.',
        ],
        points: 20,
      ),
    ];
  }

  // ============================================================
  // Unit 2.4.3 — 오메가(ω)의 성질
  // ============================================================
  static List<ProblemModel> omegaProperties() {
    return [
      ProblemModel(
        id: 'cm1_2_4_3_1',
        lessonId: 'cm1_2_4_3',
        question:
            r'$\omega$ 가 $x^3=1$ 의 허근일 때 $\omega^3$ 의 값은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: ['1', '-1', r'$\omega$', '0'],
        correctAnswer: '1',
        explanation: r'$\omega$ 는 $x^3=1$ 의 해 중 하나이므로 $\omega^3=1$.',
        hints: [
          r'$\omega$ 는 $x^3 = 1$ 의 근.',
          '정의에 따라 곧바로.',
          r'대입하면 $\omega^3 = 1$.',
        ],
        points: 10,
      ),
      ProblemModel(
        id: 'cm1_2_4_3_2',
        lessonId: 'cm1_2_4_3',
        question:
            r'$\omega$ 가 $x^3=1$ 의 허근일 때 $1 + \omega + \omega^2$ 의 값은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: ['0', '1', '-1', '3'],
        correctAnswer: '0',
        explanation:
            r'$x^3-1 = (x-1)(x^2+x+1)$ 이고 $\omega$ 는 $x^2+x+1=0$ 의 근이므로 $\omega^2+\omega+1=0$.',
        hints: [
          r'$x^3-1$ 을 인수분해.',
          r'$\omega$ 가 $x^2+x+1=0$ 의 근.',
          '직접 대입.',
        ],
        points: 15,
      ),
      ProblemModel(
        id: 'cm1_2_4_3_3',
        lessonId: 'cm1_2_4_3',
        question:
            r'$\omega$ 가 $x^3=1$ 의 허근일 때 $\omega^{100}$ 의 값을 $\omega$ 또는 $\omega^2$ 로 표현하면?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.hard,
        options: [r'$\omega$', r'$\omega^2$', '1', '-1'],
        correctAnswer: r'$\omega$',
        explanation:
            r'$\omega^3=1$ 이므로 $\omega$ 의 거듭제곱은 주기 3. $100 = 3\cdot 33 + 1$. 따라서 $\omega^{100} = \omega^1 = \omega$.',
        hints: [
          r'$\omega^3 = 1$ 이라 거듭제곱 주기 3.',
          '100 을 3 으로 나눈 나머지.',
          r'나머지 1 — 즉 $\omega^1$.',
        ],
        points: 20,
      ),
    ];
  }

  // ============================================================
  // Unit 2.5.1 — 연립이차방정식
  // ============================================================
  static List<ProblemModel> simultaneousQuad() {
    return [
      ProblemModel(
        id: 'cm1_2_5_1_1',
        lessonId: 'cm1_2_5_1',
        question:
            r'$\begin{cases} x+y=3 \\ xy=2 \end{cases}$ 의 해 $(x,y)$ 의 쌍의 개수는? (순서 구분)',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: ['1', '2', '3', '0'],
        correctAnswer: '2',
        explanation:
            r'$x, y$ 는 $t^2-3t+2=0$ 의 두 근, 즉 1 과 2. 순서를 구분하면 $(1,2),(2,1)$.',
        hints: [
          r'합·곱이 주어진 두 수는 이차방정식의 두 근.',
          r'$t^2 - (\text{합})t + (\text{곱}) = 0$.',
          '근: 1, 2 — 순서 두 가지.',
        ],
        points: 15,
      ),
      ProblemModel(
        id: 'cm1_2_5_1_2',
        lessonId: 'cm1_2_5_1',
        question:
            r'$\begin{cases} x+y=4 \\ x^2+y^2=10 \end{cases}$ 일 때 $xy$ 의 값은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: ['2', '3', '4', '6'],
        correctAnswer: '3',
        explanation:
            r'$x^2+y^2 = (x+y)^2 - 2xy \Rightarrow 10 = 16 - 2xy \Rightarrow xy = 3$.',
        hints: [
          r'$x^2+y^2 = (x+y)^2 - 2xy$.',
          '주어진 값 대입.',
          '식 정리 후 xy 분리.',
        ],
        points: 15,
      ),
      ProblemModel(
        id: 'cm1_2_5_1_3',
        lessonId: 'cm1_2_5_1',
        question:
            r'$\begin{cases} x-y=2 \\ x^2+y^2=10 \end{cases}$ 의 해 $(x,y)$ 중 한 쌍은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.hard,
        options: ['(3, 1)', '(2, 0)', '(1, -1)', '(4, 2)'],
        correctAnswer: '(3, 1)',
        explanation:
            r'$x = y+2$ 대입: $(y+2)^2 + y^2 = 10 \Rightarrow 2y^2+4y-6=0 \Rightarrow y^2+2y-3=0 \Rightarrow y=1$ 또는 $-3$. 따라서 $(3,1)$ 또는 $(-1,-3)$.',
        hints: [
          '대입법 — 일차식을 변수 하나로 풀어 대입.',
          r'$x = y+2$ 대입.',
          r'$y^2+2y-3=0$ 으로 정리.',
        ],
        points: 20,
      ),
    ];
  }

  // ============================================================
  // Unit 2.5.2 — 부정방정식
  // ============================================================
  static List<ProblemModel> indeterminateEqn() {
    return [
      ProblemModel(
        id: 'cm1_2_5_2_1',
        lessonId: 'cm1_2_5_2',
        question: r'자연수 $x, y$ 에 대해 $x+y=5$ 의 해의 개수는?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: ['3', '4', '5', '6'],
        correctAnswer: '4',
        explanation:
            r'$(x,y) = (1,4), (2,3), (3,2), (4,1)$. 자연수 조건이라 $x \geq 1, y \geq 1$. 총 4 쌍.',
        hints: [
          '자연수 = 1 이상 정수.',
          r'$x=1,2,3,4$ 각각에 대응하는 $y$.',
          '쌍의 개수만 세기.',
        ],
        points: 10,
      ),
      ProblemModel(
        id: 'cm1_2_5_2_2',
        lessonId: 'cm1_2_5_2',
        question: r'$xy = 6$ 을 만족하는 자연수 $(x,y)$ 의 쌍의 개수는?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: ['2', '3', '4', '6'],
        correctAnswer: '4',
        explanation:
            r'$6$ 의 약수: 1,2,3,6. $(1,6),(2,3),(3,2),(6,1)$ — 4 쌍.',
        hints: [
          '6 의 약수 모두 찾기: 1, 2, 3, 6.',
          r'$x$ 가 약수면 $y = 6/x$.',
          '순서 다른 쌍 구분.',
        ],
        points: 15,
      ),
      ProblemModel(
        id: 'cm1_2_5_2_3',
        lessonId: 'cm1_2_5_2',
        question:
            r'정수 $x, y$ 에 대해 $x^2 + y^2 = 5$ 의 해의 개수는?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.hard,
        options: ['4', '6', '8', '12'],
        correctAnswer: '8',
        explanation:
            r'$x^2 \in \{0,1,4\}$ 검토. $(x,y) = (\pm 1, \pm 2), (\pm 2, \pm 1)$ — 부호 조합 $2 \cdot 2 \cdot 2 = 8$.',
        hints: [
          '제곱수 합 5 의 분해: 1+4 가 유일.',
          r'$x = \pm 1, \pm 2$ 가능.',
          '부호 조합 모두 세기.',
        ],
        points: 20,
      ),
    ];
  }

  // ============================================================
  // Unit 2.6.1 — 부등식의 성질과 일차부등식
  // ============================================================
  static List<ProblemModel> linearInequality() {
    return [
      ProblemModel(
        id: 'cm1_2_6_1_1',
        lessonId: 'cm1_2_6_1',
        question: r'부등식 $2x - 4 > 0$ 의 해는?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: [r'$x > 2$', r'$x < 2$', r'$x > 4$', r'$x < -2$'],
        correctAnswer: r'$x > 2$',
        explanation: r'$2x > 4 \Rightarrow x > 2$.',
        hints: [
          '상수항을 우변으로 이항.',
          '양변을 양수 2 로 나눔 (부호 유지).',
          r'$x$ 의 범위.',
        ],
        points: 10,
      ),
      ProblemModel(
        id: 'cm1_2_6_1_2',
        lessonId: 'cm1_2_6_1',
        question: r'$-3x + 6 \geq 0$ 의 해는?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: [r'$x \geq 2$', r'$x \leq 2$', r'$x \geq -2$', r'$x \leq -2$'],
        correctAnswer: r'$x \leq 2$',
        explanation:
            r'$-3x \geq -6 \Rightarrow x \leq 2$ (음수로 나눠 부호 반전).',
        hints: [
          '6 을 우변으로 이항.',
          '음수로 나눌 때 부등호 방향이 바뀝니다.',
          r'$-3$ 으로 나누고 부호 반전.',
        ],
        points: 15,
      ),
      ProblemModel(
        id: 'cm1_2_6_1_3',
        lessonId: 'cm1_2_6_1',
        question: r'$2(x-1) < 3x + 5$ 의 해는?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: [r'$x > -7$', r'$x < -7$', r'$x > 7$', r'$x < 7$'],
        correctAnswer: r'$x > -7$',
        explanation:
            r'전개: $2x - 2 < 3x + 5 \Rightarrow -7 < x \Rightarrow x > -7$.',
        hints: [
          '괄호 전개.',
          r'$x$ 항은 우변, 상수는 좌변으로 이항.',
          r'$-7 < x$.',
        ],
        points: 15,
      ),
    ];
  }

  // ============================================================
  // Unit 2.6.2 — 연립일차부등식
  // ============================================================
  static List<ProblemModel> simulLinearIneq() {
    return [
      ProblemModel(
        id: 'cm1_2_6_2_1',
        lessonId: 'cm1_2_6_2',
        question:
            r'연립부등식 $\begin{cases} x > 1 \\ x < 4 \end{cases}$ 의 해는?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: [r'$x > 1$', r'$x < 4$', r'$1 < x < 4$', '해 없음'],
        correctAnswer: r'$1 < x < 4$',
        explanation: r'두 부등식을 모두 만족하는 공통 범위는 $1 < x < 4$.',
        hints: [
          '두 부등식의 교집합.',
          '수직선에 표시해보세요.',
          '겹치는 구간만.',
        ],
        points: 10,
      ),
      ProblemModel(
        id: 'cm1_2_6_2_2',
        lessonId: 'cm1_2_6_2',
        question:
            r'$\begin{cases} 2x - 1 \geq 3 \\ x + 2 < 7 \end{cases}$ 의 해는?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: [
          r'$2 \leq x < 5$',
          r'$x \geq 2$',
          r'$x < 5$',
          '해 없음',
        ],
        correctAnswer: r'$2 \leq x < 5$',
        explanation:
            r'각각 풀면 $x \geq 2$, $x < 5$. 공통: $2 \leq x < 5$.',
        hints: [
          '두 부등식을 각각 풀고 공통범위.',
          r'$2x-1 \geq 3 \Rightarrow x \geq 2$.',
          r'$x+2 < 7 \Rightarrow x < 5$.',
        ],
        points: 15,
      ),
      ProblemModel(
        id: 'cm1_2_6_2_3',
        lessonId: 'cm1_2_6_2',
        question:
            r'$\begin{cases} x + 1 > 3 \\ x - 2 < 0 \end{cases}$ 의 해는?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.hard,
        options: [
          r'$2 < x < 2$',
          '해 없음',
          r'$x > 2$',
          r'$x < 2$',
        ],
        correctAnswer: '해 없음',
        explanation:
            r'각각 $x > 2$, $x < 2$. 두 조건을 동시에 만족하는 $x$ 가 없음 → 해 없음.',
        hints: [
          '각 식을 풀어 봐요.',
          r'$x > 2$ 와 $x < 2$ 가 동시에 가능?',
          '교집합이 공집합.',
        ],
        points: 20,
      ),
    ];
  }

  // ============================================================
  // Unit 2.6.3 — 절댓값이 있는 일차부등식
  // ============================================================
  static List<ProblemModel> absLinearIneq() {
    return [
      ProblemModel(
        id: 'cm1_2_6_3_1',
        lessonId: 'cm1_2_6_3',
        question: r'$|x| < 3$ 의 해는?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: [
          r'$x < 3$',
          r'$x > -3$',
          r'$-3 < x < 3$',
          r'$x < -3$ 또는 $x > 3$',
        ],
        correctAnswer: r'$-3 < x < 3$',
        explanation: r'$|x| < a$ ($a>0$) $\Leftrightarrow -a < x < a$.',
        hints: [
          '절댓값 부등식 기본 형태.',
          r'$|x| < a$ 는 $-a < x < a$.',
          '대입: a = 3.',
        ],
        points: 10,
      ),
      ProblemModel(
        id: 'cm1_2_6_3_2',
        lessonId: 'cm1_2_6_3',
        question: r'$|x - 1| > 2$ 의 해는?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: [
          r'$-1 < x < 3$',
          r'$x < -1$ 또는 $x > 3$',
          r'$x > 3$',
          r'$x < -1$',
        ],
        correctAnswer: r'$x < -1$ 또는 $x > 3$',
        explanation:
            r'$|X| > a$ ($a>0$) $\Leftrightarrow X < -a$ 또는 $X > a$. $x-1 < -2$ 또는 $x-1 > 2$ — $x < -1$ 또는 $x > 3$.',
        hints: [
          r'$|X| > a$ 는 $X < -a$ 또는 $X > a$.',
          r'$X = x-1$ 대입.',
          '각 식 풀이.',
        ],
        points: 15,
      ),
      ProblemModel(
        id: 'cm1_2_6_3_3',
        lessonId: 'cm1_2_6_3',
        question: r'$|2x + 1| \leq 5$ 의 해는?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.hard,
        options: [
          r'$-3 \leq x \leq 2$',
          r'$-2 \leq x \leq 3$',
          r'$-5 \leq x \leq 5$',
          r'$x \leq 2$',
        ],
        correctAnswer: r'$-3 \leq x \leq 2$',
        explanation:
            r'$-5 \leq 2x+1 \leq 5 \Rightarrow -6 \leq 2x \leq 4 \Rightarrow -3 \leq x \leq 2$.',
        hints: [
          r'$|X| \leq a$ 는 $-a \leq X \leq a$.',
          r'$-5 \leq 2x+1 \leq 5$.',
          '각 변에서 1 빼고 2 로 나누기.',
        ],
        points: 20,
      ),
    ];
  }

  // ============================================================
  // Unit 2.7.1 — 이차부등식
  // ============================================================
  static List<ProblemModel> quadInequality() {
    return [
      ProblemModel(
        id: 'cm1_2_7_1_1',
        lessonId: 'cm1_2_7_1',
        question: r'$x^2 - 4 < 0$ 의 해는?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: [
          r'$x < 2$',
          r'$x > -2$',
          r'$-2 < x < 2$',
          r'$x < -2$ 또는 $x > 2$',
        ],
        correctAnswer: r'$-2 < x < 2$',
        explanation:
            r'$x^2 < 4 \Leftrightarrow -2 < x < 2$. 또는 $(x-2)(x+2)<0$ 에서 두 근 사이.',
        hints: [
          r'$(x-2)(x+2) < 0$ 으로 인수분해.',
          '곱이 음수 → 부호가 다름.',
          '두 근 -2, 2 사이.',
        ],
        points: 10,
      ),
      ProblemModel(
        id: 'cm1_2_7_1_2',
        lessonId: 'cm1_2_7_1',
        question: r'$x^2 - 5x + 6 \geq 0$ 의 해는?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: [
          r'$2 \leq x \leq 3$',
          r'$x \leq 2$ 또는 $x \geq 3$',
          r'$x \leq 3$',
          '모든 실수',
        ],
        correctAnswer: r'$x \leq 2$ 또는 $x \geq 3$',
        explanation:
            r'$(x-2)(x-3) \geq 0$. 두 근 밖 — $x \leq 2$ 또는 $x \geq 3$.',
        hints: [
          r'인수분해: $(x-2)(x-3)$.',
          '곱이 0 이상 → 두 인수가 같은 부호 또는 0.',
          '두 근 밖.',
        ],
        points: 15,
      ),
      ProblemModel(
        id: 'cm1_2_7_1_3',
        lessonId: 'cm1_2_7_1',
        question: r'$x^2 + 2x + 5 > 0$ 의 해는?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.hard,
        options: [
          '모든 실수',
          '해 없음',
          r'$x > -1$',
          r'$x < -1$',
        ],
        correctAnswer: '모든 실수',
        explanation:
            r'$D = 4 - 20 = -16 < 0$ — 그래프가 $x$ 축과 만나지 않음. $x^2$ 계수 양수라 항상 양수.',
        hints: [
          '판별식으로 그래프와 x축 관계 확인.',
          r'$D < 0$, $a > 0$.',
          '그래프가 항상 x축 위 — 항상 양수.',
        ],
        points: 20,
      ),
    ];
  }

  // ============================================================
  // Unit 2.7.2 — 연립이차부등식
  // ============================================================
  static List<ProblemModel> simulQuadIneq() {
    return [
      ProblemModel(
        id: 'cm1_2_7_2_1',
        lessonId: 'cm1_2_7_2',
        question:
            r'$\begin{cases} x^2 < 4 \\ x > 0 \end{cases}$ 의 해는?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: [
          r'$0 < x < 2$',
          r'$-2 < x < 0$',
          r'$x > 2$',
          '해 없음',
        ],
        correctAnswer: r'$0 < x < 2$',
        explanation:
            r'$x^2 < 4 \Rightarrow -2 < x < 2$. $x > 0$ 과 공통: $0 < x < 2$.',
        hints: [
          '각 부등식 풀이.',
          r'$x^2 < 4$ 의 해: $-2 < x < 2$.',
          '교집합 (수직선).',
        ],
        points: 15,
      ),
      ProblemModel(
        id: 'cm1_2_7_2_2',
        lessonId: 'cm1_2_7_2',
        question:
            r'$\begin{cases} x^2 - 3x + 2 \leq 0 \\ x \geq 0 \end{cases}$ 의 해는?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: [
          r'$1 \leq x \leq 2$',
          r'$0 \leq x \leq 2$',
          r'$x \geq 1$',
          r'$0 \leq x \leq 1$',
        ],
        correctAnswer: r'$1 \leq x \leq 2$',
        explanation:
            r'$(x-1)(x-2) \leq 0 \Rightarrow 1 \leq x \leq 2$. $x \geq 0$ 와 공통: $1 \leq x \leq 2$.',
        hints: [
          '이차식 인수분해.',
          r'$1 \leq x \leq 2$ 가 첫 식 해.',
          'x>=0 과 교집합 (이미 포함됨).',
        ],
        points: 15,
      ),
      ProblemModel(
        id: 'cm1_2_7_2_3',
        lessonId: 'cm1_2_7_2',
        question:
            r'$\begin{cases} x^2 - x - 6 > 0 \\ x^2 - 4 \leq 0 \end{cases}$ 의 해는?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.hard,
        options: [
          r'$-2 \leq x < -2$',
          r'$-2 \leq x < 3$',
          '해 없음',
          r'$x \geq 3$',
        ],
        correctAnswer: '해 없음',
        explanation:
            r'첫 식: $(x-3)(x+2)>0 \Rightarrow x < -2$ 또는 $x > 3$. 둘째: $-2 \leq x \leq 2$. 교집합: 없음.',
        hints: [
          '각각 인수분해.',
          r'$x<-2$ 또는 $x>3$ vs $-2 \leq x \leq 2$.',
          '겹치는 곳 확인.',
        ],
        points: 20,
      ),
    ];
  }

  // ============================================================
  // Unit 2.7.3 — 이차방정식의 실근의 조건
  // ============================================================
  static List<ProblemModel> realRootCondition() {
    return [
      ProblemModel(
        id: 'cm1_2_7_3_1',
        lessonId: 'cm1_2_7_3',
        question:
            r'$x^2 + 2x + k = 0$ 이 실근을 가질 $k$ 의 범위는?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: [r'$k > 1$', r'$k \leq 1$', r'$k \geq 1$', r'$k < 1$'],
        correctAnswer: r'$k \leq 1$',
        explanation:
            r'실근 조건 $D \geq 0$. $D = 4 - 4k \geq 0 \Rightarrow k \leq 1$.',
        hints: [
          r'실근 조건은 $D \geq 0$.',
          r'$D = 2^2 - 4k$.',
          r'$4 - 4k \geq 0$.',
        ],
        points: 10,
      ),
      ProblemModel(
        id: 'cm1_2_7_3_2',
        lessonId: 'cm1_2_7_3',
        question:
            r'$x^2 - 2kx + k^2 - 4 = 0$ 이 서로 다른 두 실근을 가질 $k$ 의 범위는?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: ['모든 실수', r'$k > 0$', r'$k \neq 0$', r'$|k| < 2$'],
        correctAnswer: '모든 실수',
        explanation:
            r'$D/4 = k^2 - (k^2-4) = 4 > 0$. 항상 $D>0$ — 모든 $k$.',
        hints: [
          r'$D = (2k)^2 - 4(k^2-4)$ 계산.',
          r'$4k^2 - 4k^2 + 16 = 16$.',
          'k 에 관계없이 양수.',
        ],
        points: 15,
      ),
      ProblemModel(
        id: 'cm1_2_7_3_3',
        lessonId: 'cm1_2_7_3',
        question:
            r'$x^2 + (k-1)x + k = 0$ 의 두 근이 모두 양수일 조건은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.hard,
        options: [
          r'$0 < k \leq 3 - 2\sqrt{2}$',
          r'$0 < k < 1$',
          r'$k < 0$',
          r'$k > 3$',
        ],
        correctAnswer: r'$0 < k \leq 3 - 2\sqrt{2}$',
        explanation:
            r'두 양근 조건: $D \geq 0$ (실근), 합 $-(k-1) > 0$ (즉 $k<1$), 곱 $k > 0$. 판별식: $(k-1)^2 - 4k \geq 0 \Rightarrow k^2-6k+1 \geq 0 \Rightarrow k \leq 3-2\sqrt{2}$ 또는 $k \geq 3+2\sqrt{2}$. 종합: $0 < k \leq 3-2\sqrt{2}$.',
        hints: [
          '두 양근 조건 3가지: D≥0, 합>0, 곱>0.',
          r'합 $= -(k-1) > 0 \Rightarrow k<1$, 곱 $=k>0$.',
          '판별식까지 합쳐서 교집합.',
        ],
        points: 25,
      ),
    ];
  }

  // ============================================================
  // Unit 3.1.1 — 합의 법칙과 곱의 법칙
  // ============================================================
  static List<ProblemModel> countingBasics() {
    return [
      ProblemModel(
        id: 'cm1_3_1_1_1',
        lessonId: 'cm1_3_1_1',
        question:
            r'주사위 하나를 던질 때 짝수의 눈 또는 5 가 나오는 경우의 수는?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: ['3', '4', '5', '6'],
        correctAnswer: '4',
        explanation:
            r'짝수 (2,4,6) 3가지, 5 가 1가지. 동시에 일어날 수 없으므로 합의 법칙: $3+1=4$.',
        hints: [
          '두 사건이 동시에 일어날 수 없음 → 합의 법칙.',
          '짝수의 눈은 2, 4, 6.',
          '거기에 5 까지 더해.',
        ],
        points: 10,
      ),
      ProblemModel(
        id: 'cm1_3_1_1_2',
        lessonId: 'cm1_3_1_1',
        question:
            r'서울→부산 가는 길이 3 가지, 부산→제주 가는 길이 2 가지일 때 서울→부산→제주 경로의 수는?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: ['3', '5', '6', '8'],
        correctAnswer: '6',
        explanation:
            r'서울→부산 3 가지 각각에 대해 부산→제주 2 가지 — 곱의 법칙: $3 \times 2 = 6$.',
        hints: [
          '두 단계가 연속될 때 — 곱의 법칙.',
          r'3 \times 2.',
          '각 단계 경우의 수의 곱.',
        ],
        points: 10,
      ),
      ProblemModel(
        id: 'cm1_3_1_1_3',
        lessonId: 'cm1_3_1_1',
        question:
            r'동전 1 개와 주사위 1 개를 동시에 던질 때 가능한 결과의 수는?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: ['6', '8', '12', '36'],
        correctAnswer: '12',
        explanation:
            r'동전 2 가지 × 주사위 6 가지 = 12 가지 (곱의 법칙).',
        hints: [
          '독립적으로 동시에 일어남 — 곱의 법칙.',
          '동전 2 가지 (앞/뒤).',
          r'$2 \times 6$.',
        ],
        points: 15,
      ),
    ];
  }

  // ============================================================
  // Unit 3.1.2 — 순열
  // ============================================================
  static List<ProblemModel> permutation() {
    return [
      ProblemModel(
        id: 'cm1_3_1_2_1',
        lessonId: 'cm1_3_1_2',
        question: r'서로 다른 5 권의 책 중 3 권을 골라 한 줄로 세우는 방법의 수는?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: ['10', '15', '60', '125'],
        correctAnswer: '60',
        explanation: r'${}_5P_3 = 5 \times 4 \times 3 = 60$.',
        hints: [
          '순열 공식.',
          r'${}_nP_r = n(n-1)\cdots(n-r+1)$.',
          r'$5 \times 4 \times 3$.',
        ],
        points: 10,
      ),
      ProblemModel(
        id: 'cm1_3_1_2_2',
        lessonId: 'cm1_3_1_2',
        question: r'$6!$ 의 값은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: ['120', '360', '720', '1440'],
        correctAnswer: '720',
        explanation: r'$6! = 6 \times 5 \times 4 \times 3 \times 2 \times 1 = 720$.',
        hints: [
          '팩토리얼 정의.',
          '1부터 6까지 모두 곱.',
          r'$6 \times 120$.',
        ],
        points: 10,
      ),
      ProblemModel(
        id: 'cm1_3_1_2_3',
        lessonId: 'cm1_3_1_2',
        question:
            r'어른 2 명, 학생 3 명을 한 줄로 세울 때 어른끼리 이웃하도록 세우는 방법의 수는?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.hard,
        options: ['24', '48', '60', '120'],
        correctAnswer: '48',
        explanation:
            r'어른 2 명을 묶음으로 본다: 4 묶음 배열 $4! = 24$. 어른끼리 자리 바꿈 $2! = 2$. 총 $24 \times 2 = 48$.',
        hints: [
          '"이웃" 조건 → 묶음으로 처리.',
          '어른 2 = 1 묶음 → 총 4 단위 배열.',
          '묶음 내부 순열도 곱하기.',
        ],
        points: 20,
      ),
    ];
  }

  // ============================================================
  // Unit 3.1.3 — 조합
  // ============================================================
  static List<ProblemModel> combination() {
    return [
      ProblemModel(
        id: 'cm1_3_1_3_1',
        lessonId: 'cm1_3_1_3',
        question: r'${}_5C_2$ 의 값은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: ['5', '10', '20', '60'],
        correctAnswer: '10',
        explanation:
            r'${}_5C_2 = \dfrac{5 \times 4}{2 \times 1} = 10$.',
        hints: [
          r'조합 공식 ${}_nC_r = \dfrac{{}_nP_r}{r!}$.',
          r'$\dfrac{5 \times 4}{2 \times 1}$.',
          '계산: 20/2.',
        ],
        points: 10,
      ),
      ProblemModel(
        id: 'cm1_3_1_3_2',
        lessonId: 'cm1_3_1_3',
        question:
            r'서로 다른 6 명에서 3 명을 뽑는 방법의 수는?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: ['10', '20', '60', '120'],
        correctAnswer: '20',
        explanation:
            r'${}_6C_3 = \dfrac{6 \times 5 \times 4}{3!} = \dfrac{120}{6} = 20$.',
        hints: [
          '"뽑기"는 조합 (순서 무관).',
          r'${}_6C_3$.',
          r'$\dfrac{6 \cdot 5 \cdot 4}{6}$.',
        ],
        points: 15,
      ),
      ProblemModel(
        id: 'cm1_3_1_3_3',
        lessonId: 'cm1_3_1_3',
        question:
            r'남자 4 명, 여자 3 명에서 남자 2 명, 여자 2 명을 뽑는 방법의 수는?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.hard,
        options: ['9', '12', '18', '24'],
        correctAnswer: '18',
        explanation:
            r'${}_4C_2 \times {}_3C_2 = 6 \times 3 = 18$.',
        hints: [
          '남자 뽑기 × 여자 뽑기 (곱의 법칙).',
          r'${}_4C_2 = 6, {}_3C_2 = 3$.',
          r'$6 \times 3$.',
        ],
        points: 20,
      ),
    ];
  }

  // ============================================================
  // Unit 4.1.1 — 행렬의 뜻
  // ============================================================
  static List<ProblemModel> matrixBasics() {
    return [
      ProblemModel(
        id: 'cm1_4_1_1_1',
        lessonId: 'cm1_4_1_1',
        question:
            r'행렬 $A = \begin{pmatrix} 1 & 2 \\ 3 & 4 \end{pmatrix}$ 의 (1,2) 성분은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: ['1', '2', '3', '4'],
        correctAnswer: '2',
        explanation:
            r'$(i,j)$ 성분은 $i$ 행 $j$ 열의 값. (1,2) 는 1 행 2 열 — 2.',
        hints: [
          '(i,j) 표기에서 i는 행, j는 열.',
          '첫 행 두 번째 열.',
          '값: 2.',
        ],
        points: 10,
      ),
      ProblemModel(
        id: 'cm1_4_1_1_2',
        lessonId: 'cm1_4_1_1',
        question:
            r'$2 \times 3$ 행렬은 성분의 개수가 몇 개인가?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: ['5', '6', '8', '9'],
        correctAnswer: '6',
        explanation: r'$m \times n$ 행렬의 성분 수는 $m \cdot n = 6$.',
        hints: [
          '행 × 열.',
          r'$2 \times 3$.',
          '곱 계산.',
        ],
        points: 10,
      ),
      ProblemModel(
        id: 'cm1_4_1_1_3',
        lessonId: 'cm1_4_1_1',
        question:
            r'$2 \times 2$ 단위행렬 $E$ 의 모든 성분의 합은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: ['0', '1', '2', '4'],
        correctAnswer: '2',
        explanation:
            r'$E = \begin{pmatrix} 1 & 0 \\ 0 & 1 \end{pmatrix}$. 성분 합 $= 1+0+0+1 = 2$.',
        hints: [
          '단위행렬 — 대각선만 1, 나머지 0.',
          r'$2 \times 2$ 단위행렬을 써보세요.',
          '4 개 성분 더하기.',
        ],
        points: 15,
      ),
    ];
  }

  // ============================================================
  // Unit 4.1.2 — 행렬의 덧셈·뺄셈·실수배
  // ============================================================
  static List<ProblemModel> matrixOps() {
    return [
      ProblemModel(
        id: 'cm1_4_1_2_1',
        lessonId: 'cm1_4_1_2',
        question:
            r'$\begin{pmatrix} 1 & 2 \\ 3 & 4 \end{pmatrix} + \begin{pmatrix} 4 & 3 \\ 2 & 1 \end{pmatrix}$ 의 (1,1) 성분은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: ['1', '4', '5', '8'],
        correctAnswer: '5',
        explanation:
            r'행렬 덧셈은 대응 성분끼리 더한다. $(1,1)$ 성분 $= 1+4 = 5$.',
        hints: [
          '같은 위치 성분끼리.',
          '두 (1,1) 성분 1, 4.',
          '1+4.',
        ],
        points: 10,
      ),
      ProblemModel(
        id: 'cm1_4_1_2_2',
        lessonId: 'cm1_4_1_2',
        question:
            r'$3 \begin{pmatrix} 1 & -2 \\ 0 & 4 \end{pmatrix}$ 의 결과 행렬의 모든 성분의 합은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: ['3', '6', '9', '12'],
        correctAnswer: '9',
        explanation:
            r'각 성분에 3 곱: $\begin{pmatrix} 3 & -6 \\ 0 & 12 \end{pmatrix}$. 합 $= 3-6+0+12 = 9$.',
        hints: [
          '실수배는 모든 성분에 실수를 곱.',
          '각각 3 배.',
          '결과 4 개 성분 합.',
        ],
        points: 15,
      ),
      ProblemModel(
        id: 'cm1_4_1_2_3',
        lessonId: 'cm1_4_1_2',
        question:
            r'$\begin{pmatrix} a & 1 \\ 2 & b \end{pmatrix} = \begin{pmatrix} 3 & 1 \\ 2 & -1 \end{pmatrix}$ 일 때 $a + b$ 의 값은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: ['1', '2', '3', '4'],
        correctAnswer: '2',
        explanation:
            r'행렬 상등 — 모든 대응 성분이 같음. $a=3, b=-1$. $a+b=2$.',
        hints: [
          '행렬 상등 — 대응 성분 모두 같음.',
          r'$a = 3, b = -1$.',
          '합 계산.',
        ],
        points: 15,
      ),
    ];
  }

  // ============================================================
  // Unit 4.1.3 — 행렬의 곱셈
  // ============================================================
  static List<ProblemModel> matrixMultiply() {
    return [
      ProblemModel(
        id: 'cm1_4_1_3_1',
        lessonId: 'cm1_4_1_3',
        question:
            r'$\begin{pmatrix} 1 & 2 \end{pmatrix} \begin{pmatrix} 3 \\ 4 \end{pmatrix}$ 의 값은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.easy,
        options: ['7', '11', '12', '14'],
        correctAnswer: '11',
        explanation:
            r'$(1)(3) + (2)(4) = 3 + 8 = 11$.',
        hints: [
          r'$1 \times 2$ 행렬 곱 $2 \times 1$ 행렬 = $1 \times 1$ (스칼라).',
          '대응 성분 곱한 후 합.',
          r'$1 \cdot 3 + 2 \cdot 4$.',
        ],
        points: 10,
      ),
      ProblemModel(
        id: 'cm1_4_1_3_2',
        lessonId: 'cm1_4_1_3',
        question:
            r'$\begin{pmatrix} 1 & 0 \\ 0 & 1 \end{pmatrix} \begin{pmatrix} 2 & 3 \\ 4 & 5 \end{pmatrix}$ 의 결과는?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.medium,
        options: [
          r'$\begin{pmatrix} 2 & 3 \\ 4 & 5 \end{pmatrix}$',
          r'$\begin{pmatrix} 1 & 0 \\ 0 & 1 \end{pmatrix}$',
          r'$\begin{pmatrix} 0 & 0 \\ 0 & 0 \end{pmatrix}$',
          r'$\begin{pmatrix} 2 & 0 \\ 0 & 5 \end{pmatrix}$',
        ],
        correctAnswer: r'$\begin{pmatrix} 2 & 3 \\ 4 & 5 \end{pmatrix}$',
        explanation:
            r'단위행렬 $E$ 와의 곱은 자기 자신: $EA = A$.',
        hints: [
          '단위행렬의 정의 떠올려보세요.',
          r'$EA = AE = A$.',
          '실수의 1 과 같은 역할.',
        ],
        points: 15,
      ),
      ProblemModel(
        id: 'cm1_4_1_3_3',
        lessonId: 'cm1_4_1_3',
        question:
            r'$A = \begin{pmatrix} 1 & 2 \\ 3 & 4 \end{pmatrix}, B = \begin{pmatrix} 0 & 1 \\ 1 & 0 \end{pmatrix}$ 일 때 $AB$ 의 (1,1) 성분은?',
        type: ProblemType.multipleChoice,
        difficulty: ProblemDifficulty.hard,
        options: ['0', '1', '2', '3'],
        correctAnswer: '2',
        explanation:
            r'$(AB)_{11} = (1)(0) + (2)(1) = 2$.',
        hints: [
          'AB 의 (1,1) = A 의 1행 · B 의 1열.',
          'A 의 1행: (1, 2). B 의 1열: (0, 1).',
          r'$1 \cdot 0 + 2 \cdot 1$.',
        ],
        points: 20,
      ),
    ];
  }
}
