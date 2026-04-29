import 'package:flutter_test/flutter_test.dart';
import 'package:mathlab/core/security/rate_limiter.dart';

void main() {
  // 각 테스트 전 상태 초기화 (singleton 공유로 인한 오염 방지)
  setUp(() {
    RateLimiter.clearAll();
  });

  tearDown(() {
    RateLimiter.clearAll();
  });

  group('RateLimiter — isAllowed basic behavior', () {
    test('first attempt is always allowed', () {
      final allowed = RateLimiter.isAllowed(
        'user@example.com',
        context: RateLimitContext.login,
      );
      expect(allowed, isTrue);
    });

    test('attempts within limit are all allowed', () {
      // login 한도: 5회
      for (int i = 0; i < 5; i++) {
        final allowed = RateLimiter.isAllowed(
          'test-user',
          context: RateLimitContext.login,
        );
        expect(allowed, isTrue, reason: 'attempt ${i + 1} should be allowed');
      }
    });

    test('6th attempt triggers lockout and is denied', () {
      for (int i = 0; i < 5; i++) {
        RateLimiter.isAllowed('locked-user', context: RateLimitContext.login);
      }
      final sixthAttempt = RateLimiter.isAllowed(
        'locked-user',
        context: RateLimitContext.login,
      );
      expect(sixthAttempt, isFalse);
    });

    test('different identifiers are isolated from each other', () {
      // user-A를 한도까지 소진
      for (int i = 0; i < 5; i++) {
        RateLimiter.isAllowed('user-A', context: RateLimitContext.login);
      }
      // user-B는 첫 시도이므로 허용되어야 함
      final userBAllowed = RateLimiter.isAllowed(
        'user-B',
        context: RateLimitContext.login,
      );
      expect(userBAllowed, isTrue);
    });

    test('different contexts are isolated for same identifier', () {
      // login 컨텍스트 한도 소진
      for (int i = 0; i < 5; i++) {
        RateLimiter.isAllowed('same-user', context: RateLimitContext.login);
      }
      // passwordReset 컨텍스트는 별도 카운터
      final allowed = RateLimiter.isAllowed(
        'same-user',
        context: RateLimitContext.passwordReset,
      );
      expect(allowed, isTrue);
    });
  });

  group('RateLimiter — isLockedOut', () {
    test('not locked out initially', () {
      expect(
        RateLimiter.isLockedOut('new-user', context: RateLimitContext.login),
        isFalse,
      );
    });

    test('locked out after exceeding max attempts', () {
      for (int i = 0; i < 6; i++) {
        RateLimiter.isAllowed('victim', context: RateLimitContext.login);
      }
      expect(
        RateLimiter.isLockedOut('victim', context: RateLimitContext.login),
        isTrue,
      );
    });
  });

  group('RateLimiter — getRemainingAttempts', () {
    test('full attempts remaining on fresh identifier', () {
      final remaining = RateLimiter.getRemainingAttempts(
        'fresh-user',
        context: RateLimitContext.login,
      );
      // 아직 시도하지 않았으므로 maxAttempts = 5
      expect(remaining, 5);
    });

    test('remaining decreases after each attempt', () {
      RateLimiter.isAllowed('counting-user', context: RateLimitContext.login);
      final remaining = RateLimiter.getRemainingAttempts(
        'counting-user',
        context: RateLimitContext.login,
      );
      expect(remaining, 4);
    });

    test('remaining is 0 when locked out', () {
      for (int i = 0; i < 6; i++) {
        RateLimiter.isAllowed('maxed-user', context: RateLimitContext.login);
      }
      expect(
        RateLimiter.getRemainingAttempts('maxed-user', context: RateLimitContext.login),
        0,
      );
    });
  });

  group('RateLimiter — recordSuccess', () {
    test('recordSuccess resets attempt counter', () {
      for (int i = 0; i < 4; i++) {
        RateLimiter.isAllowed('reset-user', context: RateLimitContext.login);
      }
      // 성공 기록 → 카운터 초기화
      RateLimiter.recordSuccess('reset-user', context: RateLimitContext.login);

      final remaining = RateLimiter.getRemainingAttempts(
        'reset-user',
        context: RateLimitContext.login,
      );
      expect(remaining, 5); // 초기화 후 전체 한도
    });

    test('recordSuccess clears lockout', () {
      for (int i = 0; i < 6; i++) {
        RateLimiter.isAllowed('locked-user2', context: RateLimitContext.login);
      }
      RateLimiter.recordSuccess('locked-user2', context: RateLimitContext.login);

      expect(
        RateLimiter.isLockedOut('locked-user2', context: RateLimitContext.login),
        isFalse,
      );
    });
  });

  group('RateLimiter — getLockoutRemaining', () {
    test('returns null when not locked out', () {
      final remaining = RateLimiter.getLockoutRemaining(
        'free-user',
        context: RateLimitContext.login,
      );
      expect(remaining, isNull);
    });

    test('returns positive duration when locked out', () {
      for (int i = 0; i < 6; i++) {
        RateLimiter.isAllowed('locked3', context: RateLimitContext.login);
      }
      final remaining = RateLimiter.getLockoutRemaining(
        'locked3',
        context: RateLimitContext.login,
      );
      expect(remaining, isNotNull);
      expect(remaining!.inSeconds, greaterThan(0));
    });
  });

  group('RateLimiter — custom config', () {
    test('customConfig overrides default context limits', () {
      // maxAttempts=2 커스텀 설정
      const custom = RateLimitConfig(
        maxAttempts: 2,
        window: Duration(minutes: 1),
        lockoutDuration: Duration(minutes: 5),
        description: 'Custom test limit',
      );

      RateLimiter.isAllowed('custom-user', context: RateLimitContext.login, customConfig: custom);
      RateLimiter.isAllowed('custom-user', context: RateLimitContext.login, customConfig: custom);
      final third = RateLimiter.isAllowed(
        'custom-user',
        context: RateLimitContext.login,
        customConfig: custom,
      );
      expect(third, isFalse);
    });
  });

  group('RateLimiter — clearLimits', () {
    test('clearLimits resets all contexts for an identifier', () {
      for (int i = 0; i < 6; i++) {
        RateLimiter.isAllowed('clear-me', context: RateLimitContext.login);
      }
      expect(RateLimiter.isLockedOut('clear-me', context: RateLimitContext.login), isTrue);

      RateLimiter.clearLimits('clear-me');

      expect(RateLimiter.isLockedOut('clear-me', context: RateLimitContext.login), isFalse);
    });
  });

  group('RateLimiter — getStats', () {
    test('getStats reflects current state accurately', () {
      RateLimiter.isAllowed('stats-user', context: RateLimitContext.login);
      RateLimiter.isAllowed('stats-user', context: RateLimitContext.login);

      final stats = RateLimiter.getStats('stats-user', context: RateLimitContext.login);

      expect(stats.currentAttempts, 2);
      expect(stats.maxAttempts, 5);
      expect(stats.remainingAttempts, 3);
      expect(stats.isLockedOut, isFalse);
    });
  });

  group('RateLimiter — performCleanup', () {
    test('performCleanup does not throw on empty state', () {
      expect(() => RateLimiter.performCleanup(), returnsNormally);
    });

    test('performCleanup does not throw with active entries', () {
      RateLimiter.isAllowed('cleanup-user', context: RateLimitContext.login);
      expect(() => RateLimiter.performCleanup(), returnsNormally);
    });
  });

  group('RateLimitException', () {
    test('toString without retryAfter', () {
      final ex = RateLimitException('too many attempts');
      expect(ex.toString(), contains('too many attempts'));
    });

    test('toString with retryAfter includes minutes', () {
      final ex = RateLimitException(
        'wait',
        retryAfter: const Duration(minutes: 10),
      );
      expect(ex.toString(), contains('10 minutes'));
    });
  });
}
