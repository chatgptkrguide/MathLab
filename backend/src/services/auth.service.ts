import bcrypt from 'bcryptjs';
import { v4 as uuidv4 } from 'uuid';
import { OAuth2Client } from 'google-auth-library';
import axios from 'axios';
import { db } from '../config/database';
import { redis } from '../config/redis';
import { generateAccessToken, generateRefreshToken } from '../utils/jwt';
import { logger } from '../utils/logger';
import { User, CreateUserDTO, LoginDTO, SocialLoginDTO, AuthResponse } from '../models/user';

const BCRYPT_ROUNDS = parseInt(process.env.BCRYPT_ROUNDS || '12');
const GOOGLE_CLIENT_ID = process.env.GOOGLE_CLIENT_ID;

export class AuthService {
  /**
   * 이메일/비밀번호로 회원가입
   */
  async signUpWithEmail(data: CreateUserDTO): Promise<AuthResponse> {
    try {
      // 이메일 중복 확인
      const existingUser = await this.findUserByEmail(data.email);
      if (existingUser) {
        throw new Error('Email already exists');
      }

      // 비밀번호 해싱
      if (!data.password) {
        throw new Error('Password is required for email signup');
      }
      const password_hash = await bcrypt.hash(data.password, BCRYPT_ROUNDS);

      // 사용자 생성
      const result = await db.query(
        `INSERT INTO users (email, display_name, password_hash, auth_provider, current_grade)
         VALUES ($1, $2, $3, $4, $5)
         RETURNING id, email, display_name, auth_provider, level, xp, streak_days, hearts,
                   current_grade, avatar_url, created_at, updated_at, last_login_at, is_active`,
        [data.email, data.display_name, password_hash, 'email', data.current_grade || '중1']
      );

      const user = result.rows[0];

      // 첫 레슨 언락
      await this.unlockFirstLesson(user.id);

      // 토큰 생성
      const tokens = await this.generateTokens(user);

      return {
        user,
        ...tokens,
      };
    } catch (error) {
      logger.error('SignUp error:', error);
      throw error;
    }
  }

  /**
   * 이메일/비밀번호로 로그인
   */
  async signInWithEmail(data: LoginDTO): Promise<AuthResponse> {
    try {
      // 사용자 조회
      const result = await db.query(
        `SELECT id, email, display_name, password_hash, auth_provider, level, xp, streak_days, hearts,
                current_grade, avatar_url, created_at, updated_at, last_login_at, is_active
         FROM users
         WHERE email = $1 AND auth_provider = 'email'`,
        [data.email]
      );

      if (result.rows.length === 0) {
        throw new Error('Invalid credentials');
      }

      const user = result.rows[0];

      // 비밀번호 검증
      const isPasswordValid = await bcrypt.compare(data.password, user.password_hash);
      if (!isPasswordValid) {
        throw new Error('Invalid credentials');
      }

      // 마지막 로그인 시간 업데이트
      await db.query('UPDATE users SET last_login_at = NOW() WHERE id = $1', [user.id]);

      // 스트릭 업데이트
      await this.updateStreak(user.id);

      // password_hash 제거
      delete user.password_hash;

      // 토큰 생성
      const tokens = await this.generateTokens(user);

      return {
        user,
        ...tokens,
      };
    } catch (error) {
      logger.error('SignIn error:', error);
      throw error;
    }
  }

  /**
   * Google 소셜 로그인
   */
  async signInWithGoogle(idToken: string): Promise<AuthResponse> {
    try {
      if (!GOOGLE_CLIENT_ID) {
        throw new Error('Google Client ID not configured');
      }

      // Google ID Token 검증
      const client = new OAuth2Client(GOOGLE_CLIENT_ID);
      const ticket = await client.verifyIdToken({
        idToken,
        audience: GOOGLE_CLIENT_ID,
      });

      const payload = ticket.getPayload();
      if (!payload) {
        throw new Error('Invalid Google token');
      }

      const { sub: googleUserId, email, name, picture } = payload;

      if (!email) {
        throw new Error('Email not provided by Google');
      }

      // 기존 사용자 확인
      let user = await this.findUserByAuthProvider('google', googleUserId);

      if (!user) {
        // 이메일로 기존 사용자 확인
        user = await this.findUserByEmail(email);

        if (user) {
          // 기존 이메일 사용자를 Google 로그인으로 연결
          await db.query(
            `UPDATE users
             SET auth_provider = 'google', auth_provider_id = $1, avatar_url = COALESCE(avatar_url, $2)
             WHERE id = $3`,
            [googleUserId, picture, user.id]
          );
        } else {
          // 새 사용자 생성
          const result = await db.query(
            `INSERT INTO users (email, display_name, auth_provider, auth_provider_id, avatar_url, current_grade)
             VALUES ($1, $2, 'google', $3, $4, '중1')
             RETURNING id, email, display_name, auth_provider, level, xp, streak_days, hearts,
                       current_grade, avatar_url, created_at, updated_at, last_login_at, is_active`,
            [email, name || email.split('@')[0], googleUserId, picture]
          );

          user = result.rows[0];

          // 첫 레슨 언락
          await this.unlockFirstLesson(user.id);
        }
      }

      // 마지막 로그인 업데이트
      await db.query('UPDATE users SET last_login_at = NOW() WHERE id = $1', [user.id]);
      await this.updateStreak(user.id);

      // 토큰 생성
      const tokens = await this.generateTokens(user);

      return {
        user,
        ...tokens,
      };
    } catch (error) {
      logger.error('Google SignIn error:', error);
      throw error;
    }
  }

  /**
   * Kakao 소셜 로그인
   */
  async signInWithKakao(accessToken: string): Promise<AuthResponse> {
    try {
      // Kakao 사용자 정보 조회
      const response = await axios.get('https://kapi.kakao.com/v2/user/me', {
        headers: {
          Authorization: `Bearer ${accessToken}`,
        },
      });

      const { id: kakaoUserId, kakao_account } = response.data;
      const email = kakao_account?.email;
      const profile = kakao_account?.profile;
      const displayName = profile?.nickname || `kakao_${kakaoUserId}`;
      const avatarUrl = profile?.profile_image_url;

      // 기존 사용자 확인
      let user = await this.findUserByAuthProvider('kakao', kakaoUserId.toString());

      if (!user) {
        // 이메일로 기존 사용자 확인 (이메일이 있는 경우)
        if (email) {
          user = await this.findUserByEmail(email);
        }

        if (user) {
          // 기존 사용자를 Kakao 로그인으로 연결
          await db.query(
            `UPDATE users
             SET auth_provider = 'kakao', auth_provider_id = $1, avatar_url = COALESCE(avatar_url, $2)
             WHERE id = $3`,
            [kakaoUserId.toString(), avatarUrl, user.id]
          );
        } else {
          // 새 사용자 생성
          const userEmail = email || `kakao_${kakaoUserId}@mathlab.app`;
          const result = await db.query(
            `INSERT INTO users (email, display_name, auth_provider, auth_provider_id, avatar_url, current_grade)
             VALUES ($1, $2, 'kakao', $3, $4, '중1')
             RETURNING id, email, display_name, auth_provider, level, xp, streak_days, hearts,
                       current_grade, avatar_url, created_at, updated_at, last_login_at, is_active`,
            [userEmail, displayName, kakaoUserId.toString(), avatarUrl]
          );

          user = result.rows[0];

          // 첫 레슨 언락
          await this.unlockFirstLesson(user.id);
        }
      }

      // 마지막 로그인 업데이트
      await db.query('UPDATE users SET last_login_at = NOW() WHERE id = $1', [user.id]);
      await this.updateStreak(user.id);

      // 토큰 생성
      const tokens = await this.generateTokens(user);

      return {
        user,
        ...tokens,
      };
    } catch (error) {
      logger.error('Kakao SignIn error:', error);
      throw error;
    }
  }

  /**
   * 리프레시 토큰으로 액세스 토큰 갱신
   */
  async refreshAccessToken(refreshToken: string): Promise<{ access_token: string }> {
    try {
      // Redis에서 리프레시 토큰 검증
      const tokenData = await redis.get(`refresh_token:${refreshToken}`);
      if (!tokenData) {
        throw new Error('Invalid refresh token');
      }

      const { userId } = JSON.parse(tokenData);

      // 사용자 조회
      const user = await this.findUserById(userId);
      if (!user) {
        throw new Error('User not found');
      }

      // 새 액세스 토큰 생성
      const accessToken = generateAccessToken({
        userId: user.id,
        email: user.email,
      });

      return { access_token: accessToken };
    } catch (error) {
      logger.error('Refresh token error:', error);
      throw error;
    }
  }

  /**
   * 로그아웃
   */
  async signOut(refreshToken: string): Promise<void> {
    try {
      // Redis에서 리프레시 토큰 삭제
      await redis.del(`refresh_token:${refreshToken}`);
    } catch (error) {
      logger.error('SignOut error:', error);
      throw error;
    }
  }

  // ==================== Helper Methods ====================

  /**
   * 이메일로 사용자 찾기
   */
  private async findUserByEmail(email: string): Promise<User | null> {
    const result = await db.query(
      `SELECT id, email, display_name, auth_provider, auth_provider_id, level, xp, streak_days, hearts,
              current_grade, avatar_url, created_at, updated_at, last_login_at, is_active
       FROM users
       WHERE email = $1`,
      [email]
    );

    return result.rows.length > 0 ? result.rows[0] : null;
  }

  /**
   * ID로 사용자 찾기
   */
  private async findUserById(userId: string): Promise<User | null> {
    const result = await db.query(
      `SELECT id, email, display_name, auth_provider, auth_provider_id, level, xp, streak_days, hearts,
              current_grade, avatar_url, created_at, updated_at, last_login_at, is_active
       FROM users
       WHERE id = $1`,
      [userId]
    );

    return result.rows.length > 0 ? result.rows[0] : null;
  }

  /**
   * 소셜 로그인 Provider로 사용자 찾기
   */
  private async findUserByAuthProvider(provider: string, providerId: string): Promise<User | null> {
    const result = await db.query(
      `SELECT id, email, display_name, auth_provider, auth_provider_id, level, xp, streak_days, hearts,
              current_grade, avatar_url, created_at, updated_at, last_login_at, is_active
       FROM users
       WHERE auth_provider = $1 AND auth_provider_id = $2`,
      [provider, providerId]
    );

    return result.rows.length > 0 ? result.rows[0] : null;
  }

  /**
   * JWT 토큰 생성
   */
  private async generateTokens(user: User): Promise<{ access_token: string; refresh_token: string }> {
    const accessToken = generateAccessToken({
      userId: user.id,
      email: user.email,
    });

    const refreshTokenId = uuidv4();
    const refreshToken = generateRefreshToken({
      userId: user.id,
      tokenId: refreshTokenId,
    });

    // Redis에 리프레시 토큰 저장 (7일)
    await redis.set(
      `refresh_token:${refreshToken}`,
      JSON.stringify({ userId: user.id, tokenId: refreshTokenId }),
      60 * 60 * 24 * 7 // 7 days
    );

    return {
      access_token: accessToken,
      refresh_token: refreshToken,
    };
  }

  /**
   * 첫 레슨 언락
   */
  private async unlockFirstLesson(userId: string): Promise<void> {
    try {
      await db.query(
        `INSERT INTO user_lesson_progress (user_id, lesson_id, is_unlocked)
         VALUES ($1, 'lesson001', true)
         ON CONFLICT (user_id, lesson_id) DO NOTHING`,
        [userId]
      );
    } catch (error) {
      logger.error('Error unlocking first lesson:', error);
    }
  }

  /**
   * 스트릭 업데이트
   */
  private async updateStreak(userId: string): Promise<void> {
    try {
      const result = await db.query('SELECT last_streak_date, streak_days FROM users WHERE id = $1', [userId]);

      if (result.rows.length === 0) return;

      const { last_streak_date, streak_days } = result.rows[0];
      const today = new Date().toISOString().split('T')[0];

      if (!last_streak_date || last_streak_date !== today) {
        const yesterday = new Date(Date.now() - 86400000).toISOString().split('T')[0];

        if (last_streak_date === yesterday) {
          // 연속 학습
          await db.query(
            'UPDATE users SET streak_days = streak_days + 1, last_streak_date = CURRENT_DATE WHERE id = $1',
            [userId]
          );
        } else {
          // 스트릭 리셋
          await db.query('UPDATE users SET streak_days = 1, last_streak_date = CURRENT_DATE WHERE id = $1', [userId]);
        }
      }
    } catch (error) {
      logger.error('Error updating streak:', error);
    }
  }
}

export const authService = new AuthService();
