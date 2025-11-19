import { Request, Response } from 'express';
import { userService } from '../services/user.service';
import { logger } from '../utils/logger';

export class UserController {
  /**
   * GET /api/v1/users/me
   * 현재 사용자 정보 조회
   */
  async getCurrentUser(req: Request, res: Response) {
    try {
      if (!req.user) {
        return res.status(401).json({
          success: false,
          error: 'Unauthorized',
        });
      }

      const user = await userService.getUserById(req.user.userId);

      if (!user) {
        return res.status(404).json({
          success: false,
          error: 'User not found',
        });
      }

      return res.json({
        success: true,
        data: user,
      });
    } catch (error: any) {
      logger.error('Get current user error:', error);
      return res.status(500).json({
        success: false,
        error: 'Failed to get user',
        message: error.message,
      });
    }
  }

  /**
   * GET /api/v1/users/me/stats
   * 사용자 통계 조회
   */
  async getUserStats(req: Request, res: Response) {
    try {
      if (!req.user) {
        return res.status(401).json({
          success: false,
          error: 'Unauthorized',
        });
      }

      const stats = await userService.getUserStats(req.user.userId);

      return res.json({
        success: true,
        data: stats,
      });
    } catch (error: any) {
      logger.error('Get user stats error:', error);
      return res.status(500).json({
        success: false,
        error: 'Failed to get stats',
        message: error.message,
      });
    }
  }

  /**
   * POST /api/v1/users/me/xp
   * XP 추가 (서버 검증)
   */
  async addXP(req: Request, res: Response) {
    try {
      if (!req.user) {
        return res.status(401).json({
          success: false,
          error: 'Unauthorized',
        });
      }

      const { amount } = req.body;

      if (!amount || amount <= 0) {
        return res.status(400).json({
          success: false,
          error: 'Invalid amount',
        });
      }

      const user = await userService.addXP(req.user.userId, amount);

      return res.json({
        success: true,
        message: 'XP added successfully',
        data: user,
      });
    } catch (error: any) {
      logger.error('Add XP error:', error);
      return res.status(500).json({
        success: false,
        error: 'Failed to add XP',
        message: error.message,
      });
    }
  }

  /**
   * POST /api/v1/users/me/hearts
   * 하트 차감/회복
   */
  async updateHearts(req: Request, res: Response) {
    try {
      if (!req.user) {
        return res.status(401).json({
          success: false,
          error: 'Unauthorized',
        });
      }

      const { amount } = req.body;

      const user = await userService.updateHearts(req.user.userId, amount);

      return res.json({
        success: true,
        message: 'Hearts updated successfully',
        data: user,
      });
    } catch (error: any) {
      logger.error('Update hearts error:', error);
      return res.status(500).json({
        success: false,
        error: 'Failed to update hearts',
        message: error.message,
      });
    }
  }

  /**
   * PUT /api/v1/users/me
   * 프로필 업데이트
   */
  async updateProfile(req: Request, res: Response) {
    try {
      if (!req.user) {
        return res.status(401).json({
          success: false,
          error: 'Unauthorized',
        });
      }

      const { displayName, avatarUrl } = req.body;

      const user = await userService.updateProfile(req.user.userId, {
        displayName,
        avatarUrl,
      });

      return res.json({
        success: true,
        message: 'Profile updated successfully',
        data: user,
      });
    } catch (error: any) {
      logger.error('Update profile error:', error);
      return res.status(500).json({
        success: false,
        error: 'Failed to update profile',
        message: error.message,
      });
    }
  }
}

export const userController = new UserController();
