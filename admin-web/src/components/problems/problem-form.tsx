"use client";

import { useState, useEffect, useCallback } from "react";
import { Problem, ProblemType, ProblemDifficulty, Unit, Lesson, DIFFICULTY_LABELS } from "@/lib/types";
import { getUnits, getLessons, getProblemCountsByLesson } from "@/lib/firestore";
import { uploadProblemImage } from "@/lib/storage";
import { Upload, X, Check, Plus, Lightbulb, BookOpen } from "lucide-react";

interface ProblemFormProps {
  initialData?: Problem;
  onSubmit: (data: Omit<Problem, "id" | "createdAt" | "updatedAt">) => Promise<void>;
  submitLabel?: string;
  quickAddMode?: boolean;
  onProblemCountChange?: () => void;
}

export default function ProblemForm({ initialData, onSubmit, submitLabel = "저장", quickAddMode = false, onProblemCountChange }: ProblemFormProps) {
  const [units, setUnits] = useState<Unit[]>([]);
  const [lessons, setLessons] = useState<Lesson[]>([]);
  const [filteredLessons, setFilteredLessons] = useState<Lesson[]>([]);
  const [problemCounts, setProblemCounts] = useState<Record<string, number>>({});
  const [selectedUnitId, setSelectedUnitId] = useState("");
  const [saving, setSaving] = useState(false);
  const [successToast, setSuccessToast] = useState(false);
  const [questionMode, setQuestionMode] = useState<"text" | "image">("text");
  const [imageUploading, setImageUploading] = useState(false);

  const [lessonId, setLessonId] = useState(initialData?.lessonId || "");
  const [question, setQuestion] = useState(initialData?.question || "");
  const [type, setType] = useState<ProblemType>(initialData?.type || "multipleChoice");
  const [difficulty, setDifficulty] = useState<ProblemDifficulty>(initialData?.difficulty || "easy");
  const [options, setOptions] = useState<string[]>(
    initialData?.options?.length ? initialData.options : ["", "", "", ""]
  );
  const [correctAnswer, setCorrectAnswer] = useState(initialData?.correctAnswer || "");
  const [imageUrls, setImageUrls] = useState<string[]>(initialData?.imageUrls || []);
  const [hints, setHints] = useState<string[]>(initialData?.hints?.length ? initialData.hints : [""]);
  const [explanation, setExplanation] = useState(initialData?.explanation || "");
  const [points, setPoints] = useState(initialData?.points || 10);

  useEffect(() => {
    loadCurriculum();
  }, []);

  const loadCurriculum = async () => {
    try {
      const [u, l, c] = await Promise.all([getUnits(), getLessons(), getProblemCountsByLesson()]);
      setUnits(u);
      setLessons(l);
      setProblemCounts(c);
      if (initialData?.lessonId) {
        const lesson = l.find((ls) => ls.id === initialData.lessonId);
        if (lesson?.unitId) {
          setSelectedUnitId(lesson.unitId);
          setFilteredLessons(l.filter((ls) => ls.unitId === lesson.unitId));
        }
      }
    } catch (error) {
      console.error("Failed to load curriculum:", error);
    }
  };

  const handleUnitChange = useCallback((unitId: string) => {
    setSelectedUnitId(unitId);
    setFilteredLessons(lessons.filter((l) => l.unitId === unitId));
    setLessonId("");
  }, [lessons]);

  const handleImageUpload = async (files: FileList) => {
    setImageUploading(true);
    try {
      const uploadPromises = Array.from(files).map((file) => uploadProblemImage(file));
      const urls = await Promise.all(uploadPromises);
      setImageUrls((prev) => [...prev, ...urls]);
    } catch {
      alert("이미지 업로드 실패");
    } finally {
      setImageUploading(false);
    }
  };

  const removeImage = (index: number) => {
    setImageUrls((prev) => prev.filter((_, i) => i !== index));
  };

  const resetForm = () => {
    setQuestion("");
    setOptions(["", "", "", ""]);
    setCorrectAnswer("");
    setImageUrls([]);
    setQuestionMode("text");
    setHints([""]);
    setExplanation("");
    setDifficulty("easy");
    setPoints(10);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!lessonId) return alert("레슨을 선택해주세요.");
    if (questionMode === "text" && !question.trim()) return alert("문제를 입력해주세요.");
    if (questionMode === "image" && imageUrls.length === 0) return alert("이미지를 업로드해주세요.");
    if (!correctAnswer.trim()) return alert("정답을 입력해주세요.");
    if (type === "multipleChoice" && options.some((o) => !o.trim())) return alert("모든 선택지를 입력해주세요.");

    setSaving(true);
    try {
      await onSubmit({
        lessonId,
        question: question || "(이미지 문제)",
        type,
        difficulty,
        options: type === "multipleChoice" ? options : [],
        correctAnswer,
        hints: hints.filter((h) => h.trim()),
        explanation: explanation.trim() || undefined,
        points,
        imageUrls,
      });
      if (quickAddMode) {
        setProblemCounts((prev) => ({ ...prev, [lessonId]: (prev[lessonId] || 0) + 1 }));
        onProblemCountChange?.();
        resetForm();
        setSuccessToast(true);
        setTimeout(() => setSuccessToast(false), 2000);
      }
    } finally {
      setSaving(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      {successToast && (
        <div className="fixed top-4 right-4 z-50 flex items-center gap-2 rounded-lg bg-green-600 px-4 py-3 text-sm font-medium text-white shadow-lg">
          <Check className="h-4 w-4" /> 등록 완료
        </div>
      )}

      {/* 1. 단원 / 레슨 */}
      <div className="flex items-center gap-2 flex-wrap">
        <select value={selectedUnitId} onChange={(e) => handleUnitChange(e.target.value)}
          className="rounded-lg border border-gray-300 px-3 py-2 text-sm min-w-[180px]">
          <option value="">단원 선택</option>
          {units.map((u) => <option key={u.id} value={u.id}>{u.emoji} {u.title}</option>)}
        </select>
        <span className="text-gray-300">/</span>
        <select value={lessonId} onChange={(e) => setLessonId(e.target.value)} disabled={!selectedUnitId}
          className="rounded-lg border border-gray-300 px-3 py-2 text-sm min-w-[220px]">
          <option value="">레슨 선택</option>
          {filteredLessons.map((l) => (
            <option key={l.id} value={l.id}>{l.order}. {l.title} ({problemCounts[l.id] || 0})</option>
          ))}
        </select>
      </div>

      {/* 2. 문제 유형 + 난이도 */}
      <div className="flex gap-2 flex-wrap">
        {([
          ["multipleChoice", "객관식"],
          ["shortAnswer", "단답형"],
          ["trueFalse", "O/X"],
        ] as [ProblemType, string][]).map(([key, label]) => (
          <button key={key} type="button" onClick={() => { setType(key); setCorrectAnswer(""); }}
            className={`rounded-lg px-4 py-2 text-sm font-medium transition-colors ${
              type === key ? "bg-blue-600 text-white" : "bg-gray-100 text-gray-600 hover:bg-gray-200"
            }`}>
            {label}
          </button>
        ))}
        <div className="w-px bg-gray-200 mx-1" />
        <select value={difficulty} onChange={(e) => setDifficulty(e.target.value as ProblemDifficulty)}
          className="rounded-lg border border-gray-300 px-3 py-2 text-sm">
          {(Object.entries(DIFFICULTY_LABELS) as [ProblemDifficulty, string][]).map(([key, label]) => (
            <option key={key} value={key}>{label}</option>
          ))}
        </select>
        <input type="number" value={points} onChange={(e) => setPoints(parseInt(e.target.value) || 10)}
          className="rounded-lg border border-gray-300 px-3 py-2 text-sm w-20" min={1} max={100}
          title="배점" />
        <span className="text-xs text-gray-400 self-center">점</span>
      </div>

      {/* 3. 문제 입력 (텍스트 / 이미지) */}
      <div className="rounded-xl border border-gray-200 bg-white p-4">
        <div className="flex items-center gap-2 mb-3">
          <span className="text-sm font-semibold text-gray-900">문제</span>
          <div className="flex rounded-md border border-gray-200 overflow-hidden ml-auto">
            <button type="button" onClick={() => setQuestionMode("text")}
              className={`px-3 py-1 text-xs font-medium ${questionMode === "text" ? "bg-blue-600 text-white" : "text-gray-500"}`}>
              텍스트
            </button>
            <button type="button" onClick={() => setQuestionMode("image")}
              className={`px-3 py-1 text-xs font-medium ${questionMode === "image" ? "bg-blue-600 text-white" : "text-gray-500"}`}>
              이미지
            </button>
          </div>
        </div>

        {questionMode === "text" ? (
          <textarea value={question} onChange={(e) => setQuestion(e.target.value)} rows={2}
            className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm resize-none"
            placeholder="문제를 입력하세요 (LaTeX: $수식$)" />
        ) : (
          <>
            {imageUrls.length > 0 && (
              <div className="flex flex-wrap gap-2 mb-3">
                {imageUrls.map((url, i) => (
                  <div key={i} className="relative inline-block">
                    <img src={url} alt={`문제 이미지 ${i + 1}`} className="max-h-48 rounded-lg border border-gray-200" />
                    <button type="button" onClick={() => removeImage(i)}
                      className="absolute top-1 right-1 h-6 w-6 rounded-full bg-red-500 text-white flex items-center justify-center">
                      <X className="h-3.5 w-3.5" />
                    </button>
                  </div>
                ))}
              </div>
            )}
            <label className={`flex flex-col items-center gap-1 rounded-lg border-2 border-dashed py-6 cursor-pointer ${
              imageUploading ? "border-blue-300 bg-blue-50" : "border-gray-300 hover:border-blue-400"}`}
              onDragOver={(e) => e.preventDefault()}
              onDrop={(e) => { e.preventDefault(); if (e.dataTransfer.files.length) handleImageUpload(e.dataTransfer.files); }}>
              <Upload className="h-5 w-5 text-gray-400" />
              <span className="text-xs text-gray-500">{imageUploading ? "업로드 중..." : "클릭 또는 드래그 (여러 장 가능)"}</span>
              <input type="file" accept="image/*" multiple className="hidden"
                onChange={(e) => { if (e.target.files) handleImageUpload(e.target.files); }} />
            </label>
          </>
        )}
      </div>

      {/* 4. 정답 */}
      <div className="rounded-xl border border-gray-200 bg-white p-4">
        <span className="text-sm font-semibold text-gray-900 mb-3 block">정답</span>

        {type === "multipleChoice" ? (
          <div className="space-y-2">
            {options.map((opt, i) => (
              <div key={i} className="flex items-center gap-2">
                <button type="button" onClick={() => setCorrectAnswer(opt)}
                  className={`h-7 w-7 rounded-full text-xs font-medium flex-shrink-0 ${
                    correctAnswer === opt && opt ? "bg-green-500 text-white" : "bg-gray-100 text-gray-600 hover:bg-gray-200"
                  }`}>
                  {correctAnswer === opt && opt ? <Check className="h-3.5 w-3.5 mx-auto" /> : i + 1}
                </button>
                <input value={opt} placeholder={`선택지 ${i + 1}`}
                  onChange={(e) => {
                    const next = [...options]; next[i] = e.target.value; setOptions(next);
                    if (correctAnswer === opt) setCorrectAnswer(e.target.value);
                  }}
                  className="flex-1 rounded-lg border border-gray-300 px-3 py-2 text-sm" />
              </div>
            ))}
            <p className="text-xs text-gray-400 mt-1">번호를 클릭하면 정답으로 설정됩니다</p>
          </div>
        ) : type === "trueFalse" ? (
          <div className="flex gap-3">
            {(["true", "false"] as const).map((v) => (
              <button key={v} type="button" onClick={() => setCorrectAnswer(v)}
                className={`flex-1 rounded-lg border-2 py-2.5 text-sm font-medium ${
                  correctAnswer === v ? "border-blue-500 bg-blue-50 text-blue-700" : "border-gray-200 text-gray-600"
                }`}>
                {v === "true" ? "O (참)" : "X (거짓)"}
              </button>
            ))}
          </div>
        ) : (
          <input value={correctAnswer} onChange={(e) => setCorrectAnswer(e.target.value)}
            className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm" placeholder="정답 입력" />
        )}
      </div>

      {/* 5. 힌트 */}
      <div className="rounded-xl border border-gray-200 bg-white p-4">
        <div className="flex items-center gap-2 mb-3">
          <Lightbulb className="h-4 w-4 text-amber-500" />
          <span className="text-sm font-semibold text-gray-900">힌트</span>
          <span className="text-xs text-gray-400">(선택)</span>
        </div>
        <div className="space-y-2">
          {hints.map((hint, i) => (
            <div key={i} className="flex items-center gap-2">
              <span className="text-xs text-gray-400 w-4 flex-shrink-0">{i + 1}</span>
              <input value={hint} onChange={(e) => {
                const next = [...hints]; next[i] = e.target.value; setHints(next);
              }}
                className="flex-1 rounded-lg border border-gray-300 px-3 py-2 text-sm"
                placeholder={`힌트 ${i + 1}`} />
              {hints.length > 1 && (
                <button type="button" onClick={() => setHints(hints.filter((_, idx) => idx !== i))}
                  className="text-gray-400 hover:text-red-500">
                  <X className="h-4 w-4" />
                </button>
              )}
            </div>
          ))}
          {hints.length < 3 && (
            <button type="button" onClick={() => setHints([...hints, ""])}
              className="flex items-center gap-1 text-xs text-blue-600 hover:text-blue-700 font-medium">
              <Plus className="h-3.5 w-3.5" /> 힌트 추가
            </button>
          )}
        </div>
      </div>

      {/* 6. 풀이 설명 */}
      <div className="rounded-xl border border-gray-200 bg-white p-4">
        <div className="flex items-center gap-2 mb-3">
          <BookOpen className="h-4 w-4 text-green-600" />
          <span className="text-sm font-semibold text-gray-900">풀이 설명</span>
          <span className="text-xs text-gray-400">(선택)</span>
        </div>
        <textarea value={explanation} onChange={(e) => setExplanation(e.target.value)} rows={2}
          className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm resize-none"
          placeholder="정답 후 보여줄 풀이 설명을 입력하세요" />
      </div>

      {/* 7. 등록 */}
      <button type="submit" disabled={saving}
        className="w-full rounded-xl bg-blue-600 px-4 py-3 text-sm font-medium text-white hover:bg-blue-700 disabled:opacity-50">
        {saving ? "저장 중..." : submitLabel}
      </button>
    </form>
  );
}
