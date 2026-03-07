"use client";

import { useState, useEffect, useCallback } from "react";
import AdminLayout from "@/components/layout/admin-layout";
import ProblemForm from "@/components/problems/problem-form";
import { createProblem, getUnits, getLessons, getProblemCountsByLesson } from "@/lib/firestore";
import { Problem, Unit, Lesson } from "@/lib/types";

export default function NewProblemPage() {
  const [units, setUnits] = useState<Unit[]>([]);
  const [lessons, setLessons] = useState<Lesson[]>([]);
  const [problemCounts, setProblemCounts] = useState<Record<string, number>>({});
  const [selectedOverviewUnitId, setSelectedOverviewUnitId] = useState<string | null>(null);

  const loadOverviewData = useCallback(async () => {
    try {
      const [unitsData, lessonsData, counts] = await Promise.all([
        getUnits(),
        getLessons(),
        getProblemCountsByLesson(),
      ]);
      setUnits(unitsData);
      setLessons(lessonsData);
      setProblemCounts(counts);
    } catch (error) {
      console.error("Failed to load overview data:", error);
    }
  }, []);

  useEffect(() => {
    loadOverviewData();
  }, [loadOverviewData]);

  const handleSubmit = async (data: Omit<Problem, "id" | "createdAt" | "updatedAt">) => {
    await createProblem(data);
  };

  const getCountColor = (count: number) => {
    if (count === 0) return "bg-red-100 text-red-700";
    if (count < 5) return "bg-yellow-100 text-yellow-700";
    return "bg-green-100 text-green-700";
  };

  const getCountDot = (count: number) => {
    if (count === 0) return "bg-red-400";
    if (count < 5) return "bg-yellow-400";
    return "bg-green-400";
  };

  const getLessonsForUnit = (unitId: string) => {
    return lessons.filter((l) => l.unitId === unitId);
  };

  const getUnitTotalProblems = (unitId: string) => {
    return getLessonsForUnit(unitId).reduce(
      (sum, l) => sum + (problemCounts[l.id] || 0),
      0
    );
  };

  return (
    <AdminLayout>
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900">문제 등록</h1>
        <p className="text-sm text-gray-500 mt-1">새로운 수학 문제를 등록합니다</p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Main Form */}
        <div className="lg:col-span-2">
          <ProblemForm
            onSubmit={handleSubmit}
            submitLabel="등록"
            quickAddMode={true}
            onProblemCountChange={loadOverviewData}
          />
        </div>

        {/* Sidebar - Unit/Lesson Overview */}
        <div className="space-y-3">
          <h3 className="text-sm font-semibold text-gray-900">단원별 문제 현황</h3>
          <div className="space-y-2 max-h-[calc(100vh-200px)] overflow-y-auto pr-1">
            {units.map((unit) => {
              const unitLessons = getLessonsForUnit(unit.id);
              const totalProblems = getUnitTotalProblems(unit.id);
              const isExpanded = selectedOverviewUnitId === unit.id;

              return (
                <div key={unit.id} className="rounded-lg border border-gray-200 bg-white overflow-hidden">
                  <button
                    type="button"
                    onClick={() =>
                      setSelectedOverviewUnitId(isExpanded ? null : unit.id)
                    }
                    className="flex w-full items-center justify-between px-3 py-2.5 text-left hover:bg-gray-50 transition-colors"
                  >
                    <div className="flex items-center gap-2 min-w-0">
                      <span className="text-sm">{unit.emoji}</span>
                      <span className="text-sm font-medium text-gray-800 truncate">
                        {unit.title}
                      </span>
                    </div>
                    <div className="flex items-center gap-2 flex-shrink-0">
                      <span className="text-xs text-gray-400">
                        {unitLessons.length}레슨
                      </span>
                      <span className={`inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium ${getCountColor(totalProblems)}`}>
                        {totalProblems}문제
                      </span>
                    </div>
                  </button>

                  {isExpanded && unitLessons.length > 0 && (
                    <div className="border-t border-gray-100 px-3 py-2 space-y-1 bg-gray-50/50">
                      {unitLessons.map((lesson) => {
                        const count = problemCounts[lesson.id] || 0;
                        return (
                          <div
                            key={lesson.id}
                            className="flex items-center justify-between py-1"
                          >
                            <div className="flex items-center gap-2 min-w-0">
                              <span className={`h-2 w-2 rounded-full flex-shrink-0 ${getCountDot(count)}`} />
                              <span className="text-xs text-gray-600 truncate">
                                {lesson.order}. {lesson.title}
                              </span>
                            </div>
                            <span className={`text-xs font-medium flex-shrink-0 ${
                              count === 0 ? "text-red-500" : count < 5 ? "text-yellow-600" : "text-green-600"
                            }`}>
                              {count}문제
                            </span>
                          </div>
                        );
                      })}
                    </div>
                  )}
                </div>
              );
            })}

            {units.length === 0 && (
              <div className="rounded-lg border border-gray-200 bg-white px-4 py-8 text-center">
                <p className="text-sm text-gray-400">단원 데이터를 불러오는 중...</p>
              </div>
            )}
          </div>

          {/* Legend */}
          <div className="flex items-center gap-4 text-xs text-gray-400 pt-1">
            <div className="flex items-center gap-1">
              <span className="h-2 w-2 rounded-full bg-red-400" />
              0문제
            </div>
            <div className="flex items-center gap-1">
              <span className="h-2 w-2 rounded-full bg-yellow-400" />
              1-4문제
            </div>
            <div className="flex items-center gap-1">
              <span className="h-2 w-2 rounded-full bg-green-400" />
              5+문제
            </div>
          </div>
        </div>
      </div>
    </AdminLayout>
  );
}
