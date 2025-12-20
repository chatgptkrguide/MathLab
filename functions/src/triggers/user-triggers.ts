/**
 * User 관련 Firestore Triggers
 */

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { createLogger } from '../utils/logger';
import {
  sendNotificationToUser,
  NotificationType,
} from '../services/fcm-service';

const logger = createLogger('UserTriggers');
const db = admin.firestore();

/**
 * 신규 사용자 생성 트리거
 *
 * 역할:
 * - 사용자 초기 데이터 설정
 * - Welcome 알림 생성
 * - Bronze League 자동 참가
 */
export const onUserCreated = functions
  .region('asia-northeast3')
  .firestore.document('users/{userId}')
  .onCreate(async (snapshot, context) => {
    const userId = context.params.userId;
    const userData = snapshot.data();

    try {
      logger.info(`New user created: ${userId}`, {
        email: userData.email,
        name: userData.name
      });

      // 1. Welcome 알림 생성
      await db.collection('notifications').add({
        userId,
        type: 'welcome',
        title: 'MathLab에 오신 것을 환영합니다!',
        message: '매일 짧은 시간 동안 수학 학습으로 실력을 향상시켜보세요.',
        isRead: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // 1-1. Welcome 푸시 알림 전송
      await sendNotificationToUser(userId, {
        type: NotificationType.WELCOME,
        title: 'MathLab에 오신 것을 환영합니다! 🎉',
        body: '매일 짧은 시간 동안 수학 학습으로 실력을 향상시켜보세요.',
        actionUrl: '/home',
      });

      // 2. Bronze League 자동 참가
      const now = new Date();
      const weekStart = getWeekStartDate(now);
      const weekEnd = new Date(weekStart);
      weekEnd.setDate(weekEnd.getDate() + 7);

      const leagueId = `bronze_${weekStart.toISOString().split('T')[0]}`;

      // League 문서 생성 또는 업데이트
      await db.collection('leagues').doc(leagueId).set({
        tier: 'LeagueTier.bronze',
        weekStartDate: admin.firestore.Timestamp.fromDate(weekStart),
        weekEndDate: admin.firestore.Timestamp.fromDate(weekEnd),
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });

      // League 참가자 추가
      await db
        .collection('leagues')
        .doc(leagueId)
        .collection('participants')
        .doc(userId)
        .set({
          userId,
          userName: userData.name || 'User',
          weeklyXp: 0,
          avatarUrl: userData.photoUrl || null,
          badges: [],
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

      logger.info(`User ${userId} joined Bronze League: ${leagueId}`);

      // 3. 첫 번째 레슨 잠금 해제 (레슨 데이터가 있다면)
      const lessonsSnapshot = await db
        .collection('lessons')
        .orderBy('order')
        .limit(1)
        .get();

      if (!lessonsSnapshot.empty) {
        const firstLessonDoc = lessonsSnapshot.docs[0];
        await firstLessonDoc.ref.update({
          isUnlocked: true,
        });
        logger.info(`First lesson unlocked for user ${userId}`);
      }

    } catch (error) {
      logger.error('Error in onUserCreated trigger', error as Error);
      // 트리거 실패는 재시도되므로 예외를 던지지 않음
    }
  });

/**
 * 사용자 XP 업데이트 트리거
 *
 * 역할:
 * - 레벨업 감지
 * - 업적 달성 체크
 * - League 순위 업데이트
 */
export const onUserXPUpdated = functions
  .region('asia-northeast3')
  .firestore.document('users/{userId}')
  .onUpdate(async (change, context) => {
    const userId = context.params.userId;
    const beforeData = change.before.data();
    const afterData = change.after.data();

    const beforeXP = beforeData.xp || 0;
    const afterXP = afterData.xp || 0;
    const xpGained = afterXP - beforeXP;

    if (xpGained <= 0) {
      return; // XP 감소나 변화 없음
    }

    try {
      logger.info(`User ${userId} gained ${xpGained} XP (${beforeXP} → ${afterXP})`);

      // 1. 레벨업 체크
      const beforeLevel = beforeData.level || 1;
      const newLevel = calculateLevel(afterXP);

      if (newLevel > beforeLevel) {
        // 레벨업 알림
        await db.collection('notifications').add({
          userId,
          type: 'level_up',
          title: '레벨 업!',
          message: `축하합니다! 레벨 ${newLevel}에 도달했습니다!`,
          isRead: false,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        // 레벨업 푸시 알림
        await sendNotificationToUser(userId, {
          type: NotificationType.LEVEL_UP,
          title: '🎊 레벨 업!',
          body: `축하합니다! 레벨 ${newLevel}에 도달했습니다!`,
          data: {
            level: newLevel.toString(),
          },
          actionUrl: '/profile',
        });

        // 사용자 레벨 업데이트
        await change.after.ref.update({
          level: newLevel,
        });

        logger.info(`User ${userId} leveled up: ${beforeLevel} → ${newLevel}`);
      }

      // 2. League 참가자 주간 XP 업데이트
      const now = new Date();
      const weekStart = getWeekStartDate(now);
      const leagueId = `bronze_${weekStart.toISOString().split('T')[0]}`; // TODO: 사용자의 실제 tier 사용

      const participantRef = db
        .collection('leagues')
        .doc(leagueId)
        .collection('participants')
        .doc(userId);

      const participantDoc = await participantRef.get();

      if (participantDoc.exists) {
        const currentWeeklyXp = participantDoc.data()?.weeklyXp || 0;
        await participantRef.update({
          weeklyXp: currentWeeklyXp + xpGained,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        logger.info(`Updated weekly XP for user ${userId}: +${xpGained}`);
      }

      // 3. 업적 체크 (XP 마일스톤)
      const xpMilestones = [100, 500, 1000, 5000, 10000, 50000];
      for (const milestone of xpMilestones) {
        if (beforeXP < milestone && afterXP >= milestone) {
          await db.collection('notifications').add({
            userId,
            type: 'achievement',
            title: '업적 달성!',
            message: `총 ${milestone} XP를 획득했습니다!`,
            isRead: false,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
          });

          // 업적 달성 푸시 알림
          await sendNotificationToUser(userId, {
            type: NotificationType.ACHIEVEMENT,
            title: '🏆 업적 달성!',
            body: `총 ${milestone} XP를 획득했습니다!`,
            data: {
              milestone: milestone.toString(),
            },
            actionUrl: '/achievements',
          });

          logger.info(`User ${userId} reached XP milestone: ${milestone}`);
        }
      }

    } catch (error) {
      logger.error('Error in onUserXPUpdated trigger', error as Error);
    }
  });

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
 * XP 기반 레벨 계산
 *
 * 레벨 공식: level = floor(sqrt(XP / 100)) + 1
 */
function calculateLevel(xp: number): number {
  return Math.floor(Math.sqrt(xp / 100)) + 1;
}
