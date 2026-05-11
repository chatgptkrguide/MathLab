import 'package:flutter_test/flutter_test.dart';
import 'package:mathlab/shared/constants/game_constants.dart';

void main() {
  group('GameConstants.leagueRange', () {
    test('bronze returns [0, 500]', () {
      expect(GameConstants.leagueRange('bronze'), [0, 500]);
    });

    test('silver returns [500, 1100]', () {
      expect(GameConstants.leagueRange('silver'), [500, 1100]);
    });

    test('gold returns [1100, 2500]', () {
      expect(GameConstants.leagueRange('gold'), [1100, 2500]);
    });

    test('diamond returns [2500, 5000]', () {
      expect(GameConstants.leagueRange('diamond'), [2500, 5000]);
    });

    test('master returns [5000, 10000]', () {
      expect(GameConstants.leagueRange('master'), [5000, 10000]);
    });

    test('미정의 리그는 bronze fallback [0, 500]을 반환한다', () {
      expect(GameConstants.leagueRange('unknown'), [0, 500]);
      expect(GameConstants.leagueRange(''), [0, 500]);
      expect(GameConstants.leagueRange('platinum'), [0, 500]);
    });

    test('대소문자 구분 없이 동작한다 (uppercase)', () {
      expect(GameConstants.leagueRange('BRONZE'), [0, 500]);
      expect(GameConstants.leagueRange('Silver'), [500, 1100]);
      expect(GameConstants.leagueRange('GOLD'), [1100, 2500]);
    });

    test('leagueXpThresholds 에 5개 리그가 정의되어 있다', () {
      expect(GameConstants.leagueXpThresholds.keys,
          containsAll(['bronze', 'silver', 'gold', 'diamond', 'master']));
      expect(GameConstants.leagueXpThresholds.length, 5);
    });

    test('각 리그의 최솟값이 이전 리그의 최댓값과 일치한다 (연속성 검증)', () {
      final ranges = [
        GameConstants.leagueRange('bronze'),
        GameConstants.leagueRange('silver'),
        GameConstants.leagueRange('gold'),
        GameConstants.leagueRange('diamond'),
        GameConstants.leagueRange('master'),
      ];

      for (var i = 0; i < ranges.length - 1; i++) {
        expect(ranges[i][1], ranges[i + 1][0],
            reason: 'league[$i] max should equal league[${i + 1}] min');
      }
    });

    test('xpPerCorrectAnswer, xpPerPerfectLesson 등 XP 상수가 양수이다', () {
      expect(GameConstants.xpPerCorrectAnswer, greaterThan(0));
      expect(GameConstants.xpPerPerfectLesson, greaterThan(0));
      expect(GameConstants.xpStreakBonus, greaterThan(0));
    });

    test('maxHearts 는 0보다 크다', () {
      expect(GameConstants.maxHearts, greaterThan(0));
    });

    test('heartRegenMinutes 는 양수이다', () {
      expect(GameConstants.heartRegenMinutes, greaterThan(0));
    });
  });
}
