/**
 * iOS App Store Connect API 설정
 */

import * as jwt from 'jsonwebtoken';
import { createLogger } from '../utils/logger';
import { BadRequestError } from '../utils/error-handler';

const logger = createLogger('IOSConfig');

/**
 * iOS 환경 설정
 */
export interface IOSConfig {
  keyId: string;
  issuerId: string;
  bundleId: string;
  privateKey: string;
  verifyURL: string;
  sandboxURL: string;
}

/**
 * 환경 변수에서 iOS 설정 로드
 */
export function loadIOSConfig(): IOSConfig {
  const keyId = process.env.IOS_KEY_ID;
  const issuerId = process.env.IOS_ISSUER_ID;
  const bundleId = process.env.IOS_BUNDLE_ID;
  const privateKey = process.env.IOS_PRIVATE_KEY;

  // 필수 환경 변수 검증
  if (!keyId || !issuerId || !bundleId || !privateKey) {
    const missing = [];
    if (!keyId) missing.push('IOS_KEY_ID');
    if (!issuerId) missing.push('IOS_ISSUER_ID');
    if (!bundleId) missing.push('IOS_BUNDLE_ID');
    if (!privateKey) missing.push('IOS_PRIVATE_KEY');

    logger.error('Missing required iOS configuration', undefined, {
      missingVars: missing
    });

    throw new BadRequestError(
      `Missing required iOS configuration: ${missing.join(', ')}`
    );
  }

  const config: IOSConfig = {
    keyId,
    issuerId,
    bundleId,
    privateKey,
    verifyURL: process.env.APP_STORE_VERIFY_URL || 'https://buy.itunes.apple.com/verifyReceipt',
    sandboxURL: process.env.APP_STORE_SANDBOX_URL || 'https://sandbox.itunes.apple.com/verifyReceipt'
  };

  logger.info('iOS configuration loaded successfully', {
    bundleId: config.bundleId,
    hasPrivateKey: !!config.privateKey,
    verifyURL: config.verifyURL
  });

  return config;
}

/**
 * App Store Connect API용 JWT 토큰 생성
 */
export function generateAppStoreConnectToken(config: IOSConfig): string {
  const now = Math.floor(Date.now() / 1000);

  const payload = {
    iss: config.issuerId,
    iat: now,
    exp: now + 20 * 60, // 20분 유효 (최대 60분)
    aud: 'appstoreconnect-v1',
    bid: config.bundleId
  };

  const header = {
    alg: 'ES256',
    kid: config.keyId,
    typ: 'JWT'
  };

  try {
    const token = jwt.sign(payload, config.privateKey, {
      algorithm: 'ES256',
      header
    });

    logger.debug('App Store Connect JWT token generated', {
      issuerId: config.issuerId,
      expiresAt: new Date(payload.exp * 1000).toISOString()
    });

    return token;
  } catch (error) {
    logger.error('Failed to generate JWT token', error as Error);
    throw new Error('Failed to generate App Store Connect JWT token');
  }
}

/**
 * 영수증 검증 URL 결정 (Production vs Sandbox)
 */
export function getVerifyReceiptURL(
  config: IOSConfig,
  isSandbox: boolean = false
): string {
  return isSandbox ? config.sandboxURL : config.verifyURL;
}

/**
 * App Store 영수증 검증 상태 코드 해석
 */
export function interpretReceiptStatus(status: number): {
  isValid: boolean;
  message: string;
  shouldRetry: boolean;
} {
  const statusMessages: Record<number, { message: string; isValid: boolean; shouldRetry: boolean }> = {
    0: {
      message: 'Valid receipt',
      isValid: true,
      shouldRetry: false
    },
    21000: {
      message: 'The App Store could not read the JSON object you provided',
      isValid: false,
      shouldRetry: false
    },
    21002: {
      message: 'The data in the receipt-data property was malformed or missing',
      isValid: false,
      shouldRetry: false
    },
    21003: {
      message: 'The receipt could not be authenticated',
      isValid: false,
      shouldRetry: false
    },
    21004: {
      message: 'The shared secret you provided does not match the shared secret on file',
      isValid: false,
      shouldRetry: false
    },
    21005: {
      message: 'The receipt server is not currently available',
      isValid: false,
      shouldRetry: true
    },
    21006: {
      message: 'This receipt is valid but the subscription has expired',
      isValid: true, // 영수증은 유효하지만 구독 만료
      shouldRetry: false
    },
    21007: {
      message: 'This receipt is from the test environment (sandbox)',
      isValid: false,
      shouldRetry: false // Sandbox URL로 재시도 필요
    },
    21008: {
      message: 'This receipt is from the production environment',
      isValid: false,
      shouldRetry: false // Production URL로 재시도 필요
    },
    21009: {
      message: 'Internal data access error',
      isValid: false,
      shouldRetry: true
    },
    21010: {
      message: 'The user account cannot be found or has been deleted',
      isValid: false,
      shouldRetry: false
    }
  };

  const result = statusMessages[status] || {
    message: `Unknown status code: ${status}`,
    isValid: false,
    shouldRetry: false
  };

  logger.debug('Receipt status interpreted', {
    status,
    ...result
  });

  return result;
}

/**
 * 영수증에서 최신 구독 정보 추출
 */
export function extractLatestSubscription(
  receiptInfo: any[]
): any | null {
  if (!receiptInfo || receiptInfo.length === 0) {
    return null;
  }

  // expires_date_ms 기준으로 정렬하여 최신 구독 찾기
  const sorted = receiptInfo.sort((a, b) => {
    const aExpires = parseInt(a.expires_date_ms || '0', 10);
    const bExpires = parseInt(b.expires_date_ms || '0', 10);
    return bExpires - aExpires;
  });

  return sorted[0];
}

/**
 * 구독이 활성 상태인지 확인
 */
export function isSubscriptionActive(expiresDateMs: string): boolean {
  const expiryTime = parseInt(expiresDateMs, 10);
  const now = Date.now();

  const isActive = expiryTime > now;

  logger.debug('Subscription active status checked', {
    expiresAt: new Date(expiryTime).toISOString(),
    currentTime: new Date(now).toISOString(),
    isActive
  });

  return isActive;
}

/**
 * 무료 체험 기간 여부 확인
 */
export function isTrialPeriod(isTrialPeriodString: string): boolean {
  return isTrialPeriodString === 'true';
}

/**
 * 취소 여부 확인
 */
export function isCancelled(cancellationDateMs?: string): boolean {
  return !!cancellationDateMs;
}
