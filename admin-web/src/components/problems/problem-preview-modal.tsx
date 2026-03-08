"use client";

import { useState } from "react";
import { Problem, PROBLEM_TYPE_LABELS, DIFFICULTY_LABELS } from "@/lib/types";
import LatexRenderer from "@/components/ui/latex-renderer";
import { X, ChevronDown, ChevronUp, Lightbulb, BookOpen } from "lucide-react";

interface ProblemPreviewModalProps {
  problem: Problem | null;
  onClose: () => void;
}

export default function ProblemPreviewModal({ problem, onClose }: ProblemPreviewModalProps) {
  const [selectedOption, setSelectedOption] = useState<number | null>(null);
  const [showHints, setShowHints] = useState(false);
  const [showExplanation, setShowExplanation] = useState(false);

  if (!problem) return null;

  const difficultyColor: Record<string, string> = {
    easy: "bg-green-100 text-green-700",
    medium: "bg-yellow-100 text-yellow-700",
    hard: "bg-orange-100 text-orange-700",
    expert: "bg-red-100 text-red-700",
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50" onClick={onClose}>
      <div
        className="relative w-full max-w-sm mx-4 rounded-3xl bg-white shadow-2xl max-h-[90vh] flex flex-col overflow-hidden"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Phone-like header */}
        <div className="bg-gradient-to-b from-blue-600 to-blue-500 px-5 pt-5 pb-4">
          <div className="flex items-center justify-between mb-3">
            <span className="text-xs font-medium text-blue-200">학생 미리보기</span>
            <button onClick={onClose} className="text-white/70 hover:text-white transition-colors">
              <X className="h-5 w-5" />
            </button>
          </div>
          <div className="flex items-center gap-2">
            <span className={`rounded-full px-2.5 py-0.5 text-xs font-bold ${difficultyColor[problem.difficulty] || "bg-gray-100 text-gray-700"}`}>
              {DIFFICULTY_LABELS[problem.difficulty] || problem.difficulty}
            </span>
            <span className="rounded-full bg-white/20 px-2.5 py-0.5 text-xs font-bold text-white">
              {problem.points}점
            </span>
            <span className="rounded-full bg-white/20 px-2.5 py-0.5 text-xs font-medium text-white">
              {PROBLEM_TYPE_LABELS[problem.type] || problem.type}
            </span>
          </div>
        </div>

        {/* Content area */}
        <div className="flex-1 overflow-y-auto px-5 py-5 space-y-5">
          {/* Question */}
          <div>
            <div className="text-base font-semibold text-gray-900 leading-relaxed">
              <LatexRenderer text={problem.question} />
            </div>
          </div>

          {/* Images */}
          {problem.imageUrls && problem.imageUrls.length > 0 && (
            <div className="space-y-2">
              {problem.imageUrls.map((url, i) => (
                <img
                  key={i}
                  src={url}
                  alt={`문제 이미지 ${i + 1}`}
                  className="w-full rounded-xl border border-gray-100 object-contain"
                />
              ))}
            </div>
          )}

          {/* Options (multiple choice) */}
          {problem.type === "multipleChoice" && problem.options && problem.options.length > 0 && (
            <div className="space-y-2.5">
              {problem.options.map((option, i) => {
                const isSelected = selectedOption === i;
                const isCorrect = option === problem.correctAnswer;
                const showResult = selectedOption !== null;

                return (
                  <button
                    key={i}
                    onClick={() => setSelectedOption(i)}
                    className={`w-full flex items-center gap-3 rounded-2xl border-2 px-4 py-3.5 text-left transition-all ${
                      showResult && isCorrect
                        ? "border-green-400 bg-green-50"
                        : showResult && isSelected && !isCorrect
                        ? "border-red-400 bg-red-50"
                        : isSelected
                        ? "border-blue-500 bg-blue-50"
                        : "border-gray-200 hover:border-gray-300 hover:bg-gray-50"
                    }`}
                  >
                    <div className={`flex h-8 w-8 items-center justify-center rounded-full text-sm font-bold flex-shrink-0 ${
                      showResult && isCorrect
                        ? "bg-green-500 text-white"
                        : showResult && isSelected && !isCorrect
                        ? "bg-red-500 text-white"
                        : isSelected
                        ? "bg-blue-600 text-white"
                        : "bg-gray-100 text-gray-500"
                    }`}>
                      {String.fromCharCode(65 + i)}
                    </div>
                    <span className="text-sm font-medium text-gray-800 flex-1">
                      <LatexRenderer text={option} />
                    </span>
                  </button>
                );
              })}
            </div>
          )}

          {/* True/False */}
          {problem.type === "trueFalse" && (
            <div className="flex gap-3">
              {(["true", "false"] as const).map((v) => {
                const isSelected = selectedOption === (v === "true" ? 0 : 1);
                const isCorrect = problem.correctAnswer === v;
                const showResult = selectedOption !== null;

                return (
                  <button
                    key={v}
                    onClick={() => setSelectedOption(v === "true" ? 0 : 1)}
                    className={`flex-1 rounded-2xl border-2 py-4 text-base font-bold transition-all ${
                      showResult && isCorrect
                        ? "border-green-400 bg-green-50 text-green-700"
                        : showResult && isSelected && !isCorrect
                        ? "border-red-400 bg-red-50 text-red-700"
                        : isSelected
                        ? "border-blue-500 bg-blue-50 text-blue-700"
                        : "border-gray-200 text-gray-500 hover:border-gray-300"
                    }`}
                  >
                    {v === "true" ? "O" : "X"}
                  </button>
                );
              })}
            </div>
          )}

          {/* Short answer display */}
          {problem.type === "shortAnswer" && (
            <div className="rounded-2xl border-2 border-dashed border-gray-300 px-4 py-4">
              <p className="text-xs text-gray-400 mb-1">정답</p>
              <p className="text-sm font-medium text-gray-700">
                <LatexRenderer text={problem.correctAnswer} />
              </p>
            </div>
          )}

          {/* Hints (collapsible) */}
          {problem.hints && problem.hints.length > 0 && problem.hints.some(h => h.trim()) && (
            <div className="rounded-2xl border border-amber-200 bg-amber-50/60 overflow-hidden">
              <button
                onClick={() => setShowHints(!showHints)}
                className="w-full flex items-center justify-between px-4 py-3 text-left"
              >
                <div className="flex items-center gap-2">
                  <Lightbulb className="h-4 w-4 text-amber-500" />
                  <span className="text-sm font-semibold text-amber-800">힌트</span>
                  <span className="text-xs text-amber-500">({problem.hints.filter(h => h.trim()).length}개)</span>
                </div>
                {showHints ? (
                  <ChevronUp className="h-4 w-4 text-amber-500" />
                ) : (
                  <ChevronDown className="h-4 w-4 text-amber-500" />
                )}
              </button>
              {showHints && (
                <div className="px-4 pb-3 space-y-2">
                  {problem.hints.filter(h => h.trim()).map((hint, i) => (
                    <div key={i} className="flex items-start gap-2">
                      <span className="text-xs font-bold text-amber-600 mt-0.5 w-4 flex-shrink-0 text-center">{i + 1}</span>
                      <p className="text-sm text-amber-900">
                        <LatexRenderer text={hint} />
                      </p>
                    </div>
                  ))}
                </div>
              )}
            </div>
          )}

          {/* Explanation (collapsible) */}
          {problem.explanation && (
            <div className="rounded-2xl border border-green-200 bg-green-50/60 overflow-hidden">
              <button
                onClick={() => setShowExplanation(!showExplanation)}
                className="w-full flex items-center justify-between px-4 py-3 text-left"
              >
                <div className="flex items-center gap-2">
                  <BookOpen className="h-4 w-4 text-green-600" />
                  <span className="text-sm font-semibold text-green-800">풀이 설명</span>
                </div>
                {showExplanation ? (
                  <ChevronUp className="h-4 w-4 text-green-500" />
                ) : (
                  <ChevronDown className="h-4 w-4 text-green-500" />
                )}
              </button>
              {showExplanation && (
                <div className="px-4 pb-3">
                  <p className="text-sm text-green-900 leading-relaxed">
                    <LatexRenderer text={problem.explanation} />
                  </p>
                </div>
              )}
            </div>
          )}
        </div>

        {/* Footer */}
        <div className="px-5 py-4 border-t border-gray-100 bg-gray-50/50">
          <button
            onClick={() => { setSelectedOption(null); setShowHints(false); setShowExplanation(false); }}
            className="w-full rounded-2xl bg-gray-200 py-3 text-sm font-medium text-gray-600 hover:bg-gray-300 transition-colors"
          >
            초기화
          </button>
        </div>
      </div>
    </div>
  );
}
