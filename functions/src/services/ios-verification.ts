/**
 * iOS 영수증 검증 서비스
 */

import * as admin from 'firebase-admin';
import axios from 'axios';
import { createLogger } from '../utils/logger';
import {
  ReceiptVerificationError,
  ExternalAPIError,
  retryWithBackoff,
  logError
} from '../utils/error-handler';
import {
  validateIOSReceiptRequest
} from '../utils/validators';
import {
  loadIOSConfig,
  getVerifyReceiptURL,
  interpretReceiptStatus,
  extractLatestSubscription,
  isSubscriptionActive,
  isTrialPeriod,
  isCancelled
} from '../config/ios-config';
import { getSubscriptionTierFromProductId } from '../utils/user-utils';
import {
  IOSReceiptVerificationRequest,
  IOSReceiptVerificationResponse,
  AppStoreReceiptResponse,
  Subscription,
  SubscriptionStatus,
  PremiumTier,
  Platform
} from '../types/subscription';
import { updateUserPremiumStatus } from '../utils/user-utils';

const logger = createLogger('IOSVerificationService');

/**
 * iOS 영수증 검증 및 구독 저장
 */
export async function verifyIOSReceipt(
  request: IOSReceiptVerificationRequest
): Promise<IOSReceiptVerificationResponse> {
  try {
    // 입력 검증
    validateIOSReceiptRequest(request);

    logger.info('Starting iOS receipt verification', {
      userId: request.userId,
      productId: request.productId,
      transactionId: request.transactionId
    });

    // iOS 설정 로드
    const config = loadIOSConfig();

    // App Store에 영수증 검증 요청 (재시도 로직 포함)
    const receiptResponse = await verifyReceiptWithAppStore(
      request.receiptData,
      config,
      false // 먼저 Production으로 시도
    );

    // 영수증 응답 검증
    if (!receiptResponse || receiptResponse.status !== 0) {
      const statusInfo = interpretReceiptStatus(receiptResponse?.status || -1);

      // Sandbox 환경인 경우 재시도
      if (receiptResponse?.status === 21007) {
        logger.info('Receipt is from sandbox, retrying with sandbox URL');
        const sandboxResponse = await verifyReceiptWithAppStore(
          request.receiptData,
          config,
          true // Sandbox URL 사용
        );

        if (sandboxResponse.status === 0) {
          return await processValidReceipt(request, sandboxResponse, config);
        }
      }

      // 검증 실패
      throw new ReceiptVerificationError(
        `Receipt verification failed: ${statusInfo.message}`,
        `IOS_${receiptResponse?.status || 'UNKNOWN'}`
      );
    }

    // 검증 성공 - 구독 정보 처리
    return await processValidReceipt(request, receiptResponse, config);

  } catch (error) {
    logError(error as Error, {
      userId: request.userId,
      productId: request.productId
    });

    if (error instanceof ReceiptVerificationError) {
      throw error;
    }

    return {
      success: false,
      error: (error as Error).message
    };
  }
}

/**
 * App Store에 영수증 검증 요청
 */
async function verifyReceiptWithAppStore(
  receiptData: string,
  config: any,
  isSandbox: boolean
): Promise<AppStoreReceiptResponse> {
  const url = getVerifyReceiptURL(config, isSandbox);

  logger.debug('Sending receipt to App Store', {
    url,
    isSandbox,
    receiptLength: receiptData.length
  });

  try {
    const response = await retryWithBackoff(
      async () => {
        const result = await axios.post<AppStoreReceiptResponse>(
          url,
          {
            'receipt-data': receiptData,
            'exclude-old-transactions': true
          },
          {
            timeout: 10000, // 10초 타임아웃
            headers: {
              'Content-Type': 'application/json'
            }
          }
        );
        return result.data;
      },
      {
        maxRetries: 3,
        initialDelayMs: 1000,
        retryableErrors: ['ETIMEDOUT', 'ECONNRESET']
      }
    );

    logger.info('Received response from App Store', {
      status: response.status,
      environment: response.environment,
      isSandbox
    });

    return response;

  } catch (error) {
    logger.error('Failed to verify receipt with App Store', error as Error, {
      url,
      isSandbox
    });
    throw new ExternalAPIError('Failed to communicate with App Store');
  }
}

/**
 * 유효한 영수증 처리 및 Firestore 저장
 */
async function processValidReceipt(
  request: IOSReceiptVerificationRequest,
  receiptResponse: AppStoreReceiptResponse,
  config: any
): Promise<IOSReceiptVerificationResponse> {
  try {
    // 최신 구독 정보 추출
    const latestReceiptInfo = receiptResponse.latest_receipt_info || receiptResponse.receipt.in_app;
    const latestSubscription = extractLatestSubscription(latestReceiptInfo);

    if (!latestSubscription) {
      throw new ReceiptVerificationError('No subscription found in receipt');
    }

    logger.debug('Latest subscription info extracted', {
      productId: latestSubscription.product_id,
      transactionId: latestSubscription.transaction_id,
      expiresDateMs: latestSubscription.expires_date_ms
    });

    // 구독 상태 판별
    const expiresDateMs = latestSubscription.expires_date_ms;
    const isActive = isSubscriptionActive(expiresDateMs);
    const isTrial = isTrialPeriod(latestSubscription.is_trial_period);
    const cancelled = isCancelled(latestSubscription.cancellation_date_ms);

    let status: SubscriptionStatus;
    if (cancelled) {
      status = SubscriptionStatus.CANCELLED;
    } else if (isTrial) {
      status = SubscriptionStatus.TRIAL;
    } else if (isActive) {
      status = SubscriptionStatus.ACTIVE;
    } else {
      status = SubscriptionStatus.EXPIRED;
    }

    // 구독 티어 판별
    const tier = getSubscriptionTierFromProductId(latestSubscription.product_id) as PremiumTier;

    // 만료 날짜
    const expiryDate = new Date(parseInt(expiresDateMs, 10));

    // 체험 종료 날짜
    let trialEndDate: Date | null = null;
    if (isTrial && expiresDateMs) {
      trialEndDate = new Date(parseInt(expiresDateMs, 10));
    }

    // Firestore에 저장할 구독 데이터
    const subscriptionData: Omit<Subscription, 'id'> = {
      userId: request.userId,
      tier,
      status,
      platform: Platform.IOS,
      startDate: new Date(parseInt(latestSubscription.purchase_date_ms, 10)),
      expiryDate: tier === PremiumTier.LIFETIME ? null : expiryDate,
      trialEndDate,
      autoRenew: !cancelled,
      transactionId: latestSubscription.original_transaction_id,
      productId: latestSubscription.product_id,
      originalReceipt: request.receiptData,
      createdAt: new Date(),
      updatedAt: new Date(),
      lastVerifiedAt: new Date(),
      cancelledAt: cancelled ? new Date(parseInt(latestSubscription.cancellation_date_ms!, 10)) : undefined
    };

    // Firestore에 저장
    const subscriptionId = await saveSubscriptionToFirestore(subscriptionData);

    logger.info('iOS subscription verified and saved successfully', {
      userId: request.userId,
      subscriptionId,
      tier,
      status,
      expiryDate: expiryDate.toISOString()
    });

    return {
      success: true,
      subscriptionId,
      expiryDate,
      tier
    };

  } catch (error) {
    logError(error as Error, {
      userId: request.userId
    });
    throw error;
  }
}

/**
 * Firestore에 구독 정보 저장
 */
async function saveSubscriptionToFirestore(
  subscriptionData: Omit<Subscription, 'id'>
): Promise<string> {
  try {
    const db = admin.firestore();

    // 동일한 transactionId가 이미 존재하는지 확인
    const existingSubscription = await db
      .collection('subscriptions')
      .where('transactionId', '==', subscriptionData.transactionId)
      .limit(1)
      .get();

    let subscriptionId: string;

    if (!existingSubscription.empty) {
      // 기존 구독 업데이트
      subscriptionId = existingSubscription.docs[0].id;

      await db
        .collection('subscriptions')
        .doc(subscriptionId)
        .update({
          ...subscriptionData,
          updatedAt: admin.firestore.FieldValue.serverTimestamp()
        });

      logger.info('Updated existing subscription', {
        subscriptionId,
        userId: subscriptionData.userId
      });
    } else {
      // 새 구독 생성
      const docRef = await db.collection('subscriptions').add({
        ...subscriptionData,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });

      subscriptionId = docRef.id;

      logger.info('Created new subscription', {
        subscriptionId,
        userId: subscriptionData.userId
      });
    }

    // 사용자의 premiumStatus 업데이트
    await updateUserPremiumStatus(subscriptionData.userId, subscriptionData.status, subscriptionData.tier);

    return subscriptionId;

  } catch (error) {
    logger.error('Failed to save subscription to Firestore', error as Error, {
      userId: subscriptionData.userId
    });
    throw new Error('Failed to save subscription data');
  }
}
