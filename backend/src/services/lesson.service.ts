import { db } from '../config/database';
import { logger } from '../utils/logger';

export class LessonService {
  /**
   * 모든 레슨 목록 조회
   */
  async getAllLessons() {
    const result = await db.query(
      'SELECT * FROM lessons ORDER BY order_index ASC'
    );
    return result.rows;
  }

  /**
   * 사용자의 레슨 진행도 조회
   */
  async getUserLessonProgress(userId: string) {
    const result = await db.query(
      `SELECT l.*, ulp.is_unlocked, ulp.is_completed, ulp.progress_percent,
              ulp.problems_completed, ulp.problems_total
       FROM lessons l
       LEFT JOIN user_lesson_progress ulp ON l.id = ulp.lesson_id AND ulp.user_id = $1
       ORDER BY l.order_index ASC`,
      [userId]
    );
    return result.rows;
  }

  /**
   * 레슨 완료 처리
   */
  async completeLesson(userId: string, lessonId: string) {
    await db.transaction(async (client) => {
      // 레슨 완료 처리
      await client.query(
        `UPDATE user_lesson_progress
         SET is_completed = true, completed_at = NOW(), progress_percent = 100
         WHERE user_id = $1 AND lesson_id = $2`,
        [userId, lessonId]
      );

      // 다음 레슨 언락
      const nextLesson = await client.query(
        `SELECT id FROM lessons WHERE order_index > (
          SELECT order_index FROM lessons WHERE id = $1
        ) ORDER BY order_index ASC LIMIT 1`,
        [lessonId]
      );

      if (nextLesson.rows.length > 0) {
        await client.query(
          `INSERT INTO user_lesson_progress (user_id, lesson_id, is_unlocked)
           VALUES ($1, $2, true)
           ON CONFLICT (user_id, lesson_id) DO UPDATE SET is_unlocked = true`,
          [userId, nextLesson.rows[0].id]
        );
      }

      // XP 보상
      const lesson = await client.query(
        'SELECT xp_reward FROM lessons WHERE id = $1',
        [lessonId]
      );

      if (lesson.rows.length > 0) {
        await client.query(
          'UPDATE users SET xp = xp + $1 WHERE id = $2',
          [lesson.rows[0].xp_reward, userId]
        );
      }
    });
  }
}

export const lessonService = new LessonService();
