import 'package:flutter/material.dart';

enum ShopItemType { heartRefill, heartSingle, streakFreeze, xpBoost }

class ShopItem {
  final String id;
  final String name;
  final String description;
  final int gemCost;
  final ShopItemType type;
  final IconData icon;
  final Color color;
  final bool isEnabled;

  const ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.gemCost,
    required this.type,
    required this.icon,
    required this.color,
    this.isEnabled = true,
  });

  static const List<ShopItem> allItems = [
    ShopItem(
      id: 'heart_refill',
      name: '하트 충전',
      description: '하트를 5개로 가득 채웁니다',
      gemCost: 50,
      type: ShopItemType.heartRefill,
      icon: Icons.favorite,
      color: Color(0xFFFF4B6E),
    ),
    ShopItem(
      id: 'heart_single',
      name: '하트 1개',
      description: '하트를 1개 추가합니다',
      gemCost: 10,
      type: ShopItemType.heartSingle,
      icon: Icons.favorite_border,
      color: Color(0xFFFF6B8A),
    ),
    ShopItem(
      id: 'streak_freeze',
      name: '스트릭 보호',
      description: '하루 학습을 건너뛰어도 스트릭 유지',
      gemCost: 100,
      type: ShopItemType.streakFreeze,
      icon: Icons.shield,
      color: Color(0xFF45A6AD),
    ),
    ShopItem(
      id: 'xp_boost',
      name: 'XP 2배 부스터',
      description: '24시간 동안 XP 2배 획득 (준비 중)',
      gemCost: 80,
      type: ShopItemType.xpBoost,
      icon: Icons.bolt,
      color: Color(0xFFFFB800),
      isEnabled: false,
    ),
  ];
}
