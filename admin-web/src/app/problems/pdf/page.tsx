"use client";

export const dynamic = "force-dynamic";

import { useState, useEffect, useCallback } from "react";
import AdminLayout from "@/components/layout/admin-layout";
import { bulkCreateProblems, getUnits, getLessons } from "@/lib/firestore";
import {
  Unit,
  Lesson,
  ProblemDifficulty,
  DIFFICULTY_LABELS,
} from "@/lib/types";
import LatexRenderer from "@/components/ui/latex-renderer";
import { GRADES, DEFAULT_GRADE } from "@/lib/grades";
import {
  Upload,
  FileText,
  Check,
  AlertCircle,
  Trash2,
  ChevronDown,
  Loader2,
  Edit3,
  X,
  Save,
} from "lucide-react";
import {
  ParsedProblem,
  extractTextFromPdf,
  parseProblems,
  parseAnswers,
  mergeAnswers,
} from "@/lib/pdf-parser";

interface EditableProblem extends ParsedProblem {
  selected: boolean;
  editing: boolean;
}

export default function PdfUploadPage() {
  const [units, setUnits] = useState<Unit[]>([]);
  const [lessons, setLessons] = useState<Lesson[]>([]);
  const [pdfGrade, setPdfGrade] = useState(DEFAULT_GRADE);
  const [selectedUnitId, setSelectedUnitId] = useState("");
  const [selectedLessonId, setSelectedLessonId] = useState("");
  const [difficulty, setDifficulty] = useState<ProblemDifficulty>("medium");
  const [problems, setProblems] = useState<EditableProblem[]>([]);
  const [parsing, setParsing] = useState(false);
  const [uploading, setUploading] = useState(false);
  const [uploaded, setUploaded] = useState(false);
  const [uploadCount, setUploadCount] = useState(0);
  const [fileName, setFileName] = useState("");
  const [dragOver, setDragOver] = useState(false);
  const [parseError, setParseError] = useState("");
  const [rawPages, setRawPages] = useState<string[]>([]);
  const [showRawText, setShowRawText] = useState(false);

  useEffect(() => {
    loadCurriculum();
  }, []);

  const loadCurriculum = async () => {
    try {
      const [u, l] = await Promise.all([getUnits(), getLessons()]);
      setUnits(u);
      setLessons(l);
    } catch (error) {
      console.error(error);
    }
  };

  const filteredLessons = selectedUnitId
    ? lessons.filter((l) => l.unitId === selectedUnitId)
    : lessons;

  const handleFile = useCallback(async (file: File) => {
    if (!file.name.toLowerCase().endsWith(".pdf")) {
      setParseError("PDF 파일만 업로드할 수 있습니다.");
      return;
    }

    if (file.size > 50 * 1024 * 1024) {
      setParseError("파일 크기가 50MB를 초과합니다.");
      return;
    }

    setFileName(file.name);
    setParsing(true);
    setParseError("");
    setProblems([]);
    setUploaded(false);

    try {
      const pages = await extractTextFromPdf(file);
      setRawPages(pages);

      if (pages.every((p) => p.trim().length === 0)) {
        setParseError(
          "PDF에서 텍스트를 추출할 수 없습니다. 이미지 기반 PDF일 수 있습니다."
        );
        setParsing(false);
        return;
      }

      // Try to separate problem pages from answer pages
      // Heuristic: pages containing "정답" or "풀이" or "해설" are answer pages
      const answerKeywords = ["정답", "풀이", "해설", "답"];
      const problemPages: string[] = [];
      const answerPages: string[] = [];

      pages.forEach((page) => {
        const firstLine = page.split("\n")[0] || "";
        const isAnswerPage = answerKeywords.some(
          (kw) =>
            firstLine.includes(kw) ||
            page.slice(0, 100).includes(kw + " 및") ||
            page.slice(0, 100).includes(kw + "과")
        );
        if (isAnswerPage) {
          answerPages.push(page);
        } else {
          problemPages.push(page);
        }
      });

      // Parse problems from problem pages
      let parsed = parseProblems(
        problemPages.length > 0 ? problemPages : pages
      );

      // Parse answers if answer pages exist
      if (answerPages.length > 0) {
        const answers = parseAnswers(answerPages);
        parsed = mergeAnswers(parsed, answers);
      }

      if (parsed.length === 0) {
        setParseError(
          "문제를 파싱할 수 없습니다. PDF 형식을 확인해주세요. 아래에서 추출된 원본 텍스트를 확인할 수 있습니다."
        );
        setShowRawText(true);
      }

      const editable: EditableProblem[] = parsed.map((p) => ({
        ...p,
        selected: true,
        editing: false,
      }));

      setProblems(editable);
    } catch (error) {
      console.error("PDF parsing error:", error);
      setParseError("PDF 파싱 중 오류가 발생했습니다. 파일이 손상되었거나 지원하지 않는 형식일 수 있습니다.");
    } finally {
      setParsing(false);
    }
  }, []);

  const handleFileInput = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) handleFile(file);
  };

  const handleDrop = useCallback(
    (e: React.DragEvent) => {
      e.preventDefault();
      setDragOver(false);
      const file = e.dataTransfer.files[0];
      if (file) handleFile(file);
    },
    [handleFile]
  );

  const handleDragOver = (e: React.DragEvent) => {
    e.preventDefault();
    setDragOver(true);
  };

  const handleDragLeave = () => {
    setDragOver(false);
  };

  const toggleSelect = (index: number) => {
    setProblems((prev) =>
      prev.map((p, i) =>
        i === index ? { ...p, selected: !p.selected } : p
      )
    );
  };

  const toggleSelectAll = () => {
    const allSelected = problems.every((p) => p.selected);
    setProblems((prev) =>
      prev.map((p) => ({ ...p, selected: !allSelected }))
    );
  };

  const toggleEdit = (index: number) => {
    setProblems((prev) =>
      prev.map((p, i) =>
        i === index ? { ...p, editing: !p.editing } : p
      )
    );
  };

  const updateProblem = (
    index: number,
    field: keyof ParsedProblem,
    value: string | string[]
  ) => {
    setProblems((prev) =>
      prev.map((p, i) =>
        i === index ? { ...p, [field]: value } : p
      )
    );
  };

  const updateOption = (problemIndex: number, optionIndex: number, value: string) => {
    setProblems((prev) =>
      prev.map((p, i) => {
        if (i !== problemIndex) return p;
        const newOptions = [...p.options];
        newOptions[optionIndex] = value;
        return { ...p, options: newOptions };
      })
    );
  };

  const removeProblem = (index: number) => {
    setProblems((prev) => prev.filter((_, i) => i !== index));
  };

  const handleUpload = async () => {
    if (!selectedLessonId) {
      alert("레슨을 선택해주세요.");
      return;
    }

    const selected = problems.filter((p) => p.selected);
    if (selected.length === 0) {
      alert("등록할 문제를 선택해주세요.");
      return;
    }

    if (!confirm(`${selected.length}개의 문제를 등록하시겠습니까?`)) return;

    setUploading(true);
    try {
      const dataToUpload = selected.map((p, idx) => ({
        lessonId: selectedLessonId,
        question: p.question,
        type: p.type as "multipleChoice" | "shortAnswer",
        difficulty,
        options: p.options,
        correctAnswer: p.correctAnswer,
        explanation: p.explanation || "",
        hints: [] as string[],
        points: 10,
        imageUrls: [] as string[],
        order: idx,
      }));

      const count = await bulkCreateProblems(dataToUpload);
      setUploadCount(count);
      setUploaded(true);
      setProblems([]);
    } catch (error) {
      console.error("Upload error:", error);
      setParseError("문제 등록에 실패했습니다. 네트워크 상태를 확인하고 다시 시도해주세요.");
    } finally {
      setUploading(false);
    }
  };

  const selectedCount = problems.filter((p) => p.selected).length;

  return (
    <AdminLayout>
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900">PDF 문제 변환</h1>
        <p className="text-sm text-gray-500 mt-1">
          PDF 파일에서 수학 문제를 추출하여 Firestore에 등록합니다
        </p>
      </div>

      {/* Step 1: PDF Upload */}
      <div className="rounded-xl border border-gray-200 bg-white p-6 mb-6">
        <h3 className="text-sm font-semibold text-gray-900 mb-4">
          1. PDF 파일 업로드
        </h3>

        <label
          className={`flex flex-col items-center justify-center rounded-lg border-2 border-dashed px-4 py-12 cursor-pointer transition-colors ${
            dragOver
              ? "border-blue-500 bg-blue-50"
              : "border-gray-300 hover:border-blue-400 hover:bg-blue-50/50"
          }`}
          onDrop={handleDrop}
          onDragOver={handleDragOver}
          onDragLeave={handleDragLeave}
        >
          {parsing ? (
            <>
              <Loader2 className="h-10 w-10 text-blue-500 mb-3 animate-spin" />
              <span className="text-sm font-medium text-gray-700">
                PDF 파싱 중...
              </span>
            </>
          ) : (
            <>
              <FileText className="h-10 w-10 text-gray-400 mb-3" />
              <span className="text-sm font-medium text-gray-700">
                {fileName
                  ? fileName
                  : "클릭하거나 PDF 파일을 드래그하세요"}
              </span>
              <span className="text-xs text-gray-400 mt-1">
                .pdf 파일만 지원 (최대 50MB)
              </span>
            </>
          )}
          <input
            type="file"
            accept=".pdf"
            className="hidden"
            onChange={handleFileInput}
            disabled={parsing}
          />
        </label>

        {parseError && (
          <div className="mt-4 flex items-start gap-2 rounded-lg bg-red-50 border border-red-200 px-4 py-3">
            <AlertCircle className="h-4 w-4 text-red-500 mt-0.5 flex-shrink-0" />
            <span className="text-sm text-red-700">{parseError}</span>
          </div>
        )}
      </div>

      {/* Raw text toggle (for debugging) */}
      {rawPages.length > 0 && (
        <div className="rounded-xl border border-gray-200 bg-white mb-6">
          <button
            onClick={() => setShowRawText(!showRawText)}
            className="flex items-center justify-between w-full px-6 py-4 text-left"
          >
            <span className="text-sm font-medium text-gray-600">
              추출된 원본 텍스트 보기 ({rawPages.length}페이지)
            </span>
            <ChevronDown
              className={`h-4 w-4 text-gray-400 transition-transform ${
                showRawText ? "rotate-180" : ""
              }`}
            />
          </button>
          {showRawText && (
            <div className="border-t border-gray-200 px-6 py-4 max-h-96 overflow-y-auto">
              {rawPages.map((page, i) => (
                <div key={i} className="mb-4">
                  <div className="text-xs font-medium text-gray-400 mb-1">
                    페이지 {i + 1}
                  </div>
                  <pre className="text-xs text-gray-700 whitespace-pre-wrap bg-gray-50 rounded-lg p-3">
                    {page || "(빈 페이지)"}
                  </pre>
                </div>
              ))}
            </div>
          )}
        </div>
      )}

      {/* Step 2: Lesson Selection */}
      {problems.length > 0 && (
        <div className="rounded-xl border border-gray-200 bg-white p-6 mb-6">
          <h3 className="text-sm font-semibold text-gray-900 mb-4">
            2. 단원/레슨 및 난이도 선택
          </h3>

          {/* 학년 선택 */}
          <div className="flex gap-1.5 flex-wrap mb-4">
            {GRADES.map((g) => (
              <button key={g.key}
                onClick={() => { setPdfGrade(g.key); setSelectedUnitId(""); setSelectedLessonId(""); }}
                className={`rounded-lg px-4 py-2 text-sm font-semibold transition-colors ${
                  pdfGrade === g.key ? "bg-blue-600 text-white" : "bg-gray-100 text-gray-600 hover:bg-gray-200"
                }`}>
                {g.label}
              </button>
            ))}
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            {/* Unit Select */}
            <div>
              <label className="block text-xs font-medium text-gray-600 mb-1.5">
                단원
              </label>
              <div className="relative">
                <select
                  value={selectedUnitId}
                  onChange={(e) => {
                    setSelectedUnitId(e.target.value);
                    setSelectedLessonId("");
                  }}
                  className="w-full appearance-none rounded-lg border border-gray-300 bg-white px-3 py-2.5 pr-8 text-sm text-gray-900 focus:border-blue-500 focus:ring-1 focus:ring-blue-500"
                >
                  <option value="">전체 단원</option>
                  {units.filter((u) => {
                    const grade = GRADES.find((g) => g.key === pdfGrade);
                    return grade?.subjects.includes(u.subject);
                  }).map((unit) => (
                    <option key={unit.id} value={unit.id}>
                      {unit.title}
                    </option>
                  ))}
                </select>
                <ChevronDown className="absolute right-2.5 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400 pointer-events-none" />
              </div>
            </div>

            {/* Lesson Select */}
            <div>
              <label className="block text-xs font-medium text-gray-600 mb-1.5">
                레슨 <span className="text-red-500">*</span>
              </label>
              <div className="relative">
                <select
                  value={selectedLessonId}
                  onChange={(e) => setSelectedLessonId(e.target.value)}
                  className="w-full appearance-none rounded-lg border border-gray-300 bg-white px-3 py-2.5 pr-8 text-sm text-gray-900 focus:border-blue-500 focus:ring-1 focus:ring-blue-500"
                >
                  <option value="">레슨 선택</option>
                  {filteredLessons.map((lesson) => (
                    <option key={lesson.id} value={lesson.id}>
                      {lesson.title}
                    </option>
                  ))}
                </select>
                <ChevronDown className="absolute right-2.5 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400 pointer-events-none" />
              </div>
            </div>

            {/* Difficulty Select */}
            <div>
              <label className="block text-xs font-medium text-gray-600 mb-1.5">
                난이도
              </label>
              <div className="relative">
                <select
                  value={difficulty}
                  onChange={(e) =>
                    setDifficulty(e.target.value as ProblemDifficulty)
                  }
                  className="w-full appearance-none rounded-lg border border-gray-300 bg-white px-3 py-2.5 pr-8 text-sm text-gray-900 focus:border-blue-500 focus:ring-1 focus:ring-blue-500"
                >
                  {Object.entries(DIFFICULTY_LABELS).map(([key, label]) => (
                    <option key={key} value={key}>
                      {label}
                    </option>
                  ))}
                </select>
                <ChevronDown className="absolute right-2.5 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400 pointer-events-none" />
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Success Message */}
      {uploaded && (
        <div className="rounded-xl border border-green-200 bg-green-50 p-6 mb-6">
          <div className="flex items-center gap-3">
            <Check className="h-6 w-6 text-green-600" />
            <div>
              <h3 className="text-sm font-semibold text-green-900">
                등록 완료
              </h3>
              <p className="text-sm text-green-700">
                {uploadCount}개의 문제가 등록되었습니다.
              </p>
            </div>
          </div>
        </div>
      )}

      {/* Step 3: Preview & Edit */}
      {problems.length > 0 && (
        <div className="rounded-xl border border-gray-200 bg-white mb-6">
          {/* Header */}
          <div className="flex items-center justify-between border-b border-gray-200 px-6 py-4">
            <div className="flex items-center gap-4">
              <h3 className="text-sm font-semibold text-gray-900">
                3. 파싱 결과 ({problems.length}개 문제)
              </h3>
              <button
                onClick={toggleSelectAll}
                className="text-xs text-blue-600 hover:text-blue-800"
              >
                {problems.every((p) => p.selected)
                  ? "전체 해제"
                  : "전체 선택"}
              </button>
            </div>
            <button
              onClick={handleUpload}
              disabled={
                uploading || selectedCount === 0 || !selectedLessonId
              }
              className="flex items-center gap-2 rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              <Upload className="h-4 w-4" />
              {uploading
                ? "등록 중..."
                : `${selectedCount}개 문제 등록`}
            </button>
          </div>

          {/* Problem list */}
          <div className="divide-y divide-gray-100 max-h-[700px] overflow-y-auto">
            {problems.map((problem, index) => (
              <div
                key={index}
                className={`px-6 py-4 ${
                  !problem.selected ? "opacity-50" : ""
                }`}
              >
                {problem.editing ? (
                  /* Edit Mode */
                  <ProblemEditor
                    problem={problem}
                    index={index}
                    onUpdate={updateProblem}
                    onUpdateOption={updateOption}
                    onClose={() => toggleEdit(index)}
                  />
                ) : (
                  /* View Mode */
                  <div className="flex items-start gap-3">
                    {/* Checkbox */}
                    <input
                      type="checkbox"
                      checked={problem.selected}
                      onChange={() => toggleSelect(index)}
                      className="mt-1 h-4 w-4 rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                    />

                    {/* Number */}
                    <span className="flex h-6 w-6 items-center justify-center rounded-full bg-gray-100 text-xs font-medium text-gray-600 flex-shrink-0 mt-0.5">
                      {problem.number}
                    </span>

                    {/* Content */}
                    <div className="flex-1 min-w-0">
                      <div className="text-sm text-gray-900 mb-2">
                        <LatexRenderer text={problem.question} />
                      </div>

                      {/* Options for multiple choice */}
                      {problem.type === "multipleChoice" &&
                        problem.options.length > 0 && (
                          <div className="grid grid-cols-1 sm:grid-cols-2 gap-1 mb-2">
                            {problem.options.map((opt, oi) => (
                              <div
                                key={oi}
                                className={`text-xs px-2 py-1 rounded ${
                                  problem.correctAnswer === opt
                                    ? "bg-green-50 text-green-700 font-medium"
                                    : "text-gray-600"
                                }`}
                              >
                                {["①", "②", "③", "④", "⑤"][oi]}{" "}
                                <LatexRenderer text={opt} />
                              </div>
                            ))}
                          </div>
                        )}

                      {/* Tags */}
                      <div className="flex flex-wrap gap-1.5">
                        <span
                          className={`inline-flex items-center rounded-full px-2 py-0.5 text-xs ${
                            problem.type === "multipleChoice"
                              ? "bg-blue-50 text-blue-700"
                              : "bg-purple-50 text-purple-700"
                          }`}
                        >
                          {problem.type === "multipleChoice"
                            ? "객관식"
                            : "단답형"}
                        </span>
                        {problem.correctAnswer && (
                          <span className="inline-flex items-center rounded-full bg-green-50 px-2 py-0.5 text-xs text-green-700">
                            정답: {problem.correctAnswer}
                          </span>
                        )}
                        {!problem.correctAnswer && (
                          <span className="inline-flex items-center rounded-full bg-yellow-50 px-2 py-0.5 text-xs text-yellow-700">
                            정답 미입력
                          </span>
                        )}
                      </div>
                    </div>

                    {/* Actions */}
                    <div className="flex items-center gap-1 flex-shrink-0">
                      <button
                        onClick={() => toggleEdit(index)}
                        className="p-1.5 rounded-lg text-gray-400 hover:bg-gray-100 hover:text-gray-600 transition-colors"
                        title="수정"
                      >
                        <Edit3 className="h-4 w-4" />
                      </button>
                      <button
                        onClick={() => removeProblem(index)}
                        className="p-1.5 rounded-lg text-gray-400 hover:bg-red-50 hover:text-red-500 transition-colors"
                        title="삭제"
                      >
                        <Trash2 className="h-4 w-4" />
                      </button>
                    </div>
                  </div>
                )}
              </div>
            ))}
          </div>
        </div>
      )}
    </AdminLayout>
  );
}

// Inline editor component
function ProblemEditor({
  problem,
  index,
  onUpdate,
  onUpdateOption,
  onClose,
}: {
  problem: EditableProblem;
  index: number;
  onUpdate: (index: number, field: keyof ParsedProblem, value: string | string[]) => void;
  onUpdateOption: (problemIndex: number, optionIndex: number, value: string) => void;
  onClose: () => void;
}) {
  return (
    <div className="bg-blue-50/30 rounded-lg p-4 border border-blue-100">
      <div className="flex items-center justify-between mb-3">
        <span className="text-xs font-medium text-blue-600">
          문제 {problem.number} 수정 중
        </span>
        <button
          onClick={onClose}
          className="flex items-center gap-1 text-xs text-blue-600 hover:text-blue-800"
        >
          <Save className="h-3 w-3" />
          완료
        </button>
      </div>

      {/* Question */}
      <div className="mb-3">
        <label className="block text-xs font-medium text-gray-600 mb-1">
          문제
        </label>
        <textarea
          value={problem.question}
          onChange={(e) => onUpdate(index, "question", e.target.value)}
          rows={3}
          className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm text-gray-900 focus:border-blue-500 focus:ring-1 focus:ring-blue-500"
        />
      </div>

      {/* Type toggle */}
      <div className="mb-3">
        <label className="block text-xs font-medium text-gray-600 mb-1">
          유형
        </label>
        <div className="flex gap-2">
          <button
            onClick={() => onUpdate(index, "type", "multipleChoice")}
            className={`px-3 py-1.5 rounded-lg text-xs font-medium transition-colors ${
              problem.type === "multipleChoice"
                ? "bg-blue-600 text-white"
                : "bg-gray-100 text-gray-600 hover:bg-gray-200"
            }`}
          >
            객관식
          </button>
          <button
            onClick={() => onUpdate(index, "type", "shortAnswer")}
            className={`px-3 py-1.5 rounded-lg text-xs font-medium transition-colors ${
              problem.type === "shortAnswer"
                ? "bg-blue-600 text-white"
                : "bg-gray-100 text-gray-600 hover:bg-gray-200"
            }`}
          >
            단답형
          </button>
        </div>
      </div>

      {/* Options (for multiple choice) */}
      {problem.type === "multipleChoice" && (
        <div className="mb-3">
          <label className="block text-xs font-medium text-gray-600 mb-1">
            선택지
          </label>
          <div className="space-y-1.5">
            {problem.options.map((opt, oi) => (
              <div key={oi} className="flex items-center gap-2">
                <span className="text-xs text-gray-400 w-4">
                  {["①", "②", "③", "④", "⑤"][oi]}
                </span>
                <input
                  value={opt}
                  onChange={(e) =>
                    onUpdateOption(index, oi, e.target.value)
                  }
                  className="flex-1 rounded-lg border border-gray-300 px-3 py-1.5 text-sm text-gray-900 focus:border-blue-500 focus:ring-1 focus:ring-blue-500"
                />
                {oi >= 4 && (
                  <button
                    onClick={() => {
                      const newOptions = problem.options.filter(
                        (_, i) => i !== oi
                      );
                      onUpdate(index, "options", newOptions);
                    }}
                    className="p-1 text-gray-400 hover:text-red-500"
                  >
                    <X className="h-3 w-3" />
                  </button>
                )}
              </div>
            ))}
            {problem.options.length < 5 && (
              <button
                onClick={() =>
                  onUpdate(index, "options", [
                    ...problem.options,
                    "",
                  ])
                }
                className="text-xs text-blue-600 hover:text-blue-800 ml-6"
              >
                + 선택지 추가
              </button>
            )}
          </div>
        </div>
      )}

      {/* Correct Answer */}
      <div className="mb-3">
        <label className="block text-xs font-medium text-gray-600 mb-1">
          정답
        </label>
        <input
          value={problem.correctAnswer}
          onChange={(e) => onUpdate(index, "correctAnswer", e.target.value)}
          className="w-full rounded-lg border border-gray-300 px-3 py-1.5 text-sm text-gray-900 focus:border-blue-500 focus:ring-1 focus:ring-blue-500"
          placeholder="정답을 입력하세요"
        />
      </div>

      {/* Explanation */}
      <div>
        <label className="block text-xs font-medium text-gray-600 mb-1">
          풀이/해설
        </label>
        <textarea
          value={problem.explanation}
          onChange={(e) => onUpdate(index, "explanation", e.target.value)}
          rows={2}
          className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm text-gray-900 focus:border-blue-500 focus:ring-1 focus:ring-blue-500"
          placeholder="풀이 또는 해설을 입력하세요 (선택)"
        />
      </div>
    </div>
  );
}
