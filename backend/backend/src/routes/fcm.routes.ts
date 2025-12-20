import { Router } from 'express';
import fcmController from '../controllers/fcm.controller';
import { authenticateToken, requireAdmin } from '../middlewares/auth.middleware';

const router = Router();

// FCM 토큰 관리
router.post('/token', authenticateToken, fcmController.saveToken);
router.delete('/token/:userId', authenticateToken, fcmController.deleteToken);

// 토픽 구독
router.post('/subscribe', authenticateToken, fcmController.subscribeToTopic);
router.post('/unsubscribe', authenticateToken, fcmController.unsubscribeFromTopic);

// 푸시 알림 전송 (관리자 전용)
router.post(
  '/send',
  authenticateToken,
  requireAdmin,
  fcmController.sendNotification
);

export default router;
