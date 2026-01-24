import 'package:flutter_test/flutter_test.dart';
import 'package:mathlab/data/repositories/friend_repository.dart';

void main() {
  group('FriendRepository', () {
    late FriendRepository repository;

    setUp(() {
      repository = FriendRepository();
    });

    test('should be created', () {
      expect(repository, isNotNull);
      expect(repository.repositoryName, 'FriendRepository');
    });

    // TODO: Add more tests with Firebase emulator
  });
}
