/**
 * 입력 검증 유틸리티
 */

import { BadRequestError } from './error-handler';

/**
 * 필수 필드 검증
 */
export function requireFields<T extends Record<string, any>>(
  data: T,
  requiredFields: (keyof T)[]
): void {
  const missingFields = requiredFields.filter(field => {
    const value = data[field];
    return value === undefined || value === null || value === '';
  });

  if (missingFields.length > 0) {
    throw new BadRequestError(
      `Missing required fields: ${missingFields.join(', ')}`
    );
  }
}

/**
 * 이메일 형식 검증
 */
export function validateEmail(email: string): boolean {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

/**
 * userId 형식 검증 (Firebase UID 형식)
 */
export function validateUserId(userId: string): void {
  if (!userId || typeof userId !== 'string') {
    throw new BadRequestError('Invalid userId: must be a non-empty string');
  }

  // Firebase UID는 보통 28자의 영숫자 문자열
  if (userId.length < 10 || userId.length > 128) {
    throw new BadRequestError('Invalid userId: length must be between 10 and 128 characters');
  }

  // 영숫자와 일부 특수문자만 허용
  const validPattern = /^[a-zA-Z0-9_-]+$/;
  if (!validPattern.test(userId)) {
    throw new BadRequestError('Invalid userId: contains invalid characters');
  }
}

/**
 * Base64 인코딩된 영수증 데이터 검증
 */
export function validateReceiptData(receiptData: string): void {
  if (!receiptData || typeof receiptData !== 'string') {
    throw new BadRequestError('Invalid receiptData: must be a non-empty string');
  }

  // Base64 형식 검증
  const base64Regex = /^[A-Za-z0-9+/]+=*$/;
  if (!base64Regex.test(receiptData)) {
    throw new BadRequestError('Invalid receiptData: must be valid Base64 encoded string');
  }

  // 최소 길이 검증 (너무 짧은 영수증은 유효하지 않음)
  if (receiptData.length < 100) {
    throw new BadRequestError('Invalid receiptData: too short');
  }
}

/**
 * iOS 제품 ID 검증
 */
export function validateIOSProductId(productId: string): void {
  if (!productId || typeof productId !== 'string') {
    throw new BadRequestError('Invalid productId: must be a non-empty string');
  }

  // iOS 제품 ID 형식: com.company.product.subscription
  const validPattern = /^[a-zA-Z0-9._-]+$/;
  if (!validPattern.test(productId)) {
    throw new BadRequestError('Invalid productId: contains invalid characters');
  }

  if (productId.length < 5 || productId.length > 255) {
    throw new BadRequestError('Invalid productId: length must be between 5 and 255 characters');
  }
}

/**
 * Android 구매 토큰 검증
 */
export function validatePurchaseToken(purchaseToken: string): void {
  if (!purchaseToken || typeof purchaseToken !== 'string') {
    throw new BadRequestError('Invalid purchaseToken: must be a non-empty string');
  }

  // Android 구매 토큰은 매우 긴 문자열
  if (purchaseToken.length < 50) {
    throw new BadRequestError('Invalid purchaseToken: too short');
  }

  // 영숫자와 일부 특수문자만 허용
  const validPattern = /^[a-zA-Z0-9._-]+$/;
  if (!validPattern.test(purchaseToken)) {
    throw new BadRequestError('Invalid purchaseToken: contains invalid characters');
  }
}

/**
 * Android 패키지명 검증
 */
export function validatePackageName(packageName: string): void {
  if (!packageName || typeof packageName !== 'string') {
    throw new BadRequestError('Invalid packageName: must be a non-empty string');
  }

  // 패키지명 형식: com.company.app
  const validPattern = /^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$/;
  if (!validPattern.test(packageName)) {
    throw new BadRequestError('Invalid packageName: must follow reverse domain notation (e.g., com.company.app)');
  }
}

/**
 * 트랜잭션 ID 검증
 */
export function validateTransactionId(transactionId: string): void {
  if (!transactionId || typeof transactionId !== 'string') {
    throw new BadRequestError('Invalid transactionId: must be a non-empty string');
  }

  if (transactionId.length < 5 || transactionId.length > 255) {
    throw new BadRequestError('Invalid transactionId: length must be between 5 and 255 characters');
  }

  // 영숫자와 일부 특수문자만 허용
  const validPattern = /^[a-zA-Z0-9._-]+$/;
  if (!validPattern.test(transactionId)) {
    throw new BadRequestError('Invalid transactionId: contains invalid characters');
  }
}

/**
 * iOS 영수증 검증 요청 검증
 */
export function validateIOSReceiptRequest(request: any): void {
  // 필수 필드 검증
  requireFields(request, ['userId', 'receiptData', 'transactionId', 'productId']);

  // 개별 필드 검증
  validateUserId(request.userId);
  validateReceiptData(request.receiptData);
  validateTransactionId(request.transactionId);
  validateIOSProductId(request.productId);
}

/**
 * Android 영수증 검증 요청 검증
 */
export function validateAndroidReceiptRequest(request: any): void {
  // 필수 필드 검증
  requireFields(request, ['userId', 'purchaseToken', 'productId', 'packageName']);

  // 개별 필드 검증
  validateUserId(request.userId);
  validatePurchaseToken(request.purchaseToken);
  validateIOSProductId(request.productId); // Android도 동일한 형식 사용
  validatePackageName(request.packageName);
}

/**
 * Webhook 서명 검증 (iOS)
 *
 * TODO: 실제 프로덕션 배포 전에 HMAC 또는 JWT 서명 검증 구현 필요
 * 현재는 기본 검증만 수행 (보안 취약점 존재)
 *
 * @deprecated 프로덕션에서는 실제 암호화 서명 검증 구현 필요
 */
export function validateWebhookSignature(
  payload: string,
  signature: string,
  secret: string
): boolean {
  if (!payload || !signature || !secret) {
    return false;
  }

  // ⚠️ 경고: 실제 서명 검증이 구현되지 않았습니다
  // 프로덕션 배포 전에 crypto 모듈을 사용한 HMAC-SHA256 검증 구현 필요
  // 예시:
  // const crypto = require('crypto');
  // const expectedSignature = crypto
  //   .createHmac('sha256', secret)
  //   .update(payload)
  //   .digest('hex');
  // return crypto.timingSafeEqual(
  //   Buffer.from(signature),
  //   Buffer.from(expectedSignature)
  // );

  console.warn('[SECURITY WARNING] Webhook signature validation not implemented');
  return true;
}

/**
 * 날짜 형식 검증 (ISO 8601)
 */
export function validateISODate(dateString: string): void {
  const date = new Date(dateString);
  if (isNaN(date.getTime())) {
    throw new BadRequestError(`Invalid date format: ${dateString}`);
  }
}

/**
 * 숫자 범위 검증
 */
export function validateNumberRange(
  value: number,
  min: number,
  max: number,
  fieldName: string = 'value'
): void {
  if (typeof value !== 'number' || isNaN(value)) {
    throw new BadRequestError(`Invalid ${fieldName}: must be a number`);
  }

  if (value < min || value > max) {
    throw new BadRequestError(
      `Invalid ${fieldName}: must be between ${min} and ${max}`
    );
  }
}

/**
 * Enum 값 검증
 */
export function validateEnum<T extends Record<string, string>>(
  value: string,
  enumType: T,
  fieldName: string = 'value'
): void {
  const validValues = Object.values(enumType);
  if (!validValues.includes(value)) {
    throw new BadRequestError(
      `Invalid ${fieldName}: must be one of [${validValues.join(', ')}]`
    );
  }
}

/**
 * URL 형식 검증
 */
export function validateURL(url: string): void {
  try {
    new URL(url);
  } catch (error) {
    throw new BadRequestError(`Invalid URL format: ${url}`);
  }
}

/**
 * 배열 검증
 */
export function validateArray<T>(
  value: any,
  minLength: number = 0,
  maxLength: number = Number.MAX_SAFE_INTEGER,
  fieldName: string = 'array'
): void {
  if (!Array.isArray(value)) {
    throw new BadRequestError(`Invalid ${fieldName}: must be an array`);
  }

  if (value.length < minLength || value.length > maxLength) {
    throw new BadRequestError(
      `Invalid ${fieldName}: length must be between ${minLength} and ${maxLength}`
    );
  }
}

/**
 * 객체 검증
 */
export function validateObject(
  value: any,
  fieldName: string = 'object'
): void {
  if (typeof value !== 'object' || value === null || Array.isArray(value)) {
    throw new BadRequestError(`Invalid ${fieldName}: must be an object`);
  }
}
