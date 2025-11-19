import { db } from '../config/database';
import { logger } from '../utils/logger';

export class ProblemService {
  /**
   * 레슨의 문제 목록 조회
   */
  async getProblemsByLesson(lessonId: string) {
    const result = await db.query(
      `SELECT id, lesson_id, category, difficulty, question, type, options,
              hints, tags, xp_reward
       FROM problems
       WHERE lesson_id = $1
       ORDER BY difficulty ASC`,
      [lessonId]
    );
    return result.rows;
  }

  /**
   * 문제 답안 제출 및 검증 (서버에서 정답 확인)
   */
  async submitProblemAnswer(
    userId: string,
    problemId: string,
    userAnswer: string,
    timeSpent: number,
    hintsUsed: number
  ) {
    // 정답 조회
    const problemResult = await db.query(
      'SELECT correct_answer, xp_reward, explanation FROM problems WHERE id = $1',
      [problemId]
    );

    if (problemResult.rows.length === 0) {
      throw new Error('Problem not found');
    }

    const problem = problemResult.rows[0];
    const isCorrect = userAnswer.trim().toLowerCase() === problem.correct_answer.trim().toLowerCase();

    // XP 계산 (힌트 사용 시 감소)
    let xpEarned = isCorrect ? problem.xp_reward : 0;
    if (hintsUsed > 0) {
      xpEarned = Math.floor(xpEarned * (1 - hintsUsed * 0.2)); // 힌트당 20% 감소
    }

    // 결과 저장
    await db.query(
      `INSERT INTO user_problem_results (user_id, problem_id, is_correct, user_answer, time_spent_seconds, hints_used, xp_earned)
       VALUES ($1, $2, $3, $4, $5, $6, $7)`,
      [userId, problemId, isCorrect, userAnswer, timeSpent, hintsUsed, xpEarned]
    );

    // 정답이면 XP 추가
    if (isCorrect) {
      await db.query(
        'UPDATE users SET xp = xp + $1 WHERE id = $2',
        [xpEarned, userId]
      );
    }

    return {
      isCorrect,
      xpEarned,
      explanation: problem.explanation,
      correctAnswer: isCorrect ? undefined : problem.correct_answer,
    };
  }

  /**
   * 사용자의 문제 풀이 기록
   */
  async getUserProblemResults(userId: string, limit: number = 50) {
    const result = await db.query(
      `SELECT upr.*, p.question, p.category
       FROM user_problem_results upr
       JOIN problems p ON upr.problem_id = p.id
       WHERE upr.user_id = $1
       ORDER BY upr.solved_at DESC
       LIMIT $2`,
      [userId, limit]
    );
    return result.rows;
  }
}

export const problemService = new ProblemService();
