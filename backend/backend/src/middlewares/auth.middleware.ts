import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { supabase } from '../config/database';
import env from '../config/env';
import { ResponseHandler } from '../utils/response';
import logger from '../utils/logger';

export interface AuthRequest extends Request {
  user?: {
    id: string;
    email: string;
    role?: string;
  };
}

/**
 * JWT 토큰 검증 미들웨어
 */
export async function authenticateToken(
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const authHeader = req.headers.authorization;
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) {
      ResponseHandler.unauthorized(res, '인증 토큰이 필요합니다');
      return;
    }

    // JWT 토큰 검증
    const decoded = jwt.verify(token, env.JWT_SECRET) as { 
      id: string; 
      email: string;
      role?: string;
    };

    // Supabase에서 사용자 확인
    const { data: user, error } = await supabase
      .from('users')
      .select('id, email, role')
      .eq('id', decoded.id)
      .single();

    if (error || !user) {
      ResponseHandler.unauthorized(res, '유효하지 않은 토큰입니다');
      return;
    }

    req.user = {
      id: user.id,
      email: user.email,
      role: user.role,
    };

    next();
  } catch (error) {
    if (error instanceof jwt.TokenExpiredError) {
      ResponseHandler.error(res, 'AUTH_EXPIRED_TOKEN', '만료된 토큰입니다', 401);
    } else if (error instanceof jwt.JsonWebTokenError) {
      ResponseHandler.error(res, 'AUTH_INVALID_TOKEN', '유효하지 않은 토큰입니다', 401);
    } else {
      logger.error('Token verification error:', error);
      ResponseHandler.serverError(res);
    }
  }
}

/**
 * 관리자 권한 확인 미들웨어
 */
export function requireAdmin(
  req: AuthRequest,
  res: Response,
  next: NextFunction
): void {
  if (!req.user || req.user.role !== 'admin') {
    ResponseHandler.forbidden(res, '관리자 권한이 필요합니다');
    return;
  }
  next();
}

/**
 * Supabase Auth 토큰 검증 미들웨어 (대안)
 */
export async function authenticateSupabase(
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const authHeader = req.headers.authorization;
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) {
      ResponseHandler.unauthorized(res, '인증 토큰이 필요합니다');
      return;
    }

    // Supabase Auth로 토큰 검증
    const { data: { user }, error } = await supabase.auth.getUser(token);

    if (error || !user) {
      ResponseHandler.unauthorized(res, '유효하지 않은 토큰입니다');
      return;
    }

    req.user = {
      id: user.id,
      email: user.email || '',
    };

    next();
  } catch (error) {
    logger.error('Supabase auth verification error:', error);
    ResponseHandler.serverError(res);
  }
}
