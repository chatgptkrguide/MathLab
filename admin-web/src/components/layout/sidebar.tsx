"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import {
  LayoutDashboard,
  FileText,
  BookOpen,
  GraduationCap,
  Shapes,
  FileUp,
  Sparkles,
} from "lucide-react";

const navItems = [
  { href: "/dashboard", label: "대시보드", icon: LayoutDashboard, exact: true },
  { href: "/problems", label: "문제 관리", icon: FileText, exact: true },
  { href: "/problems/geometry", label: "기하 문제 생성기", icon: Shapes, exact: false },
  { href: "/problems/pdf", label: "PDF 변환", icon: FileUp, exact: false },
  { href: "/problems/ai", label: "AI 도구", icon: Sparkles, exact: false },
  { href: "/curriculum", label: "커리큘럼 관리", icon: BookOpen, exact: false },
];

export default function Sidebar() {
  const pathname = usePathname();

  return (
    <aside className="fixed left-0 top-0 z-40 h-screen w-64 border-r border-gray-200 bg-white">
      <div className="flex h-full flex-col">
        {/* Logo */}
        <div className="flex h-16 items-center gap-2 border-b border-gray-200 px-6">
          <GraduationCap className="h-7 w-7 text-blue-600" />
          <span className="text-lg font-bold text-gray-900">MathLab Admin</span>
        </div>

        {/* Navigation */}
        <nav className="flex-1 space-y-1 px-3 py-4">
          {navItems.map((item) => {
            const isActive = item.exact
              ? pathname === item.href
              : pathname === item.href || pathname.startsWith(item.href + "/");
            const Icon = item.icon;

            return (
              <Link
                key={item.href}
                href={item.href}
                className={`flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium transition-colors ${
                  isActive
                    ? "bg-blue-50 text-blue-700"
                    : "text-gray-600 hover:bg-gray-50 hover:text-gray-900"
                }`}
              >
                <Icon className="h-5 w-5" />
                {item.label}
              </Link>
            );
          })}
        </nav>
      </div>
    </aside>
  );
}
