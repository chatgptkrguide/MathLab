import { Router } from 'express';
import { authController } from '../controllers/auth.controller';

const router = Router();

// 회원가입
router.post('/signup/email', authController.signUpWithEmail.bind(authController));

// 로그인
router.post('/login/email', authController.loginWithEmail.bind(authController));
router.post('/login/google', authController.loginWithGoogle.bind(authController));
router.post('/login/kakao', authController.loginWithKakao.bind(authController));

// 토큰 갱신
router.post('/refresh', authController.refreshToken.bind(authController));

// 로그아웃
router.post('/logout', authController.logout.bind(authController));

export default router;
