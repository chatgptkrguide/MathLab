import 'package:flutter_test/flutter_test.dart';
import 'package:mathlab/data/models/user/user_model.dart';

void main() {
  // 테스트에 사용할 기준 시각 (고정값으로 플레이크 방지)
  final fixedNow = DateTime(2024, 6, 15, 12, 0);

  // 기본 UserModel 팩토리
  UserModel makeUser({
    String uid = 'uid-001',
    String? displayName = '홍길동',
    String? email = 'test@example.com',
    AuthProvider provider = AuthProvider.email,
    bool isGuest = false,
    int level = 3,
    int xp = 200,
    int totalXp = 500,
    int hearts = 5,
    int streak = 7,
    String league = 'Silver',
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName,
      authProvider: provider,
      isGuest: isGuest,
      level: level,
      xp: xp,
      totalXp: totalXp,
      hearts: hearts,
      maxHearts: 5,
      streak: streak,
      league: league,
      createdAt: fixedNow,
      updatedAt: fixedNow,
    );
  }

  group('UserModel — toJson', () {
    test('toJson contains all required fields', () {
      final user = makeUser();
      final json = user.toJson();

      expect(json['uid'], 'uid-001');
      expect(json['email'], 'test@example.com');
      expect(json['displayName'], '홍길동');
      expect(json['authProvider'], 'email');
      expect(json['isGuest'], false);
      expect(json['level'], 3);
      expect(json['xp'], 200);
      expect(json['totalXp'], 500);
      expect(json['streak'], 7);
      expect(json['league'], 'Silver');
    });

    test('toJson serializes DateTime as ISO-8601 string', () {
      final user = makeUser();
      final json = user.toJson();

      expect(json['createdAt'], isA<String>());
      expect(DateTime.parse(json['createdAt'] as String), fixedNow);
    });

    test('toJson null optional fields are preserved as null', () {
      final user = makeUser(email: null);
      final json = user.toJson();

      expect(json['email'], isNull);
      expect(json['lastLoginAt'], isNull);
      expect(json['lastStudyDate'], isNull);
    });

    test('toJson achievements serialized as list', () {
      final user = UserModel(
        uid: 'u1',
        authProvider: AuthProvider.google,
        achievements: ['first_lesson', 'streak_7'],
        createdAt: fixedNow,
        updatedAt: fixedNow,
      );
      final json = user.toJson();

      expect(json['achievements'], ['first_lesson', 'streak_7']);
    });
  });

  group('UserModel — copyWith', () {
    test('copyWith returns new instance with updated fields', () {
      final original = makeUser(level: 1, xp: 0);
      final updated = original.copyWith(level: 5, xp: 450);

      expect(updated.level, 5);
      expect(updated.xp, 450);
      // 변경하지 않은 필드는 보존
      expect(updated.uid, original.uid);
      expect(updated.displayName, original.displayName);
    });

    test('copyWith preserves identity of unchanged fields', () {
      final original = makeUser();
      final updated = original.copyWith(streak: 10);

      expect(updated.email, original.email);
      expect(updated.league, original.league);
      expect(updated.streak, 10);
    });

    test('copyWith does not mutate original', () {
      final original = makeUser(hearts: 5);
      original.copyWith(hearts: 0);

      expect(original.hearts, 5);
    });
  });

  group('UserModel — isProfileComplete', () {
    test('returns true when displayName is non-empty', () {
      final user = makeUser(displayName: '홍길동');
      expect(user.isProfileComplete, isTrue);
    });

    test('returns false when displayName is null', () {
      final user = makeUser(displayName: null);
      expect(user.isProfileComplete, isFalse);
    });

    test('returns false when displayName is empty string', () {
      final user = makeUser(displayName: '');
      expect(user.isProfileComplete, isFalse);
    });
  });

  group('UserModel — business logic getters', () {
    test('isAdmin true only for role=admin', () {
      final admin = makeUser().copyWith(role: 'admin');
      final normal = makeUser();

      expect(admin.isAdmin, isTrue);
      expect(normal.isAdmin, isFalse);
    });

    test('hasHearts false when hearts == 0', () {
      final user = makeUser(hearts: 0);
      expect(user.hasHearts, isFalse);
    });

    test('hasHearts true when hearts > 0', () {
      final user = makeUser(hearts: 3);
      expect(user.hasHearts, isTrue);
    });

    test('hasFullHearts true when hearts == maxHearts', () {
      final user = makeUser(hearts: 5);
      expect(user.hasFullHearts, isTrue);
    });

    test('hasFullHearts false when hearts < maxHearts', () {
      final user = makeUser(hearts: 4);
      expect(user.hasFullHearts, isFalse);
    });

    test('xpNeededForNextLevel grows with level', () {
      final lvl1 = makeUser(level: 1);
      final lvl5 = makeUser(level: 5);

      expect(lvl5.xpNeededForNextLevel, greaterThan(lvl1.xpNeededForNextLevel));
    });

    test('levelProgress is clamped between 0 and 1', () {
      // xp가 필요량을 초과해도 1.0을 넘지 않아야 함
      final user = makeUser(level: 1, xp: 99999);
      expect(user.levelProgress, lessThanOrEqualTo(1.0));
      expect(user.levelProgress, greaterThanOrEqualTo(0.0));
    });

    test('leagueTier maps correctly', () {
      expect(makeUser(league: 'Bronze').leagueTier, 0);
      expect(makeUser(league: 'Silver').leagueTier, 1);
      expect(makeUser(league: 'Gold').leagueTier, 2);
      expect(makeUser(league: 'Diamond').leagueTier, 3);
      expect(makeUser(league: 'Master').leagueTier, 4);
      expect(makeUser(league: 'unknown').leagueTier, 0); // fallback
    });

    test('equality is based on uid only', () {
      final a = makeUser(uid: 'same-uid', level: 1);
      final b = makeUser(uid: 'same-uid', level: 99);
      final c = makeUser(uid: 'other-uid');

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('id getter returns uid', () {
      final user = makeUser(uid: 'abc-123');
      expect(user.id, 'abc-123');
    });
  });

  group('UserModel — guest factory', () {
    test('guest user has isGuest=true and displayName=게스트', () {
      final guest = UserModel.guest('guest-uid-1');

      expect(guest.isGuest, isTrue);
      expect(guest.displayName, '게스트');
      expect(guest.authProvider, AuthProvider.guest);
    });
  });

  group('UserModel — AuthProvider enum', () {
    test('all AuthProvider values can be serialized and round-tripped via name', () {
      for (final provider in AuthProvider.values) {
        final name = provider.name;
        final parsed = AuthProvider.values.firstWhere((e) => e.name == name);
        expect(parsed, provider);
      }
    });
  });
}
