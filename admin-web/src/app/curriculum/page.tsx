"use client";

import { useEffect, useState } from "react";
import AdminLayout from "@/components/layout/admin-layout";
import {
  getUnits,
  getLessons,
  createUnit,
  updateUnit,
  deleteUnit,
  createLesson,
  updateLesson,
  deleteLesson,
} from "@/lib/firestore";
import { Unit, Lesson, UnitTheme, UNIT_THEME_COLORS } from "@/lib/types";
import {
  Plus,
  Trash2,
  Edit2,
  ChevronDown,
  ChevronRight,
  Save,
  X,
  GripVertical,
} from "lucide-react";

export default function CurriculumPage() {
  const [units, setUnits] = useState<Unit[]>([]);
  const [lessons, setLessons] = useState<Lesson[]>([]);
  const [loading, setLoading] = useState(true);
  const [expandedUnits, setExpandedUnits] = useState<Set<string>>(new Set());

  // Unit form
  const [showUnitForm, setShowUnitForm] = useState(false);
  const [editingUnit, setEditingUnit] = useState<Unit | null>(null);
  const [unitForm, setUnitForm] = useState({
    title: "",
    description: "",
    subject: "공통수학1",
    order: 0,
    emoji: "📐",
    theme: "blue" as UnitTheme,
  });

  // Lesson form
  const [showLessonForm, setShowLessonForm] = useState<string | null>(null);
  const [editingLesson, setEditingLesson] = useState<Lesson | null>(null);
  const [lessonForm, setLessonForm] = useState({
    title: "",
    description: "",
    order: 0,
    xpReward: 10,
    type: "standard",
    difficulty: "beginner",
    concepts: "",
    estimatedMinutes: 5,
  });

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      const [u, l] = await Promise.all([getUnits(), getLessons()]);
      setUnits(u);
      setLessons(l);
    } catch (error) {
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  const toggleUnit = (id: string) => {
    setExpandedUnits((prev) => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });
  };

  // ====== Unit CRUD ======
  const openUnitForm = (unit?: Unit) => {
    if (unit) {
      setEditingUnit(unit);
      setUnitForm({
        title: unit.title,
        description: unit.description,
        subject: unit.subject,
        order: unit.order,
        emoji: unit.emoji,
        theme: unit.theme,
      });
    } else {
      setEditingUnit(null);
      setUnitForm({
        title: "",
        description: "",
        subject: "공통수학1",
        order: units.length + 1,
        emoji: "📐",
        theme: "blue",
      });
    }
    setShowUnitForm(true);
  };

  const saveUnit = async () => {
    if (!unitForm.title.trim()) {
      alert("단원 제목을 입력해주세요.");
      return;
    }
    try {
      if (editingUnit) {
        await updateUnit(editingUnit.id, unitForm);
      } else {
        await createUnit(unitForm);
      }
      setShowUnitForm(false);
      await loadData();
    } catch (error) {
      console.error(error);
      alert("저장에 실패했습니다.");
    }
  };

  const handleDeleteUnit = async (id: string) => {
    const unitLessons = lessons.filter((l) => l.unitId === id);
    if (unitLessons.length > 0) {
      alert("이 단원에 속한 레슨이 있습니다. 레슨을 먼저 삭제해주세요.");
      return;
    }
    if (!confirm("이 단원을 삭제하시겠습니까?")) return;
    try {
      await deleteUnit(id);
      await loadData();
    } catch (error) {
      console.error(error);
      alert("삭제에 실패했습니다.");
    }
  };

  // ====== Lesson CRUD ======
  const openLessonForm = (unitId: string, lesson?: Lesson) => {
    if (lesson) {
      setEditingLesson(lesson);
      setLessonForm({
        title: lesson.title,
        description: lesson.description,
        order: lesson.order,
        xpReward: lesson.xpReward,
        type: lesson.type,
        difficulty: lesson.difficulty,
        concepts: lesson.concepts.join(", "),
        estimatedMinutes: lesson.estimatedMinutes,
      });
    } else {
      setEditingLesson(null);
      const unitLessons = lessons.filter((l) => l.unitId === unitId);
      setLessonForm({
        title: "",
        description: "",
        order: unitLessons.length + 1,
        xpReward: 10,
        type: "standard",
        difficulty: "beginner",
        concepts: "",
        estimatedMinutes: 5,
      });
    }
    setShowLessonForm(unitId);
  };

  const saveLesson = async () => {
    if (!lessonForm.title.trim()) {
      alert("레슨 제목을 입력해주세요.");
      return;
    }
    try {
      const data = {
        unitId: showLessonForm!,
        title: lessonForm.title,
        description: lessonForm.description,
        order: lessonForm.order,
        xpReward: lessonForm.xpReward,
        type: lessonForm.type,
        difficulty: lessonForm.difficulty,
        concepts: lessonForm.concepts
          .split(",")
          .map((c) => c.trim())
          .filter(Boolean),
        estimatedMinutes: lessonForm.estimatedMinutes,
      };

      if (editingLesson) {
        await updateLesson(editingLesson.id, data);
      } else {
        await createLesson(data as Omit<Lesson, "id">);
      }
      setShowLessonForm(null);
      await loadData();
    } catch (error) {
      console.error(error);
      alert("저장에 실패했습니다.");
    }
  };

  const handleDeleteLesson = async (id: string) => {
    if (!confirm("이 레슨을 삭제하시겠습니까?")) return;
    try {
      await deleteLesson(id);
      await loadData();
    } catch (error) {
      console.error(error);
      alert("삭제에 실패했습니다.");
    }
  };

  const subjects = ["공통수학1", "공통수학2", "수학I", "수학II", "미적분", "확률과 통계", "기하"];
  const themeOptions: UnitTheme[] = ["blue", "green", "orange", "purple", "red", "yellow"];
  const emojiOptions = ["📐", "📊", "📈", "🔢", "🧮", "📏", "📝", "🎯", "🔺", "🔵", "⭐", "🧩"];

  return (
    <AdminLayout>
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">커리큘럼 관리</h1>
          <p className="text-sm text-gray-500 mt-1">
            {units.length}개 단원, {lessons.length}개 레슨
          </p>
        </div>
        <button
          onClick={() => openUnitForm()}
          className="flex items-center gap-2 rounded-lg bg-blue-600 px-4 py-2.5 text-sm font-medium text-white hover:bg-blue-700 transition-colors"
        >
          <Plus className="h-4 w-4" />
          단원 추가
        </button>
      </div>

      {loading ? (
        <div className="flex items-center justify-center py-20">
          <div className="h-8 w-8 animate-spin rounded-full border-4 border-blue-600 border-t-transparent" />
        </div>
      ) : units.length === 0 ? (
        <div className="rounded-xl border border-gray-200 bg-white py-20 text-center">
          <p className="text-sm text-gray-500 mb-4">등록된 단원이 없습니다.</p>
          <button
            onClick={() => openUnitForm()}
            className="text-sm text-blue-600 hover:text-blue-700 font-medium"
          >
            첫 단원 추가하기
          </button>
        </div>
      ) : (
        <div className="space-y-3">
          {units.map((unit) => {
            const unitLessons = lessons
              .filter((l) => l.unitId === unit.id)
              .sort((a, b) => a.order - b.order);
            const isExpanded = expandedUnits.has(unit.id);

            return (
              <div
                key={unit.id}
                className="rounded-xl border border-gray-200 bg-white overflow-hidden"
              >
                {/* Unit Header */}
                <div
                  className="flex items-center gap-3 px-5 py-4 cursor-pointer hover:bg-gray-50 transition-colors"
                  onClick={() => toggleUnit(unit.id)}
                >
                  <GripVertical className="h-4 w-4 text-gray-300 flex-shrink-0" />
                  {isExpanded ? (
                    <ChevronDown className="h-4 w-4 text-gray-400" />
                  ) : (
                    <ChevronRight className="h-4 w-4 text-gray-400" />
                  )}
                  <div
                    className="h-3 w-3 rounded-full flex-shrink-0"
                    style={{ backgroundColor: UNIT_THEME_COLORS[unit.theme] }}
                  />
                  <span className="text-lg">{unit.emoji}</span>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2">
                      <span className="text-sm font-semibold text-gray-900">
                        {unit.order}. {unit.title}
                      </span>
                      <span className="text-xs text-gray-400">{unit.subject}</span>
                    </div>
                    <span className="text-xs text-gray-500">
                      {unitLessons.length}개 레슨
                    </span>
                  </div>
                  <div className="flex items-center gap-1" onClick={(e) => e.stopPropagation()}>
                    <button
                      onClick={() => openUnitForm(unit)}
                      className="flex h-8 w-8 items-center justify-center rounded-lg text-gray-400 hover:bg-blue-50 hover:text-blue-600 transition-colors"
                    >
                      <Edit2 className="h-4 w-4" />
                    </button>
                    <button
                      onClick={() => handleDeleteUnit(unit.id)}
                      className="flex h-8 w-8 items-center justify-center rounded-lg text-gray-400 hover:bg-red-50 hover:text-red-600 transition-colors"
                    >
                      <Trash2 className="h-4 w-4" />
                    </button>
                  </div>
                </div>

                {/* Lessons */}
                {isExpanded && (
                  <div className="border-t border-gray-100">
                    {unitLessons.length === 0 ? (
                      <div className="px-14 py-6 text-center text-xs text-gray-400">
                        레슨이 없습니다.
                      </div>
                    ) : (
                      <div className="divide-y divide-gray-50">
                        {unitLessons.map((lesson) => (
                          <div
                            key={lesson.id}
                            className="flex items-center gap-3 px-14 py-3 hover:bg-gray-50 transition-colors"
                          >
                            <GripVertical className="h-3.5 w-3.5 text-gray-300 flex-shrink-0" />
                            <div className="flex-1 min-w-0">
                              <span className="text-sm text-gray-900">
                                {lesson.order}. {lesson.title}
                              </span>
                              <div className="flex gap-2 mt-0.5">
                                <span className="text-xs text-gray-400">
                                  {lesson.xpReward} XP
                                </span>
                                <span className="text-xs text-gray-400">
                                  {lesson.estimatedMinutes}분
                                </span>
                              </div>
                            </div>
                            <div className="flex items-center gap-1">
                              <button
                                onClick={() => openLessonForm(unit.id, lesson)}
                                className="flex h-7 w-7 items-center justify-center rounded text-gray-400 hover:bg-blue-50 hover:text-blue-600 transition-colors"
                              >
                                <Edit2 className="h-3.5 w-3.5" />
                              </button>
                              <button
                                onClick={() => handleDeleteLesson(lesson.id)}
                                className="flex h-7 w-7 items-center justify-center rounded text-gray-400 hover:bg-red-50 hover:text-red-600 transition-colors"
                              >
                                <Trash2 className="h-3.5 w-3.5" />
                              </button>
                            </div>
                          </div>
                        ))}
                      </div>
                    )}

                    {/* Add Lesson Button */}
                    <div className="px-14 py-3 border-t border-gray-50">
                      <button
                        onClick={() => openLessonForm(unit.id)}
                        className="flex items-center gap-1.5 text-xs text-blue-600 hover:text-blue-700 font-medium"
                      >
                        <Plus className="h-3.5 w-3.5" />
                        레슨 추가
                      </button>
                    </div>
                  </div>
                )}
              </div>
            );
          })}
        </div>
      )}

      {/* Unit Form Modal */}
      {showUnitForm && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50">
          <div className="w-full max-w-lg rounded-xl bg-white p-6 mx-4 shadow-xl">
            <div className="flex items-center justify-between mb-6">
              <h3 className="text-lg font-semibold text-gray-900">
                {editingUnit ? "단원 수정" : "단원 추가"}
              </h3>
              <button onClick={() => setShowUnitForm(false)}>
                <X className="h-5 w-5 text-gray-400" />
              </button>
            </div>

            <div className="space-y-4">
              <div>
                <label className="block text-sm text-gray-600 mb-1">제목</label>
                <input
                  value={unitForm.title}
                  onChange={(e) => setUnitForm({ ...unitForm, title: e.target.value })}
                  className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none"
                  placeholder="예: 다항식"
                />
              </div>

              <div>
                <label className="block text-sm text-gray-600 mb-1">설명</label>
                <input
                  value={unitForm.description}
                  onChange={(e) => setUnitForm({ ...unitForm, description: e.target.value })}
                  className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none"
                  placeholder="단원 설명"
                />
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm text-gray-600 mb-1">과목</label>
                  <select
                    value={unitForm.subject}
                    onChange={(e) => setUnitForm({ ...unitForm, subject: e.target.value })}
                    className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm"
                  >
                    {subjects.map((s) => (
                      <option key={s} value={s}>
                        {s}
                      </option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="block text-sm text-gray-600 mb-1">순서</label>
                  <input
                    type="number"
                    value={unitForm.order}
                    onChange={(e) => setUnitForm({ ...unitForm, order: parseInt(e.target.value) || 0 })}
                    className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm"
                    min={1}
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm text-gray-600 mb-1">아이콘</label>
                  <div className="flex flex-wrap gap-2">
                    {emojiOptions.map((e) => (
                      <button
                        key={e}
                        type="button"
                        onClick={() => setUnitForm({ ...unitForm, emoji: e })}
                        className={`h-9 w-9 rounded-lg text-lg flex items-center justify-center transition-colors ${
                          unitForm.emoji === e
                            ? "bg-blue-100 border-2 border-blue-500"
                            : "bg-gray-50 border border-gray-200 hover:bg-gray-100"
                        }`}
                      >
                        {e}
                      </button>
                    ))}
                  </div>
                </div>
                <div>
                  <label className="block text-sm text-gray-600 mb-1">테마 색상</label>
                  <div className="flex flex-wrap gap-2">
                    {themeOptions.map((t) => (
                      <button
                        key={t}
                        type="button"
                        onClick={() => setUnitForm({ ...unitForm, theme: t })}
                        className={`h-9 w-9 rounded-lg flex items-center justify-center transition-all ${
                          unitForm.theme === t ? "ring-2 ring-offset-2 ring-blue-500" : ""
                        }`}
                        style={{ backgroundColor: UNIT_THEME_COLORS[t] }}
                      />
                    ))}
                  </div>
                </div>
              </div>
            </div>

            <div className="flex justify-end gap-3 mt-6">
              <button
                onClick={() => setShowUnitForm(false)}
                className="rounded-lg border border-gray-300 px-4 py-2 text-sm text-gray-700 hover:bg-gray-50 transition-colors"
              >
                취소
              </button>
              <button
                onClick={saveUnit}
                className="flex items-center gap-2 rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white hover:bg-blue-700 transition-colors"
              >
                <Save className="h-4 w-4" />
                저장
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Lesson Form Modal */}
      {showLessonForm && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50">
          <div className="w-full max-w-lg rounded-xl bg-white p-6 mx-4 shadow-xl">
            <div className="flex items-center justify-between mb-6">
              <h3 className="text-lg font-semibold text-gray-900">
                {editingLesson ? "레슨 수정" : "레슨 추가"}
              </h3>
              <button onClick={() => setShowLessonForm(null)}>
                <X className="h-5 w-5 text-gray-400" />
              </button>
            </div>

            <div className="space-y-4">
              <div>
                <label className="block text-sm text-gray-600 mb-1">제목</label>
                <input
                  value={lessonForm.title}
                  onChange={(e) => setLessonForm({ ...lessonForm, title: e.target.value })}
                  className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none"
                  placeholder="예: 다항식의 덧셈과 뺄셈"
                />
              </div>

              <div>
                <label className="block text-sm text-gray-600 mb-1">설명</label>
                <input
                  value={lessonForm.description}
                  onChange={(e) => setLessonForm({ ...lessonForm, description: e.target.value })}
                  className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none"
                  placeholder="레슨 설명"
                />
              </div>

              <div className="grid grid-cols-3 gap-4">
                <div>
                  <label className="block text-sm text-gray-600 mb-1">순서</label>
                  <input
                    type="number"
                    value={lessonForm.order}
                    onChange={(e) => setLessonForm({ ...lessonForm, order: parseInt(e.target.value) || 0 })}
                    className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm"
                    min={1}
                  />
                </div>
                <div>
                  <label className="block text-sm text-gray-600 mb-1">XP 보상</label>
                  <input
                    type="number"
                    value={lessonForm.xpReward}
                    onChange={(e) => setLessonForm({ ...lessonForm, xpReward: parseInt(e.target.value) || 0 })}
                    className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm"
                    min={1}
                  />
                </div>
                <div>
                  <label className="block text-sm text-gray-600 mb-1">예상 시간(분)</label>
                  <input
                    type="number"
                    value={lessonForm.estimatedMinutes}
                    onChange={(e) => setLessonForm({ ...lessonForm, estimatedMinutes: parseInt(e.target.value) || 0 })}
                    className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm"
                    min={1}
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm text-gray-600 mb-1">유형</label>
                  <select
                    value={lessonForm.type}
                    onChange={(e) => setLessonForm({ ...lessonForm, type: e.target.value })}
                    className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm"
                  >
                    <option value="standard">일반</option>
                    <option value="story">스토리</option>
                    <option value="practice">연습</option>
                    <option value="review">복습</option>
                    <option value="challenge">챌린지</option>
                    <option value="boss">보스</option>
                  </select>
                </div>
                <div>
                  <label className="block text-sm text-gray-600 mb-1">난이도</label>
                  <select
                    value={lessonForm.difficulty}
                    onChange={(e) => setLessonForm({ ...lessonForm, difficulty: e.target.value })}
                    className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm"
                  >
                    <option value="beginner">초급</option>
                    <option value="intermediate">중급</option>
                    <option value="advanced">고급</option>
                    <option value="expert">전문가</option>
                  </select>
                </div>
              </div>

              <div>
                <label className="block text-sm text-gray-600 mb-1">개념 (쉼표로 구분)</label>
                <input
                  value={lessonForm.concepts}
                  onChange={(e) => setLessonForm({ ...lessonForm, concepts: e.target.value })}
                  className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none"
                  placeholder="예: 다항식, 덧셈, 뺄셈"
                />
              </div>
            </div>

            <div className="flex justify-end gap-3 mt-6">
              <button
                onClick={() => setShowLessonForm(null)}
                className="rounded-lg border border-gray-300 px-4 py-2 text-sm text-gray-700 hover:bg-gray-50 transition-colors"
              >
                취소
              </button>
              <button
                onClick={saveLesson}
                className="flex items-center gap-2 rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white hover:bg-blue-700 transition-colors"
              >
                <Save className="h-4 w-4" />
                저장
              </button>
            </div>
          </div>
        </div>
      )}
    </AdminLayout>
  );
}
