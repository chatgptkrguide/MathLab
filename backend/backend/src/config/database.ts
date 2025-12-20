import { Pool, PoolConfig } from 'pg';
import env from './env';
import { createClient } from '@supabase/supabase-js';
import logger from '../utils/logger';

// PostgreSQL Pool Configuration
const poolConfig: PoolConfig = {
  connectionString: env.DATABASE_URL,
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
};

// PostgreSQL Connection Pool
export const pool = new Pool(poolConfig);

pool.on('error', (err) => {
  logger.error('Unexpected error on idle PostgreSQL client', err);
  process.exit(-1);
});

// Supabase Client (우선 사용)
export const supabase = createClient(
  env.SUPABASE_URL,
  env.SUPABASE_SERVICE_ROLE_KEY,
  {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  }
);

// Test Database Connection
export async function testConnection(): Promise<boolean> {
  try {
    // Test Supabase connection
    const { data, error } = await supabase.from('users').select('count').limit(1);
    
    if (error) {
      logger.warn('Supabase connection test failed:', error.message);
      
      // Fallback to PostgreSQL
      const client = await pool.connect();
      const result = await client.query('SELECT NOW()');
      client.release();
      logger.info('PostgreSQL connection successful:', result.rows[0]);
      return true;
    }
    
    logger.info('Supabase connection successful');
    return true;
  } catch (error) {
    logger.error('Database connection failed:', error);
    return false;
  }
}

// Execute Query Helper (Supabase 우선, 실패 시 PostgreSQL)
export async function executeQuery<T = any>(
  query: string,
  params?: any[]
): Promise<T[]> {
  try {
    const client = await pool.connect();
    const result = await client.query(query, params);
    client.release();
    return result.rows as T[];
  } catch (error) {
    logger.error('Query execution failed:', error);
    throw error;
  }
}

// Graceful Shutdown
process.on('SIGINT', async () => {
  await pool.end();
  logger.info('PostgreSQL pool closed');
  process.exit(0);
});
