"use client";

import { useEffect, useState } from "react";
import AdminLayout from "@/components/layout/admin-layout";
import { getDashboardStats } from "@/lib/firestore";
import { PROBLEM_TYPE_LABELS, DIFFICULTY_LABELS, Problem } from "@/lib/types";
import LatexRenderer from "@/components/ui/latex-renderer";
import { FileText, BookOpen, Layers, Clock } from "lucide-react";
import Link from "next/link";

interface Stats {
  totalProblems: number;
  totalUnits: number;
  totalLessons: number;
  byDifficulty: Record<string, number>;
  byType: Record<string, number>;
  byLesson: Record<string, number>;
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
      setStats(data);
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
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4 mb-8">
            <StatCard
              icon={<FileText className="h-5 w-5 text-blue-600" />}
              label="총 문제 수"
              value={stats.totalProblems}
              bg="bg-blue-50"
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
