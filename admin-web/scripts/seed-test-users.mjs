/**
 * Seed script: 테스트용 더미 사용자 8명을 Firestore에 추가
 *
 * 친구 검색 / 리그 / 팀 / 활동 피드 등 멀티 사용자 의존 기능을
 * 본인 계정 하나로 검증할 수 있도록 다양한 레벨·리그·스트릭의 사용자를 시드.
 *
 * 실행:
 *   cd admin-web
 *   node scripts/seed-test-users.mjs           # 시드
 *   node scripts/seed-test-users.mjs cleanup   # 시드한 테스트 사용자 일괄 삭제
 *
 * 시드된 사용자는 모두 isTestUser: true 필드를 가짐 → cleanup 시 안전하게 일괄 제거.
 */

import "dotenv/config";
import { initializeApp, getApps } from "firebase-admin/app";
import { getFirestore, Timestamp } from "firebase-admin/firestore";

const projectId =
  process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID || "mathlab-gomath";

if (getApps().length === 0) {
  initializeApp({ projectId });
}
const db = getFirestore();

// ====================================================================
// 테스트 사용자 정의 (다양한 레벨·리그·학년·스트릭으로 분포)
// ====================================================================
const TEST_USERS = [
  {
    displayName: "수학천재 민준",
    level: 12,
    totalXp: 5800,
    streak: 42,
    league: "gold",
    currentGrade: "고1",
  },
  {
    displayName: "공식왕 서연",
    level: 9,
    totalXp: 4200,
    streak: 28,
    league: "silver",
    currentGrade: "고1",
  },
  {
    displayName: "대수마스터 지호",
    level: 15,
    totalXp: 7300,
    streak: 67,
    league: "diamond",
    currentGrade: "고2",
  },
  {
    displayName: "기하의신 하윤",
    level: 7,
    totalXp: 2900,
    streak: 14,
    league: "silver",
    currentGrade: "중3",
  },
  {
    displayName: "도형달인 채원",
    level: 5,
    totalXp: 1800,
    streak: 9,
    league: "bronze",
    currentGrade: "중3",
  },
  {
    displayName: "함수전문가 현우",
    level: 11,
    totalXp: 5100,
    streak: 35,
    league: "gold",
    currentGrade: "고1",
  },
  {
    displayName: "스트릭레전드 시우",
    level: 8,
    totalXp: 3500,
    streak: 88,
    league: "silver",
    currentGrade: "고1",
  },
  {
    displayName: "신입생 윤서",
    level: 2,
    totalXp: 350,
    streak: 3,
    league: "bronze",
    currentGrade: "중2",
  },
];

function buildUserDoc(u, now) {
  return {
    email: u.email,
    displayName: u.displayName,
    photoUrl: null,
    phoneNumber: null,
    authProvider: "email",
    isGuest: false,
    isEmailVerified: true,
    role: "user",
    createdAt: now,
    updatedAt: now,
    lastLoginAt: now,
    level: u.level,
    xp: 0,
    totalXp: u.totalXp,
    dailyXP: 0,
    streak: u.streak,
    longestStreak: u.streak,
    lastStudyDate: now,
    hearts: 5,
    maxHearts: 5,
    lastHeartLostAt: null,
    gems: 50 * u.level,
    league: u.league,
    achievements: [],
    streakFreezes: 1,
    lastFreezeUsedAt: null,
    currentGrade: u.currentGrade,
    preferredLanguage: "ko",
    notificationsEnabled: true,
    soundEnabled: true,
    dailyGoalMinutes: 15,
    dailyReminderEnabled: true,
    reminderHour: 19,
    reminderMinute: 0,
    streakReminderEnabled: true,
    achievementAlertEnabled: true,
    leagueUpdateEnabled: true,
    weeklyReportEnabled: false,
    isTestUser: true,
  };
}

async function seed() {
  console.log(`🌱 Seeding ${TEST_USERS.length} test users to: ${projectId}\n`);
  const now = Timestamp.now();
  const batch = db.batch();

  TEST_USERS.forEach((u, i) => {
    const uid = `test_user_${String(i + 1).padStart(2, "0")}`;
    const email = `test${i + 1}@mathlab.dev`;
    const ref = db.collection("users").doc(uid);
    batch.set(ref, buildUserDoc({ ...u, email }, now));
    console.log(
      `  + ${u.displayName.padEnd(20)} lv${String(u.level).padStart(2)} | ${u.league.padEnd(8)} | streak ${u.streak}일`
    );
  });

  await batch.commit();
  console.log(`\n✅ 시드 완료. 앱에서 친구 검색해 보세요:`);
  console.log(`   → "수학천재", "공식왕", "대수마스터" 등 닉네임으로 검색 가능`);
  console.log(`   → 리그 화면에서 위 8명이 함께 노출됨`);
}

async function cleanup() {
  console.log("🗑️  Removing test users (isTestUser==true)...");
  const snap = await db
    .collection("users")
    .where("isTestUser", "==", true)
    .get();

  if (snap.empty) {
    console.log("(no test users found)");
    return;
  }

  const batch = db.batch();
  snap.docs.forEach((doc) => batch.delete(doc.ref));
  await batch.commit();
  console.log(`✅ ${snap.size}명 삭제 완료`);
}

const cmd = process.argv[2] || "seed";
if (cmd === "seed") {
  seed()
    .then(() => process.exit(0))
    .catch((e) => {
      console.error("❌ Seed failed:", e);
      process.exit(1);
    });
} else if (cmd === "cleanup") {
  cleanup()
    .then(() => process.exit(0))
    .catch((e) => {
      console.error("❌ Cleanup failed:", e);
      process.exit(1);
    });
} else {
  console.log(
    "Usage: node scripts/seed-test-users.mjs [seed|cleanup]\n" +
      "  seed     → 8명의 테스트 사용자 추가\n" +
      "  cleanup  → isTestUser==true인 사용자 일괄 삭제"
  );
  process.exit(1);
}
