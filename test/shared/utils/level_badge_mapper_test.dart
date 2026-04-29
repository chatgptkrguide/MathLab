import 'package:flutter_test/flutter_test.dart';
import 'package:mathlab/shared/utils/level_badge_mapper.dart';

void main() {
  group('LevelBadgeMapper.getBadgeForLevel', () {
    test('level 1-14 returns bronze', () {
      for (int lvl in [1, 5, 10, 14]) {
        expect(
          LevelBadgeMapper.getBadgeForLevel(lvl),
          LevelBadge.bronze,
          reason: 'level $lvl should be bronze',
        );
      }
    });

    test('level 15-29 returns silver', () {
      for (int lvl in [15, 20, 29]) {
        expect(
          LevelBadgeMapper.getBadgeForLevel(lvl),
          LevelBadge.silver,
          reason: 'level $lvl should be silver',
        );
      }
    });

    test('level 30-49 returns gold', () {
      for (int lvl in [30, 40, 49]) {
        expect(
          LevelBadgeMapper.getBadgeForLevel(lvl),
          LevelBadge.gold,
          reason: 'level $lvl should be gold',
        );
      }
    });

    test('level 50+ returns diamond', () {
      for (int lvl in [50, 99, 999]) {
        expect(
          LevelBadgeMapper.getBadgeForLevel(lvl),
          LevelBadge.diamond,
          reason: 'level $lvl should be diamond',
        );
      }
    });

    test('boundary level 15 returns silver not bronze', () {
      expect(LevelBadgeMapper.getBadgeForLevel(15), LevelBadge.silver);
    });

    test('boundary level 30 returns gold not silver', () {
      expect(LevelBadgeMapper.getBadgeForLevel(30), LevelBadge.gold);
    });

    test('boundary level 50 returns diamond not gold', () {
      expect(LevelBadgeMapper.getBadgeForLevel(50), LevelBadge.diamond);
    });
  });

  group('LevelBadgeMapper.getBadgeName', () {
    test('returns Korean display name', () {
      expect(LevelBadgeMapper.getBadgeName(1), '브론즈');
      expect(LevelBadgeMapper.getBadgeName(15), '실버');
      expect(LevelBadgeMapper.getBadgeName(30), '골드');
      expect(LevelBadgeMapper.getBadgeName(50), '다이아몬드');
    });
  });

  group('LevelBadgeMapper.getBadgeImagePath', () {
    test('returns correct asset path for bronze', () {
      expect(
        LevelBadgeMapper.getBadgeImagePath(1),
        'assets/images/badges/badge_bronze.png',
      );
    });

    test('returns correct asset path for diamond', () {
      expect(
        LevelBadgeMapper.getBadgeImagePath(50),
        'assets/images/badges/badge_diamond.png',
      );
    });

    test('path always ends with .png', () {
      for (int lvl in [1, 15, 30, 50]) {
        expect(LevelBadgeMapper.getBadgeImagePath(lvl), endsWith('.png'));
      }
    });
  });

  group('LevelBadge enum properties', () {
    test('all badges have non-empty assetName', () {
      for (final badge in LevelBadge.values) {
        expect(badge.assetName, isNotEmpty);
      }
    });

    test('all badges have non-empty displayName', () {
      for (final badge in LevelBadge.values) {
        expect(badge.displayName, isNotEmpty);
      }
    });

    test('assetNames are unique across badges', () {
      final names = LevelBadge.values.map((b) => b.assetName).toSet();
      expect(names.length, LevelBadge.values.length);
    });
  });
}
