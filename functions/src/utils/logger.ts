/**
 * 구조화된 로깅 유틸리티
 */

export enum LogLevel {
  DEBUG = 'DEBUG',
  INFO = 'INFO',
  WARN = 'WARN',
  ERROR = 'ERROR'
}

interface LogMetadata {
  [key: string]: any;
}

/**
 * 구조화된 로그 출력
 */
export class Logger {
  private context: string;

  constructor(context: string) {
    this.context = context;
  }

  /**
   * DEBUG 레벨 로그
   */
  debug(message: string, metadata?: LogMetadata): void {
    this.log(LogLevel.DEBUG, message, metadata);
  }

  /**
   * INFO 레벨 로그
   */
  info(message: string, metadata?: LogMetadata): void {
    this.log(LogLevel.INFO, message, metadata);
  }

  /**
   * WARN 레벨 로그
   */
  warn(message: string, metadata?: LogMetadata): void {
    this.log(LogLevel.WARN, message, metadata);
  }

  /**
   * ERROR 레벨 로그
   */
  error(message: string, error?: Error, metadata?: LogMetadata): void {
    const errorMetadata = error ? {
      errorMessage: error.message,
      errorStack: error.stack,
      ...metadata
    } : metadata;

    this.log(LogLevel.ERROR, message, errorMetadata);
  }

  /**
   * 구조화된 로그 출력
   */
  private log(level: LogLevel, message: string, metadata?: LogMetadata): void {
    const logEntry = {
      timestamp: new Date().toISOString(),
      level,
      context: this.context,
      message,
      ...metadata
    };

    // Console 출력 (Cloud Logging으로 자동 전송)
    switch (level) {
      case LogLevel.DEBUG:
      case LogLevel.INFO:
        console.log(JSON.stringify(logEntry));
        break;
      case LogLevel.WARN:
        console.warn(JSON.stringify(logEntry));
        break;
      case LogLevel.ERROR:
        console.error(JSON.stringify(logEntry));
        break;
    }
  }

  /**
   * 함수 실행 시간 측정
   */
  async measureTime<T>(
    operation: string,
    fn: () => Promise<T>
  ): Promise<T> {
    const startTime = Date.now();

    try {
      const result = await fn();
      const duration = Date.now() - startTime;

      this.info(`Operation completed: ${operation}`, {
        operation,
        duration,
        status: 'success'
      });

      return result;
    } catch (error) {
      const duration = Date.now() - startTime;

      this.error(`Operation failed: ${operation}`, error as Error, {
        operation,
        duration,
        status: 'failed'
      });

      throw error;
    }
  }
}

/**
 * 로거 인스턴스 생성 헬퍼
 */
export function createLogger(context: string): Logger {
  return new Logger(context);
}
