import { Request, Response } from 'express';
import { leaderboardService } from '../services/leaderboard.service';
import { logger } from '../utils/logger';

export class LeaderboardController {
  async getWeeklyLeaderboard(req: Request, res: Response) {
    try {
      const { league, limit } = req.query;
      const leaderboard = await leaderboardService.getWeeklyLeaderboard(
        (league as string) || 'bronze',
        parseInt(limit as string) || 50
      );
      return res.json({ success: true, data: leaderboard });
    } catch (error: any) {
      logger.error('Get leaderboard error:', error);
      return res.status(500).json({ success: false, error: error.message });
    }
  }

  async getMyRank(req: Request, res: Response) {
    try {
      if (!req.user) {
        return res.status(401).json({ success: false, error: 'Unauthorized' });
      }
      const rank = await leaderboardService.getMyRank(req.user.userId);
      return res.json({ success: true, data: rank });
    } catch (error: any) {
      logger.error('Get my rank error:', error);
      return res.status(500).json({ success: false, error: error.message });
    }
  }
}

export const leaderboardController = new LeaderboardController();
