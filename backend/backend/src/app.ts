import express, { Express, Request, Response, NextFunction } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import env from './config/env';
import logger from './utils/logger';
import { ResponseHandler } from './utils/response';

// Routes
import fcmRoutes from './routes/fcm.routes';

const app: Express = express();

// Security middleware
app.use(helmet());
app.use(cors({
  origin: env.ALLOWED_ORIGINS,
  credentials: true,
}));

// Body parsing middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: '요청이 너무 많습니다. 잠시 후 다시 시도해주세요.',
});
app.use('/api/', limiter);

// Request logging
app.use((req: Request, res: Response, next: NextFunction) => {
  logger.info(`${req.method} ${req.url}`);
  next();
});

// Health check
app.get('/health', (req: Request, res: Response) => {
  ResponseHandler.success(res, { status: 'OK', timestamp: new Date().toISOString() });
});

// API routes
app.use(`/api/${env.API_VERSION}/fcm`, fcmRoutes);
// TODO: Add auth routes
// TODO: Add payment routes

// 404 handler
app.use((req: Request, res: Response) => {
  ResponseHandler.notFound(res, `경로를 찾을 수 없습니다: ${req.url}`);
});

// Error handler
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  logger.error('Unhandled error:', err);
  ResponseHandler.serverError(res, err.message);
});

export default app;
