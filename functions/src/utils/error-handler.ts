/**
 * 에러 처리 및 커스텀 에러 클래스
 */

import { createLogger } from './logger';

const logger = createLogger('ErrorHandler');

/**
 * 커스텀 에러 베이스 클래스
 */
export class AppError extends Error {
  constructor(
    public statusCode: number,
    public message: string,
    public isOperational: boolean = true,
    public errorCode?: string
  ) {
    super(message);
    Object.setPrototypeOf(this, AppError.prototype);
    Error.captureStackTrace(this, this.constructor);
  }
}

/**
 * 영수증 검증 실패 에러
 */
export class ReceiptVerificationError extends AppError {
  constructor(message: string, errorCode?: string) {
    super(400, message, true, errorCode);
    this.name = 'ReceiptVerificationError';
  }
}

/**
 * 외부 API 호출 실패 에러
 */
export class ExternalAPIError extends AppError {
  constructor(message: string, statusCode: number = 502) {
    super(statusCode, message, true, 'EXTERNAL_API_ERROR');
    this.name = 'ExternalAPIError';
  }
}

/**
 * 인증 실패 에러
 */
export class AuthenticationError extends AppError {
  constructor(message: string = 'Authentication failed') {
    super(401, message, true, 'AUTH_ERROR');
    this.name = 'AuthenticationError';
  }
}

/**
 * 리소스를 찾을 수 없음
 */
export class NotFoundError extends AppError {
  constructor(message: string = 'Resource not found') {
    super(404, message, true, 'NOT_FOUND');
    this.name = 'NotFoundError';
  }
}

/**
 * 잘못된 요청 에러
 */
export class BadRequestError extends AppError {
  constructor(message: string) {
    super(400, message, true, 'BAD_REQUEST');
    this.name = 'BadRequestError';
  }
}

/**
 * Webhook 검증 실패 에러
 */
export class WebhookVerificationError extends AppError {
  constructor(message: string = 'Webhook verification failed') {
    super(401, message, true, 'WEBHOOK_VERIFICATION_ERROR');
    this.name = 'WebhookVerificationError';
  }
}

/**
 * 에러 응답 포맷터
 */
export interface ErrorResponse {
  success: false;
  error: {
    code: string;
    message: string;
    statusCode: number;
    timestamp: string;
    details?: any;
  };
}

/**
 * HTTP 함수용 에러 응답 생성
 */
export function formatErrorResponse(error: Error | AppError): ErrorResponse {
  const isAppError = error instanceof AppError;

  const response: ErrorResponse = {
    success: false,
    error: {
      code: isAppError ? error.errorCode || 'INTERNAL_ERROR' : 'INTERNAL_ERROR',
      message: error.message || 'An unexpected error occurred',
      statusCode: isAppError ? error.statusCode : 500,
      timestamp: new Date().toISOString()
    }
  };

  // 프로덕션 환경에서는 스택 트레이스 제거
  if (process.env.NODE_ENV === 'production') {
    // 스택 트레이스를 로그에만 남기고 응답에는 포함하지 않음
    logger.error('Error occurred', error);
  } else {
    // 개발 환경에서는 디버깅을 위해 스택 트레이스 포함
    response.error.details = {
      stack: error.stack
    };
  }

  return response;
}

/**
 * 재시도 로직 with Exponential Backoff
 */
export async function retryWithBackoff<T>(
  operation: () => Promise<T>,
  options: {
    maxRetries?: number;
    initialDelayMs?: number;
    maxDelayMs?: number;
    backoffMultiplier?: number;
    retryableErrors?: string[];
  } = {}
): Promise<T> {
  const {
    maxRetries = 3,
    initialDelayMs = 1000,
    maxDelayMs = 10000,
    backoffMultiplier = 2,
    retryableErrors = ['ECONNRESET', 'ETIMEDOUT', 'ENOTFOUND']
  } = options;

  let lastError: Error;
  let delayMs = initialDelayMs;

  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      return await operation();
    } catch (error: any) {
      lastError = error;

      // 마지막 시도였다면 에러 throw
      if (attempt === maxRetries) {
        break;
      }

      // 재시도 가능한 에러인지 확인
      const isRetryable = retryableErrors.some(code =>
        error.code === code || error.message?.includes(code)
      );

      if (!isRetryable) {
        // 재시도 불가능한 에러는 즉시 throw
        throw error;
      }

      // Exponential Backoff 대기
      logger.warn(`Retry attempt ${attempt + 1}/${maxRetries} after ${delayMs}ms`, {
        error: error.message,
        attempt: attempt + 1,
        delayMs
      });

      await sleep(delayMs);

      // 다음 재시도를 위한 delay 증가 (최대값 제한)
      delayMs = Math.min(delayMs * backoffMultiplier, maxDelayMs);
    }
  }

  // 모든 재시도 실패
  throw lastError!;
}

/**
 * Sleep 유틸리티
 */
function sleep(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms));
}

/**
 * 에러 카테고리 판별
 */
export function categorizeError(error: Error | AppError): 'client' | 'server' | 'external' {
  if (error instanceof AppError) {
    if (error.statusCode >= 400 && error.statusCode < 500) {
      return 'client';
    }
    if (error instanceof ExternalAPIError) {
      return 'external';
    }
    return 'server';
  }

  // 일반 에러는 서버 에러로 분류
  return 'server';
}

/**
 * 에러를 안전하게 로깅
 */
export function logError(error: Error | AppError, context?: Record<string, any>): void {
  const category = categorizeError(error);
  const isAppError = error instanceof AppError;

  logger.error(
    `[${category.toUpperCase()}] ${error.message}`,
    error,
    {
      category,
      errorCode: isAppError ? error.errorCode : undefined,
      statusCode: isAppError ? error.statusCode : undefined,
      isOperational: isAppError ? error.isOperational : false,
      ...context
    }
  );
}
