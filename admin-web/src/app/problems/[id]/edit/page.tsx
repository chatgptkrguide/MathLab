"use client";

import { useEffect, useState } from "react";
import { useRouter, useParams } from "next/navigation";
import AdminLayout from "@/components/layout/admin-layout";
import ProblemForm from "@/components/problems/problem-form";
import { getProblem, updateProblem } from "@/lib/firestore";
import { Problem } from "@/lib/types";
import { AlertCircle, CheckCircle } from "lucide-react";

export default function EditProblemPage() {
  const router = useRouter();
  const params = useParams();
  const id = params.id as string;
  const [problem, setProblem] = useState<Problem | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");

  useEffect(() => {
    loadProblem();
  }, [id]);

  const loadProblem = async () => {
    try {
      const data = await getProblem(id);
      setProblem(data);
    } catch (error) {
      console.error("Failed to load problem:", error);
      setError("문제를 불러오지 못했습니다. 다시 시도해주세요.");
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (data: Omit<Problem, "id" | "createdAt" | "updatedAt">) => {
    setError("");
    setSuccess("");
    try {
      await updateProblem(id, data);
      setSuccess("문제가 수정되었습니다. 목록으로 이동합니다.");
      setTimeout(() => router.push("/problems"), 1500);
    } catch (error) {
      console.error("Failed to update problem:", error);
      setError("문제 수정에 실패했습니다. 다시 시도해주세요.");
    }
  };

  return (
    <AdminLayout>
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900">문제 수정</h1>
        <p className="text-sm text-gray-500 mt-1">문제 ID: {id}</p>
      </div>

      {error && (
        <div className="mb-6 flex items-start gap-2 rounded-lg bg-red-50 border border-red-200 px-4 py-3">
          <AlertCircle className="h-4 w-4 text-red-500 mt-0.5 flex-shrink-0" />
          <span className="text-sm text-red-700">{error}</span>
          <button onClick={() => setError("")} className="ml-auto text-red-400 hover:text-red-600 text-sm">&times;</button>
        </div>
      )}

      {success && (
        <div className="mb-6 flex items-start gap-2 rounded-lg bg-green-50 border border-green-200 px-4 py-3">
          <CheckCircle className="h-4 w-4 text-green-500 mt-0.5 flex-shrink-0" />
          <span className="text-sm text-green-700">{success}</span>
        </div>
      )}

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
