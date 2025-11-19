import { Request, Response } from 'express';
import { authService } from '../services/auth.service';
import { logger } from '../utils/logger';

export class AuthController {
  /**
   * POST /api/v1/auth/signup/email
   * 이메일 회원가입
   */
  async signUpWithEmail(req: Request, res: Response) {
    try {
      const { email, password, displayName, grade } = req.body;

      // 입력 검증
      if (!email || !password || !displayName) {
        return res.status(400).json({
          success: false,
          error: 'Missing required fields',
          message: 'Email, password, and displayName are required',
        });
      }

      const result = await authService.signUpWithEmail({
        email,
        password,
        display_name: displayName,
        auth_provider: 'email',
        current_grade: grade,
      });

      return res.status(201).json({
        success: true,
        message: 'User created successfully',
        data: result,
      });
    } catch (error: any) {
      logger.error('SignUp error:', error);

      if (error.message === 'Email already exists') {
        return res.status(409).json({
          success: false,
          error: 'Email already exists',
          message: 'This email is already registered',
        });
      }

      return res.status(500).json({
        success: false,
        error: 'Signup failed',
        message: error.message || 'An error occurred during signup',
      });
    }
  }

  /**
   * POST /api/v1/auth/login/email
   * 이메일 로그인
   */
  async loginWithEmail(req: Request, res: Response) {
    try {
      const { email, password } = req.body;

      // 입력 검증
      if (!email || !password) {
        return res.status(400).json({
          success: false,
          error: 'Missing required fields',
          message: 'Email and password are required',
        });
      }

      const result = await authService.signInWithEmail({ email, password });

      return res.json({
        success: true,
        message: 'Login successful',
        data: result,
      });
    } catch (error: any) {
      logger.error('Login error:', error);

      if (error.message === 'Invalid credentials') {
        return res.status(401).json({
          success: false,
          error: 'Invalid credentials',
          message: 'Email or password is incorrect',
        });
      }

      return res.status(500).json({
        success: false,
        error: 'Login failed',
        message: error.message || 'An error occurred during login',
      });
    }
  }

  /**
   * POST /api/v1/auth/login/google
   * Google 로그인
   */
  async loginWithGoogle(req: Request, res: Response) {
    try {
      const { idToken } = req.body;

      if (!idToken) {
        return res.status(400).json({
          success: false,
          error: 'Missing required fields',
          message: 'Google ID token is required',
        });
      }

      const result = await authService.signInWithGoogle(idToken);

      return res.json({
        success: true,
        message: 'Google login successful',
        data: result,
      });
    } catch (error: any) {
      logger.error('Google login error:', error);

      return res.status(500).json({
        success: false,
        error: 'Google login failed',
        message: error.message || 'An error occurred during Google login',
      });
    }
  }

  /**
   * POST /api/v1/auth/login/kakao
   * Kakao 로그인
   */
  async loginWithKakao(req: Request, res: Response) {
    try {
      const { accessToken } = req.body;

      if (!accessToken) {
        return res.status(400).json({
          success: false,
          error: 'Missing required fields',
          message: 'Kakao access token is required',
        });
      }

      const result = await authService.signInWithKakao(accessToken);

      return res.json({
        success: true,
        message: 'Kakao login successful',
        data: result,
      });
    } catch (error: any) {
      logger.error('Kakao login error:', error);

      return res.status(500).json({
        success: false,
        error: 'Kakao login failed',
        message: error.message || 'An error occurred during Kakao login',
      });
    }
  }

  /**
   * POST /api/v1/auth/refresh
   * 토큰 갱신
   */
  async refreshToken(req: Request, res: Response) {
    try {
      const { refreshToken } = req.body;

      if (!refreshToken) {
        return res.status(400).json({
          success: false,
          error: 'Missing required fields',
          message: 'Refresh token is required',
        });
      }

      const result = await authService.refreshAccessToken(refreshToken);

      return res.json({
        success: true,
        message: 'Token refreshed successfully',
        data: result,
      });
    } catch (error: any) {
      logger.error('Refresh token error:', error);

      return res.status(401).json({
        success: false,
        error: 'Token refresh failed',
        message: error.message || 'Invalid or expired refresh token',
      });
    }
  }

  /**
   * POST /api/v1/auth/logout
   * 로그아웃
   */
  async logout(req: Request, res: Response) {
    try {
      const { refreshToken } = req.body;

      if (!refreshToken) {
        return res.status(400).json({
          success: false,
          error: 'Missing required fields',
          message: 'Refresh token is required',
        });
      }

      await authService.signOut(refreshToken);

      return res.json({
        success: true,
        message: 'Logout successful',
      });
    } catch (error: any) {
      logger.error('Logout error:', error);

      return res.status(500).json({
        success: false,
        error: 'Logout failed',
        message: error.message || 'An error occurred during logout',
      });
    }
  }
}

export const authController = new AuthController();
