/**
 * Firebase Cloud Functions Entry Point
 * 프리미엄 구독 시스템 & 사용자 라이프사이클 Cloud Functions
 */

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { Response } from 'express';
import { createLogger } from './utils/logger';
import { formatErrorResponse } from './utils/error-handler';
import { verifyAuth, AuthenticatedRequest, verifyUserMatch } from './utils/auth-middleware';

// Firebase Admin 초기화
admin.initializeApp();

const logger = createLogger('CloudFunctions');

// ==================== CORS & Auth Helpers ====================

const ALLOWED_ORIGINS = [
  'https://gomath-mathlab.web.app',
  'https://gomath-mathlab.firebaseapp.com',
];

function setCorsHeaders(res: Response, method: string = 'POST'): void {
  // In production, restrict to known origins
  const origin = ALLOWED_ORIGINS[0];
  res.set('Access-Control-Allow-Origin', origin);
  res.set('Access-Control-Allow-Methods', method);
  res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  res.set('Access-Control-Allow-Credentials', 'true');
}

function handlePreflight(req: AuthenticatedRequest, res: Response): boolean {
  if (req.method === 'OPTIONS') {
    setCorsHeaders(res, 'POST, GET, OPTIONS');
    res.status(204).send('');
    return true;
  }
  return false;
}

// ==================== Firestore Triggers (TODO: implement) ====================

// TODO: Uncomment when trigger modules are created
// export { onUserCreated, onUserXPUpdated } from './triggers/user-triggers';
// export { weeklyLeagueReset, onLeagueParticipantUpdated, dailyLeagueReminder } from './triggers/league-triggers';

/**
 * iOS 영수증 검증 HTTP Function
 *
 * Request Body:
 * {
 *   userId: string;
 *   receiptData: string; // Base64 encoded
 *   transactionId: string;
 *   productId: string;
 * }
 */
export const verifyIOSReceiptFunction = functions
  .region('asia-northeast3')
  .https.onRequest(async (req: AuthenticatedRequest, res) => {
    setCorsHeaders(res);
    if (handlePreflight(req, res)) return;

    if (req.method !== 'POST') {
      res.status(405).json({ success: false, error: { code: 'METHOD_NOT_ALLOWED', message: 'Only POST requests are allowed' } });
      return;
    }

    // Auth verification
    const uid = await verifyAuth(req, res);
    if (!uid) return;
    if (!verifyUserMatch(uid, req.body.userId, res)) return;

    try {
      logger.info('iOS receipt verification request received', {
        userId: req.body.userId,
        productId: req.body.productId,
      });

      // TODO: Implement verifyIOSReceipt service
      res.status(501).json({ success: false, error: { code: 'NOT_IMPLEMENTED', message: 'iOS receipt verification not yet implemented' } });
    } catch (error) {
      logger.error('iOS receipt verification failed', error as Error);
      const errorResponse = formatErrorResponse(error as Error);
      res.status(errorResponse.error.statusCode).json(errorResponse);
    }
  });

/**
 * Android 영수증 검증 HTTP Function
 *
 * Request Body:
 * {
 *   userId: string;
 *   purchaseToken: string;
 *   productId: string;
 *   packageName: string;
 * }
 */
export const verifyAndroidReceiptFunction = functions
  .region('asia-northeast3')
  .https.onRequest(async (req: AuthenticatedRequest, res) => {
    setCorsHeaders(res);
    if (handlePreflight(req, res)) return;

    if (req.method !== 'POST') {
      res.status(405).json({ success: false, error: { code: 'METHOD_NOT_ALLOWED', message: 'Only POST requests are allowed' } });
      return;
    }

    // Auth verification
    const uid = await verifyAuth(req, res);
    if (!uid) return;
    if (!verifyUserMatch(uid, req.body.userId, res)) return;

    try {
      logger.info('Android receipt verification request received', {
        userId: req.body.userId,
        productId: req.body.productId,
      });

      // TODO: Implement verifyAndroidReceipt service
      res.status(501).json({ success: false, error: { code: 'NOT_IMPLEMENTED', message: 'Android receipt verification not yet implemented' } });
    } catch (error) {
      logger.error('Android receipt verification failed', error as Error);
      const errorResponse = formatErrorResponse(error as Error);
      res.status(errorResponse.error.statusCode).json(errorResponse);
    }
  });

/**
 * iOS Server-to-Server Notification Webhook
 *
 * Apple이 구독 상태 변경 시 호출하는 웹훅
 */
// Webhooks: No user auth (called by Apple/Google servers)
export const iosWebhook = functions
  .region('asia-northeast3')
  .https.onRequest(async (req, res) => {
    if (req.method !== 'POST') {
      res.status(405).json({ success: false, error: 'Only POST requests are allowed' });
      return;
    }

    try {
      logger.info('iOS webhook received');

      // TODO: Implement processIOSWebhook + Apple signature verification
      res.status(501).json({ success: false, error: 'iOS webhook not yet implemented' });
    } catch (error) {
      logger.error('iOS webhook processing failed', error as Error);
      const errorResponse = formatErrorResponse(error as Error);
      res.status(errorResponse.error.statusCode).json(errorResponse);
    }
  });

/**
 * Android Real-time Developer Notifications Webhook
 *
 * Google Cloud Pub/Sub를 통해 호출되는 웹훅
 */
export const androidWebhook = functions
  .region('asia-northeast3')
  .pubsub.topic('android-subscription-notifications')
  .onPublish(async (message) => {
    try {
      logger.info('Android webhook received via Pub/Sub');

      // TODO: Implement processAndroidWebhook
      logger.warn('Android webhook processing not yet implemented');
    } catch (error) {
      logger.error('Android webhook processing failed', error as Error);
      throw error;
    }
  });

/**
 * 구독 상태 동기화 Scheduled Function
 *
 * 매일 00:00 KST (15:00 UTC)에 실행
 */
export const syncSubscriptions = functions
  .region('asia-northeast3')
  .pubsub.schedule('0 15 * * *')
  .timeZone('Asia/Seoul')
  .onRun(async () => {
    try {
      logger.info('Starting scheduled subscription sync');

      // TODO: Implement syncAllSubscriptions
      logger.warn('Subscription sync not yet implemented');

      return null;
    } catch (error) {
      logger.error('Scheduled subscription sync failed', error as Error);
      throw error;
    }
  });

/**
 * 만료된 구독 정리 Scheduled Function
 *
 * 매일 01:00 KST (16:00 UTC)에 실행
 */
export const cleanupExpired = functions
  .region('asia-northeast3')
  .pubsub.schedule('0 16 * * *')
  .timeZone('Asia/Seoul')
  .onRun(async () => {
    try {
      logger.info('Starting expired subscription cleanup');

      // TODO: Implement cleanupExpiredSubscriptions
      logger.warn('Expired subscription cleanup not yet implemented');

      return null;
    } catch (error) {
      logger.error('Expired subscription cleanup failed', error as Error);
      throw error;
    }
  });

/**
 * 구독 통계 조회 HTTP Function
 *
 * 관리자용 구독 통계 API
 */
// Admin-only: Subscription stats (requires auth)
export const subscriptionStats = functions
  .region('asia-northeast3')
  .https.onRequest(async (req: AuthenticatedRequest, res) => {
    setCorsHeaders(res, 'GET');
    if (handlePreflight(req, res)) return;

    if (req.method !== 'GET') {
      res.status(405).json({ success: false, error: 'Only GET requests are allowed' });
      return;
    }

    // Auth verification (admin check)
    const uid = await verifyAuth(req, res);
    if (!uid) return;

    try {
      logger.info('Subscription stats request received', { requestedBy: uid });

      // TODO: Implement getSubscriptionStats + admin role check
      res.status(501).json({ success: false, error: 'Subscription stats not yet implemented' });
    } catch (error) {
      logger.error('Failed to get subscription stats', error as Error);
      const errorResponse = formatErrorResponse(error as Error);
      res.status(errorResponse.error.statusCode).json(errorResponse);
    }
  });

/**
 * FCM 토큰 등록 HTTP Function
 *
 * Request Body:
 * {
 *   userId: string;
 *   fcmToken: string;
 *   platform: 'ios' | 'android' | 'web';
 * }
 */
export const registerFCMTokenFunction = functions
  .region('asia-northeast3')
  .https.onRequest(async (req: AuthenticatedRequest, res) => {
    setCorsHeaders(res);
    if (handlePreflight(req, res)) return;

    if (req.method !== 'POST') {
      res.status(405).json({ success: false, error: 'Only POST requests are allowed' });
      return;
    }

    // Auth verification
    const uid = await verifyAuth(req, res);
    if (!uid) return;

    try {
      const { fcmToken, platform } = req.body;

      if (!fcmToken || !platform) {
        res.status(400).json({ success: false, error: 'Missing required fields: fcmToken, platform' });
        return;
      }

      // Store FCM token in Firestore under user's document
      await admin.firestore().collection('users').doc(uid).collection('fcmTokens').doc(fcmToken).set({
        token: fcmToken,
        platform,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      res.status(200).json({ success: true, message: 'FCM token registered successfully' });
    } catch (error) {
      logger.error('Failed to register FCM token', error as Error);
      const errorResponse = formatErrorResponse(error as Error);
      res.status(errorResponse.error.statusCode).json(errorResponse);
    }
  });

/**
 * FCM 토큰 삭제 HTTP Function
 *
 * Request Body:
 * {
 *   userId: string;
 *   fcmToken: string;
 * }
 */
export const removeFCMTokenFunction = functions
  .region('asia-northeast3')
  .https.onRequest(async (req: AuthenticatedRequest, res) => {
    setCorsHeaders(res);
    if (handlePreflight(req, res)) return;

    if (req.method !== 'POST') {
      res.status(405).json({ success: false, error: 'Only POST requests are allowed' });
      return;
    }

    // Auth verification
    const uid = await verifyAuth(req, res);
    if (!uid) return;

    try {
      const { fcmToken } = req.body;

      if (!fcmToken) {
        res.status(400).json({ success: false, error: 'Missing required field: fcmToken' });
        return;
      }

      // Remove FCM token from Firestore
      await admin.firestore().collection('users').doc(uid).collection('fcmTokens').doc(fcmToken).delete();

      res.status(200).json({ success: true, message: 'FCM token removed successfully' });
    } catch (error) {
      logger.error('Failed to remove FCM token', error as Error);
      const errorResponse = formatErrorResponse(error as Error);
      res.status(errorResponse.error.statusCode).json(errorResponse);
    }
  });

/**
 * 테스트용 푸시 알림 전송 HTTP Function
 *
 * Request Body:
 * {
 *   userId: string;
 *   title: string;
 *   body: string;
 *   type?: NotificationType;
 *   data?: Record<string, string>;
 * }
 */
// Admin-only: Test notification (requires auth)
export const sendTestNotification = functions
  .region('asia-northeast3')
  .https.onRequest(async (req: AuthenticatedRequest, res) => {
    setCorsHeaders(res);
    if (handlePreflight(req, res)) return;

    if (req.method !== 'POST') {
      res.status(405).json({ success: false, error: 'Only POST requests are allowed' });
      return;
    }

    // Auth verification
    const uid = await verifyAuth(req, res);
    if (!uid) return;

    try {
      const { userId, title, body, data } = req.body;

      if (!userId || !title || !body) {
        res.status(400).json({ success: false, error: 'Missing required fields: userId, title, body' });
        return;
      }

      // Get user's FCM tokens
      const tokensSnapshot = await admin.firestore()
        .collection('users').doc(userId)
        .collection('fcmTokens').get();

      if (tokensSnapshot.empty) {
        res.status(200).json({ success: false, message: 'No FCM tokens found for user' });
        return;
      }

      const tokens = tokensSnapshot.docs.map(doc => doc.data().token);
      const message: admin.messaging.MulticastMessage = {
        tokens,
        notification: { title, body },
        data: data || {},
      };

      const result = await admin.messaging().sendEachForMulticast(message);

      res.status(200).json({
        success: true,
        message: `Sent to ${result.successCount}/${tokens.length} devices`,
      });
    } catch (error) {
      logger.error('Failed to send test notification', error as Error);
      const errorResponse = formatErrorResponse(error as Error);
      res.status(errorResponse.error.statusCode).json(errorResponse);
    }
  });

/**
 * Health Check Function
 *
 * Cloud Functions 상태 확인용
 */
export const healthCheck = functions
  .region('asia-northeast3') // Seoul
  .https.onRequest((req, res) => {
    res.status(200).json({
      status: 'healthy',
      timestamp: new Date().toISOString(),
      region: 'asia-northeast3',
      functions: [
        // Subscription Functions
        'verifyIOSReceiptFunction',
        'verifyAndroidReceiptFunction',
        'iosWebhook',
        'androidWebhook',
        'syncSubscriptions',
        'cleanupExpired',
        'subscriptionStats',
        // User Triggers
        'onUserCreated',
        'onUserXPUpdated',
        // League Triggers
        'weeklyLeagueReset',
        'onLeagueParticipantUpdated',
        'dailyLeagueReminder',
        // FCM Functions
        'registerFCMTokenFunction',
        'removeFCMTokenFunction',
        'sendTestNotification',
      ]
    });
  });
