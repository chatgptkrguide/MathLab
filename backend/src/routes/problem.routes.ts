import { Router } from 'express';
import { authMiddleware, optionalAuthMiddleware } from '../middlewares/auth';
import { problemController } from '../controllers/problem.controller';

const router = Router();

router.get('/', optionalAuthMiddleware, problemController.getProblemsByLesson.bind(problemController));
router.post('/:problemId/submit', authMiddleware, problemController.submitAnswer.bind(problemController));
router.get('/me/results', authMiddleware, problemController.getUserResults.bind(problemController));

export default router;
