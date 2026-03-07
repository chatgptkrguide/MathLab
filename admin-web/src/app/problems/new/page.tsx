"use client";

import { useRouter } from "next/navigation";
import AdminLayout from "@/components/layout/admin-layout";
import ProblemForm from "@/components/problems/problem-form";
import { createProblem } from "@/lib/firestore";
import { Problem } from "@/lib/types";

export default function NewProblemPage() {
  const router = useRouter();

  const handleSubmit = async (data: Omit<Problem, "id" | "createdAt" | "updatedAt">) => {
    try {
      await createProblem(data);
      alert("문제가 등록되었습니다.");
      router.push("/problems");
    } catch (error) {
      console.error(error);
      alert("문제 등록에 실패했습니다.");
    }
  };

  return (
    <AdminLayout>
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900">문제 등록</h1>
        <p className="text-sm text-gray-500 mt-1">새로운 수학 문제를 등록합니다</p>
      </div>
      <ProblemForm onSubmit={handleSubmit} submitLabel="등록" />
    </AdminLayout>
  );
}
