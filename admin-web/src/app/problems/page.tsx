"use client";

import { useEffect, useState, useCallback } from "react";
import AdminLayout from "@/components/layout/admin-layout";
import { getProblems, deleteProblem, getUnits, getLessons, ProblemFilters } from "@/lib/firestore";
import { Problem, Unit, Lesson, ProblemType, ProblemDifficulty, PROBLEM_TYPE_LABELS, DIFFICULTY_LABELS } from "@/lib/types";
import LatexRenderer from "@/components/ui/latex-renderer";
import CreateProblemModal from "@/components/problems/create-problem-modal";
import Link from "next/link";
import { DocumentSnapshot } from "firebase/firestore";
import ProblemPreviewModal from "@/components/problems/problem-preview-modal";
import { Search, Trash2, Edit2, Plus, Filter, FileSpreadsheet, Eye } from "lucide-react";

export default function ProblemsPage() {
  const [problems, setProblems] = useState<Problem[]>([]);
  const [units, setUnits] = useState<Unit[]>([]);
  const [lessons, setLessons] = useState<Lesson[]>([]);
  const [loading, setLoading] = useState(true);
  const [lastDoc, setLastDoc] = useState<DocumentSnapshot | null>(null);
  const [total, setTotal] = useState(0);
  const [hasMore, setHasMore] = useState(false);
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [editingProblem, setEditingProblem] = useState<Problem | null>(null);
  const [previewProblem, setPreviewProblem] = useState<Problem | null>(null);

  // Filters
  const [selectedUnitId, setSelectedUnitId] = useState("");
  const [selectedLessonId, setSelectedLessonId] = useState("");
  const [selectedDifficulty, setSelectedDifficulty] = useState<ProblemDifficulty | "">("");
  const [selectedType, setSelectedType] = useState<ProblemType | "">("");
  const [searchText, setSearchText] = useState("");
  const [showFilters, setShowFilters] = useState(false);

  useEffect(() => {
    loadCurriculum();
    loadProblems();
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

  const buildFilters = useCallback((): ProblemFilters => {
    const filters: ProblemFilters = {};
    if (selectedLessonId) filters.lessonId = selectedLessonId;
    if (selectedDifficulty) filters.difficulty = selectedDifficulty as ProblemDifficulty;
    if (selectedType) filters.type = selectedType as ProblemType;
    if (searchText) filters.searchText = searchText;
    return filters;
  }, [selectedLessonId, selectedDifficulty, selectedType, searchText]);

  const loadProblems = async (append = false) => {
    setLoading(true);
    try {
      const filters = buildFilters();
      const result = await getProblems(filters, 20, append ? lastDoc || undefined : undefined);
      setProblems(append ? [...problems, ...result.problems] : result.problems);
      setLastDoc(result.lastDoc);
      setTotal(result.total);
      setHasMore(result.problems.length === 20);
    } catch (error) {
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  const applyFilters = () => {
    setLastDoc(null);
    loadProblems(false);
  };

  const handleDelete = async (id: string) => {
    if (!confirm("이 문제를 삭제하시겠습니까?")) return;
    try {
      await deleteProblem(id);
      setProblems(problems.filter((p) => p.id !== id));
      setTotal((prev) => prev - 1);
    } catch (error) {
      console.error(error);
      alert("삭제에 실패했습니다.");
    }
  };

  const filteredLessons = selectedUnitId
    ? lessons.filter((l) => l.unitId === selectedUnitId)
    : lessons;

  const getLessonTitle = (lessonId: string) => {
    const lesson = lessons.find((l) => l.id === lessonId);
    return lesson?.title || lessonId;
  };

  return (
    <AdminLayout>
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">문제 관리</h1>
          <p className="text-sm text-gray-500 mt-1">총 {total}개의 문제</p>
        </div>
        <div className="flex items-center gap-2">
          <Link
            href="/problems/bulk"
            className="flex items-center gap-2 rounded-lg border border-gray-300 px-4 py-2.5 text-sm font-medium text-gray-700 hover:bg-gray-50 transition-colors"
          >
            <FileSpreadsheet className="h-4 w-4" />
            엑셀 등록
          </Link>
          <button
            onClick={() => setShowCreateModal(true)}
            className="flex items-center gap-2 rounded-lg bg-blue-600 px-4 py-2.5 text-sm font-medium text-white hover:bg-blue-700 transition-colors"
          >
            <Plus className="h-4 w-4" />
            문제 등록
          </button>
        </div>
      </div>

      {/* Search & Filters */}
      <div className="rounded-xl border border-gray-200 bg-white mb-6">
        <div className="flex items-center gap-3 px-4 py-3 border-b border-gray-100">
          <Search className="h-4 w-4 text-gray-400" />
          <input
            value={searchText}
            onChange={(e) => setSearchText(e.target.value)}
            onKeyDown={(e) => e.key === "Enter" && applyFilters()}
            placeholder="문제 검색..."
            className="flex-1 text-sm border-none outline-none"
          />
          <button
            onClick={() => setShowFilters(!showFilters)}
            className={`flex items-center gap-1 rounded-lg px-3 py-1.5 text-xs font-medium transition-colors ${
              showFilters ? "bg-blue-50 text-blue-700" : "text-gray-500 hover:bg-gray-50"
            }`}
          >
            <Filter className="h-3.5 w-3.5" />
            필터
          </button>
          <button
            onClick={applyFilters}
            className="rounded-lg bg-blue-600 px-4 py-1.5 text-xs font-medium text-white hover:bg-blue-700 transition-colors"
          >
            검색
          </button>
        </div>

        {showFilters && (
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-3 px-4 py-3">
            <select
              value={selectedUnitId}
              onChange={(e) => {
                setSelectedUnitId(e.target.value);
                setSelectedLessonId("");
              }}
              className="rounded-lg border border-gray-300 px-3 py-2 text-sm"
            >
              <option value="">모든 단원</option>
              {units.map((u) => (
                <option key={u.id} value={u.id}>
                  {u.emoji} {u.title}
                </option>
              ))}
            </select>

            <select
              value={selectedLessonId}
              onChange={(e) => setSelectedLessonId(e.target.value)}
              className="rounded-lg border border-gray-300 px-3 py-2 text-sm"
            >
              <option value="">모든 레슨</option>
              {filteredLessons.map((l) => (
                <option key={l.id} value={l.id}>
                  {l.title}
                </option>
              ))}
            </select>

            <select
              value={selectedDifficulty}
              onChange={(e) => setSelectedDifficulty(e.target.value as ProblemDifficulty | "")}
              className="rounded-lg border border-gray-300 px-3 py-2 text-sm"
            >
              <option value="">모든 난이도</option>
              {Object.entries(DIFFICULTY_LABELS).map(([k, v]) => (
                <option key={k} value={k}>
                  {v}
                </option>
              ))}
            </select>

            <select
              value={selectedType}
              onChange={(e) => setSelectedType(e.target.value as ProblemType | "")}
              className="rounded-lg border border-gray-300 px-3 py-2 text-sm"
            >
              <option value="">모든 유형</option>
              {Object.entries(PROBLEM_TYPE_LABELS).map(([k, v]) => (
                <option key={k} value={k}>
                  {v}
                </option>
              ))}
            </select>
          </div>
        )}
      </div>

      {/* Problem List */}
      <div className="rounded-xl border border-gray-200 bg-white">
        {loading && problems.length === 0 ? (
          <div className="flex items-center justify-center py-20">
            <div className="h-8 w-8 animate-spin rounded-full border-4 border-blue-600 border-t-transparent" />
          </div>
        ) : problems.length === 0 ? (
          <div className="py-20 text-center">
            <p className="text-sm text-gray-500 mb-3">등록된 문제가 없습니다.</p>
            <button
              onClick={() => setShowCreateModal(true)}
              className="text-sm text-blue-600 hover:text-blue-700 font-medium"
            >
              첫 문제 등록하기
            </button>
          </div>
        ) : (
          <div className="divide-y divide-gray-100">
            {problems.map((problem) => (
              <div
                key={problem.id}
                className="flex items-start gap-4 px-6 py-4 hover:bg-gray-50 transition-colors"
              >
                <div className="flex-1 min-w-0">
                  <div className="text-sm text-gray-900 mb-2">
                    <LatexRenderer text={problem.question} />
                  </div>
                  <div className="flex flex-wrap gap-2">
                    <span className="inline-flex items-center rounded-full bg-blue-50 px-2 py-0.5 text-xs text-blue-700">
                      {PROBLEM_TYPE_LABELS[problem.type] || problem.type}
                    </span>
                    <span className="inline-flex items-center rounded-full bg-orange-50 px-2 py-0.5 text-xs text-orange-700">
                      {DIFFICULTY_LABELS[problem.difficulty] || problem.difficulty}
                    </span>
                    <span className="inline-flex items-center rounded-full bg-gray-100 px-2 py-0.5 text-xs text-gray-600">
                      {getLessonTitle(problem.lessonId)}
                    </span>
                    <span className="inline-flex items-center rounded-full bg-gray-100 px-2 py-0.5 text-xs text-gray-600">
                      {problem.points}점
                    </span>
                  </div>
                </div>
                <div className="flex items-center gap-1">
                  <button
                    onClick={() => setPreviewProblem(problem)}
                    className="flex h-8 w-8 items-center justify-center rounded-lg text-gray-400 hover:bg-purple-50 hover:text-purple-600 transition-colors"
                    title="미리보기"
                  >
                    <Eye className="h-4 w-4" />
                  </button>
                  <button
                    onClick={() => { setEditingProblem(problem); setShowCreateModal(true); }}
                    className="flex h-8 w-8 items-center justify-center rounded-lg text-gray-400 hover:bg-blue-50 hover:text-blue-600 transition-colors"
                    title="수정"
                  >
                    <Edit2 className="h-4 w-4" />
                  </button>
                  <button
                    onClick={() => handleDelete(problem.id)}
                    className="flex h-8 w-8 items-center justify-center rounded-lg text-gray-400 hover:bg-red-50 hover:text-red-600 transition-colors"
                    title="삭제"
                  >
                    <Trash2 className="h-4 w-4" />
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}

        {/* Load More */}
        {hasMore && (
          <div className="border-t border-gray-100 px-6 py-4 text-center">
            <button
              onClick={() => loadProblems(true)}
              disabled={loading}
              className="text-sm text-blue-600 hover:text-blue-700 font-medium disabled:opacity-50"
            >
              {loading ? "불러오는 중..." : "더 보기"}
            </button>
          </div>
        )}
      </div>

      {/* Create/Edit Problem Modal */}
      <CreateProblemModal
        open={showCreateModal}
        onClose={() => { setShowCreateModal(false); setEditingProblem(null); }}
        onCreated={() => {
          loadProblems(false);
          setEditingProblem(null);
        }}
        editData={editingProblem || undefined}
      />

      {/* Problem Preview Modal */}
      <ProblemPreviewModal
        problem={previewProblem}
        onClose={() => setPreviewProblem(null)}
      />
    </AdminLayout>
  );
}
