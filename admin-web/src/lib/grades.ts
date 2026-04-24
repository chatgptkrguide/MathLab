export interface GradeInfo {
  key: string;
  label: string;
  subjects: string[];
}

export const GRADES: GradeInfo[] = [
  { key: "elem", label: "초등", subjects: ["공통수학1"] },
  { key: "mid", label: "중등", subjects: ["공통수학1", "공통수학2"] },
  { key: "h1", label: "고1", subjects: ["공통수학1", "공통수학2"] },
  { key: "h2", label: "고2", subjects: ["공통수학1", "공통수학2", "수학I", "수학II", "확률과 통계"] },
  { key: "h3", label: "고3", subjects: ["공통수학1", "공통수학2", "수학I", "수학II", "확률과 통계", "미적분", "기하"] },
];

export const DEFAULT_GRADE = "h1";
