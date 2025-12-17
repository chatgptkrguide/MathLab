/**
 * 사용자 프리미엄 상태 업데이트 유틸리티
 */

import * as admin from 'firebase-admin';
import { createLogger } from './logger';
import { SubscriptionStatus, PremiumTier } from '../types/subscription';

const logger = createLogger('UserUtils');

/**
 * 사용자의 프리미엄 상태를 Firestore에 업데이트
 *
 * @param userId - 사용자 ID
 * @param status - 구독 상태
 * @param tier - 프리미엄 티어 (선택적)
 */
export async function updateUserPremiumStatus(
  userId: string,
  status: SubscriptionStatus,
  tier?: PremiumTier | null
): Promise<void> {
  try {
    const db = admin.firestore();

    const isPremium = status === SubscriptionStatus.ACTIVE || status === SubscriptionStatus.TRIAL;

    // tier가 제공되지 않았거나 구독이 비활성 상태인 경우 null 처리
    const premiumTier = (tier && isPremium) ? tier : null;

    await db.collection('users').doc(userId).update({
      isPremium,
      premiumTier,
      premiumStatus: status,
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });

    logger.debug('User premium status updated', {
      userId,
      isPremium,
      tier: premiumTier,
      status
    });

  } catch (error) {
    logger.error('Failed to update user premium status', error as Error, {
      userId,
      status,
      tier
    });
    throw error;
  }
}

/**
 * iOS Transaction ID로 구독 찾기
 */
export async function findSubscriptionByTransactionId(
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
 * Android Purchase Token으로 구독 찾기
 */
export async function findSubscriptionByPurchaseToken(
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
 * Product ID로 구독 티어 판별
 *
 * @param productId - iOS/Android 제품 ID
 * @returns 구독 티어 (monthly, yearly, lifetime)
 */
export function getSubscriptionTierFromProductId(productId: string): 'monthly' | 'yearly' | 'lifetime' {
  const lowerProductId = productId.toLowerCase();

  if (lowerProductId.includes('monthly')) {
    return 'monthly';
  } else if (lowerProductId.includes('yearly') || lowerProductId.includes('annual')) {
    return 'yearly';
  } else if (lowerProductId.includes('lifetime')) {
    return 'lifetime';
  }

  // 기본값: monthly
  logger.warn('Could not determine subscription tier from productId, defaulting to monthly', {
    productId
  });
  return 'monthly';
}
