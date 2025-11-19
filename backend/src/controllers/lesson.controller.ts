import { Request, Response } from 'express';
import { lessonService } from '../services/lesson.service';
import { logger } from '../utils/logger';

export class LessonController {
  async getAllLessons(req: Request, res: Response) {
    try {
      const lessons = await lessonService.getAllLessons();
      return res.json({ success: true, data: lessons });
    } catch (error: any) {
      logger.error('Get lessons error:', error);
      return res.status(500).json({ success: false, error: error.message });
    }
  }

  async getUserProgress(req: Request, res: Response) {
    try {
      if (!req.user) {
        return res.status(401).json({ success: false, error: 'Unauthorized' });
      }
      const progress = await lessonService.getUserLessonProgress(req.user.userId);
      return res.json({ success: true, data: progress });
    } catch (error: any) {
      logger.error('Get user progress error:', error);
      return res.status(500).json({ success: false, error: error.message });
    }
  }

  async completeLesson(req: Request, res: Response) {
    try {
      if (!req.user) {
        return res.status(401).json({ success: false, error: 'Unauthorized' });
      }
      const { lessonId } = req.params;
      await lessonService.completeLesson(req.user.userId, lessonId);
      return res.json({ success: true, message: 'Lesson completed' });
    } catch (error: any) {
      logger.error('Complete lesson error:', error);
      return res.status(500).json({ success: false, error: error.message });
    }
  }
}

export const lessonController = new LessonController();
