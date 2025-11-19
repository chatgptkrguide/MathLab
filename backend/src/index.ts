import express, { Request, Response, NextFunction } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';
import rateLimit from 'express-rate-limit';
import { logger, stream } from './utils/logger';
import { db } from './config/database';
import { redis } from './config/redis';

// Load environment variables
dotenv.config();

const app = express();
const PORT = process.env.PORT || 8080;
const API_VERSION = process.env.API_VERSION || 'v1';

// ==================== Middleware ====================

// Security headers
app.use(helmet());

// CORS
const corsOrigins = process.env.CORS_ORIGIN?.split(',') || ['http://localhost:3000'];
app.use(
  cors({
    origin: corsOrigins,
    credentials: true,
  })
);

// Body parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Rate limiting
const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '60000'), // 1 minute
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100'), // 100 requests per windowMs
  message: {
    success: false,
    error: 'Too many requests',
    message: 'Please try again later',
  },
  standardHeaders: true,
  legacyHeaders: false,
});
app.use(limiter);

// HTTP request logging
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    logger.http(`${req.method} ${req.path} ${res.statusCode} - ${duration}ms`);
  });
  next();
});

// ==================== Routes ====================

// Health check
app.get('/health', async (req: Request, res: Response) => {
  try {
    const dbHealthy = await db.testConnection();
    const redisHealthy = await redis.testConnection();

    const status = dbHealthy && redisHealthy ? 'healthy' : 'degraded';
    const statusCode = dbHealthy && redisHealthy ? 200 : 503;

    res.status(statusCode).json({
      success: true,
      status,
      timestamp: new Date().toISOString(),
      services: {
        database: dbHealthy ? 'up' : 'down',
        redis: redisHealthy ? 'up' : 'down',
      },
    });
  } catch (error) {
    logger.error('Health check error:', error);
    res.status(503).json({
      success: false,
      status: 'unhealthy',
      error: 'Service unavailable',
    });
  }
});

// API version info
app.get(`/api/${API_VERSION}`, (req: Request, res: Response) => {
  res.json({
    success: true,
    message: 'MathLab API Server',
    version: API_VERSION,
    timestamp: new Date().toISOString(),
    endpoints: {
      auth: `/api/${API_VERSION}/auth`,
      users: `/api/${API_VERSION}/users`,
      lessons: `/api/${API_VERSION}/lessons`,
      problems: `/api/${API_VERSION}/problems`,
      achievements: `/api/${API_VERSION}/achievements`,
      leaderboard: `/api/${API_VERSION}/leaderboard`,
    },
  });
});

// API Routes
import authRoutes from './routes/auth.routes';
import userRoutes from './routes/user.routes';
import lessonRoutes from './routes/lesson.routes';
import problemRoutes from './routes/problem.routes';
import leaderboardRoutes from './routes/leaderboard.routes';

app.use(`/api/${API_VERSION}/auth`, authRoutes);
app.use(`/api/${API_VERSION}/users`, userRoutes);
app.use(`/api/${API_VERSION}/lessons`, lessonRoutes);
app.use(`/api/${API_VERSION}/problems`, problemRoutes);
app.use(`/api/${API_VERSION}/leaderboard`, leaderboardRoutes);

// ==================== Error Handling ====================

// 404 handler
app.use((req: Request, res: Response) => {
  res.status(404).json({
    success: false,
    error: 'Not found',
    message: `Route ${req.method} ${req.path} not found`,
  });
});

// Global error handler
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  logger.error('Unhandled error:', err);

  res.status(500).json({
    success: false,
    error: 'Internal server error',
    message: process.env.NODE_ENV === 'development' ? err.message : 'An unexpected error occurred',
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
  });
});

// ==================== Server Startup ====================

async function startServer() {
  try {
    // Test database connection
    logger.info('Testing database connection...');
    const dbConnected = await db.testConnection();
    if (!dbConnected) {
      throw new Error('Failed to connect to database');
    }

    // Test Redis connection
    logger.info('Testing Redis connection...');
    const redisConnected = await redis.testConnection();
    if (!redisConnected) {
      logger.warn('Redis connection failed, continuing without cache');
    }

    // Start server
    app.listen(PORT, () => {
      logger.info(`🚀 MathLab API Server is running!`);
      logger.info(`📡 Port: ${PORT}`);
      logger.info(`🌐 Environment: ${process.env.NODE_ENV || 'development'}`);
      logger.info(`📊 API Version: ${API_VERSION}`);
      logger.info(`✅ Health check: http://localhost:${PORT}/health`);
      logger.info(`📖 API docs: http://localhost:${PORT}/api/${API_VERSION}`);
    });
  } catch (error) {
    logger.error('Failed to start server:', error);
    process.exit(1);
  }
}

// Graceful shutdown
process.on('SIGTERM', async () => {
  logger.info('SIGTERM signal received: closing HTTP server');
  await db.close();
  await redis.close();
  process.exit(0);
});

process.on('SIGINT', async () => {
  logger.info('SIGINT signal received: closing HTTP server');
  await db.close();
  await redis.close();
  process.exit(0);
});

// Start the server
startServer();

export default app;
