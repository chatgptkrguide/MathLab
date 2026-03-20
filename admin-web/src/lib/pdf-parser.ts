async function getPdfjsLib() {
  const pdfjsLib = await import("pdfjs-dist");
  if (typeof window !== "undefined") {
    pdfjsLib.GlobalWorkerOptions.workerSrc = `//cdnjs.cloudflare.com/ajax/libs/pdf.js/${pdfjsLib.version}/pdf.worker.min.mjs`;
  }
  return pdfjsLib;
}

export interface ParsedProblem {
  number: number;
  question: string;
  type: "multipleChoice" | "shortAnswer";
  options: string[];
  correctAnswer: string;
  explanation: string;
}

/**
 * PDF 파일에서 페이지별 텍스트를 추출합니다.
 */
export async function extractTextFromPdf(file: File): Promise<string[]> {
  const pdfjsLib = await getPdfjsLib();
  const arrayBuffer = await file.arrayBuffer();
  const pdf = await pdfjsLib.getDocument({ data: arrayBuffer }).promise;
  const pages: string[] = [];

  for (let i = 1; i <= pdf.numPages; i++) {
    const page = await pdf.getPage(i);
    const content = await page.getTextContent();
    const text = content.items
      .map((item) => {
        if ("str" in item) return item.str;
        return "";
      })
      .join("");

    // Reconstruct lines based on y-position changes
    const lines: string[] = [];
    let currentLine = "";
    let lastY: number | null = null;

    for (const item of content.items) {
      if (!("str" in item)) continue;
      const y = item.transform[5]; // y-position
      if (lastY !== null && Math.abs(y - lastY) > 2) {
        if (currentLine.trim()) lines.push(currentLine.trim());
        currentLine = "";
      }
      currentLine += item.str;
      lastY = y;
    }
    if (currentLine.trim()) lines.push(currentLine.trim());

    pages.push(lines.join("\n"));
  }

  return pages;
}

// Circle number characters used in Korean math problems
const CIRCLE_NUMBERS = ["①", "②", "③", "④", "⑤"];

/**
 * 텍스트에서 문제를 파싱합니다.
 * 패턴: 숫자 + "." 또는 숫자만으로 시작하는 줄
 */
export function parseProblems(pages: string[]): ParsedProblem[] {
  const fullText = pages.join("\n\n");
  const problems: ParsedProblem[] = [];

  // Split by problem number pattern: number at start of line followed by dot or space
  // e.g., "1.", "1 ", "12.", "12 "
  const problemPattern = /(?:^|\n)\s*(\d{1,3})\s*[.．)\s]\s*/g;

  const matches: { index: number; number: number }[] = [];
  let match: RegExpExecArray | null;

  while ((match = problemPattern.exec(fullText)) !== null) {
    const num = parseInt(match[1]);
    // Only accept sequential or reasonable problem numbers (1-200)
    if (num >= 1 && num <= 200) {
      matches.push({ index: match.index, number: num });
    }
  }

  // Deduplicate: if same number appears multiple times, keep first occurrence
  // But allow the same number in answer section (we'll handle that separately)
  const seenNumbers = new Set<number>();
  const uniqueMatches = matches.filter((m) => {
    if (seenNumbers.has(m.number)) return false;
    seenNumbers.add(m.number);
    return true;
  });

  for (let i = 0; i < uniqueMatches.length; i++) {
    const current = uniqueMatches[i];
    const nextIndex =
      i + 1 < uniqueMatches.length
        ? uniqueMatches[i + 1].index
        : fullText.length;

    let block = fullText.slice(current.index, nextIndex).trim();

    // Remove the leading number
    block = block.replace(/^\s*\d{1,3}\s*[.．)\s]\s*/, "").trim();

    // Skip very short blocks (likely not real problems)
    if (block.length < 5) continue;

    // Check if it contains circle numbers (multiple choice)
    const hasCircleNumbers = CIRCLE_NUMBERS.some((cn) => block.includes(cn));

    if (hasCircleNumbers) {
      // Parse multiple choice
      const parsed = parseMultipleChoice(block, current.number);
      if (parsed) problems.push(parsed);
    } else {
      // Short answer
      problems.push({
        number: current.number,
        question: cleanQuestion(block),
        type: "shortAnswer",
        options: [],
        correctAnswer: "",
        explanation: "",
      });
    }
  }

  return problems;
}

/**
 * 객관식 문제를 파싱합니다.
 */
function parseMultipleChoice(
  block: string,
  number: number
): ParsedProblem | null {
  // Find where options start (first circle number)
  const firstOptionIndex = Math.min(
    ...CIRCLE_NUMBERS.map((cn) => {
      const idx = block.indexOf(cn);
      return idx === -1 ? Infinity : idx;
    })
  );

  if (firstOptionIndex === Infinity) return null;

  const questionPart = block.slice(0, firstOptionIndex).trim();
  const optionsPart = block.slice(firstOptionIndex);

  // Parse options
  const options: string[] = [];
  for (let i = 0; i < CIRCLE_NUMBERS.length; i++) {
    const current = CIRCLE_NUMBERS[i];
    const next = i + 1 < CIRCLE_NUMBERS.length ? CIRCLE_NUMBERS[i + 1] : null;

    const startIdx = optionsPart.indexOf(current);
    if (startIdx === -1) continue;

    let endIdx: number;
    if (next) {
      const nextIdx = optionsPart.indexOf(next);
      endIdx = nextIdx === -1 ? optionsPart.length : nextIdx;
    } else {
      endIdx = optionsPart.length;
    }

    const optionText = optionsPart
      .slice(startIdx + current.length, endIdx)
      .trim();
    options.push(optionText);
  }

  return {
    number,
    question: cleanQuestion(questionPart),
    type: "multipleChoice",
    options,
    correctAnswer: "",
    explanation: "",
  };
}

/**
 * 정답/풀이 페이지를 파싱합니다.
 * 패턴: 번호 → 정답 → 풀이
 */
export function parseAnswers(
  pages: string[]
): Map<number, { answer: string; explanation: string }> {
  const answers = new Map<number, { answer: string; explanation: string }>();
  const fullText = pages.join("\n\n");

  // Pattern: number followed by answer
  // Common patterns:
  // "1. ③" or "1) 3" or "1 ③" (for multiple choice)
  // "1. 42" or "1) -3" (for short answer)
  const answerPattern =
    /(?:^|\n)\s*(\d{1,3})\s*[.．)\s]\s*([①②③④⑤]|\d+[./\-]?\d*|[^\n]{1,50})/g;

  let match: RegExpExecArray | null;
  while ((match = answerPattern.exec(fullText)) !== null) {
    const num = parseInt(match[1]);
    const answerText = match[2].trim();

    if (num >= 1 && num <= 200 && answerText) {
      // Convert circle number to option index if needed
      const circleIdx = CIRCLE_NUMBERS.indexOf(answerText);
      const answer = circleIdx !== -1 ? String(circleIdx + 1) : answerText;

      // Try to find explanation after the answer on subsequent lines
      const afterMatch = fullText.slice(
        match.index + match[0].length,
        match.index + match[0].length + 500
      );
      const explanationLines: string[] = [];
      const lines = afterMatch.split("\n");

      for (const line of lines) {
        const trimmed = line.trim();
        // Stop if we hit another problem number pattern
        if (/^\d{1,3}\s*[.．)\s]/.test(trimmed)) break;
        if (trimmed) explanationLines.push(trimmed);
        if (explanationLines.length >= 5) break; // limit explanation length
      }

      answers.set(num, {
        answer,
        explanation: explanationLines.join(" "),
      });
    }
  }

  return answers;
}

/**
 * 문제 텍스트를 정리합니다.
 */
function cleanQuestion(text: string): string {
  return text
    .replace(/\s+/g, " ") // collapse whitespace
    .replace(/\n/g, " ") // replace newlines with spaces
    .trim();
}

/**
 * 파싱된 문제에 정답을 매칭합니다.
 */
export function mergeAnswers(
  problems: ParsedProblem[],
  answers: Map<number, { answer: string; explanation: string }>
): ParsedProblem[] {
  return problems.map((problem) => {
    const answerData = answers.get(problem.number);
    if (!answerData) return problem;

    let correctAnswer = answerData.answer;

    // For multiple choice: if answer is a circle number index (1-5),
    // map it to the actual option text
    if (problem.type === "multipleChoice") {
      const idx = parseInt(correctAnswer);
      if (!isNaN(idx) && idx >= 1 && idx <= problem.options.length) {
        correctAnswer = problem.options[idx - 1];
      }
      // If it's a circle number character
      const circleIdx = CIRCLE_NUMBERS.indexOf(correctAnswer);
      if (circleIdx !== -1 && circleIdx < problem.options.length) {
        correctAnswer = problem.options[circleIdx];
      }
    }

    return {
      ...problem,
      correctAnswer,
      explanation: answerData.explanation || problem.explanation,
    };
  });
}
