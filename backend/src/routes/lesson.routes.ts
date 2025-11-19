import { Router } from 'express';
import { authMiddleware, optionalAuthMiddleware } from '../middlewares/auth';
import { lessonController } from '../controllers/lesson.controller';

const router = Router();

router.get('/', optionalAuthMiddleware, lessonController.getAllLessons.bind(lessonController));
router.get('/me/progress', authMiddleware, lessonController.getUserProgress.bind(lessonController));
router.post('/:lessonId/complete', authMiddleware, lessonController.completeLesson.bind(lessonController));

export default router;
