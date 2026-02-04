import 'package:flutter/material.dart';

/// Figma 디자인 색상 상수
class FigmaColors {
  FigmaColors._();

  // === 피그마 메인 색상 ===
  static const Color skyBlue = Color(0xFF61A1D8);       // 앱 메인 배경
  static const Color darkNavy = Color(0xFF211E41);       // 스플래시/로그인 배경
  static const Color royalBlue = Color(0xFF4575F6);      // 액센트
  static const Color deepBlue = Color(0xFF0014F7);       // CTA 버튼
  static const Color gold = Color(0xFFF3C283);           // 챌린지 카드
  static const Color tealGreen = Color(0xFF45A6AD);      // 진행률 바

  // === 기존 색상 유지 ===
  static const Color primary = Color(0xFF1CB0F6);
  static const Color secondary = Color(0xFF58CC02);

  // === 노드 색상 (피그마) ===
  static const Color nodeGreen = Color(0xFF58CC02);      // 완료된 노드
  static const Color nodeLocked = Color(0xFFB0B0B0);     // 잠긴 노드
  static const Color nodeOrange = Color(0xFFFF9600);     // Practice 노드
  static const Color nodePurple = Color(0xFFCE82FF);     // Story 노드
  static const Color nodeRed = Color(0xFFFF4B4B);        // Challenge 노드
  static const Color nodeBoss = Color(0xFF8B5CF6);       // Boss 노드
  static const Color nodeActive = Color(0xFF2B59FF);     // 활성 노드 배경
  static const Color nodeLockedBg = Color(0xFFE4E9EA);   // 잠금 노드 배경
  static const Color nodeUnlockedBg = Color(0xFFE4F5FF); // 언락 노드 배경
  static const Color nodeHighlight = Color(0xFFD5F0FF);  // 하이라이트 노드

  // === 피그마 텍스트/UI 색상 ===
  static const Color textDark = Color(0xFF2A2E2D);       // 메인 텍스트
  static const Color textSecondary = Color(0xFF7D8381);  // 보조 텍스트
  static const Color textLight = Color(0xFFAAAAAA);      // 비활성 텍스트
  static const Color cardBg = Color(0xFFF5F5F5);         // 카드 배경
  static const Color chipBg = Color(0xFFF1F2F1);         // 칩 배경
  static const Color profileBg = Color(0xFFE4F5FF);      // 프로필 카드 배경
  static const Color premiumBg = Color(0xFFD3E9FF);      // 프리미엄 카드 배경
  static const Color premiumBlue = Color(0xFF2E90FA);    // 프리미엄 라벨
  static const Color badgeOrange = Color(0xFFFF9121);    // 뱃지 오렌지
  static const Color streakGold = Color(0xFFFFB53E);     // 스트릭 골드

  // === 그라디언트 ===
  static const LinearGradient homeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF61A1D8), Color(0xFF5494C8)],
  );

  static const LinearGradient skyBlueGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF61A1D8), Color(0xFF4A8BC2)],
  );

  static const LinearGradient tealGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF45A6AD), Color(0xFF3A8F95)],
  );

  static const LinearGradient deepBlueCTA = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A3CF7), Color(0xFF0014F7)],
  );

  static const LinearGradient greenCTA = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF58CC02), Color(0xFF46A302)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF3C283), Color(0xFFE8A85C)],
  );
}
