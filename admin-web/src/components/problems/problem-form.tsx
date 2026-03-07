"use client";

import { useState, useEffect, useCallback } from "react";
import { Problem, ProblemType, ProblemDifficulty, Unit, Lesson, PROBLEM_TYPE_LABELS, DIFFICULTY_LABELS } from "@/lib/types";
import { getUnits, getLessons } from "@/lib/firestore";
import { uploadProblemImage } from "@/lib/storage";
import LatexRenderer from "@/components/ui/latex-renderer";
import { Plus, Trash2, Upload, X, Eye, EyeOff, GripVertical } from "lucide-react";

interface ProblemFormProps {
  initialData?: Problem;
  onSubmit: (data: Omit<Problem, "id" | "createdAt" | "updatedAt">) => Promise<void>;
  submitLabel?: string;
}

export default function ProblemForm({ initialData, onSubmit, submitLabel = "저장" }: ProblemFormProps) {
  const [units, setUnits] = useState<Unit[]>([]);
  const [lessons, setLessons] = useState<Lesson[]>([]);
  const [filteredLessons, setFilteredLessons] = useState<Lesson[]>([]);
  const [selectedUnitId, setSelectedUnitId] = useState("");
  const [showPreview, setShowPreview] = useState(false);
  const [saving, setSaving] = useState(false);
  const [uploading, setUploading] = useState(false);

  // Form state
  const [lessonId, setLessonId] = useState(initialData?.lessonId || "");
  const [question, setQuestion] = useState(initialData?.question || "");
  const [type, setType] = useState<ProblemType>(initialData?.type || "multipleChoice");
  const [difficulty, setDifficulty] = useState<ProblemDifficulty>(initialData?.difficulty || "easy");
  const [options, setOptions] = useState<string[]>(
    initialData?.options?.length ? initialData.options : ["", "", "", ""]
  );
  const [correctAnswer, setCorrectAnswer] = useState(initialData?.correctAnswer || "");
  const [explanation, setExplanation] = useState(initialData?.explanation || "");
  const [hints, setHints] = useState<string[]>(
    initialData?.hints?.length ? initialData.hints : [""]
  );
  const [points, setPoints] = useState(initialData?.points || 10);
  const [imageUrls, setImageUrls] = useState<string[]>(initialData?.imageUrls || []);

  useEffect(() => {
    loadCurriculum();
  }, []);

  const loadCurriculum = async () => {
    try {
      const [unitsData, lessonsData] = await Promise.all([getUnits(), getLessons()]);
      setUnits(unitsData);
      setLessons(lessonsData);

      // If editing, find the unit for the lesson
      if (initialData?.lessonId) {
        const lesson = lessonsData.find((l) => l.id === initialData.lessonId);
        if (lesson?.unitId) {
          setSelectedUnitId(lesson.unitId);
          setFilteredLessons(lessonsData.filter((l) => l.unitId === lesson.unitId));
        }
      }
    } catch (error) {
      console.error("Failed to load curriculum:", error);
    }
  };

  const handleUnitChange = useCallback(
    (unitId: string) => {
      setSelectedUnitId(unitId);
      const filtered = lessons.filter((l) => l.unitId === unitId);
      setFilteredLessons(filtered);
      setLessonId("");
    },
    [lessons]
  );

  const handleImageUpload = async (files: FileList) => {
    setUploading(true);
    try {
      const urls: string[] = [];
      for (const file of Array.from(files)) {
        const url = await uploadProblemImage(file);
        urls.push(url);
      }
      setImageUrls((prev) => [...prev, ...urls]);
    } catch (error) {
      console.error("Image upload failed:", error);
      alert("이미지 업로드에 실패했습니다.");
    } finally {
      setUploading(false);
    }
  };

  const removeImage = (index: number) => {
    setImageUrls((prev) => prev.filter((_, i) => i !== index));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!lessonId) {
      alert("레슨을 선택해주세요.");
      return;
    }
    if (!question.trim()) {
      alert("문제를 입력해주세요.");
      return;
    }
    if (!correctAnswer.trim()) {
      alert("정답을 입력해주세요.");
      return;
    }
    if (type === "multipleChoice" && options.some((o) => !o.trim())) {
      alert("모든 선택지를 입력해주세요.");
      return;
    }

    setSaving(true);
    try {
      await onSubmit({
        lessonId,
        question,
        type,
        difficulty,
        options: type === "multipleChoice" ? options : [],
        correctAnswer,
        explanation: explanation || undefined,
        hints: hints.filter((h) => h.trim()),
        points,
        imageUrls,
      });
    } finally {
      setSaving(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Left Column - Main Form */}
        <div className="lg:col-span-2 space-y-6">
          {/* Unit / Lesson Selection */}
          <div className="rounded-xl border border-gray-200 bg-white p-6">
            <h3 className="text-sm font-semibold text-gray-900 mb-4">단원 / 레슨</h3>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm text-gray-600 mb-1">단원</label>
                <select
                  value={selectedUnitId}
                  onChange={(e) => handleUnitChange(e.target.value)}
                  className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20"
                >
                  <option value="">단원 선택</option>
                  {units.map((unit) => (
                    <option key={unit.id} value={unit.id}>
                      {unit.emoji} {unit.title} ({unit.subject})
                    </option>
                  ))}
                </select>
              </div>
              <div>
                <label className="block text-sm text-gray-600 mb-1">레슨</label>
                <select
                  value={lessonId}
                  onChange={(e) => setLessonId(e.target.value)}
                  className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20"
                  disabled={!selectedUnitId}
                >
                  <option value="">레슨 선택</option>
                  {filteredLessons.map((lesson) => (
                    <option key={lesson.id} value={lesson.id}>
                      {lesson.order}. {lesson.title}
                    </option>
                  ))}
                </select>
              </div>
            </div>
          </div>

          {/* Question */}
          <div className="rounded-xl border border-gray-200 bg-white p-6">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-sm font-semibold text-gray-900">문제</h3>
              <span className="text-xs text-gray-400">LaTeX: $수식$ 또는 $$수식$$</span>
            </div>
            <textarea
              value={question}
              onChange={(e) => setQuestion(e.target.value)}
              rows={4}
              className="w-full rounded-lg border border-gray-300 px-4 py-3 text-sm focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20 resize-none"
              placeholder="문제를 입력하세요. LaTeX 수식은 $..$ 또는 $$..$$ 으로 감싸세요."
            />
            {question && (
              <div className="mt-3 rounded-lg bg-gray-50 p-4 text-sm">
                <span className="text-xs text-gray-400 mb-2 block">미리보기</span>
                <LatexRenderer text={question} />
              </div>
            )}
          </div>

          {/* Type & Difficulty */}
          <div className="rounded-xl border border-gray-200 bg-white p-6">
            <h3 className="text-sm font-semibold text-gray-900 mb-4">유형 / 난이도</h3>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm text-gray-600 mb-1">문제 유형</label>
                <select
                  value={type}
                  onChange={(e) => setType(e.target.value as ProblemType)}
                  className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20"
                >
                  {Object.entries(PROBLEM_TYPE_LABELS).map(([key, label]) => (
                    <option key={key} value={key}>
                      {label}
                    </option>
                  ))}
                </select>
              </div>
              <div>
                <label className="block text-sm text-gray-600 mb-1">난이도</label>
                <select
                  value={difficulty}
                  onChange={(e) => setDifficulty(e.target.value as ProblemDifficulty)}
                  className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20"
                >
                  {Object.entries(DIFFICULTY_LABELS).map(([key, label]) => (
                    <option key={key} value={key}>
                      {label}
                    </option>
                  ))}
                </select>
              </div>
            </div>
          </div>

          {/* Multiple Choice Options */}
          {type === "multipleChoice" && (
            <div className="rounded-xl border border-gray-200 bg-white p-6">
              <h3 className="text-sm font-semibold text-gray-900 mb-4">선택지</h3>
              <div className="space-y-3">
                {options.map((option, index) => (
                  <div key={index} className="flex items-center gap-3">
                    <span className="flex h-7 w-7 items-center justify-center rounded-full bg-gray-100 text-xs font-medium text-gray-600">
                      {index + 1}
                    </span>
                    <input
                      value={option}
                      onChange={(e) => {
                        const newOptions = [...options];
                        newOptions[index] = e.target.value;
                        setOptions(newOptions);
                      }}
                      className="flex-1 rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20"
                      placeholder={`선택지 ${index + 1}`}
                    />
                    <button
                      type="button"
                      onClick={() => setCorrectAnswer(option)}
                      className={`rounded-lg px-3 py-2 text-xs font-medium transition-colors ${
                        correctAnswer === option
                          ? "bg-green-100 text-green-700 border border-green-300"
                          : "bg-gray-50 text-gray-500 border border-gray-200 hover:bg-gray-100"
                      }`}
                    >
                      {correctAnswer === option ? "정답" : "정답 설정"}
                    </button>
                  </div>
                ))}
              </div>
              {options.length > 0 && (
                <div className="mt-3 rounded-lg bg-gray-50 p-3">
                  <span className="text-xs text-gray-400">선택지 미리보기</span>
                  <div className="mt-2 space-y-1">
                    {options.filter(o => o).map((opt, i) => (
                      <div key={i} className="text-sm">
                        <LatexRenderer text={`${i + 1}. ${opt}`} />
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </div>
          )}

          {/* Correct Answer (non multiple-choice) */}
          {type !== "multipleChoice" && (
            <div className="rounded-xl border border-gray-200 bg-white p-6">
              <h3 className="text-sm font-semibold text-gray-900 mb-4">정답</h3>
              {type === "trueFalse" ? (
                <div className="flex gap-4">
                  {["true", "false"].map((val) => (
                    <button
                      key={val}
                      type="button"
                      onClick={() => setCorrectAnswer(val)}
                      className={`flex-1 rounded-lg border-2 px-4 py-3 text-sm font-medium transition-colors ${
                        correctAnswer === val
                          ? "border-blue-500 bg-blue-50 text-blue-700"
                          : "border-gray-200 text-gray-600 hover:border-gray-300"
                      }`}
                    >
                      {val === "true" ? "O (참)" : "X (거짓)"}
                    </button>
                  ))}
                </div>
              ) : (
                <input
                  value={correctAnswer}
                  onChange={(e) => setCorrectAnswer(e.target.value)}
                  className="w-full rounded-lg border border-gray-300 px-4 py-2.5 text-sm focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20"
                  placeholder="정답을 입력하세요"
                />
              )}
            </div>
          )}

          {/* Explanation */}
          <div className="rounded-xl border border-gray-200 bg-white p-6">
            <h3 className="text-sm font-semibold text-gray-900 mb-4">풀이 설명</h3>
            <textarea
              value={explanation}
              onChange={(e) => setExplanation(e.target.value)}
              rows={3}
              className="w-full rounded-lg border border-gray-300 px-4 py-3 text-sm focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20 resize-none"
              placeholder="풀이 설명을 입력하세요 (LaTeX 지원)"
            />
            {explanation && (
              <div className="mt-3 rounded-lg bg-gray-50 p-4 text-sm">
                <span className="text-xs text-gray-400 mb-2 block">미리보기</span>
                <LatexRenderer text={explanation} />
              </div>
            )}
          </div>

          {/* Hints */}
          <div className="rounded-xl border border-gray-200 bg-white p-6">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-sm font-semibold text-gray-900">힌트</h3>
              <button
                type="button"
                onClick={() => setHints([...hints, ""])}
                className="flex items-center gap-1 text-xs text-blue-600 hover:text-blue-700"
              >
                <Plus className="h-3.5 w-3.5" />
                힌트 추가
              </button>
            </div>
            <div className="space-y-3">
              {hints.map((hint, index) => (
                <div key={index} className="flex gap-2">
                  <div className="flex items-start gap-2 flex-1">
                    <GripVertical className="h-5 w-5 text-gray-300 mt-2 flex-shrink-0" />
                    <div className="flex-1">
                      <input
                        value={hint}
                        onChange={(e) => {
                          const newHints = [...hints];
                          newHints[index] = e.target.value;
                          setHints(newHints);
                        }}
                        className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20"
                        placeholder={`힌트 ${index + 1}`}
                      />
                    </div>
                  </div>
                  {hints.length > 1 && (
                    <button
                      type="button"
                      onClick={() => setHints(hints.filter((_, i) => i !== index))}
                      className="flex h-9 w-9 items-center justify-center rounded-lg text-gray-400 hover:bg-red-50 hover:text-red-500 transition-colors"
                    >
                      <Trash2 className="h-4 w-4" />
                    </button>
                  )}
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Right Column - Sidebar */}
        <div className="space-y-6">
          {/* Points */}
          <div className="rounded-xl border border-gray-200 bg-white p-6">
            <h3 className="text-sm font-semibold text-gray-900 mb-4">배점</h3>
            <input
              type="number"
              value={points}
              onChange={(e) => setPoints(parseInt(e.target.value) || 0)}
              min={1}
              max={100}
              className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20"
            />
          </div>

          {/* Image Upload */}
          <div className="rounded-xl border border-gray-200 bg-white p-6">
            <h3 className="text-sm font-semibold text-gray-900 mb-4">이미지</h3>
            <label
              className={`flex flex-col items-center justify-center rounded-lg border-2 border-dashed px-4 py-6 cursor-pointer transition-colors ${
                uploading
                  ? "border-blue-300 bg-blue-50"
                  : "border-gray-300 hover:border-blue-400 hover:bg-blue-50/50"
              }`}
              onDragOver={(e) => e.preventDefault()}
              onDrop={(e) => {
                e.preventDefault();
                if (e.dataTransfer.files.length > 0) {
                  handleImageUpload(e.dataTransfer.files);
                }
              }}
            >
              <Upload className="h-6 w-6 text-gray-400 mb-2" />
              <span className="text-xs text-gray-500">
                {uploading ? "업로드 중..." : "클릭 또는 드래그하여 업로드"}
              </span>
              <input
                type="file"
                accept="image/*"
                multiple
                className="hidden"
                onChange={(e) => {
                  if (e.target.files) handleImageUpload(e.target.files);
                }}
              />
            </label>

            {imageUrls.length > 0 && (
              <div className="mt-4 space-y-2">
                {imageUrls.map((url, index) => (
                  <div key={index} className="relative group">
                    <img
                      src={url}
                      alt={`이미지 ${index + 1}`}
                      className="w-full rounded-lg border border-gray-200"
                    />
                    <button
                      type="button"
                      onClick={() => removeImage(index)}
                      className="absolute top-2 right-2 flex h-6 w-6 items-center justify-center rounded-full bg-red-500 text-white opacity-0 group-hover:opacity-100 transition-opacity"
                    >
                      <X className="h-3.5 w-3.5" />
                    </button>
                  </div>
                ))}
              </div>
            )}
          </div>

          {/* Preview Toggle */}
          <div className="rounded-xl border border-gray-200 bg-white p-6">
            <button
              type="button"
              onClick={() => setShowPreview(!showPreview)}
              className="flex w-full items-center justify-center gap-2 rounded-lg border border-gray-300 px-4 py-2.5 text-sm font-medium text-gray-700 hover:bg-gray-50 transition-colors"
            >
              {showPreview ? (
                <>
                  <EyeOff className="h-4 w-4" /> 미리보기 닫기
                </>
              ) : (
                <>
                  <Eye className="h-4 w-4" /> 모바일 미리보기
                </>
              )}
            </button>
          </div>

          {/* Submit */}
          <button
            type="submit"
            disabled={saving}
            className="w-full rounded-xl bg-blue-600 px-4 py-3 text-sm font-medium text-white hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
          >
            {saving ? "저장 중..." : submitLabel}
          </button>
        </div>
      </div>

      {/* Mobile Preview Modal */}
      {showPreview && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50">
          <div className="relative mx-4">
            <button
              type="button"
              onClick={() => setShowPreview(false)}
              className="absolute -top-10 right-0 text-white hover:text-gray-300"
            >
              <X className="h-6 w-6" />
            </button>
            <div className="w-[375px] rounded-[2rem] border-4 border-gray-800 bg-white p-6 shadow-2xl max-h-[700px] overflow-y-auto">
              <div className="mb-6">
                <div className="flex items-center justify-between mb-4">
                  <span className="inline-flex items-center rounded-full bg-blue-100 px-2.5 py-0.5 text-xs font-medium text-blue-700">
                    {DIFFICULTY_LABELS[difficulty]}
                  </span>
                  <span className="text-xs text-gray-400">{points}점</span>
                </div>
                <div className="text-base font-medium text-gray-900 leading-relaxed">
                  <LatexRenderer text={question || "문제를 입력하세요"} />
                </div>
              </div>

              {imageUrls.length > 0 && (
                <div className="mb-4 space-y-2">
                  {imageUrls.map((url, i) => (
                    <img key={i} src={url} alt="" className="w-full rounded-lg" />
                  ))}
                </div>
              )}

              {type === "multipleChoice" && (
                <div className="space-y-2">
                  {options.map((opt, i) => (
                    <div
                      key={i}
                      className={`rounded-xl border-2 px-4 py-3 text-sm ${
                        correctAnswer === opt
                          ? "border-green-500 bg-green-50"
                          : "border-gray-200"
                      }`}
                    >
                      <LatexRenderer text={opt || `선택지 ${i + 1}`} />
                    </div>
                  ))}
                </div>
              )}

              {type === "trueFalse" && (
                <div className="grid grid-cols-2 gap-3">
                  <div className={`rounded-xl border-2 px-4 py-3 text-center text-sm font-medium ${
                    correctAnswer === "true" ? "border-green-500 bg-green-50" : "border-gray-200"
                  }`}>O</div>
                  <div className={`rounded-xl border-2 px-4 py-3 text-center text-sm font-medium ${
                    correctAnswer === "false" ? "border-green-500 bg-green-50" : "border-gray-200"
                  }`}>X</div>
                </div>
              )}

              {(type === "shortAnswer" || type === "fillInBlank") && (
                <div className="rounded-xl border-2 border-gray-200 px-4 py-3">
                  <span className="text-sm text-gray-400">답: {correctAnswer || "___"}</span>
                </div>
              )}

              {explanation && (
                <div className="mt-4 rounded-xl bg-green-50 p-4">
                  <p className="text-xs font-medium text-green-700 mb-1">풀이</p>
                  <div className="text-sm text-green-800">
                    <LatexRenderer text={explanation} />
                  </div>
                </div>
              )}

              {hints.filter(h => h).length > 0 && (
                <div className="mt-4 rounded-xl bg-yellow-50 p-4">
                  <p className="text-xs font-medium text-yellow-700 mb-2">힌트</p>
                  {hints.filter(h => h).map((h, i) => (
                    <div key={i} className="text-sm text-yellow-800 mb-1">
                      {i + 1}. <LatexRenderer text={h} />
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        </div>
      )}
    </form>
  );
}
