"use client";

import { useEffect, useState } from "react";
import AdminLayout from "@/components/layout/admin-layout";
import { getDashboardStats } from "@/lib/firestore";
import { PROBLEM_TYPE_LABELS, DIFFICULTY_LABELS, Problem } from "@/lib/types";
import LatexRenderer from "@/components/ui/latex-renderer";
import {
  FileText,
  BookOpen,
  Layers,
  Clock,
  Users,
  CalendarPlus,
  PlusCircle,
  FolderPlus,
  Upload,
} from "lucide-react";
import Link from "next/link";

interface Stats {
  totalProblems: number;
  totalUnits: number;
  totalLessons: number;
  userCount: number;
  todayCount: number;
  byDifficulty: Record<string, number>;
  byType: Record<string, number>;
  byLesson: Record<string, number>;
  weeklyData: { date: string; count: number }[];
  lessonCoverage: { lessonId: string; lessonTitle: string; count: number }[];
  recentProblems: Problem[];
}

export default function DashboardPage() {
  const [stats, setStats] = useState<Stats | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadStats();
  }, []);

  const loadStats = async () => {
    try {
      const data = await getDashboardStats();
      setStats(data as Stats);
    } catch (error) {
      console.error("Failed to load stats:", error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <AdminLayout>
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900">대시보드</h1>
        <p className="text-sm text-gray-500 mt-1">MathLab 문제 관리 현황</p>
      </div>

      {loading ? (
        <div className="flex items-center justify-center py-20">
          <div className="h-8 w-8 animate-spin rounded-full border-4 border-blue-600 border-t-transparent" />
        </div>
      ) : stats ? (
        <>
          {/* Summary Cards */}
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-6 mb-8">
            <StatCard
              icon={<FileText className="h-5 w-5 text-blue-600" />}
              label="총 문제 수"
              value={stats.totalProblems}
              bg="bg-blue-50"
            />
            <StatCard
              icon={<CalendarPlus className="h-5 w-5 text-cyan-600" />}
              label="오늘 등록"
              value={stats.todayCount}
              bg="bg-cyan-50"
            />
            <StatCard
              icon={<Users className="h-5 w-5 text-pink-600" />}
              label="사용자 수"
              value={stats.userCount}
              bg="bg-pink-50"
            />
            <StatCard
              icon={<Layers className="h-5 w-5 text-green-600" />}
              label="단원 수"
              value={stats.totalUnits}
              bg="bg-green-50"
            />
            <StatCard
              icon={<BookOpen className="h-5 w-5 text-purple-600" />}
              label="레슨 수"
              value={stats.totalLessons}
              bg="bg-purple-50"
            />
            <StatCard
              icon={<Clock className="h-5 w-5 text-orange-600" />}
              label="레슨당 평균 문제"
              value={
                stats.totalLessons > 0
                  ? Math.round(stats.totalProblems / stats.totalLessons)
                  : 0
              }
              bg="bg-orange-50"
            />
          </div>

          {/* Quick Actions */}
          <div className="rounded-xl border border-gray-200 bg-white p-6 mb-8">
            <h3 className="text-sm font-semibold text-gray-900 mb-4">빠른 작업</h3>
            <div className="flex flex-wrap gap-3">
              <Link
                href="/problems"
                className="inline-flex items-center gap-2 rounded-lg border border-blue-200 bg-blue-50 px-4 py-2.5 text-sm font-medium text-blue-700 hover:bg-blue-100 transition-colors"
              >
                <PlusCircle className="h-4 w-4" />
                문제 등록
              </Link>
              <Link
                href="/curriculum"
                className="inline-flex items-center gap-2 rounded-lg border border-green-200 bg-green-50 px-4 py-2.5 text-sm font-medium text-green-700 hover:bg-green-100 transition-colors"
              >
                <FolderPlus className="h-4 w-4" />
                단원 추가
              </Link>
              <Link
                href="/problems/bulk"
                className="inline-flex items-center gap-2 rounded-lg border border-purple-200 bg-purple-50 px-4 py-2.5 text-sm font-medium text-purple-700 hover:bg-purple-100 transition-colors"
              >
                <Upload className="h-4 w-4" />
                엑셀 등록
              </Link>
            </div>
          </div>

          {/* Weekly Activity Chart */}
          <div className="rounded-xl border border-gray-200 bg-white p-6 mb-8">
            <h3 className="text-sm font-semibold text-gray-900 mb-4">주간 문제 등록 현황</h3>
            <div className="flex items-end gap-2 h-40">
              {stats.weeklyData.map((day) => {
                const maxCount = Math.max(...stats.weeklyData.map((d) => d.count), 1);
                const heightPct = (day.count / maxCount) * 100;
                const dateObj = new Date(day.date + "T00:00:00");
                const dayLabel = dateObj.toLocaleDateString("ko-KR", { weekday: "short" });
                const dateLabel = `${dateObj.getMonth() + 1}/${dateObj.getDate()}`;
                return (
                  <div key={day.date} className="flex-1 flex flex-col items-center gap-1">
                    <span className="text-xs font-medium text-gray-700">{day.count}</span>
                    <div className="w-full flex items-end" style={{ height: "100px" }}>
                      <div
                        className="w-full rounded-t-md bg-blue-500 transition-all"
                        style={{
                          height: `${Math.max(heightPct, 2)}%`,
                          minHeight: "2px",
                        }}
                      />
                    </div>
                    <span className="text-xs text-gray-500">{dateLabel}</span>
                    <span className="text-xs text-gray-400">{dayLabel}</span>
                  </div>
                );
              })}
            </div>
          </div>

          {/* Charts Row */}
          <div className="grid grid-cols-1 gap-6 lg:grid-cols-2 mb-8">
            {/* By Difficulty */}
            <div className="rounded-xl border border-gray-200 bg-white p-6">
              <h3 className="text-sm font-semibold text-gray-900 mb-4">난이도별 분포</h3>
              <div className="space-y-3">
                {Object.entries(DIFFICULTY_LABELS).map(([key, label]) => {
                  const count = stats.byDifficulty[key] || 0;
                  const pct = stats.totalProblems > 0 ? (count / stats.totalProblems) * 100 : 0;
                  return (
                    <div key={key}>
                      <div className="flex justify-between text-sm mb-1">
                        <span className="text-gray-600">{label}</span>
                        <span className="font-medium text-gray-900">{count}문제</span>
                      </div>
                      <div className="h-2 w-full rounded-full bg-gray-100">
                        <div
                          className="h-2 rounded-full bg-blue-500 transition-all"
                          style={{ width: `${pct}%` }}
                        />
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>

            {/* By Type */}
            <div className="rounded-xl border border-gray-200 bg-white p-6">
              <h3 className="text-sm font-semibold text-gray-900 mb-4">유형별 분포</h3>
              <div className="space-y-3">
                {Object.entries(PROBLEM_TYPE_LABELS).map(([key, label]) => {
                  const count = stats.byType[key] || 0;
                  const pct = stats.totalProblems > 0 ? (count / stats.totalProblems) * 100 : 0;
                  return (
                    <div key={key}>
                      <div className="flex justify-between text-sm mb-1">
                        <span className="text-gray-600">{label}</span>
                        <span className="font-medium text-gray-900">{count}문제</span>
                      </div>
                      <div className="h-2 w-full rounded-full bg-gray-100">
                        <div
                          className="h-2 rounded-full bg-purple-500 transition-all"
                          style={{ width: `${pct}%` }}
                        />
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          </div>

          {/* Lesson Coverage */}
          <div className="grid grid-cols-1 gap-6 lg:grid-cols-2 mb-8">
            {/* Top 5 Lessons */}
            <div className="rounded-xl border border-gray-200 bg-white p-6">
              <h3 className="text-sm font-semibold text-gray-900 mb-4">문제가 많은 레슨 (Top 5)</h3>
              {stats.lessonCoverage.length === 0 ? (
                <p className="text-sm text-gray-500">레슨 데이터가 없습니다.</p>
              ) : (
                <div className="space-y-3">
                  {stats.lessonCoverage.slice(0, 5).map((lesson, idx) => {
                    const maxCount = stats.lessonCoverage[0]?.count || 1;
                    const pct = (lesson.count / maxCount) * 100;
                    return (
                      <div key={lesson.lessonId}>
                        <div className="flex justify-between text-sm mb-1">
                          <span className="text-gray-600 truncate mr-2">
                            <span className="text-gray-400 mr-1">{idx + 1}.</span>
                            {lesson.lessonTitle}
                          </span>
                          <span className="font-medium text-gray-900 whitespace-nowrap">{lesson.count}문제</span>
                        </div>
                        <div className="h-2 w-full rounded-full bg-gray-100">
                          <div
                            className="h-2 rounded-full bg-green-500 transition-all"
                            style={{ width: `${pct}%` }}
                          />
                        </div>
                      </div>
                    );
                  })}
                </div>
              )}
            </div>

            {/* Bottom 5 Lessons */}
            <div className="rounded-xl border border-gray-200 bg-white p-6">
              <h3 className="text-sm font-semibold text-gray-900 mb-4">문제가 적은 레슨 (Bottom 5)</h3>
              {stats.lessonCoverage.length === 0 ? (
                <p className="text-sm text-gray-500">레슨 데이터가 없습니다.</p>
              ) : (
                <div className="space-y-3">
                  {stats.lessonCoverage
                    .slice(-5)
                    .reverse()
                    .map((lesson, idx) => {
                      const maxInBottom = stats.lessonCoverage.slice(-5)[0]?.count || 1;
                      const pct = maxInBottom > 0 ? (lesson.count / maxInBottom) * 100 : 0;
                      return (
                        <div key={lesson.lessonId}>
                          <div className="flex justify-between text-sm mb-1">
                            <span className="text-gray-600 truncate mr-2">
                              <span className="text-gray-400 mr-1">{idx + 1}.</span>
                              {lesson.lessonTitle}
                            </span>
                            <span className="font-medium text-gray-900 whitespace-nowrap">
                              {lesson.count}문제
                              {lesson.count === 0 && (
                                <span className="ml-1 text-xs text-red-500">!</span>
                              )}
                            </span>
                          </div>
                          <div className="h-2 w-full rounded-full bg-gray-100">
                            <div
                              className="h-2 rounded-full bg-amber-500 transition-all"
                              style={{ width: `${Math.max(pct, 2)}%` }}
                            />
                          </div>
                        </div>
                      );
                    })}
                </div>
              )}
            </div>
          </div>

          {/* Recent Problems */}
          <div className="rounded-xl border border-gray-200 bg-white">
            <div className="flex items-center justify-between border-b border-gray-200 px-6 py-4">
              <h3 className="text-sm font-semibold text-gray-900">최근 등록된 문제</h3>
              <Link
                href="/problems"
                className="text-sm text-blue-600 hover:text-blue-700"
              >
                전체 보기
              </Link>
            </div>
            <div className="divide-y divide-gray-100">
              {stats.recentProblems.length === 0 ? (
                <div className="px-6 py-8 text-center text-sm text-gray-500">
                  등록된 문제가 없습니다.
                </div>
              ) : (
                stats.recentProblems.map((problem) => (
                  <div
                    key={problem.id}
                    className="flex items-center justify-between px-6 py-3"
                  >
                    <div className="flex-1 min-w-0">
                      <div className="text-sm text-gray-900 truncate">
                        <LatexRenderer text={problem.question} />
                      </div>
                      <div className="flex gap-2 mt-1">
                        <span className="inline-flex items-center rounded-full bg-gray-100 px-2 py-0.5 text-xs text-gray-600">
                          {PROBLEM_TYPE_LABELS[problem.type] || problem.type}
                        </span>
                        <span className="inline-flex items-center rounded-full bg-gray-100 px-2 py-0.5 text-xs text-gray-600">
                          {DIFFICULTY_LABELS[problem.difficulty] || problem.difficulty}
                        </span>
                      </div>
                    </div>
                    <Link
                      href={`/problems/${problem.id}/edit`}
                      className="ml-4 text-xs text-blue-600 hover:text-blue-700 whitespace-nowrap"
                    >
                      수정
                    </Link>
                  </div>
                ))
              )}
            </div>
          </div>
        </>
      ) : (
        <div className="text-center py-20 text-gray-500">
          데이터를 불러올 수 없습니다.
        </div>
      )}
    </AdminLayout>
  );
}

function StatCard({
  icon,
  label,
  value,
  bg,
}: {
  icon: React.ReactNode;
  label: string;
  value: number;
  bg: string;
}) {
  return (
    <div className="rounded-xl border border-gray-200 bg-white p-5">
      <div className="flex items-center gap-3">
        <div className={`flex h-10 w-10 items-center justify-center rounded-lg ${bg}`}>
          {icon}
        </div>
        <div>
          <p className="text-sm text-gray-500">{label}</p>
          <p className="text-2xl font-bold text-gray-900">{value}</p>
        </div>
      </div>
    </div>
  );
}
