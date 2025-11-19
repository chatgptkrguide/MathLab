import { db } from '../config/database';
import { logger } from '../utils/logger';
import { User, UserStats } from '../models/user';

export class UserService {
  /**
   * 사용자 정보 조회
   */
  async getUserById(userId: string): Promise<User | null> {
    const result = await db.query(
      `SELECT id, email, display_name, auth_provider, level, xp, streak_days, hearts,
              current_grade, avatar_url, created_at, updated_at, last_login_at, is_active
       FROM users
       WHERE id = $1`,
      [userId]
    );

    return result.rows.length > 0 ? result.rows[0] : null;
  }

  /**
   * 사용자 통계 조회
   */
  async getUserStats(userId: string): Promise<UserStats | null> {
    const result = await db.query('SELECT * FROM user_stats WHERE user_id = $1', [userId]);

    return result.rows.length > 0 ? result.rows[0] : null;
  }

  /**
   * XP 추가 (서버 검증)
   */
  async addXP(userId: string, amount: number): Promise<User> {
    const result = await db.query(
      `UPDATE users
       SET xp = xp + $1, updated_at = NOW()
       WHERE id = $2
       RETURNING id, email, display_name, level, xp, streak_days, hearts, current_grade, avatar_url`,
      [amount, userId]
    );

    // 레벨업 체크
    const user = result.rows[0];
    const levelUpXP = user.level * 100;

    if (user.xp >= levelUpXP) {
      await db.query('UPDATE users SET level = level + 1 WHERE id = $1', [userId]);
    }

    return user;
  }

  /**
   * 하트 차감/회복
   */
  async updateHearts(userId: string, amount: number): Promise<User> {
    const result = await db.query(
      `UPDATE users
       SET hearts = GREATEST(0, LEAST(5, hearts + $1)), updated_at = NOW()
       WHERE id = $2
       RETURNING id, email, display_name, level, xp, streak_days, hearts, current_grade, avatar_url`,
      [amount, userId]
    );

    return result.rows[0];
  }

  /**
   * 프로필 업데이트
   */
  async updateProfile(userId: string, data: { displayName?: string; avatarUrl?: string }): Promise<User> {
    const updates: string[] = [];
    const values: any[] = [];
    let paramCount = 1;

    if (data.displayName) {
      updates.push(`display_name = $${paramCount++}`);
      values.push(data.displayName);
    }

    if (data.avatarUrl) {
      updates.push(`avatar_url = $${paramCount++}`);
      values.push(data.avatarUrl);
    }

    updates.push(`updated_at = NOW()`);
    values.push(userId);

    const result = await db.query(
      `UPDATE users
       SET ${updates.join(', ')}
       WHERE id = $${paramCount}
       RETURNING id, email, display_name, level, xp, streak_days, hearts, current_grade, avatar_url`,
      values
    );

    return result.rows[0];
  }
}

export const userService = new UserService();
