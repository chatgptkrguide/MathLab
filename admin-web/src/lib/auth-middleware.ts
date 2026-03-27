import { NextRequest, NextResponse } from "next/server";

/**
 * API 라우트 공통 인증 미들웨어
 * Firebase ID Token 검증 + admin 권한 확인
 *
 * @returns 인증된 사용자 uid, 또는 에러 NextResponse
 */
export async function requireAdmin(
  req: NextRequest
): Promise<{ uid: string } | NextResponse> {
  const { verifyAdminRequest } = await import("@/lib/firebase-admin");
  const authResult = await verifyAdminRequest(
    req.headers.get("Authorization")
  );

  if ("error" in authResult) {
    return NextResponse.json(
      { error: authResult.error },
      { status: authResult.status }
    );
  }

  return { uid: authResult.uid };
}
