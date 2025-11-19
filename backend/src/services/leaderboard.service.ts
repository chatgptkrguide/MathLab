import { db } from '../config/database';
import { redis } from '../config/redis';
import { logger } from '../utils/logger';

export class LeaderboardService {
  /**
   * 주간 리더보드 조회
   */
  async getWeeklyLeaderboard(league: string = 'bronze', limit: number = 50) {
    // Redis 캐시 확인
    const cacheKey = `leaderboard:${league}:${this.getCurrentWeek()}`;
    const cached = await redis.get(cacheKey);

    if (cached) {
      return JSON.parse(cached);
    }

    // DB 조회
    const result = await db.query(
      `SELECT l.rank_position, u.id, u.display_name, u.avatar_url, l.weekly_xp
       FROM leaderboard l
       JOIN users u ON l.user_id = u.id
       WHERE l.league = $1 AND l.week_start = $2
       ORDER BY l.rank_position ASC
       LIMIT $3`,
      [league, this.getCurrentWeek(), limit]
    );

    // 캐시 저장 (5분)
    await redis.set(cacheKey, JSON.stringify(result.rows), 300);

    return result.rows;
  }

  /**
   * 내 순위 조회
   */
  async getMyRank(userId: string) {
    const result = await db.query(
      `SELECT rank_position, league, weekly_xp
       FROM leaderboard
       WHERE user_id = $1 AND week_start = $2`,
      [userId, this.getCurrentWeek()]
    );

    if (result.rows.length === 0) {
      // 리더보드 엔트리 생성
      await this.createLeaderboardEntry(userId);
      return { rank_position: null, league: 'bronze', weekly_xp: 0 };
    }

    return result.rows[0];
  }

  /**
   * 주간 XP 업데이트
   */
  async updateWeeklyXP(userId: string, xpGained: number) {
    const weekStart = this.getCurrentWeek();

    // 리더보드 엔트리 업데이트
    await db.query(
      `INSERT INTO leaderboard (user_id, league, weekly_xp, week_start, week_end)
       VALUES ($1, 'bronze', $2, $3, $3 + INTERVAL '6 days')
       ON CONFLICT (user_id, week_start)
       DO UPDATE SET weekly_xp = leaderboard.weekly_xp + $2`,
      [userId, xpGained, weekStart]
    );

    // Redis 캐시 무효화
    await redis.del(`leaderboard:bronze:${weekStart}`);
  }

  // Helper methods
  private getCurrentWeek(): string {
    const now = new Date();
    const dayOfWeek = now.getDay();
    const diff = now.getDate() - dayOfWeek + (dayOfWeek === 0 ? -6 : 1);
    const monday = new Date(now.setDate(diff));
    return monday.toISOString().split('T')[0];
  }

  private async createLeaderboardEntry(userId: string) {
    const weekStart = this.getCurrentWeek();
    await db.query(
      `INSERT INTO leaderboard (user_id, league, weekly_xp, week_start, week_end)
       VALUES ($1, 'bronze', 0, $2, $2::date + INTERVAL '6 days')
       ON CONFLICT DO NOTHING`,
      [userId, weekStart]
    );
  }
}

export const leaderboardService = new LeaderboardService();
