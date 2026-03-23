import { NextRequest, NextResponse } from "next/server";
import OpenAI from "openai";

function getOpenAI() {
  return new OpenAI({ apiKey: process.env.OPENAI_API_KEY });
}

interface VariantRequest {
  question: string;
  type: string;
  options?: string[];
  correctAnswer: string;
  explanation?: string;
  difficulty?: string;
  variantCount?: number;
  variantType?: "number_change" | "level_up" | "concept_similar";
}

export async function POST(req: NextRequest) {
  try {
    // 인증 확인
    const { verifyAdminRequest } = await import("@/lib/firebase-admin");
    const authResult = await verifyAdminRequest(
      req.headers.get("Authorization")
    );
    if ("error" in authResult) {
      return NextResponse.json(
        { error: authResult.error },
        { status: authResult.status }
      );
    }

    const body: VariantRequest = await req.json();

    if (!body.question || !body.correctAnswer) {
      return NextResponse.json(
        { error: "question과 correctAnswer는 필수입니다." },
        { status: 400 }
      );
    }

    const count = body.variantCount || 3;
    const variantType = body.variantType || "number_change";

    const variantTypeDesc = {
      number_change:
        "숫자만 변경한 변형 문제를 만드세요. 문제의 구조와 풀이 방법은 동일하지만 수치가 다릅니다.",
      level_up:
        "난이도를 한 단계 올린 심화 문제를 만드세요. 같은 개념을 사용하지만 더 복잡한 조건이나 추가 단계가 필요합니다.",
      concept_similar:
        "같은 개념을 활용하지만 다른 형태의 문제를 만드세요. 응용력을 기를 수 있는 문제입니다.",
    };

    const optionsText =
      body.options && body.options.length > 0
        ? `\n선택지:\n${body.options.map((o, i) => `${i + 1}. ${o}`).join("\n")}`
        : "";

    const isMultipleChoice =
      body.type === "multipleChoice" && body.options && body.options.length > 0;

    const prompt = `당신은 수학 교육 전문가입니다. 다음 원본 문제를 기반으로 ${count}개의 변형 문제를 생성해주세요.

## 원본 문제
- 문제: ${body.question}${optionsText}
- 유형: ${body.type === "multipleChoice" ? "객관식" : "단답형"}
- 정답: ${body.correctAnswer}
${body.explanation ? `- 풀이: ${body.explanation}` : ""}
${body.difficulty ? `- 난이도: ${body.difficulty}` : ""}

## 변형 유형
${variantTypeDesc[variantType]}

## 작성 규칙
1. 각 변형 문제는 독립적으로 풀 수 있어야 합니다.
2. 정답이 반드시 정확해야 합니다. 직접 검증하세요.
3. ${isMultipleChoice ? "객관식 문제는 반드시 선택지 4~5개를 포함하세요. 정답이 선택지에 포함되어야 합니다." : "단답형 문제는 정확한 정답을 제공하세요."}
4. 수식은 반드시 $...$ (인라인) 또는 $$...$$ (블록) 형태의 LaTeX로 작성하세요.
5. 풀이(explanation)도 간단히 포함하세요.

## 출력 형식
반드시 아래 JSON 형식으로만 응답하세요. 다른 텍스트는 포함하지 마세요.
{
  "variants": [
    {
      "question": "변형 문제 내용",
      "type": "${body.type}",
      ${isMultipleChoice ? '"options": ["선택지1", "선택지2", "선택지3", "선택지4"],' : '"options": [],'}
      "correctAnswer": "정답",
      "explanation": "간단한 풀이"
    }
  ]
}`;

    const completion = await getOpenAI().chat.completions.create({
      model: "gpt-4o-mini",
      messages: [{ role: "user", content: prompt }],
      temperature: 0.8,
      max_tokens: 3000,
    });

    const content = completion.choices[0]?.message?.content?.trim() || "";

    let parsed: {
      variants: {
        question: string;
        type: string;
        options: string[];
        correctAnswer: string;
        explanation: string;
      }[];
    };
    try {
      const jsonStr = content.replace(/```json?\s*/g, "").replace(/```/g, "").trim();
      parsed = JSON.parse(jsonStr);
    } catch {
      return NextResponse.json(
        { error: "AI 응답을 파싱할 수 없습니다.", raw: content },
        { status: 500 }
      );
    }

    if (!parsed.variants || !Array.isArray(parsed.variants)) {
      return NextResponse.json(
        { error: "유효한 변형 문제를 생성하지 못했습니다.", raw: content },
        { status: 500 }
      );
    }

    return NextResponse.json({ variants: parsed.variants });
  } catch (error) {
    console.error("Variant generation error:", error);
    return NextResponse.json(
      { error: "변형 문제 생성 중 오류가 발생했습니다." },
      { status: 500 }
    );
  }
}
