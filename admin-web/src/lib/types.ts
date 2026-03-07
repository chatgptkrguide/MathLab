import { Timestamp } from "firebase/firestore";

// Problem types matching Flutter ProblemType enum
export type ProblemType =
  | "multipleChoice"
  | "shortAnswer"
  | "trueFalse"
  | "fillInBlank"
  | "matching"
  | "dragAndDrop";

// Problem difficulty matching Flutter ProblemDifficulty enum
export type ProblemDifficulty = "easy" | "medium" | "hard" | "expert";

// Unit theme matching Flutter UnitTheme enum
export type UnitTheme = "blue" | "green" | "orange" | "purple" | "red" | "yellow";

export interface Problem {
  id: string;
  lessonId: string;
  question: string;
  type: ProblemType;
  difficulty: ProblemDifficulty;
  options: string[];
  correctAnswer: string;
  explanation?: string;
  hint?: string;
  hints: string[];
  points: number;
  imageUrl?: string;
  imageUrls: string[];
  createdAt?: Timestamp;
  updatedAt?: Timestamp;
}

export interface Unit {
  id: string;
  title: string;
  description: string;
  subject: string;
  order: number;
  emoji: string;
  theme: UnitTheme;
}

export interface Lesson {
  id: string;
  unitId?: string;
  title: string;
  description: string;
  order: number;
  xpReward: number;
  type: string;
  difficulty: string;
  concepts: string[];
  estimatedMinutes: number;
}

export interface UserModel {
  id: string;
  email?: string;
  isAdmin?: boolean;
}

export const PROBLEM_TYPE_LABELS: Record<ProblemType, string> = {
  multipleChoice: "객관식 (4지선다)",
  shortAnswer: "단답형",
  trueFalse: "O/X",
  fillInBlank: "빈칸 채우기",
  matching: "매칭",
  dragAndDrop: "드래그 앤 드롭",
};

export const DIFFICULTY_LABELS: Record<ProblemDifficulty, string> = {
  easy: "쉬움",
  medium: "보통",
  hard: "어려움",
  expert: "전문가",
};

export const UNIT_THEME_COLORS: Record<UnitTheme, string> = {
  blue: "#3B82F6",
  green: "#22C55E",
  orange: "#F97316",
  purple: "#8B5CF6",
  red: "#EF4444",
  yellow: "#EAB308",
};
