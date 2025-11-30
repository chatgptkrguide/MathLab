/**
 * iOS Server-to-Server Notification Webhook 핸들러
 */

import * as admin from 'firebase-admin';
import { createLogger } from '../utils/logger';
import { logError } from '../utils/error-handler';
import { verifyIOSReceipt } from '../services/ios-verification';
import {
  IOSWebhookPayload,
  IOSNotificationType,
  WebhookProcessResult
} from '../types/webhook';
import {
  SubscriptionStatus
} from '../types/subscription';

const logger = createLogger('IOSWebhook');

/**
 * iOS Webhook 처리
 */
export async function processIOSWebhook(
  payload: IOSWebhookPayload
): Promise<WebhookProcessResult> {
  const result: WebhookProcessResult = {
    success: false,
    notificationType: payload.notification_type,
    action: 'none'
  };

  try {
    logger.info('Processing iOS webhook notification', {
      notificationType: payload.notification_type,
      environment: payload.environment
    });

    // 통지 유형별 처리
    switch (payload.notification_type) {
      case IOSNotificationType.INITIAL_BUY:
        result.action = 'activate';
        await handleInitialPurchase(payload, result);
        break;

      case IOSNotificationType.DID_RENEW:
      case IOSNotificationType.INTERACTIVE_RENEWAL:
        result.action = 'renew';
        await handleRenewal(payload, result);
        break;

      case IOSNotificationType.DID_FAIL_TO_RENEW:
        result.action = 'update';
        await handleRenewalFailure(payload, result);
        break;

      case IOSNotificationType.DID_CHANGE_RENEWAL_STATUS:
      case IOSNotificationType.DID_CHANGE_RENEWAL_PREF:
        result.action = 'update';
        await handleRenewalStatusChange(payload, result);
        break;

      case IOSNotificationType.EXPIRED:
        result.action = 'deactivate';
        await handleExpiration(payload, result);
        break;

      case IOSNotificationType.CANCEL:
        result.action = 'deactivate';
        await handleCancellation(payload, result);
        break;

      case IOSNotificationType.REFUND:
        result.action = 'deactivate';
        await handleRefund(payload, result);
        break;

      case IOSNotificationType.PRICE_INCREASE_CONSENT:
        result.action = 'update';
        await handlePriceIncreaseConsent(payload, result);
        break;

      default:
        logger.warn('Unknown notification type', {
          notificationType: payload.notification_type
        });
        result.action = 'none';
    }

    result.success = true;

    logger.info('iOS webhook processed successfully', {
      notificationType: payload.notification_type,
      action: result.action,
      userId: result.userId,
      subscriptionId: result.subscriptionId
    });

  } catch (error) {
    result.success = false;
    result.error = (error as Error).message;
    logError(error as Error, {
      notificationType: payload.notification_type
    });
  }

  return result;
}

/**
 * 최초 구매 처리
 */
async function handleInitialPurchase(
  payload: IOSWebhookPayload,
  result: WebhookProcessResult
): Promise<void> {
  logger.info('Handling initial purchase', {
    environment: payload.environment
  });

  const latestReceipt = payload.unified_receipt.latest_receipt_info[0];
  if (!latestReceipt) {
    throw new Error('No receipt info found in webhook payload');
  }

  // original_transaction_id로 사용자 찾기
  const subscription = await findSubscriptionByTransactionId(
    latestReceipt.original_transaction_id
  );

  if (subscription) {
    result.userId = subscription.userId;
    result.subscriptionId = subscription.id;

    // 영수증 재검증
    await verifyIOSReceipt({
      userId: subscription.userId,
      receiptData: payload.unified_receipt.latest_receipt,
      transactionId: latestReceipt.transaction_id,
      productId: latestReceipt.product_id
    });
  } else {
    logger.warn('Subscription not found for initial purchase', {
      originalTransactionId: latestReceipt.original_transaction_id
    });
  }
}

/**
 * 구독 갱신 처리
 */
async function handleRenewal(
  payload: IOSWebhookPayload,
  result: WebhookProcessResult
): Promise<void> {
  logger.info('Handling subscription renewal');

  const latestReceipt = payload.unified_receipt.latest_receipt_info[0];
  if (!latestReceipt) {
    throw new Error('No receipt info found in webhook payload');
  }

  const subscription = await findSubscriptionByTransactionId(
    latestReceipt.original_transaction_id
  );

  if (subscription) {
    result.userId = subscription.userId;
    result.subscriptionId = subscription.id;

    // 만료 날짜 업데이트
    const expiryDate = new Date(parseInt(latestReceipt.expires_date_ms, 10));

    await admin.firestore()
      .collection('subscriptions')
      .doc(subscription.id)
      .update({
        status: SubscriptionStatus.ACTIVE,
        expiryDate,
        autoRenew: true,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        lastVerifiedAt: admin.firestore.FieldValue.serverTimestamp()
      });

    // 사용자 프리미엄 상태 업데이트
    await updateUserPremiumStatus(subscription.userId, SubscriptionStatus.ACTIVE);

    logger.info('Subscription renewed', {
      subscriptionId: subscription.id,
      expiryDate: expiryDate.toISOString()
    });
  }
}

/**
 * 갱신 실패 처리
 */
async function handleRenewalFailure(
  payload: IOSWebhookPayload,
  result: WebhookProcessResult
): Promise<void> {
  logger.info('Handling renewal failure');

  const latestReceipt = payload.unified_receipt.latest_receipt_info[0];
  if (!latestReceipt) {
    throw new Error('No receipt info found in webhook payload');
  }

  const subscription = await findSubscriptionByTransactionId(
    latestReceipt.original_transaction_id
  );

  if (subscription) {
    result.userId = subscription.userId;
    result.subscriptionId = subscription.id;

    // 구독을 일시 중지 상태로 변경 (유예 기간)
    await admin.firestore()
      .collection('subscriptions')
      .doc(subscription.id)
      .update({
        status: SubscriptionStatus.PAUSED,
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });

    logger.warn('Subscription renewal failed, marked as paused', {
      subscriptionId: subscription.id
    });
  }
}

/**
 * 갱신 상태 변경 처리
 */
async function handleRenewalStatusChange(
  payload: IOSWebhookPayload,
  result: WebhookProcessResult
): Promise<void> {
  logger.info('Handling renewal status change');

  const latestReceipt = payload.unified_receipt.latest_receipt_info[0];
  if (!latestReceipt) {
    throw new Error('No receipt info found in webhook payload');
  }

  const subscription = await findSubscriptionByTransactionId(
    latestReceipt.original_transaction_id
  );

  if (subscription) {
    result.userId = subscription.userId;
    result.subscriptionId = subscription.id;

    // auto_renew_status 확인
    const autoRenew = latestReceipt.auto_renew_status === '1';

    await admin.firestore()
      .collection('subscriptions')
      .doc(subscription.id)
      .update({
        autoRenew,
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });

    logger.info('Subscription renewal status changed', {
      subscriptionId: subscription.id,
      autoRenew
    });
  }
}

/**
 * 구독 만료 처리
 */
async function handleExpiration(
  payload: IOSWebhookPayload,
  result: WebhookProcessResult
): Promise<void> {
  logger.info('Handling subscription expiration');

  const latestReceipt = payload.unified_receipt.latest_receipt_info[0];
  if (!latestReceipt) {
    throw new Error('No receipt info found in webhook payload');
  }

  const subscription = await findSubscriptionByTransactionId(
    latestReceipt.original_transaction_id
  );

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
 * 구독 취소 처리
 */
async function handleCancellation(
  payload: IOSWebhookPayload,
  result: WebhookProcessResult
): Promise<void> {
  logger.info('Handling subscription cancellation');

  const latestReceipt = payload.unified_receipt.latest_receipt_info[0];
  if (!latestReceipt) {
    throw new Error('No receipt info found in webhook payload');
  }

  const subscription = await findSubscriptionByTransactionId(
    latestReceipt.original_transaction_id
  );

  if (subscription) {
    result.userId = subscription.userId;
    result.subscriptionId = subscription.id;

    const cancelledAt = latestReceipt.cancellation_date_ms
      ? new Date(parseInt(latestReceipt.cancellation_date_ms, 10))
      : new Date();

    await admin.firestore()
      .collection('subscriptions')
      .doc(subscription.id)
      .update({
        status: SubscriptionStatus.CANCELLED,
        autoRenew: false,
        cancelledAt,
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });

    // 사용자 프리미엄 상태 업데이트
    await updateUserPremiumStatus(subscription.userId, SubscriptionStatus.CANCELLED);

    logger.info('Subscription cancelled', {
      subscriptionId: subscription.id,
      cancelledAt: cancelledAt.toISOString()
    });
  }
}

/**
 * 환불 처리
 */
async function handleRefund(
  payload: IOSWebhookPayload,
  result: WebhookProcessResult
): Promise<void> {
  logger.info('Handling refund');

  const latestReceipt = payload.unified_receipt.latest_receipt_info[0];
  if (!latestReceipt) {
    throw new Error('No receipt info found in webhook payload');
  }

  const subscription = await findSubscriptionByTransactionId(
    latestReceipt.original_transaction_id
  );

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

    logger.warn('Subscription refunded', {
      subscriptionId: subscription.id
    });
  }
}

/**
 * 가격 인상 동의 처리
 */
async function handlePriceIncreaseConsent(
  payload: IOSWebhookPayload,
  result: WebhookProcessResult
): Promise<void> {
  logger.info('Handling price increase consent');

  const latestReceipt = payload.unified_receipt.latest_receipt_info[0];
  if (!latestReceipt) {
    throw new Error('No receipt info found in webhook payload');
  }

  const subscription = await findSubscriptionByTransactionId(
    latestReceipt.original_transaction_id
  );

  if (subscription) {
    result.userId = subscription.userId;
    result.subscriptionId = subscription.id;

    // 가격 인상 동의 로그만 남김 (실제 가격 변경은 영수증 재검증 시 반영)
    logger.info('User consented to price increase', {
      subscriptionId: subscription.id,
      userId: subscription.userId
    });
  }
}

/**
 * Transaction ID로 구독 찾기
 */
async function findSubscriptionByTransactionId(
  transactionId: string
): Promise<any | null> {
  const db = admin.firestore();

  const snapshot = await db
    .collection('subscriptions')
    .where('transactionId', '==', transactionId)
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
