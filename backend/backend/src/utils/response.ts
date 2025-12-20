import { Response } from 'express';

export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  error?: {
    code: string;
    message: string;
    details?: any;
  };
  message?: string;
}

export class ResponseHandler {
  static success<T>(res: Response, data: T, message?: string, statusCode = 200): void {
    const response: ApiResponse<T> = {
      success: true,
      data,
      message,
    };
    res.status(statusCode).json(response);
  }

  static error(
    res: Response,
    code: string,
    message: string,
    statusCode = 500,
    details?: any
  ): void {
    const response: ApiResponse = {
      success: false,
      error: {
        code,
        message,
        details,
      },
    };
    res.status(statusCode).json(response);
  }

  static validationError(res: Response, errors: any[]): void {
    this.error(res, 'VALIDATION_ERROR', '입력 데이터 검증 실패', 400, errors);
  }

  static unauthorized(res: Response, message = '인증이 필요합니다'): void {
    this.error(res, 'AUTH_REQUIRED', message, 401);
  }

  static forbidden(res: Response, message = '권한이 없습니다'): void {
    this.error(res, 'FORBIDDEN', message, 403);
  }

  static notFound(res: Response, message = '리소스를 찾을 수 없습니다'): void {
    this.error(res, 'NOT_FOUND', message, 404);
  }

  static serverError(res: Response, message = '서버 오류가 발생했습니다'): void {
    this.error(res, 'SERVER_ERROR', message, 500);
  }
}
