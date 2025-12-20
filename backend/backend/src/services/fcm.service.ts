import admin from 'firebase-admin';
import { supabase } from '../config/database';
import logger from '../utils/logger';

export interface FcmToken {
  id: number;
  user_id: string;
  token: string;
  device_type: 'ios' | 'android' | 'web';
  device_id?: string;
  created_at: Date;
  updated_at: Date;
}

export interface SendNotificationPayload {
  userId?: string;
  userIds?: string[];
  topic?: string;
  title: string;
  body: string;
  data?: Record<string, string>;
  imageUrl?: string;
}

export class FcmService {
  /**
   * FCM 토큰 저장 또는 갱신
   */
  async saveToken(
    userId: string,
    token: string,
    deviceType: 'ios' | 'android' | 'web',
    deviceId?: string
  ): Promise<FcmToken> {
    try {
      const { data, error } = await supabase
        .from('fcm_tokens')
        .upsert(
          {
            user_id: userId,
            token,
            device_type: deviceType,
            device_id: deviceId,
            updated_at: new Date().toISOString(),
          },
          {
            onConflict: 'user_id,device_id',
          }
        )
        .select()
        .single();

      if (error) throw error;

      logger.info(`FCM token saved for user ${userId}`);
      return data as FcmToken;
    } catch (error) {
      logger.error('Error saving FCM token:', error);
      throw error;
    }
  }

  /**
   * 사용자의 FCM 토큰 조회
   */
  async getTokens(userId: string): Promise<FcmToken[]> {
    try {
      const { data, error } = await supabase
        .from('fcm_tokens')
        .select('*')
        .eq('user_id', userId);

      if (error) throw error;

      return data as FcmToken[];
    } catch (error) {
      logger.error('Error fetching FCM tokens:', error);
      throw error;
    }
  }

  /**
   * FCM 토큰 삭제
   */
  async deleteToken(userId: string, deviceId?: string): Promise<void> {
    try {
      const query = supabase
        .from('fcm_tokens')
        .delete()
        .eq('user_id', userId);

      if (deviceId) {
        query.eq('device_id', deviceId);
      }

      const { error } = await query;

      if (error) throw error;

      logger.info(`FCM token deleted for user ${userId}`);
    } catch (error) {
      logger.error('Error deleting FCM token:', error);
      throw error;
    }
  }

  /**
   * 토픽 구독
   */
  async subscribeToTopic(token: string, topic: string): Promise<void> {
    try {
      await admin.messaging().subscribeToTopic(token, topic);
      logger.info(`Token subscribed to topic: ${topic}`);
    } catch (error) {
      logger.error('Error subscribing to topic:', error);
      throw error;
    }
  }

  /**
   * 토픽 구독 해제
   */
  async unsubscribeFromTopic(token: string, topic: string): Promise<void> {
    try {
      await admin.messaging().unsubscribeFromTopic(token, topic);
      logger.info(`Token unsubscribed from topic: ${topic}`);
    } catch (error) {
      logger.error('Error unsubscribing from topic:', error);
      throw error;
    }
  }

  /**
   * 푸시 알림 전송
   */
  async sendNotification(payload: SendNotificationPayload): Promise<void> {
    try {
      const message: admin.messaging.Message = {
        notification: {
          title: payload.title,
          body: payload.body,
          ...(payload.imageUrl && { imageUrl: payload.imageUrl }),
        },
        data: payload.data,
      };

      // 특정 사용자에게 전송
      if (payload.userId) {
        const tokens = await this.getTokens(payload.userId);
        if (tokens.length === 0) {
          logger.warn(`No FCM tokens found for user ${payload.userId}`);
          return;
        }

        const tokenStrings = tokens.map((t) => t.token);
        await admin.messaging().sendEachForMulticast({
          tokens: tokenStrings,
          ...message,
        });

        logger.info(`Notification sent to user ${payload.userId}`);
      }
      // 여러 사용자에게 전송
      else if (payload.userIds && payload.userIds.length > 0) {
        const { data: tokens, error } = await supabase
          .from('fcm_tokens')
          .select('token')
          .in('user_id', payload.userIds);

        if (error) throw error;

        if (!tokens || tokens.length === 0) {
          logger.warn('No FCM tokens found for specified users');
          return;
        }

        const tokenStrings = tokens.map((t) => t.token);
        await admin.messaging().sendEachForMulticast({
          tokens: tokenStrings,
          ...message,
        });

        logger.info(`Notification sent to ${payload.userIds.length} users`);
      }
      // 토픽으로 전송
      else if (payload.topic) {
        await admin.messaging().send({
          topic: payload.topic,
          ...message,
        });

        logger.info(`Notification sent to topic ${payload.topic}`);
      }
    } catch (error) {
      logger.error('Error sending notification:', error);
      throw error;
    }
  }
}

export default new FcmService();
