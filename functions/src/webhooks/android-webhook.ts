/**
 * Android Real-time Developer Notifications (RTDN) Webhook 핸들러
 */

import * as admin from 'firebase-admin';
import { createLogger } from '../utils/logger';
import { logError } from '../utils/error-handler';
import { verifyAndroidReceipt } from '../services/android-verification';
import { decodePubSubMessage, interpretNotificationType } from '../config/android-config';
import {
  AndroidWebhookPayload,
  AndroidNotificationType,
  WebhookProcessResult
} from '../types/webhook';
import {
  SubscriptionStatus
} from '../types/subscription';

const logger = createLogger('AndroidWebhook');

/**
 * Android Webhook 처리 (Pub/Sub 메시지)
 */
export async function processAndroidWebhook(
  pubsubMessage: any
): Promise<WebhookProcessResult> {
  const result: WebhookProcessResult = {
    success: false,
    notificationType: 'unknown',
    action: 'none'
  };

  try {
    // Pub/Sub 메시지 디코딩
    const payload: AndroidWebhookPayload = decodePubSubMessage(pubsubMessage);

    logger.info('Processing Android webhook notification', {
      version: payload.version,
      packageName: payload.packageName,
      eventTimeMillis: payload.eventTimeMillis
    });

    if (!payload.subscriptionNotification) {
      logger.warn('No subscription notification in payload');
      return result;
    }

    const notification = payload.subscriptionNotification;
    const notificationInfo = interpretNotificationType(notification.notificationType);

    result.notificationType = notificationInfo.type;
    result.action = notificationInfo.action;

    logger.info('Notification type interpreted', {
      notificationType: notification.notificationType,
      type: notificationInfo.type,
      action: notificationInfo.action,
      message: notificationInfo.message
    });

    // 통지 유형별 처리
    switch (notification.notificationType) {
      case AndroidNotificationType.SUBSCRIPTION_PURCHASED:
        await handlePurchase(payload, notification, result);
        break;

      case AndroidNotificationType.SUBSCRIPTION_RENEWED:
        await handleRenewal(payload, notification, result);
        break;

      case AndroidNotificationType.SUBSCRIPTION_RECOVERED:
        await handleRecovery(payload, notification, result);
        break;

      case AndroidNotificationType.SUBSCRIPTION_RESTARTED:
        await handleRestart(payload, notification, result);
        break;

      case AndroidNotificationType.SUBSCRIPTION_CANCELED:
        await handleCancellation(payload, notification, result);
        break;

      case AndroidNotificationType.SUBSCRIPTION_ON_HOLD:
      case AndroidNotificationType.SUBSCRIPTION_IN_GRACE_PERIOD:
        await handleHoldOrGrace(payload, notification, result);
        break;

      case AndroidNotificationType.SUBSCRIPTION_PAUSED:
        await handlePause(payload, notification, result);
        break;

      case AndroidNotificationType.SUBSCRIPTION_REVOKED:
        await handleRevoke(payload, notification, result);
        break;

      case AndroidNotificationType.SUBSCRIPTION_EXPIRED:
        await handleExpiration(payload, notification, result);
        break;

      case AndroidNotificationType.SUBSCRIPTION_DEFERRED:
      case AndroidNotificationType.SUBSCRIPTION_PAUSE_SCHEDULE_CHANGED:
      case AndroidNotificationType.SUBSCRIPTION_PRICE_CHANGE_CONFIRMED:
        await handleUpdate(payload, notification, result);
        break;

      default:
        logger.warn('Unknown notification type', {
          notificationType: notification.notificationType
        });
    }

    result.success = true;

    logger.info('Android webhook processed successfully', {
      notificationType: notificationInfo.type,
      action: result.action,
      userId: result.userId,
      subscriptionId: result.subscriptionId
    });

  } catch (error) {
    result.success = false;
    result.error = (error as Error).message;
    logError(error as Error, {
      message: pubsubMessage
    });
  }

  return result;
}

/**
 * 구독 구매 처리
 */
async function handlePurchase(
  payload: AndroidWebhookPayload,
  notification: any,
  result: WebhookProcessResult
): Promise<void> {
  logger.info('Handling subscription purchase');

  const subscription = await findSubscriptionByPurchaseToken(notification.purchaseToken);

  if (subscription) {
    result.userId = subscription.userId;
    result.subscriptionId = subscription.id;

    // 영수증 재검증
    await verifyAndroidReceipt({
      userId: subscription.userId,
      purchaseToken: notification.purchaseToken,
      productId: notification.subscriptionId,
      packageName: payload.packageName
    });
  } else {
    logger.warn('Subscription not found for purchase', {
      purchaseToken: notification.purchaseToken
    });
  }
}

/**
 * 구독 갱신 처리
 */
async function handleRenewal(
  payload: AndroidWebhookPayload,
  notification: any,
  result: WebhookProcessResult
): Promise<void> {
  logger.info('Handling subscription renewal');

  const subscription = await findSubscriptionByPurchaseToken(notification.purchaseToken);

  if (subscription) {
    result.userId = subscription.userId;
    result.subscriptionId = subscription.id;

    // 상태를 ACTIVE로 업데이트
    await admin.firestore()
      .collection('subscriptions')
      .doc(subscription.id)
      .update({
        status: SubscriptionStatus.ACTIVE,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        lastVerifiedAt: admin.firestore.FieldValue.serverTimestamp()
      });

    // 사용자 프리미엄 상태 업데이트
    await updateUserPremiumStatus(subscription.userId, SubscriptionStatus.ACTIVE);

    logger.info('Subscription renewed', {
      subscriptionId: subscription.id
    });
  }
}

/**
 * 구독 복구 처리 (결제 문제 해결)
 */
async function handleRecovery(
  payload: AndroidWebhookPayload,
  notification: any,
  result: WebhookProcessResult
): Promise<void> {
  logger.info('Handling subscription recovery');

  const subscription = await findSubscriptionByPurchaseToken(notification.purchaseToken);

  if (subscription) {
    result.userId = subscription.userId;
    result.subscriptionId = subscription.id;

    await admin.firestore()
      .collection('subscriptions')
      .doc(subscription.id)
      .update({
        status: SubscriptionStatus.ACTIVE,
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });

    // 사용자 프리미엄 상태 업데이트
    await updateUserPremiumStatus(subscription.userId, SubscriptionStatus.ACTIVE);

    logger.info('Subscription recovered from hold', {
      subscriptionId: subscription.id
    });
  }
}

/**
 * 구독 재시작 처리
 */
async function handleRestart(
  payload: AndroidWebhookPayload,
  notification: any,
  result: WebhookProcessResult
): Promise<void> {
  logger.info('Handling subscription restart');

  const subscription = await findSubscriptionByPurchaseToken(notification.purchaseToken);

  if (subscription) {
    result.userId = subscription.userId;
    result.subscriptionId = subscription.id;

    await admin.firestore()
      .collection('subscriptions')
      .doc(subscription.id)
      .update({
        status: SubscriptionStatus.ACTIVE,
        autoRenew: true,
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });

    // 사용자 프리미엄 상태 업데이트
    await updateUserPremiumStatus(subscription.userId, SubscriptionStatus.ACTIVE);

    logger.info('Subscription restarted', {
      subscriptionId: subscription.id
    });
  }
}

/**
 * 구독 취소 처리
 */
async function handleCancellation(
  payload: AndroidWebhookPayload,
  notification: any,
  result: WebhookProcessResult
): Promise<void> {
  logger.info('Handling subscription cancellation');

  const subscription = await findSubscriptionByPurchaseToken(notification.purchaseToken);

  if (subscription) {
    result.userId = subscription.userId;
    result.subscriptionId = subscription.id;

    await admin.firestore()
      .collection('subscriptions')
      .doc(subscription.id)
      .update({
        status: SubscriptionStatus.CANCELLED,
        autoRenew: false,
        cancelledAt: new Date(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });

    // 사용자 프리미엄 상태 업데이트
    await updateUserPremiumStatus(subscription.userId, SubscriptionStatus.CANCELLED);

    logger.info('Subscription cancelled', {
      subscriptionId: subscription.id
    });
  }
}

/**
 * 계정 보류 또는 유예 기간 처리
 */
async function handleHoldOrGrace(
  payload: AndroidWebhookPayload,
  notification: any,
  result: WebhookProcessResult
): Promise<void> {
  logger.info('Handling subscription hold or grace period');

  const subscription = await findSubscriptionByPurchaseToken(notification.purchaseToken);

  if (subscription) {
    result.userId = subscription.userId;
    result.subscriptionId = subscription.id;

    await admin.firestore()
      .collection('subscriptions')
      .doc(subscription.id)
      .update({
        status: SubscriptionStatus.PAUSED,
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });

    logger.warn('Subscription on hold or in grace period', {
      subscriptionId: subscription.id,
      notificationType: notification.notificationType
    });
  }
}

/**
 * 구독 일시 중지 처리
 */
async function handlePause(
  payload: AndroidWebhookPayload,
  notification: any,
  result: WebhookProcessResult
): Promise<void> {
  logger.info('Handling subscription pause');

  const subscription = await findSubscriptionByPurchaseToken(notification.purchaseToken);

  if (subscription) {
    result.userId = subscription.userId;
    result.subscriptionId = subscription.id;

    await admin.firestore()
      .collection('subscriptions')
      .doc(subscription.id)
      .update({
        status: SubscriptionStatus.PAUSED,
        autoRenew: false,
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });

    // 사용자 프리미엄 상태 업데이트
    await updateUserPremiumStatus(subscription.userId, SubscriptionStatus.PAUSED);

    logger.info('Subscription paused', {
      subscriptionId: subscription.id
    });
  }
}

/**
 * 구독 취소 (환불) 처리
 */
async function handleRevoke(
  payload: AndroidWebhookPayload,
  notification: any,
  result: WebhookProcessResult
): Promise<void> {
  logger.info('Handling subscription revoke (refund)');

  const subscription = await findSubscriptionByPurchaseToken(notification.purchaseToken);

  if (subscription) {
    result.userId = subscription.userId;
    result.subscriptionId = subscription.id;

    await admin.firestore()
      .collection('subscriptions')
      .doc(subscription.id)
      .update({
        status: SubscriptionStatus.CANCELLED,
        autoRenew: false,
        cancelledAt: new Date(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });

    // 사용자 프리미엄 상태 업데이트
    await updateUserPremiumStatus(subscription.userId, SubscriptionStatus.CANCELLED);

    logger.warn('Subscription revoked due to refund', {
      subscriptionId: subscription.id
    });
  }
}

/**
 * 구독 만료 처리
 */
async function handleExpiration(
  payload: AndroidWebhookPayload,
  notification: any,
  result: WebhookProcessResult
): Promise<void> {
  logger.info('Handling subscription expiration');

  const subscription = await findSubscriptionByPurchaseToken(notification.purchaseToken);

  if (subscription) {
    result.userId = subscription.userId;
    result.subscriptionId = subscription.id;

    await admin.firestore()
      .collection('subscriptions')
      .doc(subscription.id)
      .update({
        status: SubscriptionStatus.EXPIRED,
        autoRenew: false,
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });

    // 사용자 프리미엄 상태 업데이트
    await updateUserPremiumStatus(subscription.userId, SubscriptionStatus.EXPIRED);

    logger.info('Subscription expired', {
      subscriptionId: subscription.id
    });
  }
}

/**
 * 구독 정보 업데이트 처리
 */
async function handleUpdate(
  payload: AndroidWebhookPayload,
  notification: any,
  result: WebhookProcessResult
): Promise<void> {
  logger.info('Handling subscription update');

  const subscription = await findSubscriptionByPurchaseToken(notification.purchaseToken);

  if (subscription) {
    result.userId = subscription.userId;
    result.subscriptionId = subscription.id;

    // 영수증 재검증하여 최신 정보로 업데이트
    await verifyAndroidReceipt({
      userId: subscription.userId,
      purchaseToken: notification.purchaseToken,
      productId: notification.subscriptionId,
      packageName: payload.packageName
    });

    logger.info('Subscription updated', {
      subscriptionId: subscription.id,
      notificationType: notification.notificationType
    });
  }
}

/**
 * Purchase Token으로 구독 찾기
 */
async function findSubscriptionByPurchaseToken(
  purchaseToken: string
): Promise<any | null> {
  const db = admin.firestore();

  const snapshot = await db
    .collection('subscriptions')
    .where('purchaseToken', '==', purchaseToken)
    .limit(1)
    .get();

  if (snapshot.empty) {
    return null;
  }

  const doc = snapshot.docs[0];
  return {
    id: doc.id,
    ...doc.data()
  };
}

/**
 * 사용자 프리미엄 상태 업데이트
 */
async function updateUserPremiumStatus(
  userId: string,
  status: SubscriptionStatus
): Promise<void> {
  try {
    const db = admin.firestore();

    const isPremium = status === SubscriptionStatus.ACTIVE || status === SubscriptionStatus.TRIAL;

    await db.collection('users').doc(userId).update({
      isPremium,
      premiumStatus: status,
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });

    logger.debug('User premium status updated via webhook', {
      userId,
      isPremium,
      status
    });

  } catch (error) {
    logger.error('Failed to update user premium status', error as Error, {
      userId
    });
  }
}
