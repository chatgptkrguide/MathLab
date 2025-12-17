/**
 * 구독 상태 동기화 서비스
 * 정기적으로 모든 활성 구독의 상태를 검증하고 업데이트
 */

import * as admin from 'firebase-admin';
import { createLogger } from '../utils/logger';
import { logError } from '../utils/error-handler';
import { verifyIOSReceipt } from './ios-verification';
import { verifyAndroidReceipt } from './android-verification';
import {
  Subscription,
  SubscriptionStatus,
  Platform,
  SyncResult
} from '../types/subscription';
import { updateUserPremiumStatus } from '../utils/user-utils';

const logger = createLogger('SubscriptionSyncService');

/**
 * 모든 활성 구독 동기화
 */
export async function syncAllSubscriptions(): Promise<{
  totalProcessed: number;
  successful: number;
  failed: number;
  errors: string[];
}> {
  logger.info('Starting subscription sync job');

  const db = admin.firestore();
  const results = {
    totalProcessed: 0,
    successful: 0,
    failed: 0,
    errors: [] as string[]
  };

  try {
    // 활성 상태 또는 체험 중인 구독만 조회
    const subscriptionsSnapshot = await db
      .collection('subscriptions')
      .where('status', 'in', [
        SubscriptionStatus.ACTIVE,
        SubscriptionStatus.TRIAL,
        SubscriptionStatus.PAUSED
      ])
      .get();

    logger.info(`Found ${subscriptionsSnapshot.size} subscriptions to sync`);

    // 배치 처리 (10개씩)
    const batchSize = 10;
    const subscriptions = subscriptionsSnapshot.docs;

    for (let i = 0; i < subscriptions.length; i += batchSize) {
      const batch = subscriptions.slice(i, i + batchSize);

      // 병렬 처리
      const batchResults = await Promise.allSettled(
        batch.map(doc => syncSingleSubscription(doc.id, doc.data() as Subscription))
      );

      // 결과 집계
      batchResults.forEach((result, index) => {
        results.totalProcessed++;

        if (result.status === 'fulfilled') {
          if (result.value.synced) {
            results.successful++;
            logger.debug('Subscription synced successfully', {
              subscriptionId: batch[index].id,
              changes: result.value.changes
            });
          } else {
            results.failed++;
            if (result.value.error) {
              results.errors.push(`${batch[index].id}: ${result.value.error}`);
            }
          }
        } else {
          results.failed++;
          results.errors.push(`${batch[index].id}: ${result.reason}`);
          logger.error('Failed to sync subscription', result.reason, {
            subscriptionId: batch[index].id
          });
        }
      });

      // 과도한 API 호출 방지를 위한 지연
      if (i + batchSize < subscriptions.length) {
        await sleep(2000); // 2초 대기
      }
    }

    logger.info('Subscription sync job completed', {
      totalProcessed: results.totalProcessed,
      successful: results.successful,
      failed: results.failed,
      errorCount: results.errors.length
    });

  } catch (error) {
    logger.error('Subscription sync job failed', error as Error);
    throw error;
  }

  return results;
}

/**
 * 단일 구독 동기화
 */
async function syncSingleSubscription(
  subscriptionId: string,
  subscription: Subscription
): Promise<SyncResult> {
  const result: SyncResult = {
    userId: subscription.userId,
    subscriptionId,
    synced: false,
    changes: []
  };

  try {
    logger.debug('Syncing subscription', {
      subscriptionId,
      userId: subscription.userId,
      platform: subscription.platform,
      tier: subscription.tier
    });

    // 플랫폼별로 영수증 재검증
    if (subscription.platform === Platform.IOS) {
      await syncIOSSubscription(subscription, result);
    } else if (subscription.platform === Platform.ANDROID) {
      await syncAndroidSubscription(subscription, result);
    } else {
      result.error = `Unknown platform: ${subscription.platform}`;
      return result;
    }

    result.synced = true;

  } catch (error) {
    result.synced = false;
    result.error = (error as Error).message;
    logError(error as Error, {
      subscriptionId,
      userId: subscription.userId
    });
  }

  return result;
}

/**
 * iOS 구독 동기화
 */
async function syncIOSSubscription(
  subscription: Subscription,
  result: SyncResult
): Promise<void> {
  if (!subscription.originalReceipt) {
    throw new Error('Missing original receipt data for iOS subscription');
  }

  // 영수증 재검증
  const verificationResult = await verifyIOSReceipt({
    userId: subscription.userId,
    receiptData: subscription.originalReceipt,
    transactionId: subscription.transactionId,
    productId: subscription.productId
  });

  if (!verificationResult.success) {
    throw new Error(`iOS receipt verification failed: ${verificationResult.error}`);
  }

  // 변경 사항 추적
  if (verificationResult.expiryDate) {
    // null-safe 체크: expiryDate가 null일 수 있음 (lifetime 구독)
    const oldExpiry = subscription.expiryDate ? subscription.expiryDate.getTime() : null;
    const newExpiry = verificationResult.expiryDate.getTime();

    if (oldExpiry !== newExpiry) {
      const oldExpiryStr = subscription.expiryDate ? subscription.expiryDate.toISOString() : 'null';
      result.changes?.push(`Expiry date updated: ${oldExpiryStr} → ${verificationResult.expiryDate.toISOString()}`);
    }
  }

  logger.debug('iOS subscription synced', {
    subscriptionId: result.subscriptionId,
    changes: result.changes
  });
}

/**
 * Android 구독 동기화
 */
async function syncAndroidSubscription(
  subscription: Subscription,
  result: SyncResult
): Promise<void> {
  if (!subscription.purchaseToken) {
    throw new Error('Missing purchase token for Android subscription');
  }

  const packageName = process.env.ANDROID_PACKAGE_NAME;
  if (!packageName) {
    throw new Error('Missing ANDROID_PACKAGE_NAME environment variable');
  }

  // 구독 정보 재검증
  const verificationResult = await verifyAndroidReceipt({
    userId: subscription.userId,
    purchaseToken: subscription.purchaseToken,
    productId: subscription.productId,
    packageName
  });

  if (!verificationResult.success) {
    throw new Error(`Android receipt verification failed: ${verificationResult.error}`);
  }

  // 변경 사항 추적
  if (verificationResult.expiryDate) {
    // null-safe 체크: expiryDate가 null일 수 있음 (lifetime 구독)
    const oldExpiry = subscription.expiryDate ? subscription.expiryDate.getTime() : null;
    const newExpiry = verificationResult.expiryDate.getTime();

    if (oldExpiry !== newExpiry) {
      const oldExpiryStr = subscription.expiryDate ? subscription.expiryDate.toISOString() : 'null';
      result.changes?.push(`Expiry date updated: ${oldExpiryStr} → ${verificationResult.expiryDate.toISOString()}`);
    }
  }

  logger.debug('Android subscription synced', {
    subscriptionId: result.subscriptionId,
    changes: result.changes
  });
}

/**
 * 만료된 구독 정리
 */
export async function cleanupExpiredSubscriptions(): Promise<{
  totalProcessed: number;
  updated: number;
}> {
  logger.info('Starting expired subscription cleanup');

  const db = admin.firestore();
  const now = new Date();

  try {
    // 활성 상태지만 만료 시간이 지난 구독 조회
    const expiredSubscriptions = await db
      .collection('subscriptions')
      .where('status', 'in', [
        SubscriptionStatus.ACTIVE,
        SubscriptionStatus.TRIAL,
        SubscriptionStatus.PAUSED
      ])
      .where('expiryDate', '<=', now)
      .get();

    logger.info(`Found ${expiredSubscriptions.size} expired subscriptions`);

    let updated = 0;

    // 배치로 업데이트
    const batch = db.batch();
    expiredSubscriptions.docs.forEach(doc => {
      batch.update(doc.ref, {
        status: SubscriptionStatus.EXPIRED,
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });
      updated++;
    });

    await batch.commit();

    // 사용자의 프리미엄 상태도 업데이트
    for (const doc of expiredSubscriptions.docs) {
      const subscription = doc.data() as Subscription;
      await updateUserPremiumStatus(subscription.userId, SubscriptionStatus.EXPIRED);
    }

    logger.info('Expired subscription cleanup completed', {
      totalProcessed: expiredSubscriptions.size,
      updated
    });

    return {
      totalProcessed: expiredSubscriptions.size,
      updated
    };

  } catch (error) {
    logger.error('Expired subscription cleanup failed', error as Error);
    throw error;
  }
}

/**
 * Sleep 유틸리티
 */
function sleep(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms));
}

/**
 * 구독 통계 수집
 */
export async function getSubscriptionStats(): Promise<{
  total: number;
  active: number;
  trial: number;
  cancelled: number;
  expired: number;
  paused: number;
  byPlatform: {
    ios: number;
    android: number;
  };
  byTier: {
    monthly: number;
    yearly: number;
    lifetime: number;
  };
}> {
  const db = admin.firestore();

  try {
    const subscriptionsSnapshot = await db.collection('subscriptions').get();

    const stats = {
      total: subscriptionsSnapshot.size,
      active: 0,
      trial: 0,
      cancelled: 0,
      expired: 0,
      paused: 0,
      byPlatform: {
        ios: 0,
        android: 0
      },
      byTier: {
        monthly: 0,
        yearly: 0,
        lifetime: 0
      }
    };

    subscriptionsSnapshot.docs.forEach(doc => {
      const subscription = doc.data() as Subscription;

      // 상태별 집계
      switch (subscription.status) {
        case SubscriptionStatus.ACTIVE:
          stats.active++;
          break;
        case SubscriptionStatus.TRIAL:
          stats.trial++;
          break;
        case SubscriptionStatus.CANCELLED:
          stats.cancelled++;
          break;
        case SubscriptionStatus.EXPIRED:
          stats.expired++;
          break;
        case SubscriptionStatus.PAUSED:
          stats.paused++;
          break;
      }

      // 플랫폼별 집계
      if (subscription.platform === Platform.IOS) {
        stats.byPlatform.ios++;
      } else if (subscription.platform === Platform.ANDROID) {
        stats.byPlatform.android++;
      }

      // 티어별 집계
      switch (subscription.tier) {
        case 'monthly':
          stats.byTier.monthly++;
          break;
        case 'yearly':
          stats.byTier.yearly++;
          break;
        case 'lifetime':
          stats.byTier.lifetime++;
          break;
      }
    });

    logger.info('Subscription statistics collected', stats);

    return stats;

  } catch (error) {
    logger.error('Failed to collect subscription statistics', error as Error);
    throw error;
  }
}
