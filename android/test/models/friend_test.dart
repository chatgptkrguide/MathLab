import 'package:flutter_test/flutter_test.dart';
import 'package:mathlab/data/models/user/friend.dart';

void main() {
  group('Friend Model', () {
    test('should have photoUrl getter', () {
      final friend = Friend(
        id: 'test-id',
        userId: 'user-123',
        name: 'Test User',
        profileImageUrl: 'https://example.com/photo.jpg',
        level: 5,
        xp: 1000,
        createdAt: DateTime.now(),
      );

      expect(friend.photoUrl, 'https://example.com/photo.jpg');
      expect(friend.photoUrl, friend.profileImageUrl);
    });

    test('photoUrl should return null when profileImageUrl is null', () {
      final friend = Friend(
        id: 'test-id',
        userId: 'user-123',
        name: 'Test User',
        level: 5,
        xp: 1000,
        createdAt: DateTime.now(),
      );

      expect(friend.photoUrl, isNull);
    });
  });
}
