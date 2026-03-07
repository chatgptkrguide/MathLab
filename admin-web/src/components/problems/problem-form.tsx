"use client";

import { useState, useEffect, useCallback } from "react";
import { Problem, ProblemType, ProblemDifficulty, Unit, Lesson, PROBLEM_TYPE_LABELS, DIFFICULTY_LABELS } from "@/lib/types";
import { getUnits, getLessons, getProblemCountsByLesson } from "@/lib/firestore";
import { uploadProblemImage } from "@/lib/storage";
import LatexRenderer from "@/components/ui/latex-renderer";
import { Plus, Trash2, Upload, X, ChevronDown, ChevronUp, Check } from "lucide-react";

const DIFFICULTY_POINTS: Record<ProblemDifficulty, number> = {
  easy: 10,
  medium: 15,
  hard: 20,
  expert: 25,
};

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
  const [uploading, setUploading] = useState(false);
  const [showExtraOptions, setShowExtraOptions] = useState(false);
  const [successToast, setSuccessToast] = useState(false);

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
      const [unitsData, lessonsData, counts] = await Promise.all([
        getUnits(),
        getLessons(),
        getProblemCountsByLesson(),
      ]);
      setUnits(unitsData);
      setLessons(lessonsData);
      setProblemCounts(counts);

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

  const handleDifficultyChange = (newDifficulty: ProblemDifficulty) => {
    setDifficulty(newDifficulty);
    if (!initialData) {
      setPoints(DIFFICULTY_POINTS[newDifficulty]);
    }
  };

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

  const resetForm = () => {
    setQuestion("");
    setOptions(["", "", "", ""]);
    setCorrectAnswer("");
    setExplanation("");
    setHints([""]);
    setImageUrls([]);
    setShowExtraOptions(false);
    // Keep unit, lesson, type, difficulty for quick-add
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

      if (quickAddMode) {
        // Update local count
        setProblemCounts((prev) => ({
          ...prev,
          [lessonId]: (prev[lessonId] || 0) + 1,
        }));
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
      {/* Success Toast */}
      {successToast && (
        <div className="fixed top-4 right-4 z-50 flex items-center gap-2 rounded-lg bg-green-600 px-4 py-3 text-sm font-medium text-white shadow-lg animate-in slide-in-from-top-2">
          <Check className="h-4 w-4" />
          문제가 등록되었습니다
        </div>
      )}

      {/* Unit / Lesson Selection - Inline */}
      <div className="flex items-center gap-3 flex-wrap">
        <select
          value={selectedUnitId}
          onChange={(e) => handleUnitChange(e.target.value)}
          className="rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20 min-w-[200px]"
        >
          <option value="">단원 선택</option>
          {units.map((unit) => (
            <option key={unit.id} value={unit.id}>
              {unit.emoji} {unit.title} ({unit.subject})
            </option>
          ))}
        </select>

        <span className="text-gray-300">/</span>

        <select
          value={lessonId}
          onChange={(e) => setLessonId(e.target.value)}
          className="rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20 min-w-[250px]"
          disabled={!selectedUnitId}
        >
          <option value="">레슨 선택</option>
          {filteredLessons.map((lesson) => {
            const count = problemCounts[lesson.id] || 0;
            return (
              <option key={lesson.id} value={lesson.id}>
                {lesson.order}. {lesson.title} ({count}문제)
              </option>
            );
          })}
        </select>

        {selectedUnitId && (
          <span className="text-xs text-gray-400">
            {filteredLessons.length}개 레슨
          </span>
        )}
      </div>

      {/* Main Content */}
      <div className="space-y-4">
        {/* Question */}
        <div className="rounded-xl border border-gray-200 bg-white p-5">
          <div className="flex items-center justify-between mb-3">
            <h3 className="text-sm font-semibold text-gray-900">문제</h3>
            <span className="text-xs text-gray-400">LaTeX: $수식$ 또는 $$수식$$</span>
          </div>
          <textarea
            value={question}
            onChange={(e) => setQuestion(e.target.value)}
            rows={3}
            className="w-full rounded-lg border border-gray-300 px-4 py-3 text-sm focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20 resize-none"
            placeholder="문제를 입력하세요. LaTeX 수식은 $..$ 또는 $$..$$ 으로 감싸세요."
          />
          {question && (
            <div className="mt-2 rounded-lg bg-gray-50 px-4 py-3 text-sm">
              <LatexRenderer text={question} />
            </div>
          )}
        </div>

        {/* Type, Difficulty, Points - Single Row */}
        <div className="flex items-center gap-3 flex-wrap">
          <div className="flex items-center gap-2">
            <label className="text-xs text-gray-500">유형</label>
            <select
              value={type}
              onChange={(e) => setType(e.target.value as ProblemType)}
              className="rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20"
            >
              {Object.entries(PROBLEM_TYPE_LABELS).map(([key, label]) => (
                <option key={key} value={key}>
                  {label}
                </option>
              ))}
            </select>
          </div>

          <div className="flex items-center gap-2">
            <label className="text-xs text-gray-500">난이도</label>
            <select
              value={difficulty}
              onChange={(e) => handleDifficultyChange(e.target.value as ProblemDifficulty)}
              className="rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20"
            >
              {Object.entries(DIFFICULTY_LABELS).map(([key, label]) => (
                <option key={key} value={key}>
                  {label}
                </option>
              ))}
            </select>
          </div>

          <div className="flex items-center gap-2">
            <label className="text-xs text-gray-500">배점</label>
            <input
              type="number"
              value={points}
              onChange={(e) => setPoints(parseInt(e.target.value) || 0)}
              min={1}
              max={100}
              className="w-16 rounded-lg border border-gray-300 px-2 py-2 text-sm text-center focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20"
            />
          </div>
        </div>

        {/* Multiple Choice Options */}
        {type === "multipleChoice" && (
          <div className="rounded-xl border border-gray-200 bg-white p-5">
            <h3 className="text-sm font-semibold text-gray-900 mb-3">선택지</h3>
            <div className="space-y-2">
              {options.map((option, index) => (
                <div key={index} className="flex items-center gap-2">
                  <button
                    type="button"
                    onClick={() => setCorrectAnswer(option)}
                    className={`flex h-7 w-7 items-center justify-center rounded-full text-xs font-medium flex-shrink-0 transition-colors ${
                      correctAnswer === option && option
                        ? "bg-green-500 text-white"
                        : "bg-gray-100 text-gray-600 hover:bg-gray-200"
                    }`}
                    title="정답 설정"
                  >
                    {correctAnswer === option && option ? <Check className="h-3.5 w-3.5" /> : index + 1}
                  </button>
                  <input
                    value={option}
                    onChange={(e) => {
                      const newOptions = [...options];
                      newOptions[index] = e.target.value;
                      setOptions(newOptions);
                      // If this was the correct answer, update it
                      if (correctAnswer === option) {
                        setCorrectAnswer(e.target.value);
                      }
                    }}
                    className="flex-1 rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20"
                    placeholder={`선택지 ${index + 1}`}
                  />
                </div>
              ))}
            </div>
            {options.some(o => o) && (
              <div className="mt-2 rounded-lg bg-gray-50 px-3 py-2">
                <div className="space-y-0.5">
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
          <div className="rounded-xl border border-gray-200 bg-white p-5">
            <h3 className="text-sm font-semibold text-gray-900 mb-3">정답</h3>
            {type === "trueFalse" ? (
              <div className="flex gap-3">
                {["true", "false"].map((val) => (
                  <button
                    key={val}
                    type="button"
                    onClick={() => setCorrectAnswer(val)}
                    className={`flex-1 rounded-lg border-2 px-4 py-2.5 text-sm font-medium transition-colors ${
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
        <div className="rounded-xl border border-gray-200 bg-white p-5">
          <h3 className="text-sm font-semibold text-gray-900 mb-3">풀이 설명</h3>
          <textarea
            value={explanation}
            onChange={(e) => setExplanation(e.target.value)}
            rows={2}
            className="w-full rounded-lg border border-gray-300 px-4 py-3 text-sm focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20 resize-none"
            placeholder="풀이 설명을 입력하세요 (LaTeX 지원)"
          />
          {explanation && (
            <div className="mt-2 rounded-lg bg-gray-50 px-4 py-3 text-sm">
              <LatexRenderer text={explanation} />
            </div>
          )}
        </div>

        {/* Extra Options - Collapsible */}
        <div className="rounded-xl border border-gray-200 bg-white">
          <button
            type="button"
            onClick={() => setShowExtraOptions(!showExtraOptions)}
            className="flex w-full items-center justify-between px-5 py-3 text-sm font-medium text-gray-600 hover:bg-gray-50 transition-colors rounded-xl"
          >
            <span>추가 옵션 (힌트, 이미지)</span>
            {showExtraOptions ? (
              <ChevronUp className="h-4 w-4" />
            ) : (
              <ChevronDown className="h-4 w-4" />
            )}
          </button>

          {showExtraOptions && (
            <div className="border-t border-gray-200 px-5 py-4 space-y-4">
              {/* Hints */}
              <div>
                <div className="flex items-center justify-between mb-2">
                  <h4 className="text-sm font-medium text-gray-700">힌트</h4>
                  <button
                    type="button"
                    onClick={() => setHints([...hints, ""])}
                    className="flex items-center gap-1 text-xs text-blue-600 hover:text-blue-700"
                  >
                    <Plus className="h-3.5 w-3.5" />
                    추가
                  </button>
                </div>
                <div className="space-y-2">
                  {hints.map((hint, index) => (
                    <div key={index} className="flex gap-2">
                      <input
                        value={hint}
                        onChange={(e) => {
                          const newHints = [...hints];
                          newHints[index] = e.target.value;
                          setHints(newHints);
                        }}
                        className="flex-1 rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20"
                        placeholder={`힌트 ${index + 1}`}
                      />
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

              {/* Image Upload */}
              <div>
                <h4 className="text-sm font-medium text-gray-700 mb-2">이미지</h4>
                <label
                  className={`flex items-center justify-center gap-2 rounded-lg border-2 border-dashed px-4 py-4 cursor-pointer transition-colors ${
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
                  <Upload className="h-4 w-4 text-gray-400" />
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
                  <div className="mt-3 flex gap-2 flex-wrap">
                    {imageUrls.map((url, index) => (
                      <div key={index} className="relative group w-20 h-20">
                        <img
                          src={url}
                          alt={`이미지 ${index + 1}`}
                          className="w-full h-full object-cover rounded-lg border border-gray-200"
                        />
                        <button
                          type="button"
                          onClick={() => removeImage(index)}
                          className="absolute -top-1 -right-1 flex h-5 w-5 items-center justify-center rounded-full bg-red-500 text-white opacity-0 group-hover:opacity-100 transition-opacity"
                        >
                          <X className="h-3 w-3" />
                        </button>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            </div>
          )}
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
    </form>
  );
}
