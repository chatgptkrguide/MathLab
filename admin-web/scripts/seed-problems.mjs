/**
 * Seed script: PDF에서 파악한 문제 데이터를 Firestore에 등록
 *
 * - 1.1.1 다항식의 사칙연산 (문제 1~8)
 * - 2.1.1 허수단위와 복소수 (문제 1~6)
 *
 * 실행: cd admin-web && node scripts/seed-problems.mjs
 */

import "dotenv/config";
import { initializeApp, cert, getApps } from "firebase-admin/app";
import { getFirestore, FieldValue } from "firebase-admin/firestore";

// Firebase Admin SDK - uses Application Default Credentials or GOOGLE_APPLICATION_CREDENTIALS
const projectId = process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID || "mathlab-gomath";

if (getApps().length === 0) {
  initializeApp({ projectId });
}

const db = getFirestore();

// ==================== 1.1.1 다항식의 사칙연산 (cm1_1_1_1) ====================
const lesson_cm1_1_1_1 = [
  {
    lessonId: "cm1_1_1_1",
    question: "두 다항식 $A=3x^2+2xy$, $B=-x^2+xy$에 대하여 $A+2B$를 간단히 하면?",
    type: "multipleChoice",
    difficulty: "easy",
    options: ["$x^2+3xy$", "$x^2+4xy$", "$x^2+5xy$", "$2x^2+4xy$", "$2x^2+5xy$"],
    correctAnswer: "$x^2+4xy$",
    explanation: "$A+2B = (3x^2+2xy) + 2(-x^2+xy) = 3x^2+2xy-2x^2+2xy = x^2+4xy$",
    hints: ["$2B$를 먼저 구한 후 $A$와 더하세요"],
    points: 10,
    order: 0,
    imageUrls: [],
  },
  {
    lessonId: "cm1_1_1_1",
    question: "다음 식을 전개한 것으로 바른 것은? $(x^2-2x+4)(x+1)$",
    type: "multipleChoice",
    difficulty: "easy",
    options: [
      "$x^3-x^2-2x+4$",
      "$x^3+x^2-2x+4$",
      "$x^3-x^2+2x+4$",
      "$x^3+x^2+2x+4$",
      "$x^3-x^2+2x-4$",
    ],
    correctAnswer: "$x^3-x^2+2x+4$",
    explanation: "$(x^2-2x+4)(x+1) = x^3+x^2-2x^2-2x+4x+4 = x^3-x^2+2x+4$",
    hints: ["각 항을 $(x+1)$에 분배법칙으로 곱하세요"],
    points: 10,
    order: 1,
    imageUrls: [],
  },
  {
    lessonId: "cm1_1_1_1",
    question: "다항식 $-ab^2+5a^3b+3a^4b^3-2a^2$을 a에 대한 내림차순으로 정리한 것은?",
    type: "multipleChoice",
    difficulty: "medium",
    options: [
      "$-ab^2-2a^2+5a^3b+3a^4b^3$",
      "$3a^4b^3+5a^3b-ab^2-2a^2$",
      "$3a^4b^3+5a^3b-2a^2-ab^2$",
      "$3a^4b^3-2a^2-ab^2+5a^3b$",
      "$3a^4b^3-ab^2+5a^3b-2a^2$",
    ],
    correctAnswer: "$3a^4b^3+5a^3b-2a^2-ab^2$",
    explanation: "a의 차수가 높은 것부터: $3a^4b^3$(4차) → $5a^3b$(3차) → $-2a^2$(2차) → $-ab^2$(1차)",
    hints: ["각 항에서 a의 지수를 확인하고 높은 순서대로 나열하세요"],
    points: 15,
    order: 2,
    imageUrls: [],
  },
  {
    lessonId: "cm1_1_1_1",
    question: "두 다항식 $A=x^2-2x+1$, $B=2x^2+2x-2$에 대하여 $A+B$를 간단히 하면?",
    type: "multipleChoice",
    difficulty: "easy",
    options: ["$x^2-x-1$", "$x^2+x+1$", "$x^2+1$", "$3x^2-1$", "$3x^2+1$"],
    correctAnswer: "$3x^2-1$",
    explanation: "$A+B = (x^2-2x+1)+(2x^2+2x-2) = 3x^2+0x-1 = 3x^2-1$",
    hints: ["동류항끼리 묶어서 계산하세요"],
    points: 10,
    order: 3,
    imageUrls: [],
  },
  {
    lessonId: "cm1_1_1_1",
    question: "다항식 $9xy+4y^3+6x^2y^4$을 x에 대하여 내림차순으로 바르게 정리한 것은?",
    type: "multipleChoice",
    difficulty: "medium",
    options: [
      "$4y^3+6x^2y^4+9xy$",
      "$4y^3+9xy+6x^2y^4$",
      "$6x^2y^4+4y^3+9xy$",
      "$6x^2y^4+9xy+4y^3$",
      "$9xy+6x^2y^4+4y^3$",
    ],
    correctAnswer: "$6x^2y^4+9xy+4y^3$",
    explanation: "x의 차수: $6x^2y^4$(2차) → $9xy$(1차) → $4y^3$(0차)",
    hints: ["각 항에서 x의 지수를 확인하세요"],
    points: 15,
    order: 4,
    imageUrls: [],
  },
  {
    lessonId: "cm1_1_1_1",
    question: "다항식 $y^3-5y+6+12y^2$을 y에 대하여 내림차순으로 정리하였을 때 두 번째 항의 계수를 구하시오.",
    type: "shortAnswer",
    difficulty: "medium",
    options: [],
    correctAnswer: "12",
    explanation: "내림차순 정리: $y^3+12y^2-5y+6$. 두 번째 항은 $12y^2$이므로 계수는 12",
    hints: ["먼저 y에 대한 내림차순으로 정리한 후 두 번째 항을 찾으세요"],
    points: 15,
    order: 5,
    imageUrls: [],
  },
  {
    lessonId: "cm1_1_1_1",
    question: "다음 식을 전개한 것으로 바른 것은? $(3x-2)(x^2+x-3)$",
    type: "multipleChoice",
    difficulty: "medium",
    options: [
      "$3x^3-x^2-11x+6$",
      "$3x^3+x^2-11x+6$",
      "$3x^3-x^2+11x+6$",
      "$3x^3+x^2+11x+6$",
      "$3x^3-x^2+11x-6$",
    ],
    correctAnswer: "$3x^3+x^2-11x+6$",
    explanation: "$(3x-2)(x^2+x-3) = 3x^3+3x^2-9x-2x^2-2x+6 = 3x^3+x^2-11x+6$",
    hints: ["분배법칙을 사용해 각 항을 곱하세요"],
    points: 15,
    order: 6,
    imageUrls: [],
  },
  {
    lessonId: "cm1_1_1_1",
    question: "$(4a^2-b)(a^2+2a-b)$를 바르게 전개한 것은?",
    type: "multipleChoice",
    difficulty: "hard",
    options: [
      "$4a^4-8a^3+5a^2b-2ab+b^2$",
      "$4a^4-8a^3+5a^2b-2ab+b^2$",
      "$4a^4+8a^3-5a^2b-2ab-b^2$",
      "$4a^4+8a^3-5a^2b-2ab+b^2$",
      "$4a^4+8a^3-5a^2b+2ab-b^2$",
    ],
    correctAnswer: "$4a^4+8a^3-5a^2b-2ab+b^2$",
    explanation: "$(4a^2-b)(a^2+2a-b) = 4a^4+8a^3-4a^2b-a^2b-2ab+b^2 = 4a^4+8a^3-5a^2b-2ab+b^2$",
    hints: ["$4a^2$와 $-b$를 각각 $(a^2+2a-b)$에 곱하세요"],
    points: 20,
    order: 7,
    imageUrls: [],
  },
];

// ==================== 2.1.1 허수단위와 복소수 (cm2_1_1_1) ====================
const lesson_cm2_1_1_1 = [
  {
    lessonId: "cm2_1_1_1",
    question: "5의 켤레복소수는? (단, $i=\\sqrt{-1}$)",
    type: "multipleChoice",
    difficulty: "easy",
    options: ["$5$", "$-5$", "$5i$", "$-5i$", "$0$"],
    correctAnswer: "$5$",
    explanation: "5는 실수이므로 허수부분이 0입니다. 켤레복소수는 허수부분의 부호만 바꾸므로 5 자체입니다.",
    hints: ["실수의 켤레복소수는 자기 자신입니다"],
    points: 10,
    order: 0,
    imageUrls: [],
  },
  {
    lessonId: "cm2_1_1_1",
    question: "$-3+6i$의 실수부분을 a, 허수부분을 b라고 할 때, $a-b$의 값을 구하시오. (단, $i=\\sqrt{-1}$)",
    type: "shortAnswer",
    difficulty: "easy",
    options: [],
    correctAnswer: "-9",
    explanation: "$-3+6i$에서 실수부분 $a=-3$, 허수부분 $b=6$이므로 $a-b = -3-6 = -9$",
    hints: ["$a+bi$에서 실수부분은 $a$, 허수부분은 $b$입니다 ($i$ 제외)"],
    points: 10,
    order: 1,
    imageUrls: [],
  },
  {
    lessonId: "cm2_1_1_1",
    question: "7의 실수부분을 a, 허수부분을 b라고 할 때, $a-b$의 값을 구하시오.",
    type: "shortAnswer",
    difficulty: "easy",
    options: [],
    correctAnswer: "7",
    explanation: "7 = 7+0i이므로 실수부분 $a=7$, 허수부분 $b=0$. 따라서 $a-b = 7-0 = 7$",
    hints: ["실수는 허수부분이 0인 복소수입니다"],
    points: 10,
    order: 2,
    imageUrls: [],
  },
  {
    lessonId: "cm2_1_1_1",
    question: "다음 중 허수인 것의 개수를 구하시오. (단, $i=\\sqrt{-1}$)\n$\\sqrt{3}i$, $-\\sqrt{5}$, $\\frac{2}{3}i$, $(2i)^2$, $3+4i$",
    type: "shortAnswer",
    difficulty: "medium",
    options: [],
    correctAnswer: "3",
    explanation: "$\\sqrt{3}i$: 허수, $-\\sqrt{5}$: 실수, $\\frac{2}{3}i$: 허수, $(2i)^2 = -4$: 실수, $3+4i$: 허수. 허수는 3개",
    hints: ["허수는 허수부분이 0이 아닌 복소수입니다", "$(2i)^2 = 4i^2 = -4$는 실수입니다"],
    points: 15,
    order: 3,
    imageUrls: [],
  },
  {
    lessonId: "cm2_1_1_1",
    question: "$4i$의 실수부분을 a, 허수부분을 b라고 할 때, $a+b$의 값을 구하시오. (단, $i=\\sqrt{-1}$)",
    type: "shortAnswer",
    difficulty: "easy",
    options: [],
    correctAnswer: "4",
    explanation: "$4i = 0+4i$이므로 실수부분 $a=0$, 허수부분 $b=4$. $a+b = 0+4 = 4$",
    hints: ["$4i$는 $0+4i$로 쓸 수 있습니다"],
    points: 10,
    order: 4,
    imageUrls: [],
  },
  {
    lessonId: "cm2_1_1_1",
    question: "$5-4i$의 켤레복소수는? (단, $i=\\sqrt{-1}$)",
    type: "multipleChoice",
    difficulty: "easy",
    options: ["$4+5i$", "$4-5i$", "$5+4i$", "$5-4i$", "$-5+4i$"],
    correctAnswer: "$5+4i$",
    explanation: "켤레복소수는 허수부분의 부호를 바꾸면 됩니다. $5-4i$의 켤레복소수는 $5+4i$",
    hints: ["$a+bi$의 켤레복소수는 $a-bi$입니다"],
    points: 10,
    order: 5,
    imageUrls: [],
  },
];

// ==================== SEED ====================

async function seed() {
  const allProblems = [...lesson_cm1_1_1_1, ...lesson_cm2_1_1_1];

  console.log(`\n총 ${allProblems.length}개 문제를 Firestore에 등록합니다...\n`);

  // Check for duplicates per question text
  const problemsToAdd = [];

  for (const problem of allProblems) {
    try {
      const snapshot = await db
        .collection("problems")
        .where("question", "==", problem.question)
        .get();

      if (!snapshot.empty) {
        console.log(`  SKIP (중복): "${problem.question.substring(0, 40)}..."`);
      } else {
        problemsToAdd.push(problem);
      }
    } catch (e) {
      // If query fails, still add
      problemsToAdd.push(problem);
    }
  }

  if (problemsToAdd.length === 0) {
    console.log("\n모든 문제가 이미 존재합니다. 추가 등록 없음.\n");
    process.exit(0);
  }

  console.log(`\n${problemsToAdd.length}개 새 문제를 등록합니다...\n`);

  let count = 0;
  for (const problem of problemsToAdd) {
    try {
      await db.collection("problems").add({
        ...problem,
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      });
      count++;
      const label = problem.lessonId;
      process.stdout.write(`\r  ${count}/${problemsToAdd.length} (${label})`);
    } catch (e) {
      console.error(`\n  등록 실패: ${e.message}`);
    }
  }

  console.log(`\n\n완료! ${count}개 문제가 등록되었습니다.\n`);

  // Summary
  const grouped = {};
  problemsToAdd.forEach((p) => {
    grouped[p.lessonId] = (grouped[p.lessonId] || 0) + 1;
  });
  console.log("등록된 레슨:");
  Object.entries(grouped).forEach(([lid, cnt]) => {
    console.log(`  ${lid}: ${cnt}개`);
  });

  process.exit(0);
}

seed().catch((e) => {
  console.error("시드 실패:", e);
  process.exit(1);
});
