"use client";

import { useState, useEffect } from "react";
import AdminLayout from "@/components/layout/admin-layout";
import { bulkCreateProblems, getUnits, getLessons } from "@/lib/firestore";
import { Problem, Unit, Lesson, ProblemType, ProblemDifficulty, PROBLEM_TYPE_LABELS, DIFFICULTY_LABELS } from "@/lib/types";
import LatexRenderer from "@/components/ui/latex-renderer";
import * as XLSX from "xlsx-js-style";
import { Download, Upload, FileSpreadsheet, Check, AlertCircle } from "lucide-react";

interface ParsedProblem {
  lessonId: string;
  question: string;
  type: ProblemType;
  difficulty: ProblemDifficulty;
  options: string[];
  correctAnswer: string;
  explanation?: string;
  hints: string[];
  points: number;
  imageUrls: string[];
  valid: boolean;
  errors: string[];
}

export default function BulkUploadPage() {
  const [units, setUnits] = useState<Unit[]>([]);
  const [lessons, setLessons] = useState<Lesson[]>([]);
  const [parsedData, setParsedData] = useState<ParsedProblem[]>([]);
  const [uploading, setUploading] = useState(false);
  const [uploaded, setUploaded] = useState(false);
  const [uploadCount, setUploadCount] = useState(0);

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

  const downloadTemplate = () => {
    const headers = [
      "lessonId",
      "question",
      "type",
      "difficulty",
      "option1",
      "option2",
      "option3",
      "option4",
      "correctAnswer",
      "explanation",
      "hint1",
      "hint2",
      "hint3",
      "points",
    ];

    const example = [
      "lesson_id_here",
      "$x^2 + 2x + 1 = 0$의 해는?",
      "multipleChoice",
      "medium",
      "$x = -1$",
      "$x = 1$",
      "$x = 0$",
      "$x = 2$",
      "$x = -1$",
      "$(x+1)^2 = 0$이므로 $x = -1$",
      "완전제곱식으로 인수분해하세요",
      "$(x+1)^2$ 형태입니다",
      "",
      "10",
    ];

    const ws = XLSX.utils.aoa_to_sheet([headers, example]);
    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, "Problems");

    // Lesson reference sheet
    const lessonData = lessons.map((l) => {
      const unit = units.find((u) => u.id === l.unitId);
      return [l.id, unit?.title || "", l.title];
    });
    const ws2 = XLSX.utils.aoa_to_sheet([
      ["lessonId", "단원", "레슨"],
      ...lessonData,
    ]);
    XLSX.utils.book_append_sheet(wb, ws2, "Lessons Reference");

    // Type reference sheet
    const typeData = Object.entries(PROBLEM_TYPE_LABELS).map(([k, v]) => [k, v]);
    const diffData = Object.entries(DIFFICULTY_LABELS).map(([k, v]) => [k, v]);
    const ws3 = XLSX.utils.aoa_to_sheet([
      ["문제 유형 (type)", "설명"],
      ...typeData,
      [],
      ["난이도 (difficulty)", "설명"],
      ...diffData,
    ]);
    XLSX.utils.book_append_sheet(wb, ws3, "Types Reference");

    XLSX.writeFile(wb, "mathlab_problems_template.xlsx");
  };

  const handleFileUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    // Defensive: limit file size to 10MB and validate extension
    const MAX_FILE_SIZE = 10 * 1024 * 1024;
    if (file.size > MAX_FILE_SIZE) {
      alert("파일 크기가 10MB를 초과합니다.");
      return;
    }
    const allowedExtensions = [".xlsx", ".csv", ".xls"];
    const ext = file.name.substring(file.name.lastIndexOf(".")).toLowerCase();
    if (!allowedExtensions.includes(ext)) {
      alert("지원하지 않는 파일 형식입니다. (.xlsx, .csv, .xls만 가능)");
      return;
    }

    const reader = new FileReader();
    reader.onload = (event) => {
      try {
        const wb = XLSX.read(event.target?.result, { type: "binary" });
        const ws = wb.Sheets[wb.SheetNames[0]];
        const data = XLSX.utils.sheet_to_json<Record<string, string>>(ws);

        const parsed: ParsedProblem[] = data.map((row) => {
          const errors: string[] = [];

          const type = (row.type || "multipleChoice") as ProblemType;
          const difficulty = (row.difficulty || "easy") as ProblemDifficulty;
          const lessonId = row.lessonId || "";
          const question = row.question || "";
          const correctAnswer = row.correctAnswer || "";

          if (!lessonId) errors.push("lessonId 필수");
          if (!question) errors.push("question 필수");
          if (!correctAnswer) errors.push("correctAnswer 필수");
          if (!["multipleChoice", "shortAnswer", "trueFalse", "fillInBlank", "matching", "dragAndDrop"].includes(type)) {
            errors.push(`잘못된 type: ${type}`);
          }
          if (!["easy", "medium", "hard", "expert"].includes(difficulty)) {
            errors.push(`잘못된 difficulty: ${difficulty}`);
          }

          const options: string[] = [];
          if (type === "multipleChoice") {
            for (let i = 1; i <= 4; i++) {
              const opt = row[`option${i}`] || "";
              options.push(opt);
              if (!opt) errors.push(`option${i} 필수 (객관식)`);
            }
          }

          const hints: string[] = [];
          for (let i = 1; i <= 3; i++) {
            const h = row[`hint${i}`];
            if (h) hints.push(h);
          }

          return {
            lessonId,
            question,
            type,
            difficulty,
            options,
            correctAnswer,
            explanation: row.explanation || undefined,
            hints,
            points: parseInt(row.points) || 10,
            imageUrls: [],
            valid: errors.length === 0,
            errors,
          };
        });

        setParsedData(parsed);
        setUploaded(false);
      } catch (error) {
        console.error(error);
        alert("파일 파싱에 실패했습니다.");
      }
    };
    reader.readAsBinaryString(file);
  };

  const handleBulkUpload = async () => {
    const validProblems = parsedData.filter((p) => p.valid);
    if (validProblems.length === 0) {
      alert("업로드할 유효한 문제가 없습니다.");
      return;
    }

    if (!confirm(`${validProblems.length}개의 문제를 등록하시겠습니까?`)) return;

    setUploading(true);
    try {
      const dataToUpload = validProblems.map(({ valid, errors, ...rest }) => rest);
      const count = await bulkCreateProblems(dataToUpload);
      setUploadCount(count);
      setUploaded(true);
      setParsedData([]);
    } catch (error) {
      console.error(error);
      alert("업로드에 실패했습니다.");
    } finally {
      setUploading(false);
    }
  };

  const validCount = parsedData.filter((p) => p.valid).length;
  const invalidCount = parsedData.filter((p) => !p.valid).length;

  return (
    <AdminLayout>
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900">대량 등록</h1>
        <p className="text-sm text-gray-500 mt-1">CSV/Excel 파일로 문제를 대량 등록합니다</p>
      </div>

      {/* Template Download */}
      <div className="rounded-xl border border-gray-200 bg-white p-6 mb-6">
        <h3 className="text-sm font-semibold text-gray-900 mb-2">1. 템플릿 다운로드</h3>
        <p className="text-sm text-gray-500 mb-4">
          아래 버튼을 클릭하여 업로드 템플릿을 다운로드하세요. 레슨 ID 참조 시트가 포함되어 있습니다.
        </p>
        <button
          onClick={downloadTemplate}
          className="flex items-center gap-2 rounded-lg border border-gray-300 px-4 py-2.5 text-sm font-medium text-gray-700 hover:bg-gray-50 transition-colors"
        >
          <Download className="h-4 w-4" />
          템플릿 다운로드 (.xlsx)
        </button>
      </div>

      {/* File Upload */}
      <div className="rounded-xl border border-gray-200 bg-white p-6 mb-6">
        <h3 className="text-sm font-semibold text-gray-900 mb-2">2. 파일 업로드</h3>
        <label className="flex flex-col items-center justify-center rounded-lg border-2 border-dashed border-gray-300 px-4 py-10 cursor-pointer hover:border-blue-400 hover:bg-blue-50/50 transition-colors">
          <FileSpreadsheet className="h-10 w-10 text-gray-400 mb-3" />
          <span className="text-sm font-medium text-gray-700">클릭하여 파일 선택</span>
          <span className="text-xs text-gray-400 mt-1">.xlsx, .csv 파일 지원</span>
          <input
            type="file"
            accept=".xlsx,.csv,.xls"
            className="hidden"
            onChange={handleFileUpload}
          />
        </label>
      </div>

      {/* Success Message */}
      {uploaded && (
        <div className="rounded-xl border border-green-200 bg-green-50 p-6 mb-6">
          <div className="flex items-center gap-3">
            <Check className="h-6 w-6 text-green-600" />
            <div>
              <h3 className="text-sm font-semibold text-green-900">업로드 완료</h3>
              <p className="text-sm text-green-700">{uploadCount}개의 문제가 등록되었습니다.</p>
            </div>
          </div>
        </div>
      )}

      {/* Preview */}
      {parsedData.length > 0 && (
        <div className="rounded-xl border border-gray-200 bg-white mb-6">
          <div className="flex items-center justify-between border-b border-gray-200 px-6 py-4">
            <div>
              <h3 className="text-sm font-semibold text-gray-900">3. 미리보기</h3>
              <p className="text-xs text-gray-500 mt-1">
                유효: {validCount}개 / 오류: {invalidCount}개 / 총 {parsedData.length}개
              </p>
            </div>
            <button
              onClick={handleBulkUpload}
              disabled={uploading || validCount === 0}
              className="flex items-center gap-2 rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              <Upload className="h-4 w-4" />
              {uploading ? "업로드 중..." : `${validCount}개 등록`}
            </button>
          </div>

          <div className="divide-y divide-gray-100 max-h-[600px] overflow-y-auto">
            {parsedData.map((problem, index) => (
              <div
                key={index}
                className={`px-6 py-4 ${!problem.valid ? "bg-red-50/50" : ""}`}
              >
                <div className="flex items-start gap-3">
                  <span className="flex h-6 w-6 items-center justify-center rounded-full bg-gray-100 text-xs font-medium text-gray-600 flex-shrink-0 mt-0.5">
                    {index + 1}
                  </span>
                  <div className="flex-1 min-w-0">
                    <div className="text-sm text-gray-900 mb-1">
                      <LatexRenderer text={problem.question} />
                    </div>
                    <div className="flex flex-wrap gap-1.5">
                      <span className="inline-flex items-center rounded-full bg-blue-50 px-2 py-0.5 text-xs text-blue-700">
                        {PROBLEM_TYPE_LABELS[problem.type] || problem.type}
                      </span>
                      <span className="inline-flex items-center rounded-full bg-orange-50 px-2 py-0.5 text-xs text-orange-700">
                        {DIFFICULTY_LABELS[problem.difficulty] || problem.difficulty}
                      </span>
                      <span className="inline-flex items-center rounded-full bg-green-50 px-2 py-0.5 text-xs text-green-700">
                        정답: {problem.correctAnswer}
                      </span>
                    </div>
                    {!problem.valid && (
                      <div className="mt-2 flex items-start gap-1.5">
                        <AlertCircle className="h-3.5 w-3.5 text-red-500 mt-0.5 flex-shrink-0" />
                        <span className="text-xs text-red-600">
                          {problem.errors.join(", ")}
                        </span>
                      </div>
                    )}
                  </div>
                  <div className="flex-shrink-0">
                    {problem.valid ? (
                      <Check className="h-5 w-5 text-green-500" />
                    ) : (
                      <AlertCircle className="h-5 w-5 text-red-500" />
                    )}
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </AdminLayout>
  );
}
