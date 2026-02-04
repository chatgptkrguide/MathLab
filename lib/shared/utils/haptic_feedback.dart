import 'package:flutter/services.dart';

/// 앱 전체에서 사용하는 햅틱 피드백 유틸리티
/// Flutter의 HapticFeedback을 감싸는 래퍼 클래스
class AppHapticFeedback {
  /// 가벼운 햅틱 피드백 (버튼 탭 등)
  static Future<void> light() async {
    await HapticFeedback.lightImpact();
  }

  /// 가벼운 임팩트 (light의 별칭)
  static Future<void> lightImpact() async {
    await HapticFeedback.lightImpact();
  }

  /// 중간 강도 햅틱 피드백
  static Future<void> medium() async {
    await HapticFeedback.mediumImpact();
  }

  /// 강한 햅틱 피드백
  static Future<void> heavy() async {
    await HapticFeedback.heavyImpact();
  }

  /// 성공 피드백 (힌트 잠금 해제 등)
  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
  }

  /// 에러 피드백
  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
  }

  /// 선택 클릭 피드백 (페이지 전환 등)
  static Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }

  /// 진동 피드백
  static Future<void> vibrate() async {
    await HapticFeedback.vibrate();
  }
}
