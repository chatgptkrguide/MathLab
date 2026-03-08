"use client";

import { useState, useEffect, useCallback } from "react";
import { Problem, ProblemType, ProblemDifficulty, Unit, Lesson, DIFFICULTY_LABELS } from "@/lib/types";
import { getUnits, getLessons, getProblemCountsByLesson, createProblem, updateProblem } from "@/lib/firestore";
import {
  X, Check, ChevronRight, ChevronLeft,
  Plus, Lightbulb, BookOpen, Sparkles,
} from "lucide-react";

interface CreateProblemModalProps {
  open: boolean;
  onClose: () => void;
  onCreated: () => void;
  editData?: Problem;
}

const STEPS = [
  { label: "위치 선택", desc: "단원과 레슨을 선택하세요" },
  { label: "문제 작성", desc: "문제 유형과 내용을 입력하세요" },
  { label: "정답 & 힌트", desc: "정답, 힌트, 풀이를 입력하세요" },
];

export default function CreateProblemModal({ open, onClose, onCreated, editData }: CreateProblemModalProps) {
  const [step, setStep] = useState(0);
  const [units, setUnits] = useState<Unit[]>([]);
  const [lessons, setLessons] = useState<Lesson[]>([]);
  const [filteredLessons, setFilteredLessons] = useState<Lesson[]>([]);
  const [problemCounts, setProblemCounts] = useState<Record<string, number>>({});
  const [saving, setSaving] = useState(false);

  // Form state
  const [selectedUnitId, setSelectedUnitId] = useState("");
  const [lessonId, setLessonId] = useState(editData?.lessonId || "");
  const [type, setType] = useState<ProblemType>(editData?.type || "multipleChoice");
  const [difficulty, setDifficulty] = useState<ProblemDifficulty>(editData?.difficulty || "easy");
  const [question, setQuestion] = useState(editData?.question || "");
  const [options, setOptions] = useState<string[]>(editData?.options?.length ? editData.options : ["", "", "", ""]);
  const [correctAnswer, setCorrectAnswer] = useState(editData?.correctAnswer || "");
  const [hints, setHints] = useState<string[]>(editData?.hints?.length ? editData.hints : [""]);
  const [explanation, setExplanation] = useState(editData?.explanation || "");
  const [points, setPoints] = useState(editData?.points || 10);

  useEffect(() => {
    if (open) {
      loadCurriculum();
      if (editData) {
        setStep(0);
        setLessonId(editData.lessonId || "");
        setType(editData.type || "multipleChoice");
        setDifficulty(editData.difficulty || "easy");
        setQuestion(editData.question || "");
        setOptions(editData.options?.length ? editData.options : ["", "", "", ""]);
        setCorrectAnswer(editData.correctAnswer || "");
        setHints(editData.hints?.length ? editData.hints : [""]);
        setExplanation(editData.explanation || "");
        setPoints(editData.points || 10);
      } else {
        resetForm();
      }
    }
  }, [open, editData]);

  const loadCurriculum = async () => {
    try {
      const [u, l, c] = await Promise.all([getUnits(), getLessons(), getProblemCountsByLesson()]);
      setUnits(u);
      setLessons(l);
      setProblemCounts(c);
      if (editData?.lessonId) {
        const lesson = l.find((ls) => ls.id === editData.lessonId);
        if (lesson?.unitId) {
          setSelectedUnitId(lesson.unitId);
          setFilteredLessons(l.filter((ls) => ls.unitId === lesson.unitId));
        }
      }
    } catch (error) {
      console.error("Failed to load curriculum:", error);
    }
  };

  const resetForm = () => {
    setStep(0);
    setSelectedUnitId("");
    setLessonId("");
    setType("multipleChoice");
    setDifficulty("easy");
    setQuestion("");
    setOptions(["", "", "", ""]);
    setCorrectAnswer("");
    setHints([""]);
    setExplanation("");
    setPoints(10);
  };

  const handleUnitSelect = (unitId: string) => {
    setSelectedUnitId(unitId);
    setFilteredLessons(lessons.filter((l) => l.unitId === unitId));
    setLessonId("");
  };

  const canProceed = useCallback((): boolean => {
    if (step === 0) return !!lessonId;
    if (step === 1) return !!question.trim();
    if (step === 2) {
      if (!correctAnswer.trim()) return false;
      if (type === "multipleChoice" && options.some((o) => !o.trim())) return false;
      return true;
    }
    return false;
  }, [step, lessonId, question, correctAnswer, type, options]);

  const handleSubmit = async () => {
    if (!canProceed()) return;
    setSaving(true);
    try {
      const problemData = {
        lessonId,
        question,
        type,
        difficulty,
        options: type === "multipleChoice" ? options : [],
        correctAnswer,
        hints: hints.filter((h) => h.trim()),
        explanation: explanation.trim() || undefined,
        points,
        imageUrls: [],
      };

      if (editData) {
        await updateProblem(editData.id, problemData);
      } else {
        await createProblem(problemData);
      }
      onCreated();
      onClose();
    } catch (error) {
      console.error(error);
      alert(editData ? "문제 수정에 실패했습니다." : "문제 등록에 실패했습니다.");
    } finally {
      setSaving(false);
    }
  };

  if (!open) return null;

  const selectedUnit = units.find((u) => u.id === selectedUnitId);

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50" onClick={onClose}>
      <div
        className="relative w-full max-w-2xl mx-4 rounded-2xl bg-white shadow-2xl max-h-[90vh] flex flex-col"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-4 border-b border-gray-100">
          <div>
            <h2 className="text-lg font-bold text-gray-900">{editData ? "문제 수정" : "문제 등록"}</h2>
            <p className="text-xs text-gray-500 mt-0.5">{STEPS[step].desc}</p>
          </div>
          <button onClick={onClose} className="text-gray-400 hover:text-gray-600 transition-colors">
            <X className="h-5 w-5" />
          </button>
        </div>

        {/* Stepper */}
        <div className="px-6 py-3 border-b border-gray-50 bg-gray-50/50">
          <div className="flex items-center gap-1">
            {STEPS.map((s, i) => (
              <div key={i} className="flex items-center gap-1 flex-1">
                <div className={`flex items-center gap-2 ${i <= step ? "" : "opacity-40"}`}>
                  <div className={`flex h-7 w-7 items-center justify-center rounded-full text-xs font-bold transition-all ${
                    i < step ? "bg-green-500 text-white" :
                    i === step ? "bg-blue-600 text-white ring-2 ring-blue-200" :
                    "bg-gray-200 text-gray-500"
                  }`}>
                    {i < step ? <Check className="h-3.5 w-3.5" /> : i + 1}
                  </div>
                  <span className={`text-xs font-medium hidden sm:inline ${
                    i === step ? "text-blue-700" : i < step ? "text-green-700" : "text-gray-400"
                  }`}>{s.label}</span>
                </div>
                {i < STEPS.length - 1 && (
                  <div className={`flex-1 h-px mx-2 ${i < step ? "bg-green-400" : "bg-gray-200"}`} />
                )}
              </div>
            ))}
          </div>
        </div>

        {/* Content */}
        <div className="flex-1 overflow-y-auto px-6 py-5">
          {/* STEP 0: 위치 선택 */}
          {step === 0 && (
            <div className="space-y-5">
              <div>
                <label className="text-sm font-semibold text-gray-900 mb-3 block">단원 선택</label>
                <div className="grid grid-cols-1 gap-2">
                  {units.map((unit) => {
                    const unitLessons = lessons.filter((l) => l.unitId === unit.id);
                    const unitProblems = unitLessons.reduce((acc, l) => acc + (problemCounts[l.id] || 0), 0);
                    const isSelected = selectedUnitId === unit.id;
                    return (
                      <button
                        key={unit.id}
                        type="button"
                        onClick={() => handleUnitSelect(unit.id)}
                        className={`flex items-center gap-3 rounded-xl border-2 px-4 py-3 text-left transition-all ${
                          isSelected ? "border-blue-500 bg-blue-50 ring-1 ring-blue-200" : "border-gray-200 hover:border-gray-300 hover:bg-gray-50"
                        }`}
                      >
                        <span className="text-xl">{unit.emoji}</span>
                        <div className="flex-1 min-w-0">
                          <div className="text-sm font-medium text-gray-900">{unit.title}</div>
                          <div className="text-xs text-gray-500">{unitLessons.length}개 레슨 · {unitProblems}개 문제</div>
                        </div>
                        {isSelected && <Check className="h-5 w-5 text-blue-600" />}
                      </button>
                    );
                  })}
                </div>
              </div>

              {selectedUnitId && (
                <div>
                  <label className="text-sm font-semibold text-gray-900 mb-3 block">
                    레슨 선택
                    <span className="ml-2 text-xs font-normal text-gray-400">{selectedUnit?.emoji} {selectedUnit?.title}</span>
                  </label>
                  <div className="grid grid-cols-1 gap-2">
                    {filteredLessons.length === 0 ? (
                      <div className="text-center py-6 text-sm text-gray-400">이 단원에 레슨이 없습니다.</div>
                    ) : (
                      filteredLessons.map((lesson) => {
                        const count = problemCounts[lesson.id] || 0;
                        const isSelected = lessonId === lesson.id;
                        return (
                          <button
                            key={lesson.id}
                            type="button"
                            onClick={() => setLessonId(lesson.id)}
                            className={`flex items-center gap-3 rounded-xl border-2 px-4 py-3 text-left transition-all ${
                              isSelected ? "border-blue-500 bg-blue-50 ring-1 ring-blue-200" : "border-gray-200 hover:border-gray-300 hover:bg-gray-50"
                            }`}
                          >
                            <div className="flex-1">
                              <div className="text-sm font-medium text-gray-900">{lesson.order}. {lesson.title}</div>
                            </div>
                            <span className={`rounded-full px-2 py-0.5 text-xs font-medium ${
                              count === 0 ? "bg-red-100 text-red-700" :
                              count < 5 ? "bg-amber-100 text-amber-700" :
                              "bg-green-100 text-green-700"
                            }`}>
                              {count}문제
                            </span>
                            {isSelected && <Check className="h-5 w-5 text-blue-600" />}
                          </button>
                        );
                      })
                    )}
                  </div>
                </div>
              )}
            </div>
          )}

          {/* STEP 1: 문제 작성 */}
          {step === 1 && (
            <div className="space-y-5">
              <div>
                <label className="text-sm font-semibold text-gray-900 mb-3 block">문제 설정</label>
                <div className="flex gap-2 flex-wrap items-center">
                  {([
                    ["multipleChoice", "객관식"],
                    ["shortAnswer", "단답형"],
                    ["trueFalse", "O/X"],
                  ] as [ProblemType, string][]).map(([key, label]) => (
                    <button key={key} type="button" onClick={() => { setType(key); setCorrectAnswer(""); setOptions(["", "", "", ""]); }}
                      className={`rounded-lg px-4 py-2 text-sm font-medium transition-all ${
                        type === key ? "bg-blue-600 text-white shadow-sm" : "bg-gray-100 text-gray-600 hover:bg-gray-200"
                      }`}>
                      {label}
                    </button>
                  ))}
                  <div className="w-px h-6 bg-gray-200 mx-1" />
                  <select value={difficulty} onChange={(e) => setDifficulty(e.target.value as ProblemDifficulty)}
                    className="rounded-lg border border-gray-300 px-3 py-2 text-sm">
                    {(Object.entries(DIFFICULTY_LABELS) as [ProblemDifficulty, string][]).map(([key, label]) => (
                      <option key={key} value={key}>{label}</option>
                    ))}
                  </select>
                  <div className="flex items-center gap-1">
                    <input type="number" value={points} onChange={(e) => setPoints(parseInt(e.target.value) || 10)}
                      className="rounded-lg border border-gray-300 px-3 py-2 text-sm w-16 text-center" min={1} max={100} />
                    <span className="text-xs text-gray-400">점</span>
                  </div>
                </div>
              </div>

              <div>
                <label className="text-sm font-semibold text-gray-900 mb-3 block">문제 내용</label>
                <textarea value={question} onChange={(e) => setQuestion(e.target.value)} rows={4}
                  className="w-full rounded-xl border border-gray-300 px-4 py-3 text-sm resize-none focus:border-blue-500 focus:ring-2 focus:ring-blue-100 focus:outline-none"
                  placeholder="문제를 입력하세요 (LaTeX: $수식$)" />
              </div>
            </div>
          )}

          {/* STEP 2: 정답 & 힌트 */}
          {step === 2 && (
            <div className="space-y-5">
              <div>
                <label className="text-sm font-semibold text-gray-900 mb-3 block">정답 입력</label>

                {type === "multipleChoice" ? (
                  <div className="space-y-2">
                    {options.map((opt, i) => (
                      <div key={i} className="flex items-center gap-2">
                        <button type="button" onClick={() => setCorrectAnswer(opt)}
                          className={`h-8 w-8 rounded-full text-xs font-bold flex-shrink-0 transition-all ${
                            correctAnswer === opt && opt
                              ? "bg-green-500 text-white shadow-sm ring-2 ring-green-200"
                              : "bg-gray-100 text-gray-500 hover:bg-gray-200"
                          }`}>
                          {correctAnswer === opt && opt ? <Check className="h-4 w-4 mx-auto" /> : i + 1}
                        </button>
                        <input value={opt} placeholder={`선택지 ${i + 1}`}
                          onChange={(e) => {
                            const next = [...options]; next[i] = e.target.value; setOptions(next);
                            if (correctAnswer === opt) setCorrectAnswer(e.target.value);
                          }}
                          className="flex-1 rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:ring-2 focus:ring-blue-100 focus:outline-none" />
                      </div>
                    ))}
                    <p className="text-xs text-gray-400 mt-1">번호를 클릭하면 정답으로 설정됩니다</p>
                  </div>
                ) : type === "trueFalse" ? (
                  <div className="flex gap-3">
                    {(["true", "false"] as const).map((v) => (
                      <button key={v} type="button" onClick={() => setCorrectAnswer(v)}
                        className={`flex-1 rounded-xl border-2 py-3 text-sm font-medium transition-all ${
                          correctAnswer === v ? "border-blue-500 bg-blue-50 text-blue-700 shadow-sm" : "border-gray-200 text-gray-500 hover:border-gray-300"
                        }`}>
                        {v === "true" ? "O (참)" : "X (거짓)"}
                      </button>
                    ))}
                  </div>
                ) : (
                  <input value={correctAnswer} onChange={(e) => setCorrectAnswer(e.target.value)}
                    className="w-full rounded-xl border border-gray-300 px-4 py-3 text-sm focus:border-blue-500 focus:ring-2 focus:ring-blue-100 focus:outline-none"
                    placeholder="정답을 입력하세요" />
                )}
              </div>

              {/* 힌트 */}
              <div className="rounded-xl border border-amber-200 bg-amber-50/50 p-4">
                <div className="flex items-center gap-2 mb-3">
                  <Lightbulb className="h-4 w-4 text-amber-500" />
                  <span className="text-sm font-semibold text-gray-900">힌트</span>
                  <span className="text-xs text-gray-400">(선택)</span>
                </div>
                <div className="space-y-2">
                  {hints.map((hint, i) => (
                    <div key={i} className="flex items-center gap-2">
                      <span className="text-xs text-amber-600 font-bold w-5 flex-shrink-0 text-center">{i + 1}</span>
                      <input value={hint} onChange={(e) => {
                        const next = [...hints]; next[i] = e.target.value; setHints(next);
                      }}
                        className="flex-1 rounded-lg border border-amber-200 bg-white px-3 py-2 text-sm focus:border-amber-400 focus:outline-none"
                        placeholder={`${i + 1}번째 힌트`} />
                      {hints.length > 1 && (
                        <button type="button" onClick={() => setHints(hints.filter((_, idx) => idx !== i))}
                          className="text-gray-300 hover:text-red-500 transition-colors">
                          <X className="h-4 w-4" />
                        </button>
                      )}
                    </div>
                  ))}
                  {hints.length < 3 && (
                    <button type="button" onClick={() => setHints([...hints, ""])}
                      className="flex items-center gap-1 text-xs text-amber-600 hover:text-amber-700 font-medium mt-1">
                      <Plus className="h-3.5 w-3.5" /> 힌트 추가
                    </button>
                  )}
                </div>
              </div>

              {/* 풀이 설명 */}
              <div className="rounded-xl border border-green-200 bg-green-50/50 p-4">
                <div className="flex items-center gap-2 mb-3">
                  <BookOpen className="h-4 w-4 text-green-600" />
                  <span className="text-sm font-semibold text-gray-900">풀이 설명</span>
                  <span className="text-xs text-gray-400">(선택)</span>
                </div>
                <textarea value={explanation} onChange={(e) => setExplanation(e.target.value)} rows={2}
                  className="w-full rounded-lg border border-green-200 bg-white px-3 py-2 text-sm resize-none focus:border-green-400 focus:outline-none"
                  placeholder="정답 후 보여줄 풀이 설명" />
              </div>
            </div>
          )}
        </div>

        {/* Footer */}
        <div className="flex items-center justify-between px-6 py-4 border-t border-gray-100 bg-gray-50/50">
          <button
            onClick={() => step > 0 ? setStep(step - 1) : onClose()}
            className="flex items-center gap-1 rounded-lg px-4 py-2 text-sm font-medium text-gray-600 hover:bg-gray-100 transition-colors"
          >
            <ChevronLeft className="h-4 w-4" />
            {step > 0 ? "이전" : "취소"}
          </button>

          <div className="flex items-center gap-2">
            {step < 2 ? (
              <button
                onClick={() => setStep(step + 1)}
                disabled={!canProceed()}
                className="flex items-center gap-1 rounded-lg bg-blue-600 px-5 py-2 text-sm font-medium text-white hover:bg-blue-700 disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
              >
                다음
                <ChevronRight className="h-4 w-4" />
              </button>
            ) : (
              <button
                onClick={handleSubmit}
                disabled={!canProceed() || saving}
                className="flex items-center gap-2 rounded-lg bg-blue-600 px-5 py-2 text-sm font-medium text-white hover:bg-blue-700 disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
              >
                <Sparkles className="h-4 w-4" />
                {saving ? (editData ? "수정 중..." : "등록 중...") : (editData ? "수정 완료" : "문제 등록")}
              </button>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
