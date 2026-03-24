"use client";

import { useState, useEffect } from "react";
import { auth } from "@/lib/firebase";
import AdminLayout from "@/components/layout/admin-layout";
import {
  getProblems,
  getUnits,
  getLessons,
  updateProblem,
  bulkCreateProblems,
} from "@/lib/firestore";
import {
  Problem,
  Unit,
  Lesson,
  ProblemDifficulty,
  DIFFICULTY_LABELS,
  PROBLEM_TYPE_LABELS,
} from "@/lib/types";
import LatexRenderer from "@/components/ui/latex-renderer";
import {
  Sparkles,
  Lightbulb,
  Copy,
  ChevronDown,
  Loader2,
  Check,
  AlertCircle,
  Save,
  RefreshCw,
  Wand2,
  ArrowRight,
  X,
  Search,
  Filter,
} from "lucide-react";

type TabType = "hints" | "variants";
type VariantType = "number_change" | "level_up" | "concept_similar";

interface StructuredHint {
  step: number;
  label: string;
  content: string;
}

interface GeneratedVariant {
  question: string;
  type: string;
  options: string[];
  correctAnswer: string;
  explanation: string;
  selected: boolean;
}

export default function AIToolsPage() {
  // Data state
  const [units, setUnits] = useState<Unit[]>([]);
  const [lessons, setLessons] = useState<Lesson[]>([]);
  const [problems, setProblems] = useState<Problem[]>([]);
  const [loading, setLoading] = useState(false);

  // Filters
  const [selectedUnitId, setSelectedUnitId] = useState("");
  const [selectedLessonId, setSelectedLessonId] = useState("");
  const [searchText, setSearchText] = useState("");

  // Selection
  const [selectedProblem, setSelectedProblem] = useState<Problem | null>(null);
  const [activeTab, setActiveTab] = useState<TabType>("hints");

  // Hint generation (GoPS 3-Step)
  const [structuredHints, setStructuredHints] = useState<StructuredHint[]>([]);
  const [hintLoading, setHintLoading] = useState(false);
  const [hintSaved, setHintSaved] = useState(false);
  const [hintError, setHintError] = useState("");

  // Variant generation
  const [variants, setVariants] = useState<GeneratedVariant[]>([]);
  const [variantType, setVariantType] = useState<VariantType>("number_change");
  const [variantCount, setVariantCount] = useState(3);
  const [variantLoading, setVariantLoading] = useState(false);
  const [variantSaved, setVariantSaved] = useState(false);
  const [variantError, setVariantError] = useState("");
  const [variantDifficulty, setVariantDifficulty] =
    useState<ProblemDifficulty>("medium");

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

  const loadProblems = async () => {
    if (!selectedLessonId) return;
    setLoading(true);
    try {
      const result = await getProblems(
        { lessonId: selectedLessonId, searchText },
        100
      );
      setProblems(result.problems);
    } catch (error) {
      console.error(error);
    }
    setLoading(false);
  };

  useEffect(() => {
    if (selectedLessonId) {
      loadProblems();
    } else {
      setProblems([]);
    }
  }, [selectedLessonId]);

  const selectProblem = (p: Problem) => {
    setSelectedProblem(p);
    setStructuredHints([]);
    setVariants([]);
    setHintSaved(false);
    setVariantSaved(false);
    setHintError("");
    setVariantError("");
  };

  // ==================== HINT GENERATION ====================

  // Detect math topic from lesson title
  const detectTopic = (): string => {
    if (!selectedProblem) return "";
    const lesson = lessons.find((l) => l.id === selectedProblem.lessonId);
    if (!lesson) return "";
    const title = lesson.title.toLowerCase();
    const unit = units.find((u) => u.id === lesson.unitId);
    const unitTitle = unit?.title?.toLowerCase() || "";
    const combined = title + " " + unitTitle;

    if (/미분|적분|극한|미적/.test(combined)) return "미적분";
    if (/기하|도형|좌표|벡터|직선|원|삼각/.test(combined)) return "기하";
    if (/확률|통계|평균|분산|표준편차/.test(combined)) return "확률/통계";
    if (/수열|급수|점화/.test(combined)) return "수열";
    return "대수";
  };

  const generateHints = async () => {
    if (!selectedProblem) return;
    setHintLoading(true);
    setHintError("");
    setHintSaved(false);

    try {
      const user = auth.currentUser;
      const token = user ? await user.getIdToken() : null;

      const res = await fetch("/api/ai/generate-hints", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          ...(token && { Authorization: `Bearer ${token}` }),
        },
        body: JSON.stringify({
          question: selectedProblem.question,
          type: selectedProblem.type,
          options: selectedProblem.options,
          correctAnswer: selectedProblem.correctAnswer,
          explanation: selectedProblem.explanation,
          difficulty: selectedProblem.difficulty,
          topic: detectTopic(),
        }),
      });

      const data = await res.json();
      if (!res.ok) throw new Error(data.error || "힌트 생성 실패");
      setStructuredHints(
        data.structuredHints || data.hints.map((h: string, i: number) => ({
          step: i + 1,
          label: ["인지 활성화", "전략 제시", "해결 구조"][i] || `Step ${i + 1}`,
          content: h,
        }))
      );
    } catch (err) {
      setHintError(err instanceof Error ? err.message : "힌트 생성 실패");
    }
    setHintLoading(false);
  };

  const saveHints = async () => {
    if (!selectedProblem || structuredHints.length === 0) return;
    const flatHints = structuredHints.map((h) => h.content);
    try {
      await updateProblem(selectedProblem.id, { hints: flatHints });
      setHintSaved(true);
      setSelectedProblem({ ...selectedProblem, hints: flatHints });
      setProblems((prev) =>
        prev.map((p) =>
          p.id === selectedProblem.id ? { ...p, hints: flatHints } : p
        )
      );
    } catch (err) {
      setHintError("힌트 저장 실패");
      console.error(err);
    }
  };

  // ==================== VARIANT GENERATION ====================

  const generateVariants = async () => {
    if (!selectedProblem) return;
    setVariantLoading(true);
    setVariantError("");
    setVariantSaved(false);

    try {
      const user = auth.currentUser;
      const token = user ? await user.getIdToken() : null;

      const res = await fetch("/api/ai/generate-variants", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          ...(token && { Authorization: `Bearer ${token}` }),
        },
        body: JSON.stringify({
          question: selectedProblem.question,
          type: selectedProblem.type,
          options: selectedProblem.options,
          correctAnswer: selectedProblem.correctAnswer,
          explanation: selectedProblem.explanation,
          difficulty: selectedProblem.difficulty,
          variantCount,
          variantType,
        }),
      });

      const data = await res.json();
      if (!res.ok) throw new Error(data.error || "변형 문제 생성 실패");
      setVariants(
        data.variants.map((v: GeneratedVariant) => ({ ...v, selected: true }))
      );
    } catch (err) {
      setVariantError(
        err instanceof Error ? err.message : "변형 문제 생성 실패"
      );
    }
    setVariantLoading(false);
  };

  const saveVariants = async () => {
    if (!selectedProblem) return;
    const selected = variants.filter((v) => v.selected);
    if (selected.length === 0) return;

    try {
      const problemsToCreate = selected.map((v) => ({
        lessonId: selectedProblem.lessonId,
        question: v.question,
        type: v.type as Problem["type"],
        difficulty: variantDifficulty,
        options: v.options || [],
        correctAnswer: v.correctAnswer,
        explanation: v.explanation || "",
        hints: [] as string[],
        points: selectedProblem.points || 10,
        imageUrls: [] as string[],
      }));

      await bulkCreateProblems(problemsToCreate);
      setVariantSaved(true);
      // Reload problems
      loadProblems();
    } catch (err) {
      setVariantError("변형 문제 저장 실패");
      console.error(err);
    }
  };

  const toggleVariantSelection = (index: number) => {
    setVariants((prev) =>
      prev.map((v, i) => (i === index ? { ...v, selected: !v.selected } : v))
    );
  };

  const updateVariantField = (
    index: number,
    field: keyof GeneratedVariant,
    value: string
  ) => {
    setVariants((prev) =>
      prev.map((v, i) => (i === index ? { ...v, [field]: value } : v))
    );
  };

  // ==================== RENDER ====================

  const lessonMap = new Map(lessons.map((l) => [l.id, l]));
  const unitMap = new Map(units.map((u) => [u.id, u]));

  return (
    <AdminLayout>
      <div className="mx-auto max-w-7xl">
        {/* Header */}
        <div className="mb-8">
          <div className="flex items-center gap-3 mb-2">
            <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-purple-100">
              <Sparkles className="h-5 w-5 text-purple-600" />
            </div>
            <div>
              <h1 className="text-2xl font-bold text-gray-900">AI 도구</h1>
              <p className="text-sm text-gray-500">
                AI로 힌트 생성 및 문제 변형을 자동화합니다
              </p>
            </div>
          </div>
        </div>

        <div className="grid grid-cols-12 gap-6">
          {/* Left: Problem List */}
          <div className="col-span-5">
            <div className="rounded-xl border border-gray-200 bg-white">
              {/* Filters */}
              <div className="border-b border-gray-100 p-4 space-y-3">
                <div className="flex items-center gap-2 text-sm font-medium text-gray-700">
                  <Filter className="h-4 w-4" />
                  문제 선택
                </div>

                {/* Unit Select */}
                <div className="relative">
                  <select
                    value={selectedUnitId}
                    onChange={(e) => {
                      setSelectedUnitId(e.target.value);
                      setSelectedLessonId("");
                    }}
                    className="w-full appearance-none rounded-lg border border-gray-200 bg-white px-3 py-2 pr-8 text-sm focus:border-blue-500 focus:outline-none"
                  >
                    <option value="">전체 단원</option>
                    {units.map((u) => (
                      <option key={u.id} value={u.id}>
                        {u.emoji} {u.title}
                      </option>
                    ))}
                  </select>
                  <ChevronDown className="pointer-events-none absolute right-2 top-2.5 h-4 w-4 text-gray-400" />
                </div>

                {/* Lesson Select */}
                <div className="relative">
                  <select
                    value={selectedLessonId}
                    onChange={(e) => setSelectedLessonId(e.target.value)}
                    className="w-full appearance-none rounded-lg border border-gray-200 bg-white px-3 py-2 pr-8 text-sm focus:border-blue-500 focus:outline-none"
                  >
                    <option value="">레슨 선택</option>
                    {filteredLessons.map((l) => (
                      <option key={l.id} value={l.id}>
                        {l.title}
                      </option>
                    ))}
                  </select>
                  <ChevronDown className="pointer-events-none absolute right-2 top-2.5 h-4 w-4 text-gray-400" />
                </div>

                {/* Search */}
                <div className="relative">
                  <Search className="absolute left-3 top-2.5 h-4 w-4 text-gray-400" />
                  <input
                    type="text"
                    value={searchText}
                    onChange={(e) => setSearchText(e.target.value)}
                    onKeyDown={(e) => e.key === "Enter" && loadProblems()}
                    placeholder="문제 검색..."
                    className="w-full rounded-lg border border-gray-200 bg-white pl-9 pr-3 py-2 text-sm focus:border-blue-500 focus:outline-none"
                  />
                </div>
              </div>

              {/* Problem List */}
              <div className="max-h-[calc(100vh-340px)] overflow-y-auto divide-y divide-gray-50">
                {loading ? (
                  <div className="flex items-center justify-center py-12">
                    <Loader2 className="h-6 w-6 animate-spin text-gray-400" />
                  </div>
                ) : problems.length === 0 ? (
                  <div className="py-12 text-center text-sm text-gray-400">
                    {selectedLessonId
                      ? "해당 레슨에 문제가 없습니다"
                      : "레슨을 선택하세요"}
                  </div>
                ) : (
                  problems.map((p) => (
                    <button
                      key={p.id}
                      onClick={() => selectProblem(p)}
                      className={`w-full text-left px-4 py-3 transition-colors hover:bg-gray-50 ${
                        selectedProblem?.id === p.id
                          ? "bg-purple-50 border-l-3 border-l-purple-500"
                          : ""
                      }`}
                    >
                      <div className="flex items-start justify-between gap-2">
                        <div className="min-w-0 flex-1">
                          <div className="text-sm text-gray-900 line-clamp-2">
                            <LatexRenderer text={p.question} />
                          </div>
                          <div className="mt-1 flex items-center gap-2">
                            <span className="inline-flex items-center rounded-full bg-gray-100 px-2 py-0.5 text-xs text-gray-600">
                              {PROBLEM_TYPE_LABELS[p.type] || p.type}
                            </span>
                            <span className="inline-flex items-center rounded-full bg-gray-100 px-2 py-0.5 text-xs text-gray-600">
                              {DIFFICULTY_LABELS[p.difficulty] || p.difficulty}
                            </span>
                            {p.hints && p.hints.length > 0 && (
                              <span className="inline-flex items-center rounded-full bg-amber-100 px-2 py-0.5 text-xs text-amber-700">
                                <Lightbulb className="mr-0.5 h-3 w-3" />
                                {p.hints.length}
                              </span>
                            )}
                          </div>
                        </div>
                        <ArrowRight className="mt-1 h-4 w-4 shrink-0 text-gray-300" />
                      </div>
                    </button>
                  ))
                )}
              </div>
            </div>
          </div>

          {/* Right: AI Tools */}
          <div className="col-span-7">
            {!selectedProblem ? (
              <div className="flex h-96 items-center justify-center rounded-xl border-2 border-dashed border-gray-200 bg-white">
                <div className="text-center">
                  <Sparkles className="mx-auto h-12 w-12 text-gray-300" />
                  <p className="mt-3 text-sm text-gray-400">
                    왼쪽에서 문제를 선택하면
                    <br />
                    AI 도구를 사용할 수 있습니다
                  </p>
                </div>
              </div>
            ) : (
              <div className="space-y-4">
                {/* Selected Problem Preview */}
                <div className="rounded-xl border border-gray-200 bg-white p-5">
                  <div className="flex items-center justify-between mb-3">
                    <span className="text-xs font-medium text-gray-400 uppercase tracking-wider">
                      선택된 문제
                    </span>
                    <button
                      onClick={() => setSelectedProblem(null)}
                      className="rounded-lg p-1 text-gray-400 hover:bg-gray-100 hover:text-gray-600"
                    >
                      <X className="h-4 w-4" />
                    </button>
                  </div>
                  <div className="text-sm text-gray-800 leading-relaxed">
                    <LatexRenderer text={selectedProblem.question} />
                  </div>
                  {selectedProblem.options.length > 0 && (
                    <div className="mt-3 space-y-1">
                      {selectedProblem.options.map((opt, i) => (
                        <div
                          key={i}
                          className={`text-sm px-3 py-1.5 rounded-lg ${
                            opt === selectedProblem.correctAnswer
                              ? "bg-green-50 text-green-700 font-medium"
                              : "text-gray-600"
                          }`}
                        >
                          <span className="text-gray-400 mr-2">{i + 1}.</span>
                          <LatexRenderer text={opt} />
                        </div>
                      ))}
                    </div>
                  )}
                  <div className="mt-3 flex items-center gap-2 text-xs text-gray-500">
                    <span>
                      정답:{" "}
                      <span className="font-medium text-green-600">
                        <LatexRenderer text={selectedProblem.correctAnswer} />
                      </span>
                    </span>
                    {selectedProblem.explanation && (
                      <span className="text-gray-300">|</span>
                    )}
                    {selectedProblem.explanation && (
                      <span className="truncate max-w-xs">
                        풀이: <LatexRenderer text={selectedProblem.explanation} />
                      </span>
                    )}
                  </div>
                </div>

                {/* Tab Buttons */}
                <div className="flex gap-2">
                  <button
                    onClick={() => setActiveTab("hints")}
                    className={`flex items-center gap-2 rounded-lg px-4 py-2.5 text-sm font-medium transition-colors ${
                      activeTab === "hints"
                        ? "bg-amber-500 text-white shadow-sm"
                        : "bg-white text-gray-600 border border-gray-200 hover:bg-gray-50"
                    }`}
                  >
                    <Lightbulb className="h-4 w-4" />
                    힌트 생성
                  </button>
                  <button
                    onClick={() => setActiveTab("variants")}
                    className={`flex items-center gap-2 rounded-lg px-4 py-2.5 text-sm font-medium transition-colors ${
                      activeTab === "variants"
                        ? "bg-purple-500 text-white shadow-sm"
                        : "bg-white text-gray-600 border border-gray-200 hover:bg-gray-50"
                    }`}
                  >
                    <Copy className="h-4 w-4" />
                    문제 변형
                  </button>
                </div>

                {/* Hint Generation Tab */}
                {activeTab === "hints" && (
                  <div className="rounded-xl border border-gray-200 bg-white p-5">
                    <div className="flex items-center justify-between mb-4">
                      <div>
                        <h3 className="text-base font-semibold text-gray-900">
                          GoPS 3-Step 힌트 생성
                        </h3>
                        <p className="text-xs text-gray-500 mt-0.5">
                          인지 활성화 → 전략 제시 → 해결 구조 (보이게 → 생각하게 → 풀게)
                        </p>
                      </div>
                      <button
                        onClick={generateHints}
                        disabled={hintLoading}
                        className="flex items-center gap-2 rounded-lg bg-amber-500 px-4 py-2 text-sm font-medium text-white hover:bg-amber-600 disabled:opacity-50 transition-colors"
                      >
                        {hintLoading ? (
                          <Loader2 className="h-4 w-4 animate-spin" />
                        ) : (
                          <Wand2 className="h-4 w-4" />
                        )}
                        {hintLoading ? "생성 중..." : "힌트 생성"}
                      </button>
                    </div>

                    {/* Current hints */}
                    {selectedProblem.hints &&
                      selectedProblem.hints.length > 0 && (
                        <div className="mb-4 rounded-lg bg-amber-50 p-3">
                          <div className="text-xs font-medium text-amber-700 mb-2">
                            기존 힌트 ({selectedProblem.hints.length}개)
                          </div>
                          {selectedProblem.hints.map((h, i) => (
                            <div
                              key={i}
                              className="text-sm text-amber-800 py-1"
                            >
                              <span className="font-medium mr-2">
                                {i + 1}.
                              </span>
                              <LatexRenderer text={h} />
                            </div>
                          ))}
                        </div>
                      )}

                    {/* Error */}
                    {hintError && (
                      <div className="mb-4 flex items-center gap-2 rounded-lg bg-red-50 p-3 text-sm text-red-600">
                        <AlertCircle className="h-4 w-4 shrink-0" />
                        {hintError}
                      </div>
                    )}

                    {/* Generated Hints - GoPS 3-Step */}
                    {structuredHints.length > 0 && (
                      <div className="space-y-3">
                        <div className="text-xs font-medium text-gray-500 uppercase tracking-wider">
                          GoPS 3-Step 힌트
                        </div>
                        {structuredHints.map((hint, i) => {
                          const stepConfig = [
                            {
                              color: "bg-blue-500",
                              borderColor: "border-blue-200",
                              bgColor: "bg-blue-50/50",
                              tagColor: "bg-blue-100 text-blue-700",
                              desc: "보이게 한다 - 질문으로 끝나야 함",
                            },
                            {
                              color: "bg-amber-500",
                              borderColor: "border-amber-200",
                              bgColor: "bg-amber-50/50",
                              tagColor: "bg-amber-100 text-amber-700",
                              desc: "생각하게 한다 - ~해보자로 끝나야 함",
                            },
                            {
                              color: "bg-rose-500",
                              borderColor: "border-rose-200",
                              bgColor: "bg-rose-50/50",
                              tagColor: "bg-rose-100 text-rose-700",
                              desc: "풀게 한다 - 마지막 답만 빼고 scaffold",
                            },
                          ][i] || {
                            color: "bg-gray-500",
                            borderColor: "border-gray-200",
                            bgColor: "bg-gray-50",
                            tagColor: "bg-gray-100 text-gray-700",
                            desc: "",
                          };

                          return (
                            <div
                              key={i}
                              className={`rounded-lg border ${stepConfig.borderColor} ${stepConfig.bgColor} p-4`}
                            >
                              <div className="flex items-center gap-2 mb-2">
                                <span
                                  className={`flex h-6 w-6 items-center justify-center rounded-full text-xs font-bold text-white ${stepConfig.color}`}
                                >
                                  {hint.step}
                                </span>
                                <span
                                  className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold ${stepConfig.tagColor}`}
                                >
                                  {hint.label}
                                </span>
                                <span className="text-[10px] text-gray-400 ml-auto">
                                  {stepConfig.desc}
                                </span>
                              </div>
                              {/* Editable hint content */}
                              <textarea
                                value={hint.content}
                                onChange={(e) => {
                                  const updated = [...structuredHints];
                                  updated[i] = {
                                    ...updated[i],
                                    content: e.target.value,
                                  };
                                  setStructuredHints(updated);
                                }}
                                rows={3}
                                className="w-full rounded-lg border border-gray-200 bg-white px-3 py-2 text-sm focus:border-blue-500 focus:outline-none resize-none"
                              />
                              <div className="mt-2 rounded-lg bg-white border border-gray-100 p-3 text-sm text-gray-700 overflow-x-auto">
                                <LatexRenderer text={hint.content} />
                              </div>
                            </div>
                          );
                        })}

                        {/* Save Button */}
                        <div className="flex items-center gap-3 pt-2">
                          <button
                            onClick={saveHints}
                            disabled={hintSaved}
                            className={`flex items-center gap-2 rounded-lg px-5 py-2.5 text-sm font-medium transition-colors ${
                              hintSaved
                                ? "bg-green-100 text-green-700"
                                : "bg-blue-600 text-white hover:bg-blue-700"
                            }`}
                          >
                            {hintSaved ? (
                              <Check className="h-4 w-4" />
                            ) : (
                              <Save className="h-4 w-4" />
                            )}
                            {hintSaved ? "저장 완료" : "힌트 저장"}
                          </button>
                          <button
                            onClick={generateHints}
                            disabled={hintLoading}
                            className="flex items-center gap-2 rounded-lg border border-gray-200 bg-white px-4 py-2.5 text-sm text-gray-600 hover:bg-gray-50 transition-colors"
                          >
                            <RefreshCw className="h-4 w-4" />
                            재생성
                          </button>
                        </div>
                      </div>
                    )}
                  </div>
                )}

                {/* Variant Generation Tab */}
                {activeTab === "variants" && (
                  <div className="rounded-xl border border-gray-200 bg-white p-5">
                    <div className="mb-4">
                      <h3 className="text-base font-semibold text-gray-900">
                        문제 변형 생성
                      </h3>
                      <p className="text-xs text-gray-500 mt-0.5">
                        원본 문제를 기반으로 유사한 변형 문제를 자동 생성합니다
                      </p>
                    </div>

                    {/* Options */}
                    <div className="grid grid-cols-3 gap-3 mb-4">
                      {/* Variant Type */}
                      <div>
                        <label className="block text-xs font-medium text-gray-600 mb-1">
                          변형 유형
                        </label>
                        <select
                          value={variantType}
                          onChange={(e) =>
                            setVariantType(e.target.value as VariantType)
                          }
                          className="w-full rounded-lg border border-gray-200 bg-white px-3 py-2 text-sm focus:border-blue-500 focus:outline-none"
                        >
                          <option value="number_change">숫자 변경</option>
                          <option value="level_up">난이도 상향</option>
                          <option value="concept_similar">유사 개념</option>
                        </select>
                      </div>

                      {/* Count */}
                      <div>
                        <label className="block text-xs font-medium text-gray-600 mb-1">
                          생성 개수
                        </label>
                        <select
                          value={variantCount}
                          onChange={(e) =>
                            setVariantCount(Number(e.target.value))
                          }
                          className="w-full rounded-lg border border-gray-200 bg-white px-3 py-2 text-sm focus:border-blue-500 focus:outline-none"
                        >
                          {[1, 2, 3, 5].map((n) => (
                            <option key={n} value={n}>
                              {n}개
                            </option>
                          ))}
                        </select>
                      </div>

                      {/* Difficulty */}
                      <div>
                        <label className="block text-xs font-medium text-gray-600 mb-1">
                          저장 난이도
                        </label>
                        <select
                          value={variantDifficulty}
                          onChange={(e) =>
                            setVariantDifficulty(
                              e.target.value as ProblemDifficulty
                            )
                          }
                          className="w-full rounded-lg border border-gray-200 bg-white px-3 py-2 text-sm focus:border-blue-500 focus:outline-none"
                        >
                          {Object.entries(DIFFICULTY_LABELS).map(
                            ([val, label]) => (
                              <option key={val} value={val}>
                                {label}
                              </option>
                            )
                          )}
                        </select>
                      </div>
                    </div>

                    {/* Variant Type Description */}
                    <div className="mb-4 rounded-lg bg-purple-50 p-3 text-xs text-purple-700">
                      {variantType === "number_change" &&
                        "숫자/계수만 변경하여 같은 유형의 연습 문제를 생성합니다."}
                      {variantType === "level_up" &&
                        "난이도를 높여 더 복잡한 조건의 심화 문제를 생성합니다."}
                      {variantType === "concept_similar" &&
                        "같은 개념을 다른 형태로 응용한 문제를 생성합니다."}
                    </div>

                    {/* Generate Button */}
                    <button
                      onClick={generateVariants}
                      disabled={variantLoading}
                      className="flex items-center gap-2 rounded-lg bg-purple-500 px-4 py-2 text-sm font-medium text-white hover:bg-purple-600 disabled:opacity-50 transition-colors mb-4"
                    >
                      {variantLoading ? (
                        <Loader2 className="h-4 w-4 animate-spin" />
                      ) : (
                        <Wand2 className="h-4 w-4" />
                      )}
                      {variantLoading ? "생성 중..." : "변형 문제 생성"}
                    </button>

                    {/* Error */}
                    {variantError && (
                      <div className="mb-4 flex items-center gap-2 rounded-lg bg-red-50 p-3 text-sm text-red-600">
                        <AlertCircle className="h-4 w-4 shrink-0" />
                        {variantError}
                      </div>
                    )}

                    {/* Generated Variants */}
                    {variants.length > 0 && (
                      <div className="space-y-4">
                        <div className="text-xs font-medium text-gray-500 uppercase tracking-wider">
                          생성된 변형 문제 ({variants.length}개)
                        </div>

                        {variants.map((v, i) => (
                          <div
                            key={i}
                            className={`rounded-lg border p-4 transition-colors ${
                              v.selected
                                ? "border-purple-200 bg-purple-50/30"
                                : "border-gray-100 bg-gray-50 opacity-60"
                            }`}
                          >
                            <div className="flex items-center justify-between mb-3">
                              <div className="flex items-center gap-2">
                                <input
                                  type="checkbox"
                                  checked={v.selected}
                                  onChange={() => toggleVariantSelection(i)}
                                  className="h-4 w-4 rounded border-gray-300 text-purple-600 focus:ring-purple-500"
                                />
                                <span className="text-sm font-medium text-gray-700">
                                  변형 #{i + 1}
                                </span>
                                <span className="inline-flex items-center rounded-full bg-gray-100 px-2 py-0.5 text-xs text-gray-600">
                                  {PROBLEM_TYPE_LABELS[v.type as Problem["type"]] || v.type}
                                </span>
                              </div>
                            </div>

                            {/* Question */}
                            <div className="mb-2">
                              <label className="text-xs text-gray-500">
                                문제
                              </label>
                              <textarea
                                value={v.question}
                                onChange={(e) =>
                                  updateVariantField(
                                    i,
                                    "question",
                                    e.target.value
                                  )
                                }
                                rows={2}
                                className="mt-1 w-full rounded-lg border border-gray-200 bg-white px-3 py-2 text-sm focus:border-purple-500 focus:outline-none resize-none"
                              />
                              <div className="mt-1 text-xs text-gray-400">
                                <LatexRenderer text={v.question} />
                              </div>
                            </div>

                            {/* Options (for multiple choice) */}
                            {v.options && v.options.length > 0 && (
                              <div className="mb-2">
                                <label className="text-xs text-gray-500">
                                  선택지
                                </label>
                                <div className="mt-1 space-y-1">
                                  {v.options.map((opt, oi) => (
                                    <div
                                      key={oi}
                                      className={`flex items-center gap-2 rounded-lg px-3 py-1.5 text-sm ${
                                        opt === v.correctAnswer
                                          ? "bg-green-50 text-green-700"
                                          : "text-gray-600"
                                      }`}
                                    >
                                      <span className="text-gray-400 text-xs">
                                        {oi + 1}.
                                      </span>
                                      <LatexRenderer text={opt} />
                                      {opt === v.correctAnswer && (
                                        <Check className="h-3 w-3 text-green-500 ml-auto" />
                                      )}
                                    </div>
                                  ))}
                                </div>
                              </div>
                            )}

                            {/* Correct Answer */}
                            <div className="mb-2">
                              <label className="text-xs text-gray-500">
                                정답
                              </label>
                              <input
                                type="text"
                                value={v.correctAnswer}
                                onChange={(e) =>
                                  updateVariantField(
                                    i,
                                    "correctAnswer",
                                    e.target.value
                                  )
                                }
                                className="mt-1 w-full rounded-lg border border-gray-200 bg-white px-3 py-2 text-sm focus:border-purple-500 focus:outline-none"
                              />
                            </div>

                            {/* Explanation */}
                            {v.explanation && (
                              <div>
                                <label className="text-xs text-gray-500">
                                  풀이
                                </label>
                                <div className="mt-1 text-sm text-gray-600">
                                  <LatexRenderer text={v.explanation} />
                                </div>
                              </div>
                            )}
                          </div>
                        ))}

                        {/* Save & Regenerate */}
                        <div className="flex items-center gap-3 pt-2">
                          <button
                            onClick={saveVariants}
                            disabled={
                              variantSaved ||
                              variants.filter((v) => v.selected).length === 0
                            }
                            className={`flex items-center gap-2 rounded-lg px-5 py-2.5 text-sm font-medium transition-colors ${
                              variantSaved
                                ? "bg-green-100 text-green-700"
                                : "bg-blue-600 text-white hover:bg-blue-700 disabled:opacity-50"
                            }`}
                          >
                            {variantSaved ? (
                              <Check className="h-4 w-4" />
                            ) : (
                              <Save className="h-4 w-4" />
                            )}
                            {variantSaved
                              ? "저장 완료"
                              : `선택한 ${
                                  variants.filter((v) => v.selected).length
                                }개 저장`}
                          </button>
                          <button
                            onClick={generateVariants}
                            disabled={variantLoading}
                            className="flex items-center gap-2 rounded-lg border border-gray-200 bg-white px-4 py-2.5 text-sm text-gray-600 hover:bg-gray-50 transition-colors"
                          >
                            <RefreshCw className="h-4 w-4" />
                            재생성
                          </button>
                        </div>
                      </div>
                    )}
                  </div>
                )}
              </div>
            )}
          </div>
        </div>
      </div>
    </AdminLayout>
  );
}
