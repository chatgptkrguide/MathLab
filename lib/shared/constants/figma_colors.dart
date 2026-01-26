import 'package:flutter/material.dart';

/// Figma 디자인 색상 상수
class FigmaColors {
  FigmaColors._();

  // 홈 그라데이션
  static const LinearGradient homeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1CB0F6), Color(0xFF1899D6)],
  );

  // 기타 색상
  static const Color primary = Color(0xFF1CB0F6);
  static const Color secondary = Color(0xFF58CC02);
}
