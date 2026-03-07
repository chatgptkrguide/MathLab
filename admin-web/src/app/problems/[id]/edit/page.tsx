"use client";

import { useEffect, useState } from "react";
import { useRouter, useParams } from "next/navigation";
import AdminLayout from "@/components/layout/admin-layout";
import ProblemForm from "@/components/problems/problem-form";
import { getProblem, updateProblem } from "@/lib/firestore";
import { Problem } from "@/lib/types";

export default function EditProblemPage() {
  const router = useRouter();
  const params = useParams();
  const id = params.id as string;
  const [problem, setProblem] = useState<Problem | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadProblem();
  }, [id]);

  const loadProblem = async () => {
    try {
      const data = await getProblem(id);
      setProblem(data);
    } catch (error) {
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (data: Omit<Problem, "id" | "createdAt" | "updatedAt">) => {
    try {
      await updateProblem(id, data);
      alert("문제가 수정되었습니다.");
      router.push("/problems");
    } catch (error) {
      console.error(error);
      alert("문제 수정에 실패했습니다.");
    }
  };

  return (
    <AdminLayout>
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900">문제 수정</h1>
        <p className="text-sm text-gray-500 mt-1">문제 ID: {id}</p>
      </div>

      {loading ? (
        <div className="flex items-center justify-center py-20">
          <div className="h-8 w-8 animate-spin rounded-full border-4 border-blue-600 border-t-transparent" />
        </div>
      ) : problem ? (
        <ProblemForm initialData={problem} onSubmit={handleSubmit} submitLabel="수정" />
      ) : (
        <div className="py-20 text-center text-sm text-gray-500">
          문제를 찾을 수 없습니다.
        </div>
      )}
    </AdminLayout>
  );
}
