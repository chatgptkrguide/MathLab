/**
 * Firebase Auth verification middleware for HTTP Cloud Functions
 */

import * as admin from 'firebase-admin';
import { Request, Response } from 'express';
import { createLogger } from './logger';

const logger = createLogger('AuthMiddleware');

export interface AuthenticatedRequest extends Request {
  uid?: string;
  email?: string;
}

/**
 * Verify Firebase Auth token from Authorization header
 * Returns the decoded token's UID, or sends 401 and returns null
 */
export async function verifyAuth(
  req: AuthenticatedRequest,
  res: Response
): Promise<string | null> {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    logger.warn('Missing or invalid Authorization header');
    res.status(401).json({
      success: false,
      error: {
        code: 'UNAUTHORIZED',
        message: 'Missing or invalid Authorization header. Use: Bearer <Firebase ID Token>',
      },
    });
    return null;
  }

  const idToken = authHeader.split('Bearer ')[1];

  try {
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    req.uid = decodedToken.uid;
    req.email = decodedToken.email;

    logger.info('Auth token verified', {
      uid: decodedToken.uid,
      email: decodedToken.email,
    });

    return decodedToken.uid;
  } catch (error) {
    logger.error('Auth token verification failed', error as Error);
    res.status(401).json({
      success: false,
      error: {
        code: 'UNAUTHORIZED',
        message: 'Invalid or expired authentication token',
      },
    });
    return null;
  }
}

/**
 * Verify that the authenticated user matches the userId in the request body
 */
export function verifyUserMatch(
  uid: string,
  requestUserId: string,
  res: Response
): boolean {
  if (uid !== requestUserId) {
    logger.warn('User ID mismatch', {
      tokenUid: uid,
      requestUserId,
    });
    res.status(403).json({
      success: false,
      error: {
        code: 'FORBIDDEN',
        message: 'You can only access your own data',
      },
    });
    return false;
  }
  return true;
}
