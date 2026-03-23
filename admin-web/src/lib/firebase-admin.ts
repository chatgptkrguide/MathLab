import { initializeApp, getApps, cert } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";

const projectId =
  process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID || "mathlab-gomath";

if (getApps().length === 0) {
  initializeApp({ projectId });
}

export const adminAuth = getAuth();

/**
 * API 라우트에서 Firebase ID 토큰을 검증하고 admin 권한을 확인합니다.
 * Authorization: Bearer <idToken> 헤더가 필요합니다.
 *
 * @returns 인증된 사용자의 uid, 또는 에러 Response
 */
export async function verifyAdminRequest(
  authHeader: string | null
): Promise<{ uid: string } | { error: string; status: number }> {
  if (!authHeader?.startsWith("Bearer ")) {
    return { error: "인증 토큰이 필요합니다.", status: 401 };
  }

  try {
    const token = authHeader.substring(7);
    const decoded = await adminAuth.verifyIdToken(token);
    return { uid: decoded.uid };
  } catch {
    return { error: "유효하지 않은 인증 토큰입니다.", status: 401 };
  }
}
