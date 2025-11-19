export interface User {
  id: string;
  email: string;
  display_name: string;
  password_hash?: string;
  auth_provider: 'email' | 'google' | 'kakao' | 'apple';
  auth_provider_id?: string;
  level: number;
  xp: number;
  streak_days: number;
  hearts: number;
  current_grade: string;
  avatar_url?: string;
  created_at: Date;
  updated_at: Date;
  last_login_at?: Date;
  last_streak_date?: Date;
  is_active: boolean;
}

export interface CreateUserDTO {
  email: string;
  display_name: string;
  password?: string;
  auth_provider: 'email' | 'google' | 'kakao' | 'apple';
  auth_provider_id?: string;
  current_grade?: string;
}

export interface LoginDTO {
  email: string;
  password: string;
}

export interface SocialLoginDTO {
  provider: 'google' | 'kakao' | 'apple';
  id_token?: string;
  access_token?: string;
}

export interface AuthResponse {
  user: Omit<User, 'password_hash'>;
  access_token: string;
  refresh_token: string;
}

export interface UserStats {
  user_id: string;
  display_name: string;
  level: number;
  xp: number;
  streak_days: number;
  hearts: number;
  lessons_completed: number;
  problems_attempted: number;
  problems_correct: number;
  achievements_unlocked: number;
  accuracy_percent: number;
}
