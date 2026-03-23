import 'package:flutter/material.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../core/utils/app_logger.dart';
import '../../../data/services/analytics_service.dart';
import 'coach_mark_overlay.dart';

/// 코치마크를 관리하는 컨트롤러
/// 앱 온보딩 완료 상태를 추적하고 오버레이를 표시/숨김
class CoachMarkController {
  static const String _onboardingKey = 'onboarding_completed';
  static final LocalStorageService _storage = LocalStorageService();

  /// 온보딩 완료 여부 확인
  static Future<bool> isCompleted() async {
    try {
      final data = await _storage.loadMap(_onboardingKey);
      return data?['completed'] == true;
    } catch (e) {
      AppLogger.error('Failed to check onboarding status', error: e);
      return false;
    }
  }

  /// 온보딩 완료 처리
  static Future<void> markCompleted() async {
    try {
      await _storage.saveMap(_onboardingKey, {
        'completed': true,
        'completedAt': DateTime.now().toIso8601String(),
      });

      await AnalyticsService().logEvent(
        name: 'coach_mark_onboarding_complete',
        parameters: {
          'completed_at': DateTime.now().toIso8601String(),
        },
      );

      AppLogger.info('Coach mark onboarding completed');
    } catch (e) {
      AppLogger.error('Failed to mark onboarding complete', error: e);
    }
  }

  /// 온보딩 초기화 (테스트용)
  static Future<void> reset() async {
    try {
      await _storage.remove(_onboardingKey);
      AppLogger.info('Coach mark onboarding reset');
    } catch (e) {
      AppLogger.error('Failed to reset onboarding', error: e);
    }
  }

  /// 코치마크 오버레이를 표시
  static void show({
    required BuildContext context,
    required List<CoachMarkStep> steps,
    VoidCallback? onComplete,
    ValueChanged<int>? onTabChange,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => CoachMarkOverlay(
        steps: steps,
        onComplete: () async {
          entry.remove();
          await markCompleted();
          onComplete?.call();
        },
        onSkip: () async {
          entry.remove();
          await markCompleted();
          onComplete?.call();
        },
        onTabChange: onTabChange,
      ),
    );

    overlay.insert(entry);
  }
}
