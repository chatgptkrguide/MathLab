/**
 * Structured logger for Cloud Functions
 */

import * as functions from 'firebase-functions';

interface LogMetadata {
  [key: string]: unknown;
}

interface Logger {
  info(message: string, metadata?: LogMetadata): void;
  error(message: string, error?: Error, metadata?: LogMetadata): void;
  warn(message: string, metadata?: LogMetadata): void;
  debug(message: string, metadata?: LogMetadata): void;
}

export function createLogger(context: string): Logger {
  const formatMessage = (level: string, message: string, metadata?: LogMetadata): string => {
    const base = `[${context}] ${message}`;
    if (metadata && Object.keys(metadata).length > 0) {
      return `${base} ${JSON.stringify(metadata)}`;
    }
    return base;
  };

  return {
    info(message: string, metadata?: LogMetadata): void {
      functions.logger.info(formatMessage('INFO', message, metadata));
    },
    error(message: string, error?: Error, metadata?: LogMetadata): void {
      const errorMeta = error
        ? { ...metadata, errorMessage: error.message, stack: error.stack }
        : metadata;
      functions.logger.error(formatMessage('ERROR', message, errorMeta));
    },
    warn(message: string, metadata?: LogMetadata): void {
      functions.logger.warn(formatMessage('WARN', message, metadata));
    },
    debug(message: string, metadata?: LogMetadata): void {
      functions.logger.debug(formatMessage('DEBUG', message, metadata));
    },
  };
}
