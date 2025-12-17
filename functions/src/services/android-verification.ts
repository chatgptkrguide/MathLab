/**
 * Android 영수증 검증 서비스
 */

import * as admin from 'firebase-admin';
import { createLogger } from '../utils/logger';
import {
  ReceiptVerificationError,
  ExternalAPIError,
  retryWithBackoff,
  logError
} from '../utils/error-handler';
import {
  validateAndroidReceiptRequest
} from '../utils/validators';
import {
  loadAndroidConfig,
  createGooglePlayClient,
  interpretSubscriptionState,
  interpretCancelReason,
  isSubscriptionActive,
  isInGracePeriod
} from '../config/android-config';
import { getSubscriptionTierFromProductId } from '../utils/user-utils';
import {
  AndroidReceiptVerificationRequest,
  AndroidReceiptVerificationResponse,
  GooglePlaySubscriptionResponse,
  Subscription,
  SubscriptionStatus,
  PremiumTier,
  Platform
} from '../types/subscription';
import { updateUserPremiumStatus } from '../utils/user-utils';

const logger = createLogger('AndroidVerificationService');

/**
 * Android 영수증 검증 및 구독 저장
 */
export async function verifyAndroidReceipt(
  request: AndroidReceiptVerificationRequest
): Promise<AndroidReceiptVerificationResponse> {
  try {
    // 입력 검증
    validateAndroidReceiptRequest(request);

    logger.info('Starting Android receipt verification', {
      userId: request.userId,
      productId: request.productId,
      packageName: request.packageName
    });

    // Android 설정 로드
    const config = loadAndroidConfig();

    // Google Play API 클라이언트 생성
    const androidPublisher = await createGooglePlayClient(config);

    // Google Play에 구독 정보 요청 (재시도 로직 포함)
    const subscriptionResponse = await getSubscriptionFromGooglePlay(
      androidPublisher,
      request.packageName,
      request.productId,
      request.purchaseToken
    );

    // 구독 정보 처리 및 Firestore 저장
    return await processValidSubscription(request, subscriptionResponse, config);

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
 * Google Play API에서 구독 정보 조회
 */
async function getSubscriptionFromGooglePlay(
  androidPublisher: any,
  packageName: string,
  productId: string,
  purchaseToken: string
): Promise<GooglePlaySubscriptionResponse> {
  logger.debug('Fetching subscription from Google Play', {
    packageName,
    productId
  });

  try {
    const response = await retryWithBackoff(
      async () => {
        const result = await androidPublisher.purchases.subscriptions.get({
          packageName,
          subscriptionId: productId,
          token: purchaseToken
        });
        return result.data;
      },
      {
        maxRetries: 3,
        initialDelayMs: 1000,
        retryableErrors: ['ETIMEDOUT', 'ECONNRESET']
      }
    );

    logger.info('Received subscription info from Google Play', {
      orderId: response.orderId,
      startTimeMillis: response.startTimeMillis,
      expiryTimeMillis: response.expiryTimeMillis,
      autoRenewing: response.autoRenewing,
      paymentState: response.paymentState
    });

    return response;

  } catch (error: any) {
    logger.error('Failed to get subscription from Google Play', error, {
      packageName,
      productId,
      errorCode: error.code,
      errorMessage: error.message
    });

    // Google Play API 에러 메시지 해석
    if (error.code === 401) {
      throw new ReceiptVerificationError('Invalid credentials');
    } else if (error.code === 404) {
      throw new ReceiptVerificationError('Subscription not found');
    } else if (error.code === 410) {
      throw new ReceiptVerificationError('Purchase token is no longer valid');
    }

    throw new ExternalAPIError('Failed to communicate with Google Play API');
  }
}

/**
 * 유효한 구독 정보 처리 및 Firestore 저장
 */
async function processValidSubscription(
  request: AndroidReceiptVerificationRequest,
  subscriptionResponse: GooglePlaySubscriptionResponse,
  config: any
): Promise<AndroidReceiptVerificationResponse> {
  try {
    // 구독 상태 판별
    const stateInfo = interpretSubscriptionState(subscriptionResponse.paymentState);
    const isActive = isSubscriptionActive(
      subscriptionResponse.expiryTimeMillis,
      subscriptionResponse.autoRenewing
    );
    const inGracePeriod = isInGracePeriod(
      subscriptionResponse.expiryTimeMillis,
      subscriptionResponse.autoRenewing
    );

    logger.debug('Subscription state analyzed', {
      paymentState: subscriptionResponse.paymentState,
      stateInfo,
      isActive,
      inGracePeriod,
      autoRenewing: subscriptionResponse.autoRenewing
    });

    // 구독 상태 결정
    let status: SubscriptionStatus;
    if (subscriptionResponse.cancelReason !== undefined) {
      status = SubscriptionStatus.CANCELLED;
    } else if (inGracePeriod) {
      status = SubscriptionStatus.PAUSED; // 유예 기간
    } else if (isActive) {
      // 체험 기간 여부 확인 (purchaseType === 0이면 trial)
      status = subscriptionResponse.purchaseType === 0
        ? SubscriptionStatus.TRIAL
        : SubscriptionStatus.ACTIVE;
    } else {
      status = SubscriptionStatus.EXPIRED;
    }

    // 구독 티어 판별
    const tier = getSubscriptionTierFromProductId(request.productId) as PremiumTier;

    // 만료 날짜
    const expiryDate = new Date(parseInt(subscriptionResponse.expiryTimeMillis, 10));

    // 시작 날짜
    const startDate = new Date(parseInt(subscriptionResponse.startTimeMillis, 10));

    // 체험 종료 날짜 (체험 기간인 경우)
    let trialEndDate: Date | null = null;
    if (status === SubscriptionStatus.TRIAL) {
      trialEndDate = expiryDate;
    }

    // 취소 시간
    let cancelledAt: Date | undefined;
    if (subscriptionResponse.userCancellationTimeMillis) {
      cancelledAt = new Date(parseInt(subscriptionResponse.userCancellationTimeMillis, 10));
    }

    // Firestore에 저장할 구독 데이터
    const subscriptionData: Omit<Subscription, 'id'> = {
      userId: request.userId,
      tier,
      status,
      platform: Platform.ANDROID,
      startDate,
      expiryDate: tier === PremiumTier.LIFETIME ? null : expiryDate,
      trialEndDate,
      autoRenew: subscriptionResponse.autoRenewing,
      transactionId: subscriptionResponse.orderId,
      productId: request.productId,
      purchaseToken: request.purchaseToken,
      createdAt: new Date(),
      updatedAt: new Date(),
      lastVerifiedAt: new Date(),
      cancelledAt
    };

    // 취소 사유 로깅
    if (subscriptionResponse.cancelReason !== undefined) {
      const cancelReasonText = interpretCancelReason(subscriptionResponse.cancelReason);
      logger.info('Subscription cancelled', {
        userId: request.userId,
        cancelReason: subscriptionResponse.cancelReason,
        cancelReasonText,
        cancelledAt: cancelledAt?.toISOString()
      });
    }

    // Firestore에 저장
    const subscriptionId = await saveSubscriptionToFirestore(subscriptionData);

    logger.info('Android subscription verified and saved successfully', {
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
