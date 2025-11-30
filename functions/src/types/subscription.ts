/**
 * 구독 관련 타입 정의
 */

export enum PremiumTier {
  MONTHLY = 'monthly',
  YEARLY = 'yearly',
  LIFETIME = 'lifetime'
}

export enum SubscriptionStatus {
  ACTIVE = 'active',
  TRIAL = 'trial',
  CANCELLED = 'cancelled',
  EXPIRED = 'expired',
  PAUSED = 'paused'
}

export enum Platform {
  IOS = 'ios',
  ANDROID = 'android'
}

/**
 * Firestore 구독 문서 구조
 */
export interface Subscription {
  id: string;
  userId: string;
  tier: PremiumTier;
  status: SubscriptionStatus;
  platform: Platform;
  startDate: Date;
  expiryDate: Date | null;
  trialEndDate: Date | null;
  autoRenew: boolean;

  // Platform-specific identifiers
  transactionId: string; // iOS: original_transaction_id, Android: orderId
  productId: string; // iOS/Android: product ID
  purchaseToken?: string; // Android only
  originalReceipt?: string; // iOS only

  // Metadata
  createdAt: Date;
  updatedAt: Date;
  lastVerifiedAt?: Date;
  cancelledAt?: Date;
}

/**
 * iOS 영수증 검증 요청
 */
export interface IOSReceiptVerificationRequest {
  userId: string;
  receiptData: string; // Base64 encoded
  transactionId: string;
  productId: string;
}

/**
 * iOS 영수증 검증 응답
 */
export interface IOSReceiptVerificationResponse {
  success: boolean;
  subscriptionId?: string;
  expiryDate?: Date;
  tier?: PremiumTier;
  error?: string;
}

/**
 * Android 영수증 검증 요청
 */
export interface AndroidReceiptVerificationRequest {
  userId: string;
  purchaseToken: string;
  productId: string;
  packageName: string;
}

/**
 * Android 영수증 검증 응답
 */
export interface AndroidReceiptVerificationResponse {
  success: boolean;
  subscriptionId?: string;
  expiryDate?: Date;
  tier?: PremiumTier;
  error?: string;
}

/**
 * App Store Server API 영수증 응답 (간소화)
 */
export interface AppStoreReceiptResponse {
  status: number;
  environment: 'Production' | 'Sandbox';
  receipt: {
    in_app: Array<{
      product_id: string;
      transaction_id: string;
      original_transaction_id: string;
      purchase_date_ms: string;
      expires_date_ms: string;
      is_trial_period: string;
      cancellation_date_ms?: string;
    }>;
  };
  latest_receipt_info?: Array<{
    product_id: string;
    transaction_id: string;
    original_transaction_id: string;
    purchase_date_ms: string;
    expires_date_ms: string;
    is_trial_period: string;
    cancellation_date_ms?: string;
  }>;
}

/**
 * Google Play API 구독 응답
 */
export interface GooglePlaySubscriptionResponse {
  kind: string;
  startTimeMillis: string;
  expiryTimeMillis: string;
  autoRenewing: boolean;
  priceCurrencyCode: string;
  priceAmountMicros: string;
  countryCode: string;
  developerPayload: string;
  paymentState: number; // 0: Pending, 1: Received, 2: Free trial, 3: Pending deferred
  cancelReason?: number;
  userCancellationTimeMillis?: string;
  orderId: string;
  linkedPurchaseToken?: string;
  purchaseType?: number;
}

/**
 * 구독 동기화 결과
 */
export interface SyncResult {
  userId: string;
  subscriptionId: string;
  synced: boolean;
  changes?: string[];
  error?: string;
}
