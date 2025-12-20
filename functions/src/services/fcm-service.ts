/**
 * Firebase Cloud Messaging (FCM) Service
 *
 * 역할:
 * - 푸시 알림 전송
 * - 알림 타입별 메시지 템플릿
 * - 사용자별 FCM 토큰 관리
 * - 멀티캐스트 전송
 */

import * as admin from 'firebase-admin';
import { createLogger } from '../utils/logger';

const logger = createLogger('FCMService');

/**
 * 알림 타입 정의
 */
export enum NotificationType {
  WELCOME = 'welcome',
  LEVEL_UP = 'level_up',
  ACHIEVEMENT = 'achievement',
  LEAGUE_PROMOTION = 'league_promotion',
  LEAGUE_RELEGATION = 'league_relegation',
  LEAGUE_SEASON_END = 'league_season_end',
  LEAGUE_RANK = 'league_rank',
  LEAGUE_REMINDER = 'league_reminder',
  DAILY_REMINDER = 'daily_reminder',
  STREAK_REMINDER = 'streak_reminder',
  LESSON_UNLOCK = 'lesson_unlock',
  FRIEND_REQUEST = 'friend_request',
  FRIEND_ACCEPTED = 'friend_accepted',
  CHALLENGE_INVITATION = 'challenge_invitation',
}

/**
 * 알림 페이로드 인터페이스
 */
export interface NotificationPayload {
  type: NotificationType;
  title: string;
  body: string;
  data?: Record<string, string>;
  imageUrl?: string;
  actionUrl?: string;
}

/**
 * 단일 사용자에게 푸시 알림 전송
 *
 * @param userId 사용자 ID
 * @param payload 알림 내용
 * @returns 전송 성공 여부
 */
export async function sendNotificationToUser(
  userId: string,
  payload: NotificationPayload
): Promise<boolean> {
  try {
    // 사용자 FCM 토큰 조회
    const fcmTokens = await getUserFCMTokens(userId);

    if (fcmTokens.length === 0) {
      logger.warning(`No FCM tokens found for user: ${userId}`);
      return false;
    }

    // FCM 메시지 구성
    const message = buildFCMMessage(payload, fcmTokens[0]);

    // 전송
    const response = await admin.messaging().send(message);

    logger.info(`Notification sent to user ${userId}`, {
      messageId: response,
      type: payload.type,
    });

    return true;
  } catch (error) {
    logger.error(`Failed to send notification to user ${userId}`, error as Error);
    return false;
  }
}

/**
 * 여러 사용자에게 동일한 알림 전송 (멀티캐스트)
 *
 * @param userIds 사용자 ID 배열
 * @param payload 알림 내용
 * @returns 성공/실패 결과
 */
export async function sendNotificationToMultipleUsers(
  userIds: string[],
  payload: NotificationPayload
): Promise<{ successCount: number; failureCount: number }> {
  try {
    // 모든 사용자의 FCM 토큰 수집
    const tokensPromises = userIds.map((userId) => getUserFCMTokens(userId));
    const tokensArrays = await Promise.all(tokensPromises);
    const allTokens = tokensArrays.flat();

    if (allTokens.length === 0) {
      logger.warning('No FCM tokens found for any user');
      return { successCount: 0, failureCount: userIds.length };
    }

    // 멀티캐스트 메시지 구성
    const message = buildMulticastMessage(payload, allTokens);

    // 전송
    const response = await admin.messaging().sendEachForMulticast(message);

    logger.info(`Multicast notification sent to ${userIds.length} users`, {
      successCount: response.successCount,
      failureCount: response.failureCount,
      type: payload.type,
    });

    // 실패한 토큰 정리 (invalid tokens)
    if (response.failureCount > 0) {
      await cleanupInvalidTokens(allTokens, response.responses);
    }

    return {
      successCount: response.successCount,
      failureCount: response.failureCount,
    };
  } catch (error) {
    logger.error('Failed to send multicast notification', error as Error);
    return { successCount: 0, failureCount: userIds.length };
  }
}

/**
 * 토픽에 메시지 전송 (전체 사용자 브로드캐스트)
 *
 * @param topic 토픽 이름
 * @param payload 알림 내용
 * @returns 전송 성공 여부
 */
export async function sendNotificationToTopic(
  topic: string,
  payload: NotificationPayload
): Promise<boolean> {
  try {
    const message = buildTopicMessage(payload, topic);
    const response = await admin.messaging().send(message);

    logger.info(`Notification sent to topic: ${topic}`, {
      messageId: response,
      type: payload.type,
    });

    return true;
  } catch (error) {
    logger.error(`Failed to send notification to topic: ${topic}`, error as Error);
    return false;
  }
}

/**
 * FCM 토큰 등록
 *
 * @param userId 사용자 ID
 * @param fcmToken FCM 토큰
 * @param platform 플랫폼 (ios, android, web)
 */
export async function registerFCMToken(
  userId: string,
  fcmToken: string,
  platform: 'ios' | 'android' | 'web'
): Promise<void> {
  try {
    const db = admin.firestore();
    const tokenRef = db.collection('users').doc(userId).collection('fcmTokens').doc(fcmToken);

    await tokenRef.set({
      token: fcmToken,
      platform: platform,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    logger.info(`FCM token registered for user ${userId}`, { platform });
  } catch (error) {
    logger.error(`Failed to register FCM token for user ${userId}`, error as Error);
    throw error;
  }
}

/**
 * FCM 토큰 삭제 (로그아웃 시)
 *
 * @param userId 사용자 ID
 * @param fcmToken FCM 토큰
 */
export async function removeFCMToken(userId: string, fcmToken: string): Promise<void> {
  try {
    const db = admin.firestore();
    await db.collection('users').doc(userId).collection('fcmTokens').doc(fcmToken).delete();

    logger.info(`FCM token removed for user ${userId}`);
  } catch (error) {
    logger.error(`Failed to remove FCM token for user ${userId}`, error as Error);
  }
}

/**
 * 사용자 FCM 토큰 조회
 *
 * @param userId 사용자 ID
 * @returns FCM 토큰 배열
 */
async function getUserFCMTokens(userId: string): Promise<string[]> {
  try {
    const db = admin.firestore();
    const tokensSnapshot = await db
      .collection('users')
      .doc(userId)
      .collection('fcmTokens')
      .get();

    if (tokensSnapshot.empty) {
      return [];
    }

    return tokensSnapshot.docs.map((doc) => doc.data().token as string);
  } catch (error) {
    logger.error(`Failed to get FCM tokens for user ${userId}`, error as Error);
    return [];
  }
}

/**
 * FCM 메시지 구성 (단일 전송)
 */
function buildFCMMessage(
  payload: NotificationPayload,
  token: string
): admin.messaging.Message {
  const message: admin.messaging.Message = {
    token: token,
    notification: {
      title: payload.title,
      body: payload.body,
    },
    data: {
      type: payload.type,
      ...(payload.data || {}),
    },
    android: {
      notification: {
        sound: 'default',
        channelId: getChannelId(payload.type),
        priority: 'high' as const,
        imageUrl: payload.imageUrl,
        clickAction: payload.actionUrl,
      },
    },
    apns: {
      payload: {
        aps: {
          sound: 'default',
          badge: 1,
          contentAvailable: true,
        },
      },
      fcmOptions: {
        imageUrl: payload.imageUrl,
      },
    },
    webpush: {
      notification: {
        icon: '/assets/icons/icon-192x192.png',
        badge: '/assets/icons/badge-72x72.png',
        image: payload.imageUrl,
      },
      fcmOptions: {
        link: payload.actionUrl,
      },
    },
  };

  return message;
}

/**
 * 멀티캐스트 메시지 구성
 */
function buildMulticastMessage(
  payload: NotificationPayload,
  tokens: string[]
): admin.messaging.MulticastMessage {
  return {
    tokens: tokens,
    notification: {
      title: payload.title,
      body: payload.body,
    },
    data: {
      type: payload.type,
      ...(payload.data || {}),
    },
    android: {
      notification: {
        sound: 'default',
        channelId: getChannelId(payload.type),
        priority: 'high' as const,
        imageUrl: payload.imageUrl,
      },
    },
    apns: {
      payload: {
        aps: {
          sound: 'default',
          badge: 1,
          contentAvailable: true,
        },
      },
      fcmOptions: {
        imageUrl: payload.imageUrl,
      },
    },
    webpush: {
      notification: {
        icon: '/assets/icons/icon-192x192.png',
        badge: '/assets/icons/badge-72x72.png',
        image: payload.imageUrl,
      },
      fcmOptions: {
        link: payload.actionUrl,
      },
    },
  };
}

/**
 * 토픽 메시지 구성
 */
function buildTopicMessage(
  payload: NotificationPayload,
  topic: string
): admin.messaging.Message {
  return {
    topic: topic,
    notification: {
      title: payload.title,
      body: payload.body,
    },
    data: {
      type: payload.type,
      ...(payload.data || {}),
    },
    android: {
      notification: {
        sound: 'default',
        channelId: getChannelId(payload.type),
        priority: 'high' as const,
        imageUrl: payload.imageUrl,
      },
    },
    apns: {
      payload: {
        aps: {
          sound: 'default',
          badge: 1,
          contentAvailable: true,
        },
      },
      fcmOptions: {
        imageUrl: payload.imageUrl,
      },
    },
    webpush: {
      notification: {
        icon: '/assets/icons/icon-192x192.png',
        badge: '/assets/icons/badge-72x72.png',
        image: payload.imageUrl,
      },
      fcmOptions: {
        link: payload.actionUrl,
      },
    },
  };
}

/**
 * 알림 타입별 Android 채널 ID
 */
function getChannelId(type: NotificationType): string {
  switch (type) {
    case NotificationType.LEVEL_UP:
    case NotificationType.ACHIEVEMENT:
    case NotificationType.LEAGUE_PROMOTION:
      return 'achievement_channel';

    case NotificationType.LEAGUE_RELEGATION:
    case NotificationType.LEAGUE_SEASON_END:
    case NotificationType.LEAGUE_RANK:
      return 'league_channel';

    case NotificationType.DAILY_REMINDER:
    case NotificationType.STREAK_REMINDER:
    case NotificationType.LEAGUE_REMINDER:
      return 'reminder_channel';

    case NotificationType.FRIEND_REQUEST:
    case NotificationType.FRIEND_ACCEPTED:
    case NotificationType.CHALLENGE_INVITATION:
      return 'social_channel';

    default:
      return 'default_channel';
  }
}

/**
 * 유효하지 않은 토큰 정리
 */
async function cleanupInvalidTokens(
  tokens: string[],
  responses: admin.messaging.SendResponse[]
): Promise<void> {
  try {
    const db = admin.firestore();
    const invalidTokens: string[] = [];

    responses.forEach((response, index) => {
      if (!response.success && response.error) {
        const errorCode = response.error.code;
        // Invalid token errors
        if (
          errorCode === 'messaging/invalid-registration-token' ||
          errorCode === 'messaging/registration-token-not-registered'
        ) {
          invalidTokens.push(tokens[index]);
        }
      }
    });

    if (invalidTokens.length > 0) {
      logger.info(`Cleaning up ${invalidTokens.length} invalid FCM tokens`);

      // Firestore에서 유효하지 않은 토큰 삭제
      const batch = db.batch();
      const usersSnapshot = await db.collection('users').get();

      for (const userDoc of usersSnapshot.docs) {
        const tokensSnapshot = await userDoc.ref.collection('fcmTokens').get();

        tokensSnapshot.docs.forEach((tokenDoc) => {
          if (invalidTokens.includes(tokenDoc.data().token)) {
            batch.delete(tokenDoc.ref);
          }
        });
      }

      await batch.commit();
      logger.info('Invalid FCM tokens cleaned up successfully');
    }
  } catch (error) {
    logger.error('Failed to cleanup invalid tokens', error as Error);
  }
}
