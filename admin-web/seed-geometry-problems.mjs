/**
 * Seed script: 기하 문제 + 다항식 문제를 Firestore에 등록
 * 실행: node seed-geometry-problems.mjs
 */

import "dotenv/config";
import { initializeApp } from "firebase/app";
import { getFirestore, collection, addDoc, serverTimestamp, getDocs, query, where } from "firebase/firestore";

const firebaseConfig = {
  apiKey: process.env.NEXT_PUBLIC_FIREBASE_API_KEY,
  authDomain: process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN,
  projectId: process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID,
  storageBucket: process.env.NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: process.env.NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID,
  appId: process.env.NEXT_PUBLIC_FIREBASE_APP_ID,
};

if (!firebaseConfig.apiKey || !firebaseConfig.projectId) {
  console.error("❌ .env.local 파일에 Firebase 설정이 없습니다.");
  process.exit(1);
}

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

// ==================== 기하 - 점과 좌표 (lesson_geo_1) ====================
const geoLesson1 = [
  {
    lessonId: "lesson_geo_1",
    question: "좌표평면에서 두 점 A(1, 2)와 B(4, 6) 사이의 거리를 구하세요.",
    type: "multipleChoice",
    difficulty: "easy",
    options: ["5", "4", "6", "7"],
    correctAnswer: "5",
    explanation: "두 점 사이의 거리 공식: √((4-1)² + (6-2)²) = √(9 + 16) = √25 = 5",
    hints: ["두 점 사이의 거리 공식: √((x₂-x₁)² + (y₂-y₁)²)", "x좌표의 차: 4-1=3, y좌표의 차: 6-2=4"],
    points: 10,
    order: 0,
    imageUrls: [],
  },
  {
    lessonId: "lesson_geo_1",
    question: "두 점 A(2, 3)과 B(8, 3) 사이의 거리는?",
    type: "multipleChoice",
    difficulty: "easy",
    options: ["6", "5", "8", "10"],
    correctAnswer: "6",
    explanation: "y좌표가 같으므로 |8-2| = 6",
    hints: ["y좌표가 같은 두 점은 x좌표의 차이가 거리입니다"],
    points: 10,
    order: 1,
    imageUrls: [],
  },
  {
    lessonId: "lesson_geo_1",
    question: "점 A(1, 3)과 점 B(5, 7)의 중점의 좌표는?",
    type: "multipleChoice",
    difficulty: "easy",
    options: ["(3, 5)", "(2, 4)", "(4, 6)", "(3, 4)"],
    correctAnswer: "(3, 5)",
    explanation: "중점 = ((1+5)/2, (3+7)/2) = (3, 5)",
    hints: ["중점 공식: ((x₁+x₂)/2, (y₁+y₂)/2)"],
    points: 10,
    order: 2,
    imageUrls: [],
  },
  {
    lessonId: "lesson_geo_1",
    question: "두 점 A(-2, 1)과 B(4, -3) 사이의 거리를 구하세요. (소수 첫째 자리까지)",
    type: "multipleChoice",
    difficulty: "medium",
    options: ["7.2", "6.5", "8.0", "5.8"],
    correctAnswer: "7.2",
    explanation: "√((4-(-2))² + (-3-1)²) = √(36 + 16) = √52 ≈ 7.2",
    hints: ["거리 공식에 대입하세요", "√52 = √(4×13) = 2√13 ≈ 7.2"],
    points: 15,
    order: 3,
    imageUrls: [],
  },
  {
    lessonId: "lesson_geo_1",
    question: "점 A(2, 1)과 점 B(8, 5)를 1:2로 내분하는 점의 x좌표는?",
    type: "multipleChoice",
    difficulty: "medium",
    options: ["4", "3", "5", "6"],
    correctAnswer: "4",
    explanation: "내분점 x좌표 = (1×8 + 2×2)/(1+2) = (8+4)/3 = 4",
    hints: ["내분점 공식: (m×x₂ + n×x₁)/(m+n)", "m=1, n=2를 대입하세요"],
    points: 15,
    order: 4,
    imageUrls: [],
  },
];

// ==================== 기하 - 직선의 방정식 (lesson_geo_2) ====================
const geoLesson2 = [
  {
    lessonId: "lesson_geo_2",
    question: "기울기가 2이고 y절편이 -3인 직선의 방정식은?",
    type: "multipleChoice",
    difficulty: "easy",
    options: ["y = 2x - 3", "y = -2x + 3", "y = 2x + 3", "y = -3x + 2"],
    correctAnswer: "y = 2x - 3",
    explanation: "y = mx + b에서 m=2, b=-3이므로 y = 2x - 3",
    hints: ["직선의 방정식: y = mx + b (m: 기울기, b: y절편)"],
    points: 10,
    order: 0,
    imageUrls: [],
  },
  {
    lessonId: "lesson_geo_2",
    question: "두 점 (1, 3)과 (3, 7)을 지나는 직선의 기울기는?",
    type: "multipleChoice",
    difficulty: "easy",
    options: ["2", "3", "4", "1"],
    correctAnswer: "2",
    explanation: "기울기 = (7-3)/(3-1) = 4/2 = 2",
    hints: ["기울기 = (y₂-y₁)/(x₂-x₁)"],
    points: 10,
    order: 1,
    imageUrls: [],
  },
  {
    lessonId: "lesson_geo_2",
    question: "직선 y = 3x + 1에 평행하고 점 (2, 5)를 지나는 직선의 방정식은?",
    type: "multipleChoice",
    difficulty: "medium",
    options: ["y = 3x - 1", "y = 3x + 5", "y = 3x + 1", "y = -3x + 11"],
    correctAnswer: "y = 3x - 1",
    explanation: "평행한 직선은 기울기가 같으므로 m=3\ny = 3x + b에 (2, 5) 대입: 5 = 6 + b, b = -1\n따라서 y = 3x - 1",
    hints: ["평행한 두 직선은 기울기가 같습니다", "기울기 3인 직선에 점 (2,5)를 대입하세요"],
    points: 15,
    order: 2,
    imageUrls: [],
  },
  {
    lessonId: "lesson_geo_2",
    question: "직선 y = 2x + 1과 수직인 직선의 기울기는?",
    type: "multipleChoice",
    difficulty: "medium",
    options: ["-1/2", "1/2", "-2", "2"],
    correctAnswer: "-1/2",
    explanation: "수직인 두 직선의 기울기의 곱은 -1\nm₁ × m₂ = -1, 2 × m₂ = -1, m₂ = -1/2",
    hints: ["두 직선이 수직이면 기울기의 곱이 -1입니다"],
    points: 15,
    order: 3,
    imageUrls: [],
  },
  {
    lessonId: "lesson_geo_2",
    question: "x절편이 3이고 y절편이 -6인 직선의 기울기는?",
    type: "multipleChoice",
    difficulty: "easy",
    options: ["2", "-2", "3", "-3"],
    correctAnswer: "2",
    explanation: "두 점 (3, 0)과 (0, -6)을 지남\n기울기 = (-6-0)/(0-3) = -6/-3 = 2",
    hints: ["x절편은 (3, 0), y절편은 (0, -6)입니다", "두 점으로 기울기를 구하세요"],
    points: 10,
    order: 4,
    imageUrls: [],
  },
];

// ==================== 기하 - 원의 방정식 (lesson_geo_4) ====================
const geoLesson4 = [
  {
    lessonId: "lesson_geo_4",
    question: "중심이 (2, 3)이고 반지름이 5인 원의 방정식은?",
    type: "multipleChoice",
    difficulty: "easy",
    options: [
      "(x-2)² + (y-3)² = 25",
      "(x+2)² + (y+3)² = 25",
      "(x-2)² + (y-3)² = 5",
      "(x+2)² + (y-3)² = 25",
    ],
    correctAnswer: "(x-2)² + (y-3)² = 25",
    explanation: "원의 방정식: (x-a)² + (y-b)² = r²\n중심 (2,3), 반지름 5이므로: (x-2)² + (y-3)² = 25",
    hints: ["원의 표준형: (x-a)² + (y-b)² = r²", "반지름 5의 제곱은 25입니다"],
    points: 10,
    order: 0,
    imageUrls: [],
  },
  {
    lessonId: "lesson_geo_4",
    question: "원 x² + y² = 16의 반지름은?",
    type: "multipleChoice",
    difficulty: "easy",
    options: ["4", "16", "8", "2"],
    correctAnswer: "4",
    explanation: "x² + y² = r²에서 r² = 16이므로 r = 4",
    hints: ["원의 방정식 x² + y² = r²에서 r²을 찾으세요"],
    points: 10,
    order: 1,
    imageUrls: [],
  },
  {
    lessonId: "lesson_geo_4",
    question: "원 (x-1)² + (y+2)² = 9의 중심 좌표는?",
    type: "multipleChoice",
    difficulty: "easy",
    options: ["(1, -2)", "(-1, 2)", "(1, 2)", "(-1, -2)"],
    correctAnswer: "(1, -2)",
    explanation: "(x-a)² + (y-b)² = r²에서 a=1, b=-2이므로 중심은 (1, -2)",
    hints: ["(x-a)² + (y-b)²에서 중심은 (a, b)입니다", "y+2 = y-(-2)이므로 b=-2입니다"],
    points: 10,
    order: 2,
    imageUrls: [],
  },
  {
    lessonId: "lesson_geo_4",
    question: "중심이 원점이고 점 (3, 4)를 지나는 원의 방정식은?",
    type: "multipleChoice",
    difficulty: "medium",
    options: ["x² + y² = 25", "x² + y² = 7", "x² + y² = 49", "x² + y² = 12"],
    correctAnswer: "x² + y² = 25",
    explanation: "반지름 = √(3² + 4²) = √25 = 5\n따라서 x² + y² = 25",
    hints: ["원점에서 점 (3,4)까지의 거리가 반지름입니다", "3² + 4² = 9 + 16 = 25"],
    points: 15,
    order: 3,
    imageUrls: [],
  },
  {
    lessonId: "lesson_geo_4",
    question: "원 x² + y² - 4x + 6y - 3 = 0의 반지름은?",
    type: "multipleChoice",
    difficulty: "hard",
    options: ["4", "3", "5", "16"],
    correctAnswer: "4",
    explanation: "완전제곱식으로 변환:\n(x² - 4x + 4) + (y² + 6y + 9) = 3 + 4 + 9\n(x-2)² + (y+3)² = 16\n반지름 = √16 = 4",
    hints: [
      "일반형을 표준형으로 변환하세요",
      "x² - 4x = (x-2)² - 4, y² + 6y = (y+3)² - 9",
    ],
    points: 20,
    order: 4,
    imageUrls: [],
  },
];

// ==================== 다항식 - 덧셈과 뺄셈 (lesson_poly_1) ====================
const polyLesson1 = [
  {
    lessonId: "lesson_poly_1",
    question: "$(2x + 3) + (4x - 1)$을 계산하세요.",
    type: "multipleChoice",
    difficulty: "easy",
    options: ["$6x + 2$", "$6x + 4$", "$6x - 2$", "$2x + 4$"],
    correctAnswer: "$6x + 2$",
    explanation: "동류항끼리 더합니다: 2x + 4x = 6x, 3 + (-1) = 2\n따라서 6x + 2",
    hints: ["동류항끼리 묶어서 계산하세요", "x가 붙은 항끼리, 상수항끼리 더하세요"],
    points: 10,
    order: 0,
    imageUrls: [],
  },
  {
    lessonId: "lesson_poly_1",
    question: "$(3x² + 2x - 1) + (x² - 4x + 5)$를 계산하세요.",
    type: "multipleChoice",
    difficulty: "easy",
    options: ["$4x² - 2x + 4$", "$4x² + 6x + 4$", "$3x² - 2x + 4$", "$4x² - 2x - 4$"],
    correctAnswer: "$4x² - 2x + 4$",
    explanation: "3x² + x² = 4x², 2x + (-4x) = -2x, -1 + 5 = 4\n따라서 4x² - 2x + 4",
    hints: ["같은 차수의 항끼리 더하세요"],
    points: 10,
    order: 1,
    imageUrls: [],
  },
  {
    lessonId: "lesson_poly_1",
    question: "$(5x - 3) - (2x + 7)$을 계산하세요.",
    type: "multipleChoice",
    difficulty: "easy",
    options: ["$3x - 10$", "$3x + 4$", "$7x - 10$", "$3x + 10$"],
    correctAnswer: "$3x - 10$",
    explanation: "빼기를 풀면: 5x - 3 - 2x - 7 = 3x - 10",
    hints: ["빼기를 분배하세요: -(2x + 7) = -2x - 7"],
    points: 10,
    order: 2,
    imageUrls: [],
  },
  {
    lessonId: "lesson_poly_1",
    question: "$(x² + 3x + 2) - (2x² - x + 4)$를 계산하세요.",
    type: "multipleChoice",
    difficulty: "medium",
    options: ["$-x² + 4x - 2$", "$x² + 4x - 2$", "$-x² + 2x - 2$", "$3x² + 2x + 6$"],
    correctAnswer: "$-x² + 4x - 2$",
    explanation: "x² - 2x² = -x², 3x - (-x) = 4x, 2 - 4 = -2\n따라서 -x² + 4x - 2",
    hints: ["빼는 다항식의 부호를 바꿔서 더하세요", "-(2x² - x + 4) = -2x² + x - 4"],
    points: 15,
    order: 3,
    imageUrls: [],
  },
  {
    lessonId: "lesson_poly_1",
    question: "$2(x + 3) + 3(2x - 1)$을 계산하세요.",
    type: "multipleChoice",
    difficulty: "medium",
    options: ["$8x + 3$", "$8x + 5$", "$6x + 3$", "$8x - 3$"],
    correctAnswer: "$8x + 3$",
    explanation: "2x + 6 + 6x - 3 = 8x + 3",
    hints: ["먼저 분배법칙으로 괄호를 풀어주세요", "2(x+3) = 2x + 6, 3(2x-1) = 6x - 3"],
    points: 15,
    order: 4,
    imageUrls: [],
  },
];

// ==================== 다항식 - 곱셈과 나눗셈 (lesson_poly_2) ====================
const polyLesson2 = [
  {
    lessonId: "lesson_poly_2",
    question: "$3x × 2x$를 계산하세요.",
    type: "multipleChoice",
    difficulty: "easy",
    options: ["$6x²$", "$5x²$", "$6x$", "$5x$"],
    correctAnswer: "$6x²$",
    explanation: "3 × 2 = 6, x × x = x²이므로 6x²",
    hints: ["계수끼리 곱하고, 변수끼리 곱하세요"],
    points: 10,
    order: 0,
    imageUrls: [],
  },
  {
    lessonId: "lesson_poly_2",
    question: "$2x(x + 3)$을 전개하세요.",
    type: "multipleChoice",
    difficulty: "easy",
    options: ["$2x² + 6x$", "$2x² + 3x$", "$2x² + 3$", "$2x + 6x$"],
    correctAnswer: "$2x² + 6x$",
    explanation: "분배법칙: 2x × x + 2x × 3 = 2x² + 6x",
    hints: ["분배법칙을 사용하세요: a(b+c) = ab + ac"],
    points: 10,
    order: 1,
    imageUrls: [],
  },
  {
    lessonId: "lesson_poly_2",
    question: "$(x + 2)(x + 3)$을 전개하세요.",
    type: "multipleChoice",
    difficulty: "medium",
    options: ["$x² + 5x + 6$", "$x² + 6x + 5$", "$x² + 5x + 5$", "$2x + 5$"],
    correctAnswer: "$x² + 5x + 6$",
    explanation: "x·x + x·3 + 2·x + 2·3 = x² + 3x + 2x + 6 = x² + 5x + 6",
    hints: ["FOIL 방법을 사용하세요", "(a+b)(c+d) = ac + ad + bc + bd"],
    points: 15,
    order: 2,
    imageUrls: [],
  },
  {
    lessonId: "lesson_poly_2",
    question: "$(x + 1)²$을 전개하세요.",
    type: "multipleChoice",
    difficulty: "medium",
    options: ["$x² + 2x + 1$", "$x² + 1$", "$x² + x + 1$", "$2x + 1$"],
    correctAnswer: "$x² + 2x + 1$",
    explanation: "(a+b)² = a² + 2ab + b²\n= x² + 2(1)(x) + 1² = x² + 2x + 1",
    hints: ["완전제곱식 공식: (a+b)² = a² + 2ab + b²"],
    points: 15,
    order: 3,
    imageUrls: [],
  },
  {
    lessonId: "lesson_poly_2",
    question: "$(x + 3)(x - 3)$을 계산하세요.",
    type: "multipleChoice",
    difficulty: "medium",
    options: ["$x² - 9$", "$x² + 9$", "$x² - 6x + 9$", "$x² - 6$"],
    correctAnswer: "$x² - 9$",
    explanation: "합차공식: (a+b)(a-b) = a² - b²\n= x² - 9",
    hints: ["합차공식을 사용하세요: (a+b)(a-b) = a² - b²"],
    points: 15,
    order: 4,
    imageUrls: [],
  },
];

// ==================== 점과 직선 사이의 거리 (lesson_geo_3) ====================
const geoLesson3 = [
  {
    lessonId: "lesson_geo_3",
    question: "점 (2, 3)에서 직선 3x + 4y - 6 = 0까지의 거리는?",
    type: "multipleChoice",
    difficulty: "medium",
    options: ["2.4", "3.0", "1.8", "4.2"],
    correctAnswer: "2.4",
    explanation: "점과 직선 사이의 거리 = |ax₀ + by₀ + c| / √(a² + b²)\n= |3(2) + 4(3) - 6| / √(9 + 16)\n= |6 + 12 - 6| / √25\n= 12 / 5 = 2.4",
    hints: ["거리 공식: |ax₀ + by₀ + c| / √(a² + b²)", "a=3, b=4, c=-6, 점 (2,3)을 대입하세요"],
    points: 15,
    order: 0,
    imageUrls: [],
  },
  {
    lessonId: "lesson_geo_3",
    question: "점 (1, 0)에서 직선 y = x + 2까지의 거리는? (소수 첫째자리까지)",
    type: "multipleChoice",
    difficulty: "medium",
    options: ["2.1", "1.5", "3.0", "1.0"],
    correctAnswer: "2.1",
    explanation: "y = x + 2 → x - y + 2 = 0\n거리 = |1 - 0 + 2| / √(1 + 1) = 3/√2 ≈ 2.1",
    hints: ["먼저 ax + by + c = 0 형태로 바꾸세요", "x - y + 2 = 0으로 변환됩니다"],
    points: 15,
    order: 1,
    imageUrls: [],
  },
  {
    lessonId: "lesson_geo_3",
    question: "원점에서 직선 3x - 4y + 10 = 0까지의 거리는?",
    type: "multipleChoice",
    difficulty: "easy",
    options: ["2", "3", "5", "10"],
    correctAnswer: "2",
    explanation: "거리 = |3(0) - 4(0) + 10| / √(9 + 16) = 10/5 = 2",
    hints: ["원점은 (0, 0)입니다", "공식에 x₀=0, y₀=0을 대입하세요"],
    points: 10,
    order: 2,
    imageUrls: [],
  },
  {
    lessonId: "lesson_geo_3",
    question: "두 평행한 직선 2x + y - 1 = 0과 2x + y + 4 = 0 사이의 거리는?",
    type: "multipleChoice",
    difficulty: "hard",
    options: ["√5", "5", "3", "2√5"],
    correctAnswer: "√5",
    explanation: "평행한 두 직선 사이의 거리 = |c₁ - c₂| / √(a² + b²)\n= |-1 - 4| / √(4 + 1) = 5/√5 = √5",
    hints: ["평행한 직선의 거리는 한 직선 위의 점에서 다른 직선까지의 거리입니다", "|c₁ - c₂| / √(a² + b²)을 사용하세요"],
    points: 20,
    order: 3,
    imageUrls: [],
  },
  {
    lessonId: "lesson_geo_3",
    question: "점 (0, 5)에서 x축까지의 거리는?",
    type: "multipleChoice",
    difficulty: "easy",
    options: ["5", "0", "10", "√5"],
    correctAnswer: "5",
    explanation: "x축의 방정식은 y = 0\n점 (0, 5)에서 y = 0까지의 거리 = |5| = 5",
    hints: ["x축은 y = 0입니다"],
    points: 10,
    order: 4,
    imageUrls: [],
  },
];

// ==================== SEED ====================

async function seed() {
  // Temporary open rules - no auth needed for seeding
  const allProblems = [
    ...polyLesson1,
    ...polyLesson2,
    ...geoLesson1,
    ...geoLesson2,
    ...geoLesson3,
    ...geoLesson4,
  ];

  console.log(`\n📚 총 ${allProblems.length}개 문제를 Firestore에 등록합니다...\n`);

  // Check existing problems per lesson
  const lessonIds = [...new Set(allProblems.map((p) => p.lessonId))];
  for (const lid of lessonIds) {
    const existing = await getDocs(query(collection(db, "problems"), where("lessonId", "==", lid)));
    if (existing.size > 0) {
      console.log(`⚠️  ${lid}: 이미 ${existing.size}개 문제 존재 → 건너뜁니다`);
      // Remove those problems from allProblems
      const idx = allProblems.findIndex((p) => p.lessonId === lid);
      while (idx >= 0) {
        const i = allProblems.findIndex((p) => p.lessonId === lid);
        if (i < 0) break;
        allProblems.splice(i, 1);
      }
    }
  }

  if (allProblems.length === 0) {
    console.log("\n✅ 모든 레슨에 이미 문제가 존재합니다. 추가 등록 없음.\n");
    process.exit(0);
  }

  let count = 0;
  for (const problem of allProblems) {
    try {
      await addDoc(collection(db, "problems"), {
        ...problem,
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp(),
      });
      count++;
      const lessonLabel = problem.lessonId.replace("lesson_", "");
      process.stdout.write(`\r  ✅ ${count}/${allProblems.length} (${lessonLabel})`);
    } catch (e) {
      console.error(`\n❌ 등록 실패:`, e.message);
    }
  }

  console.log(`\n\n🎉 완료! ${count}개 문제가 등록되었습니다.\n`);
  console.log("등록된 레슨:");
  const grouped = {};
  allProblems.forEach((p) => {
    grouped[p.lessonId] = (grouped[p.lessonId] || 0) + 1;
  });
  Object.entries(grouped).forEach(([lid, cnt]) => {
    console.log(`  📝 ${lid}: ${cnt}개`);
  });

  process.exit(0);
}

seed().catch((e) => {
  console.error("시드 실패:", e);
  process.exit(1);
});
