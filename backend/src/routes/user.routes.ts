import { Router } from 'express';
import { authMiddleware } from '../middlewares/auth';
import { userController } from '../controllers/user.controller';

const router = Router();

// 모든 라우트에 인증 필요
router.use(authMiddleware);

// 사용자 정보
router.get('/me', userController.getCurrentUser.bind(userController));
router.put('/me', userController.updateProfile.bind(userController));

// 사용자 통계
router.get('/me/stats', userController.getUserStats.bind(userController));

// 게임 데이터
router.post('/me/xp', userController.addXP.bind(userController));
router.post('/me/hearts', userController.updateHearts.bind(userController));

export default router;
