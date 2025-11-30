/**
 * Android Google Play Billing API 설정
 */

import { google } from 'googleapis';
import { createLogger } from '../utils/logger';
import { BadRequestError } from '../utils/error-handler';

const logger = createLogger('AndroidConfig');

/**
 * Android 환경 설정
 */
export interface AndroidConfig {
  packageName: string;
  serviceAccountKey: any;
  apiURL: string;
}

/**
 * 환경 변수에서 Android 설정 로드
 */
export function loadAndroidConfig(): AndroidConfig {
  const packageName = process.env.ANDROID_PACKAGE_NAME;
  const serviceAccountKeyJSON = process.env.ANDROID_SERVICE_ACCOUNT_KEY;

  // 필수 환경 변수 검증
  if (!packageName || !serviceAccountKeyJSON) {
    const missing = [];
    if (!packageName) missing.push('ANDROID_PACKAGE_NAME');
    if (!serviceAccountKeyJSON) missing.push('ANDROID_SERVICE_ACCOUNT_KEY');

    logger.error('Missing required Android configuration', undefined, {
      missingVars: missing
    });

    throw new BadRequestError(
      `Missing required Android configuration: ${missing.join(', ')}`
    );
  }

  // Service Account Key JSON 파싱
  let serviceAccountKey;
  try {
    serviceAccountKey = JSON.parse(serviceAccountKeyJSON);
  } catch (error) {
    logger.error('Failed to parse Android service account key JSON', error as Error);
    throw new BadRequestError('Invalid ANDROID_SERVICE_ACCOUNT_KEY: must be valid JSON');
  }

  const config: AndroidConfig = {
    packageName,
    serviceAccountKey,
    apiURL: process.env.GOOGLE_PLAY_API_URL || 'https://androidpublisher.googleapis.com/androidpublisher/v3'
  };

  logger.info('Android configuration loaded successfully', {
    packageName: config.packageName,
    hasServiceAccountKey: !!config.serviceAccountKey,
    apiURL: config.apiURL
  });

  return config;
}

/**
 * Google Play API 클라이언트 생성
 */
export async function createGooglePlayClient(config: AndroidConfig) {
  try {
    // Service Account로 인증
    const auth = new google.auth.GoogleAuth({
      credentials: config.serviceAccountKey,
      scopes: ['https://www.googleapis.com/auth/androidpublisher']
    });

    const authClient = await auth.getClient();

    // Google Play Developer API 클라이언트 생성
    const androidPublisher = google.androidpublisher({
      version: 'v3',
      auth: authClient as any
    });

    logger.debug('Google Play API client created successfully');

    return androidPublisher;
  } catch (error) {
    logger.error('Failed to create Google Play API client', error as Error);
    throw new Error('Failed to authenticate with Google Play API');
  }
}

/**
 * 구독 상태 코드 해석
 */
export function interpretSubscriptionState(paymentState: number): {
  status: 'active' | 'cancelled' | 'paused' | 'expired';
  message: string;
} {
  const states: Record<number, { status: any; message: string }> = {
    0: {
      status: 'paused',
      message: 'Payment pending'
    },
    1: {
      status: 'active',
      message: 'Payment received'
    },
    2: {
      status: 'active',
      message: 'Free trial'
    },
    3: {
      status: 'paused',
      message: 'Pending deferred upgrade/downgrade'
    }
  };

  const result = states[paymentState] || {
    status: 'expired',
    message: `Unknown payment state: ${paymentState}`
  };

  logger.debug('Subscription state interpreted', {
    paymentState,
    ...result
  });

  return result;
}

/**
 * 취소 사유 코드 해석
 */
export function interpretCancelReason(cancelReason?: number): string {
  if (cancelReason === undefined) {
    return 'Not cancelled';
  }

  const reasons: Record<number, string> = {
    0: 'User cancelled the subscription',
    1: 'Subscription was cancelled by the system (e.g., billing issue)',
    2: 'Subscription was replaced with a new subscription',
    3: 'Subscription was cancelled by the developer'
  };

  return reasons[cancelReason] || `Unknown cancel reason: ${cancelReason}`;
}

/**
 * 구독이 활성 상태인지 확인
 */
export function isSubscriptionActive(
  expiryTimeMillis: string,
  autoRenewing: boolean
): boolean {
  const expiryTime = parseInt(expiryTimeMillis, 10);
  const now = Date.now();

  // 만료 시간이 미래이고 자동 갱신 중이면 활성
  const isActive = expiryTime > now && autoRenewing;

  logger.debug('Android subscription active status checked', {
    expiresAt: new Date(expiryTime).toISOString(),
    currentTime: new Date(now).toISOString(),
    autoRenewing,
    isActive
  });

  return isActive;
}

/**
 * 구독이 유예 기간인지 확인
 */
export function isInGracePeriod(
  expiryTimeMillis: string,
  autoRenewing: boolean
): boolean {
  const expiryTime = parseInt(expiryTimeMillis, 10);
  const now = Date.now();

  // 만료되었지만 자동 갱신은 활성화된 경우 (결제 재시도 중)
  const inGracePeriod = expiryTime <= now && autoRenewing;

  logger.debug('Grace period status checked', {
    expiresAt: new Date(expiryTime).toISOString(),
    currentTime: new Date(now).toISOString(),
    autoRenewing,
    inGracePeriod
  });

  return inGracePeriod;
}

/**
 * Product ID로 구독 티어 판별
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

/**
 * Notification Type 해석
 */
export function interpretNotificationType(notificationType: number): {
  type: string;
  action: 'activate' | 'deactivate' | 'update' | 'none';
  message: string;
} {
  const types: Record<number, { type: string; action: any; message: string }> = {
    1: {
      type: 'SUBSCRIPTION_RECOVERED',
      action: 'activate',
      message: 'Subscription recovered from account hold'
    },
    2: {
      type: 'SUBSCRIPTION_RENEWED',
      action: 'update',
      message: 'Active subscription renewed'
    },
    3: {
      type: 'SUBSCRIPTION_CANCELED',
      action: 'deactivate',
      message: 'Subscription voluntarily cancelled by user'
    },
    4: {
      type: 'SUBSCRIPTION_PURCHASED',
      action: 'activate',
      message: 'New subscription purchased'
    },
    5: {
      type: 'SUBSCRIPTION_ON_HOLD',
      action: 'deactivate',
      message: 'Subscription in account hold (billing issue)'
    },
    6: {
      type: 'SUBSCRIPTION_IN_GRACE_PERIOD',
      action: 'update',
      message: 'Subscription in grace period (payment retry)'
    },
    7: {
      type: 'SUBSCRIPTION_RESTARTED',
      action: 'activate',
      message: 'Subscription reactivated'
    },
    8: {
      type: 'SUBSCRIPTION_PRICE_CHANGE_CONFIRMED',
      action: 'update',
      message: 'User confirmed subscription price increase'
    },
    9: {
      type: 'SUBSCRIPTION_DEFERRED',
      action: 'update',
      message: 'Subscription renewal deferred to future date'
    },
    10: {
      type: 'SUBSCRIPTION_PAUSED',
      action: 'deactivate',
      message: 'Subscription paused'
    },
    11: {
      type: 'SUBSCRIPTION_PAUSE_SCHEDULE_CHANGED',
      action: 'update',
      message: 'Subscription pause schedule changed'
    },
    12: {
      type: 'SUBSCRIPTION_REVOKED',
      action: 'deactivate',
      message: 'Subscription revoked (refund issued)'
    },
    13: {
      type: 'SUBSCRIPTION_EXPIRED',
      action: 'deactivate',
      message: 'Subscription expired'
    }
  };

  const result = types[notificationType] || {
    type: 'UNKNOWN',
    action: 'none',
    message: `Unknown notification type: ${notificationType}`
  };

  logger.debug('Notification type interpreted', {
    notificationType,
    ...result
  });

  return result;
}

/**
 * Pub/Sub 메시지 디코딩
 */
export function decodePubSubMessage(message: any): any {
  try {
    // Pub/Sub 메시지는 base64로 인코딩되어 있음
    const data = message.data;
    const decodedData = Buffer.from(data, 'base64').toString('utf-8');
    const parsedData = JSON.parse(decodedData);

    logger.debug('Pub/Sub message decoded successfully', {
      messageId: message.messageId,
      publishTime: message.publishTime
    });

    return parsedData;
  } catch (error) {
    logger.error('Failed to decode Pub/Sub message', error as Error, {
      messageId: message.messageId
    });
    throw new Error('Failed to decode Pub/Sub message');
  }
}
