import { Response } from 'express';
import { AuthRequest } from '../middlewares/auth.middleware';
import fcmService from '../services/fcm.service';
import { ResponseHandler } from '../utils/response';
import logger from '../utils/logger';

export class FcmController {
  /**
   * POST /api/v1/fcm/token
   * FCM 토큰 등록/갱신
   */
  async saveToken(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { token, deviceType, deviceId } = req.body;
      const userId = req.user!.id;

      if (!token || !deviceType) {
        ResponseHandler.validationError(res, [
          { field: 'token', message: 'FCM 토큰은 필수입니다' },
          { field: 'deviceType', message: '디바이스 타입은 필수입니다' },
        ]);
        return;
      }

      const savedToken = await fcmService.saveToken(
        userId,
        token,
        deviceType,
        deviceId
      );

      ResponseHandler.success(res, savedToken, 'FCM 토큰이 저장되었습니다', 201);
    } catch (error) {
      logger.error('Error in saveToken:', error);
      ResponseHandler.serverError(res);
    }
  }

  /**
   * DELETE /api/v1/fcm/token/:userId
   * FCM 토큰 삭제
   */
  async deleteToken(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { userId } = req.params;
      const { deviceId } = req.query;

      // 자신의 토큰만 삭제 가능 (관리자는 모든 토큰 삭제 가능)
      if (req.user!.id !== userId && req.user!.role !== 'admin') {
        ResponseHandler.forbidden(res, '자신의 토큰만 삭제할 수 있습니다');
        return;
      }

      await fcmService.deleteToken(userId, deviceId as string);

      ResponseHandler.success(res, null, 'FCM 토큰이 삭제되었습니다');
    } catch (error) {
      logger.error('Error in deleteToken:', error);
      ResponseHandler.serverError(res);
    }
  }

  /**
   * POST /api/v1/fcm/subscribe
   * 토픽 구독
   */
  async subscribeToTopic(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { token, topic } = req.body;

      if (!token || !topic) {
        ResponseHandler.validationError(res, [
          { field: 'token', message: 'FCM 토큰은 필수입니다' },
          { field: 'topic', message: '토픽은 필수입니다' },
        ]);
        return;
      }

      await fcmService.subscribeToTopic(token, topic);

      ResponseHandler.success(res, null, `토픽 ${topic}에 구독되었습니다`);
    } catch (error) {
      logger.error('Error in subscribeToTopic:', error);
      ResponseHandler.serverError(res);
    }
  }

  /**
   * POST /api/v1/fcm/unsubscribe
   * 토픽 구독 해제
   */
  async unsubscribeFromTopic(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { token, topic } = req.body;

      if (!token || !topic) {
        ResponseHandler.validationError(res, [
          { field: 'token', message: 'FCM 토큰은 필수입니다' },
          { field: 'topic', message: '토픽은 필수입니다' },
        ]);
        return;
      }

      await fcmService.unsubscribeFromTopic(token, topic);

      ResponseHandler.success(res, null, `토픽 ${topic} 구독이 해제되었습니다`);
    } catch (error) {
      logger.error('Error in unsubscribeFromTopic:', error);
      ResponseHandler.serverError(res);
    }
  }

  /**
   * POST /api/v1/fcm/send
   * 푸시 알림 전송 (관리자 전용)
   */
  async sendNotification(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { userId, userIds, topic, title, body, data, imageUrl } = req.body;

      if (!title || !body) {
        ResponseHandler.validationError(res, [
          { field: 'title', message: '제목은 필수입니다' },
          { field: 'body', message: '내용은 필수입니다' },
        ]);
        return;
      }

      if (!userId && !userIds && !topic) {
        ResponseHandler.validationError(res, [
          {
            field: 'target',
            message: 'userId, userIds, topic 중 하나는 필수입니다',
          },
        ]);
        return;
      }

      await fcmService.sendNotification({
        userId,
        userIds,
        topic,
        title,
        body,
        data,
        imageUrl,
      });

      ResponseHandler.success(res, null, '푸시 알림이 전송되었습니다');
    } catch (error) {
      logger.error('Error in sendNotification:', error);
      ResponseHandler.serverError(res);
    }
  }
}

export default new FcmController();
