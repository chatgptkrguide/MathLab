import { Request, Response } from 'express';
import { problemService } from '../services/problem.service';
import { logger } from '../utils/logger';

export class ProblemController {
  async getProblemsByLesson(req: Request, res: Response) {
    try {
      const { lessonId } = req.query;
      if (!lessonId) {
        return res.status(400).json({ success: false, error: 'lessonId required' });
      }
      const problems = await problemService.getProblemsByLesson(lessonId as string);
      return res.json({ success: true, data: problems });
    } catch (error: any) {
      logger.error('Get problems error:', error);
      return res.status(500).json({ success: false, error: error.message });
    }
  }

  async submitAnswer(req: Request, res: Response) {
    try {
      if (!req.user) {
        return res.status(401).json({ success: false, error: 'Unauthorized' });
      }
      const { problemId } = req.params;
      const { answer, timeSpent, hintsUsed } = req.body;

      const result = await problemService.submitProblemAnswer(
        req.user.userId,
        problemId,
        answer,
        timeSpent || 0,
        hintsUsed || 0
      );

      return res.json({ success: true, data: result });
    } catch (error: any) {
      logger.error('Submit answer error:', error);
      return res.status(500).json({ success: false, error: error.message });
    }
  }

  async getUserResults(req: Request, res: Response) {
    try {
      if (!req.user) {
        return res.status(401).json({ success: false, error: 'Unauthorized' });
      }
      const results = await problemService.getUserProblemResults(req.user.userId);
      return res.json({ success: true, data: results });
    } catch (error: any) {
      logger.error('Get user results error:', error);
      return res.status(500).json({ success: false, error: error.message });
    }
  }
}

export const problemController = new ProblemController();
