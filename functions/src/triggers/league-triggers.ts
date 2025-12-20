/**
 * League 관련 Firestore Triggers 및 Scheduled Functions
 */

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { createLogger } from '../utils/logger';
import {
  sendNotificationToUser,
  NotificationType,
} from '../services/fcm-service';

const logger = createLogger('LeagueTriggers');
const db = admin.firestore();

/**
 * 주간 리그 리셋 (매주 월요일 00:00 실행)
 *
 * 역할:
 * - 지난 주 리그 종료 처리
 * - 승급/강등 처리
 * - 새로운 주차 리그 생성
 */
export const weeklyLeagueReset = functions
  .region('asia-northeast3')
  .pubsub.schedule('0 0 * * 1') // Every Monday at 00:00 (KST)
  .timeZone('Asia/Seoul')
  .onRun(async (context) => {
    try {
      logger.info('Starting weekly league reset...');

      const now = new Date();
      const lastWeekStart = getWeekStartDate(new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000));
      const lastWeekEnd = new Date(lastWeekStart);
      lastWeekEnd.setDate(lastWeekEnd.getDate() + 7);

      // 모든 티어의 지난 주 리그 조회
      const tiers = ['bronze', 'silver', 'gold', 'platinum', 'diamond', 'champion'];

      for (const tier of tiers) {
        const leagueId = `${tier}_${lastWeekStart.toISOString().split('T')[0]}`;
        logger.info(`Processing ${tier} league: ${leagueId}`);

        await processLeagueSeason(leagueId, tier);
      }

      logger.info('Weekly league reset completed successfully');
    } catch (error) {
      logger.error('Error in weekly league reset', error as Error);
      throw error; // Cloud Scheduler will retry
    }
  });

/**
 * 리그 시즌 처리 (승급/강등 및 보상)
 */
async function processLeagueSeason(leagueId: string, tier: string) {
  try {
    // 참가자 순위대로 조회
    const participantsSnapshot = await db
      .collection('leagues')
      .doc(leagueId)
      .collection('participants')
      .orderBy('weeklyXp', 'desc')
      .get();

    if (participantsSnapshot.empty) {
      logger.info(`No participants in league: ${leagueId}`);
      return;
    }

    const participants = participantsSnapshot.docs;
    const totalParticipants = participants.length;

    // 승급/강등 기준
    const promotionCount = Math.min(10, Math.floor(totalParticipants * 0.2)); // 상위 20% (최대 10명)
    const relegationCount = tier !== 'bronze' ? Math.min(5, Math.floor(totalParticipants * 0.1)) : 0; // 하위 10% (최대 5명)

    const batch = db.batch();

    // 각 참가자 처리
    for (let i = 0; i < participants.length; i++) {
      const participant = participants[i];
      const rank = i + 1;
      const userId = participant.id;
      const data = participant.data();

      // 승급 처리
      if (rank <= promotionCount && tier !== 'champion') {
        const nextTier = getNextTier(tier);
        logger.info(`Promoting user ${userId} from ${tier} to ${nextTier}`);

        await createPromotionNotification(userId, tier, nextTier, rank, batch);
        await updateUserTier(userId, nextTier, batch);
      }
      // 강등 처리
      else if (rank > totalParticipants - relegationCount && tier !== 'bronze') {
        const previousTier = getPreviousTier(tier);
        logger.info(`Relegating user ${userId} from ${tier} to ${previousTier}`);

        await createRelegationNotification(userId, tier, previousTier, rank, batch);
        await updateUserTier(userId, previousTier, batch);
      }
      // 유지
      else {
        logger.info(`User ${userId} stays in ${tier} (rank: ${rank})`);
        await createSeasonEndNotification(userId, tier, rank, data.weeklyXp, batch);
      }

      // 뱃지 부여
      await awardBadges(userId, rank, data.weeklyXp, totalParticipants, batch);
    }

    // 리그 아카이브 (종료 마크)
    batch.update(db.collection('leagues').doc(leagueId), {
      status: 'completed',
      completedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    await batch.commit();
    logger.info(`League season processed: ${leagueId} (${totalParticipants} participants)`);
  } catch (error) {
    logger.error(`Error processing league season: ${leagueId}`, error as Error);
    throw error;
  }
}

/**
 * 승급 알림 생성
 */
async function createPromotionNotification(
  userId: string,
  currentTier: string,
  nextTier: string,
  rank: number,
  batch: admin.firestore.WriteBatch
) {
  const notificationRef = db.collection('notifications').doc();
  batch.set(notificationRef, {
    userId,
    type: 'league_promotion',
    title: '🎉 승급하셨습니다!',
    message: `축하합니다! ${currentTier} 리그 ${rank}위로 ${nextTier} 리그로 승급하셨습니다!`,
    data: {
      fromTier: currentTier,
      toTier: nextTier,
      rank: rank,
    },
    isRead: false,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // 승급 푸시 알림 (batch 외부에서 실행)
  setImmediate(async () => {
    await sendNotificationToUser(userId, {
      type: NotificationType.LEAGUE_PROMOTION,
      title: '🎉 승급하셨습니다!',
      body: `축하합니다! ${currentTier} 리그 ${rank}위로 ${nextTier} 리그로 승급하셨습니다!`,
      data: {
        fromTier: currentTier,
        toTier: nextTier,
        rank: rank.toString(),
      },
      actionUrl: '/league',
    });
  });
}

/**
 * 강등 알림 생성
 */
async function createRelegationNotification(
  userId: string,
  currentTier: string,
  previousTier: string,
  rank: number,
  batch: admin.firestore.WriteBatch
) {
  const notificationRef = db.collection('notifications').doc();
  batch.set(notificationRef, {
    userId,
    type: 'league_relegation',
    title: '강등되었습니다',
    message: `${currentTier} 리그 ${rank}위로 ${previousTier} 리그로 강등되었습니다. 다음 주에 다시 도전해보세요!`,
    data: {
      fromTier: currentTier,
      toTier: previousTier,
      rank: rank,
    },
    isRead: false,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // 강등 푸시 알림
  setImmediate(async () => {
    await sendNotificationToUser(userId, {
      type: NotificationType.LEAGUE_RELEGATION,
      title: '강등되었습니다',
      body: `${currentTier} 리그 ${rank}위로 ${previousTier} 리그로 강등되었습니다. 다음 주에 다시 도전해보세요!`,
      data: {
        fromTier: currentTier,
        toTier: previousTier,
        rank: rank.toString(),
      },
      actionUrl: '/league',
    });
  });
}

/**
 * 시즌 종료 알림 생성 (유지)
 */
async function createSeasonEndNotification(
  userId: string,
  tier: string,
  rank: number,
  weeklyXp: number,
  batch: admin.firestore.WriteBatch
) {
  const notificationRef = db.collection('notifications').doc();
  batch.set(notificationRef, {
    userId,
    type: 'league_season_end',
    title: '리그 시즌 종료',
    message: `${tier} 리그에서 ${rank}위를 기록하셨습니다! 주간 XP: ${weeklyXp}`,
    data: {
      tier: tier,
      rank: rank,
      weeklyXp: weeklyXp,
    },
    isRead: false,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

/**
 * 사용자 티어 업데이트
 */
async function updateUserTier(
  userId: string,
  newTier: string,
  batch: admin.firestore.WriteBatch
) {
  const userRef = db.collection('users').doc(userId);
  batch.update(userRef, {
    tier: `LeagueTier.${newTier}`,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

/**
 * 뱃지 부여 로직
 */
async function awardBadges(
  userId: string,
  rank: number,
  weeklyXp: number,
  totalParticipants: number,
  batch: admin.firestore.WriteBatch
) {
  const badges: string[] = [];

  // 1위: 득점왕 뱃지
  if (rank === 1) {
    badges.push('LeagueBadge.topScorer');
  }

  // 주간 XP가 매우 높을 때: 완벽 뱃지 (예: 1000 XP 이상)
  if (weeklyXp >= 1000) {
    badges.push('LeagueBadge.perfect');
  }

  // 순위 급상승 체크 (이전 주와 비교 - 추후 구현)
  // TODO: 이전 주 순위 데이터와 비교하여 5단계 이상 상승 시 rising 뱃지

  if (badges.length > 0) {
    const now = new Date();
    const weekStart = getWeekStartDate(now);
    const currentTier = await getUserCurrentTier(userId);
    const leagueId = `${currentTier}_${weekStart.toISOString().split('T')[0]}`;

    const participantRef = db
      .collection('leagues')
      .doc(leagueId)
      .collection('participants')
      .doc(userId);

    batch.update(participantRef, {
      badges: admin.firestore.FieldValue.arrayUnion(...badges),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    logger.info(`Awarded badges to user ${userId}: ${badges.join(', ')}`);
  }
}

/**
 * 사용자 현재 티어 조회
 */
async function getUserCurrentTier(userId: string): Promise<string> {
  const userDoc = await db.collection('users').doc(userId).get();
  const userData = userDoc.data();
  const tierString = userData?.tier || 'LeagueTier.bronze';
  return tierString.split('.')[1]; // "LeagueTier.bronze" → "bronze"
}

/**
 * 다음 티어 계산
 */
function getNextTier(currentTier: string): string {
  const tiers = ['bronze', 'silver', 'gold', 'platinum', 'diamond', 'champion'];
  const currentIndex = tiers.indexOf(currentTier);
  return currentIndex < tiers.length - 1 ? tiers[currentIndex + 1] : currentTier;
}

/**
 * 이전 티어 계산
 */
function getPreviousTier(currentTier: string): string {
  const tiers = ['bronze', 'silver', 'gold', 'platinum', 'diamond', 'champion'];
  const currentIndex = tiers.indexOf(currentTier);
  return currentIndex > 0 ? tiers[currentIndex - 1] : currentTier;
}

/**
 * 주차 시작일 계산 (월요일 00:00 기준)
 */
function getWeekStartDate(date: Date): Date {
  const weekday = date.getDay(); // Sunday = 0, Monday = 1
  const daysToMonday = weekday === 0 ? 6 : weekday - 1;
  const weekStart = new Date(date);
  weekStart.setDate(date.getDate() - daysToMonday);
  weekStart.setHours(0, 0, 0, 0);
  return weekStart;
}

/**
 * 리그 참가자 XP 업데이트 시 실시간 순위 갱신 트리거
 *
 * 역할:
 * - 참가자 순위 실시간 계산
 * - 순위 변동 알림 (선택적)
 */
export const onLeagueParticipantUpdated = functions
  .region('asia-northeast3')
  .firestore.document('leagues/{leagueId}/participants/{userId}')
  .onUpdate(async (change, context) => {
    const leagueId = context.params.leagueId;
    const userId = context.params.userId;

    const beforeXP = change.before.data().weeklyXp || 0;
    const afterXP = change.after.data().weeklyXp || 0;

    if (beforeXP === afterXP) {
      return; // XP 변화 없음
    }

    try {
      // 실시간 순위 재계산은 클라이언트에서 orderBy로 자동 처리되므로
      // 여기서는 주요 순위 변동만 감지 (예: 1위 달성)

      const participantsSnapshot = await db
        .collection('leagues')
        .doc(leagueId)
        .collection('participants')
        .orderBy('weeklyXp', 'desc')
        .limit(1)
        .get();

      if (!participantsSnapshot.empty) {
        const topParticipant = participantsSnapshot.docs[0];

        // 새로 1위가 된 경우 알림
        if (topParticipant.id === userId && beforeXP < topParticipant.data().weeklyXp) {
          await db.collection('notifications').add({
            userId,
            type: 'league_rank',
            title: '🏆 1위 달성!',
            message: '축하합니다! 현재 리그에서 1위를 차지하고 있습니다!',
            data: {
              leagueId,
              rank: 1,
              weeklyXp: afterXP,
            },
            isRead: false,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
          });
          logger.info(`User ${userId} reached rank 1 in league ${leagueId}`);
        }
      }
    } catch (error) {
      logger.error('Error in onLeagueParticipantUpdated', error as Error);
      // 순위 알림 실패는 중요하지 않으므로 예외를 던지지 않음
    }
  });

/**
 * 일일 리그 활동 체크 (매일 23:00 실행)
 *
 * 역할:
 * - 활동하지 않은 사용자에게 리마인더 알림
 * - 리그 종료 D-1 알림
 */
export const dailyLeagueReminder = functions
  .region('asia-northeast3')
  .pubsub.schedule('0 23 * * *') // Every day at 23:00 (KST)
  .timeZone('Asia/Seoul')
  .onRun(async (context) => {
    try {
      logger.info('Starting daily league reminder...');

      const now = new Date();
      const weekStart = getWeekStartDate(now);
      const weekEnd = new Date(weekStart);
      weekEnd.setDate(weekEnd.getDate() + 7);

      // 리그 종료까지 남은 시간
      const timeUntilEnd = weekEnd.getTime() - now.getTime();
      const daysUntilEnd = Math.ceil(timeUntilEnd / (1000 * 60 * 60 * 24));

      // 리그 종료 1일 전이면 알림
      if (daysUntilEnd === 1) {
        logger.info('Sending league end reminders (D-1)');
        await sendLeagueEndReminders(weekStart);
      }

      // 오늘 활동하지 않은 사용자에게 리마인더
      await sendInactiveUserReminders();

      logger.info('Daily league reminder completed');
    } catch (error) {
      logger.error('Error in daily league reminder', error as Error);
    }
  });

/**
 * 리그 종료 1일 전 알림 발송
 */
async function sendLeagueEndReminders(weekStart: Date) {
  try {
    const tiers = ['bronze', 'silver', 'gold', 'platinum', 'diamond', 'champion'];

    for (const tier of tiers) {
      const leagueId = `${tier}_${weekStart.toISOString().split('T')[0]}`;

      const participantsSnapshot = await db
        .collection('leagues')
        .doc(leagueId)
        .collection('participants')
        .get();

      const batch = db.batch();

      participantsSnapshot.docs.forEach((doc) => {
        const notificationRef = db.collection('notifications').doc();
        batch.set(notificationRef, {
          userId: doc.id,
          type: 'league_reminder',
          title: '⏰ 리그 종료 임박!',
          message: '리그 시즌이 내일 종료됩니다. 마지막 기회를 놓치지 마세요!',
          data: {
            tier: tier,
            daysRemaining: 1,
          },
          isRead: false,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      });

      await batch.commit();
      logger.info(`Sent league end reminders to ${tier} league (${participantsSnapshot.size} users)`);
    }
  } catch (error) {
    logger.error('Error sending league end reminders', error as Error);
  }
}

/**
 * 비활동 사용자 리마인더 발송
 */
async function sendInactiveUserReminders() {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // 오늘 학습 활동이 없는 사용자 조회
    const usersSnapshot = await db
      .collection('users')
      .where('lastActivityDate', '<', admin.firestore.Timestamp.fromDate(today))
      .limit(500) // 배치 크기 제한
      .get();

    if (usersSnapshot.empty) {
      logger.info('No inactive users found');
      return;
    }

    const batch = db.batch();

    usersSnapshot.docs.forEach((doc) => {
      const notificationRef = db.collection('notifications').doc();
      batch.set(notificationRef, {
        userId: doc.id,
        type: 'daily_reminder',
        title: '📚 학습 시간이에요!',
        message: '오늘 아직 학습하지 않으셨네요. 스트릭을 유지하고 리그 순위를 올려보세요!',
        isRead: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    await batch.commit();
    logger.info(`Sent reminders to ${usersSnapshot.size} inactive users`);
  } catch (error) {
    logger.error('Error sending inactive user reminders', error as Error);
  }
}
