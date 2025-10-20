import 'package:flutter/services.dart';

/// 햅틱 피드백 유틸리티
/// 듀오링고 스타일의 촉각 피드백 제공
class AppHapticFeedback {
  AppHapticFeedback._(); // private constructor

  /// 가벼운 햅틱 (탭, 선택)
  static Future<void> lightImpact() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      // 햅틱을 지원하지 않는 디바이스에서는 무시
    }
  }

  /// 중간 햅틱 (정답)
  static Future<void> mediumImpact() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      // 햅틱을 지원하지 않는 디바이스에서는 무시
    }
  }

  /// 강한 햅틱 (오답, 레벨업)
  static Future<void> heavyImpact() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      // 햅틱을 지원하지 않는 디바이스에서는 무시
    }
  }

  /// 선택 햅틱 (아이템 선택)
  static Future<void> selectionClick() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      // 햅틱을 지원하지 않는 디바이스에서는 무시
    }
  }

  /// 성공 햅틱 (정답, 완료)
  static Future<void> success() async {
    await mediumImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await lightImpact();
  }

  /// 실패 햅틱 (오답)
  static Future<void> error() async {
    await heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await heavyImpact();
  }

  /// 레벨업 햅틱 (축하)
  static Future<void> levelUp() async {
    await heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await lightImpact();
  }
}