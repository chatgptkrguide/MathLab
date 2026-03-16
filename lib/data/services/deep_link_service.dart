import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/infrastructure/navigation_provider.dart';
import '../../core/utils/app_logger.dart';

class DeepLinkService {
  final WidgetRef ref;

  DeepLinkService(this.ref);

  String? _pendingDeepLink;
  String? get pendingDeepLink => _pendingDeepLink;

  void clearPendingDeepLink() => _pendingDeepLink = null;

  Future<void> initialize() async {
    // 앱이 deep link로 열린 경우 초기 URI 처리
    try {
      final initialUri = await _getInitialUri();
      if (initialUri != null) {
        _pendingDeepLink = initialUri;
        AppLogger.info('Initial deep link: $initialUri', tag: 'DeepLink');
      }
    } catch (e) {
      AppLogger.error('Deep link init failed', tag: 'DeepLink', error: e);
    }
  }

  Future<String?> _getInitialUri() async {
    // Phase 2: Platform channel로 초기 URI 가져오기
    // MethodChannel('app.mathlab/deeplink').invokeMethod('getInitialUri')
    return null;
  }

  void dispose() {
    // Phase 2: Stream subscription cleanup
    _pendingDeepLink = null;
  }

  /// URI 문자열을 파싱하여 적절한 화면으로 네비게이션
  void handleDeepLink(BuildContext context, String link) {
    final uri = Uri.tryParse(link);
    if (uri == null) {
      AppLogger.warning('Invalid deep link: $link', tag: 'DeepLink');
      return;
    }

    _handleUri(context, uri);
  }

  /// URI 객체를 직접 처리 (기존 handleDeepLink(Uri) 호환)
  void handleDeepLinkUri(BuildContext context, Uri uri) {
    _handleUri(context, uri);
  }

  /// 내부 URI 라우팅 처리
  void _handleUri(BuildContext context, Uri uri) {
    AppLogger.info('Handling deep link: ${uri.path}', tag: 'DeepLink');

    final firstSegment = uri.pathSegments.isNotEmpty
        ? uri.pathSegments.first
        : null;

    if (firstSegment == null) {
      AppLogger.warning('Empty deep link path', tag: 'DeepLink');
      return;
    }

    switch (firstSegment) {
      case 'lesson':
        _navigateToLesson(context, uri);
      case 'friend':
      case 'friend_request':
        _navigateToFriend(context, uri);
      case 'message':
        _navigateToMessage(context, uri);
      case 'profile':
        _navigateToProfile(context, uri);
      case 'achievement':
        _navigateToAchievement(context, uri);
      case 'team':
        _navigateToTeam(context, uri);
      default:
        AppLogger.warning(
          'Unknown deep link path: ${uri.path}',
          tag: 'DeepLink',
        );
    }
  }

  /// Handle notification data and navigate accordingly
  void handleNotification(BuildContext context, Map<String, dynamic> data) {
    AppLogger.info('Processing notification: $data', tag: 'DeepLink');

    try {
      final type = data['type'] as String?;
      final targetId = data['targetId'] as String?;

      if (type == null) {
        AppLogger.warning('Notification type is null', tag: 'DeepLink');
        return;
      }

      switch (type) {
        case 'lesson':
          if (targetId != null) {
            AppLogger.info('Navigate to lesson: $targetId', tag: 'DeepLink');
            // Phase 2: Navigator.push to lesson screen with targetId
          }
          ref.read(navigationProvider.notifier).goToLessons();

        case 'achievement':
          ref.read(navigationProvider.notifier).setTab(3); // 프로필 탭
          AppLogger.info('Navigate to achievement', tag: 'DeepLink');

        case 'friend_request':
          AppLogger.info('Navigate to friend request', tag: 'DeepLink');
          // Phase 2: Navigator.push to friends screen

        case 'message':
          if (targetId != null) {
            AppLogger.info('Navigate to message: $targetId', tag: 'DeepLink');
          }
          // Phase 2: Navigator.push to message detail screen

        case 'team':
          ref.read(navigationProvider.notifier).goToTeam();
          AppLogger.info('Navigate to team', tag: 'DeepLink');

        default:
          AppLogger.warning(
            'Unknown notification type: $type',
            tag: 'DeepLink',
          );
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to handle notification',
        error: e,
        stackTrace: stackTrace,
        tag: 'DeepLink',
      );
    }
  }

  /// 대기 중인 딥링크가 있으면 처리
  void processPendingDeepLink(BuildContext context) {
    if (_pendingDeepLink != null) {
      handleDeepLink(context, _pendingDeepLink!);
      clearPendingDeepLink();
    }
  }

  // ──────────────────────────────────────────
  // Private navigation methods
  // ──────────────────────────────────────────

  void _navigateToLesson(BuildContext context, Uri uri) {
    final lessonId = uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
    if (lessonId == null) {
      // lessonId 없으면 학습 탭으로만 이동
      ref.read(navigationProvider.notifier).goToLessons();
      return;
    }
    AppLogger.info('Navigate to lesson: $lessonId', tag: 'DeepLink');
    ref.read(navigationProvider.notifier).goToLessons();
    // Phase 2: Navigator.push to specific lesson screen with lessonId
  }

  void _navigateToFriend(BuildContext context, Uri uri) {
    final friendId = uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
    AppLogger.info(
      'Navigate to friends${friendId != null ? ': $friendId' : ''}',
      tag: 'DeepLink',
    );
    // Phase 2: Navigator.push to friends screen (with optional friendId)
  }

  void _navigateToMessage(BuildContext context, Uri uri) {
    final messageId = uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
    AppLogger.info(
      'Navigate to message${messageId != null ? ': $messageId' : ''}',
      tag: 'DeepLink',
    );
    // Phase 2: Navigator.push to message detail screen
  }

  void _navigateToProfile(BuildContext context, Uri uri) {
    AppLogger.info('Navigate to profile', tag: 'DeepLink');
    ref.read(navigationProvider.notifier).goToProfile();
  }

  void _navigateToAchievement(BuildContext context, Uri uri) {
    AppLogger.info('Navigate to achievement', tag: 'DeepLink');
    ref.read(navigationProvider.notifier).goToProfile();
    // Phase 2: Open achievement detail overlay
  }

  void _navigateToTeam(BuildContext context, Uri uri) {
    AppLogger.info('Navigate to team', tag: 'DeepLink');
    ref.read(navigationProvider.notifier).goToTeam();
  }
}
