/**
 * Firebase Cloud Functions Entry Point
 * 프리미엄 구독 시스템 & 사용자 라이프사이클 Cloud Functions
 */

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { createLogger } from './utils/logger';
import { formatErrorResponse } from './utils/error-handler';
import { verifyIOSReceipt } from './services/ios-verification';
import { verifyAndroidReceipt } from './services/android-verification';
import {
  syncAllSubscriptions,
  cleanupExpiredSubscriptions,
  getSubscriptionStats
} from './services/subscription-sync';
import { processIOSWebhook } from './webhooks/ios-webhook';
import { processAndroidWebhook } from './webhooks/android-webhook';
import {
  IOSReceiptVerificationRequest,
  AndroidReceiptVerificationRequest
} from './types/subscription';

// Firebase Admin 초기화
admin.initializeApp();

const logger = createLogger('CloudFunctions');

// ==================== Firestore Triggers ====================

/**
 * User Lifecycle Triggers
 */
export { onUserCreated, onUserXPUpdated } from './triggers/user-triggers';

/**
 * League Management Triggers
 */
export {
  weeklyLeagueReset,
  onLeagueParticipantUpdated,
  dailyLeagueReminder
} from './triggers/league-triggers';

// ==================== FCM Push Notification Functions ====================

import {
  registerFCMToken,
  removeFCMToken,
  sendNotificationToUser,
  NotificationType,
  NotificationPayload,
} from './services/fcm-service';

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
  .region('asia-northeast3') // Seoul
  .https.onRequest(async (req, res) => {
    // CORS 설정
    res.set('Access-Control-Allow-Origin', '*');
    res.set('Access-Control-Allow-Methods', 'POST');
    res.set('Access-Control-Allow-Headers', 'Content-Type');

    if (req.method === 'OPTIONS') {
      res.status(204).send('');
      return;
    }

    if (req.method !== 'POST') {
      res.status(405).json({
        success: false,
        error: {
          code: 'METHOD_NOT_ALLOWED',
          message: 'Only POST requests are allowed'
        }
      });
      return;
    }

    try {
      logger.info('iOS receipt verification request received', {
        userId: req.body.userId,
        productId: req.body.productId
      });

      const request: IOSReceiptVerificationRequest = req.body;
      const result = await verifyIOSReceipt(request);

      res.status(200).json(result);

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
  .region('asia-northeast3') // Seoul
  .https.onRequest(async (req, res) => {
    // CORS 설정
    res.set('Access-Control-Allow-Origin', '*');
    res.set('Access-Control-Allow-Methods', 'POST');
    res.set('Access-Control-Allow-Headers', 'Content-Type');

    if (req.method === 'OPTIONS') {
      res.status(204).send('');
      return;
    }

    if (req.method !== 'POST') {
      res.status(405).json({
        success: false,
        error: {
          code: 'METHOD_NOT_ALLOWED',
          message: 'Only POST requests are allowed'
        }
      });
      return;
    }

    try {
      logger.info('Android receipt verification request received', {
        userId: req.body.userId,
        productId: req.body.productId
      });

      const request: AndroidReceiptVerificationRequest = req.body;
      const result = await verifyAndroidReceipt(request);

      res.status(200).json(result);

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
export const iosWebhook = functions
  .region('asia-northeast3') // Seoul
  .https.onRequest(async (req, res) => {
    if (req.method !== 'POST') {
      res.status(405).json({
        success: false,
        error: 'Only POST requests are allowed'
      });
      return;
    }

    try {
      logger.info('iOS webhook received');

      const payload = req.body;
      const result = await processIOSWebhook(payload);

      res.status(200).json(result);

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
  .region('asia-northeast3') // Seoul
  .pubsub.topic('android-subscription-notifications')
  .onPublish(async (message) => {
    try {
      logger.info('Android webhook received via Pub/Sub');

      const result = await processAndroidWebhook(message);

      logger.info('Android webhook processed', {
        success: result.success,
        action: result.action
      });

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
  .region('asia-northeast3') // Seoul
  .pubsub.schedule('0 15 * * *') // 매일 15:00 UTC (00:00 KST)
  .timeZone('Asia/Seoul')
  .onRun(async (context) => {
    try {
      logger.info('Starting scheduled subscription sync');

      const result = await syncAllSubscriptions();

      logger.info('Scheduled subscription sync completed', {
        totalProcessed: result.totalProcessed,
        successful: result.successful,
        failed: result.failed
      });

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
  .region('asia-northeast3') // Seoul
  .pubsub.schedule('0 16 * * *') // 매일 16:00 UTC (01:00 KST)
  .timeZone('Asia/Seoul')
  .onRun(async (context) => {
    try {
      logger.info('Starting expired subscription cleanup');

      const result = await cleanupExpiredSubscriptions();

      logger.info('Expired subscription cleanup completed', {
        totalProcessed: result.totalProcessed,
        updated: result.updated
      });

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
export const subscriptionStats = functions
  .region('asia-northeast3') // Seoul
  .https.onRequest(async (req, res) => {
    // CORS 설정
    res.set('Access-Control-Allow-Origin', '*');
    res.set('Access-Control-Allow-Methods', 'GET');
    res.set('Access-Control-Allow-Headers', 'Content-Type');

    if (req.method === 'OPTIONS') {
      res.status(204).send('');
      return;
    }

    if (req.method !== 'GET') {
      res.status(405).json({
        success: false,
        error: 'Only GET requests are allowed'
      });
      return;
    }

    try {
      logger.info('Subscription stats request received');

      const stats = await getSubscriptionStats();

      res.status(200).json({
        success: true,
        stats
      });

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
  .https.onRequest(async (req, res) => {
    // CORS 설정
    res.set('Access-Control-Allow-Origin', '*');
    res.set('Access-Control-Allow-Methods', 'POST');
    res.set('Access-Control-Allow-Headers', 'Content-Type');

    if (req.method === 'OPTIONS') {
      res.status(204).send('');
      return;
    }

    if (req.method !== 'POST') {
      res.status(405).json({
        success: false,
        error: 'Only POST requests are allowed',
      });
      return;
    }

    try {
      const { userId, fcmToken, platform } = req.body;

      if (!userId || !fcmToken || !platform) {
        res.status(400).json({
          success: false,
          error: 'Missing required fields: userId, fcmToken, platform',
        });
        return;
      }

      await registerFCMToken(userId, fcmToken, platform);

      res.status(200).json({
        success: true,
        message: 'FCM token registered successfully',
      });
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
  .https.onRequest(async (req, res) => {
    // CORS 설정
    res.set('Access-Control-Allow-Origin', '*');
    res.set('Access-Control-Allow-Methods', 'POST');
    res.set('Access-Control-Allow-Headers', 'Content-Type');

    if (req.method === 'OPTIONS') {
      res.status(204).send('');
      return;
    }

    if (req.method !== 'POST') {
      res.status(405).json({
        success: false,
        error: 'Only POST requests are allowed',
      });
      return;
    }

    try {
      const { userId, fcmToken } = req.body;

      if (!userId || !fcmToken) {
        res.status(400).json({
          success: false,
          error: 'Missing required fields: userId, fcmToken',
        });
        return;
      }

      await removeFCMToken(userId, fcmToken);

      res.status(200).json({
        success: true,
        message: 'FCM token removed successfully',
      });
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
export const sendTestNotification = functions
  .region('asia-northeast3')
  .https.onRequest(async (req, res) => {
    // CORS 설정
    res.set('Access-Control-Allow-Origin', '*');
    res.set('Access-Control-Allow-Methods', 'POST');
    res.set('Access-Control-Allow-Headers', 'Content-Type');

    if (req.method === 'OPTIONS') {
      res.status(204).send('');
      return;
    }

    if (req.method !== 'POST') {
      res.status(405).json({
        success: false,
        error: 'Only POST requests are allowed',
      });
      return;
    }

    try {
      const { userId, title, body, type, data } = req.body;

      if (!userId || !title || !body) {
        res.status(400).json({
          success: false,
          error: 'Missing required fields: userId, title, body',
        });
        return;
      }

      const payload: NotificationPayload = {
        type: type || NotificationType.WELCOME,
        title: title,
        body: body,
        data: data,
      };

      const success = await sendNotificationToUser(userId, payload);

      res.status(200).json({
        success: success,
        message: success ? 'Test notification sent' : 'Failed to send notification',
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
