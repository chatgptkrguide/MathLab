import { Router } from 'express';
import { authMiddleware, optionalAuthMiddleware } from '../middlewares/auth';
import { leaderboardController } from '../controllers/leaderboard.controller';

const router = Router();

router.get('/weekly', optionalAuthMiddleware, leaderboardController.getWeeklyLeaderboard.bind(leaderboardController));
router.get('/me', authMiddleware, leaderboardController.getMyRank.bind(leaderboardController));

export default router;
