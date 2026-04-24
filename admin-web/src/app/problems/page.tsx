"use client";

import { useEffect, useState } from "react";
import AdminLayout from "@/components/layout/admin-layout";
import { getProblems, deleteProblem, getUnits, getLessons, getProblemCountsByLesson, ProblemFilters } from "@/lib/firestore";
import { Problem, Unit, Lesson, PROBLEM_TYPE_LABELS, DIFFICULTY_LABELS } from "@/lib/types";
import LatexRenderer from "@/components/ui/latex-renderer";
import CreateProblemModal from "@/components/problems/create-problem-modal";
import { DocumentSnapshot } from "firebase/firestore";
import {
  Trash2, Edit2, Plus, AlertCircle,
  ChevronDown, ChevronRight, Lightbulb, BookOpen,
} from "lucide-react";
import { GRADES, DEFAULT_GRADE } from "@/lib/grades";

export default function ProblemsPage(): React.JSX.Element {
  const [units, setUnits] = useState<Unit[]>([]);
  const [lessons, setLessons] = useState<Lesson[]>([]);
  const [problemCounts, setProblemCounts] = useState<Record<string, number>>({});
  const [loading, setLoading] = useState(true);

  // Navigation state
  const [activeGrade, setActiveGrade] = useState(DEFAULT_GRADE);
  const [expandedSubject, setExpandedSubject] = useState<string | null>(null);
  const [expandedUnit, setExpandedUnit] = useState<string | null>(null);
  const [selectedLesson, setSelectedLesson] = useState<Lesson | null>(null);

  // Problem list for selected lesson
  const [problems, setProblems] = useState<Problem[]>([]);
  const [problemsLoading, setProblemsLoading] = useState(false);
  const [expandedProblem, setExpandedProblem] = useState<string | null>(null);
  const [lastDoc, setLastDoc] = useState<DocumentSnapshot | null>(null);
  const [hasMore, setHasMore] = useState(false);

  // Modal
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [editingProblem, setEditingProblem] = useState<Problem | null>(null);
  const [error, setError] = useState("");

  useEffect(() => {
    loadCurriculum();
  }, []);

  const loadCurriculum = async (): Promise<void> => {
    try {
      const [u, l, c] = await Promise.all([getUnits(), getLessons(), getProblemCountsByLesson()]);
      setUnits(u);
      setLessons(l);
      setProblemCounts(c);
    } catch (err) {
      console.error(err);
      setError("데이터를 불러오지 못했습니다.");
    } finally {
      setLoading(false);
    }
  };

  const handleSelectLesson = async (lesson: Lesson): Promise<void> => {
    setSelectedLesson(lesson);
    setProblems([]);
    setLastDoc(null);
    setExpandedProblem(null);
    setProblemsLoading(true);
    try {
      const filters: ProblemFilters = { lessonId: lesson.id };
      const result = await getProblems(filters, 50);
      setProblems(result.problems);
      setLastDoc(result.lastDoc);
      setHasMore(result.problems.length === 50);
    } catch (err) {
      console.error(err);
    } finally {
      setProblemsLoading(false);
    }
  };

  const handleDelete = async (id: string): Promise<void> => {
    if (!confirm("이 문제를 삭제하시겠습니까?")) return;
    try {
      await deleteProblem(id);
      setProblems(problems.filter((p) => p.id !== id));
      setProblemCounts((prev) => ({
        ...prev,
        [selectedLesson?.id || ""]: (prev[selectedLesson?.id || ""] || 1) - 1,
      }));
    } catch (err) {
      console.error(err);
      setError("삭제에 실패했습니다.");
    }
  };

  const loadMore = async (): Promise<void> => {
    if (!selectedLesson || !lastDoc) return;
    setProblemsLoading(true);
    try {
      const result = await getProblems({ lessonId: selectedLesson.id }, 50, lastDoc);
      setProblems([...problems, ...result.problems]);
      setLastDoc(result.lastDoc);
      setHasMore(result.problems.length === 50);
    } finally {
      setProblemsLoading(false);
    }
  };

  // Current grade data
  const grade = GRADES.find((g) => g.key === activeGrade) ?? GRADES[2];
  const gradeSubjects = grade.subjects;

  return (
    <AdminLayout>
      {error && (
        <div className="mb-4 flex items-center gap-2 rounded-lg bg-red-50 border border-red-200 px-4 py-3">
          <AlertCircle className="h-4 w-4 text-red-500 flex-shrink-0" />
          <span className="text-sm text-red-700">{error}</span>
          <button onClick={() => setError("")} className="ml-auto text-red-400 hover:text-red-600">&times;</button>
        </div>
      )}

      <div className="flex gap-6 h-[calc(100vh-7rem)]">
        {/* ===== LEFT: 학년/과목/단원/레슨 트리 ===== */}
        <div className="w-80 flex-shrink-0 flex flex-col rounded-xl border border-gray-200 bg-white overflow-hidden">
          {/* 학년 탭 */}
          <div className="flex border-b border-gray-200 bg-gray-50 overflow-x-auto">
            {GRADES.map((g) => (
              <button
                key={g.key}
                onClick={() => {
                  setActiveGrade(g.key);
                  setExpandedSubject(null);
                  setExpandedUnit(null);
                  setSelectedLesson(null);
                  setProblems([]);
                }}
                className={`flex-shrink-0 px-5 py-3 text-sm font-semibold border-b-2 transition-colors ${
                  activeGrade === g.key
                    ? "border-blue-600 text-blue-700 bg-white"
                    : "border-transparent text-gray-500 hover:text-gray-700"
                }`}
              >
                {g.label}
              </button>
            ))}
          </div>

          {/* 과목/단원/레슨 트리 */}
          <div className="flex-1 overflow-y-auto">
            {loading ? (
              <div className="flex items-center justify-center py-12">
                <div className="h-6 w-6 animate-spin rounded-full border-2 border-blue-600 border-t-transparent" />
              </div>
            ) : (
              gradeSubjects.map((subject) => {
                const subjectUnits = units.filter((u) => u.subject === subject);
                const isSubjectOpen = expandedSubject === subject;
                const subjectTotal = subjectUnits.reduce((sum, u) => {
                  const uLessons = lessons.filter((l) => l.unitId === u.id);
                  return sum + uLessons.reduce((s, l) => s + (problemCounts[l.id] || 0), 0);
                }, 0);

                return (
                  <div key={subject}>
                    {/* 과목 헤더 */}
                    <button
                      onClick={() => setExpandedSubject(isSubjectOpen ? null : subject)}
                      className="flex w-full items-center gap-2 px-4 py-3 text-left hover:bg-gray-50 border-b border-gray-100 transition-colors"
                    >
                      {isSubjectOpen ? (
                        <ChevronDown className="h-4 w-4 text-gray-400 flex-shrink-0" />
                      ) : (
                        <ChevronRight className="h-4 w-4 text-gray-400 flex-shrink-0" />
                      )}
                      <span className="text-sm font-bold text-gray-900 flex-1">{subject}</span>
                      <span className="rounded-full bg-gray-100 px-2 py-0.5 text-xs text-gray-500">
                        {subjectTotal}
                      </span>
                    </button>

                    {/* 단원 목록 */}
                    {isSubjectOpen && subjectUnits.map((unit) => {
                      const unitLessons = lessons.filter((l) => l.unitId === unit.id);
                      const isUnitOpen = expandedUnit === unit.id;
                      const unitTotal = unitLessons.reduce((s, l) => s + (problemCounts[l.id] || 0), 0);

                      return (
                        <div key={unit.id}>
                          <button
                            onClick={() => setExpandedUnit(isUnitOpen ? null : unit.id)}
                            className="flex w-full items-center gap-2 pl-8 pr-4 py-2.5 text-left hover:bg-blue-50/50 transition-colors"
                          >
                            {isUnitOpen ? (
                              <ChevronDown className="h-3.5 w-3.5 text-blue-400 flex-shrink-0" />
                            ) : (
                              <ChevronRight className="h-3.5 w-3.5 text-gray-400 flex-shrink-0" />
                            )}
                            <span className="text-xs font-semibold text-gray-700 flex-1 truncate">{unit.title}</span>
                            <span className={`rounded-full px-1.5 py-0.5 text-[10px] font-medium ${
                              unitTotal === 0 ? "bg-red-100 text-red-600" : "bg-blue-100 text-blue-600"
                            }`}>
                              {unitTotal}
                            </span>
                          </button>

                          {/* 레슨 목록 */}
                          {isUnitOpen && unitLessons.map((lesson) => {
                            const count = problemCounts[lesson.id] || 0;
                            const isSelected = selectedLesson?.id === lesson.id;

                            return (
                              <button
                                key={lesson.id}
                                onClick={() => handleSelectLesson(lesson)}
                                className={`flex w-full items-center gap-2 pl-14 pr-4 py-2 text-left transition-colors ${
                                  isSelected ? "bg-blue-50 border-r-2 border-blue-600" : "hover:bg-gray-50"
                                }`}
                              >
                                <span className={`text-xs flex-1 truncate ${
                                  isSelected ? "font-semibold text-blue-700" : "text-gray-600"
                                }`}>
                                  {lesson.title}
                                </span>
                                <span className={`rounded px-1.5 py-0.5 text-[10px] font-medium ${
                                  count === 0
                                    ? "bg-gray-100 text-gray-400"
                                    : count < 5
                                    ? "bg-amber-100 text-amber-600"
                                    : "bg-green-100 text-green-600"
                                }`}>
                                  {count}
                                </span>
                              </button>
                            );
                          })}
                        </div>
                      );
                    })}
                  </div>
                );
              })
            )}
          </div>
        </div>

        {/* ===== RIGHT: 문제 목록 ===== */}
        <div className="flex-1 flex flex-col rounded-xl border border-gray-200 bg-white overflow-hidden">
          {/* 헤더 */}
          <div className="flex items-center justify-between px-6 py-4 border-b border-gray-200 bg-gray-50/50">
            {selectedLesson ? (
              <div className="min-w-0">
                <h2 className="text-lg font-bold text-gray-900 truncate">{selectedLesson.title}</h2>
                <p className="text-sm text-gray-500 mt-0.5">{problems.length}개 문제</p>
              </div>
            ) : (
              <div>
                <h2 className="text-lg font-bold text-gray-900">문제 관리</h2>
                <p className="text-sm text-gray-500 mt-0.5">왼쪽에서 레슨을 선택하세요</p>
              </div>
            )}
            {selectedLesson && (
              <button
                onClick={() => { setEditingProblem(null); setShowCreateModal(true); }}
                className="flex items-center gap-1.5 rounded-lg bg-blue-600 px-3.5 py-2 text-xs font-semibold text-white hover:bg-blue-700 transition-colors"
              >
                <Plus className="h-3.5 w-3.5" />
                문제 추가
              </button>
            )}
          </div>

          {/* 문제 리스트 */}
          <div className="flex-1 overflow-y-auto">
            {!selectedLesson ? (
              <div className="flex flex-col items-center justify-center h-full text-gray-400">
                <BookOpen className="h-12 w-12 mb-3 opacity-30" />
                <p className="text-sm">왼쪽 트리에서 레슨을 선택하면</p>
                <p className="text-sm">해당 레슨의 문제가 표시됩니다</p>
              </div>
            ) : problemsLoading && problems.length === 0 ? (
              <div className="flex items-center justify-center py-20">
                <div className="h-6 w-6 animate-spin rounded-full border-2 border-blue-600 border-t-transparent" />
              </div>
            ) : problems.length === 0 ? (
              <div className="flex flex-col items-center justify-center h-full text-gray-400">
                <p className="text-sm mb-2">이 레슨에 문제가 없습니다</p>
                <button
                  onClick={() => { setEditingProblem(null); setShowCreateModal(true); }}
                  className="text-sm text-blue-600 hover:text-blue-700 font-medium"
                >
                  첫 문제 추가하기
                </button>
              </div>
            ) : (
              <div className="divide-y divide-gray-100">
                {problems.map((problem, idx) => {
                  const isExpanded = expandedProblem === problem.id;
                  const hasHints = problem.hints && problem.hints.length > 0;
                  const hasExplanation = !!problem.explanation;

                  return (
                    <div key={problem.id}>
                      {/* 문제 행 */}
                      <div
                        className="flex items-start gap-3 px-5 py-3.5 hover:bg-gray-50 cursor-pointer transition-colors"
                        onClick={() => setExpandedProblem(isExpanded ? null : problem.id)}
                      >
                        <span className="text-xs font-bold text-gray-300 mt-1 w-5 text-right flex-shrink-0">
                          {idx + 1}
                        </span>
                        <div className="flex-1 min-w-0">
                          <div className="text-sm text-gray-900 mb-1.5 leading-relaxed">
                            <LatexRenderer text={problem.question} />
                          </div>
                          <div className="flex flex-wrap gap-1.5">
                            <span className="rounded bg-blue-50 px-1.5 py-0.5 text-[10px] font-medium text-blue-700">
                              {PROBLEM_TYPE_LABELS[problem.type] || problem.type}
                            </span>
                            <span className="rounded bg-orange-50 px-1.5 py-0.5 text-[10px] font-medium text-orange-700">
                              {DIFFICULTY_LABELS[problem.difficulty] || problem.difficulty}
                            </span>
                            <span className="rounded bg-gray-100 px-1.5 py-0.5 text-[10px] font-medium text-gray-500">
                              {problem.points}점
                            </span>
                            {hasHints && (
                              <span className="rounded bg-amber-50 px-1.5 py-0.5 text-[10px] font-medium text-amber-600">
                                힌트 {problem.hints.length}
                              </span>
                            )}
                          </div>
                        </div>
                        <div className="flex items-center gap-0.5 flex-shrink-0">
                          <button
                            onClick={(e) => { e.stopPropagation(); setEditingProblem(problem); setShowCreateModal(true); }}
                            className="h-7 w-7 flex items-center justify-center rounded text-gray-400 hover:bg-blue-50 hover:text-blue-600"
                            title="수정"
                          >
                            <Edit2 className="h-3.5 w-3.5" />
                          </button>
                          <button
                            onClick={(e) => { e.stopPropagation(); handleDelete(problem.id); }}
                            className="h-7 w-7 flex items-center justify-center rounded text-gray-400 hover:bg-red-50 hover:text-red-600"
                            title="삭제"
                          >
                            <Trash2 className="h-3.5 w-3.5" />
                          </button>
                          {isExpanded ? (
                            <ChevronDown className="h-3.5 w-3.5 text-gray-400" />
                          ) : (
                            <ChevronRight className="h-3.5 w-3.5 text-gray-300" />
                          )}
                        </div>
                      </div>

                      {/* 펼침 영역 */}
                      {isExpanded && (
                        <div className="mx-5 mb-3 ml-10 space-y-2">
                          {/* 정답 */}
                          <div className="rounded-lg bg-green-50 border border-green-200 px-3.5 py-2.5">
                            <p className="text-[10px] font-bold text-green-600 mb-1">정답</p>
                            <p className="text-sm text-green-900 font-medium">
                              <LatexRenderer text={problem.correctAnswer} />
                            </p>
                            {problem.type === "multipleChoice" && problem.options.length > 0 && (
                              <div className="mt-1.5 flex flex-wrap gap-1.5">
                                {problem.options.map((opt, i) => (
                                  <span key={i} className={`text-xs px-2 py-0.5 rounded ${
                                    opt === problem.correctAnswer
                                      ? "bg-green-200 text-green-800 font-bold"
                                      : "bg-white text-gray-500 border border-green-200"
                                  }`}>
                                    {i + 1}. <LatexRenderer text={opt} />
                                  </span>
                                ))}
                              </div>
                            )}
                          </div>

                          {/* 힌트 */}
                          {hasHints && (
                            <div className="rounded-lg bg-amber-50 border border-amber-200 px-3.5 py-2.5">
                              <div className="flex items-center gap-1 mb-1.5">
                                <Lightbulb className="h-3 w-3 text-amber-500" />
                                <p className="text-[10px] font-bold text-amber-600">힌트 ({problem.hints.length})</p>
                              </div>
                              <div className="space-y-1">
                                {problem.hints.map((hint, i) => (
                                  <div key={i} className="flex gap-2 text-xs text-amber-900">
                                    <span className="font-bold text-amber-500 flex-shrink-0">{i + 1}.</span>
                                    <span><LatexRenderer text={hint} /></span>
                                  </div>
                                ))}
                              </div>
                            </div>
                          )}

                          {/* 풀이 */}
                          {hasExplanation && (
                            <div className="rounded-lg bg-blue-50 border border-blue-200 px-3.5 py-2.5">
                              <div className="flex items-center gap-1 mb-1.5">
                                <BookOpen className="h-3 w-3 text-blue-500" />
                                <p className="text-[10px] font-bold text-blue-600">풀이</p>
                              </div>
                              <p className="text-xs text-blue-900">
                                <LatexRenderer text={problem.explanation!} />
                              </p>
                            </div>
                          )}
                        </div>
                      )}
                    </div>
                  );
                })}

                {hasMore && (
                  <div className="px-5 py-3 text-center">
                    <button onClick={loadMore} disabled={problemsLoading}
                      className="text-xs text-blue-600 hover:text-blue-700 font-medium disabled:opacity-50">
                      {problemsLoading ? "불러오는 중..." : "더 보기"}
                    </button>
                  </div>
                )}
              </div>
            )}
          </div>
        </div>
      </div>

      <CreateProblemModal
        open={showCreateModal}
        onClose={() => { setShowCreateModal(false); setEditingProblem(null); }}
        onCreated={() => {
          if (selectedLesson) handleSelectLesson(selectedLesson);
          loadCurriculum();
          setEditingProblem(null);
        }}
        editData={editingProblem || undefined}
      />
    </AdminLayout>
  );
}
