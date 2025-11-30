/**
 * Webhook 관련 타입 정의
 */

/**
 * iOS Server-to-Server Notification 타입
 */
export enum IOSNotificationType {
  DID_RENEW = 'DID_RENEW',
  DID_FAIL_TO_RENEW = 'DID_FAIL_TO_RENEW',
  DID_CHANGE_RENEWAL_STATUS = 'DID_CHANGE_RENEWAL_STATUS',
  EXPIRED = 'EXPIRED',
  CANCEL = 'CANCEL',
  REFUND = 'REFUND',
  INITIAL_BUY = 'INITIAL_BUY',
  INTERACTIVE_RENEWAL = 'INTERACTIVE_RENEWAL',
  DID_CHANGE_RENEWAL_PREF = 'DID_CHANGE_RENEWAL_PREF',
  PRICE_INCREASE_CONSENT = 'PRICE_INCREASE_CONSENT'
}

/**
 * iOS Webhook Payload (Simplified)
 */
export interface IOSWebhookPayload {
  notification_type: IOSNotificationType;
  unified_receipt: {
    latest_receipt: string;
    latest_receipt_info: Array<{
      product_id: string;
      transaction_id: string;
      original_transaction_id: string;
      purchase_date_ms: string;
      expires_date_ms: string;
      is_trial_period: string;
      cancellation_date_ms?: string;
      auto_renew_status?: string;
    }>;
  };
  environment: 'PROD' | 'Sandbox';
}

/**
 * Android Real-time Developer Notification 타입
 */
export enum AndroidNotificationType {
  SUBSCRIPTION_RECOVERED = 1,
  SUBSCRIPTION_RENEWED = 2,
  SUBSCRIPTION_CANCELED = 3,
  SUBSCRIPTION_PURCHASED = 4,
  SUBSCRIPTION_ON_HOLD = 5,
  SUBSCRIPTION_IN_GRACE_PERIOD = 6,
  SUBSCRIPTION_RESTARTED = 7,
  SUBSCRIPTION_PRICE_CHANGE_CONFIRMED = 8,
  SUBSCRIPTION_DEFERRED = 9,
  SUBSCRIPTION_PAUSED = 10,
  SUBSCRIPTION_PAUSE_SCHEDULE_CHANGED = 11,
  SUBSCRIPTION_REVOKED = 12,
  SUBSCRIPTION_EXPIRED = 13
}

/**
 * Android Webhook Payload (Pub/Sub Message)
 */
export interface AndroidWebhookPayload {
  version: string;
  packageName: string;
  eventTimeMillis: string;
  subscriptionNotification?: {
    version: string;
    notificationType: AndroidNotificationType;
    purchaseToken: string;
    subscriptionId: string;
  };
}

/**
 * Webhook 처리 결과
 */
export interface WebhookProcessResult {
  success: boolean;
  notificationType: string;
  userId?: string;
  subscriptionId?: string;
  action: string;
  error?: string;
}
