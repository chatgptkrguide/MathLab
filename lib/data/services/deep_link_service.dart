import 'package:flutter/material.dart';
import '../../shared/utils/logger.dart';

/// FCM 알림 타입
enum NotificationType {
  leagueUpdate,       // 리그 업데이트
  friendRequest,      // 친구 요청
  achievement,        // 업적 달성
  streakReminder,     // 연속 학습 리마인더
  lessonComplete,     // 레슨 완료
  weeklyTestAvailable, // 주간 테스트 가능
  premiumOffer,       // 프리미엄 제안
  customMessage,      // 커스텀 메시지
  unknown,            // 알 수 없는 타입
}

/// FCM 딥링크 서비스
///
/// 알림 타입에 따라 적절한 화면으로 네비게이션
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  /// 알림 데이터를 파싱하여 화면 이동
  Future<void> handleNotification(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    try {
      Logger.info('딥링크 처리 시작: $data', tag: 'DeepLink');

      // 알림 타입 파싱
      final type = parseNotificationType(data['type']);
      
      // 타입별 네비게이션
      switch (type) {
        case NotificationType.leagueUpdate:
          await _navigateToLeague(context, data);
          break;
        
        case NotificationType.friendRequest:
          await _navigateToFriends(context, data);
          break;
        
        case NotificationType.achievement:
          await _navigateToAchievements(context, data);
          break;
        
        case NotificationType.streakReminder:
          await _navigateToHome(context);
          break;
        
        case NotificationType.lessonComplete:
          await _navigateToLesson(context, data);
          break;
        
        case NotificationType.weeklyTestAvailable:
          await _navigateToWeeklyTest(context, data);
          break;
        
        case NotificationType.premiumOffer:
          await _navigateToPremium(context, data);
          break;
        
        case NotificationType.customMessage:
          await _navigateToMessages(context, data);
          break;
        
        case NotificationType.unknown:
          Logger.warning('알 수 없는 알림 타입: ${data['type']}', tag: 'DeepLink');
          await _navigateToHome(context);
          break;
      }
    } catch (error, stackTrace) {
      Logger.error(
        '딥링크 처리 실패',
        error: error,
        stackTrace: stackTrace,
        tag: 'DeepLink',
      );
      // 에러 발생 시 홈 화면으로 이동
      await _navigateToHome(context);
    }
  }

  /// 알림 타입 파싱 (테스트용으로 public)
  @visibleForTesting
  NotificationType parseNotificationType(dynamic typeValue) {
    if (typeValue == null) return NotificationType.unknown;
    
    final typeString = typeValue.toString().toLowerCase();
    
    switch (typeString) {
      case 'league_update':
        return NotificationType.leagueUpdate;
      case 'friend_request':
        return NotificationType.friendRequest;
      case 'achievement':
        return NotificationType.achievement;
      case 'streak_reminder':
        return NotificationType.streakReminder;
      case 'lesson_complete':
        return NotificationType.lessonComplete;
      case 'weekly_test_available':
        return NotificationType.weeklyTestAvailable;
      case 'premium_offer':
        return NotificationType.premiumOffer;
      case 'custom_message':
        return NotificationType.customMessage;
      default:
        return NotificationType.unknown;
    }
  }

  /// 리그 화면으로 이동
  Future<void> _navigateToLeague(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    Logger.info('리그 화면으로 이동', tag: 'DeepLink');

    if (!context.mounted) return;

    // 현재 다이얼로그나 bottom sheet를 모두 닫고 메인 화면으로
    Navigator.of(context).popUntil((route) => route.isFirst);

    // TODO: NavigationProvider를 사용하여 탭 인덱스 변경 필요
    // ref.read(navigationProvider.notifier).setTab(4); // LeagueScreen
  }

  /// 친구 화면으로 이동
  Future<void> _navigateToFriends(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    Logger.info('친구 화면으로 이동', tag: 'DeepLink');

    if (!context.mounted) return;

    Navigator.of(context).popUntil((route) => route.isFirst);

    // TODO: NavigationProvider를 사용하여 탭 인덱스 변경 필요
    // 친구 요청 ID가 있으면 상세 화면으로 추가 이동
    final requestId = data['requestId'];
    if (requestId != null) {
      Logger.debug('친구 요청 ID: $requestId', tag: 'DeepLink');
    }
  }

  /// 업적 화면으로 이동
  Future<void> _navigateToAchievements(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    Logger.info('업적 화면으로 이동', tag: 'DeepLink');

    if (!context.mounted) return;

    Navigator.of(context).popUntil((route) => route.isFirst);

    final achievementId = data['achievementId'];
    if (achievementId != null) {
      Logger.debug('업적 ID: $achievementId', tag: 'DeepLink');
    }
  }

  /// 홈 화면으로 이동
  Future<void> _navigateToHome(BuildContext context) async {
    Logger.info('홈 화면으로 이동', tag: 'DeepLink');

    if (!context.mounted) return;

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  /// 레슨 화면으로 이동
  Future<void> _navigateToLesson(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    Logger.info('레슨 화면으로 이동', tag: 'DeepLink');

    if (!context.mounted) return;

    Navigator.of(context).popUntil((route) => route.isFirst);

    final lessonId = data['lessonId'];
    final unitId = data['unitId'];

    if (lessonId != null && unitId != null) {
      Logger.debug('레슨 ID: $lessonId, 유닛 ID: $unitId', tag: 'DeepLink');
    }
  }

  /// 주간 테스트 화면으로 이동
  Future<void> _navigateToWeeklyTest(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    Logger.info('주간 테스트 화면으로 이동', tag: 'DeepLink');

    if (!context.mounted) return;

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  /// 프리미엄 화면으로 이동
  Future<void> _navigateToPremium(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    Logger.info('프리미엄 화면으로 이동', tag: 'DeepLink');

    if (!context.mounted) return;

    Navigator.of(context).popUntil((route) => route.isFirst);

    final promoCode = data['promoCode'];
    if (promoCode != null) {
      Logger.debug('프로모션 코드: $promoCode', tag: 'DeepLink');
    }
  }

  /// 메시지 화면으로 이동
  Future<void> _navigateToMessages(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    Logger.info('메시지 화면으로 이동', tag: 'DeepLink');

    if (!context.mounted) return;

    Navigator.of(context).popUntil((route) => route.isFirst);
    
    // 특정 채팅방 ID가 있으면 해당 채팅방으로 이동
    final chatRoomId = data['chatRoomId'];
    if (chatRoomId != null) {
      // TODO: 특정 채팅방 상세 화면으로 이동
      Logger.debug('채팅방 ID: $chatRoomId', tag: 'DeepLink');
    }
  }

  /// URL 스키마 처리 (Universal Links / App Links)
  Future<void> handleDeepLinkUrl(
    BuildContext context,
    String url,
  ) async {
    try {
      Logger.info('Deep Link URL 처리: $url', tag: 'DeepLink');
      
      final uri = Uri.parse(url);
      final path = uri.path;
      final queryParams = uri.queryParameters;
      
      // URL 패턴별 처리
      if (path.startsWith('/league')) {
        await _navigateToLeague(context, queryParams);
      } else if (path.startsWith('/friends')) {
        await _navigateToFriends(context, queryParams);
      } else if (path.startsWith('/achievements')) {
        await _navigateToAchievements(context, queryParams);
      } else if (path.startsWith('/lesson')) {
        await _navigateToLesson(context, queryParams);
      } else if (path.startsWith('/weekly-test')) {
        await _navigateToWeeklyTest(context, queryParams);
      } else if (path.startsWith('/premium')) {
        await _navigateToPremium(context, queryParams);
      } else if (path.startsWith('/messages')) {
        await _navigateToMessages(context, queryParams);
      } else {
        await _navigateToHome(context);
      }
    } catch (error, stackTrace) {
      Logger.error(
        'Deep Link URL 처리 실패',
        error: error,
        stackTrace: stackTrace,
        tag: 'DeepLink',
      );
      await _navigateToHome(context);
    }
  }
}
