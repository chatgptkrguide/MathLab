/**
 * Update script: Firestore에 이미 등록된 문제들에 hints 필드를 추가/업데이트
 *
 * - 기존 문제의 question 텍스트로 매칭하여 hints를 업데이트
 * - hints가 비어있거나 없는 문제만 업데이트 (이미 있으면 건너뜀)
 * - --force 옵션으로 모든 문제의 hints를 강제 업데이트 가능
 *
 * 실행: cd admin-web && node scripts/update-hints.mjs
 * 강제: cd admin-web && node scripts/update-hints.mjs --force
 */

import "dotenv/config";
import { initializeApp, getApps } from "firebase-admin/app";
import { getFirestore, FieldValue } from "firebase-admin/firestore";

const projectId =
  process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID || "mathlab-gomath";

if (getApps().length === 0) {
  initializeApp({ projectId });
}

const db = getFirestore();
const forceUpdate = process.argv.includes("--force");

// ==================== 힌트 데이터 (question → hints 매핑) ====================

const hintsByQuestion = new Map();

// --- 1.1.1 다항식의 사칙연산 ---
hintsByQuestion.set(
  "두 다항식 $A=3x^2+2xy$, $B=-x^2+xy$에 대하여 $A+2B$를 간단히 하면?",
  ["$2B$를 먼저 구한 후 $A$와 더하세요"]
);
hintsByQuestion.set(
  "다음 식을 전개한 것으로 바른 것은? $(x^2-2x+4)(x+1)$",
  ["각 항을 $(x+1)$에 분배법칙으로 곱하세요"]
);
hintsByQuestion.set(
  "다항식 $-ab^2+5a^3b+3a^4b^3-2a^2$을 a에 대한 내림차순으로 정리한 것은?",
  ["각 항에서 a의 지수를 확인하고 높은 순서대로 나열하세요"]
);
hintsByQuestion.set(
  "두 다항식 $A=x^2-2x+1$, $B=2x^2+2x-2$에 대하여 $A+B$를 간단히 하면?",
  ["동류항끼리 묶어서 계산하세요"]
);
hintsByQuestion.set(
  "다항식 $9xy+4y^3+6x^2y^4$을 x에 대하여 내림차순으로 바르게 정리한 것은?",
  ["각 항에서 x의 지수를 확인하세요"]
);
hintsByQuestion.set(
  "다항식 $y^3-5y+6+12y^2$을 y에 대하여 내림차순으로 정리하였을 때 두 번째 항의 계수를 구하시오.",
  ["먼저 y에 대한 내림차순으로 정리한 후 두 번째 항을 찾으세요"]
);
hintsByQuestion.set(
  "다음 식을 전개한 것으로 바른 것은? $(3x-2)(x^2+x-3)$",
  ["분배법칙을 사용해 각 항을 곱하세요"]
);
hintsByQuestion.set("$(4a^2-b)(a^2+2a-b)$를 바르게 전개한 것은?", [
  "$4a^2$와 $-b$를 각각 $(a^2+2a-b)$에 곱하세요",
]);

// --- 2.1.1 허수단위와 복소수 ---
hintsByQuestion.set("5의 켤레복소수는? (단, $i=\\sqrt{-1}$)", [
  "실수의 켤레복소수는 자기 자신입니다",
]);
hintsByQuestion.set(
  "$-3+6i$의 실수부분을 a, 허수부분을 b라고 할 때, $a-b$의 값을 구하시오. (단, $i=\\sqrt{-1}$)",
  ["$a+bi$에서 실수부분은 $a$, 허수부분은 $b$입니다 ($i$ 제외)"]
);
hintsByQuestion.set(
  "7의 실수부분을 a, 허수부분을 b라고 할 때, $a-b$의 값을 구하시오.",
  ["실수는 허수부분이 0인 복소수입니다"]
);
hintsByQuestion.set(
  "다음 중 허수인 것의 개수를 구하시오. (단, $i=\\sqrt{-1}$)\n$\\sqrt{3}i$, $-\\sqrt{5}$, $\\frac{2}{3}i$, $(2i)^2$, $3+4i$",
  [
    "허수는 허수부분이 0이 아닌 복소수입니다",
    "$(2i)^2 = 4i^2 = -4$는 실수입니다",
  ]
);
hintsByQuestion.set(
  "$4i$의 실수부분을 a, 허수부분을 b라고 할 때, $a+b$의 값을 구하시오. (단, $i=\\sqrt{-1}$)",
  ["$4i$는 $0+4i$로 쓸 수 있습니다"]
);
hintsByQuestion.set("$5-4i$의 켤레복소수는? (단, $i=\\sqrt{-1}$)", [
  "$a+bi$의 켤레복소수는 $a-bi$입니다",
]);

// --- 기하 - 점과 좌표 ---
hintsByQuestion.set(
  "좌표평면에서 두 점 A(1, 2)와 B(4, 6) 사이의 거리를 구하세요.",
  [
    "두 점 사이의 거리 공식: $\\sqrt{(x_2-x_1)^2 + (y_2-y_1)^2}$",
    "x좌표의 차: 4-1=3, y좌표의 차: 6-2=4",
  ]
);
hintsByQuestion.set("두 점 A(2, 3)과 B(8, 3) 사이의 거리는?", [
  "y좌표가 같은 두 점은 x좌표의 차이가 거리입니다",
]);
hintsByQuestion.set("점 A(1, 3)과 점 B(5, 7)의 중점의 좌표는?", [
  "중점 공식: $\\left(\\frac{x_1+x_2}{2}, \\frac{y_1+y_2}{2}\\right)$",
]);
hintsByQuestion.set(
  "두 점 A(-2, 1)과 B(4, -3) 사이의 거리를 구하세요. (소수 첫째 자리까지)",
  [
    "거리 공식에 대입하세요",
    "$\\sqrt{52} = \\sqrt{4 \\times 13} = 2\\sqrt{13} \\approx 7.2$",
  ]
);
hintsByQuestion.set(
  "점 A(2, 1)과 점 B(8, 5)를 1:2로 내분하는 점의 x좌표는?",
  [
    "내분점 공식: $\\frac{m \\cdot x_2 + n \\cdot x_1}{m+n}$",
    "m=1, n=2를 대입하세요",
  ]
);

// --- 기하 - 직선의 방정식 ---
hintsByQuestion.set("기울기가 2이고 y절편이 -3인 직선의 방정식은?", [
  "직선의 방정식: $y = mx + b$ (m: 기울기, b: y절편)",
]);
hintsByQuestion.set("두 점 (1, 3)과 (3, 7)을 지나는 직선의 기울기는?", [
  "기울기 = $\\frac{y_2 - y_1}{x_2 - x_1}$",
]);
hintsByQuestion.set(
  "직선 y = 3x + 1에 평행하고 점 (2, 5)를 지나는 직선의 방정식은?",
  ["평행한 두 직선은 기울기가 같습니다", "기울기 3인 직선에 점 (2,5)를 대입하세요"]
);
hintsByQuestion.set("직선 y = 2x + 1과 수직인 직선의 기울기는?", [
  "두 직선이 수직이면 기울기의 곱이 -1입니다",
]);
hintsByQuestion.set("x절편이 3이고 y절편이 -6인 직선의 기울기는?", [
  "x절편은 (3, 0), y절편은 (0, -6)입니다",
  "두 점으로 기울기를 구하세요",
]);

// --- 기하 - 점과 직선 사이의 거리 ---
hintsByQuestion.set("점 (2, 3)에서 직선 3x + 4y - 6 = 0까지의 거리는?", [
  "거리 공식: $\\frac{|ax_0 + by_0 + c|}{\\sqrt{a^2 + b^2}}$",
  "a=3, b=4, c=-6, 점 (2,3)을 대입하세요",
]);
hintsByQuestion.set(
  "점 (1, 0)에서 직선 y = x + 2까지의 거리는? (소수 첫째자리까지)",
  [
    "먼저 $ax + by + c = 0$ 형태로 바꾸세요",
    "$x - y + 2 = 0$으로 변환됩니다",
  ]
);
hintsByQuestion.set("원점에서 직선 3x - 4y + 10 = 0까지의 거리는?", [
  "원점은 (0, 0)입니다",
  "공식에 $x_0=0$, $y_0=0$을 대입하세요",
]);
hintsByQuestion.set(
  "두 평행한 직선 2x + y - 1 = 0과 2x + y + 4 = 0 사이의 거리는?",
  [
    "평행한 직선의 거리는 한 직선 위의 점에서 다른 직선까지의 거리입니다",
    "$\\frac{|c_1 - c_2|}{\\sqrt{a^2 + b^2}}$을 사용하세요",
  ]
);
hintsByQuestion.set("점 (0, 5)에서 x축까지의 거리는?", [
  "x축은 $y = 0$입니다",
]);

// --- 기하 - 원의 방정식 ---
hintsByQuestion.set("중심이 (2, 3)이고 반지름이 5인 원의 방정식은?", [
  "원의 표준형: $(x-a)^2 + (y-b)^2 = r^2$",
  "반지름 5의 제곱은 25입니다",
]);
hintsByQuestion.set("원 x² + y² = 16의 반지름은?", [
  "원의 방정식 $x^2 + y^2 = r^2$에서 $r^2$을 찾으세요",
]);
hintsByQuestion.set("원 (x-1)² + (y+2)² = 9의 중심 좌표는?", [
  "$(x-a)^2 + (y-b)^2$에서 중심은 $(a, b)$입니다",
  "$y+2 = y-(-2)$이므로 $b=-2$입니다",
]);
hintsByQuestion.set("중심이 원점이고 점 (3, 4)를 지나는 원의 방정식은?", [
  "원점에서 점 (3,4)까지의 거리가 반지름입니다",
  "$3^2 + 4^2 = 9 + 16 = 25$",
]);
hintsByQuestion.set("원 x² + y² - 4x + 6y - 3 = 0의 반지름은?", [
  "일반형을 표준형으로 변환하세요",
  "$x^2 - 4x = (x-2)^2 - 4$, $y^2 + 6y = (y+3)^2 - 9$",
]);

// --- 다항식 - 덧셈과 뺄셈 ---
hintsByQuestion.set("$(2x + 3) + (4x - 1)$을 계산하세요.", [
  "동류항끼리 묶어서 계산하세요",
  "x가 붙은 항끼리, 상수항끼리 더하세요",
]);
hintsByQuestion.set("$(3x² + 2x - 1) + (x² - 4x + 5)$를 계산하세요.", [
  "같은 차수의 항끼리 더하세요",
]);
hintsByQuestion.set("$(5x - 3) - (2x + 7)$을 계산하세요.", [
  "빼기를 분배하세요: $-(2x + 7) = -2x - 7$",
]);
hintsByQuestion.set("$(x² + 3x + 2) - (2x² - x + 4)$를 계산하세요.", [
  "빼는 다항식의 부호를 바꿔서 더하세요",
  "$-(2x^2 - x + 4) = -2x^2 + x - 4$",
]);
hintsByQuestion.set("$2(x + 3) + 3(2x - 1)$을 계산하세요.", [
  "먼저 분배법칙으로 괄호를 풀어주세요",
  "$2(x+3) = 2x + 6$, $3(2x-1) = 6x - 3$",
]);

// --- 다항식 - 곱셈과 나눗셈 ---
hintsByQuestion.set("$3x × 2x$를 계산하세요.", [
  "계수끼리 곱하고, 변수끼리 곱하세요",
]);
hintsByQuestion.set("$2x(x + 3)$을 전개하세요.", [
  "분배법칙을 사용하세요: $a(b+c) = ab + ac$",
]);
hintsByQuestion.set("$(x + 2)(x + 3)$을 전개하세요.", [
  "FOIL 방법을 사용하세요",
  "$(a+b)(c+d) = ac + ad + bc + bd$",
]);
hintsByQuestion.set("$(x + 1)²$을 전개하세요.", [
  "완전제곱식 공식: $(a+b)^2 = a^2 + 2ab + b^2$",
]);
hintsByQuestion.set("$(x + 3)(x - 3)$을 계산하세요.", [
  "합차공식을 사용하세요: $(a+b)(a-b) = a^2 - b^2$",
]);

// ==================== UPDATE LOGIC ====================

async function updateHints() {
  console.log(
    `\n📝 Firestore 문제들의 hints 업데이트를 시작합니다...${forceUpdate ? " (강제 모드)" : ""}\n`
  );

  // 모든 문제 가져오기
  const snapshot = await db.collection("problems").get();
  console.log(`총 ${snapshot.size}개 문제 발견\n`);

  let updated = 0;
  let skipped = 0;
  let noMatch = 0;

  for (const docSnap of snapshot.docs) {
    const data = docSnap.data();
    const question = data.question || "";
    const existingHints = data.hints || [];

    // 이미 hints가 있고 force 모드가 아니면 건너뜀
    if (existingHints.length > 0 && !forceUpdate) {
      skipped++;
      continue;
    }

    // question으로 매칭
    const newHints = hintsByQuestion.get(question);

    if (newHints && newHints.length > 0) {
      await docSnap.ref.update({
        hints: newHints,
        updatedAt: FieldValue.serverTimestamp(),
      });
      updated++;
      console.log(
        `  ✅ 업데이트: "${question.substring(0, 50)}..." (${newHints.length}개 힌트)`
      );
    } else {
      // 매칭되지 않는 문제 - hint 필드(단일)가 있으면 hints 배열로 변환
      if (data.hint && existingHints.length === 0) {
        await docSnap.ref.update({
          hints: [data.hint],
          updatedAt: FieldValue.serverTimestamp(),
        });
        updated++;
        console.log(
          `  🔄 hint→hints 변환: "${question.substring(0, 50)}..."`
        );
      } else if (existingHints.length === 0) {
        noMatch++;
        console.log(
          `  ⚠️  매칭 없음 (힌트 없음): "${question.substring(0, 50)}..."`
        );
      }
    }
  }

  console.log(`\n${"=".repeat(50)}`);
  console.log(`✅ 업데이트: ${updated}개`);
  console.log(`⏭️  건너뜀 (이미 존재): ${skipped}개`);
  if (noMatch > 0) {
    console.log(`⚠️  매칭 없음: ${noMatch}개 (수동 추가 필요)`);
  }
  console.log(`${"=".repeat(50)}\n`);

  process.exit(0);
}

updateHints().catch((e) => {
  console.error("업데이트 실패:", e);
  process.exit(1);
});
