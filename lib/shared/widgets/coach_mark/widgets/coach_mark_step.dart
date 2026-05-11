// Data classes for coach mark steps and arrow direction.
import 'package:flutter/material.dart';

/// 코치마크 단계 데이터
class CoachMarkStep {
  final GlobalKey targetKey;
  final String title;
  final String description;
  final ArrowDirection arrowDirection;
  final EdgeInsets tooltipOffset;
  final int? tabIndex; // null = 현재 탭 유지

  const CoachMarkStep({
    required this.targetKey,
    required this.title,
    required this.description,
    this.arrowDirection = ArrowDirection.up,
    this.tooltipOffset = EdgeInsets.zero,
    this.tabIndex,
  });
}

enum ArrowDirection { up, down, left, right }
