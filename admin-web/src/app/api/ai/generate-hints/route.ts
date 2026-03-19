import { NextRequest, NextResponse } from "next/server";
import OpenAI from "openai";

const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

interface HintRequest {
  question: string;
  type: string;
  options?: string[];
  correctAnswer: string;
  explanation?: string;
  difficulty?: string;
  topic?: string;
}

const SYSTEM_PROMPT = `당신은 GoPS(Guided Problem Solving) 교수법을 적용하는 수학 교육 전문가입니다.

학생이 수학 문제를 풀 때, 정확히 3단계의 힌트를 생성합니다. 각 단계는 교육학적으로 명확한 목적을 가집니다.

## GoPS 3-Step Hint Framework

### Step 1: Cognitive Activation (인지 활성화) - "보이게 한다"
목적: 학생이 문제의 구조를 스스로 인식하도록 유도
규칙:
- 시각적 직관 또는 그래프 기반 사고를 유도한다
- 최소한의 정보만 제공하여 핵심 인식을 촉발한다
- 문제를 다르게 바라보는 관점을 제시한다
- 반드시 질문 형태("~인가요?", "~보이나요?", "~어떨까?")로 끝난다
- 정답이나 풀이 방향을 직접 알려주지 않는다

### Step 2: Strategy Hint (전략 제시) - "생각하게 한다"
목적: 문제 해결을 위한 수학적 접근 전략 제공
규칙:
- 핵심 개념과 문제를 연결하는 수학적 원리를 제시한다
- 구조적 힌트로 수식을 포함한다
- "이제 ~해보자", "~를 구해보자", "~로 변형해보자" 형태의 능동적 가이드로 마무리한다
- 풀이의 방향을 제시하되 구체적 계산은 하지 않는다

### Step 3: Solution Scaffold (해결 구조 제공) - "풀게 한다"
목적: 학생이 거의 스스로 풀 수 있도록 상세한 해결 단계 구조 제공
규칙:
- Step-by-step으로 식을 세우고 중간 계산 과정을 보여준다
- 대입/계산 과정의 대부분을 제시한다
- 최종 답만 학생이 직접 구하도록 마지막 한 단계를 남긴다
- 인지부하를 최소화하기 위해 깔끔하게 구조화한다

## 문제 유형별 조정
- multipleChoice(객관식): Step 1에서 선택지 구조의 차이를 인식하게 유도, Step 3에서 2-3개 선택지까지 좁혀줌
- shortAnswer(단답형): Step 1에서 식의 핵심 구조 인식 유도, Step 3에서 마지막 연산 1개만 남김
- fillInBlank(빈칸채우기): Step 1에서 빈칸 전후 맥락의 패턴 인식 유도, Step 3에서 대입값만 남김
- trueFalse(O/X): Step 1에서 명제의 핵심 조건 재인식, Step 2에서 반례 탐색 전략, Step 3에서 판단만 남김

## 수학 분야별 Step 1 전략
- 대수: 식의 구조(인수분해 가능성, 대칭성, 특수형태) 인식 유도
- 기하: 시각적 직관(보조선, 닮음, 대칭 관계) 유도
- 미적분: 함수의 행동/극한 직관 유도, 부정형 인식
- 확률/통계: 사건 구조(독립/종속, 여사건, 경우의 수 분류) 인식 유도
- 수열: 항 간의 패턴/규칙성 인식 유도

## 수식 표기
- 인라인 수식: $...$
- 블록 수식: $$...$$
- LaTeX 문법 사용 (\\frac{a}{b}, \\sqrt{x}, x^2, \\sum, \\int, \\lim 등)

## 출력 형식
반드시 아래 JSON 형식으로만 응답하세요. JSON 외의 텍스트는 절대 포함하지 마세요.
{
  "hints": [
    {
      "step": 1,
      "label": "인지 활성화",
      "content": "Step 1 힌트 내용 (반드시 질문으로 끝남)"
    },
    {
      "step": 2,
      "label": "전략 제시",
      "content": "Step 2 힌트 내용 (~해보자 형태로 끝남)"
    },
    {
      "step": 3,
      "label": "해결 구조",
      "content": "Step 3 힌트 내용 (마지막 답만 빼고 scaffold 제공)"
    }
  ]
}`;

const TYPE_LABELS: Record<string, string> = {
  multipleChoice: "객관식",
  shortAnswer: "단답형",
  fillInBlank: "빈칸채우기",
  trueFalse: "O/X",
  matching: "매칭",
  dragAndDrop: "드래그앤드롭",
};

export async function POST(req: NextRequest) {
  try {
    const body: HintRequest = await req.json();

    if (!body.question || !body.correctAnswer) {
      return NextResponse.json(
        { error: "question과 correctAnswer는 필수입니다." },
        { status: 400 }
      );
    }

    const optionsText =
      body.options && body.options.length > 0
        ? `\n- 선택지:\n${body.options.map((o, i) => `  ${i + 1}. ${o}`).join("\n")}`
        : "";

    const userPrompt = `## 문제 정보
- 문제: ${body.question}
- 유형: ${TYPE_LABELS[body.type] || body.type}${optionsText}
- 정답: ${body.correctAnswer}
${body.explanation ? `- 풀이: ${body.explanation}` : ""}
${body.difficulty ? `- 난이도: ${body.difficulty}` : ""}
${body.topic ? `- 수학 분야: ${body.topic}` : ""}

위 문제에 대해 GoPS 3-Step 힌트를 생성해주세요.`;

    const completion = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [
        { role: "system", content: SYSTEM_PROMPT },
        { role: "user", content: userPrompt },
      ],
      temperature: 0.4,
      max_tokens: 1500,
    });

    const content = completion.choices[0]?.message?.content?.trim() || "";

    // Parse JSON from response (handle markdown code blocks)
    let parsed: {
      hints: { step: number; label: string; content: string }[];
    };
    try {
      const jsonStr = content
        .replace(/```json?\s*/g, "")
        .replace(/```/g, "")
        .trim();
      parsed = JSON.parse(jsonStr);
    } catch {
      return NextResponse.json(
        { error: "AI 응답을 파싱할 수 없습니다.", raw: content },
        { status: 500 }
      );
    }

    if (!parsed.hints || !Array.isArray(parsed.hints)) {
      return NextResponse.json(
        { error: "유효한 힌트를 생성하지 못했습니다.", raw: content },
        { status: 500 }
      );
    }

    // Return structured hints (with labels) and flat strings (for Firestore)
    const structuredHints = parsed.hints.map((h) => ({
      step: h.step,
      label: h.label,
      content: h.content,
    }));

    const flatHints = parsed.hints.map((h) => h.content);

    return NextResponse.json({
      hints: flatHints,
      structuredHints,
    });
  } catch (error) {
    console.error("Hint generation error:", error);
    return NextResponse.json(
      { error: "힌트 생성 중 오류가 발생했습니다." },
      { status: 500 }
    );
  }
}
