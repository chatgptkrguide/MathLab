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
}

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
        ? `\n선택지:\n${body.options.map((o, i) => `${i + 1}. ${o}`).join("\n")}`
        : "";

    const prompt = `당신은 수학 교육 전문가입니다. 다음 수학 문제에 대해 학생이 스스로 풀 수 있도록 도와주는 단계별 힌트 3개를 생성해주세요.

## 문제 정보
- 문제: ${body.question}${optionsText}
- 정답: ${body.correctAnswer}
${body.explanation ? `- 풀이: ${body.explanation}` : ""}
${body.difficulty ? `- 난이도: ${body.difficulty}` : ""}

## 힌트 작성 규칙
1. **힌트 1 (개념 힌트)**: 이 문제를 풀기 위해 필요한 핵심 개념이나 공식을 알려주세요. 정답을 직접 알려주지 마세요.
2. **힌트 2 (적용 힌트)**: 개념을 이 문제에 어떻게 적용하는지 구체적으로 안내하세요. 중간 과정의 일부를 보여줄 수 있습니다.
3. **힌트 3 (풀이 힌트)**: 풀이의 마지막 단계 직전까지 안내하세요. 학생이 마지막 한 단계만 직접 계산하면 답을 구할 수 있도록 합니다.

## 수식 표기
- 수식은 반드시 $...$ (인라인) 또는 $$...$$ (블록) 형태의 LaTeX로 작성하세요.
- 예: $x^2 + 2x + 1 = 0$, $\\frac{a}{b}$, $\\sqrt{x}$

## 출력 형식
반드시 아래 JSON 형식으로만 응답하세요. 다른 텍스트는 포함하지 마세요.
{
  "hints": ["힌트1 내용", "힌트2 내용", "힌트3 내용"]
}`;

    const completion = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [{ role: "user", content: prompt }],
      temperature: 0.7,
      max_tokens: 1000,
    });

    const content = completion.choices[0]?.message?.content?.trim() || "";

    // Parse JSON from response (handle markdown code blocks)
    let parsed: { hints: string[] };
    try {
      const jsonStr = content.replace(/```json?\s*/g, "").replace(/```/g, "").trim();
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

    return NextResponse.json({ hints: parsed.hints });
  } catch (error) {
    console.error("Hint generation error:", error);
    return NextResponse.json(
      { error: "힌트 생성 중 오류가 발생했습니다." },
      { status: 500 }
    );
  }
}
