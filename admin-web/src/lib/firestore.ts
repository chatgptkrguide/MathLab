import {
  collection,
  doc,
  getDocs,
  getDoc,
  addDoc,
  updateDoc,
  deleteDoc,
  query,
  where,
  orderBy,
  limit,
  startAfter,
  serverTimestamp,
  DocumentSnapshot,
  QueryConstraint,
  writeBatch,
} from "firebase/firestore";
import { db } from "./firebase";
import { Problem, Unit, Lesson, ProblemType, ProblemDifficulty } from "./types";

// ==================== PROBLEMS ====================

export interface ProblemFilters {
  lessonId?: string;
  unitId?: string;
  difficulty?: ProblemDifficulty;
  type?: ProblemType;
  searchText?: string;
}

export async function getProblems(
  filters: ProblemFilters = {},
  pageSize = 20,
  lastDoc?: DocumentSnapshot
): Promise<{ problems: Problem[]; lastDoc: DocumentSnapshot | null; total: number }> {
  const constraints: QueryConstraint[] = [];

  if (filters.lessonId) {
    constraints.push(where("lessonId", "==", filters.lessonId));
  }
  if (filters.difficulty) {
    constraints.push(where("difficulty", "==", filters.difficulty));
  }
  if (filters.type) {
    constraints.push(where("type", "==", filters.type));
  }

  constraints.push(orderBy("createdAt", "desc"));

  if (lastDoc) {
    constraints.push(startAfter(lastDoc));
  }
  constraints.push(limit(pageSize));

  const q = query(collection(db, "problems"), ...constraints);
  const snapshot = await getDocs(q);

  const problems: Problem[] = snapshot.docs.map((doc) => ({
    id: doc.id,
    ...doc.data(),
  })) as Problem[];

  // Client-side text search if needed
  let filtered = problems;
  if (filters.searchText) {
    const search = filters.searchText.toLowerCase();
    filtered = problems.filter(
      (p) =>
        p.question.toLowerCase().includes(search) ||
        p.correctAnswer.toLowerCase().includes(search)
    );
  }

  // Get total count (separate query without pagination)
  const countConstraints: QueryConstraint[] = [];
  if (filters.lessonId) countConstraints.push(where("lessonId", "==", filters.lessonId));
  if (filters.difficulty) countConstraints.push(where("difficulty", "==", filters.difficulty));
  if (filters.type) countConstraints.push(where("type", "==", filters.type));
  const countQuery = query(collection(db, "problems"), ...countConstraints);
  const countSnapshot = await getDocs(countQuery);

  return {
    problems: filtered,
    lastDoc: snapshot.docs[snapshot.docs.length - 1] || null,
    total: countSnapshot.size,
  };
}

export async function getProblem(id: string): Promise<Problem | null> {
  const docRef = doc(db, "problems", id);
  const docSnap = await getDoc(docRef);
  if (!docSnap.exists()) return null;
  return { id: docSnap.id, ...docSnap.data() } as Problem;
}

export async function createProblem(
  data: Omit<Problem, "id" | "createdAt" | "updatedAt">
): Promise<string> {
  // Get current problem count for this lesson to set order
  const countQuery = query(
    collection(db, "problems"),
    where("lessonId", "==", data.lessonId)
  );
  const countSnap = await getDocs(countQuery);
  const order = countSnap.size;

  const docRef = await addDoc(collection(db, "problems"), {
    ...data,
    order,
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
  });
  return docRef.id;
}

export async function updateProblem(
  id: string,
  data: Partial<Omit<Problem, "id" | "createdAt">>
): Promise<void> {
  const docRef = doc(db, "problems", id);
  await updateDoc(docRef, {
    ...data,
    updatedAt: serverTimestamp(),
  });
}

export async function deleteProblem(id: string): Promise<void> {
  await deleteDoc(doc(db, "problems", id));
}

export async function bulkCreateProblems(
  problems: Omit<Problem, "id" | "createdAt" | "updatedAt">[]
): Promise<number> {
  const batch = writeBatch(db);
  let count = 0;

  for (const problem of problems) {
    const docRef = doc(collection(db, "problems"));
    batch.set(docRef, {
      ...problem,
      createdAt: serverTimestamp(),
      updatedAt: serverTimestamp(),
    });
    count++;

    // Firestore batch limit is 500
    if (count % 450 === 0) {
      await batch.commit();
    }
  }

  if (count % 450 !== 0) {
    await batch.commit();
  }

  return count;
}

// ==================== UNITS ====================

export async function getUnits(): Promise<Unit[]> {
  const q = query(collection(db, "units"), orderBy("order", "asc"));
  const snapshot = await getDocs(q);
  return snapshot.docs.map((doc) => ({
    id: doc.id,
    ...doc.data(),
  })) as Unit[];
}

export async function getUnit(id: string): Promise<Unit | null> {
  const docSnap = await getDoc(doc(db, "units", id));
  if (!docSnap.exists()) return null;
  return { id: docSnap.id, ...docSnap.data() } as Unit;
}

export async function createUnit(data: Omit<Unit, "id">): Promise<string> {
  const docRef = await addDoc(collection(db, "units"), data);
  return docRef.id;
}

export async function updateUnit(id: string, data: Partial<Omit<Unit, "id">>): Promise<void> {
  await updateDoc(doc(db, "units", id), data);
}

export async function deleteUnit(id: string): Promise<void> {
  await deleteDoc(doc(db, "units", id));
}

// ==================== LESSONS (top-level collection matching Flutter app) ====================

export async function getLessons(unitId?: string): Promise<Lesson[]> {
  const constraints: QueryConstraint[] = [];
  if (unitId) {
    constraints.push(where("unitId", "==", unitId));
  }
  constraints.push(orderBy("order", "asc"));

  const q = query(collection(db, "lessons"), ...constraints);
  const snapshot = await getDocs(q);
  return snapshot.docs.map((d) => ({
    id: d.id,
    ...d.data(),
  })) as Lesson[];
}

export async function getLesson(unitId: string, id: string): Promise<Lesson | null> {
  const docSnap = await getDoc(doc(db, "lessons", id));
  if (!docSnap.exists()) return null;
  return { id: docSnap.id, ...docSnap.data() } as Lesson;
}

export async function createLesson(data: Omit<Lesson, "id">): Promise<string> {
  if (!data.unitId) throw new Error("unitId is required");
  const docRef = await addDoc(collection(db, "lessons"), data);
  return docRef.id;
}

export async function updateLesson(unitId: string, id: string, data: Partial<Omit<Lesson, "id">>): Promise<void> {
  await updateDoc(doc(db, "lessons", id), data);
}

export async function deleteLesson(unitId: string, id: string): Promise<void> {
  await deleteDoc(doc(db, "lessons", id));
}

// ==================== PROBLEM COUNTS ====================

export async function getProblemCountsByLesson(): Promise<Record<string, number>> {
  const snapshot = await getDocs(collection(db, "problems"));
  const counts: Record<string, number> = {};
  snapshot.docs.forEach((doc) => {
    const lessonId = doc.data().lessonId;
    if (lessonId) {
      counts[lessonId] = (counts[lessonId] || 0) + 1;
    }
  });
  return counts;
}

// ==================== STATS ====================

export async function getUserCount(): Promise<number> {
  const snapshot = await getDocs(collection(db, "users"));
  return snapshot.size;
}

export async function getDashboardStats() {
  const [problemsSnap, unitsSnap, lessonsSnap, userCount] = await Promise.all([
    getDocs(collection(db, "problems")),
    getDocs(collection(db, "units")),
    getDocs(collection(db, "lessons")),
    getUserCount(),
  ]);

  const totalLessons = lessonsSnap.size;

  const problems = problemsSnap.docs.map((d) => d.data());

  // Count by difficulty
  const byDifficulty: Record<string, number> = {};
  const byType: Record<string, number> = {};
  const byLesson: Record<string, number> = {};

  problems.forEach((p) => {
    byDifficulty[p.difficulty] = (byDifficulty[p.difficulty] || 0) + 1;
    byType[p.type] = (byType[p.type] || 0) + 1;
    byLesson[p.lessonId] = (byLesson[p.lessonId] || 0) + 1;
  });

  // Weekly activity data (last 7 days)
  const now = new Date();
  const weeklyData: { date: string; count: number }[] = [];
  for (let i = 6; i >= 0; i--) {
    const d = new Date(now);
    d.setDate(d.getDate() - i);
    const dateStr = d.toISOString().split("T")[0]; // YYYY-MM-DD
    weeklyData.push({ date: dateStr, count: 0 });
  }

  // Today count
  const todayStr = now.toISOString().split("T")[0];
  let todayCount = 0;

  problemsSnap.docs.forEach((d) => {
    const data = d.data();
    const createdAt = data.createdAt as { seconds?: number } | undefined;
    if (createdAt?.seconds) {
      const createdDate = new Date(createdAt.seconds * 1000);
      const dateStr = createdDate.toISOString().split("T")[0];
      const entry = weeklyData.find((w) => w.date === dateStr);
      if (entry) {
        entry.count++;
      }
      if (dateStr === todayStr) {
        todayCount++;
      }
    }
  });

  // Lesson coverage: merge lesson titles with problem counts
  const lessonMap = new Map<string, string>();
  lessonsSnap.docs.forEach((d) => {
    const data = d.data();
    lessonMap.set(d.id, data.title || d.id);
  });

  const lessonCoverage = Array.from(lessonMap.entries()).map(([lessonId, lessonTitle]) => ({
    lessonId,
    lessonTitle,
    count: byLesson[lessonId] || 0,
  }));
  lessonCoverage.sort((a, b) => b.count - a.count);

  return {
    totalProblems: problemsSnap.size,
    totalUnits: unitsSnap.size,
    totalLessons,
    userCount,
    todayCount,
    byDifficulty,
    byType,
    byLesson,
    weeklyData,
    lessonCoverage,
    recentProblems: problemsSnap.docs
      .map((d) => ({ id: d.id, ...d.data() }))
      .sort((a: Record<string, unknown>, b: Record<string, unknown>) => {
        const aTime = (a.createdAt as { seconds?: number })?.seconds || 0;
        const bTime = (b.createdAt as { seconds?: number })?.seconds || 0;
        return bTime - aTime;
      })
      .slice(0, 10) as Problem[],
  };
}
