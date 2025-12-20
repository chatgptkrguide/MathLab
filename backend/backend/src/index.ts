import app from './app';
import env from './config/env';
import { testConnection } from './config/database';
import logger from './utils/logger';
import admin from 'firebase-admin';

// Firebase Admin 초기화
if (env.FIREBASE_PROJECT_ID && env.FIREBASE_PRIVATE_KEY && env.FIREBASE_CLIENT_EMAIL) {
  admin.initializeApp({
    credential: admin.credential.cert({
      projectId: env.FIREBASE_PROJECT_ID,
      privateKey: env.FIREBASE_PRIVATE_KEY,
      clientEmail: env.FIREBASE_CLIENT_EMAIL,
    }),
  });
  logger.info('Firebase Admin SDK initialized');
} else {
  logger.warn('Firebase credentials not configured - FCM features will be unavailable');
}

// Start server
async function startServer() {
  try {
    // Test database connection
    const dbConnected = await testConnection();
    if (!dbConnected) {
      logger.error('Database connection failed - exiting');
      process.exit(1);
    }

    // Start listening
    const PORT = env.PORT;
    app.listen(PORT, () => {
      logger.info('Server running on port ' + PORT);
      logger.info('Environment: ' + env.NODE_ENV);
      logger.info('API Version: ' + env.API_VERSION);
    });
  } catch (error) {
    logger.error('Failed to start server:', error);
    process.exit(1);
  }
}

startServer();

// Graceful shutdown
process.on('SIGTERM', () => {
  logger.info('SIGTERM signal received - shutting down gracefully');
  process.exit(0);
});

process.on('SIGINT', () => {
  logger.info('SIGINT signal received - shutting down gracefully');
  process.exit(0);
});
