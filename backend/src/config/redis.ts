import Redis from 'ioredis';
import { logger } from '../utils/logger';

// Redis Connection
class RedisClient {
  private client: Redis;

  constructor() {
    this.client = new Redis({
      host: process.env.REDIS_HOST || 'localhost',
      port: parseInt(process.env.REDIS_PORT || '6379'),
      password: process.env.REDIS_PASSWORD || undefined,
      retryStrategy: (times) => {
        const delay = Math.min(times * 50, 2000);
        return delay;
      },
      maxRetriesPerRequest: 3,
    });

    this.client.on('connect', () => {
      logger.info('✅ Redis connected');
    });

    this.client.on('error', (err) => {
      logger.error('❌ Redis connection error:', err);
    });

    this.client.on('ready', () => {
      logger.info('Redis is ready to accept commands');
    });
  }

  /**
   * Get Redis client instance
   */
  getClient(): Redis {
    return this.client;
  }

  /**
   * Set value with expiration
   */
  async set(key: string, value: string, expireSeconds?: number): Promise<void> {
    if (expireSeconds) {
      await this.client.setex(key, expireSeconds, value);
    } else {
      await this.client.set(key, value);
    }
  }

  /**
   * Get value
   */
  async get(key: string): Promise<string | null> {
    return await this.client.get(key);
  }

  /**
   * Delete key
   */
  async del(key: string): Promise<void> {
    await this.client.del(key);
  }

  /**
   * Check if key exists
   */
  async exists(key: string): Promise<boolean> {
    const result = await this.client.exists(key);
    return result === 1;
  }

  /**
   * Set hash field
   */
  async hset(key: string, field: string, value: string): Promise<void> {
    await this.client.hset(key, field, value);
  }

  /**
   * Get hash field
   */
  async hget(key: string, field: string): Promise<string | null> {
    return await this.client.hget(key, field);
  }

  /**
   * Get all hash fields
   */
  async hgetall(key: string): Promise<Record<string, string>> {
    return await this.client.hgetall(key);
  }

  /**
   * Add to sorted set (for leaderboard)
   */
  async zadd(key: string, score: number, member: string): Promise<void> {
    await this.client.zadd(key, score, member);
  }

  /**
   * Get sorted set rank (for leaderboard)
   */
  async zrank(key: string, member: string): Promise<number | null> {
    return await this.client.zrank(key, member);
  }

  /**
   * Get sorted set reverse rank (for leaderboard - higher score = better rank)
   */
  async zrevrank(key: string, member: string): Promise<number | null> {
    return await this.client.zrevrank(key, member);
  }

  /**
   * Get sorted set range with scores (for leaderboard top N)
   */
  async zrevrangeWithScores(
    key: string,
    start: number,
    stop: number
  ): Promise<Array<{ member: string; score: number }>> {
    const results = await this.client.zrevrange(key, start, stop, 'WITHSCORES');
    const formatted: Array<{ member: string; score: number }> = [];

    for (let i = 0; i < results.length; i += 2) {
      formatted.push({
        member: results[i],
        score: parseFloat(results[i + 1]),
      });
    }

    return formatted;
  }

  /**
   * Increment hash field (for counters)
   */
  async hincrby(key: string, field: string, increment: number): Promise<number> {
    return await this.client.hincrby(key, field, increment);
  }

  /**
   * Test Redis connection
   */
  async testConnection(): Promise<boolean> {
    try {
      await this.client.ping();
      logger.info('✅ Redis connection successful');
      return true;
    } catch (error) {
      logger.error('❌ Redis connection failed', error);
      return false;
    }
  }

  /**
   * Close Redis connection
   */
  async close(): Promise<void> {
    await this.client.quit();
    logger.info('Redis connection closed');
  }
}

// Export singleton instance
export const redis = new RedisClient();
