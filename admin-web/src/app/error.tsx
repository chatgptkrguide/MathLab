"use client";

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  return (
    <div className="flex min-h-screen flex-col items-center justify-center bg-gray-50">
      <h1 className="text-4xl font-bold text-red-500">오류 발생</h1>
      <p className="mt-4 text-gray-600">문제가 발생했습니다. 다시 시도해주세요.</p>
      <button
        onClick={reset}
        className="mt-6 rounded-lg bg-blue-600 px-6 py-3 text-white hover:bg-blue-700"
      >
        다시 시도
      </button>
    </div>
  );
}
